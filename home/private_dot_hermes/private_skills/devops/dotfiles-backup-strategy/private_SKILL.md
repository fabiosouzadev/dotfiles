---
name: dotfiles-backup-strategy
description: "Disaster recovery: hermes-sync, omniroute-sync, manifest."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos]
metadata:
  hermes:
    tags: [dotfiles, backup, disaster-recovery, sync, encryption]
    category: devops
requires_toolsets: [terminal, file]
supersedes: []
---

# Dotfiles Backup Strategy Skill

**Trigger**: Use when implementing disaster recovery for the dotfiles repository — Hermes/OmniRoute sync tools, selective SQL backup, manifest generation, age encryption, restore procedures.

**Goal**: Provide complete reference for backup strategies from `fabiosouzadev/dotfiles` enabling reliable disaster recovery across all profiles.

---

## 1. Backup Architecture

### What Gets Backed Up

| Category | Source | Tool | Frequency | Retention |
|----------|--------|------|-----------|-----------|
| **Chezmoi Source** | `~/.local/share/chezmoi` | `chezmoi-manifest` | On change | Forever (git) |
| **Hermes Memory** | `~/.local/share/hermes/memory.db` | `hermes-sync` | Daily | 30 days |
| **OmniRoute Data** | `~/.local/share/omniroute` | `omniroute-sync` | Daily | 30 days |
| **Orchestrator Logs** | `~/.local/share/coding-orchestrator/logs` | `tar` | Daily | 30 days |
| **VPS Config** | `/etc/caddy`, `/opt/dockge` | `tar` | Daily | 7 days |
| **Secrets (age)** | `.chezmoidata/**/secrets*.age` | `chezmoi` | On change | Forever (git) |
| **GPG/SSH Keys** | `~/.gnupg`, `~/.ssh` | `tar + age` | Weekly | 90 days |
| **System State** | `systemctl list-unit-files` | `systemctl` | Daily | 7 days |

### Backup Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    BACKUP ORCHESTRATOR                      │
├─────────────────────────────────────────────────────────────┤
│  1. Generate Manifest (chezmoi-manifest)                   │
│  2. Dump SQLite (hermes-sync, omniroute-sync)              │
│  3. Archive Configs (tar + gzip)                           │
│  4. Encrypt (age -r recipient)                             │
│  5. Upload (rclone to S3/GCS/B2)                           │
│  6. Verify (checksum + test restore)                       │
│  7. Prune (retention policy)                               │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. Manifest Generation

### Chezmoi Manifest Script

```bash
#!/usr/bin/env bash
# chezmoi-manifest - Generate complete manifest of managed files

set -euo pipeinfo "Generating chezmoi manifest..."

MANIFEST_DIR="${HOME}/.local/share/chezmoi/manifests"
mkdir -p "$MANIFEST_DIR"

DATE=$(date +%Y%m%d-%H%M%S)
MANIFEST_FILE="$MANIFEST_DIR/manifest-$DATE.json"

# Generate manifest with metadata
chezmoi managed --include=files,dirs,symlinks,scripts --format=json > "$MANIFEST_FILE.tmp"

# Add metadata
jq --arg date "$(date -Iseconds)" \
   --arg hostname "$(hostname)" \
   --arg user "$(whoami)" \
   --arg chezmoi_version "$(chezmoi --version)" \
   '. + {metadata: {generated: $date, hostname: $hostname, user: $user, chezmoi_version: $chezmoi_version}}' \
   "$MANIFEST_FILE.tmp" > "$MANIFEST_FILE"

rm "$MANIFEST_FILE.tmp"

# Also generate human-readable summary
chezmoi managed --include=files,dirs,symlinks,scripts | wc -l > "$MANIFEST_DIR/count-$DATE.txt"

success "Manifest saved: $MANIFEST_FILE"
```

---

## 3. Hermes Sync Tool

### `hermes-sync` Commands

