---
name: dotfiles-ai-integration
description: "AI stack: Hermes, OmniRoute, Orchestrator install, config."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos]
metadata:
  hermes:
    tags: [dotfiles, ai, hermes, omniroute, orchestrator]
    category: devops
requires_toolsets: [terminal, file]
supersedes: []
---

# Dotfiles AI Integration Skill

**Trigger**: Use when configuring the AI development stack — Hermes Agent, OmniRoute LLM Gateway, Coding Orchestrator (nightly agent), including install, config, dashboards, backup/sync, and cron scheduling.

**Goal**: Provide complete reference for AI integration patterns from `fabiosouzadev/dotfiles` enabling reproducible AI-assisted development environment.

---

## 1. AI Stack Architecture

### Components

| Component | Role | Port | Profile |
|-----------|------|------|---------|
| **Hermes Agent** | Local AI agent with memory, tools, skills | 9119 | VPS (dashboard), Personal (optional) |
| **OmniRoute** | LLM gateway/router (local + cloud) | 20128 | VPS (dashboard), Personal (optional) |
| **Coding Orchestrator** | Nightly autonomous coding agent | Cron 02:00 | VPS only |
| **Aider** | AI pair programming (terminal) | N/A | All (when enabled) |
| **Claude Code** | Anthropic CLI agent | N/A | Work (when enabled) |

### Feature Flags

```go
{{- /* In .chezmoi.yaml.tmpl */}}
"ai": {
  "coding_assistants": true,
  "hermes": {
    "dashboard": { "enabled": true, "port": 9119, "domain": "hermes.example.duckdns.org" },
    "agent_memory": true
  },
  "omniroute": { "enabled": true, "port": 20128, "domain": "omniroute.example.duckdns.org" },
  "coding_orchestrator": {
    "enabled": true,
    "schedule": "0 2 * * *",
    "budget_per_night": 5,
    "budget_per_task": 2
  },
  "ollama": { "enabled": false }
}
```

---

## 2. Installation Scripts

### `run_once_after_590-install-ai-tools.sh.tmpl`

```bash
#!/usr/bin/env bash

{{ template "common/script_is_not_ephemeral" . }}
{{ template "common/script_eval_mise" . }}
{{ template "common/script_helper" . }}

info ">>>>>> 🤖 Installing AI Tools 🤖 <<<<<<"

{{- /* NPM-based AI tools */}}
{{- range .ai_tools.npm }}
{{- $enabled := $.features.ai.coding_assistants }}
{{- if and $enabled (not .block_on_workplace) }}
info "Installing {{ .name }} (NPM)"
{{ .env | default "" }} npm install -g {{ .package }}
{{- if .completions_cmd }}
{{ template "common/script_validate_completions_path" $ }}
{{ .completions_cmd }} > "{{ $.chezmoi.homeDir }}/.local/share/zsh/site-functions/_{{ .name }}"
{{- end }}
{{- end }}
{{- end }}

{{- /* Curl-install AI tools */}}
{{- range .ai_tools.curl }}
{{- $enabled := $.features.ai.coding_assistants }}
{{- if and $enabled (not .block_on_workplace) }}
info "Installing {{ .name }} (curl)"
{{ .script | default (printf "curl -fsSL %s | bash" .url) | indent 2 }}
{{- if .completions_cmd }}
{{ template "common/script_validate_completions_path" $ }}
{{ .completions_cmd }} > "{{ $.chezmoi.homeDir }}/.local/share/zsh/site-functions/_{{ .name }}"
{{- end }}
{{- end }}
{{- end }}

{{- /* Hermes (if dashboard enabled) */}}
{{- if .features.ai.hermes.dashboard.enabled }}
info "Installing Hermes..."
{{ template "common/script_install_binary" dict
  "name" "hermes"
  "repo" "nousresearch/hermes-agent"
  "version" "latest"
  "asset_pattern" "https://github.com/nousresearch/hermes-agent/releases/download/%s/hermes_%s_linux_arm64.tar.gz"
  "completions_cmd" "hermes completion zsh"
}}
{{- end }}

{{- /* OmniRoute (if enabled) */}}
{{- if .features.ai.omniroute.enabled }}
info "Installing OmniRoute..."
{{ template "common/script_install_binary" dict
  "name" "omniroute"
  "repo" "nousresearch/omniroute"
  "version" "latest"
  "asset_pattern" "https://github.com/nousresearch/omniroute/releases/download/%s/omniroute_%s_linux_arm64.tar.gz"
  "completions_cmd" "omniroute completion zsh"
}}
{{- end }}

{{- /* Coding Orchestrator (VPS only) */}}
{{- if and $.features.ai.coding_orchestrator.enabled $.settings.vps }}
info "Installing Coding Orchestrator..."
{{ template "common/script_install_binary" dict
  "name" "coding-orchestrator"
  "repo" "fabiosouzadev/coding-orchestrator"
  "version" "latest"
  "asset_pattern" "https://github.com/fabiosouzadev/coding-orchestrator/releases/download/%s/coding-orchestrator_%s_linux_arm64.tar.gz"
  "completions_cmd" "coding-orchestrator completion zsh"
}}
{{- end }}

success ">>> 🤖 AI Tools Installed 🤖"
```

