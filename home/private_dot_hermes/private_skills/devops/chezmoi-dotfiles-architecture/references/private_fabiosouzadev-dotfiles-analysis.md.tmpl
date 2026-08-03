# Loop Engineering Analysis: fabiosouzadev/dotfiles

**Session**: 2026-08-03 | **Repo**: https://github.com/fabiosouzadev/dotfiles | **Commits**: 893 on main

---

## Executive Summary

This repository is a **production-grade chezmoi dotfiles platform** — not just configuration files, but a complete bootstrap system for multi-environment development (laptop, work, VPS, WSL, Termux, macOS) with first-class AI integration (Hermes, OmniRoute, Coding Orchestrator). It implements feature-flag architecture, conditional deployment, encrypted secrets, and living documentation.

**Maturity**: High — 5 months active evolution, 893 commits, synchronized docs, idempotent scripts.

---

## Architecture Overview

### Data Flow
```
.chezmoi.yaml.tmpl (detection + feature flags)
       │
       ├──► .chezmoidata/ (per-OS/profile data: packages, features, repos)
       │
       ├──► .chezmoiscripts/ (lifecycle: run_once_before/after, run_onchange)
       │
       ├──► .chezmoitemplates/ (reusable guards: script_is_not_ephemeral, etc.)
       │
       └──► home/**/*.tmpl (templates for $HOME: .zshrc, .config/*, systemd, etc.)
                     │
                     ▼
              $HOME (destination)
```

### Key Files
| File | Purpose |
|------|---------|
| `.chezmoiroot` | Points to `home/` as source dir |
| `home/.chezmoi.yaml.tmpl` | Environment detection, profile logic, feature flags, data consolidation |
| `home/.chezmoiignore.tmpl` | Conditional ignore by OS/profile/VPS |
| `home/.chezmoidata/**/*.yaml` | Package lists, feature toggles, repo lists |
| `home/.chezmoiscripts/**/*.sh.tmpl` | Bootstrap scripts with guards and ordering |
| `home/.chezmoitemplates/common/` | Reusable template guards and helpers |
| `home/dot_zshrc.d/*.zsh.tmpl` | Modular Zsh config (numbered 099-999) |
| `home/private_dot_*/` | Encrypted app configs (age/GPG) |
| `home/encrypted_*.asc` | GPG-encrypted shell secrets |

---

## Profile Detection Logic (FACT)

From `home/.chezmoi.yaml.tmpl`:

```go
// CI / Ephemeral detection
$ci := or (env "CI" "true") (env "GITHUB_ACTIONS") (env "GITLAB_CI") ...
$codespaces := env "CODESPACES"
$devContainer := or (env "REMOTE_CONTAINERS") (env "DEVCONTAINER") ...
$ephemeral := or $ci $codespaces $devContainer $gitpod $replit

// Container heuristics (Linux only)
$inContainer := or $devContainer $codespaces $gitpod $replit $distrobox $limavm
               (hasDockerenv) (cgroupContains docker|podman|lxc) (likelyContainerUser)
               (env "KUBERNETES_SERVICE_HOST")

// WSL detection
$wsl := and (eq .chezmoi.os "linux") (contains .chezmoi.kernel.osrelease "microsoft")

// GUI availability (complex ternary logic)
$guiAvailable := ternary true (forceGUI) (ternary false (forceHeadless) ...)

// Headless = no TTY OR no GUI OR WSL OR container OR SSH OR Termux
$headless := or (not $interactiveTTY) (not $guiAvailable) $wsl $inContainer $sshSession $termux

// Profile detection
$ismanaged := contains $hostLower "zwpe0f96cn"  // Zup managed machine
$profile := env "CHEZMOI_PROFILE" | default ($ismanaged | ternary "work" "personal")

// VPS auto-detection (Oracle Cloud ARM64)
$isVps := or (env "CHEZMOI_VPS") (contains $hostLower "vps") (contains $hostLower "vnic")
           (hasPrefix "instance-" $hostLower)
           (and (eq .chezmoi.osRelease.id "ubuntu") (eq .chezmoi.username "ubuntu") $sshSession (not $guiAvailable))

if $isVps { $profile = "vps" }
```

