#!/usr/bin/env bash
# run-agent.sh — Executa o coding agent na worktree
# Uso: ./run-agent.sh <task_id> <agent> <worktree_path> <context_dir> <instructions_file>

set -euo pipefail

TASK_ID="${1:-}"
AGENT="${2:-claude}"
WORKTREE_PATH="${3:-}"
CONTEXT_DIR="${4:-}"
INSTRUCTIONS_FILE="${5:-}"
BUDGET_USD="${6:-2}"
TIMEOUT_SEC="${7:-1800}"

if [[ -z "$TASK_ID" || -z "$AGENT" || -z "$WORKTREE_PATH" || -z "$CONTEXT_DIR" ]]; then
    echo "Uso: $0 <task_id> <agent> <worktree_path> <context_dir> <instructions_file> [budget_usd] [timeout_sec]" >&2
    exit 1
fi

LOG_FILE="/tmp/hermes-coding-$TASK_ID.log"
RESULT_FILE="/tmp/hermes-coding-$TASK_ID-result.json"

info() { echo "[INFO] $*" | tee -a "$LOG_FILE"; }
warn() { echo "[WARN] $*" | tee -a "$LOG_FILE" >&2; }
error() { echo "[ERROR] $*" | tee -a "$LOG_FILE" >&2; exit 1; }

info "Iniciando agent $AGENT para task $TASK_ID"
info "Worktree: $WORKTREE_PATH"
info "Context: $CONTEXT_DIR"
info "Budget: \$${BUDGET_USD} USD"
info "Timeout: ${TIMEOUT_SEC}s"

cd "$WORKTREE_PATH" || error "Worktree não encontrada: $WORKTREE_PATH"

# Lê instruções
if [[ ! -f "$INSTRUCTIONS_FILE" ]]; then
    error "Arquivo de instruções não encontrado: $INSTRUCTIONS_FILE"
fi
INSTRUCTIONS=$(cat "$INSTRUCTIONS_FILE")

# Lê contexto resumido
CONTEXT_SUMMARY="$CONTEXT_DIR/CONTEXT_SUMMARY.md"
if [[ ! -f "$CONTEXT_SUMMARY" ]]; then
    warn "Resumo de contexto não encontrado: $CONTEXT_SUMMARY"
    CONTEXT_TEXT=""
else
    CONTEXT_TEXT=$(cat "$CONTEXT_SUMMARY")
fi

# Monta prompt completo para o agent
FULL_PROMPT=$(cat <<EOF
# Task: $TASK_ID
# Agent: $AGENT
# Budget: \$${BUDGET_USD} USD
# Timeout: ${TIMEOUT_SEC}s

## Contexto da Task
$CONTEXT_TEXT

## Instruções
$INSTRUCTIONS

## Diretrizes de Execução
- Trabalhe apenas dentro desta worktree: $WORKTREE_PATH
- Faça commits atômicos com mensagens claras
- Não modifique arquivos fora do escopo da task
- Se precisar de dependências, instale localmente
- Reporte progresso a cada passo significativo
- Ao finalizar, forneça resumo do que foi feito + arquivos modificados
EOF
)

info "Executando $AGENT com prompt de ${#FULL_PROMPT} chars..."

# Função para executar com timeout e budget
run_with_monitoring() {
    local agent_cmd="$1"
    local start_time=$(date +%s)
    local last_heartbeat=$start_time
    
    info "Comando: $agent_cmd"
    
    # Executa com timeout
    if timeout "$TIMEOUT_SEC" bash -c "$agent_cmd" 2>&1 | tee -a "$LOG_FILE"; then
        local exit_code=0
    else
        local exit_code=$?
    fi
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    info "Agent finalizado em ${duration}s (exit code: $exit_code)"
    return $exit_code
}

# Seleciona comando baseado no agent
case "$AGENT" in
    claude)
        # Claude Code com budget e modo print
        AGENT_CMD="mise exec node@20 -- claude -p --max-budget-usd $BUDGET_USD --output-format json '$FULL_PROMPT'"
        ;;
    aider)
        # Aider com modelo do OmniRoute
        AGENT_CMD="aider --model omniroute/work --api-base http://localhost:20128/v1 --max-tokens 8192 --yes --message '$FULL_PROMPT'"
        ;;
    codex)
        # Codex CLI
        AGENT_CMD="mise exec node@20 -- codex exec --model omniroute/work '$FULL_PROMPT'"
        ;;
    gemini)
        # Gemini CLI
        AGENT_CMD="mise exec node@20 -- gemini -p '$FULL_PROMPT'"
        ;;
    opencode)
        # OpenCode
        AGENT_CMD="mise exec node@20 -- opencode run '$FULL_PROMPT'"
        ;;
    *)
        error "Agent desconhecido: $AGENT"
        ;;
esac

# Executa
run_with_monitoring "$AGENT_CMD"
EXIT_CODE=$?

# Coleta resultado
info "Coletando resultados..."
MODIFIED_FILES=$(git status --porcelain | awk '{print $2}' | tr '\n' ' ' || echo "")
COMMITS=$(git log --oneline -5 2>/dev/null || echo "")

# Cria arquivo de resultado JSON
cat > "$RESULT_FILE" <<EOF
{
    "task_id": "$TASK_ID",
    "agent": "$AGENT",
    "worktree": "$WORKTREE_PATH",
    "exit_code": $EXIT_CODE,
    "duration_sec": $((end_time - start_time)),
    "budget_usd": $BUDGET_USD,
    "modified_files": "$MODIFIED_FILES",
    "commits": "$COMMITS",
    "log_file": "$LOG_FILE",
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF

info "Resultado salvo em: $RESULT_FILE"
cat "$RESULT_FILE"

exit $EXIT_CODE