### AI Tools Data: `.chezmoidata/common/ai_tools.yaml`

```yaml
npm:
  - name: "aider"
    package: "aider-chat"
    completions_cmd: "aider --completion-zsh"
    block_on_workplace: false
    env: "AIDER_MODEL=claude-3-5-sonnet-20241022 AIDER_WEAK_MODEL=claude-3-haiku-20240307"
  
  - name: "claude-code"
    package: "@anthropic-ai/claude-code"
    completions_cmd: "claude completion zsh"
    block_on_workplace: true
  
  - name: "continue"
    package: "continue"
    completions_cmd: "continue --completion zsh"
    block_on_workplace: false

curl:
  - name: "opencode"
    url: "https://opencode.ai/install.sh"
    script: "curl -fsSL https://opencode.ai/install.sh | bash"
    completions_cmd: "opencode completion zsh"
    block_on_workplace: false
  
  - name: "amp"
    url: "https://ampcode.com/install.sh"
    script: "curl -fsSL https://ampcode.com/install.sh | bash"
    completions_cmd: "amp completion zsh"
    block_on_workplace: false
```

---

## 3. Hermes Configuration

### Config File: `home/.config/hermes/config.yaml`

```yaml
# Hermes Agent Configuration
server:
  host: "0.0.0.0"
  port: 9119
  cors_origins:
    - "https://hermes.example.duckdns.org"
    - "http://localhost:9119"

# Memory & Context
memory:
  type: "sqlite"
  path: "~/.local/share/hermes/memory.db"
  max_messages: 10000
  embedding_model: "nomic-embed-text"

# Model Providers (via OmniRoute)
providers:
  omniroute:
    url: "http://localhost:20128"
    timeout: 300
  ollama:
    url: "http://localhost:11434"
    enabled: false

# Skills
skills:
  auto_load: true
  paths:
    - "~/.config/hermes/skills"
    - "~/.local/share/hermes/skills"

# Tools
tools:
  enabled: true
  approval_mode: "auto"  # auto, ask, deny
  max_parallel: 3

# Logging
logging:
  level: "info"
  file: "~/.local/share/hermes/logs/hermes.log"
  max_size: "10MB"
  max_files: 5
```

### Systemd Service (VPS): `home/.config/systemd/user/hermes.service`

```ini
[Unit]
Description=Hermes Agent
After=network-online.target omniroute.service
Wants=network-online.target omniroute.service

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu
Environment=HOME=/home/ubuntu
Environment=PATH=/home/ubuntu/.local/bin:/usr/local/bin:/usr/bin:/bin
Environment=HERMES_CONFIG_DIR=/home/ubuntu/.config/hermes
ExecStart=/home/ubuntu/.local/bin/hermes serve --port 9119
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
MemoryLimit=512M

[Install]
WantedBy=default.target
```

---

## 4. OmniRoute Configuration

### Config File: `home/.config/omniroute/config.yaml`

