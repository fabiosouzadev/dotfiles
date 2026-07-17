#!/usr/bin/env bash
# coding-orchestrator.sh — Main orchestrator entry point
# Uso: ./coding-orchestrator.sh <trigger_type> <task_description> [options]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
LOG_DIR="$HOME/.hermes/logs/coding-orchestrator"

info() { echo "[INFO] $*"; }
warn() { echo "[WARN] $*" >&2; }
error() { echo "[ERROR] $*" >&2; exit 1; }

mkdir -p "$LOG_DIR"

# Parse arguments
TRIGGER_TYPE="${1:-}"
TASK_DESC="${2:-}"
REPO="${3:-}"
ISSUE_NUM="${4:-}"
BRANCH="${5:-}"

if [[ -z "$TRIGGER_TYPE" || -z "$TASK_DESC" ]]; then
    cat <<EOF
Uso: $0 <trigger_type> <task_desc> [repo] [issue_num] [branch]

Trigger types:
  telegram    - Triggered via Telegram mention
  webhook     - Triggered via webhook
  github      - Triggered via GitHub label
  cron        - Triggered via cron (processes queue)
  manual      - Manual trigger

Exemplos:
  $0 telegram "fix login bug" "owner/repo" 123
  $0 webhook "refactor auth" "owner/repo" 456 "feature/auth"
  $0 cron
  $0 manual "add tests" "owner/repo"
EOF
    exit 1
fi

# Gera task ID único
TASK_ID="task-$(date +%s)-$(openssl rand -hex 4)"
TASK_LOG="$LOG_DIR/$TASK_ID.jsonl"
RESULT_FILE="$LOG_DIR/$TASK_ID-result.json"

# Config defaults
BUDGET_USD="${BUDGET_USD:-2}"
TIMEOUT_SEC="${TIMEOUT_SEC:-1800}"

info "=== Coding Orchestrator ==="
info "Task ID: $TASK_ID"
info "Trigger: $TRIGGER_TYPE"
info "Task: $TASK_DESC"
[[ -n "$REPO" ]] && info "Repo: $REPO"
[[ -n "$ISSUE_NUM" ]] && info "Issue: #$ISSUE_NUM"
[[ -n "$BRANCH" ]] && info "Branch: $BRANCH"
info "Log: $TASK_LOG"

# Função para log JSONL
log_event() {
    local phase="$1"
    local status="$2"
    local extra="${3:-}"
    local ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    jq -n \
        --arg ts "$ts" \
        --arg task_id "$TASK_ID" \
        --arg phase "$phase" \
        --arg status "$status" \
        --argjson extra "$extra" \
        '{ts: $ts, task_id: $task_id, phase: $phase, status: $status, extra: $extra}' >> "$TASK_LOG"
}

# Início
START_TIME=$(date +%s)
log_event "init" "started" "{}"

# ============================================================
# FASE 1: Context Gathering
# ============================================================
log_event "context_gathering" "started" "{}"
info "📋 Coletando contexto..."

CONTEXT_FILE="$LOG_DIR/$TASK_ID-context.json"

# TODO: Implementar coleta real de contexto
# - GitHub API (issue/PR details)
# - Git log/diff
# - Notion MCP
# - Mem0 memory
# - Files (README, CLAUDE.md, etc)

cat > "$CONTEXT_FILE" <<EOF
{
  "task_id": "$TASK_ID",
  "trigger": "$TRIGGER_TYPE",
  "task": "$TASK_DESC",
  "repo": "$REPO",
  "issue_number": ${ISSUE_NUM:-null},
  "branch": "$BRANCH",
  "context": {
    "github": {},
    "git": {},
    "notion": {},
    "memory": {},
    "files": {}
  },
  "gathered_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF

log_event "context_gathering" "completed" "{\"context_file\": \"$CONTEXT_FILE\"}"

# ============================================================
# FASE 2: Agent Selection
# ============================================================
log_event "agent_selection" "started" "{}"
info "🤖 Selecionando agent..."

# Regras de seleção (pode vir de config.yaml)
AGENT="aider"
case "$TASK_DESC" in
    *fix*|*bug*|*hotfix*|*debug*) AGENT="aider" ;;
    *refactor*|*cleanup*|*restructure*) AGENT="aider" ;;
    *feature*|*implement*|*create*|*new*) AGENT="aider" ;;
    *spec*|*spec-to-code*) AGENT="openspec" ;;
