---
name: omniroute-architecture
description: "OmniRoute: Next.js LLM gateway, SQLite+Redis, Docker."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos]
metadata:
  hermes:
    tags: [omniroute, architecture, llm-gateway, docker]
    skill_type: knowledge
    difficulty: intermediate
    trigger: "Need to understand OmniRoute internal architecture, component interactions, or data flow for debugging, extending, or deploying"
---

# OmniRoute Architecture Skill

## Overview

OmniRoute is a **universal LLM gateway** built as a Next.js (v16) + TypeScript monorepo that routes requests across 40+ LLM providers with intelligent fallback, cost optimization, and unified API compatibility.

## Core Architecture (FACT)

### Technology Stack
- **Frontend**: Next.js 16 (App Router), React 19, TypeScript, Turbopack (dev), Webpack (prod)
- **Runtime**: Node.js 24 (Docker: `node:24.15.0-trixie-slim`)
- **Database**: SQLite (better-sqlite3) with WAL mode, FTS5 for search
- **Cache/Rate Limit**: Redis (ioredis) - optional but recommended
- **Vector Memory**: Qdrant (optional sidecar via `memory` profile)
- **Tier-1 Router**: Bifrost (Go sidecar, optional via `bifrost` profile)
- **CLI Proxy**: CLIProxyAPI sidecar (optional via `cliproxyapi` profile)

### Multi-Stage Dockerfile
| Stage | Base Image | Purpose |
|-------|------------|---------|
| `builder` | `node:24.15.0-trixie-slim` | `npm ci --legacy-peer-deps` + `npm run build -- --webpack` |
| `runner-base` | `node:24.15.0-trixie-slim` | Production runtime, Next.js standalone output, **no CLI tools** |
| `runner-cli` | `runner-base` | Adds git, docker, docker-compose, global CLIs: `@openai/codex`, `@anthropic-ai/claude-code`, `droid`, `openclaw` |
| `runner-web` | `runner-base` | Adds Chromium/Playwright for web-cookie providers (Gemini Web, Claude Web) |

**Key**: `runner-cli` is recommended for agentic workflows; `runner-base` for minimal headless.

### Docker Compose Profiles (7)
```yaml
# Base - minimal, no CLIs
docker compose --profile base up -d

# CLI - bundled CLIs for agentic workflows
docker compose --profile cli up -d

# Host - mounts host CLI binaries read-only (Linux-first)
docker compose --profile host up -d

# Web - Chromium for web-cookie providers
docker compose --profile web up -d

# Memory - Qdrant vector store sidecar
docker compose --profile base --profile memory up -d

# Bifrost - Go Tier-1 router sidecar
docker compose --profile base --profile bifrost up -d

# CLIProxyAPI - sidecar for upstream CLI proxying
docker compose --profile cli --profile cliproxyapi up -d
```

### Port Allocation
| Service | Internal | Default Host | Env Var |
|---------|----------|--------------|---------|
| Dashboard | 20128 | 20128 | `DASHBOARD_PORT` |
| API | 20129 | 20129 | `API_PORT` |
| Live WS | 20132 | 20132 | `LIVE_WS_PORT` |
| Redis | 6379 | 6379 | `REDIS_PORT` |
| Qdrant HTTP | 6333 | 6333 | `QDRANT_PORT` |
| Qdrant gRPC | 6334 | 6334 | `QDRANT_GRPC_PORT` |
| Bifrost | 8080 | 8080 | `BIFROST_PORT` |
| CLIProxyAPI | 8317 | 8317 | `CLIPROXYAPI_PORT` |

### Data Persistence
- **SQLite**: `/app/data/storage.sqlite` (mounted volume `omniroute-data`)
- **Redis**: `/data` (volume `omniroute-redis-data`)
- **Qdrant**: `/qdrant/storage` (volume `omniroute-qdrant-data`)
- **Bifrost**: `/data` (volume `omniroute-bifrost-data`)
- **CLIProxyAPI**: `/root/.cli-proxy-api` (volume `cliproxyapi-data`)

### Critical Environment Variables
```bash
# REQUIRED in production
JWT_SECRET=                          # openssl rand -base64 48
API_KEY_SECRET=                      # openssl rand -hex 32
INITIAL_PASSWORD=CHANGEME            # Change on first login!
OMNIROUTE_WS_BRIDGE_SECRET=          # openssl rand -base64 32 (WS bridge auth)
REDIS_URL=redis://redis:6379         # Rate limiter backend

# Port overrides
PORT=20128
DASHBOARD_PORT=20128
API_PORT=20129
API_HOST=0.0.0.0

# Subpath deployment (behind reverse proxy)
OMNIROUTE_BASE_PATH=/omniroute
NEXT_PUBLIC_BASE_URL=https://host/omniroute

# Security
AUTH_COOKIE_SECURE=true              # Required for HTTPS
REQUIRE_API_KEY=true                 # Enforce Bearer on /v1/*
OMNIROUTE_ALLOW_PRIVATE_PROVIDER_URLS=true  # For local providers (Ollama, LM Studio)
```

## Data Flow (FACT)