```yaml
# OmniRoute LLM Gateway Configuration
server:
  host: "0.0.0.0"
  port: 20128
  cors_origins:
    - "https://omniroute.example.duckdns.org"
    - "http://localhost:20128"

# Routing Rules
routing:
  default_provider: "anthropic"
  fallback_providers: ["openai", "ollama"]
  rules:
    - pattern: "^claude-"
      provider: "anthropic"
    - pattern: "^gpt-"
      provider: "openai"
    - pattern: "^llama-"
      provider: "ollama"

# Providers
providers:
  anthropic:
    api_key_env: "ANTHROPIC_API_KEY"
    base_url: "https://api.anthropic.com"
    models:
      - "claude-3-5-sonnet-20241022"
      - "claude-3-haiku-20240307"
      - "claude-3-opus-20240229"
  
  openai:
    api_key_env: "OPENAI_API_KEY"
    base_url: "https://api.openai.com/v1"
    models:
      - "gpt-4o"
      - "gpt-4o-mini"
      - "gpt-4-turbo"
  
  ollama:
    base_url: "http://localhost:11434"
    enabled: false
    models: []

# Rate Limiting
rate_limits:
  requests_per_minute: 60
  tokens_per_minute: 100000

# Logging
logging:
  level: "info"
  file: "~/.local/share/omniroute/logs/omniroute.log"
```

### Systemd Service (VPS): `home/.config/systemd/user/omniroute.service`

```ini
[Unit]
Description=OmniRoute LLM Gateway
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu
Environment=HOME=/home/ubuntu
Environment=PATH=/home/ubuntu/.local/bin:/usr/local/bin:/usr/bin:/bin
Environment=OMNIROUTE_CONFIG_DIR=/home/ubuntu/.config/omniroute
Environment=ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
Environment=OPENAI_API_KEY=${OPENAI_API_KEY}
ExecStart=/home/ubuntu/.local/bin/omniroute serve --port 20128
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
MemoryLimit=256M

[Install]
WantedBy=default.target
```

---

## 5. Coding Orchestrator Configuration

### Config File: `home/.config/coding-orchestrator/config.yaml`

```yaml
# Coding Orchestrator - Nightly Autonomous Agent
orchestrator:
  # Schedule
  schedule: "0 2 * * *"  # Daily at 02:00 UTC
  timezone: "UTC"
  
  # Budget Controls
  budget:
    per_night_usd: 5.00
    per_task_usd: 2.00
    hard_limit_usd: 10.00
  
  # Task Sources
  task_sources:
    - type: "github_issues"
      repo: "fabiosouzadev/dotfiles"
      labels: ["ai-task", "orchestrator"]
      max_tasks_per_night: 3
    - type: "local_file"
      path: "~/.config/coding-orchestrator/tasks.yaml"
      max_tasks_per_night: 2
  
  # Agent Configuration
  agent:
    model: "claude-3-5-sonnet-20241022"
    max_turns: 50
    timeout_minutes: 60
    worktree_base: "~/orchestrator-worktrees"
    git_user: "coding-orchestrator[bot]"
    git_email: "orchestrator@fabiosouzadev.duckdns.org"
  
  # Safety
  safety:
    require_approval: false
    auto_merge: false
    max_files_per_pr: 20
    blocked_paths:
      - ".chezmoidata/**/secrets*"
      - "private_*"
      - "*.asc"
      - "*.age"
  
  # Notifications
  notifications:
    telegram:
      enabled: true
      bot_token_env: "TELEGRAM_BOT_TOKEN"
      chat_id_env: "TELEGRAM_CHAT_ID"
      notify_on_start: true
      notify_on_complete: true
      notify_on_error: true
    email:
      enabled: false
  
  # Logging
  logging:
    level: "info"
    file: "~/.local/share/coding-orchestrator/logs/orchestrator.log"
    retain_days: 30
```

### Systemd Service + Timer (VPS)

