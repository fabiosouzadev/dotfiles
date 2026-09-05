---
name: dotfiles-vps-bootstrap
description: "Bootstrap Oracle ARM64 VPS: Dockge, Caddy, Tailscale."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [dotfiles, vps, oracle, arm64, dockge, caddy, tailscale]
    category: devops
requires_toolsets: [terminal, file]
supersedes: []
---

# Dotfiles VPS Bootstrap Skill

**Trigger**: Use when provisioning or debugging Oracle Cloud ARM64 VPS bootstrap — Dockge (Docker UI), Caddy (reverse proxy), Tailscale (VPN), DuckDNS (dynamic DNS), systemd services, monitoring.

**Goal**: Provide complete reference for VPS bootstrap patterns from `fabiosouzadev/dotfiles` enabling reproducible, secure ARM64 VPS provisioning.

---

## 1. VPS Architecture Overview

### Target Environment

| Property | Value |
|----------|-------|
| **Provider** | Oracle Cloud Free Tier |
| **Architecture** | ARM64 (Ampere Altra) |
| **OS** | Ubuntu 22.04/24.04 LTS |
| **User** | `ubuntu` (default) |
| **Hostname** | `instance-<id>` |
| **RAM** | 24 GB |
| **CPU** | 4 OCPUs |
| **Storage** | 200 GB boot volume |

### Services Deployed

```
┌─────────────────────────────────────────────────────────────┐
│                    VPS (ARM64 Ubuntu)                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │   Dockge    │  │    Caddy    │  │     Tailscale       │ │
│  │  (Port 5001)│  │  (80/443)   │  │   (Mesh VPN)        │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │  DuckDNS    │  │   Hermes    │  │    OmniRoute        │ │
│  │  (Dynamic)  │  │  (Port 9119)│  │   (Port 20128)      │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
│  ┌─────────────────────────────────────────────────────┐   │
│  │           Coding Orchestrator (Cron 02:00)          │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. Bootstrap Script Structure

### Main VPS Script: `run_once_after_500-setup-vps-infra.sh.tmpl`

```bash
#!/usr/bin/env bash

{{ template "common/script_is_not_ephemeral" . }}
{{ template "common/script_requires_sudo" . }}
{{ template "common/script_helper" . }}

info ">>>>>> 🖥️ VPS Infrastructure Setup 🖥️ <<<<<<<"

{{- /* ===== 1. DOCKER & DOCKGE ===== */}}
info "Setting up Docker & Dockge..."

# Docker (official repo)
install_docker() {
  if command -v docker &>/dev/null; then
    info "Docker already installed"
    return
  fi
  
  # Add Docker GPG key
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg
  
  # Add repository
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null
  
  apt update
  apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  
  # Enable for ubuntu user
  usermod -aG docker ubuntu
}

install_docker

# Dockge - Docker management UI
info "Setting up Dockge..."
mkdir -p /opt/dockge
curl -fsSL https://raw.githubusercontent.com/louislam/dockge/master/compose.yaml -o /opt/dockge/compose.yaml
curl -fsSL https://raw.githubusercontent.com/louislam/dockge/master/.env.example -o /opt/dockge/.env

# Configure Dockge .env
cat > /opt/dockge/.env <<'EOF'
# Dockge Configuration
DOCKGE_STACKS_DIR=/opt/dockge/stacks
DOCKGE_PORT=5001
DOCKGE_HOST=0.0.0.0
EOF

# Start Dockge
cd /opt/dockge && docker compose up -d
success "Dockge running on port 5001"

{{- /* ===== 2. CADDY REVERSE PROXY ===== */}}
info "Setting up Caddy..."

# Install Caddy
apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | \
  gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/caddy-stable-archive-keyring.gpg] \
  https://dl.cloudsmith.io/public/caddy/stable/deb/debian any-version main" | \
  tee /etc/apt/sources.list.d/caddy-stable.list
apt update && apt install -y caddy

# Caddyfile template (managed by chezmoi)
# Actual config in home/.config/caddy/Caddyfile.tmpl
success "Caddy installed"

