#!/usr/bin/env bash
# deliver-results.sh — Entrega resultados via Telegram, Notion, GitHub
# Uso: ./deliver-results.sh <task_id> <result_file>

set -euo pipefail

TASK_ID="${1:-}"
RESULT_FILE="${2:-}"

if [[ -z "$TASK_ID" || -z "$RESULT_FILE" ]]; then
    echo "Uso: $0 <task_id> <result_file>" >&2
    exit 1
fi

if [[ ! -f "$RESULT_FILE" ]]; then
    echo "Arquivo de resultado não encontrado: $RESULT_FILE" >&2
    exit 1
fi

info() { echo "[INFO] $*"; }
warn() { echo "[WARN] $*" >&2; }
error() { echo "[ERROR] $*" >&2; exit 1; }

# Lê resultado
EXIT_CODE=$(jq -r '.exit_code // 1' "$RESULT_FILE")
AGENT=$(jq -r '.agent // "unknown"' "$RESULT_FILE")
DURATION=$(jq -r '.duration_sec // 0' "$RESULT_FILE")
MODIFIED_FILES=$(jq -r '.modified_files // ""' "$RESULT_FILE")
COMMITS=$(jq -r '.commits // ""' "$RESULT_FILE")
WORKTREE=$(jq -r '.worktree // ""' "$RESULT_FILE")
LOG_FILE=$(jq -r '.log_file // ""' "$RESULT_FILE")

STATUS="✅ SUCESSO"
if [[ "$EXIT_CODE" -ne 0 ]]; then
    STATUS="❌ FALHOU (exit: $EXIT_CODE)"
fi

# Monta mensagem
MESSAGE=$(cat <<EOF
$STATUS — Task $TASK_ID

🤖 Agent: $AGENT
⏱️ Duração: ${DURATION}s
💰 Budget: \$(jq -r '.budget_usd // 0' "$RESULT_FILE") USD
📁 Worktree: $WORKTREE
📝 Arquivos modificados: ${MODIFIED_FILES:-"(nenhum)"}

📋 Commits recentes:
${COMMITS:-"(nenhum)"}

📄 Log: $LOG_FILE
EOF
)

info "Entregando resultados..."

# 1. Telegram (via Hermes skill telegram)
if command -v hermes >/dev/null 2>&1; then
    info "Enviando via Telegram..."
    hermes telegram send "$MESSAGE" 2>/dev/null || warn "Falha ao enviar Telegram"
fi

# 2. Notion (se task vinculada a página Notion)
# TODO: Implementar via MCP Notion se task_id mapear para page_id

# 3. GitHub Comment (se for issue/PR)
# Precisa de GITHUB_TOKEN e repo/issue no result file
REPO=$(jq -r '.repo // ""' "$RESULT_FILE" 2>/dev/null)
ISSUE=$(jq -r '.issue_number // ""' "$RESULT_FILE" 2>/dev/null)

if [[ -n "$REPO" && -n "$ISSUE" && -n "${GITHUB_TOKEN:-}" ]] && command -v gh >/dev/null 2>&1; then
    info "Postando comentário no GitHub (#$ISSUE)..."
    gh api "repos/$REPO/issues/$ISSUE/comments" -f body="$MESSAGE" 2>/dev/null || warn "Falha ao comentar no GitHub"
fi

# 4. Log estruturado
LOG_DIR="$HOME/.hermes/logs/coding-orchestrator"
mkdir -p "$LOG_DIR"
cp "$RESULT_FILE" "$LOG_DIR/task-$TASK_ID-$(date +%Y%m%d-%H%M%S).json"

info "Entrega concluída."