esac

# Override se branch indica agent
if [[ "$BRANCH" == *"aider"* ]]; then AGENT="aider"; fi
if [[ "$BRANCH" == *"codex"* ]]; then AGENT="codex"; fi
if [[ "$BRANCH" == *"claude"* ]]; then AGENT="claude"; fi

log_event "agent_selection" "completed" "{\"agent\": \"$AGENT\"}"
info "Agent selecionado: $AGENT"

# ============================================================
# FASE 3: Worktree Creation
# ============================================================
log_event "worktree_create" "started" "{}"
info "🌲 Criando worktree..."

WORKTREE_BASE="${WORKTREE_BASE:-$HOME/worktrees}"
WORKTREE_PATH="$WORKTREE_BASE/$TASK_ID"
mkdir -p "$WORKTREE_BASE"

if [[ -n "$REPO" && -d "$REPO" ]]; then
    # Repo local existe
    cd "$REPO"
elif [[ -n "$REPO" ]]; then
    # Clona repo
    git clone "https://github.com/$REPO.git" "$WORKTREE_PATH"
    cd "$WORKTREE_PATH"
else
    # Usa repo atual
    cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
fi

# Cria branch se não existe
if [[ -n "$BRANCH" ]]; then
    if git show-ref --verify --quiet "refs/heads/$BRANCH"; then
        git worktree add "$WORKTREE_PATH" "$BRANCH"
    else
        git worktree add -b "$BRANCH" "$WORKTREE_PATH"
    fi
else
    # Branch baseada na task
    SAFE_TASK=$(echo "$TASK_DESC" | sed 's/[^a-zA-Z0-9]/-/g' | cut -c1-40)
    BRANCH="coding-agent/$SAFE_TASK-$TASK_ID"
    git worktree add -b "$BRANCH" "$WORKTREE_PATH"
fi

cd "$WORKTREE_PATH"
log_event "worktree_create" "completed" "{\"worktree\": \"$WORKTREE_PATH\", \"branch\": \"$BRANCH\"}"
info "Worktree: $WORKTREE_PATH (branch: $BRANCH)"

# ============================================================
# FASE 4: Agent Execution
# ============================================================
log_event "agent_execution" "started" "{\"agent\": \"$AGENT\", \"worktree\": \"$WORKTREE_PATH\"}"
info "🚀 Executando $AGENT..."

# Cria prompt para o agent
PROMPT=$(cat <<EOF
Task: $TASK_DESC

Context:
- Repo: $REPO
- Issue: #$ISSUE_NUM
- Branch: $BRANCH
- Worktree: $WORKTREE_PATH

Instructions:
1. Analyze the codebase and understand the task
2. Implement the required changes
3. Run tests if available
4. Create clear, conventional commits
5. Do NOT push - just commit locally

Output your work summary when done.
EOF
)

# Cria arquivo de instruções temporário
CONTEXT_DIR="$LOG_DIR/$TASK_ID"
INSTRUCTIONS_FILE="$LOG_DIR/$TASK_ID-instructions.txt"
cat > "$INSTRUCTIONS_FILE" <<EOF
# Task: $TASK_ID
# Agent: $AGENT
# Budget: \$${BUDGET_USD} USD
# Timeout: ${TIMEOUT_SEC}s

## Contexto da Task
$(cat "$CONTEXT_DIR/CONTEXT_SUMMARY.md" 2>/dev/null || echo "Contexto não disponível")

## Instruções
$PROMPT

## Diretrizes de Execução
- Trabalhe apenas dentro desta worktree: $WORKTREE_PATH
- Faça commits atômicos com mensagens claras
- Não modifique arquivos fora do escopo da task
- Se precisar de dependências, instale localmente
- Reporte progresso a cada passo significativo
- Ao finalizar, forneça resumo do que foi feito + arquivos modificados
EOF

# Executa agent via script run-agent.sh
CONTEXT_DIR="$LOG_DIR/$TASK_ID"
AGENT_START=$(date +%s)
"$SKILL_DIR/scripts/run-agent.sh" "$TASK_ID" "$AGENT" "$WORKTREE_PATH" "$CONTEXT_DIR" "$INSTRUCTIONS_FILE" "$BUDGET_USD" "$TIMEOUT_SEC"
AGENT_EXIT=$?
AGENT_END=$(date +%s)
AGENT_DURATION=$((AGENT_END - AGENT_START))