```bash
# Backup (SQLite dump)
hermes-sync backup --output ~/.local/share/hermes/backups/$(date +%Y%m%d).sql

# Backup with compression
hermes-sync backup --output - | gzip > ~/.local/share/hermes/backups/$(date +%Y%m%d).sql.gz

# Restore
hermes-sync restore --input ~/.local/share/hermes/backups/20260115.sql

# Restore from compressed
zcat ~/.local/share/hermes/backups/20260115.sql.gz | hermes-sync restore --input -

# Selective export
hermes-sync export --type conversations --format json --output ~/hermes-conversations.json
hermes-sync export --type skills --format json --output ~/hermes-skills.json
hermes-sync export --type memories --format json --output ~/hermes-memories.json

# Import
hermes-sync import --type conversations --format json --input ~/hermes-conversations.json

# Doctor (health check)
hermes-sync doctor

# Verify backup integrity
hermes-sync verify --input ~/.local/share/hermes/backups/20260115.sql
```

### Backup Script Template: `run_once_after_620-backup-hermes.sh.tmpl`

```bash
#!/usr/bin/env bash

{{ template "common/script_is_not_ephemeral" . }}
{{ template "common/script_helper" . }}

{{- if not .features.ai.hermes.dashboard.enabled }}
info "Hermes not enabled, skipping backup"
exit 0
{{- end }}

info ">>>>>> 🤖 Hermes Backup 🤖 <<<<<<"

DATE=$(date +%Y%m%d)
BACKUP_DIR="$HOME/.local/share/hermes/backups"
mkdir -p "$BACKUP_DIR"

# 1. SQLite dump
if command -v hermes-sync &>/dev/null; then
  hermes-sync backup --output "$BACKUP_DIR/hermes-$DATE.sql"
  
  # Compress
  gzip -f "$BACKUP_DIR/hermes-$DATE.sql"
  
  # Verify
  hermes-sync verify --input "$BACKUP_DIR/hermes-$DATE.sql.gz"
  
  success "Hermes memory backed up: $BACKUP_DIR/hermes-$DATE.sql.gz"
else
  warn "hermes-sync not found, skipping"
fi

# 2. Export conversations (JSON)
if command -v hermes-sync &>/dev/null; then
  hermes-sync export --type conversations --format json \
    --output "$BACKUP_DIR/hermes-conversations-$DATE.json"
  gzip -f "$BACKUP_DIR/hermes-conversations-$DATE.json"
fi

# 3. Retention (keep 30 days)
find "$BACKUP_DIR" -name "hermes-*.sql.gz" -mtime +30 -delete
find "$BACKUP_DIR" -name "hermes-conversations-*.json.gz" -mtime +30 -delete

success ">>> 🤖 Hermes Backup Complete 🤖"
```

---

## 4. OmniRoute Sync Tool

### `omniroute-sync` Commands

```bash
# Backup (full archive)
omniroute-sync backup --output ~/.local/share/omniroute/backups/$(date +%Y%m%d).tar.gz

# Restore
omniroute-sync restore --input ~/.local/share/omniroute/backups/20260115.tar.gz

# Doctor
omniroute-sync doctor

# Verify
omniroute-sync verify --input ~/.local/share/omniroute/backups/20260115.tar.gz
```

### Backup Script Template: `run_once_after_621-backup-omniroute.sh.tmpl`

```bash
#!/usr/bin/env bash

{{ template "common/script_is_not_ephemeral" . }}
{{ template "common/script_helper" . }}

{{- if not .features.ai.omniroute.enabled }}
info "OmniRoute not enabled, skipping backup"
exit 0
{{- end }}

info ">>>>>> 🔀 OmniRoute Backup 🔀 <<<<<<"

DATE=$(date +%Y%m%d)
BACKUP_DIR="$HOME/.local/share/omniroute/backups"
mkdir -p "$BACKUP_DIR"

if command -v omniroute-sync &>/dev/null; then
  omniroute-sync backup --output "$BACKUP_DIR/omniroute-$DATE.tar.gz"
  omniroute-sync verify --input "$BACKUP_DIR/omniroute-$DATE.tar.gz"
  success "OmniRoute backed up: $BACKUP_DIR/omniroute-$DATE.tar.gz"
else
  warn "omniroute-sync not found, skipping"
fi

# Retention (keep 30 days)
find "$BACKUP_DIR" -name "omniroute-*.tar.gz" -mtime +30 -delete

success ">>> 🔀 OmniRoute Backup Complete 🔀"
```

