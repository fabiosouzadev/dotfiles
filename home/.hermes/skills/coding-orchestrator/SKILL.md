---
name: coding-orchestrator
version: 1.0.0
description: |
  Orquestrador de coding agents autônomos para execução noturna ("coding enquanto eu durmo").
  Suporta triggers via Telegram, Webhook, GitHub label, e Cron.
  Usa worktrees Git para isolamento, múltiplos agents (Claude, Aider, Codex, etc.),
  budget control, e entrega resultados via Telegram/Notion/GitHub.
category: automation
author: Hermes Agent
tags:
  - coding-agent
  - orchestration
  - automation
  - nightly
  - autonomous
  - worktree
  - claude-code
  - aider
  - codex
requires:
  - hermes >= 0.18.0
  - mise (para Node.js agents)
  - git (worktrees)
  - gh CLI (opcional, GitHub integration)
  - mem0 (opcional, memory)
  - telegram (opcional, delivery)
provides:
  - skill: coding-orchestrator
  - scripts:
    - coding-orchestrator.sh (main entry)
    - gather-context.sh
    - create-worktree.sh
    - run-agent.sh
    - deliver-results.sh
  - config: config.yaml
  - cron job template
---

# Coding Orchestrator Skill

Orquestra a execução autônoma de coding agents na VPS para implementar features,
fixar bugs, refatorar código e criar testes — tudo enquanto você dorme.

## Arquitetura

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│   TRIGGERS      │────▶│  ORCHESTRATOR    │────▶│   AGENTS        │
├─────────────────┤     ├──────────────────┤     ├─────────────────┤
│ • Telegram      │     │ • Context gather │     │ • Claude Code   │
│ • Webhook       │     │ • Agent select   │     │ • Aider         │
│ • GitHub label  │     │ • Worktree create│     │ • Codex         │
│ • Cron (noite)  │     │ • Agent execute  │     │ • Gemini        │
└─────────────────┘     │ • Validate/Commit│     │ • OpenCode      │
                        │ • Deliver        │     │ • etc.          │
                        └──────────────────┘     └─────────────────┘
                               │
                               ▼
                        ┌──────────────────┐
                        │   DELIVERY       │
                        ├──────────────────┤
                        │ • Telegram       │
                        │ • Notion         │
                        │ • GitHub Comment │
                        │ • Structured log │
                        └──────────────────┘
```

## Instalação

A skill é instalada automaticamente via chezmoi no repo `~/.local/share/chezmoi`:

```bash
# No VPS, após chezmoi apply:
hermes skill reload
```

Ou manualmente:
```bash
mkdir -p ~/.hermes/skills/coding-orchestrator
# Copiar arquivos para ~/.hermes/skills/coding-orchestrator/
hermes skill reload
```

## Configuração

Arquivo: `~/.hermes/skills/coding-orchestrator/config.yaml`

```yaml
# Triggers habilitados
triggers:
  telegram: true
  webhook: true
  github_label: true
  cron: true

# Cron schedule (UTC)
cron:
  schedule: "0 2 * * *"  # 02:00 UTC
  timezone: "UTC"

# Seleção de agent
agent_selection:
  default: "claude"
  rules:
    - pattern: "fix|bug|hotfix"
      agent: "claude"
    - pattern: "refactor|cleanup"
      agent: "aider"
    - pattern: "feature|implement|create"
      agent: "codex"
    - pattern: "spec|spec-to-code"
      agent: "openspec"

# Worktree isolation
worktree:
  base_path: "~/worktrees"
  cleanup_after: true
  keep_on_failure: true

# Budget control
budget:
  nightly_usd: 5
  per_task_usd: 2
  hard_limit: true

# Monitoring
monitoring:
  heartbeat_interval_sec: 300
  timeout_sec: 1800
  alert_on_stuck_sec: 600

# Delivery
delivery:
  telegram: true
  notion: true
  github_comment: true
  log_path: "~/.hermes/logs/coding-orchestrator/"
