---
name: omniroute-docker-deployment
description: "OmniRoute Docker: profiles, volumes, reverse proxy."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [omniroute, docker, docker-compose, deployment, production]
    skill_type: procedural
    difficulty: intermediate
    trigger: "Deploying OmniRoute with Docker, choosing profiles, configuring volumes, networking, or production hardening"
---

# OmniRoute Docker Deployment Skill

## Overview

Production-ready Docker deployment patterns for OmniRoute covering profile selection, volume management, reverse proxy integration, and security hardening.

## Profile Selection Guide (FACT)

| Use Case | Profile(s) | Rationale |
|----------|------------|-----------|
| **Minimal headless** | `base` | No CLI tools, smallest image (~250MB) |
| **Agentic workflows** | `cli` | Bundled Codex, Claude Code, Droid, OpenClaw |
| **Host CLI access** | `host` | Mounts `~/.local/bin`, `~/.codex`, `~/.claude` read-only |
| **Web providers** | `web` | Chromium/Playwright for Gemini Web, Claude Web |
| **Semantic memory** | `base` + `memory` | Qdrant vector store for >1M embeddings |
| **Tier-1 routing** | `base` + `bifrost` | Go-based Bifrost sidecar for high-throughput |
| **CLI proxying** | `cli` + `cliproxyapi` | CLIProxyAPI sidecar on port 8317 |

**Multiple profiles can combine**: `docker compose --profile cli --profile cliproxyapi up -d`

## Volume Mounts (FACT)

```yaml
volumes:
  # OmniRoute data (SQLite, logs, backups)
  - ./data:/app/data
  
  # Stack-specific volumes
  - omniroute-data:/app/data              # Base/cli/host/web
  - omniroute-redis-data:/data            # Redis
  - omniroute-qdrant-data:/qdrant/storage # Qdrant (memory profile)
  - omniroute-bifrost-data:/data          # Bifrost (bifrost profile)
  - cliproxyapi-data:/root/.cli-proxy-api # CLIProxyAPI (cliproxyapi profile)

# Host CLI mounts (host profile only)
  - ~/.local/bin:/host-local/bin:ro
  - ~/.codex:/host-home/.codex:rw
  - ~/.claude:/host-home/.claude:rw
  - ~/.factory:/host-home/.factory:rw
  - ~/.openclaw:/host-home/.openclaw:rw
  - ~/.cursor:/host-home/.cursor:rw
```

**Critical**: Stack directory mount MUST match host:container path exactly:
```yaml
- /opt/stacks:/opt/stacks  # ✓ CORRECT
- /docker:/my-stacks       # ✗ WRONG - paths don't match
```

## Production Compose (FACT)

Use `docker-compose.prod.yml` for isolated production alongside dev:
```bash
# Build & start production stack
docker compose -f docker-compose.prod.yml up -d --build

# Stream logs
docker compose -f docker-compose.prod.yml logs -f

# Tear down (keep volumes)
docker compose -f docker-compose.prod.yml down
```

| Detail | Value |
|--------|-------|
| File | `docker-compose.prod.yml` |
| Dashboard Port | `PROD_DASHBOARD_PORT=20130` |
| API Port | `PROD_API_PORT=20131` |
| Image | `omniroute:prod` (built from `runner-cli`) |
| Redis | `omniroute-redis-prod` (redis:8.6.2, dedicated volume) |
| Data Volume | `omniroute-prod-data` (named, persists across rebuilds) |

## Reverse Proxy (FACT)

### Caddy (Auto-TLS)
```yaml
services:
  omniroute:
    image: diegosouzapw/omniroute:latest
    environment:
      - PORT=20128
      - NEXT_PUBLIC_BASE_URL=https://your-domain.com
      - BASE_URL=http://omniroute:20128
      - AUTH_COOKIE_SECURE=true

  caddy:
    image: caddy:latest
    ports: ["80:80", "443:443"]
    command: caddy reverse-proxy --from https://your-domain.com --to http://omniroute:20128
```

