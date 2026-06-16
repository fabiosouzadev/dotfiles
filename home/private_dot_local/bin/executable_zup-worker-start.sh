#!/usr/bin/env bash
set -euo pipefail

WORKER_DIR="/home/fabio.souza/Workspaces/Work/Zup"
WORKER_BIN="$HOME/.local/bin/zup-worker.py"
TOKEN_FILE="${ZUP_WORKER_TOKEN_FILE:-$HOME/.local/share/zup-worker/token}"
export ZUP_WORKER_ALLOWED_BASE="${ZUP_WORKER_ALLOWED_BASE:-$WORKER_DIR}"
export ZUP_WORKER_PORT="${ZUP_WORKER_PORT:-9001}"

# Load token from file if not in env
if [ -z "${ZUP_WORKER_TOKEN:-}" ] && [ -r "$TOKEN_FILE" ]; then
  export ZUP_WORKER_TOKEN="$(tr -d '\r\n' < "$TOKEN_FILE")"
fi
: "${ZUP_WORKER_TOKEN:?ZUP_WORKER_TOKEN not set and token file missing: $TOKEN_FILE}"
: "${ZUP_AGENT_GPG_KEY:=232EFD8553CB22E5}"
export ZUP_AGENT_GPG_KEY

if tmux has-session -t zup-worker 2>/dev/null; then
  echo "zup-worker already running" >&2
  exit 0
fi

tmux new-session -d -s zup-worker "cd '$WORKER_DIR' && python3 '$WORKER_BIN'"
echo "zup-worker started" >&2