{{- /* ===== 3. TAILSCALE VPN ===== */}}
info "Setting up Tailscale..."

curl -fsSL https://tailscale.com/install.sh | sh

# Auth key from secrets (age-encrypted)
TAILSCALE_AUTH_KEY="{{ .vps_secrets.tailscale_auth_key }}"
if [[ -n "$TAILSCALE_AUTH_KEY" && "$TAILSCALE_AUTH_KEY" != "REPLACE_ME" ]]; then
  tailscale up --auth-key="$TAILSCALE_AUTH_KEY" --hostname="{{ .chezmoi.hostname }}" --advertise-routes=10.0.0.0/8
  success "Tailscale connected"
else
  warn "Tailscale auth key not configured - run manually: tailscale up"
fi

{{- /* ===== 4. DUCKDNS DYNAMIC DNS ===== */}}
info "Setting up DuckDNS..."

mkdir -p /opt/duckdns
cat > /opt/duckdns/update.sh <<'EOF'
#!/bin/bash
DOMAIN="{{ .vps_secrets.duckdns_domain }}"
TOKEN="{{ .vps_secrets.duckdns_token }}"
curl -s "https://www.duckdns.org/update?domains=${DOMAIN}&token=${TOKEN}&ip="
EOF
chmod +x /opt/duckdns/update.sh

# Systemd timer for periodic updates (every 5 min)
cat > /etc/systemd/system/duckdns.service <<'EOF'
[Unit]
Description=DuckDNS Update
After=network-online.target

[Service]
Type=oneshot
ExecStart=/opt/duckdns/update.sh
EOF

cat > /etc/systemd/system/duckdns.timer <<'EOF'
[Unit]
Description=Run DuckDNS update every 5 minutes

[Timer]
OnBootSec=5min
OnUnitActiveSec=5min

[Install]
WantedBy=timers.target
EOF

systemctl daemon-reload
systemctl enable --now duckdns.timer
success "DuckDNS timer active"

{{- /* ===== 5. SYSTEM HARDENING ===== */}}
info "Applying system hardening..."

# UFW Firewall
apt install -y ufw
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 5001/tcp  # Dockge
ufw allow 9119/tcp  # Hermes (if exposed)
ufw allow 20128/tcp # OmniRoute (if exposed)
ufw --force enable

# Fail2ban
apt install -y fail2ban
cat > /etc/fail2ban/jail.local <<'EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
EOF
systemctl enable --now fail2ban

# SSH Hardening
sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
systemctl reload sshd

success "System hardening applied"

{{- /* ===== 6. SWAP & PERFORMANCE ===== */}}
info "Configuring swap..."

# 4GB swap file (Oracle free tier has no swap by default)
if [[ ! -f /swapfile ]]; then
  fallocate -l 4G /swapfile
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  echo '/swapfile none swap sw 0 0' >> /etc/fstab
  success "4GB swap created"
fi

# sysctl tuning
cat > /etc/sysctl.d/99-vps-tuning.conf <<'EOF'
# Network
net.core.somaxconn = 65535
net.ipv4.tcp_max_syn_backlog = 65535

# Memory
vm.swappiness = 10
vm.vfs_cache_pressure = 50
EOF
sysctl --system

success ">>> 🖥️ VPS Infrastructure Ready 🖥️"
```

---

## 3. Caddy Configuration (Reverse Proxy)

### Template: `home/.config/caddy/Caddyfile.tmpl`

```go
{{- /* Caddyfile for VPS - auto TLS via Let's Encrypt */}}
{{- $domain := .vps_secrets.duckdns_domain | default "fabiosouzadev.duckdns.org" }}
{{- $email := .vps_secrets.letsencrypt_email | default "fabiovanderlei.developer@gmail.com" }}

{
  email {{ $email }}
  admin off
}

# Hermes Dashboard
hermes.{{ $domain }} {
  reverse_proxy localhost:9119
  header {
    Strict-Transport-Security "max-age=31536000"
    X-Content-Type-Options "nosniff"
    X-Frame-Options "DENY"
  }
}

