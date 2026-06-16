#!/usr/bin/bash
set -euo pipefail

WORKER_DIR="/home/fabio.souza/Workspaces/Work/Zup"
WORKER_BIN="$HOME/.local/bin/zup-worker.py"
export ZUP_WORKER_ALLOWED_BASE="${ZUP_WORKER_ALLOWED_BASE:-$WORKER_DIR}"
export ZUP_WORKER_PORT="${ZUP_WORKER_PORT:-9001}"
: "${ZUP_WORKER_TOKEN:?ZUP_WORKER_TOKEN not set}"
: "${ZUP_AGENT_GPG_KEY:=232EFD8553CB22E5}"
export ZUP_AGENT_GPG_KEY

if tmux has-session -t zup-worker 2>/dev/null; then
  echo "zup-worker already running" >&2
  exit 0
fi

tmux new-session -d -s zup-worker "cd '$WORKER_DIR' && python3 '$WORKER_BIN'"
echo "zup-worker started" >&2
