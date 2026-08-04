---
name: vps-ai-stack
description: "VPS AI stack: OmniRoute, Dockge, Caddy, Tailscale, Hermes."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [vps, omniroute, dockge, caddy, tailscale, hermes, chezmoi]
    skill_type: procedural
    difficulty: advanced
    trigger: "Deploying the complete AI stack on Oracle ARM64 VPS: OmniRoute gateway, Dockge stack manager, Caddy reverse proxy, Tailscale VPN, Hermes agent"
---

# VPS AI Stack Skill

## Overview

Complete production deployment of the AI development stack on Oracle Cloud ARM64 VPS, managed via chezmoi dotfiles. Includes OmniRoute (LLM gateway), Dockge (stack manager), Caddy (auto-TLS reverse proxy), Tailscale (VPN), and Hermes (AI agent).

## Architecture (FACT)

```
Internet → Caddy (443/80, auto-TLS)
    ↓
OmniRoute (20128/20129) ←→ Dockge (5001) ←→ Docker stacks
    ↓
Tailscale (mesh VPN) ←→ Local machine (omniroute connect)
    ↓
Hermes Agent (local) → OmniRoute API → 40+ LLM providers
```

## Component Stack (FACT)

| Component | Port | Purpose | Managed By |
|-----------|------|---------|------------|
| **Caddy** | 80, 443 | Auto-TLS reverse proxy | `run_once_after_530-install-caddy.sh.tmpl` |
| **OmniRoute** | 20128/20129 | LLM gateway, provider routing | `docker compose --profile cli up -d` |
| **Dockge** | 5001 | Docker Compose stack UI | `run_once_after_505-install-dockge.sh.tmpl` |
| **Tailscale** | Mesh | Secure VPN access | `run_once_after_556-configure-tailscale.sh.tmpl` |
| **Hermes** | Local | AI agent, uses OmniRoute | `private_dot_hermes/config.yaml.tmpl` |

## Chezmoii Configuration (FACT)

### Feature Flags (`home/.chezmoidata/vps/features.yaml`)
```yaml
features:
  dockge:
    install: true
  tailscale:
    enabled: true
  hermes:
    enabled: true
    dashboard:
      enabled: true
    agentmemory:
      enabled: true
    camofox:
      enabled: true
    composio:
      enabled: true
```

### VPS Detection (`.chezmoi.yaml.tmpl`)
```bash
# Auto-detects Oracle VPS via:
# - CHEZMOI_VPS env var
# - Hostname contains "vps" or "vnic"
# - Hostname starts with "instance-"
# - Ubuntu + ubuntu user + SSH + no GUI
$isVps = or (env "CHEZMOI_VPS") ($hostLower contains "vps") ...
if $isVps; $profile = "vps"; end
```

### Scripts Execution Order (FACT)
| Number | Script | Purpose |
|--------|--------|---------|
| 505 | `install-dockge.sh.tmpl` | Dockge stack manager |
| 530 | `install-caddy.sh.tmpl` | Caddy reverse proxy + UFW |
| 531 | `install-agentmemory.sh.tmpl` | Agent memory (Qdrant?) |
| 532 | `install-camofox.sh.tmpl` | Camofox browser automation |
| 556 | `configure-tailscale.sh.tmpl` | Tailscale VPN setup |
| 590 | `install-ai-tools.sh.tmpl` | 20+ AI CLI tools |

## OmniRoute Configuration (FACT)

### Docker Compose (via Dockge)
Stack: `~/.local/opt/stacks/omniroute/compose.yaml`
```yaml
services:
  omniroute:
    image: diegosouzapw/omniroute:latest
    container_name: omniroute
    restart: unless-stopped
    ports: ["20128:20128", "20129:20129", "20132:20132"]
    volumes:
      - ./data:/app/data
      - /var/run/docker.sock:/var/run/docker.sock  # For CLI tools
    environment:
      - PORT=20128
      - DASHBOARD_PORT=20128
      - API_PORT=20129
      - REDIS_URL=redis://redis:6379
      - OMNIROUTE_ALLOW_PRIVATE_PROVIDER_URLS=true
    profiles: ["cli"]  # Bundled Codex, Claude Code, etc.

  redis:
    image: redis:7-alpine
    volumes: [redis-data:/data]
```

### Hermes Config (`private_dot_hermes/config.yaml.tmpl`)
```yaml
model:
  default: omniroute/work
  provider: custom
  base_url: ${OMNIROUTE_BASE_URL}      # http://vps-ip:20128
  api_key: ${OMNIROUTE_API_KEY}
custom_providers:
  - name: Omniroute
    base_url: ${OMNIROUTE_BASE_URL}
    key_env: ${OMNIROUTE_API_KEY}
    model: omniroute/work
```