# OmniRoute Dashboard
omniroute.{{ $domain }} {
  reverse_proxy localhost:20128
  header {
    Strict-Transport-Security "max-age=31536000"
  }
}

# Dockge (optional - restrict to Tailscale)
dockge.{{ $domain }} {
  @tailscale {
    remote_ip 100.64.0.0/10
  }
  @local {
    remote_ip 192.168.0.0/16 10.0.0.0/8 172.16.0.0/12
  }
  handle @tailscale {
    reverse_proxy localhost:5001
  }
  handle @local {
    reverse_proxy localhost:5001
  }
  respond "Access denied" 403
}

# Uptime Kuma (if enabled)
{{- if .features.vps.monitoring.uptime_kuma }}
uptime.{{ $domain }} {
  reverse_proxy localhost:3001
}
{{- end }}
```

---

## 4. Hermes & OmniRoute Systemd Services

### Hermes Service: `home/.config/systemd/user/hermes.service`

```ini
[Unit]
Description=Hermes Agent
After=network-online.target
Wants=network-online.target

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

[Install]
WantedBy=default.target
```

### OmniRoute Service: `home/.config/systemd/user/omniroute.service`

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
ExecStart=/home/ubuntu/.local/bin/omniroute serve --port 20128
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=default.target
```

### Coding Orchestrator Service: `home/.config/systemd/user/coding-orchestrator.service`

```ini
[Unit]
Description=Coding Orchestrator (Nightly AI Agent)
After=network-online.target

[Service]
Type=oneshot
User=ubuntu
WorkingDirectory=/home/ubuntu
Environment=HOME=/home/ubuntu
Environment=PATH=/home/ubuntu/.local/bin:/usr/local/bin:/usr/bin:/bin
Environment=ORCHESTRATOR_BUDGET_PER_NIGHT=5
Environment=ORCHESTRATOR_BUDGET_PER_TASK=2
ExecStart=/home/ubuntu/.local/bin/coding-orchestrator run --schedule
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=default.target
```

### Orchestrator Timer: `home/.config/systemd/user/coding-orchestrator.timer`

```ini
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

## 5. VPS Secrets (Age-Encrypted)

### Data File: `home/.chezmoidata/vps/secrets.toml.age`

```toml
# Decrypted at apply time via age
tailscale_auth_key = "tskey-auth-<your-key>"
duckdns_domain = "fabiosouzadev"
duckdns_token = "<your-token>"
letsencrypt_email = "fabiovanderlei.developer@gmail.com"

# Hermes/OmniRoute
hermes_admin_token = "<generated>"
omniroute_admin_token = "<generated>"

# Monitoring
uptime_kuma_password = "<generated>"
```

### In `.chezmoi.yaml.tmpl` (loads secrets)

```go
{{- if .settings.vps }}
{{- $vps_secrets := fromYaml (include ".chezmoidata/vps/secrets.toml.age") }}
data:
  vps_secrets: $vps_secrets
{{- end }}
```

---

## 6. Monitoring (Uptime Kuma)

### Dockge Stack: `/opt/dockge/stacks/uptime-kuma/compose.yaml`

```yaml
version: '3.8'
services:
  uptime-kuma:
    image: louislam/uptime-kuma:1
    container_name: uptime-kuma
    volumes:
      - ./data:/app/data
    ports:
      - "3001:3001"
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "-q", "--spider", "http://localhost:3001"]
      interval: 30s
      timeout: 10s
      retries: 3
```

---

## 7. Backup Strategy (VPS)

### Backup Script: `home/.chezmoiscripts/vps/run_once_after_630-backup-vps.sh.tmpl`

```bash
#!/usr/bin/env bash

{{ template "common/script_is_not_ephemeral" . }}
{{ template "common/script_requires_sudo" . }}
{{ template "common/script_helper" . }}

info ">>>>>> 💾 VPS Backup 💾 <<<<<<"

BACKUP_DIR="/opt/backups/$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"

# 1. Backup Caddy config
cp -r /etc/caddy "$BACKUP_DIR/"