```ini
# home/.config/systemd/user/coding-orchestrator.service
[Unit]
Description=Coding Orchestrator (Nightly AI Agent)
After=network-online.target hermes.service omniroute.service
Wants=network-online.target hermes.service omniroute.service

[Service]
Type=oneshot
User=ubuntu
WorkingDirectory=/home/ubuntu
Environment=HOME=/home/ubuntu
Environment=PATH=/home/ubuntu/.local/bin:/usr/local/bin:/usr/bin:/bin
Environment=ORCHESTRATOR_CONFIG_DIR=/home/ubuntu/.config/coding-orchestrator
Environment=ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
Environment=TELEGRAM_BOT_TOKEN=${TELEGRAM_BOT_TOKEN}
Environment=TELEGRAM_CHAT_ID=${TELEGRAM_CHAT_ID}
ExecStart=/home/ubuntu/.local/bin/coding-orchestrator run --schedule
StandardOutput=journal
StandardError=journal
TimeoutSec=7200  # 2 hours max

[Install]
WantedBy=default.target
```

```ini
# home/.config/systemd/user/coding-orchestrator.timer
[Unit]
Description=Run Coding Orchestrator daily at 02:00 UTC

[Timer]
OnCalendar=*-*-* 02:00:00 UTC
Persistent=true
RandomizedDelaySec=15min

[Install]
WantedBy=timers.target
```

---

## 6. Zsh Integration

### Module: `dot_zshrc.d/300-ai-tools.zsh`

```zsh
# AI Tools Configuration
# Only loaded when .features.ai.coding_assistants = true

# ===== AIDER =====
export AIDER_MODEL="${AIDER_MODEL:-claude-3-5-sonnet-20241022}"
export AIDER_WEAK_MODEL="${AIDER_WEAK_MODEL:-claude-3-haiku-20240307}"
export AIDER_DARK_MODE="true"
export AIDER_PRETTY="true"

alias aider-dev="aider --model \$AIDER_MODEL --weak-model \$AIDER_WEAK_MODEL"
alias aider-quick="aider --model \$AIDER_WEAK_MODEL --no-git"

# Aider with OmniRoute
aider-or() {
  AIDER_API_BASE="http://localhost:20128/v1" \
  AIDER_API_KEY="omniroute" \
  aider "\$@"
}

# ===== CLAUDE CODE =====
export CLAUDE_CODE_MAX_TURNS="${CLAUDE_CODE_MAX_TURNS:-50}"
alias cc="claude-code"

# ===== CONTINUE =====
alias continue-dev="continue --model deepseek-coder"

# ===== OPENCODE / AMP =====
alias oc="opencode"
alias amp="amp"

# ===== GIT WORKTREES FOR AI AGENTS =====
ai-worktree() {
  local branch="\$1"
  local repo_root=\$(git rev-parse --show-toplevel 2>/dev/null)
  if [[ -n "\$repo_root" && -n "\$branch" ]]; then
    local wt_path="\$repo_root/../\$(basename \$repo_root)-\$branch"
    git worktree add "\$wt_path" "\$branch" 2>/dev/null || git worktree add "\$wt_path" -b "\$branch"
    cd "\$wt_path"
  fi
}

ai-worktree-clean() {
  local repo_root=\$(git rev-parse --show-toplevel 2>/dev/null)
  if [[ -n "\$repo_root" ]]; then
    git worktree prune
    git worktree list | grep -E "orchestrator|ai-" | awk '{print \$1}' | xargs -r git worktree remove
  fi
}
```

### Hermes Module: `dot_zshrc.d/310-hermes.zsh`

```zsh
# Hermes Integration
# Only loaded when .features.ai.hermes.dashboard.enabled = true

export HERMES_URL="${HERMES_URL:-http://localhost:9119}"
export HERMES_API_KEY="${HERMES_API_KEY:-}"

alias hm="hermes"
alias hm-chat="hermes chat"
alias hm-task="hermes task"
alias hm-status="hermes status"
alias hm-logs="hermes logs"
alias hm-doctor="hermes doctor"

# Hermes sync (backup)
hm-sync() {
  if command -v hermes-sync &>/dev/null; then
    hermes-sync backup --output "\$HOME/.local/share/hermes/backups/\$(date +%Y%m%d).sql"
  fi
}

# Quick health check
hm-health() {
  curl -sf "\$HERMES_URL/health" | jq .
}
```

### OmniRoute Module: `dot_zshrc.d/320-omniroute.zsh`