**Profiles**: `personal` (default), `work` (Zup), `vps` (Oracle Cloud)

---

## Feature Flag Hierarchy (FACT)

```
features:
  ai:
    coding_assistants: true
    spec_tools: true
    gsd: true
    multiplexer: true
    ollama:
      install: true (not on VPS)
      mode: "user" | "root" (depends on sudo)
    hermes:
      enabled: true
      dashboard:
        enabled: true
        port: 9119
        host: "0.0.0.0" (VPS) | "127.0.0.1" (local)
        domain: "hermes.fabiosouzadev.duckdns.org"
        isolated: true
      agentmemory: {enabled: true}
      camofox: {enabled: true}
      composio: {enabled: true}
    omniroute:
      dashboard_port: 20128
      bind: "0.0.0.0" (VPS) | "localhost" (local)
      domain: "fabiosouzadev.duckdns.org"
    coding_orchestrator:
      install: true (VPS)
      cron_schedule: "0 2 * * *"
      nightly_budget_usd: 5
      per_task_budget_usd: 2
  i3:
    enabled: true (not VPS)
  niri:
    enabled: true (not VPS)
  sudo: {enabled: not managed}
  systemd: {enabled: not managed AND linux}
```

---

## Script Lifecycle & Ordering (FACT)

### Naming Convention
```
run_once_before_XXX   # Pre-install (100s: drivers, 200s: WM config, etc.)
run_once_after_XXX    # Post-install (500s: tools, AI, services)
run_onchange_after_XXX # Re-runnable on template change (600s: cron, repos)
```

### Numbering Scheme
| Range | Purpose |
|-------|---------|
| 100-199 | Pre-install: drivers, kernel modules, base packages |
| 200-299 | Desktop config: WM, keyboard, bluetooth, virtualization |
| 300-399 | Reserved |
| 400-499 | Reserved |
| 500-599 | Post-install tools: mise, AI tools, CLI utils, fonts |
| 600-699 | On-change: cron jobs, repo cloning, sync |

### Guards (Reusable Templates)
| Guard | Template | Logic |
|-------|----------|-------|
| Skip in CI/ephemeral | `common/script_is_not_ephemeral` | `if .settings.ephemeral { exit 0 }` |
| Skip if headless | `common/script_is_not_headless` | `if .settings.headless { exit 0 }` |
| Validate completions path | `common/script_validate_completions_path` | Ensures `~/.local/share/zsh/site-functions/` exists |
| Eval mise | `common/script_eval_mise` | `eval "$(mise activate bash)"` |
| Helpers | `common/script_helper` | `info/warn/error/success` logging functions |

---

## Zsh Modular Structure (FACT)

`home/dot_zshrc.d/` — sourced in lexicographic order:

| File | Purpose |
|------|---------|
| `099-zshenv.zsh.tmpl` | Environment variables (PATH, etc.) |
| `100-install-zinit.zsh.tmpl` | Zinit plugin manager bootstrap |
| `101-zinit-plugins.zsh.tmpl` | Plugin declarations |
| `102-history.zsh.tmpl` | History settings |
| `103-fzf.zsh.tmpl` | FZF integration |
| `104-keybindings.zsh.tmpl` | Key bindings |
| `190-zsh-vi-mode.zsh.tmpl` | Vi mode + atuin |
| `200-aliases.zsh.tmpl` | General aliases |
| `200-atuin.zsh.tmpl` | Atuin history sync |
| `201-git-aliases.zsh.tmpl` | Git aliases |
| `302-aider.zsh.tmpl` | Aider config |
| `311-ollama.zsh.tmpl` | Ollama aliases |
| `312-source-composio.zsh.tmpl` | Composio completion |
| `504-zup.zsh.tmpl` | Zup workplace config |
| `604-openclaude.zsh.tmpl` | OpenClaude config |
| `606-hermes.zsh.tmpl` | Hermes aliases/functions |
| `999-autoload-compinit.zsh.tmpl` | Compinit |
| `encrypted_*.zsh.asc` | GPG-encrypted secrets (API keys, VPN, GitHub, Zup) |

---

## Secret Management (FACT)

