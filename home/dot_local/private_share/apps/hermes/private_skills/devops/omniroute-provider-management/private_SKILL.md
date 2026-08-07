---
name: omniroute-provider-management
description: "OmniRoute providers: OAuth, API keys, free, local."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos]
metadata:
  hermes:
    tags: [omniroute, providers, oauth, api-keys, llm]
    skill_type: procedural
    difficulty: intermediate
    trigger: "Setting up or managing LLM providers in OmniRoute (OAuth subscriptions, API keys, free providers, local models)"
---

# OmniRoute Provider Management Skill

## Overview

Complete guide to configuring 40+ LLM providers in OmniRoute across four authentication types.

## Provider Types (FACT)

### 1. Subscription/OAuth Providers (Auto-refresh)
| Provider | Models | Setup |
|----------|--------|-------|
| **Claude Code** (`cc/`) | `cc/claude-opus-4-7`, `cc/claude-sonnet-4-6`, `cc/claude-haiku-4-5` | Dashboard → Providers → Connect Claude Code → OAuth |
| **Codex** (`cx/`) | `cx/gpt-5.5`, `cx/gpt-5.4`, `cx/gpt-5.3-codex` | Dashboard → Providers → Connect Codex → OAuth (port 1455) |
| **GitHub Copilot** (`gh/`) | `gh/gpt-5.5`, `gh/claude-opus-4.7`, `gh/gemini-3.1-pro` | Dashboard → Providers → Connect GitHub → OAuth |

**Key**: Quota tracked per model (5h + weekly for CC/Codex, monthly for Copilot).

### 2. API Key Providers (Static keys)
```bash
# Dashboard → Add API Key
Provider: openai/anthropic/glm/kimi/qwen/deepseek/mistral/xai/perplexity/together/fireworks/cerebras/cohere/nvidia/baidu
API Key: sk-... / your-key
Name: main  # optional identifier
```

**Cheap Tier** (daily/5h reset):
- **GLM-4.7**: $0.6/1M, daily 10AM reset → Coding Plan 3× quota at 1/7 cost
- **MiniMax M2.1**: $0.2/1M, 5h rolling reset → Cheapest for 1M context
- **Kimi K2**: $9/mo flat, 10M tokens/mo → Predictable $0.90/1M effective

### 3. Free/No-Auth Providers (Toggle in dashboard)
| Provider | Prefix | Models | Cost |
|----------|--------|--------|------|
| **Qoder** | `if/` | `if/qwen3.8-max-preview`, `if/kimi-k2.7-code`, `if/deepseek-v4-flash`, `if/glm-5.2`, `if/minimax-m3` | $0 unlimited |
| **Kiro** | `kr/` | `kr/claude-sonnet-4.5`, `kr/claude-haiku-4.5` | ~50 credits/mo free |
| **Qwen Free** | `if/` | `if/qwen3-coder-next`, `if/qwen3-plus` | $0 unlimited |

**Toggle**: Provider page → "No authentication required" switch.

### 4. Local Providers (Requires env var)
```bash
OMNIROUTE_ALLOW_PRIVATE_PROVIDER_URLS=true
```
| Provider | Setup |
|----------|-------|
| **Ollama** | `http://localhost:11434` |
| **LM Studio** | `http://localhost:1234` |
| **vLLM** | `http://localhost:8000` |
| **llama.cpp** | `http://localhost:8080` |

## Model ID Patterns (FACT)

```
<provider>/<model>           # openai/gpt-4o, anthropic/claude-3-opus
<prefix>/<provider>/<model>  # cc/claude-opus-4-7, cx/gpt-5.5, gh/gpt-5.5
auto/<category>              # auto/coding, auto/cheap, auto/fast, auto/smart, auto/lkgp, auto/offline
<combo-name>                 # User-defined combo
```

## Custom Models (FACT)

Add any model without app update:
```bash
# Via API
curl -X POST http://localhost:20128/api/provider-models \
  -H "Content-Type: application/json" \
  -d '{"provider": "openai", "modelId": "gpt-5.2", "modelName": "GPT-5.2"}'

# List: curl http://localhost:20128/api/provider-models?provider=openai
# Remove: curl -X DELETE "http://localhost:20128/api/provider-models?provider=openai&model=gpt-5.2"
```

Or Dashboard: **Providers → [Provider] → Custom Models**.

## Provider Validation (FACT)

```bash
# CLI test
omniroute providers test <provider-id>

# API test
curl -X POST http://localhost:20128/api/providers/test \
  -H "Authorization: Bearer $KEY" \
  -d '{"provider": "openai", "apiKey": "sk-..."}'
```

## Chaining OmniRoute Peers (FACT)

Add another OmniRoute as Custom OpenAI-compatible provider:
- Base URL: peer's `/v1` endpoint
- API Key: dedicated least-privilege key from peer

Loop guard:
```bash
# gateway-a
OMNIROUTE_INSTANCE_ID=gateway-a
OMNIROUTE_PEER_URLS=http://gateway-b:20128/v1
OMNIROUTE_PEER_MAX_HOPS=4
```

## Validation Checklist

- [ ] OAuth providers connected (CC, Codex, Copilot)
- [ ] API keys added for paid providers
- [ ] Free providers toggled on if needed
- [ ] `OMNIROUTE_ALLOW_PRIVATE_PROVIDER_URLS=true` for local
- [ ] Model IDs verified via `/v1/models` or `omniroute models list`
- [ ] Quota tracking working (Health page)

## Related Skills
- `omniroute-architecture` - Provider system context
- `omniroute-auto-routing` - Combos and auto-router using providers
- `omniroute-cli-integration` - CLI tools using providers

## When to Use This Skill
- Initial provider setup
- Adding new providers
- Troubleshooting provider connectivity
- Managing API key rotation

## When NOT to Use
- Docker deployment → use `omniroute-docker-deployment`
- Combo/auto-router config → use `omniroute-auto-routing`
- CLI tool config → use `omniroute-cli-integration`