log_event "agent_execution" "completed" "{\"agent\": \"$AGENT\", \"duration_sec\": $AGENT_DURATION, \"exit_code\": $AGENT_EXIT}"

# ============================================================
# FASE 5: Validation & Commit
# ============================================================
if [[ $AGENT_EXIT -eq 0 ]]; then
    log_event "validation" "started" "{}"
    info "✅ Validando mudanças..."
    
    # Verifica se há mudanças
    if ! git diff --quiet HEAD; then
        info "Mudanças detectadas, rodando testes..."
        
        # Tenta rodar testes comuns
        if [[ -f "package.json" ]]; then
            npm test 2>&1 | tee -a "$TASK_LOG" || warn "Testes npm falharam"
        elif [[ -f "pytest.ini" || -f "pyproject.toml" ]]; then
            pytest 2>&1 | tee -a "$TASK_LOG" || warn "Testes pytest falharam"
        elif [[ -f "Cargo.toml" ]]; then
            cargo test 2>&1 | tee -a "$TASK_LOG" || warn "Testes cargo falharam"
        fi
        
        # Commit
        git add -A
        COMMIT_MSG=$(cat <<EOF
$TASK_DESC

Automated by coding-orchestrator (task: $TASK_ID)
Agent: $AGENT
Trigger: $TRIGGER_TYPE
EOF
)
        git commit -m "$COMMIT_MSG"
        log_event "validation" "completed" "{\"committed\": true}"
        info "✅ Commit realizado"
    else
        warn "Nenhuma mudança detectada"
        log_event "validation" "completed" "{\"committed\": false, \"reason\": \"no_changes\"}"
    fi
else
    log_event "validation" "skipped" "{\"reason\": \"agent_failed\", \"exit_code\": $AGENT_EXIT}"
    warn "Agent falhou (exit: $AGENT_EXIT), pulando validação"
fi

# ============================================================
# FASE 6: Delivery
# ============================================================
log_event "delivery" "started" "{}"
info "📦 Entregando resultados..."

# Prepara arquivo de resultado final
END_TIME=$(date +%s)
TOTAL_DURATION=$((END_TIME - START_TIME))

jq -n \
    --arg task_id "$TASK_ID" \
    --arg trigger "$TRIGGER_TYPE" \
    --arg task "$TASK_DESC" \
    --arg repo "$REPO" \
    --argjson issue "${ISSUE_NUM:-null}" \
    --arg branch "$BRANCH" \
    --arg agent "$AGENT" \
    --arg worktree "$WORKTREE_PATH" \
    --argjson exit_code $AGENT_EXIT \
    --argjson duration $TOTAL_DURATION \
    --argjson agent_duration $AGENT_DURATION \
    --arg log_file "$TASK_LOG" \
    '{
        task_id: $task_id,
        trigger: $trigger,
        task: $task,
        repo: $repo,
        issue_number: $issue,
        branch: $branch,
        agent: $agent,
        worktree: $worktree,
        exit_code: $exit_code,
        duration_sec: $duration,
        agent_duration_sec: $agent_duration,
        log_file: $log_file,
        timestamp: now | todateiso8601
    }' > "$RESULT_FILE"

# Entrega resultados
"$SKILL_DIR/scripts/deliver-results.sh" "$TASK_ID" "$RESULT_FILE"

log_event "delivery" "completed" "{}"

# ============================================================
# Cleanup (opcional)
# ============================================================
if [[ "${CLEANUP_WORKTREE:-true}" == "true" && $AGENT_EXIT -eq 0 ]]; then
    info "🧹 Limpando worktree..."
    git worktree remove "$WORKTREE_PATH" 2>/dev/null || true
    log_event "cleanup" "completed" "{}"
else
    info "Worktree mantida em: $WORKTREE_PATH"
    log_event "cleanup" "skipped" "{\"keep\": true}"
fi

# Summary
info "=== Task $TASK_ID Concluída ==="
info "Status: $([[ $AGENT_EXIT -eq 0 ]] && echo "✅ SUCESSO" || echo "❌ FALHA")"
info "Duração total: ${TOTAL_DURATION}s"
info "Agent: $AGENT (${AGENT_DURATION}s)"
info "Worktree: $WORKTREE_PATH"
info "Resultado: $RESULT_FILE"
info "Log: $TASK_LOG"

exit $AGENT_EXIT