#!/usr/bin/env python3
import http.server
import json
import os
import subprocess
import time
from pathlib import Path

HOST = "127.0.0.1"
PORT = int(os.environ.get("ZUP_WORKER_PORT", "9001"))
ALLOWED_BASE = Path(os.environ.get("ZUP_WORKER_ALLOWED_BASE", "/home/fabio.souza/Workspaces/Zup")).resolve()
TOKEN = os.environ.get("ZUP_WORKER_TOKEN", "")
GPG_KEY = os.environ.get("ZUP_AGENT_GPG_KEY", "232EFD8553CB22E5")
MAX_TIMEOUT = int(os.environ.get("ZUP_WORKER_MAX_TIMEOUT", "1800"))

AGENTS = {
    "opencode": lambda prompt, d: ["opencode", "run", prompt],
    "claude": lambda prompt, d: ["claude", "-p", prompt, "--max-turns", str(int(d.get("max_turns", 12)))],
    "codex": lambda prompt, d: ["codex", "exec", "--full-auto", prompt],
}


def response(handler, code, payload):
    body = json.dumps(payload, ensure_ascii=False, indent=2).encode()
    handler.send_response(code)
    handler.send_header("Content-Type", "application/json; charset=utf-8")
    handler.send_header("Content-Length", str(len(body)))
    handler.end_headers()
    handler.wfile.write(body)


def authed(handler):
    if not TOKEN:
        return False
    return handler.headers.get("Authorization") == f"Bearer {TOKEN}"


class Handler(http.server.BaseHTTPRequestHandler):
    server_version = "ZupWorker/1.0"

    def log_message(self, format, *args):
        print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] {self.client_address[0]} {format % args}", flush=True)

    def do_GET(self):
        if self.path != "/health":
            return response(self, 404, {"error": "not_found"})
        if not authed(self):
            return response(self, 403, {"error": "forbidden"})
        return response(self, 200, {
            "ok": True,
            "host": os.uname().nodename,
            "allowed_base": str(ALLOWED_BASE),
            "agents": sorted(AGENTS.keys()),
            "gpg_key": GPG_KEY,
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
        if not prompt or not repo:
            return response(self, 400, {"error": "missing_required", "required": ["repo", "prompt"]})
        if agent not in AGENTS:
            return response(self, 400, {"error": "unsupported_agent", "supported": sorted(AGENTS.keys())})

        repo_path = Path(os.path.expanduser(repo)).resolve()
        if not (repo_path == ALLOWED_BASE or ALLOWED_BASE in repo_path.parents):
            return response(self, 400, {"error": "path_not_allowed", "repo": str(repo_path), "allowed_base": str(ALLOWED_BASE)})
        if not repo_path.exists():
            return response(self, 400, {"error": "repo_not_found", "repo": str(repo_path)})

        timeout = min(int(data.get("timeout", 900)), MAX_TIMEOUT)
        cmd = AGENTS[agent](prompt, data)

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

        start = time.time()
        try:
            proc = subprocess.run(cmd, cwd=str(repo_path), env=env, text=True, capture_output=True, timeout=timeout)
            result = {
                "exit_code": proc.returncode,
                "duration_sec": round(time.time() - start, 2),
                "agent": agent,
                "repo": str(repo_path),
                "cmd": cmd[:2] + ["<prompt>"],
                "stdout": proc.stdout,
                "stderr": proc.stderr,
            }
            return response(self, 200, result)
        except subprocess.TimeoutExpired as e:
            return response(self, 504, {
                "error": "timeout",
                "timeout": timeout,
                "agent": agent,
                "repo": str(repo_path),
                "stdout": e.stdout or "",
                "stderr": e.stderr or "",
            })
        except Exception as e:
            return response(self, 500, {"error": "execution_failed", "detail": str(e)})


if __name__ == "__main__":
    if not TOKEN:
        raise SystemExit("ZUP_WORKER_TOKEN is required")
    print(f"Zup Worker listening on http://{HOST}:{PORT}; allowed_base={ALLOWED_BASE}", flush=True)
    http.server.ThreadingHTTPServer((HOST, PORT), Handler).serve_forever()