### Subpath Deployment (Traefik/nginx)
```bash
# .env
OMNIROUTE_BASE_PATH=/omniroute
NEXT_PUBLIC_BASE_URL=https://myhostname.example.com/omniroute

# Rebuild so image and runtime agree
docker compose --profile base up -d --build
```

**Traefik**: Route `PathPrefix(/omniroute)` to container **without** `StripPrefix` so Next.js receives `/omniroute/...` and serves assets from `/omniroute/_next/...`.

## Critical Production Variables (FACT)

```bash
# REQUIRED
JWT_SECRET=$(openssl rand -base64 48)
API_KEY_SECRET=$(openssl rand -hex 32)
OMNIROUTE_WS_BRIDGE_SECRET=$(openssl rand -base64 32)
INITIAL_PASSWORD=your-secure-password

# Security
AUTH_COOKIE_SECURE=true
REQUIRE_API_KEY=true
OMNIROUTE_ALLOW_PRIVATE_PROVIDER_URLS=true  # For local providers

# Memory
OMNIROUTE_MEMORY_MB=512  # Docker heap limit

# Redis
REDIS_URL=redis://redis:6379
```

## Healthchecks & Graceful Shutdown (FACT)

```yaml
# OmniRoute service
healthcheck:
  test: ["CMD", "node", "healthcheck.mjs"]
  interval: 30s
  timeout: 5s
  retries: 3
  start_period: 15s

# Redis healthcheck
healthcheck:
  test: ["CMD", "redis-cli", "ping"]
  interval: 10s
  timeout: 5s
  retries: 3

# Stop grace period for SQLite WAL checkpoint
stop_grace_period: 40s
```

**Always use `--stop-timeout 40`** when running container directly:
```bash
docker run -d --stop-timeout 40 ...
```

## Common Pitfalls (INFERENCE)

| Issue | Cause | Fix |
|-------|-------|-----|
| SQLite "database is locked" | Multiple containers same volume | Never mount one SQLite DB into multiple running instances |
| OAuth callback fails | `NEXT_PUBLIC_BASE_URL` mismatch | Set to exact public origin including subpath |
| Web providers fail | Missing Chromium | Use `web` profile or `runner-web` image |
| Rate limiter degrades | Redis not running | Ensure Redis container healthy, check `REDIS_URL` |
| Port conflicts | Multiple profiles same ports | Use different host ports or production compose |
| Subpath assets 404 | `OMNIROUTE_BASE_PATH` not rebuilt | Rebuild after changing `OMNIROUTE_BASE_PATH` |

## Validation Checklist

- [ ] Profile matches use case (CLI tools? → `cli` or `host`)
- [ ] `JWT_SECRET`, `API_KEY_SECRET`, `OMNIROUTE_WS_BRIDGE_SECRET` set
- [ ] `AUTH_COOKIE_SECURE=true` behind HTTPS
- [ ] `NEXT_PUBLIC_BASE_URL` matches public origin
- [ ] Volume mounts persist `/app/data`, Redis, Qdrant, Bifrost data
- [ ] `OMNIROUTE_ALLOW_PRIVATE_PROVIDER_URLS=true` for local providers
- [ ] `stop_grace_period: 40s` for SQLite WAL checkpoint
- [ ] Healthchecks configured and passing
- [ ] Production compose uses separate volumes/ports from dev

## Related Skills
- `omniroute-architecture` - Core architecture understanding
- `omniroute-provider-management` - Provider setup after deployment
- `omniroute-cli-integration` - CLI tool configuration

## When to Use This Skill
- Deploying OmniRoute to production VPS/server
- Choosing Docker Compose profiles
- Configuring reverse proxy with auto-TLS
- Debugging Docker deployment issues
- Setting up production alongside development

## When NOT to Use
- Quick local dev → `docker compose --profile base up -d` is sufficient
- Provider configuration → use `omniroute-provider-management`
- CLI tool setup → use `omniroute-cli-integration`