#!/usr/bin/bash
set -euo pipefail
tmux kill-session -t zup-worker 2>/dev/null && echo "zup-worker stopped" || echo "zup-worker not running"
"$HOME/.local/bin/zup-tunnel.sh" stop