### Environment Variables Required
```bash
# Set on VPS or via Tailscale SSH
OMNIROUTE_BASE_URL=http://your-vps-ip:20128
OMNIROUTE_API_KEY=sk-your-api-key-from-dashboard
```

## Caddy Configuration (FACT)

### Auto-TLS for OmniRoute + Dockge
```caddy
# Caddyfile
your-domain.com {
    reverse_proxy omniroute:20128
}

dockge.your-domain.com {
    reverse_proxy dockge:5001
}
```

### Oracle Cloud Warning (from script)
> ⚠️ **ORACLE CLOUD USERS**: Add Ingress Rules for ports 80 and 443 in Oracle Web Console (VCN → Security Lists)!

## Tailscale Setup (FACT)

### Script: `run_once_after_556-configure-tailscale.sh.tmpl`
```bash
# Installs Tailscale
# Authenticates via TAILSCALE_AUTHKEY or interactive
# Enables subnet routes if needed
```

### Remote Access
```bash
# On local machine
omniroute connect your-vps-tailscale-ip
omniroute models list  # Lists REMOTE VPS models
```

## Deployment Procedure (PROCEDURAL)

### 1. Bootstrap VPS
```bash
# On fresh Oracle ARM64 VPS
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin init --apply fabiosouzadev
```

### 2. Configure Secrets
```bash
# Age key for encrypted files
mkdir -p ~/.config/chezmoi
age-keygen -o ~/.config/chezmoi/key.txt

# Caddy: Ensure DNS A record points to VPS IP
# Tailscale: Set TAILSCALE_AUTHKEY or run `tailscale up` interactively
```

### 3. Apply Dotfiles
```bash
chezmoi apply
# Runs all run_once_after_* scripts in order
```

### 4. Verify Services
```bash
# OmniRoute
curl http://localhost:20128/api/monitoring/health
curl http://localhost:20128/v1/models

# Dockge
curl http://localhost:5001

# Caddy (via domain)
curl https://your-domain.com/api/monitoring/health

# Tailscale
tailscale status
```

### 5. Configure OmniRoute Providers
```bash
# Via Dashboard (https://your-domain.com)
# Or CLI
omniroute connect your-vps-tailscale-ip
omniroute providers available
omniroute setup  # Interactive wizard
```

### 6. Configure Hermes Locally
```bash
# On local machine
export OMNIROUTE_BASE_URL=https://your-domain.com
export OMNIROUTE_API_KEY=your-key
hermes
```

## Critical Validation Checklist

- [ ] Oracle Cloud ingress rules: 80, 443, 20128, 20129, 5001, Tailscale
- [ ] DNS A record → VPS IP for Caddy auto-TLS
- [ ] `OMNIROUTE_ALLOW_PRIVATE_PROVIDER_URLS=true` for local providers
- [ ] `AUTH_COOKIE_SECURE=true` behind Caddy HTTPS
- [ ] `NEXT_PUBLIC_BASE_URL=https://your-domain.com` matches public origin
- [ ] Age key at `~/.config/chezmoi/key.txt` for secret decryption
- [ ] Docker socket mounted for Dockge + OmniRoute CLI tools
- [ ] Tailscale authenticated and mesh established
- [ ] Volume paths persist: `/app/data`, Redis, Dockge stacks
- [ ] `stop_grace_period: 40s` for SQLite WAL checkpoint

## Troubleshooting (INFERENCE)

| Issue | Likely Cause | Fix |
|-------|--------------|-----|
| OmniRoute dashboard not accessible | Caddy config / DNS / Oracle ingress | Check Caddyfile, DNS propagation, Oracle security lists |
| `docker compose up` fails in Dockge | Docker socket permissions | Ensure `docker` group membership, socket mounted |
| Hermes can't connect to OmniRoute | Wrong base URL / API key | Verify `OMNIROUTE_BASE_URL` (no trailing slash), API key valid |
| Tailscale not connecting | Auth key expired / firewall | Re-run `tailscale up`, check UDP 41641 allowed |
| Caddy cert not issuing | DNS not propagated / rate limit | Wait for DNS, check Caddy logs `journalctl -u caddy` |
| Scripts not running | Chezmoii profile not "vps" | Check `chezmoi data` output for `settings.vps=true` |

## Related Skills
- `omniroute-docker-deployment` - OmniRoute Docker patterns
- `omniroute-provider-management` - Provider setup on VPS
- `dockge-stack-manager` - Managing stacks via Dockge UI
- `chezmoi-script-lifecycle` - Script execution patterns
- `chezmoi-multi-profile` - VPS profile detection

## When to Use This Skill
- Deploying complete AI stack to new Oracle ARM64 VPS
- Rebuilding VPS from scratch (disaster recovery)
- Adding new components to existing VPS stack
- Debugging VPS stack integration issues

## When NOT to Use
- Local development (use Docker Compose directly)
- Kubernetes deployment (different architecture)
- Single-component deployment (use component-specific skills)