### Dual System
1. **age (chezmoi-native)**: `private_dot_*/` directories, decrypted on `chezmoi apply`
   - Recipient: `E691C031009FB1DAA3A25125212D516F623C5747` (hardcoded in template)
   - Identity: `~/.config/chezmoi/key.txt`

2. **GPG (legacy `.asc` files)**: `encrypted_*.zsh.asc` sourced in Zsh
   - Same recipient
   - Decrypted via `gpg -d` in shell

### What's Encrypted
- `private_dot_config/` → `~/.config/*` (app configs)
- `private_dot_ssh/` → `~/.ssh/` (keys, config)
- `private_dot_hermes/` → `~/.hermes/` (state, config, memories)
- `private_dot_zup-worker/` → Zup work configs
- `encrypted_300-ai-api-keys.zsh.asc` — AI provider keys
- `encrypted_403-instivo.zsh.asc` — VPN credentials
- `encrypted_404-zup-keys.zsh.asc` — Zup SSH/GPG
- `encrypted_405-github-keys.zsh.asc` — GitHub tokens

---

## AI Integration Stack (FACT)

### Hermes Agent
- **Install**: `.chezmoiscripts/unix/run_once_after_535-install-hermes-dashboard.sh.tmpl`
- **Systemd**: `private_dot_config/private_systemd/private_user/hermes-dashboard.service.tmpl`
- **Dashboard**: `https://hermes.fabiosouzadev.duckdns.org/` (Caddy TLS)
- **Port**: 9119, Basic Auth configurable
- **Sync**: `hermes-sync-push/pull` (selective SQL + manifest + encrypted)

### OmniRoute
- **Install**: `.chezmoiscripts/run_once_after_install-omniroute-from-source.sh.tmpl`
- **Systemd**: `private_dot_config/private_systemd/private_user/omniroute.service.tmpl`
- **Dashboard**: `https://omniroute.fabiosouzadev.duckdns.org/` (subdomain) + direct `:20128`
- **Auth**: `INITIAL_PASSWORD` env var (default: CHANGEME)
- **Sync**: `omniroute-sync-push/pull` (config SQL + .env + manifest)

### Coding Orchestrator (Nocturnal Agents)
- **Skill**: `coding-orchestrator` in `~/.hermes/skills/`
- **Triggers**: GitHub label `coding-agent`, Telegram `@hermes coding-agent:`, webhook, cron `0 2 * * *`
- **Agents**: Aider (default via OmniRoute), Claude Code, Codex CLI, Gemini CLI, OpenCode
- **Isolation**: Git worktrees at `~/worktrees/task-<id>`
- **Budget**: $5/night total, $2/task max
- **Context**: GitHub API, Git diff, Notion MCP, mem0, repo files
- **Delivery**: Telegram, Notion, GitHub PR comments

---

## VPS-Specific Configuration (FACT)

### Detected as: Oracle Cloud ARM64, Ubuntu, user `ubuntu`, hostname `instance-*`

### Enabled Features (from `home/.chezmoidata/vps/features.yaml`)
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

### VPS Scripts (in `.chezmoiscripts/vps/`)
| Script | Purpose |
|--------|---------|
| `run_once_after_505-install-dockge.sh.tmpl` | Docker management UI |
| `run_once_after_530-install-caddy.sh.tmpl` | Reverse proxy with auto-TLS |
| `run_once_after_531-install-agentmemory.sh.tmpl` | Hermes agent memory service |
| `run_once_after_532-install-camofox.sh.tmpl` | Browser automation service |

### Ignored on VPS (from `.chezmoiignore.tmpl`)
- Window managers (i3, niri), fonts, hardware drivers (rtl8821ce, cirrus)
- Virtualization, Nix, OpenVPN/Instivo VPN (uses Tailscale)
- Paru (Arch), compile neovim/tmux from source
- Desktop configs (i3, niri, greenclip)

---

## Universal Binary Install Pattern (FACT)

**Location**: `home/.chezmoiscripts/unix/`
**Strategy**: Download pre-compiled binaries from GitHub Releases → `~/.local/bin/`
**No sudo required** — user-space only
**Cross-platform**: Detects OS (`uname -s`) and arch (`uname -m`)
**Idempotent**: Skips if tool already in `$PATH`
**Guard**: `script_is_not_ephemeral` only (runs on managed/work machines)

