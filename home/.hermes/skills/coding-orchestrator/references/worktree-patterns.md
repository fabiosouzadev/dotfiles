# Padrões de Worktree Git para Isolamento

## Conceito

Git worktrees permitem múltiplos working directories conectados ao mesmo repositório `.git`, cada um com sua própria branch. Ideal para execução paralela de agents sem conflitos.

## Criação Básica

```bash
# No repo principal
cd /path/to/repo

# Criar worktree com branch nova
git worktree add ../worktrees/task-123 -b feature/task-123

# Criar worktree com branch existente (local)
git worktree add ../worktrees/task-123 feature/existing-branch

# Criar worktree com branch remota
git worktree add ../worktrees/task-123 -b feature/task-123 origin/feature/task-123
```

## Estrutura Recomendada

```
~/worktrees/
├── task-1784313442-a4bc30ca/    # task-id único
│   ├── .git                     # Arquivo (não dir!) apontando para repo principal
│   ├── src/
│   ├── tests/
│   └── ...
├── task-1784313957-b83d5d68/
│   └── ...
└── ...
```

## No Orchestrator

### Script `create-worktree.sh`
```bash
#!/usr/bin/env bash
# Uso: create-worktree.sh <task_id> <repo_path> <branch_name> [base_branch] [worktree_base]

TASK_ID="$1"
REPO_PATH="$2"
BRANCH_NAME="$3"
BASE_BRANCH="${4:-main}"
WORKTREE_BASE="${5:-$HOME/worktrees}"

WORKTREE_PATH="$WORKTREE_BASE/task-$TASK_ID"

cd "$REPO_PATH" || exit 1

# Fetch latest
git fetch origin 2>/dev/null || true

# Remove worktree anterior se existir (cleanup)
if [[ -d "$WORKTREE_PATH" ]]; then
    git worktree remove --force "$WORKTREE_PATH" 2>/dev/null || true
    rm -rf "$WORKTREE_PATH"
fi

# Cria worktree
if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
    # Branch existe localmente
    git worktree add "$WORKTREE_PATH" "$BRANCH_NAME"
elif git show-ref --verify --quiet "refs/remotes/origin/$BRANCH_NAME"; then
    # Branch existe no remote
    git worktree add "$WORKTREE_PATH" -b "$BRANCH_NAME" "origin/$BRANCH_NAME"
else
    # Branch nova baseada na base_branch
    git worktree add "$WORKTREE_PATH" -b "$BRANCH_NAME" "$BASE_BRANCH"
fi

# Configura git na worktree
cd "$WORKTREE_PATH"
git config user.name "coding-orchestrator"
git config user.email "hermes@local"

echo "$WORKTREE_PATH"
```

## Limpeza

```bash
# Remove worktree específica
git worktree remove ~/worktrees/task-123

# Força remoção se tiver mudanças não commitadas
git worktree remove --force ~/worktrees/task-123

# Prune worktrees órfãs (limpa entries no .git/worktrees)
git worktree prune

# Remove diretório físico também
rm -rf ~/worktrees/task-123
```

## Listar Worktrees Ativas

```bash
git worktree list
# Output:
# /path/to/repo          84928cd [main]
# /home/user/worktrees/task-123  a1b2c3d [feature/task-123]
```

## Padrões no Orchestrator

### Branch Naming
```
coding-agent/<slugified-task>-<task_id>
# Ex: coding-agent/fix-login-bug-task-1784313442-a4bc30ca
```

### Cleanup Policy (config.yaml)
```yaml
worktree:
  base_path: "~/worktrees"
  cleanup_after: true      # Remove após sucesso
  keep_on_failure: true    # Mantém para debug se falhar
```

### Isolation Benefits
| Benefício | Descrição |
|-----------|-----------|
| **Zero conflitos** | Cada agent tem seu próprio working dir |
| **Paralelismo** | Múltiplos agents simultâneos sem interferência |
| **Rollback fácil** | `git worktree remove --force` apaga tudo |
| **Histórico limpo** | Commits só vão para branch da task |
| **Debug preservado** | `keep_on_failure: true` mantém worktree se der erro |

## Pitfalls

| Problema | Causa | Solução |
|----------|-------|---------|
| `fatal: not a git repository` | Executando fora do repo | `cd <repo_path>` antes de `git worktree add` |
| `already exists` | Worktree prévia não limpa | `git worktree remove --force <path>` antes |
| Branch não encontrada | Nome errado ou não fetch | `git fetch origin` antes |
| Permissão negada | Diretório não writable | Verificar `$HOME/worktrees` permissions |
| Submódulos não funcionam | Worktrees não suportam submodules nativamente | Evitar submodules ou usar `--recurse-submodules` no clone inicial |

## Boas Práticas

1. **Sempre `git fetch` antes** — garante branches remotas atualizadas
2. **Unique task_id** — evita colisão de branch/worktree
3. **Config user.name/email** — commits precisam de autor
4. **Cleanup automático** — evita acumular worktrees órfãs
5. **Monitor disk space** — worktrees duplicam working dir (não `.git`)