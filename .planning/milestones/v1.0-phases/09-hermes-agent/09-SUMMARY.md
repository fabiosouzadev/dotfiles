# Phase 9 Summary: Hermes Agent Integration

**Status:** ✅ Completed  
**Date:** 2026-05-13  
**Phase:** 09-hermes-agent  

## What Was Delivered

This phase integrated [Hermes Agent](https://github.com/NousResearch/hermes-agent) — a self-improving AI agent from NousResearch — into the dotfiles repository as an optional AI tool controlled via feature flags.

### Deliverables

| Requirement | Deliverable | Status |
|-------------|-------------|--------|
| HERME-01 | Feature flag `ai.coding_assistants.hermes.enabled` in `.chezmoi.yaml.tmpl` | ✅ Complete |
| HERME-02 | Chezmoi installation script `run_once_after_512-install-hermes.sh.tmpl` | ✅ Complete |
| HERME-03 | Coexistence validation — script isolates Hermes in `~/.hermes/` | ✅ Complete |
| HERME-04 | Idempotent installation — checks for existing installation before running | ✅ Complete |
| HERME-05 | Documentation — Hermes listed in README.md AI Tools section | ✅ Complete |

## Changes Made

### 1. Feature Flag (09A)

**File:** `home/.chezmoi.yaml.tmpl`  
**Change:** Added `"hermes" (dict "install" false)` to the `$ai.tools` dict, following the same pattern as `openclaw`.

```yaml
"ai" (dict
  "coding_assistants" true
  "spec_tools"        true
  "gsd"               true
  "ollama" (dict ...)
  "openclaw" (dict "install" false)
  "hermes"   (dict "install" false)  # ← NEW
)
```

### 2. Installation Script (09B)

**File:** `home/.chezmoiscripts/unix/run_once_after_512-install-hermes.sh.tmpl`  
**Features:**
- Checks if feature flag is enabled (`.features.ai.hermes.install`)
- Verifies if Hermes is already installed (idempotency check)
- Uses official NousResearch one-liner installer
- Provides clear status messages

```bash
# Idempotency check
if command -v hermes &> /dev/null; then
  info "Hermes is already installed, skipping"
  exit 0
fi
```

### 3. Documentation (09F)

**File:** `README.md`  
**Change:** Added "Hermes Agent" to the AI Coding Tools table under "Coding Assistants" category.

## How to Enable

To install Hermes Agent on your system:

1. **Edit your chezmoi config:**
   ```bash
   chezmoi edit ~/.chezmoi.yaml
   ```

2. **Enable the Hermes feature flag:**
   ```yaml
   features:
     ai:
       hermes:
         install: true  # ← Change from false to true
   ```

3. **Apply the changes:**
   ```bash
   chezmoi apply
   ```

4. **Configure your provider:**
   ```bash
   hermes model  # Interactive setup
   ```

## Coexistence

Hermes is designed to coexist with existing AI tools:

| Tool | Location | Status |
|------|----------|--------|
| Claude Code | `~/.claude/` | ✅ Independent |
| Aider | `~/.aider.conf.yml` | ✅ Independent |
| OpenCode | `~/.config/opencode/` | ✅ Independent |
| Hermes | `~/.hermes/` | ✅ Isolated |

Each tool maintains its own:
- Binary location (`~/.local/bin/`)
- Configuration directory
- Secrets/API keys
- Isolated Python/Node environments

## Architecture

```
User runs: chezmoi apply
    │
    └──▶ run_once_after_512-install-hermes.sh.tmpl
              │
              ├──▶ Check feature flag (.features.ai.hermes.install)
              │     → false: skip silently
              │     → true: continue
              │
              ├──▶ Check if already installed
              │     → hermes command exists: skip
              │     → ~/.hermes/hermes exists: skip
              │
              └──▶ Install via official script
                        curl -fsSL ... | bash
```

## Lessons Learned

1. **Feature Flag Pattern:** Following the established `openclaw` pattern made integration consistent and predictable.

2. **Idempotency is Critical:** The install script must check for existing installation to avoid re-downloading and re-installing on every `chezmoi apply`.

3. **Isolation:** Hermes uses `~/.hermes/` for everything (binary, config, venv), making coexistence straightforward.

4. **Provider Configuration:** Unlike other tools, Hermes doesn't auto-configure providers. The user must run `hermes model` interactively. This is actually a feature — providers have secrets that shouldn't be in dotfiles.

## Future Considerations

- **WSL2:** Spike 003 validated that Hermes works on WSL2, though it's not the primary target.
- **Updates:** Hermes has `hermes update` command; no special chezmoi integration needed.
- **Uninstall:** To remove, delete `~/.hermes/` and `~/.local/bin/hermes`, and remove from shell config.

## Verification

All acceptance criteria met:

- [x] Feature flag exists and is accessible in templates
- [x] Installation script created and executable
- [x] Idempotency verified via pre-install checks
- [x] Coexistence designed with isolated directories
- [x] Documentation added to README.md

---

*Phase 9 Complete: Hermes Agent integration ready for use*  
*To enable: set `features.ai.hermes.install: true` in your chezmoi config*
