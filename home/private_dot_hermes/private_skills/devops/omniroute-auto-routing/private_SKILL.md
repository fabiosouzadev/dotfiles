---
name: omniroute-auto-routing
description: "OmniRoute auto-routing: combos, auto-router, fallback."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos]
metadata:
  hermes:
    tags: [omniroute, routing, combos, auto-router, fallback]
    skill_type: procedural
    difficulty: intermediate
    trigger: "Configuring OmniRoute combos, auto-router prefixes, fallback chains, or routing strategies"
---

# OmniRoute Auto-Routing Skill

## Overview

OmniRoute provides two routing paradigms: explicit **combos** (user-defined model lists with strategies) and **auto-router** (score-driven virtual combos with `auto/*` prefixes).

## Combos (FACT)

### Creation
```bash
# Dashboard → Combos → Create New
# Or API
curl -X POST http://localhost:20128/api/combos \
  -H "Authorization: Bearer $KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "premium-coding",
    "strategy": "priority",
    "models": [
      {"model": "cc/claude-opus-4-7"},
      {"model": "glm/glm-4.7"},
      {"model": "minimax/MiniMax-M2.1"}
    ]
  }'
```

### Strategies (FACT)
| Strategy | Behavior |
|----------|----------|
| **priority** | Always tries first model; falls back only on error |
| **round-robin** | Rotates through models sequentially |
| **random** | Picks random model per request |
| **weighted** | Routes proportionally by assigned weights |
| **least-used** | Routes to model with fewest recent requests |
| **cost-optimized** | Routes to cheapest available (uses pricing table) |
| **fill-first** | Drains first model until limits hit |
| **p2c** | Power of Two Choices - picks 2 random, routes to healthier |

### Combo Defaults (FACT)
Set in Dashboard → Settings → Routing → Combo Defaults:
- Default strategy
- Target timeout (seconds) - per-model timeout for faster fallback
- Zero-latency optimizations (hedging, predictive TTFT skips, proactive fallback compression) - **opt-in**

## Auto-Router (FACT)

Zero-config score-driven routing. Send request with `auto/*` prefix:

| Prefix | Optimizes For |
|--------|---------------|
| `auto` | Balanced (latency × cost × success rate) |
| `auto/coding` | Coding tasks: Claude, GPT-5, GLM, Kimi, Qwen Coder, DeepSeek |
| `auto/cheap` | Lowest $/token, accepts higher latency |
| `auto/fast` | Lowest latency, ignores cost |
| `auto/smart` | Reasoning quality: Opus, GPT-5 xhigh, R1, GLM 5.1 |
| `auto/lkgp` | Last Known Good Provider - sticky to recent success |
| `auto/offline` | Local-only: Ollama, vLLM, llama.cpp |

```bash
curl -X POST http://localhost:20128/v1/chat/completions \
  -H "Authorization: Bearer $KEY" \
  -H "Content-Type: application/json" \
  -d '{"model": "auto/coding", "messages": [...], "stream": true}'
```

### Auto-Router Scoring (INFERENCE)
Scores candidates on:
- Latency (p50/p95)
- Cost per token (pricing table)
- Success rate (recent failures)
- Context fit (request tokens vs model window)
- Model fitness for task category
- Recent failures (circuit breaker state)
- Quota remaining
- Circuit breaker status

## Fallback Chains (FACT)

Global fallbacks applying across all requests:
```bash
# Dashboard → Settings → Routing → Fallback Chains
# Or API
curl -X POST http://localhost:20128/api/fallback-chains \
  -H "Authorization: Bearer $KEY" \
  -d '{"name": "production-fallback", "models": ["cc/claude-opus-4-7", "gh/gpt-5.3-codex", "glm/glm-4.7"]}'
```

## Wildcard Model Aliases (FACT)

Remap model names via patterns:
```
Pattern: claude-sonnet-*     →  Target: cc/claude-sonnet-4-6
Pattern: gpt-*               →  Target: gh/gpt-5.3-codex
```
Supports `*` (any chars) and `?` (single char).

## External Sticky Session (FACT)

For reverse proxy session affinity:
```http
X-Session-Id: your-session-key
```
Also accepts `x_session_id`. Returns effective session in `X-OmniRoute-Session-Id`.

## Resilience Integration (FACT)

Routing respects:
- **Connection Cooldown** - per-account backoff after retryable failures
- **Provider Circuit Breaker** - DEGRADED/OPEN/HALF_OPEN states block routing
- **Rate Limit Auto-Detection** - honors upstream `Retry-After` headers

Configure in Dashboard → Settings → Resilience.

## Validation Checklist

- [ ] Combo strategy matches use case (priority for quality, cost-optimized for budget)
- [ ] Auto-router prefix selected per task type
- [ ] Fallback chains cover critical paths
- [ ] Pricing table populated for cost-optimized routing
- [ ] Circuit breakers not blocking needed providers (Health page)
- [ ] Target timeouts set appropriately for fallback speed

## Related Skills
- `omniroute-provider-management` - Providers that combos/auto-router use
- `omniroute-cli-integration` - CLI tools using combos/auto-router
- `omniroute-architecture` - Routing pipeline context

## When to Use This Skill
- Creating combos for specific workloads
- Configuring auto-router for zero-config routing
- Setting up fallback chains for reliability
- Tuning routing strategies

## When NOT to Use
- Provider setup → use `omniroute-provider-management`
- CLI tool config → use `omniroute-cli-integration`
- Docker deployment → use `omniroute-docker-deployment`