```zsh
# OmniRoute Integration
# Only loaded when .features.ai.omniroute.enabled = true

export OMNIROUTE_URL="${OMNIROUTE_URL:-http://localhost:20128}"
export OMNIROUTE_API_KEY="${OMNIROUTE_API_KEY:-}"

alias or="omniroute"
alias or-status="omniroute status"
alias or-models="omniroute models"
alias or-logs="omniroute logs"
alias or-doctor="omniroute doctor"

# Test routing
or-test() {
  local prompt="\${1:-Hello, world!}"
  curl -sf -X POST "\$OMNIROUTE_URL/v1/chat/completions" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer \$OMNIROUTE_API_KEY" \
    -d "{\"model\":\"claude-3-5-sonnet-20241022\",\"messages\":[{\"role\":\"user\",\"content\":\"\$prompt\"}]}" | jq .
}
```

### Orchestrator Module: `dot_zshrc.d/330-coding-orchestrator.zsh`

```zsh
# Coding Orchestrator Integration
# Only loaded when .features.ai.coding_orchestrator.enabled = true

export ORCHESTRATOR_URL="${ORCHESTRATOR_URL:-}"
export ORCHESTRATOR_BUDGET_PER_NIGHT="${ORCHESTRATOR_BUDGET_PER_NIGHT:-5}"
export ORCHESTRATOR_BUDGET_PER_TASK="${ORCHESTRATOR_BUDGET_PER_TASK:-2}"

alias co="coding-orchestrator"
alias co-run="coding-orchestrator run --once"
alias co-status="coding-orchestrator status"
alias co-logs="coding-orchestrator logs"
alias co-budget="coding-orchestrator budget"

# Manual trigger with task
co-task() {
  local task="\$1"
  coding-orchestrator run --task "\$task"
}

# View worktrees
co-worktrees() {
  ls -la ~/orchestrator-worktrees/ 2>/dev/null || echo "No worktrees"
}
```

---

## 7. Sync & Backup (Hermes/OmniRoute)

### Hermes Sync Tool

```bash
# Backup Hermes memory (SQLite)
hermes-sync backup --output ~/.local/share/hermes/backups/$(date +%Y%m%d).sql

# Restore
hermes-sync restore --input ~/.local/share/hermes/backups/20260115.sql

# Selective export (conversations only)
hermes-sync export --type conversations --format json --output ~/hermes-export.json

# Doctor (health check)
hermes-sync doctor
```

### OmniRoute Sync Tool

```bash
# Backup OmniRoute config + logs
omniroute-sync backup --output ~/.local/share/omniroute/backups/$(date +%Y%m%d).tar.gz

# Restore
omniroute-sync restore --input ~/.local/share/omniroute/backups/20260115.tar.gz

# Doctor
omniroute-sync doctor
```

### Automated Backup Script: `run_once_after_620-backup-ai-stack.sh.tmpl`

```bash
#!/usr/bin/env bash

{{ template "common/script_is_not_ephemeral" . }}
{{ template "common/script_helper" . }}

info ">>>>>> 🤖 AI Stack Backup 🤖 <<<<<<"

DATE=\$(date +%Y%m%d)
BACKUP_DIR="\$HOME/.local/share/ai-backups/\$DATE"
mkdir -p "\$BACKUP_DIR"

{{- if .features.ai.hermes.dashboard.enabled }}
# Hermes backup
if command -v hermes-sync &>/dev/null; then
  hermes-sync backup --output "\$BACKUP_DIR/hermes-\$DATE.sql"
  success "Hermes backed up"
fi
{{- end }}

{{- if .features.ai.omniroute.enabled }}
# OmniRoute backup
if command -v omniroute-sync &>/dev/null; then
  omniroute-sync backup --output "\$BACKUP_DIR/omniroute-\$DATE.tar.gz"
  success "OmniRoute backed up"
fi
{{- end }}

{{- if .features.ai.coding_orchestrator.enabled }}
# Orchestrator logs backup
if [[ -d "\$HOME/.local/share/coding-orchestrator/logs" ]]; then
  tar -czf "\$BACKUP_DIR/orchestrator-\$DATE.tar.gz" -C "\$HOME/.local/share" coding-orchestrator/logs
  success "Orchestrator logs backed up"
fi
{{- end }}

# Retention (keep 30 days)
find "\$HOME/.local/share/ai-backups" -type d -mtime +30 -exec rm -rf {} \;

success ">>> 🤖 AI Stack Backup Complete: \$BACKUP_DIR 🤖"
```

