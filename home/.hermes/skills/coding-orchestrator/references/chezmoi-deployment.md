# Chezmois Deployment Patterns for Coding Orchestrator

## Overview
All infrastructure (skills, cron jobs, scripts, config) is managed via chezmoi for portable VPS deployment.

## File Structure in Chezmois Repo (`~/.local/share/chezmoi/`)

```
home/
├── .chezmoi.yaml.tmpl                    # Feature flags
├── .chezmoiscripts/unix/
│   ├── run_once_after_540-install-coding-orchestrator.sh.tmpl
│   └── run_onchange_after_610-deploy-hermes-cron-jobs.sh.tmpl
├── .hermes/skills/coding-orchestrator/   # Skill source
│   ├── SKILL.md
│   ├── config.yaml
│   └── scripts/
├── private_dot_hermes/
│   ├── private_cron_jobs.json.tmpl       # Cron job template
│   └── private_config.yaml.tmpl          # Hermes config (has ANTHROPIC_API_KEY placeholder)
└── private_dot_config/
    └── caddy/
        └── Caddyfile.tmpl                # Webhook routes
```

---

## 1. Feature Flags (`.chezmoi.yaml.tmpl`)

```yaml
"ai" (dict
  "coding_assistants" true
  "spec_tools"        true
  "gsd"               true
  "multiplexer"       (not $isVps)
  "composio"          (not $isVps)

  "coding_orchestrator" (dict
    "install"             $isVps
    "skill_name"          "coding-orchestrator"
    "cron_schedule"       "0 2 * * *"
    "cron_label"          "coding-agent"
    "nightly_budget_usd"  5
    "per_task_budget_usd" 2
  )
)
```

---

## 2. Install Script (`run_once_after_540-install-coding-orchestrator.sh.tmpl`)

```bash
{{ if .features.ai.coding_orchestrator.install }}
SOURCE_SKILL_DIR="{{ .chezmoi.sourceDir }}/home/.hermes/skills/coding-orchestrator"
TARGET_SKILL_DIR="{{ .chezmoi.homeDir }}/.hermes/skills/coding-orchestrator"

rsync -av --delete "$SOURCE_SKILL_DIR/" "$TARGET_SKILL_DIR/"
chmod +x "$TARGET_SKILL_DIR/scripts/"*.sh

# Reload Hermes skills
hermes skill reload
{{ end }}
```

**Key points:**
- Runs once on `chezmoi apply`
- Uses `rsync` for idempotent sync
- Reloads Hermes to pick up new skill

---

## 3. Cron Job Template (`private_cron_jobs.json.tmpl`)

```json
{
  "jobs": [{
    "id": "coding-orchestrator-nightly",
    "name": "Coding Orchestrator - Nightly Autonomous Coding",
    "prompt": "Execute autonomous coding tasks...",
    "skills": ["coding-orchestrator"],
    "schedule": { "kind": "cron", "expr": "{{ .features.ai.coding_orchestrator.cron_schedule }}" },
    "enabled": {{ if .features.ai.coding_orchestrator.install }}true{{ else }}false{{ end }}
  }]
}
```

---

## 4. Deploy Script (`run_onchange_after_610-deploy-hermes-cron-jobs.sh.tmpl`)

```bash
{{ template "common/script_helper" . -}}

TEMPLATE_FILE="{{ .chezmoi.sourceDir }}/home/private_dot_hermes/private_cron_jobs.json.tmpl"
TARGET_FILE="{{ .chezmoi.homeDir }}/.hermes/cron/jobs.json"

chezmoi execute-template "$TEMPLATE_FILE" > "$TARGET_FILE"
hermes cron reload
```

**Triggers:** Runs on every `chezmoi apply` when template changes.

---

## 5. Webhook Caddy Config (`Caddyfile.tmpl`)

```caddy
hermes.fabiosouzadev.duckdns.org {
    handle /webhook* {
        reverse_proxy 127.0.0.1:9119
    }
    
    # ... existing Hermes dashboard config
}
```

---

## 6. Deployment Workflow

### On New VPS
```bash
# 1. Install chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)"

# 2. Initialize from your repo
chezmoi init https://github.com/youruser/dotfiles.git

# 3. Apply (feature flags auto-detect VPS)
chezmoi apply

# 4. Manual: Configure secrets in ~/.hermes/.env
#    ANTHROPIC_API_KEY, OMNIROUTE_API_KEY, etc.
```

### Update Existing VPS
```bash
cd ~/.local/share/chezmoi
git pull
chezmoi apply

# Or just sync skill changes
chezmoi apply --filter '.hermes/skills/coding-orchestrator'
```

---

## 7. Secrets Management

### Encrypted Files (age/GPG)
```bash
# Add encrypted secret
chezmoi add --encrypt ~/.hermes/.env

# Edit encrypted file
chezmoi edit ~/.hermes/.env

# View decrypted
chezmoi cat ~/.hermes/.env
```

### Required Secrets for Coding Orchestrator
```bash
# ~/.hermes/.env
OMNIROUTE_API_KEY=sk-...
OMNIROUTE_BASE_URL=http://localhost:20128/v1

# Optional (manual auth preferred)
# ANTHROPIC_API_KEY=sk-ant-...
```

---

## 8. Rollback

```bash
# Revert last chezmoi apply
cd ~/.local/share/chezmoi
git checkout HEAD~1
chezmoi apply

# Or restore specific file
chezmoi restore ~/.hermes/skills/coding-orchestrator
hermes skill reload
```

---

## 9. Verification Checklist

After `chezmoi apply` on VPS:

- [ ] `hermes skills list` shows `coding-orchestrator` enabled
- [ ] `hermes cron list` shows `coding-orchestrator-nightly` active
- [ ] `systemctl --user status omniroute` → active (port 20128)
- [ ] `systemctl --user status hermes-dashboard` → active (port 9119)
- [ ] `curl http://localhost:20128/api/monitoring/health` → 200
- [ ] `OPENAI_API_KEY="$OMNIROUTE_API_KEY" aider --model openai/omniroute/work --openai-api-base http://localhost:20128/v1 --yes --message "test"` → works
- [ ] `~/.hermes/skills/coding-orchestrator/scripts/coding-orchestrator.sh manual "test task"` → runs without error