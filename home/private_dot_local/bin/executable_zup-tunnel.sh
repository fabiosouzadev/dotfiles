#!/usr/bin/bash
#!/usr/bin/env bash
set -euo pipefail

SSH_KEY="{{ .zup.ssh_key | default "~/.ssh/ssh-key-oracle-dev-2.key" }}"
SSH_HOST="{{ .zup.vps_host | default "ubuntu@157.151.13.223" }}"
SSH_PORT="{{ .zup.vps_port | default 22 }}"
LOCAL_PORT="${ZUP_WORKER_PORT:-9001}"
TUNNEL_SESSION="zup-tunnel"
REMOTE_SPEC="${LOCAL_PORT}:127.0.0.1:${LOCAL_PORT}"

start() {
  if tmux has-session -t "$TUNNEL_SESSION" 2>/dev/null; then
    echo "Tunnel already running (tmux: $TUNNEL_SESSION)" >&2
    return 0
  fi

  tmux new-session -d -s "$TUNNEL_SESSION" \
    "ssh -i ${SSH_KEY} \
          -p ${SSH_PORT} \
          -o ServerAliveInterval=30 \
          -o ServerAliveCountMax=3 \
          -o ExitOnForwardFailure=yes \
          -N ${SSH_HOST} \
          -R ${REMOTE_SPEC}"

  echo "Tunnel started (tmux: $TUNNEL_SESSION → ${SSH_HOST})" >&2
}

stop() {
  if tmux has-session -t "$TUNNEL_SESSION" 2>/dev/null; then
    tmux send-keys -t "$TUNNEL_SESSION" C-c 2>/dev/null || true
    sleep 0.5
    tmux kill-session -t "$TUNNEL_SESSION"
    echo "Tunnel stopped" >&2
  else
    echo "No tunnel running" >&2
  fi
}

status() {
  if tmux has-session -t "$TUNNEL_SESSION" 2>/dev/null; then
    echo "Tunnel is RUNNING (tmux: $TUNNEL_SESSION)"
    return 0
  else
    echo "Tunnel is STOPPED"
    return 1
  fi
}

case "${1:-}" in
  start)   start ;;
  stop)    stop ;;
  restart) stop; sleep 0.5; start ;;
  status)  status ;;
  *)
    echo "Usage: $0 {start|stop|restart|status}" >&2
    exit 1
    ;;
esac