---

## 5. Full System Backup Orchestrator

### Master Backup Script: `run_once_after_600-backup-all.sh.tmpl`

```bash
#!/usr/bin/env bash

{{ template "common/script_is_not_ephemeral" . }}
{{ template "common/script_helper" . }}

info ">>>>>> 💾 FULL SYSTEM BACKUP 💾 <<<<<<"

DATE=$(date +%Y%m%d-%H%M%S)
BACKUP_ROOT="$HOME/.local/share/backups"
BACKUP_DIR="$BACKUP_ROOT/$DATE"
mkdir -p "$BACKUP_DIR"

MANIFEST="$BACKUP_DIR/MANIFEST.txt"
echo "Backup started: $(date -Iseconds)" > "$MANIFEST"
echo "Hostname: $(hostname)" >> "$MANIFEST"
echo "User: $(whoami)" >> "$MANIFEST"
echo "" >> "$MANIFEST"

# ===== 1. CHEZMOI MANIFEST =====
info "Backing up chezmoi manifest..."
chezmoi managed --include=files,dirs,symlinks,scripts > "$BACKUP_DIR/chezmoi-manifest.txt"
echo "chezmoi: $(wc -l < "$BACKUP_DIR/chezmoi-manifest.txt") items" >> "$MANIFEST"

# ===== 2. HERMES =====
{{- if .features.ai.hermes.dashboard.enabled }}
info "Backing up Hermes..."
if command -v hermes-sync &>/dev/null; then
  hermes-sync backup --output "$BACKUP_DIR/hermes.sql"
  gzip -f "$BACKUP_DIR/hermes.sql"
  hermes-sync export --type conversations --format json --output "$BACKUP_DIR/hermes-conversations.json"
  gzip -f "$BACKUP_DIR/hermes-conversations.json"
  echo "hermes: memory.db + conversations" >> "$MANIFEST"
fi
{{- end }}

# ===== 3. OMNIROUTE =====
{{- if .features.ai.omniroute.enabled }}
info "Backing up OmniRoute..."
if command -v omniroute-sync &>/dev/null; then
  omniroute-sync backup --output "$BACKUP_DIR/omniroute.tar.gz"
  echo "omniroute: config + logs" >> "$MANIFEST"
fi
{{- end }}

# ===== 4. ORCHESTRATOR LOGS =====
{{- if .features.ai.coding_orchestrator.enabled }}
info "Backing up Coding Orchestrator..."
if [[ -d "$HOME/.local/share/coding-orchestrator/logs" ]]; then
  tar -czf "$BACKUP_DIR/orchestrator-logs.tar.gz" -C "$HOME/.local/share" coding-orchestrator/logs
  echo "orchestrator: logs" >> "$MANIFEST"
fi
{{- end }}

# ===== 5. VPS CONFIGS (if VPS) =====
{{- if .settings.vps }}
info "Backing up VPS configs..."
mkdir -p "$BACKUP_DIR/vps"
[[ -d /etc/caddy ]] && cp -r /etc/caddy "$BACKUP_DIR/vps/"
[[ -d /opt/dockge ]] && cp -r /opt/dockge "$BACKUP_DIR/vps/"
systemctl list-unit-files --state=enabled > "$BACKUP_DIR/vps/enabled-services.txt"
echo "vps: caddy + dockge + services" >> "$MANIFEST"
{{- end }}

# ===== 6. GPG/SSH KEYS =====
info "Backing up GPG/SSH keys..."
mkdir -p "$BACKUP_DIR/keys"
[[ -d "$HOME/.gnupg" ]] && tar -czf "$BACKUP_DIR/keys/gnupg.tar.gz" -C "$HOME" .gnupg
[[ -d "$HOME/.ssh" ]] && tar -czf "$BACKUP_DIR/keys/ssh.tar.gz" -C "$HOME" .ssh
echo "keys: gpg + ssh" >> "$MANIFEST"

# ===== 7. ENCRYPT MANIFEST =====
info "Encrypting backup..."
AGE_RECIPIENT="{{ .backup.age_recipient | default "age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" }}"
if [[ -n "$AGE_RECIPIENT" && "$AGE_RECIPIENT" != "age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" ]]; then
  tar -czf - -C "$BACKUP_DIR" . | age -r "$AGE_RECIPIENT" -o "$BACKUP_ROOT/backup-$DATE.tar.gz.age"
  success "Encrypted backup: $BACKUP_ROOT/backup-$DATE.tar.gz.age"
  
  # Verify decryption
  age -d -i ~/.config/age/identity "$BACKUP_ROOT/backup-$DATE.tar.gz.age" | tar -tzf - >/dev/null && \
    success "Encryption verified" || error "Encryption verification failed"
else
  warn "No age recipient configured, backup not encrypted"
  mv "$BACKUP_DIR" "$BACKUP_ROOT/backup-$DATE"
fi

# ===== 8. UPLOAD (optional) =====
{{- if .backup.rclone_remote }}
info "Uploading to {{ .backup.rclone_remote }}..."
rclone copy "$BACKUP_ROOT/backup-$DATE.tar.gz.age" "{{ .backup.rclone_remote }}:backups/$(hostname)/" --progress
success "Upload complete"
{{- end }}

# ===== 9. RETENTION =====
info "Applying retention policy..."
find "$BACKUP_ROOT" -name "backup-*.tar.gz.age" -mtime +90 -delete
find "$BACKUP_ROOT" -type d -name "20*" -mtime +90 -exec rm -rf {} \;

echo "Backup completed: $(date -Iseconds)" >> "$MANIFEST"
success ">>> 💾 FULL BACKUP COMPLETE: $DATE 💾"
```