# 2. Backup Dockge stacks
cp -r /opt/dockge "$BACKUP_DIR/"

# 3. Backup Tailscale state
cp /var/lib/tailscale/tailscaled.state "$BACKUP_DIR/" 2>/dev/null || true

# 4. Backup systemd services
systemctl list-unit-files --state=enabled > "$BACKUP_DIR/enabled-services.txt"

# 5. Backup chezmoi source
tar -czf "$BACKUP_DIR/chezmoi-source.tar.gz" -C /home/ubuntu .local/share/chezmoi

# 6. Encrypt and upload (optional: to S3, GCS, etc.)
# age -r age1... -o "$BACKUP_DIR.tar.gz.age" "$BACKUP_DIR.tar.gz"

# 7. Retention (keep 7 days)
find /opt/backups -type d -mtime +7 -exec rm -rf {} \;

success ">>> 💾 Backup Complete: $BACKUP_DIR 💾"
```

---

## 8. Testing VPS Bootstrap

### Dry Run

```bash
# Test script rendering
chezmoi execute-template --data='{"settings":{"vps":true},"vps_secrets":{"tailscale_auth_key":"test","duckdns_domain":"test","duckdns_token":"test"}}' \
  home/.chezmoiscripts/vps/run_once_after_500-setup-vps-infra.sh.tmpl | bash -n
```

### Verify Deployment

```bash
#!/usr/bin/env bash
# verify_vps.sh

checks=(
  "docker:command -v docker"
  "dockge:curl -sf http://localhost:5001"
  "caddy:systemctl is-active caddy"
  "tailscale:tailscale status --json | jq -r .Self.Online"
  "duckdns:systemctl is-active duckdns.timer"
  "ufw:ufw status | grep -q active"
  "fail2ban:systemctl is-active fail2ban"
  "swap:swapon --show | grep -q /swapfile"
  "hermes:systemctl --user is-active hermes"
  "omniroute:systemctl --user is-active omniroute"
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

---

## 9. Common Issues & Fixes

| Issue | Cause | Fix |
|-------|-------|-----|
| Docker permission denied | User not in docker group | `usermod -aG docker ubuntu && newgrp docker` |
| Caddy TLS fails | Port 80/443 blocked | Check Oracle Cloud security lists, UFW |
| Tailscale not connecting | Auth key expired | Generate new key in Tailscale admin console |
| DuckDNS not updating | Token wrong | Verify token in DuckDNS dashboard |
| Hermes/OmniRoute not starting | Binary not in PATH | Ensure `~/.local/bin` in service Environment |
| Dockge not accessible | Port 5001 blocked | `ufw allow 5001/tcp` |
| Arm64 binary not found | Release missing arm64 asset | Check release assets, use alternative tool |
| Swap not persisting | /etc/fstab not updated | Add `/swapfile none swap sw 0 0` to fstab |

---

## 10. Related Skills

| Skill | Relationship |
|-------|--------------|
| `chezmoi-architecture` | Prerequisite: data flow |
| `chezmoi-multi-profile` | VPS profile detection |
| `chezmoi-secret-management` | Age-encrypted VPS secrets |
| `chezmoi-script-lifecycle` | VPS scripts use guards |
| `chezmoi-ignore-patterns` | Exclude VPS scripts on desktop |
| `dotfiles-universal-binary-install` | Install tools on VPS |
| `dotfiles-ai-integration` | Hermes/OmniRoute/Orchestrator on VPS |
| `dotfiles-backup-strategy` | VPS backup procedures |

---

## 11. References

- **Oracle Cloud Free Tier**: https://www.oracle.com/cloud/free/
- **Dockge**: https://github.com/louislam/dockge
- **Caddy**: https://caddyserver.com/
- **Tailscale**: https://tailscale.com/
- **DuckDNS**: https://www.duckdns.org/
- **Repo VPS scripts**: `fabiosouzadev/dotfiles` → `.chezmoiscripts/vps/`, `.chezmoidata/vps/`

---

*Generated via Loop Engineering Mode — Phase 4: Skill Creation. Validated against live repo analysis.*