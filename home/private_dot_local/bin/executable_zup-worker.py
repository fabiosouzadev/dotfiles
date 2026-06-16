#!/usr/bin/env python3
import datetime
import http.server
import json
import os
import shlex
import subprocess
import time
from pathlib import Path

HOST = "127.0.0.1"
PORT = int(os.environ.get("ZUP_WORKER_PORT", "9001"))
ALLOWED_BASE = Path(os.environ.get("ZUP_WORKER_ALLOWED_BASE", "/home/fabio.souza/Workspaces/Work/Zup")).resolve()
TOKEN = os.environ.get("ZUP_WORKER_TOKEN", "")
GPG_KEY = os.environ.get("ZUP_AGENT_GPG_KEY", "232EFD8553CB22E5")
MAX_TIMEOUT = int(os.environ.get("ZUP_WORKER_MAX_TIMEOUT", "1800"))
MAX_DIFF_CHARS = int(os.environ.get("ZUP_WORKER_MAX_DIFF_CHARS", "120000"))
PROTECTED_BRANCHES = {"main", "master", "pet"}


def shell_cd(repo: str, command: str) -> list[str]:
    return ["bash", "-lc", f"cd {shlex.quote(repo)} && {command}"]


AGENTS = {
    "opencode": lambda prompt, d, repo: shell_cd(repo, f"opencode run {shlex.quote(prompt)}"),
    "claude": lambda prompt, d, repo: shell_cd(repo, f"claude -p {shlex.quote(prompt)} --max-turns {int(d.get('max_turns', 12))}"),
    "codex": lambda prompt, d, repo: shell_cd(repo, f"codex exec --full-auto {shlex.quote(prompt)}"),
}


def response(handler, code, payload):
    body = json.dumps(payload, ensure_ascii=False, indent=2).encode()
    handler.send_response(code)
    handler.send_header("Content-Type", "application/json; charset=utf-8")
    handler.send_header("Content-Length", str(len(body)))
    handler.end_headers()
    handler.wfile.write(body)


def authed(handler):
    return bool(TOKEN) and handler.headers.get("Authorization") == f"Bearer {TOKEN}"


def run_cmd(cmd, repo_path, env, timeout=60):
    return subprocess.run(cmd, cwd=str(repo_path), env=env, text=True, capture_output=True, timeout=timeout)


def git_info(repo_path, env):
    def git(args, timeout=60):
        proc = run_cmd(["git", *args], repo_path, env, timeout=timeout)
        return {"exit_code": proc.returncode, "stdout": proc.stdout, "stderr": proc.stderr}

    inside = git(["rev-parse", "--is-inside-work-tree"])
    if inside["exit_code"] != 0 or inside["stdout"].strip() != "true":
        return {"is_git_repo": False, "error": inside}

    branch = git(["rev-parse", "--abbrev-ref", "HEAD"])
    status = git(["status", "--short"])
    changed = git(["diff", "--name-only", "HEAD", "--"])
    stat = git(["diff", "--stat", "HEAD", "--"])
    diff = git(["diff", "--binary", "HEAD", "--"], timeout=120)

    diff_text = diff["stdout"]
    truncated = False
    if len(diff_text) > MAX_DIFF_CHARS:
        diff_text = diff_text[:MAX_DIFF_CHARS] + "\n\n[TRUNCATED: diff exceeded ZUP_WORKER_MAX_DIFF_CHARS]"
        truncated = True

    return {
        "is_git_repo": True,
        "branch": branch["stdout"].strip(),
        "status_short": status["stdout"],
        "changed_files": [x for x in changed["stdout"].splitlines() if x.strip()],
        "diff_stat": stat["stdout"],
        "diff": diff_text,
        "diff_truncated": truncated,
    }


