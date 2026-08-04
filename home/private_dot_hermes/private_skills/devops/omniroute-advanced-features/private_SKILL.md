---
name: omniroute-advanced-features
description: "OmniRoute advanced: MCP, A2A, Skills, Memory, Webhooks."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos]
metadata:
  hermes:
    tags: [omniroute, mcp, a2a, skills, memory, webhooks]
    skill_type: knowledge
    difficulty: advanced
    trigger: "Using OmniRoute advanced features: MCP server, A2A protocol, Skills framework, Memory system, Webhooks, Cloud Agents"
---

# OmniRoute Advanced Features Skill

## Overview

OmniRoute exposes enterprise-grade integration capabilities beyond basic LLM routing: MCP server, A2A protocol, extensible Skills framework, long-term Memory, Webhooks, and Cloud Agent orchestration.

## MCP Server (Model Context Protocol) (FACT)

### Transports
| Transport | Endpoint | Use Case |
|-----------|----------|----------|
| **SSE** | `http://host:20128/api/mcp/sse` | Web clients, Cursor, Continue |
| **Streamable HTTP** | `http://host:20128/api/mcp/stream` | Modern MCP clients |
| **stdio** | `omniroute --mcp` | IDE plugins (Claude Desktop, VS Code) |

### Connect Claude Desktop
```json
// ~/Library/Application Support/Claude/claude_desktop_config.json (macOS)
{
  "mcpServers": {
    "omniroute": {
      "command": "omniroute",
      "args": ["--mcp"]
    }
  }
}
```

### Scopes (FACT)
Each Bearer key can be limited to specific scopes:
- `analytics` - Usage, cost, latency metrics
- `auth` - Session, login management
- `billing` - Budget, quotas, invoices
- `combos` - Combo CRUD
- `health` - System, provider, circuit breaker health
- `keys` - API key management
- `memory` - Fact storage, retrieval
- `models` - Model catalog, search
- `providers` - Provider connections, testing
- `system` - Settings, backups, maintenance

### Tool Catalog
See `docs/frameworks/MCP-SERVER.md` for complete tool list per scope.

## A2A Server (Agent-to-Agent) (FACT)

### Protocol
- JSON-RPC 2.0 over HTTP
- Endpoint: `http://host:20128/api/a2a`
- Skills invocable as A2A methods

### Schema Reference
See `docs/frameworks/A2A-SERVER.md` for complete JSON-RPC schema.

## Skills Framework (FACT)

### Marketplace
- Browse/install: Dashboard → Skills
- Per-API-key scope restriction

### Custom Skills
1. Create TypeScript file in `src/lib/a2a/skills/`
2. Export skill class implementing `Skill` interface
3. Register in skill registry
4. Immediately invocable via A2A and MCP

### Built-in Skills (INFERENCE)
- `code-review` - Automated PR review
- `summarize` - Long content summarization
- `extract-facts` - Structured fact extraction
- `web-research` - Multi-source research

## Memory System (FACT)

### Storage Layers
| Layer | Technology | Capacity | Use Case |
|-------|------------|----------|----------|
| **Primary** | SQLite FTS5 | Unlimited | Keyword search, exact match |
| **Optional** | Qdrant (vector) | >1M embeddings | Semantic recall, similarity |

### Auto-Extraction
After each session, OmniRoute extracts:
- **Entities** - People, projects, tools, concepts
- **Preferences** - User preferences, style choices
- **Decisions** - Architectural choices, trade-offs

Stored in `memory_facts` table, scoped per API key and session.

### Management
- Dashboard → Memory (search, edit, export, purge)
- HTTP API: `/api/memory/*` for programmatic access
- See `docs/frameworks/MEMORY.md`

## Webhooks (FACT)

### Events
| Event | Trigger |
|-------|---------|
| `request.completed` | Successful proxy request |
| `request.failed` | Failed proxy request |
| `provider.unavailable` | Provider circuit breaker OPEN |
| `budget.exceeded` | API key budget limit reached |
| `combo.switched` | Auto-router/combo fallback |
| `circuit_breaker.opened` | Provider degraded |
| `circuit_breaker.closed` | Provider recovered |

