---
name: dockge-stack-manager
description: "Dockge: Docker Compose stack manager, UI, multi-agent."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [dockge, docker, compose, stack-manager, ui]
    skill_type: procedural
    difficulty: beginner
    trigger: "Managing Docker Compose stacks with Dockge UI, deploying stacks, converting docker run to compose, multi-host management"
---

# Dockge Stack Manager Skill

## Overview

Dockge is a **self-hosted Docker Compose stack manager** with a fancy, reactive UI. It manages `compose.yaml` files directly on disk - no vendor lock-in, works with standard `docker compose` CLI.

## Core Concepts (FACT)

### Philosophy
- **File-based**: Stacks stored as `compose.yaml` on host filesystem
- **No lock-in**: Use `docker compose` CLI anytime
- **Stack-oriented**: Each stack = directory with `compose.yaml`
- **Reactive UI**: Real-time progress (pull/up/down), web terminal

### Architecture
- **Frontend**: Vue 3 + TypeScript, Vite, reactive WebSocket updates
- **Backend**: Node.js, Express, Docker SDK
- **Port**: 5001 (default)
- **Stacks Dir**: `/opt/stacks` (default, configurable)

## Installation (FACT)

### Basic
```bash
mkdir -p /opt/stacks /opt/dockge
cd /opt/dockge
curl https://raw.githubusercontent.com/louislam/dockge/master/compose.yaml --output compose.yaml
docker compose up -d
```

### Custom Stacks Directory
```bash
# Generator: https://dockge.kuma.pet/compose.yaml?port=5001&stacksPath=/opt/stacks
# Or manual compose.yaml:
services:
  dockge:
    image: louislam/dockge:1
    restart: unless-stopped
    ports: ["5001:5001"]
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./data:/app/data
      - /opt/stacks:/opt/stacks  # MUST match host:container path exactly
    environment:
      - DOCKGE_STACKS_DIR=/opt/stacks
      - PUID=1000
      - PGID=1000
```

**Critical**: Stack directory mount MUST match exactly:
```yaml
- /opt/stacks:/opt/stacks  # ✓ CORRECT
- /docker:/my-stacks       # ✗ WRONG
```

### Update
```bash
cd /opt/dockge
docker compose pull && docker compose up -d
```

## Features (FACT)

| Feature | Description |
|---------|-------------|
| **Compose Editor** | Interactive YAML editor with validation |
| **Stack Operations** | Create/Edit/Start/Stop/Restart/Delete |
| **Image Updates** | Pull latest images, recreate containers |
| **Web Terminal** | Interactive container terminal in browser |
| **Multi-Agent** | Manage stacks on multiple Docker hosts |
| **Run → Compose** | Convert `docker run` commands to `compose.yaml` |
| **Scan Stacks** | Auto-discover existing compose files in stacks dir |

## Stack Structure (FACT)

```
/opt/stacks/
  my-stack/
    compose.yaml
    .env (optional)
    data/ (optional, persistent data)
  another-stack/
    compose.yaml
```

## Multi-Host Management (FACT)

**Agents** = additional Docker hosts managed from single Dockge UI:
1. Install Dockge on each host (or run agent)
2. Dashboard → Agents → Add Agent
3. Enter host URL, verify connection
4. Switch between agents in UI dropdown

## Converting docker run → compose (FACT)

Dashboard → "Convert" button → paste `docker run` command → generates `compose.yaml` with proper service config.

## User's VPS Integration (FACT from dotfiles)

### Script: `run_once_after_505-install-dockge.sh.tmpl`
```bash
{{ template "common/script_helper" }}
{{ template "common/script_is_not_ephemeral" }}
{{ template "workplace/script_is_vps" }}

{{ if not .features.dockge.install }}
info ">> Dockge: feature flag disabled, skipping <<"
exit 0
{{ end }}

mkdir -p {{ .chezmoi.homeDir }}/.local/opt/dockge
cd {{ .chezmoi.homeDir }}/.local/opt/dockge

# Download compose.yaml (commented in template)
# curl "https://dockge.kuma.pet/compose.yaml?port=5001&stacksPath=%7E%2F.local%2Fopt%2Fstacks" --output compose.yaml

docker compose up -d
```

### Feature Flag
```yaml
# home/.chezmoidata/vps/features.yaml
features:
  dockge:
    install: true
```

### Stacks Directory
User's config uses `~/.local/opt/stacks` (not default `/opt/stacks`)

## Caddy Reverse Proxy (FACT from dotfiles)

User deploys Caddy alongside Dockge for HTTPS:
```bash
# run_once_after_530-install-caddy.sh.tmpl
# Installs Caddy, configures UFW, warns about Oracle Cloud ingress rules
```

Caddy config would proxy `https://domain.com` → `http://dockge:5001`

## Common Pitfalls (INFERENCE)

| Issue | Cause | Fix |
|-------|-------|-----|
| Stacks not appearing | Wrong stacks dir path | Ensure `DOCKGE_STACKS_DIR` matches volume mount exactly |
| Permission denied | PUID/PGID mismatch | Set `PUID=1000`, `PGID=1000` (or your user) |
| Web terminal fails | Docker socket not mounted | Mount `/var/run/docker.sock:/var/run/docker.sock` |
| Multi-agent connection fails | Network/firewall | Ensure agent host reachable, Docker API exposed |
| Compose changes not reflected | Editor vs disk sync | Dockge writes directly to disk - use `docker compose` CLI to verify |

## Validation Checklist

- [ ] `DOCKGE_STACKS_DIR` matches volume mount host:container path exactly
- [ ] `PUID`/`PGID` set for correct file ownership
- [ ] Docker socket mounted
- [ ] Stacks directory exists and writable
- [ ] Caddy/reverse proxy configured for HTTPS
- [ ] Oracle Cloud ingress rules for ports 80/443 (if applicable)

## Related Skills
- `omniroute-docker-deployment` - OmniRoute stacks managed by Dockge
- `dotfiles-vps-bootstrap` - VPS setup including Dockge
- `chezmoi-script-lifecycle` - Script execution patterns

## When to Use This Skill
- Deploying/managing Docker Compose stacks via UI
- Converting `docker run` to maintainable compose files
- Multi-host Docker management
- Visual stack monitoring and terminal access

## When NOT to Use
- Kubernetes/Helm deployments
- Single-container management (use Portainer or CLI)
- CI/CD pipeline deployment (use native Docker/Compose)