**Tools installed this way**: lazygit, delta, glab, and others in `ai_tools.yaml` (curl section)

---

## Repository Clone Automation (FACT)

`home/.chezmoiscripts/unix/run_onchange_after_605-clone-my-repos.sh.tmpl`

Clones repos into structured workspaces:
```
~/Workspaces/Personal/    # .repos.personal (if features.repos.personal)
~/Workspaces/Work/Zup/    # .repos.work.workplaces.Zup (if profile=work AND workplace=Zup)
~/Workspaces/Others/      # .repos.other (if features.repos.other)
```

Repo definitions in `home/.chezmoidata/repos.json` with `repo` (URL) and `path` (target subdir).

---

## Documentation (FACT)

Generated by `gsd-doc-writer`, in `docs/`:
| File | Purpose |
|------|---------|
| `ARCHITECTURE.md` | System overview, component diagram, data flow |
| `CONFIGURATION.md` | Env vars, feature flags, per-env overrides |
| `GETTING-STARTED.md` | Installation, prerequisites, first run |
| `HERMES-BACKUP.md` | Selective sync: what enters Git, what stays out |
| `OMNIROUTE-BACKUP.md` | Selective sync for OmniRoute config |
| `KEYMAPS.md` | tmux/nvim/zsh shortcuts |
| `FORK-GUIDE.md` | How to fork without inheriting secrets |
| `WINDOWS-SETUP.md` | Windows-specific instructions |

---

## Pattern Catalog (FACT vs INFERENCE)

| Pattern | Evidence | Label |
|---------|----------|-------|
| `run_once_before/after_XXX` numbering | File names in `.chezmoiscripts/` | FACT |
| `script_is_not_ephemeral` guard | Template content | FACT |
| Feature flag hierarchy `features.ai.hermes.dashboard.enabled` | `.chezmoi.yaml.tmpl` + `vps/features.yaml` | FACT |
| VPS detection via `instance-*` hostname | Template logic | FACT |
| Workplace detection via `zwpe0f96cn` hostname | Template logic | FACT |
| Zsh module numbering 099-999 | `dot_zshrc.d/` file listing | FACT |
| `private_*` prefix = encrypted | Directory structure + README | FACT |
| `encrypted_*.asc` = GPG secrets | File extension + sourcing in Zsh | FACT |
| Universal binary install to `~/.local/bin` | Script content + README | FACT |
| `hermes-sync` / `omniroute-sync` binaries exist | Referenced in backup docs | FACT |
| Philosophy: "Reproducibility > convenience" | README + ARCHITECTURE.md | INFERENCE |
| Philosophy: "IA as first-class citizen" | AI tools integrated in bootstrap | INFERENCE |
| Trade-off: Universal binary vs package manager | ARCHITECTURE.md "Universal Binary Install Pattern" | INFERENCE |
| Preference: Zinit over Oh My Zsh | Only Zinit found in repo | INFERENCE |
| Aider as default coding agent | README "Aider (padrão, via OmniRoute)" | INFERENCE |
| Worktree isolation for coding tasks | README "Worktree Isolation" section | INFERENCE |

---

## Risks & Technical Debt (INFERENCE)

| Item | Severity | Notes |
|------|----------|-------|
| Fixed GPG recipient in template | HIGH | Rotation requires fork guide update |
| VPS detection heuristics may false-positive | MEDIUM | Add `CHEZMOI_VPS` mandatory env var |
| `run_onchange_after_610-deploy-hermes-cron-jobs.sh.tmpl` missing (404) | HIGH | Cron deploy broken? |
| `hermes-sync` / `omniroute-sync` not versioned in repo | MEDIUM | Referenced but not in `.chezmoidata/` |
| Complex `$guiAvailable` ternary hard to debug | MEDIUM | Extract to named template |
| No automated tests for scripts | MEDIUM | Add bats/shellspec |
| `docs/DEVELOPMENT.md` and `docs/TESTING.md` referenced but missing | LOW | Create or remove refs |
| `.chezmoiexternals/` only has atuin | LOW | Expand for mise, starship, zinit, fzf |