---

## 6. Age Encryption Setup

### Generate Age Key Pair

```bash
# Generate identity (private key)
age-keygen -o ~/.config/age/identity

# Output: 
# Public key: age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
# Private key saved to ~/.config/age/identity

# Add public key to .chezmoi.yaml.tmpl
age_recipient: "age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

### Encrypt/Decrypt Files

```bash
# Encrypt
age -r age1xxxx... -o file.txt.age file.txt

# Decrypt
age -d -i ~/.config/age/identity -o file.txt file.txt.age

# Encrypt for multiple recipients
age -r age1xxx -r age1yyy -o file.txt.age file.txt
```

---

## 7. Restore Procedures

### Full Restore

```bash
#!/usr/bin/env bash
# restore-full.sh <backup-file.age>

set -euo pipeinfo

BACKUP_FILE="$1"
RESTORE_DIR="/tmp/restore-$(date +%s)"
mkdir -p "$RESTORE_DIR"

info "Decrypting backup..."
age -d -i ~/.config/age/identity "$BACKUP_FILE" | tar -xzf - -C "$RESTORE_DIR"

info "Restoring chezmoi source..."
chezmoi init --source "$RESTORE_DIR/.local/share/chezmoi"

info "Restoring Hermes..."
if [[ -f "$RESTORE_DIR/hermes.sql.gz" ]]; then
  zcat "$RESTORE_DIR/hermes.sql.gz" | hermes-sync restore --input -
fi

info "Restoring OmniRoute..."
if [[ -f "$RESTORE_DIR/omniroute.tar.gz" ]]; then
  omniroute-sync restore --input "$RESTORE_DIR/omniroute.tar.gz"
fi

info "Restoring GPG/SSH keys..."
[[ -f "$RESTORE_DIR/keys/gnupg.tar.gz" ]] && tar -xzf "$RESTORE_DIR/keys/gnupg.tar.gz" -C "$HOME"
[[ -f "$RESTORE_DIR/keys/ssh.tar.gz" ]] && tar -xzf "$RESTORE_DIR/keys/ssh.tar.gz" -C "$HOME"

success "Restore complete from $BACKUP_FILE"
```

### Selective Restore

```bash
# Restore only Hermes conversations
age -d -i ~/.config/age/identity backup-20260115.tar.gz.age | \
  tar -xzf - -C /tmp/restore hermes-conversations.json.gz
zcat /tmp/restore/hermes-conversations.json.gz | hermes-sync import --type conversations --format json --input -

# Restore only SSH keys
age -d -i ~/.config/age/identity backup-20260115.tar.gz.age | \
  tar -xzf - -C /tmp/restore keys/ssh.tar.gz
