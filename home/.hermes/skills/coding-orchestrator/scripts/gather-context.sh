#!/usr/bin/env bash
# gather-context.sh — Coleta contexto completo da task
# Uso: ./gather-context.sh <task_id> <repo> <issue_number> [branch]

set -euo pipefail

TASK_ID="${1:-}"
REPO="${2:-}"
ISSUE_NUMBER="${3:-}"
BRANCH="${4:-}"
CONTEXT_DIR="${5:-/tmp/hermes-context-$TASK_ID}"

if [[ -z "$TASK_ID" || -z "$REPO" || -z "$ISSUE_NUMBER" ]]; then
    echo "Uso: $0 <task_id> <repo> <issue_number> [branch]" >&2
    exit 1
fi

mkdir -p "$CONTEXT_DIR"

info() { echo "[INFO] $*"; }
warn() { echo "[WARN] $*" >&2; }
error() { echo "[ERROR] $*" >&2; exit 1; }

info "Coletando contexto para task $TASK_ID (repo: $REPO, issue: #$ISSUE_NUMBER)"

# 1. GitHub Issue/PR Details
if command -v gh >/dev/null 2>&1 && [[ -n "${GITHUB_TOKEN:-}" ]]; then
    info "Buscando issue #$ISSUE_NUMBER do GitHub..."
    gh api "repos/$REPO/issues/$ISSUE_NUMBER" > "$CONTEXT_DIR/github_issue.json" 2>/dev/null || warn "Falha ao buscar issue"
    gh api "repos/$REPO/issues/$ISSUE_NUMBER/comments" > "$CONTEXT_DIR/github_comments.json" 2>/dev/null || warn "Falha ao buscar comentários"
    
    # Se for PR, busca detalhes do PR
    if gh api "repos/$REPO/pulls/$ISSUE_NUMBER" >/dev/null 2>&1; then
        gh api "repos/$REPO/pulls/$ISSUE_NUMBER" > "$CONTEXT_DIR/github_pr.json" 2>/dev/null
        gh api "repos/$REPO/pulls/$ISSUE_NUMBER/files" > "$CONTEXT_DIR/github_pr_files.json" 2>/dev/null
        gh api "repos/$REPO/pulls/$ISSUE_NUMBER/commits" > "$CONTEXT_DIR/github_pr_commits.json" 2>/dev/null
    fi
else
    warn "gh CLI não disponível ou GITHUB_TOKEN não definido"
fi

# 2. Git Context (repo local)
if [[ -d ".git" ]] || git rev-parse --git-dir >/dev/null 2>&1; then
    info "Coletando contexto Git local..."
    {
        echo "=== GIT LOG (últimos 20) ==="
        git log --oneline -20
        echo
        echo "=== GIT STATUS ==="
        git status
        echo
        echo "=== GIT DIFF (HEAD~5..HEAD) ==="
        git diff HEAD~5..HEAD --stat
        echo
        echo "=== BRANCHES ==="
        git branch -a
    } > "$CONTEXT_DIR/git_context.txt" 2>&1
    
    if [[ -n "$BRANCH" ]]; then
        git diff "origin/main...$BRANCH" --stat > "$CONTEXT_DIR/git_diff_branch.txt" 2>/dev/null || true
        git diff "origin/main...$BRANCH" > "$CONTEXT_DIR/git_diff_branch_full.patch" 2>/dev/null || true
    fi
else
    warn "Não está em um repositório Git"
fi

# 3. Files de Documentação/Config
info "Coletando arquivos de documentação..."
DOC_FILES=(
    "README.md"
    "CLAUDE.md"
    "AGENTS.md"
    "docs/architecture.md"
    "docs/spec.md"
    "SPEC.md"
    "spec.md"
    "package.json"
    "pyproject.toml"
    "Cargo.toml"
    "go.mod"
    "Makefile"
    "docker-compose.yml"
    ".github/workflows/"
)
for f in "${DOC_FILES[@]}"; do
    if [[ -e "$f" ]]; then
        cp -r "$f" "$CONTEXT_DIR/" 2>/dev/null || true
    fi
done

# 4. Notion (via MCP se disponível)
if command -v hermes >/dev/null 2>&1; then
    info "Buscando contexto no Notion via MCP..."
    # Nota: requer skill mcp-notion configurada
    hermes mcp notion query "task $ISSUE_NUMBER" > "$CONTEXT_DIR/notion_context.txt" 2>/dev/null || warn "MCP Notion não disponível"
fi

# 5. Memory (mem0)
if command -v mem0 >/dev/null 2>&1; then
    info "Buscando memórias relevantes..."
    mem0 search "repo:$REPO issue:$ISSUE_NUMBER" > "$CONTEXT_DIR/mem0_context.txt" 2>/dev/null || warn "mem0 não disponível"
fi

# 6. Cria arquivo de resumo consolidado
info "Gerando resumo consolidado..."
{
    echo "# Contexto da Task: $TASK_ID"
    echo
    echo "## Issue/PR: #$ISSUE_NUMBER"
    echo "## Repo: $REPO"
    echo "## Branch: ${BRANCH:-main}"
    echo "## Coletado em: $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
    echo
    if [[ -f "$CONTEXT_DIR/github_issue.json" ]]; then
        echo "## GitHub Issue"
        jq -r '.title, "", .body' "$CONTEXT_DIR/github_issue.json" 2>/dev/null || cat "$CONTEXT_DIR/github_issue.json"
        echo
    fi
    if [[ -f "$CONTEXT_DIR/git_context.txt" ]]; then
        echo "## Git Context"
        cat "$CONTEXT_DIR/git_context.txt"
        echo
    fi
    if [[ -f "$CONTEXT_DIR/notion_context.txt" ]]; then
        echo "## Notion Context"
        cat "$CONTEXT_DIR/notion_context.txt"
        echo
    fi
    if [[ -f "$CONTEXT_DIR/mem0_context.txt" ]]; then
        echo "## Memory (mem0)"
        cat "$CONTEXT_DIR/mem0_context.txt"
        echo
    fi
} > "$CONTEXT_DIR/CONTEXT_SUMMARY.md"

info "Contexto salvo em: $CONTEXT_DIR"
echo "$CONTEXT_DIR"