---

## Proposed Skills (15 Class-Level)

| Skill | Responsibility | Depends On |
|-------|----------------|------------|
| `chezmoi-architecture` | Core concepts, data flow, application order | — |
| `chezmoi-template-patterns` | Guards, composition, functions, conditionals | `chezmoi-architecture` |
| `chezmoi-environment-detection` | OS, headless, ephemeral, CI, VPS, WSL, container | `chezmoi-architecture` |
| `chezmoi-secret-management` | age + GPG, recipient, identity, encrypt/decrypt, rotate | `chezmoi-architecture` |
| `chezmoi-script-lifecycle` | run_once_before/after, run_onchange, guards, ordering | `chezmoi-architecture` |
| `chezmoi-multi-profile` | personal/work/vps, feature flags per profile | `chezmoi-environment-detection` |
| `chezmoi-ignore-patterns` | Conditional .chezmoiignore.tmpl by OS/profile/VPS | `chezmoi-architecture` |
| `dotfiles-zsh-modular` | dot_zshrc.d numbering, sourcing, encrypted secrets loading | — |
| `dotfiles-universal-binary-install` | GitHub Releases → ~/.local/bin, no-sudo, cross-platform | `chezmoi-script-lifecycle` |
| `dotfiles-ai-integration` | Hermes, OmniRoute, Coding Orchestrator install/config/sync | `chezmoi-script-lifecycle`, `chezmoi-secret-management` |
| `dotfiles-vps-bootstrap` | Oracle Cloud ARM64: Dockge, Caddy, Tailscale, DuckDNS, systemd | `chezmoi-environment-detection`, `chezmoi-script-lifecycle` |
| `dotfiles-workplace-zup` | Zup-specific: SSH keys, VPN Instivo, bob, git config | `chezmoi-multi-profile` |
| `dotfiles-backup-strategy` | Selective SQL, manifest, encrypted (hermes-sync, omniroute-sync) | `chezmoi-secret-management` |
| `dotfiles-fork-guide` | Re-encrypt secrets, rotate age key, review before apply | `chezmoi-secret-management` |
| `dotfiles-architecture-review` | Detect regressions, inconsistencies, duplications, improvements | All above |

---

## Skill Dependency Graph

```
chezmoi-architecture
    ├── chezmoi-template-patterns
    ├── chezmoi-environment-detection
    │       ├── chezmoi-multi-profile
    │       │       └── dotfiles-workplace-zup
    │       └── dotfiles-vps-bootstrap
    ├── chezmoi-secret-management
    │       ├── dotfiles-backup-strategy
    │       └── dotfiles-fork-guide
    ├── chezmoi-script-lifecycle
    │       ├── dotfiles-universal-binary-install
    │       ├── dotfiles-vps-bootstrap
    │       └── dotfiles-ai-integration
    ├── chezmoi-ignore-patterns
    └── chezmoi-multi-profile
```

---

## Backup Order for Skills

1. `chezmoi-architecture` (foundation)
2. `chezmoi-template-patterns`
3. `chezmoi-environment-detection`
4. `chezmoi-secret-management`
5. `chezmoi-script-lifecycle`
6. `chezmoi-multi-profile`
7. `chezmoi-ignore-patterns`
8. `dotfiles-zsh-modular`
9. `dotfiles-universal-binary-install`
10. `dotfiles-vps-bootstrap`
11. `dotfiles-workplace-zup`
12. `dotfiles-ai-integration`
13. `dotfiles-backup-strategy`
14. `dotfiles-architecture-review`
15. `dotfiles-fork-guide`

---

## Future Learning (UNKNOWN)

- Internals of `hermes-sync` / `omniroute-sync` binaries
- GSD methodology artifacts in `.planning/`
- Caddy config templates for Hermes/OmniRoute subdomains
- Dockge compose stack definitions
- Tailscale ACLs / tailnet lock configuration
- Mise tool version pinning strategy
- Zinit plugin specs (lazy loading, turbo mode)
- Starship prompt modules per profile
- Aider config (`.aider.conf.yaml.tmpl`)
- OmniRoute routing logic (local vs remote providers)