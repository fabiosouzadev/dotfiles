---
last_mapped_commit: d1d1c1c967319d6aa2852d6caaee2123acced521
last_mapped_at: 2026-11-23
---
<!-- refreshed: 2026-11-23 -->
# Architecture

**Analysis Date:** 2026-11-23

## System Overview

This is a chezmoi-based dotfiles repository that manages a comprehensive development environment across multiple OS platforms (macOS, Linux WSL, Arch, Ubuntu, Termux, Windows) and deployment contexts (personal workstations, VPS infrastructure, container-based environments).

```text
┌─────────────────────────────────────────────────────────────────────────┐
│                    Environment Detection Layer                           │
│           `.chezmoi.yaml.tmpl` - Profile, OS, context inference         │
├──────────────┬──────────────┬──────────────┬────────────┬────────────┬──┤
│ CI/Ephemeral │ Container    │ GUI Detection│ VPS Probe  │ SSH/Headless   │
│ (GitHub,     │ (Docker,     │ (Display,    │ (Oracle    │ Terminal mode  │
│  Codespaces) │  devcontainer) │ Wayland)   │  Cloud)    │ detection      │
└──────────────┴──────────────┴──────────────┴────────────┴────────────┴──┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│          Bootstrap & Lifecycle Scripts Layer                             │
│                   `home/.chezmoiscripts/`                                │
├──────────────┬──────────────┬──────────────┬────────────┬────────────────┤
│  Darwin      │ Linux        │ Unix Shared  │ Termux     │ VPS Specialized│
│  (macOS)     │ (Arch/Ubuntu)│ (npm, mise,  │ (mobile)   │ (Caddy, Docker)│
│  Framework   │  Framework   │ ai-tools)    │ Framework  │ Framework      │
│  `run_once_` │ `run_once_`  │ `run_once_`  │ `run_once_ │ `run_once_`    │
│  `run_before_│ `run_before_ │ `run_before_ │ `run_before │ `run_before_`  │
│  `run_onchange│ `run_onchange│ `run_onchange│ `run_onchan │ `run_onchange` │
└──────────────┴──────────────┴──────────────┴────────────┴────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│           Templated Configuration Layer                                  │
│    `home/.chezmoitemplates/` → Reusable guards and template snippets    │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│         File Deployment & Encryption Layer                              │
│                    Generated Home Directory                              │
├──────────────┬──────────────┬──────────────┬────────────┬────────────────┤
│ Shell config │ App configs  │ SSH keys &   │ Encrypted  │ Docker Compose │
│ `.zshrc.d/`  │ `.config/`   │ certs        │ state      │ stacks (.local/│
│ Modular      │ (kitty,      │ `.ssh/`      │ (Hermes,   │ opt/stacks/)   │
│ 24 modules   │  tmux, nvim, │ (private)    │ OmniRoute) │ (caddy,        │
│ (zinit,      │  git, etc)   │ (private)    │ (private)  │  ollama,       │
│ aliases,     │ `.hermes/`   │              │ (encrypted │  omniroute)    │
│ history,     │ skill state  │              │  .asc)     │                │
│ keybinds)    │ AI tools     │              │            │                │
└──────────────┴──────────────┴──────────────┴────────────┴────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                  External & AI Integration Layer                         │
│         Hermes, OmniRoute, Composio, Coding Orchestrator                │
└─────────────────────────────────────────────────────────────────────────┘
```

## Component Responsibilities

| Component | Responsibility | File |
|-----------|----------------|------|
| **Config Detection** | Multi-environment profile resolution (CI, containers, VPS, GUI, headless) | `home/.chezmoi.yaml.tmpl` |
| **Data Source** | Platform-specific package lists, feature flags, paths | `home/.chezmoidata/{linux,darwin,vps,windows,termux}/` |
| **Lifecycle Hooks** | OS-specific bootstrap (kernel, drivers, package managers, tools) | `home/.chezmoiscripts/{linux,darwin,unix,vps,termux}/` |
| **Template Reuse** | Common script guards and patterns | `home/.chezmoitemplates/{common,linux,darwin,workplace}/` |
| **Shell Environment** | Modular zsh config, plugins, aliases, keybindings | `home/.zshrc.d/` (24 modules) |
| **Application Configs** | App-specific settings managed by chezmoi | `home/private_dot_config/` |
| **SSH & Certificates** | Private key & cert management | `home/private_dot_ssh/` (private) |
| **Encrypted State** | Versioned secrets (Hermes, OmniRoute, AWS creds) | Encrypted `.asc` files |
| **AI/Automation** | AI tools, Hermes skills, OmniRoute gateway | `home/dot_hermes/`, `home/dot_local/bin/` |
| **Service Infrastructure** | Docker Compose stacks for persistent services | `home/dot_local/opt/stacks/` |

## Pattern Overview

**Overall:** Multi-layered deterministic environment builder with platform abstraction, feature flags, and encrypted state management.

**Key Characteristics:**
- **Declarative**: All configuration as code (templates, scripts, data files) — no manual CLI commands required
- **Platform-agnostic**: Single source-of-truth auto-adapts to OS, container type, CI, SSH, GUI availability
- **Phased execution**: chezmoi's `run_before_`, `run_once_`, `run_onchange_` ordering ensures dependency resolution
- **Encrypted secrets**: age-encrypted `.asc` files committed alongside templates; GPG decryption at apply time
- **Feature-flagged**: `.chezmoi.yaml.tmpl` data drives conditional installation and service deployment
- **Externally sourced**: `.chezmoiexternals/` pulls stable theme/config files from upstream (Catppuccin, etc)
- **Self-contained**: No external bootstrap repos; everything versioned in this single chezmoi directory

## Layers

**Environment Detection:**
- Purpose: Probe runtime context and infer optimal configuration
- Location: `home/.chezmoi.yaml.tmpl`
- Contains: Shell probes for CI, containers, GUI, VPS, SSH, TTY, WSL, Termux
- Depends on: OS detection (chezmoi built-ins), environment variables
- Used by: All downstream scripts and templates to conditionally execute

**Data & Configuration:**
- Purpose: Store platform-specific package lists, feature flags, and settings
- Location: `home/.chezmoidata/` (per-OS subdirectories)
- Contains: YAML/JSON defining `ai_tools`, `packages`, `features` keyed by OS/platform
- Depends on: Environment detection output
- Used by: Bootstrap scripts to conditionally install

**Bootstrap & Lifecycle Scripts:**
- Purpose: Execute OS-specific installation and configuration steps
- Location: `home/.chezmoiscripts/{linux,darwin,unix,vps,termux}/`
- Contains: Bash scripts numbered `run_before_*/run_once_*/run_onchange_*` for each stage
- Depends on: Data layer, environment context, template guards
- Used by: chezmoi apply orchestration

**Template Reuse Library:**
- Purpose: Provide common guards and snippets to reduce script duplication
- Location: `home/.chezmoitemplates/{common,linux,darwin,workplace}/`
- Contains: Reusable `script_is_ephemeral`, `script_eval_mise`, `script_helper`, etc.
- Depends on: Nothing (pure includes)
- Used by: All bootstrap scripts via `{{ template "..." . }}`

**Shell Configuration:**
- Purpose: Set up interactive shell environment (zsh)
- Location: `home/dot_zshrc.d/` (24 modular files)
- Contains: Zinit plugin loading, aliases, keybindings, fzf, atuin, Hermes/OmniRoute initialization
- Depends on: Installed tools (fzf, atuin, zinit)
- Used by: Interactive terminal sessions

**Application Configuration:**
- Purpose: Manage app-specific dotfiles and settings
- Location: `home/private_dot_config/{kitty,tmux,nvim,git,mise,...}/`
- Contains: Per-app config files (templates or static)
- Depends on: Application installation (from bootstrap)
- Used by: Applications at runtime

**Encrypted State:**
- Purpose: Version control sensitive data (credentials, keys, internal state)
- Location: Scattered across repo as `.asc` files (GPG-encrypted)
- Contains: API keys, SSH keys, database credentials, Hermes/OmniRoute internal state
- Depends on: `age` and GPG key (chezmoi configured recipient)
- Used by: Bootstrap scripts and runtime environments (decrypted on apply)

**Service Infrastructure:**
- Purpose: Define long-running services (Caddy, Ollama, Hermes, OmniRoute)
- Location: `home/dot_local/opt/stacks/{caddy,ollama,hermes,omniroute,openknowledge}/`
- Contains: Docker Compose files, Dockerfiles, encrypted env files, restore scripts
- Depends on: Docker/Podman installed (via bootstrap)
- Used by: Dockge UI or manual `docker-compose up`

## Data Flow

### Primary Apply Flow (chezmoi apply)

1. **Environment Detection** (`home/.chezmoi.yaml.tmpl`)
   - Probes OS, container type, GUI, VPS, CI, SSH, TTY
   - Builds `$data.settings` dict with boolean flags and paths
   - Outputs profile (personal/work/vps) and feature toggles

2. **Data Loading** (`home/.chezmoidata/{os}/`)
   - Loads platform-specific package lists and tool definitions
   - Feature flags resolved against `$.features.*` from template data
   - Conditional compilation of install commands

3. **Pre-Apply Hooks** (`run_before_*` scripts)
   - Install system kernels, drivers, package managers (paru, apt, brew)
   - Set up keyboard layouts, swap, networking (if not ephemeral)
   - Install Nix, fzf, devops tools

4. **Core Installation** (`run_once_*` scripts)
   - Install language runtimes (mise, Node, Python, Rust)
   - Install Ollama, Delta, IDEA, Coderabbit CLI, Atuin
   - Install AI tools (Aider, Claude, OpenCode) via npm/curl/git
   - Deploy Hermes dashboard, OmniRoute gateway, Dockge
   - Deploy cron jobs (coding orchestrator)

5. **Change-Triggered** (`run_onchange_*` scripts)
   - Install system packages whenever `.chezmoidata/` changes
   - Install Ollama models when tool version changes
   - Deploy cron jobs when script changes
   - Clone/pull personal repos

6. **File Deployment**
   - Chezmoi copies templated files from `home/` to `~`
   - Templated paths respect `dot_` → `.` and `private_` → encryption
   - `.zshrc.d/` modules auto-sourced by modular zshrc

### Shell Initialization Flow

1. **Login shell** (`~/.zprofile` / `~/.zshrc`)
   - Sources `~/.zshrc.d/*.zsh` in alphabetical order

2. **Module load order** (via `home/dot_zshrc.d/`)
   - `099-zshenv.zsh`: Environment variables
   - `100-install-zinit.zsh`: Bootstrap zinit plugin manager
   - `101-zinit-plugins.zsh`: Load plugins (fzf-tab, zsh-vi-mode, etc)
   - `102-history.zsh`: History config
   - `103-fzf.zsh`: Fuzzy find
   - `104-keybindings.zsh`: Vim bindings
   - `200-aliases.zsh`: General aliases
   - `200-atuin.zsh`: Shell history search
   - `300-ai-api-keys.zsh`: (encrypted) API keys from `encrypted_300-ai-api-keys.zsh.asc`
   - `302-aider.zsh`: Aider CLI config
   - `311-ollama.zsh`: Ollama setup
   - `605-omniroute.zsh`: OmniRoute client init
   - `606-hermes.zsh`: Hermes CLI aliases

**State Management:**
- **Persistent**: `.zshrc.d/encrypted_*.asc` holds API keys, tokens, secrets
- **Runtime**: Hermes/OmniRoute daemons manage in-memory state; synced via `hermes-sync` and `omniroute-sync` scripts
- **Versioned**: Encrypted state committed to git; decrypted at each apply

## Key Abstractions

**Environment Profile:**
- Purpose: Encapsulate OS, container, GUI, VPS, TTY detection into named profiles (personal/work/vps/ephemeral)
- Examples: `home/.chezmoi.yaml.tmpl` lines 50–127 (profile inference)
- Pattern: Boolean flags + string profile name used by all downstream scripts

**Conditional Execution Guards:**
- Purpose: Template snippets that gate script execution based on environment
- Examples: `{{ template "common/script_is_not_ephemeral" . }}`, `{{ template "workplace/script_is_vps" . }}`
- Pattern: If guard condition fails, script exits silently with `exit 0`

**Platform-Specific Data Structures:**
- Purpose: Store tool/package lists in YAML, keyed by OS and feature flag
- Examples: `home/.chezmoidata/linux/` contains `packages.yaml`, `ai_tools.yaml` with per-distro variants
- Pattern: Loop over data arrays, conditionally execute based on feature flag and blocklist

**Feature Flags:**
- Purpose: Control which optional services/tools install
- Examples: `features.ai.hermes.enabled`, `features.ai.omniroute.dashboard_port`
- Pattern: Defined in `.chezmoi.yaml.tmpl` data section; override via `CHEZMOI_*` env vars

**Encrypted Asset:**
- Purpose: Version-control secrets without exposing values
- Examples: `home/private_dot_ssh/`, `home/.zshrc.d/encrypted_*.asc`, `home/dot_local/opt/stacks/*/encrypted_*.asc`
- Pattern: `.asc` extension signals age/GPG encryption; chezmoi decrypts on apply

## Entry Points

**chezmoi init:**
- Location: (external CLI, invoked by user)
- Triggers: User runs `chezmoi init --apply fabiosouzadev`
- Responsibilities: Clone repo, decrypt secrets, run all scripts, deploy dotfiles

**chezmoi apply:**
- Location: (chezmoi built-in, uses `.chezmoi.yaml.tmpl` as config)
- Triggers: User runs `chezmoi apply` or `chezmoi update && chezmoi apply`
- Responsibilities: Re-run environment detection, execute changed scripts, update dotfiles

**Run script ordering:**
- Location: `home/.chezmoiscripts/` subdirectories
- Triggers: chezmoi detects platform OS/location
- Responsibilities: Execute `run_before_*` → `run_onchange_*` → `run_once_*` → deploy files

**Interactive shell:**
- Location: `~/.zshrc` → `~/.zshrc.d/*.zsh`
- Triggers: User opens terminal
- Responsibilities: Load plugins, set aliases, initialize Hermes/OmniRoute clients

## Architectural Constraints

- **Single source of truth**: All config lives in chezmoi directory; no external bootstrap tools required
- **Deterministic apply**: `.chezmoi.yaml.tmpl` templates scripts to be idempotent; `run_once_` gates ensure scripts run once only
- **Phased execution**: chezmoi enforces `run_before_` → `run_onchange_` → `run_once_*` ordering; scripts cannot assume parallel execution
- **Encrypted at rest**: All `.asc` files assumed age/GPG encrypted; chezmoi's `encryption: gpg` decrypts transparently
- **Platform abstraction**: No hardcoded paths; all paths derive from `$chezmoi.homeDir` and `$chezmoi.os`
- **Feature-flagged conditionals**: Scripts gate on `$.features.*` boolean flags; no inline OS checks
- **Modular shell config**: `.zshrc.d/` modules sourced alphabetically; order-dependent (100 before 200) — documented via numbering
- **Externally-sourced themes**: Catppuccin and other themes pulled via `.chezmoiexternals/` from upstream (not versioned)
- **Credential isolation**: `.zup-worker/` and `.hermes/` are workspace-scoped; personal and VPS profiles use separate secrets

## Anti-Patterns

### Hardcoded Absolute Paths in Scripts

**What happens:** Scripts like `run_once_after_590-install-ai-tools.sh.tmpl` use `$HOME/.local/bin` and `$HOME/.local/src` directly

**Why it's wrong:** `.local` path is OS-dependent on some systems (macOS uses `~/Library`); chezmoi's path context should be used throughout

**Do this instead:** Use chezmoi template functions like `{{ joinPath .chezmoi.homeDir ".local" "bin" }}` to construct paths in all scripts (`home/.chezmoiscripts/*/*.tmpl`)

### Conditional Feature Checks Mixed with OS Checks

**What happens:** Scripts sometimes check both `{{ template "common/script_is_not_ephemeral" . }}` AND `{{ if $.features.ai.herness }}` — guards nested unpredictably

**Why it's wrong:** Makes script flow hard to trace; feature flags should be the primary gate, OS checks secondary

**Do this instead:** Always gate on feature flags first, then OS guards. Order: (1) feature enabled? (2) OS/environment supports? (3) execute

### Unencrypted Credential Comments

**What happens:** `.env` files and scripts sometimes contain placeholder comments like `# API_KEY=sk-...` that could leak secrets