```

## Triggers

### 1. Telegram Mention
Mencione o bot no Telegram com formato:
```
@hermes fix login bug #123
@hermes refactor auth module
@hermes implement new feature "dark mode"
```

O parser extrai: ação, descrição, repo (opcional), issue number (opcional).

### 2. Webhook
POST para `https://hermes.fabiosouzadev.duckdns.org/webhook/coding`:
```json
{
  "task": "fix login bug",
  "repo": "owner/repo",
  "issue_number": 123,
  "branch": "fix/login-bug",
  "trigger": "webhook"
}
```

Headers necessários:
- `X-Hermes-Signature`: HMAC-SHA256 do payload com secret configurado
- `Content-Type: application/json`

### 3. GitHub Issue Label
Quando uma issue recebe label `auto-fix`, `auto-refactor`, ou `auto-implement`:
- Skill `github` monitora via webhook GitHub App
- Dispara orchestrator com contexto da issue

Labels suportados:
| Label | Agent | Descrição |
|-------|-------|-----------|
| `auto-fix` | claude | Bug fixes |
| `auto-refactor` | aider | Refatoração |
| `auto-implement` | codex | Nova feature |
| `auto-spec` | openspec | Spec-to-code |

### 4. Cron Noturno
Agendado via Hermes cron job (`0 2 * * *`):
- Processa fila de tasks pendentes
- Respeita budget noturno ($5 USD)
- Para automaticamente ao amanhecer

## Uso Manual

```bash
# Via script direto
~/.hermes/skills/coding-orchestrator/scripts/coding-orchestrator.sh \
  manual "adicionar testes unitários para auth" "owner/repo" 456

# Via Hermes CLI (se registrado como comando)
hermes coding-orchestrator manual "fix typo in README" "owner/repo"
```

## Workflow de Execução

### 1. Context Gathering
Coleta automaticamente:
- GitHub issue/PR details (title, body, comments, files changed)
- Git log local (últimos 20 commits, diff, branches)
- Documentação (README, CLAUDE.md, AGENTS.md, SPEC.md, etc.)
- Notion pages vinculadas (via MCP)
- Memórias relevantes (via mem0)

Salva em: `/tmp/hermes-context-<task_id>/CONTEXT_SUMMARY.md`

### 2. Agent Selection
Baseado em regras no `config.yaml`:
- `fix/bug/hotfix` → **Claude Code** (melhor raciocínio)
- `refactor/cleanup` → **Aider** (bom para multi-file edits)
- `feature/implement` → **Codex** (OpenAI, bom para features)
- `spec/spec-to-code` → **OpenSpec** (spec-driven)

### 3. Worktree Creation
Cria worktree Git isolada em `~/worktrees/task-<task_id>/`:
- Branch dedicada por task
- Isolamento total do repo principal
- Cleanup automático após sucesso (configurável)

### 4. Agent Execution
Executa agent com:
- Prompt enriquecido com contexto completo
- Budget USD limit (default $2/task)
- Timeout (default 30min)
- Modo não-interativo (print/headless)

Agents suportados:
| Agent | Comando | Modelo |
|-------|---------|--------|
| claude | `mise exec node@20 -- claude -p --max-budget-usd $X` | OmniRoute |
| aider | `aider --model omniroute/work --api-base http://localhost:20128/v1` | OmniRoute |
| codex | `mise exec node@20 -- codex exec --model omniroute/work` | OmniRoute |
| gemini | `mise exec node@20 -- gemini -p` | OmniRoute |
| opencode | `mise exec node@20 -- opencode run` | OmniRoute |

### 5. Validation & Commit
- Roda testes se disponíveis (`npm test`, `pytest`, `cargo test`)
- Commit atômico com mensagem convencional
- Não faz push (segurança)

### 6. Delivery
Resultados entregues via:
- **Telegram**: Resumo + link worktree + arquivos modificados
- **Notion**: Atualiza task page (se vinculada)
- **GitHub**: Comentário na issue/PR com resumo
- **Log estruturado**: `~/.hermes/logs/coding-orchestrator/`

