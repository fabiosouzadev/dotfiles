#!/usr/bin/env bash
# create-worktree.sh — Cria worktree isolada para a task
# Uso: ./create-worktree.sh <task_id> <repo_path> <branch_name> [base_branch]

set -euo pipefail

TASK_ID="${1:-}"
REPO_PATH="${2:-}"
BRANCH_NAME="${3:-}"
BASE_BRANCH="${4:-main}"
WORKTREE_BASE="${5:-$HOME/worktrees}"

if [[ -z "$TASK_ID" || -z "$REPO_PATH" || -z "$BRANCH_NAME" ]]; then
    echo "Uso: $0 <task_id> <repo_path> <branch_name> [base_branch] [worktree_base]" >&2
    exit 1
fi

WORKTREE_PATH="$WORKTREE_BASE/task-$TASK_ID"

info() { echo "[INFO] $*"; }
warn() { echo "[WARN] $*" >&2; }
error() { echo "[ERROR] $*" >&2; exit 1; }

info "Criando worktree para task $TASK_ID"
info "Repo: $REPO_PATH"
info "Branch: $BRANCH_NAME (base: $BASE_BRANCH)"
info "Worktree: $WORKTREE_PATH"

cd "$REPO_PATH" || error "Repo não encontrado: $REPO_PATH"

# Verifica se é um repo git
if ! git rev-parse --git-dir >/dev/null 2>&1; then
    error "Não é um repositório Git: $REPO_PATH"
fi

# Fetch latest
info "Fazendo fetch..."
git fetch origin 2>/dev/null || warn "Fetch falhou (rede?)"

# Verifica se branch existe localmente ou remoto
if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
    info "Branch $BRANCH_NAME existe localmente"
    BRANCH_EXISTS_LOCAL=true
elif git show-ref --verify --quiet "refs/remotes/origin/$BRANCH_NAME"; then
    info "Branch $BRANCH_NAME existe no remote"
    BRANCH_EXISTS_REMOTE=true
else
    info "Branch $BRANCH_NAME não existe — será criada a partir de $BASE_BRANCH"
    BRANCH_EXISTS_LOCAL=false
    BRANCH_EXISTS_REMOTE=false
fi

# Remove worktree anterior se existir (cleanup)
if [[ -d "$WORKTREE_PATH" ]]; then
    warn "Worktree anterior existe em $WORKTREE_PATH — removendo..."
    git worktree remove --force "$WORKTREE_PATH" 2>/dev/null || true
    rm -rf "$WORKTREE_PATH"
fi

# Cria worktree
info "Criando worktree em $WORKTREE_PATH..."
if [[ "$BRANCH_EXISTS_LOCAL" == "true" ]]; then
    git worktree add "$WORKTREE_PATH" "$BRANCH_NAME"
elif [[ "$BRANCH_EXISTS_REMOTE" == "true" ]]; then
    git worktree add "$WORKTREE_PATH" -b "$BRANCH_NAME" "origin/$BRANCH_NAME"
else
    git worktree add "$WORKTREE_PATH" -b "$BRANCH_NAME" "$BASE_BRANCH"
fi

# Verifica se worktree foi criada
if [[ ! -d "$WORKTREE_PATH/.git" ]]; then
    error "Falha ao criar worktree"
fi

# Configura git na worktree (útil para commits)
cd "$WORKTREE_PATH"
git config user.name "coding-orchestrator"
git config user.email "hermes@local"

info "Worktree criada com sucesso: $WORKTREE_PATH"
echo "$WORKTREE_PATH"