**Why it's wrong:** Comments can be accidentally exposed in logs, diffs, or when file is read carelessly

**Do this instead:** Use only `.asc` encrypted files for ANY credential placeholder, even comments. Store ALL secrets encrypted.

## Error Handling

**Strategy:** Fail-fast with explicit status codes; each bootstrap script template includes `set -euo pipefail` and uses helper functions for clean error output.

**Patterns:**
- `info()`, `warn()`, `error()`, `success()` color-coded output via `home/.chezmoitemplates/common/script_helper`
- Scripts exit `1` on error; chezmoi aborts apply and reports which script failed
- Guards (`{{ template "common/script_is_not_ephemeral" . }}`) exit `0` when condition unmet — prevents cascading failures on skipped stages
- No inline error handling in scripts; errors bubble up to chezmoi orchestration

## Cross-Cutting Concerns

**Logging:** All bootstrap scripts source `script_helper` and use `info()`, `warn()`, `error()`, `success()` helpers. Colored output for readability; no structured logging.

**Validation:** 
- `script_validate_completions_path` checks `~/.local/share/zsh/site-functions/` exists before writing completions
- No runtime validation of credentials or deployed configs — assumes `.asc` files are correct

**Authentication:**
- SSH keys in `home/private_dot_ssh/` (encrypted + private)
- API keys in `home/.zshrc.d/encrypted_300-ai-api-keys.zsh.asc` (encrypted)
- Hermes/OmniRoute credentials in respective `.asc` files
- All decrypted by chezmoi at apply time using GPG recipient configured in `.chezmoi.yaml.tmpl`

---

*Architecture analysis: 2026-11-23*
