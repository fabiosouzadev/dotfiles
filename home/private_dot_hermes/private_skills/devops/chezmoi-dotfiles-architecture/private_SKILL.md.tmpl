---
name: chezmoi-dotfiles-architecture
description: "Use when auditing chezmoi dotfiles with Loop Engineering."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [chezmoi, dotfiles, architecture, bootstrap, devops, loop-engineering]
    related_skills: [hermes-agent-skill-authoring, systematic-debugging, plan]
---

# ChezMoi Dotfiles Architecture Analysis

## Overview

This skill provides a structured methodology for **deeply understanding** a chezmoi-managed dotfiles repository — not just reading it, but building permanent, reusable knowledge about its architecture, patterns, conventions, and operational philosophy. It implements **Loop Engineering**: iterative cycles of observation → validation → consolidation → persist → review.

Use this when:
- Onboarding to a new chezmoi dotfiles repo (yours or someone else's)
- Conducting an architecture review / audit of an existing repo
- Building a mentor agent for a dotfiles repository
- Designing a new chezmoi repo from scratch with best practices
- Troubleshooting bootstrap failures across multiple environments

## When to Use

- **Trigger**: "Analyze this chezmoi dotfiles repo" / "Audit my dotfiles" / "Become a mentor for this repo"
- **Don't use for**: One-off chezmoi commands, simple template edits, or learning chezmoi basics (see official docs)

## Loop Engineering Methodology

### Phase 1 — Documentation Ingestion (FACT Collection)
Load and comprehend ALL official chezmoi documentation:
- User Guide: daily operations, templating, machine differences, scripts, encryption, password managers
- Reference: concepts, source state attributes, target types, application order
- Follow internal links; don't stop at the first page

**Completion criterion**: Can explain every chezmoi concept in the repo's README without guessing.

### Phase 2 — Repository Mapping (Structural FACTS)
Systematically map the repository structure:

```bash
# Core structure
chezmoi source dir (from .chezmoiroot)
├── .chezmoi.yaml.tmpl          # Detection, feature flags, data consolidation
├── .chezmoiignore.tmpl         # Conditional ignore patterns
├── .chezmoiroot                # Source directory pointer
├── .chezmoidata/               # Data layer (per-OS, per-profile, global)
│   ├── darwin/ linux/ windows/ termux/ vps/
│   ├── ai_tools.yaml, omniroute.yaml, repos.json
├── .chezmoiscripts/            # Execution layer (lifecycle scripts)
│   ├── darwin/ linux/ unix/ windows/ termux/ vps/
│   │   ├── run_once_before_XXX, run_once_after_XXX, run_onchange_after_XXX
├── .chezmoitemplates/          # Template layer (reusable guards, snippets)
│   ├── common/ (script_is_not_ephemeral, script_is_not_headless, etc.)
│   ├── darwin/ linux/ windows/ workplace/
├── dot_zshrc.d/                # Modular shell config (numbered)
├── private_dot_*/              # Encrypted configs (age/GPG)
├── encrypted_*.asc             # Encrypted secrets sourced in shell
└── README.md + docs/           # Living documentation
```

**Completion criterion**: Can draw the data flow diagram from memory: `.chezmoi.yaml.tmpl` → `.chezmoidata/` → `.chezmoiscripts/` → templates → `$HOME`.

### Phase 3 — Pattern Extraction (FACT vs INFERENCE)
Identify and label every pattern:

| Pattern Type | Examples | Label |
|--------------|----------|-------|
| **Naming conventions** | `run_once_before_XXX`, `private_*`, `encrypted_*.asc`, `dot_*` | FACT |
| **Template guards** | `script_is_not_ephemeral`, `script_is_not_headless` | FACT |
| **Feature flag hierarchy** | `features.ai.hermes.dashboard.enabled` | FACT |
| **Profile detection** | VPS: hostname `instance-*`, user `ubuntu`, SSH; Work: hostname contains `zwpe0f96cn` | FACT |
| **Script ordering** | 100s=pre, 200s=config, 500s=post-install, 600s=onchange/cron | FACT |
| **Zsh module numbering** | 099=env, 100s=plugins, 200s=aliases, 300s=tools, 600s=AI, 999=compinit | FACT |
| **Philosophy** | "Reproducibility > convenience", "IA as first-class citizen" | INFERENCE |
| **Trade-offs** | Universal binary install vs package manager | INFERENCE |

**Completion criterion**: Every pattern marked ✅ FACT (evidence in repo) or ⚠️ INFERENCE (reasoned, not directly observed).

### Phase 4 — Knowledge Persistence (Skill Creation)
Transform findings into **reusable, class-level skills** — one per distinct responsibility:

| Skill | Responsibility |
|-------|----------------|
| `chezmoi-architecture` | Core concepts, data flow, application order |
| `chezmoi-template-patterns` | Guards, composition, functions, conditionals |
| `chezmoi-environment-detection` | OS, headless, ephemeral, CI, VPS, WSL, container |
| `chezmoi-secret-management` | age + GPG, recipient, identity, encrypt/decrypt, rotate |
| `chezmoi-script-lifecycle` | run_once_before/after, run_onchange, guards, ordering |
| `chezmoi-multi-profile` | personal/work/vps, feature flags per profile |
| `chezmoi-ignore-patterns` | Conditional .chezmoiignore.tmpl by OS/profile/VPS |
| `dotfiles-zsh-modular` | dot_zshrc.d numbering, sourcing, encrypted secrets loading |
| `dotfiles-universal-binary-install` | GitHub Releases → ~/.local/bin, no-sudo, cross-platform |
| `dotfiles-ai-integration` | Hermes, OmniRoute, Coding Orchestrator install/config/sync |
| `dotfiles-vps-bootstrap` | Oracle Cloud ARM64: Dockge, Caddy, Tailscale, DuckDNS, systemd |
| `dotfiles-workplace-*` | Workplace-specific configs (Zup, etc.) |
| `dotfiles-backup-strategy` | Selective SQL, manifest, encrypted (hermes-sync, omniroute-sync) |
| `dotfiles-fork-guide` | Re-encrypt secrets, rotate age key, review before apply |
| `dotfiles-architecture-review` | Detect regressions, inconsistencies, duplications, improvements |

**Completion criterion**: Each skill has single responsibility, clear trigger, and verification checklist.

### Phase 5 — Mentorship Mode (Continuous)
After initial analysis, operate as permanent mentor:
- Compare future changes against acquired knowledge
- Detect regressions, inconsistencies, duplications, code smells
- Propose improvements with: benefit, risk, impact, difficulty, priority (LOW/MEDIUM/HIGH)
- Never propose changes without architectural justification

## Anti-Hallucination Protocol

**Always differentiate**:
- ✅ **FACT** — directly observed in repo (file content, commit history, docs)
- ⚠️ **INFERENCE** — reasoned from evidence, not directly stated
- ❓ **UNKNOWN** — not yet investigated

**Never** present inferences as facts. Mark every claim in analysis outputs.

## Verification Checklist

- [ ] All chezmoi docs ingested (Phase 1)
- [ ] Complete repo structure mapped with data flow diagram (Phase 2)
- [ ] All patterns extracted and labeled FACT/INFERENCE (Phase 3)
- [ ] Class-level skills proposed with single responsibilities (Phase 4)
- [ ] Mentorship protocol defined for ongoing reviews (Phase 5)
- [ ] Zero unlabeled claims in final deliverable
- [ ] Dependencies between proposed skills mapped
- [ ] Prioritized roadmap with effort/risk/benefit estimates
- [ ] Reference files created for session-specific detail (evidence, transcripts)

## Common Pitfalls

1. **Skipping Phase 1** — Analyzing repo before understanding chezmoi leads to misinterpreting template logic, application order, or feature flag semantics.
2. **Conflating FACT and INFERENCE** — "This repo uses Zinit" (FACT) vs "This repo prefers Zinit over Oh My Zsh" (INFERENCE — could be historical accident).
3. **Creating narrow, session-specific skills** — "fix-vps-dockge-install" is not a class-level skill. Create `chezmoi-script-lifecycle` instead.
4. **Ignoring conditional ignore patterns** — `.chezmoiignore.tmpl` with `{{ if .settings.vps }}` is a critical architecture piece, not a detail.
5. **Missing the feature flag hierarchy** — `features.ai.hermes.dashboard.enabled` controls install, config, systemd, Caddy — it's the single source of truth.
6. **Not verifying script idempotency** — Every `run_once` script must check existence before install; `run_onchange` must be safely re-runnable.
7. **Overlooking secret management duality** — `age` for chezmoi-native, `GPG` for legacy `.asc` files — both must be documented.
8. **Assuming single-profile** — Most mature repos have personal/work/vps; detection logic is often the most complex part.

## One-Shot Recipes

### Recipe: Full Architecture Audit (New Repo)
```bash
# 1. Get chezmoi docs
browser_navigate https://www.chezmoi.io/user-guide/
browser_navigate https://www.chezmoi.io/reference/

# 2. Clone and map repo
git clone <repo-url>
find . -type f -name "*.tmpl" -o -name "*.yaml" -o -name "*.sh" | head -50

# 3. Read core files
cat .chezmoiroot
cat home/.chezmoi.yaml.tmpl
cat home/.chezmoiignore.tmpl
ls home/.chezmoidata/
ls home/.chezmoiscripts/
ls home/.chezmoitemplates/

# 4. Run Loop Engineering phases
# ... follow phases 1-5 above
```

### Recipe: Verify Bootstrap on Clean Machine
```bash
# In clean VM/container:
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin" init --apply <github-user>
# Verify: shell loads, tools present, AI services running, no errors
```

## References

- `references/chezmoi-official-docs-summary.md` — Condensed chezmoi concepts from official docs
- `references/fabiosouzadev-dotfiles-analysis.md` — Complete Loop Engineering analysis of this user's repo (this session's deliverable)
- `references/pattern-catalog.md` — Extracted patterns with FACT/INFERENCE labels
- `references/skill-proposals.md` — 15 proposed skills with dependencies and roadmap
- Official chezmoi docs: https://www.chezmoi.io/
- User's repo: https://github.com/fabiosouzadev/dotfiles