### Configuration
```bash
# Dashboard → Webhooks → Create
Target URL: https://your-webhook-endpoint
HMAC Secret: your-signing-secret
Events: [request.completed, budget.exceeded, ...]
```

### Payload Security
- Every payload includes `X-OmniRoute-Signature` (HMAC-SHA256)
- Verify: `HMAC_SHA256(secret, payload) == signature`
- Retries: 3 attempts with exponential backoff
- Dead-letter queue after failures

See `docs/frameworks/WEBHOOKS.md` for full schema.

## Cloud Agents (FACT)

### Supported Agents
- **OpenAI Codex Cloud** - Long-running coding tasks
- **Devin** - Autonomous software engineer
- **Jules** - Google's coding agent
- **Antigravity** - Custom cloud agent

### Usage
```bash
# Dashboard → Cloud Agents → Create Task
# Or API
curl -X POST http://localhost:20128/api/v1/agents/tasks \
  -H "Authorization: Bearer $KEY" \
  -d '{"agent": "codex", "prompt": "Refactor auth module", "repo": "github.com/user/repo"}'
```

### Features
- Task status, logs, artifacts tracking
- BYO API keys per provider (credentials never leave instance)
- Dashboard → Cloud Agents for monitoring

See `docs/frameworks/CLOUD_AGENT.md` for complete reference.

## Programmatic Management (FACT)

Bearer key with `manage` scope enables full resource control:

```bash
# List providers
curl http://localhost:20128/api/providers -H "Authorization: Bearer $KEY"

# Add provider
curl -X POST http://localhost:20128/api/providers \
  -H "Authorization: Bearer $KEY" \
  -d '{"provider": "openai", "apiKey": "sk-...", "name": "main"}'

# Create combo
curl -X POST http://localhost:20128/api/combos \
  -H "Authorization: Bearer $KEY" \
  -d '{"name": "premium", "strategy": "priority", "models": [{"model": "cc/claude-opus-4-7"}]}'

# Manage API keys
curl http://localhost:20128/api/keys -H "Authorization: Bearer $KEY"
curl -X POST http://localhost:20128/api/keys -d '{"name": "ci-bot", "scopes": ["chat"]}'
```

## Internal CLI (FACT)

```bash
omniroute setup                    # Interactive wizard
omniroute doctor                   # Health diagnostics
omniroute providers available      # Supported providers
omniroute providers list           # Configured connections
omniroute providers test <id>      # Live test
omniroute combos list              # List combos
omniroute combos switch <name>     # Set default
omniroute models                   # Available models
omniroute keys add | list | remove # API key management
omniroute backup                   # Snapshot config + DB
omniroute restore [<timestamp>]    # Restore from snapshot
omniroute health                   # Detailed health
omniroute quota                    # Provider quota usage
omniroute mcp status               # MCP server status
omniroute a2a status               # A2A server status
omniroute tunnel list|create|stop  # Cloudflare/Tailscale/ngrok
omniroute reset-password           # Reset admin password
omniroute --mcp                    # Start MCP stdio
omniroute --port 3000              # Custom port
```

## Validation Checklist

- [ ] MCP transport matches client (SSE for web, stdio for IDE)
- [ ] API key scopes minimal for MCP/A2A access
- [ ] Memory layer chosen (SQLite FTS5 default, Qdrant for >1M)
- [ ] Webhook HMAC verification implemented
- [ ] Cloud agent credentials configured per provider
- [ ] Programmatic management key has `manage` scope only

## Related Skills
- `omniroute-architecture` - Core architecture context
- `omniroute-provider-management` - Providers for cloud agents
- `omniroute-cli-integration` - CLI tools using advanced features

## When to Use This Skill
- Integrating OmniRoute with IDEs via MCP
- Building A2A-compatible agent workflows
- Implementing long-term memory for agents
- Setting up webhook monitoring/alerting
- Orchestrating cloud coding agents

## When NOT to Use
- Basic LLM routing → use `omniroute-auto-routing`
- Provider setup → use `omniroute-provider-management`
- Docker deployment → use `omniroute-docker-deployment`