## Exemplos de Tasks Noturnas

```yaml
# Queue processada pelo cron 02:00-06:00
tasks:
  - trigger: cron
    task: "fix memory leak in websocket handler"
    repo: "myorg/backend"
    issue: 234
    budget: 3
    
  - trigger: cron
    task: "add unit tests for payment module"
    repo: "myorg/backend"
    issue: 235
    budget: 2
    
  - trigger: github_label
    label: "auto-refactor"
    repo: "myorg/frontend"
    issue: 112
    budget: 2
```

## Budget Control

```yaml
budget:
  nightly_usd: 5      # Total por noite
  per_task_usd: 2     # Por task
  hard_limit: true    # Para execução se estourar
```

- Monitorado via `--max-budget-usd` no Claude Code
- Aider/Codex usam token counting aproximado
- Alerta Telegram se budget > 80%

## Logs e Debug

```bash
# Ver logs de uma task
cat ~/.hermes/logs/coding-orchestrator/task-123456-abc.jsonl

# Ver resultados
cat ~/.hermes/logs/coding-orchestrator/task-123456-abc-result.json

# Tail do log em tempo real
tail -f ~/.hermes/logs/coding-orchestrator/coding-orchestrator.log
```

Estrutura do log JSONL:
```json
{"ts":"2026-07-17T02:00:00Z","task_id":"task-123","phase":"init","status":"started","extra":{}}
{"ts":"2026-07-17T02:00:01Z","task_id":"task-123","phase":"context_gathering","status":"started","extra":{}}
{"ts":"2026-07-17T02:00:05Z","task_id":"task-123","phase":"context_gathering","status":"completed","extra":{"context_file":"/tmp/..."}}
{"ts":"2026-07-17T02:00:05Z","task_id":"task-123","phase":"agent_selection","status":"completed","extra":{"agent":"claude"}}
{"ts":"2026-07-17T02:00:06Z","task_id":"task-123","phase":"worktree_create","status":"completed","extra":{"worktree":"~/worktrees/task-123","branch":"coding-agent/fix-login"}}
{"ts":"2026-07-17T02:00:06Z","task_id":"task-123","phase":"agent_execution","status":"started","extra":{"agent":"claude"}}
{"ts":"2026-07-17T02:15:32Z","task_id":"task-123","phase":"agent_execution","status":"completed","extra":{"agent":"claude","duration_sec":926,"exit_code":0}}
{"ts":"2026-07-17T02:15:33Z","task_id":"task-123","phase":"validation","status":"completed","extra":{"committed":true}}
{"ts":"2026-07-17T02:15:34Z","task_id":"task-123","phase":"delivery","status":"completed","extra":{}}
{"ts":"2026-07-17T02:15:35Z","task_id":"task-123","phase":"cleanup","status":"completed","extra":{}}
```

## Rollback

Se algo der errado:

```bash
# Desabilita skill
rm -rf ~/.hermes/skills/coding-orchestrator
hermes skill reload

# Para cron job
hermes cron disable <job-id>

# Remove worktrees órfãs
git worktree prune
rm -rf ~/worktrees/task-*

# Limpa logs
rm -rf ~/.hermes/logs/coding-orchestrator/
```

## Persistência no Chezmois

Templates para nova VPS:
- `home/.hermes/skills/coding-orchestrator/` (skill completa)
- `home/.chezmoiscripts/unix/run_once_after_XXX-install-coding-orchestrator.sh.tmpl`
- Feature flag no `.chezmoi.yaml.tmpl`: `features.ai.coding_orchestrator: true`

## Próximos Passos (Roadmap)

- [ ] Integração nativa com Hermes cron (job type `coding-orchestrator`)
- [ ] Dashboard web para monitorar tasks noturnas
- [ ] Suporte a Docker containers para isolation total
- [ ] Auto-retry com exponential backoff
- [ ] Integração com Linear/Jira (além de GitHub)
- [ ] Skill `telegram` handler para mentions
- [ ] Webhook endpoint no Caddy/Hermes gateway