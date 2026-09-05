---
name: omniroute-cli-integration
description: "OmniRoute CLI: Cursor, Claude Code, Codex, Cline, OpenClaw."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos]
metadata:
  hermes:
    tags: [omniroute, cli, cursor, claude-code, codex, cline]
    skill_type: procedural
    difficulty: intermediate
    trigger: "Configuring Cursor, Claude Code, Codex, Cline, Continue, or OpenClaw to use OmniRoute as LLM gateway"
---

# OmniRoute CLI Integration Skill

## Overview

Configure popular AI coding tools to route requests through OmniRoute for unified provider access, fallbacks, and cost optimization.

## Cursor IDE (FACT)

```json
// Settings → Models → Advanced
{
  "openaiApiBaseUrl": "http://localhost:20128/v1",
  "openaiApiKey": "your-omniroute-api-key",
  "model": "cc/claude-opus-4-7"
}
```

**Note**: Use `/v1` suffix for OpenAI-compatible endpoint.

## Claude Code (FACT)

Edit `~/.claude/settings.json`:
```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "http://localhost:20128",
    "ANTHROPIC_AUTH_TOKEN": "your-omniroute-api-key",
    "CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY": "1",
    "CLAUDE_CODE_AUTO_COMPACT_WINDOW": "190000"
  }
}
```

**Critical**: `ANTHROPIC_BASE_URL` has **NO `/v1` suffix** - Claude Code appends `/v1/messages` automatically.

### Profiles (FACT)

```bash
# Generate per-model profiles (reuses Codex profile names)
omniroute setup-claude

# Remote VPS
omniroute setup-claude --remote http://192.168.0.15:20128 --api-key oma_live_xxx

# Preview only
omniroute setup-claude --dry-run

# Launch with profile
omniroute launch --profile glm52
```

Profiles written to `~/.claude/profiles/<name>/settings.json` with model-specific `CLAUDE_CODE_AUTO_COMPACT_WINDOW`.

### Discovery Aliases (FACT)

Non-Claude models hidden from `/model` picker by default. Enable:
```bash
# Global (env var forces on)
EXPOSE_CC_DISCOVERY_ALIASES=true

# Per-provider: Provider page → "Expose in Claude Code"
# Per-model: Provider detail page → per-model toggle
```

Maps: `kimi/kimi-k2.6` → `claude/kimi/kimi-k2.6` (shown in picker, stripped at runtime).

## Codex CLI (FACT)

```bash
export OPENAI_BASE_URL="http://localhost:20128"
export OPENAI_API_KEY="your-omniroute-api-key"
codex "your prompt"
```

Or `~/.codex/config.toml`:
```toml
model = "cc/claude-opus-4-7"
model_provider = "omniroute"

[model_providers.omniroute]
name = "OmniRoute"
base_url = "http://localhost:20128/v1"
wire_api = "chat-completions"
env_key = "OMNIROUTE_API_KEY"
```

## OpenClaw (FACT)

Edit `~/.openclaw/openclaw.json`:
```json
{
  "agents": {
    "defaults": {
      "model": { "primary": "omniroute/if/kimi-k2.7-code" }
    }
  },
  "models": {
    "providers": {
      "omniroute": {
        "baseUrl": "http://localhost:20128/v1",
        "apiKey": "your-omniroute-api-key",
        "api": "openai-completions",
        "models": [{ "id": "if/kimi-k2.7-code", "name": "Kimi K2.7 Code" }]
      }
    }
  }
}
```

**Dashboard auto-config**: CLI Tools → OpenClaw → Auto-config

## Cline / Continue / RooCode (FACT)

```json
// All use OpenAI-compatible format
{
  "provider": "OpenAI Compatible",
  "baseUrl": "http://localhost:20128/v1",
  "apiKey": "your-omniroute-api-key",
  "model": "cc/claude-opus-4-7"
}
```

## Kiro IDE (FACT)

Same as Cursor - OpenAI-compatible endpoint with `/v1`.

## Remote Mode (FACT)

```bash
# One-time setup on laptop
npm install -g omniroute
omniroute connect 192.168.0.15    # password → scoped token
omniroute models list             # lists REMOTE models
omniroute configure codex         # writes local Codex profile from remote catalog

# Then use tools normally - they target remote automatically
omniroute launch --remote http://192.168.0.15:20128 --api-key oma_live_xxx
```

Contexts stored in `~/.omniroute/config.json` (chmod 600).

## Model Selection Strategy (INFERENCE)

| Task | Recommended Model/Combo |
|------|-------------------------|
| Complex coding | `auto/coding` or `cc/claude-opus-4-7` |
| Cost-sensitive | `auto/cheap` or `glm/glm-4.7` |
| Speed priority | `auto/fast` or `cx/gpt-5.5` |
| Reasoning quality | `auto/smart` or `cc/claude-opus-4-7` |
| Free only | `auto/free` or `if/kimi-k2.7-code` |
| Local only | `auto/offline` (Ollama, vLLM) |

## Troubleshooting (FACT)

| Issue | Fix |
|-------|-----|
| Claude Code ignores gateway | `ANTHROPIC_BASE_URL` has no `/v1`, restart Claude Code |
| `/model` picker empty | Needs Claude Code v2.1.219+, `CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1` |
| `400 Ambiguous model` | Both `cc/` and `claude/` providers connected → pin `ANTHROPIC_MODEL=cc/claude-opus-4-8` or enable "Prefer Claude Code" |
| Auth errors | Profile holds no token → use `omniroute launch --profile` or export `ANTHROPIC_AUTH_TOKEN` |
| Codex rejects `codex/gpt-5.5` | Use bare ID `gpt-5.5` (Codex CLI validates client-side) |

## Validation Checklist

- [ ] Correct base URL format per tool (`/v1` for OpenAI-compatible, no `/v1` for Anthropic)
- [ ] API key has `chat` scope minimum
- [ ] Model ID exists in `/v1/models` or `omniroute models list`
- [ ] Remote mode: `omniroute connect` completed, contexts configured

## Related Skills
- `omniroute-provider-management` - Providers that CLI tools will use
- `omniroute-auto-routing` - Combos/auto-router for model selection
- `omniroute-remote-mode` - Remote VPS management

## When to Use This Skill
- Setting up AI coding assistants
- Switching tools to use OmniRoute
- Debugging CLI integration issues
- Configuring per-model profiles

## When NOT to Use
- Provider setup → use `omniroute-provider-management`
- Docker deployment → use `omniroute-docker-deployment`
- Combo configuration → use `omniroute-auto-routing`