---

## 8. Secrets Management

### Required Environment Variables (VPS)

```bash
# In ~/.config/chezmoi/chezmoi.yaml or systemd Environment
ANTHROPIC_API_KEY="sk-ant-..."
OPENAI_API_KEY="sk-..."
TELEGRAM_BOT_TOKEN="123:ABC..."
TELEGRAM_CHAT_ID="-1001234567890"
```

### Age-Encrypted Secrets: `.chezmoidata/vps/secrets.toml.age`

```toml
anthropic_api_key = "sk-ant-..."
openai_api_key = "sk-..."
telegram_bot_token = "123:ABC..."
telegram_chat_id = "-1001234567890"
```

---

## 9. Testing AI Stack

### Health Checks

```bash
#!/usr/bin/env bash
# verify_ai_stack.sh

checks=(
  "aider:command -v aider"
  "hermes_binary:command -v hermes"
  "omniroute_binary:command -v omniroute"
  "orchestrator_binary:command -v coding-orchestrator"
  "hermes_service:systemctl --user is-active hermes"
  "omniroute_service:systemctl --user is-active omniroute"
  "orchestrator_timer:systemctl --user is-active coding-orchestrator.timer"
  "hermes_health:curl -sf http://localhost:9119/health"
  "omniroute_health:curl -sf http://localhost:20128/health"
)

for check in "${checks[@]}"; do
  name="${check%%:*}"
  cmd="${check#*:}"
  if eval "$cmd" &>/dev/null; then
    echo "✅ $name"
  else
    echo "❌ $name"
  fi
done
```

### Test AI Routing

```bash
# Test OmniRoute routing
curl -X POST http://localhost:20128/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"claude-3-5-sonnet-20241022","messages":[{"role":"user","content":"Say hello in Portuguese"}]}' | jq .

# Test Hermes
hermes chat "Hello, test message"

# Test Orchestrator dry run
coding-orchestrator run --dry-run --task "Add a comment to README.md"
```

---

## 10. Common Issues & Fixes

| Issue | Cause | Fix |
|-------|-------|-----|
| Hermes can't connect to OmniRoute | OmniRoute not running | `systemctl --user start omniroute` |
| OmniRoute 401 Unauthorized | API keys not set | Check `ANTHROPIC_API_KEY`, `OPENAI_API_KEY` in env |
| Orchestrator budget exceeded | Too many tasks | Reduce `max_tasks_per_night` or increase budget |
| Aider uses wrong model | Env vars not set | Export `AIDER_MODEL`, `AIDER_WEAK_MODEL` |
| Worktrees not cleaning | Git worktree prune not run | Run `ai-worktree-clean` periodically |
| Telegram notifications fail | Bot token/chat ID wrong | Verify in BotFather and chat |
| Caddy TLS fails for AI domains | DNS not propagated | Wait for DuckDNS, check Caddy logs |

---

## 11. Related Skills

| Skill | Relationship |
|-------|--------------|
| `chezmoi-multi-profile` | AI features per profile |
| `chezmoi-secret-management` | API keys encryption |
| `chezmoi-script-lifecycle` | Install scripts |
| `dotfiles-vps-bootstrap` | Systemd services on VPS |
| `dotfiles-backup-strategy` | AI stack backup |
| `dotfiles-universal-binary-install` | Binary installation pattern |
| `dotfiles-zsh-modular` | Zsh integration modules |

---

## 12. References

- **Hermes Agent**: https://github.com/nousresearch/hermes-agent
- **OmniRoute**: https://github.com/nousresearch/omniroute
- **Aider**: https://aider.chat/
- **Claude Code**: https://github.com/anthropics/claude-code
- **Repo AI Config**: `fabiosouzadev/dotfiles` → `.chezmoidata/common/ai_tools.yaml`, `.chezmoiscripts/unix/run_once_after_590-install-ai-tools.sh.tmpl`, `dot_zshrc.d/3*`

---

*Generated via Loop Engineering Mode — Phase 4: Skill Creation. Validated against live repo analysis.*