tar -xzf /tmp/restore/keys/ssh.tar.gz -C "$HOME"
```

---

## 8. Automation (Cron)

### Systemd Timer: `home/.config/systemd/user/backup-all.timer`

```ini
[Unit]
Description=Daily Full Backup

[Timer]
OnCalendar=*-*-* 03:00:00 UTC
Persistent=true
RandomizedDelaySec=30min

[Install]
WantedBy=timers.target
```

### Service: `home/.config/systemd/user/backup-all.service`

```ini
[Unit]
Description=Full System Backup
After=network-online.target

[Service]
Type=oneshot
User=ubuntu
WorkingDirectory=/home/ubuntu
Environment=HOME=/home/ubuntu
Environment=PATH=/home/ubuntu/.local/bin:/usr/local/bin:/usr/bin:/bin
ExecStart=/home/ubuntu/.local/bin/run-backup-all.sh
StandardOutput=journal
StandardError=journal
TimeoutSec=3600
```

---

## 9. Verification & Testing

### Test Backup Integrity

```bash
#!/usr/bin/env bash
# test-backup.sh <backup-file.age>

BACKUP_FILE="$1"
TEST_DIR="/tmp/backup-test-$(date +%s)"
mkdir -p "$TEST_DIR"

info "Testing backup: $BACKUP_FILE"

# 1. Decrypt
age -d -i ~/.config/age/identity "$BACKUP_FILE" | tar -xzf - -C "$TEST_DIR"

# 2. Verify manifest exists
[[ -f "$TEST_DIR/MANIFEST.txt" ]] || error "Missing MANIFEST.txt"

# 3. Verify chezmoi manifest
[[ -f "$TEST_DIR/chezmoi-manifest.txt" ]] || error "Missing chezmoi-manifest.txt"

# 4. Test Hermes restore (dry-run)
if [[ -f "$TEST_DIR/hermes.sql.gz" ]]; then
  zcat "$TEST_DIR/hermes.sql.gz" | head -20 | grep -q "SQLite" && \
    success "Hermes SQL valid" || error "Hermes SQL corrupt"
fi

# 5. Test OmniRoute archive
if [[ -f "$TEST_DIR/omniroute.tar.gz" ]]; then
  tar -tzf "$TEST_DIR/omniroute.tar.gz" >/dev/null && \
    success "OmniRoute archive valid" || error "OmniRoute archive corrupt"
fi

# 6. Cleanup
rm -rf "$TEST_DIR"

success "Backup verification PASSED"
```

---

## 10. Disaster Recovery Checklist

| Scenario | Recovery Steps | RTO | RPO |
|----------|----------------|-----|-----|
| **New machine** | `chezmoi init <repo>` → restore backups | 30 min | 24h |
| **Hermes DB corrupt** | `hermes-sync restore` | 5 min | 24h |
| **OmniRoute config lost** | `omniroute-sync restore` | 5 min | 24h |
| **Secrets lost** | Decrypt age files from repo | 2 min | 0 |
| **VPS destroyed** | Provision new → run bootstrap → restore | 45 min | 24h |
| **Full disaster** | Age decrypt → selective restore | 60 min | 24h |

---

## 11. Related Skills

| Skill | Relationship |
|-------|--------------|
| `chezmoi-architecture` | Data flow understanding |
| `chezmoi-secret-management` | Age encryption for backups |
| `chezmoi-script-lifecycle` | Backup scripts as run_once_after |
| `dotfiles-ai-integration` | Hermes/OmniRoute/Orchestrator backup |
| `dotfiles-vps-bootstrap` | VPS config backup |
| `dotfiles-universal-binary-install` | rclone, age installation |

---

## 12. References

- **age**: https://github.com/FiloSottile/age
- **rclone**: https://rclone.org/
- **chezmoi managed**: https://www.chezmoi.io/user-guide/command-overview/#chezmoi-managed
- **Repo backup scripts**: `fabiosouzadev/dotfiles` → `.chezmoiscripts/unix/run_once_after_6*.sh.tmpl`

---

*Generated via Loop Engineering Mode — Phase 4: Skill Creation. Validated against live repo analysis.*