class Handler(http.server.BaseHTTPRequestHandler):
    server_version = "ZupWorker/1.2"

    def log_message(self, format, *args):
        print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] {self.client_address[0]} {format % args}", flush=True)

    def do_GET(self):
        if self.path != "/health":
            return response(self, 404, {"error": "not_found"})
        if not authed(self):
            return response(self, 403, {"error": "forbidden"})
        return response(self, 200, {
            "ok": True,
            "version": self.server_version,
            "host": os.uname().nodename,
            "allowed_base": str(ALLOWED_BASE),
            "agents": sorted(AGENTS.keys()),
            "gpg_key": GPG_KEY,
            "features": ["git_status", "diff", "diff_stat", "changed_files", "auto_branch", "auto_push"],
        })

    def do_POST(self):
        if self.path != "/task":
            return response(self, 404, {"error": "not_found"})
        if not authed(self):
            return response(self, 403, {"error": "forbidden"})

        try:
            length = int(self.headers.get("Content-Length", "0"))
            data = json.loads(self.rfile.read(length) or b"{}")
        except Exception as e:
            return response(self, 400, {"error": "invalid_json", "detail": str(e)})

        prompt = data.get("prompt")
        repo = data.get("repo")
        agent = data.get("agent", "opencode")
        include_diff = bool(data.get("include_diff", True))
        auto_branch = bool(data.get("auto_branch", True))
        auto_commit = bool(data.get("commit", False))
        auto_push = bool(data.get("push", False))
        commit_msg = data.get("commit_message", "chore: automatic update by zup-worker")

        if not prompt or not repo:
            return response(self, 400, {"error": "missing_required", "required": ["repo", "prompt"]})
        if agent not in AGENTS:
            return response(self, 400, {"error": "unsupported_agent", "supported": sorted(AGENTS.keys())})

        repo_path = Path(os.path.expanduser(repo)).resolve()
        if not (repo_path == ALLOWED_BASE or ALLOWED_BASE in repo_path.parents):
            return response(self, 400, {"error": "path_not_allowed", "repo": str(repo_path), "allowed_base": str(ALLOWED_BASE)})
        if not repo_path.exists():
            return response(self, 400, {"error": "repo_not_found", "repo": str(repo_path)})

        env = os.environ.copy()
        env.update({
            "GIT_CONFIG_COUNT": "3",
            "GIT_CONFIG_KEY_0": "user.signingkey",
            "GIT_CONFIG_VALUE_0": GPG_KEY,
            "GIT_CONFIG_KEY_1": "commit.gpgsign",
            "GIT_CONFIG_VALUE_1": "true",
            "GIT_CONFIG_KEY_2": "tag.gpgsign",
            "GIT_CONFIG_VALUE_2": "true",
        })

        before = git_info(repo_path, env) if include_diff else None
        if before and before.get("is_git_repo") and auto_branch and before.get("branch") in PROTECTED_BRANCHES:
            new_branch = data.get("branch_name") or f"task/{agent}-{datetime.datetime.now().strftime('%Y%m%d-%H%M%S')}"
            br = run_cmd(["git", "checkout", "-b", new_branch], repo_path, env)
            if br.returncode != 0:
                return response(self, 500, {"error": "auto_branch_failed", "detail": br.stderr})
            before = git_info(repo_path, env) if include_diff else None

        timeout = min(int(data.get("timeout", 900)), MAX_TIMEOUT)
        cmd = AGENTS[agent](prompt, data, str(repo_path))
        start = time.time()

        try:
            proc = subprocess.run(cmd, cwd=str(repo_path), env=env, text=True, capture_output=True, timeout=timeout)
            after = git_info(repo_path, env) if include_diff else None

            commit_res = None
            push_res = None
            if after and after.get("status_short") and auto_commit:
                add_res = run_cmd(["git", "add", "."], repo_path, env)
                if add_res.returncode == 0:
                    commit_run = run_cmd(["git", "commit", "-m", commit_msg], repo_path, env)
                    commit_res = {"exit_code": commit_run.returncode, "stdout": commit_run.stdout, "stderr": commit_run.stderr}
                    if commit_run.returncode == 0 and auto_push:
                        branch_name = after.get("branch") or before.get("branch") if before else None
                        if branch_name:
                            push_run = run_cmd(["git", "push", "origin", branch_name], repo_path, env)
                            push_res = {"exit_code": push_run.returncode, "stdout": push_run.stdout, "stderr": push_run.stderr}
                after = git_info(repo_path, env) if include_diff else None

            return response(self, 200, {
                "exit_code": proc.returncode,
                "duration_sec": round(time.time() - start, 2),
                "agent": agent,
                "repo": str(repo_path),
                "cmd": cmd[:2] + ["<prompt>"],
                "stdout": proc.stdout,
                "stderr": proc.stderr,
                "git_before": before,
                "git_after": after,
                "dirty": bool(after and after.get("status_short")),
                "auto_commit": commit_res,
                "auto_push": push_res,
            })
        except subprocess.TimeoutExpired as e:
            after = git_info(repo_path, env) if include_diff else None
            return response(self, 504, {
                "error": "timeout",
                "timeout": timeout,
                "agent": agent,
                "repo": str(repo_path),
                "stdout": e.stdout or "",
                "stderr": e.stderr or "",
                "git_before": before,
                "git_after": after,
                "dirty": bool(after and after.get("status_short")),
            })
        except Exception as e:
            return response(self, 500, {"error": "execution_failed", "detail": str(e)})


if __name__ == "__main__":
    if not TOKEN:
        raise SystemExit("ZUP_WORKER_TOKEN is required")
    print(f"Zup Worker listening on http://{HOST}:{PORT}; allowed_base={ALLOWED_BASE}", flush=True)
    http.server.ThreadingHTTPServer((HOST, PORT), Handler).serve_forever()