```
Request → Next.js API Routes → open-sse/executors/* → Provider APIs
                ↓
         Rate Limiter (Redis) → Circuit Breaker → Response Cache
                ↓
         SQLite (providers, combos, keys, sessions, logs)
                ↓
         Optional: Qdrant (semantic memory), Bifrost (Tier-1 routing)
```

### Routing Pipeline
1. **Auth Middleware** - API key validation, scope checking
2. **Rate Limiter** - Per-token, per-IP, per-provider (Redis-backed)
3. **Combo Resolution** - `auto/*` → virtual combo, explicit combo → defined models
4. **Provider Selection** - Strategy: priority, round-robin, weighted, p2c, least-used, cost-optimized
5. **Executor Dispatch** - Provider-specific executor (open-sse/executors/*.ts)
6. **Response Processing** - Streaming, compression, cost telemetry headers
7. **Logging** - Call logs, proxy logs, cost tracking

## Provider System (FACT)

### Provider Types
| Type | Auth | Examples |
|------|------|----------|
| **Subscription (OAuth)** | Browser OAuth, auto-refresh | Claude Code (`cc/`), Codex (`cx/`), GitHub Copilot (`gh/`) |
| **API Key** | Static key in dashboard | OpenAI, Anthropic, GLM, Kimi, Qwen, DeepSeek, etc. |
| **Free (No-Auth)** | Toggle in dashboard | Qoder (`if/`), Kiro (`kr/`), Qwen Free |
| **Local** | None (requires `OMNIROUTE_ALLOW_PRIVATE_PROVIDER_URLS=true`) | Ollama, LM Studio, vLLM, llama.cpp |

### Model ID Format
```
<provider>/<model>           # e.g., openai/gpt-4o, anthropic/claude-3-opus
<prefix>/<provider>/<model>  # e.g., cc/claude-opus-4-7, cx/gpt-5.5, gh/gpt-5.5
auto/<category>              # e.g., auto/coding, auto/cheap, auto/fast
<combo-name>                 # User-defined combo
```

## Advanced Subsystems (FACT)

### MCP Server (Model Context Protocol)
- **SSE**: `http://host:20128/api/mcp/sse`
- **Streamable HTTP**: `http://host:20128/api/mcp/stream`
- **stdio**: `omniroute --mcp` (for IDE plugins)
- **Scopes**: analytics, auth, billing, combos, health, keys, memory, models, providers, system

### A2A Server (Agent-to-Agent)
- JSON-RPC 2.0 over HTTP
- Endpoint: `http://host:20128/api/a2a`
- Skills invocable via A2A

### Skills Framework
- Extensible TypeScript skills in `src/lib/skills/`
- Marketplace UI in Dashboard → Skills
- Per-API-key scope restriction
- Custom skills: drop `.ts` in `src/lib/a2a/skills/`, register

### Memory System
- **Primary**: SQLite FTS5 (keyword search)
- **Optional**: Qdrant vector store (semantic recall, >1M embeddings)
- **Auto-extraction**: Facts, preferences, decisions after each session
- **Scoped**: Per API key, per session

### Webhooks
- Events: `request.completed`, `request.failed`, `provider.unavailable`, `budget.exceeded`, `combo.switched`, `circuit_breaker.opened/closed`
- HMAC-SHA256 signature verification
- 3 retries with exponential backoff

### Cloud Agents
- OpenAI Codex Cloud, Devin, Jules, Antigravity
- Dashboard → Cloud Agents or `POST /api/v1/agents/tasks`
- BYO API keys, credentials never leave instance

## Anti-Hallucination Checks (VALIDATION)

Before making architectural assumptions, verify:
- [ ] Docker profile matches use case (CLI tools needed? → `cli` or `host`)
- [ ] Redis is running (rate limiter degrades to in-memory without it)
- [ ] `OMNIROUTE_WS_BRIDGE_SECRET` set in production
- [ ] `AUTH_COOKIE_SECURE=true` behind HTTPS
- [ ] `OMNIROUTE_ALLOW_PRIVATE_PROVIDER_URLS=true` for local providers
- [ ] Volume mounts persist `/app/data`, `/data` (Redis), etc.
- [ ] `NEXT_PUBLIC_BASE_URL` matches public origin for OAuth callbacks

## Related Skills
- `omniroute-docker-deployment` - Docker Compose patterns, production setup
- `omniroute-provider-management` - Provider setup, OAuth, API keys, model management
- `omniroute-cli-integration` - Cursor, Claude Code, Codex, Cline, OpenClaw config
- `omniroute-auto-routing` - Combos, auto-router, fallback chains
- `omniroute-advanced-features` - MCP, A2A, Skills, Memory, Webhooks, Cloud Agents

## When to Use This Skill
- Designing or debugging OmniRoute deployment
- Understanding component interactions for troubleshooting
- Planning capacity (Redis, Qdrant, Bifrost sidecars)
- Configuring reverse proxy / subpath deployment
- Security hardening (secrets, cookies, API keys)

## When NOT to Use
- Quick provider setup → use `omniroute-provider-management`
- CLI tool config → use `omniroute-cli-integration`
- Combo/auto-routing config → use `omniroute-auto-routing`