<!-- refreshed: 2026-06-12 -->
# Architecture

**Analysis Date:** 2026-06-12

## System Overview

```text
┌────────────────────────────────────────────────────────────────────┐
│                     `chezmoi apply` / `chezmoi init --apply`      │
├───────────────────────────┬──────────────────┬────────────────────┤
│ Environment detection     │ Data selection   │ Script execution    │
│ `home/.chezmoi.yaml.tmpl` │ `home/.chezmoidata/` │ `home/.chezmoiscripts/` │
├───────────────────────────┴──────────────────┴────────────────────┤
│ Template rendering, file filtering, package/install orchestration │
├────────────────────────────────────────────────────────────────────┤
│ Generated configs and secrets land in `$HOME`                     │
│ `home/dot_*`, `home/private_dot_*`, `home/.chezmoitemplates/`     │
└────────────────────────────────────────────────────────────────────┘
```

## Component Responsibilities

| Component | Responsibility | File |
|-----------|----------------|------|
| Environment bootstrap | Detect OS, profile, GUI/headless state, and feature flags | `home/.chezmoi.yaml.tmpl` |
| File filtering | Exclude OS/VPS-specific paths before rendering | `home/.chezmoiignore.tmpl` |
| Shell entrypoint | Load ordered zsh fragments into the user shell | `home/dot_zshrc.tmpl` |
| Script helpers | Provide shared shell boilerplate and logging | `home/.chezmoitemplates/common/script_helper` |
| Platform installers | Install packages, runtimes, tools, and services | `home/.chezmoiscripts/linux/*.tmpl`, `home/.chezmoiscripts/unix/*.tmpl`, `home/.chezmoiscripts/darwin/*.tmpl`, `home/.chezmoiscripts/windows/*.tmpl` |
| App configuration | Render user-facing configs for shell, tmux, wm, terminals, and AI tools | `home/dot_zshrc.d/`, `home/private_dot_config/`, `home/private_dot_mozilla/` |
| Data inputs | Hold package lists, model definitions, repo lists, and OS-specific parameters | `home/.chezmoidata/` |
| External assets | Pin third-party repos, themes, and plugin sources | `home/.chezmoiexternals/` |
| Secret material | Store encrypted secrets for SSH, GPG, VPN, and API access | `home/**/encrypted_*`, `home/dot_zshrc.d/encrypted_*.age` |

## Pattern Overview

**Overall:** Template-driven declarative provisioning with ordered lifecycle hooks.

**Key Characteristics:**
- Use `chezmoi` templates as the single orchestration layer for OS/profile-aware setup.
- Keep installation inputs in data files under `home/.chezmoidata/` and keep imperative work in `home/.chezmoiscripts/`.
- Split large application configs into modular files, especially `home/dot_zshrc.d/` and `home/private_dot_config/niri/cfg/`.
- Treat secrets as encrypted assets only; no plaintext credentials are committed.

## Layers

**1. Detection and feature selection:**
- Purpose: derive runtime context and feature flags.
- Location: `home/.chezmoi.yaml.tmpl`
- Contains: OS detection, host/profile classification, GUI/headless checks, VPS heuristics, feature dictionaries.
- Depends on: `chezmoi` template functions, environment variables, shell probes.
- Used by: `.chezmoiscripts/`, templates, ignore rules, data-driven package selection.

**2. Data layer:**
- Purpose: hold declarative inputs for package and model installation.
- Location: `home/.chezmoidata/`
- Contains: platform package manifests, fonts, kernel lists, repo lists, Ollama model definitions.
- Depends on: template variables exposed by `.chezmoi.yaml.tmpl`.
- Used by: installation scripts such as `home/.chezmoiscripts/linux/run_onchange_before_201-install-arch-packages.sh.tmpl`.

**3. Guard/template layer:**
- Purpose: reuse common shell and template guards across scripts.
- Location: `home/.chezmoitemplates/`
- Contains: shell helper snippets and platform/workplace predicates.
- Depends on: chezmoi template evaluation and shell execution.
- Used by: lifecycle scripts in `home/.chezmoiscripts/`.

**4. Lifecycle script layer:**
- Purpose: perform idempotent system setup and tool installation.
- Location: `home/.chezmoiscripts/`
- Contains: `run_once_before_`, `run_onchange_before_`, `run_once_after_`, and `run_onchange_after_` scripts.
- Depends on: guards from `home/.chezmoitemplates/`, package data, platform-specific package managers.
- Used by: `chezmoi apply` during bootstrap and refresh runs.

**5. Config file layer:**
- Purpose: render end-user configuration files for shells, editors, terminals, WMs, browsers, and AI tools.
- Location: `home/dot_zshrc.d/`, `home/private_dot_config/`, `home/private_dot_mozilla/`.
- Contains: templates and plain configs for zsh, tmux, git, niri, kitty, wezterm, starship, Firefox, and AI tooling.
- Depends on: environment data and secrets.
- Used by: the user session after deployment.

**6. External layer:**
- Purpose: vendor upstream assets that are not authored locally.
- Location: `home/.chezmoiexternals/`
- Contains: theme sources, plugins, wallpapers, browser extras.
- Depends on: remote git repositories and archive sources.
- Used by: application configs that reference those assets.

**7. Secrets layer:**
- Purpose: keep sensitive data encrypted at rest.
- Location: `home/**/encrypted_*` and `home/dot_zshrc.d/encrypted_*.age`.
- Contains: SSH keys, GPG keys, API tokens, VPN certificates, service auth blobs.
- Depends on: `age` and user-specific key material.
- Used by: shell startup, auth tooling, VPN and work-profile setup.

## Data Flow

### Primary Provisioning Flow

1. `chezmoi apply` starts from the repo root defined by `.chezmoiroot` (`.chezmoiroot`).
2. `.chezmoi.yaml.tmpl` computes the runtime context: OS, host, profile, headless/interactive state, and feature flags (`home/.chezmoi.yaml.tmpl:14-229`).
3. `.chezmoiignore.tmpl` removes platform or VPS-inapplicable files before rendering (`home/.chezmoiignore.tmpl:1-73`).
4. Templates render `home/dot_*` and `home/private_dot_*` files into the target home directory.
5. Lifecycle scripts execute in numeric order, with guards controlling whether each script runs (`home/.chezmoiscripts/linux/run_onchange_before_201-install-arch-packages.sh.tmpl:1-28`, `home/.chezmoiscripts/unix/run_once_after_503-install-mise.sh.tmpl:1-58`).
6. Generated configs, shell fragments, and installed tools are available to the session.

### Shell Initialization Flow

1. `home/dot_zshrc.tmpl` sets `ZDOTDIR=$HOME` and sources `~/.zshrc.d/*.zsh` in lexical order (`home/dot_zshrc.tmpl:3-11`).
2. Numbered fragments in `home/dot_zshrc.d/` layer environment variables, plugins, aliases, integrations, and secrets.
3. Late fragments enable tool integrations such as `mise`, `zoxide`, `direnv`, `starship`, `ollama`, and `openclaude`.

### Linux Package Install Flow

1. Linux-only scripts check platform and workplace guards before doing work (`home/.chezmoiscripts/linux/run_onchange_before_201-install-arch-packages.sh.tmpl:3-8`).
2. Package lists are read from `.chezmoidata/linux/packages/archlinux.yaml` or the relevant OS file.
3. Package managers install core, extra, multilib, and AUR packages through `pacman`, `paru`, or `yay` (`home/.chezmoiscripts/linux/run_onchange_before_201-install-arch-packages.sh.tmpl:13-24`).
4. Follow-up scripts install runtime tools, fonts, and services after package provisioning.

### Niri Configuration Flow

1. `home/private_dot_config/niri/config.kdl` acts as the top-level entrypoint.
2. It includes modular config slices from `home/private_dot_config/niri/cfg/` (`home/private_dot_config/niri/config.kdl:6-13`).
3. The include-based design keeps keybinds, rules, layout, display, input, animations, and misc settings independently editable.

**State Management:**
- State is mostly declarative and idempotent.
- Mutable state exists only where tools need caches, generated completions, or runtime stores under `$HOME`.
- Feature flags in `.chezmoi.yaml.tmpl` drive whether scripts and configs appear at all.

## Key Abstractions

**Environment flags:**
- Purpose: centralize machine classification and feature gating.
- Examples: `home/.chezmoi.yaml.tmpl`.
- Pattern: compute booleans and dictionaries once, then reuse in templates and scripts.

**Lifecycle scripts:**
- Purpose: isolate imperative bootstrapping from config rendering.
- Examples: `home/.chezmoiscripts/linux/run_onchange_before_201-install-arch-packages.sh.tmpl`, `home/.chezmoiscripts/unix/run_once_after_503-install-mise.sh.tmpl`.
- Pattern: idempotent `run_once_` and `run_onchange_` scripts with guards and `set -euo pipefail`.

**Template guards:**
- Purpose: share platform/workplace checks across scripts.
- Examples: `home/.chezmoitemplates/common/script_helper`, `home/.chezmoitemplates/linux/script_arch_based_only`, `home/.chezmoitemplates/workplace/script_is_not_zup`.
- Pattern: small include-only snippets used through `{{ template "..." . }}`.

**Modular app configs:**
- Purpose: keep complex application configuration decomposed.
- Examples: `home/dot_zshrc.d/`, `home/private_dot_config/niri/cfg/`.
- Pattern: one concern per file, ordered by numeric prefix or explicit `include` statements.

**Declarative package data:**
- Purpose: separate package choices from install logic.
- Examples: `home/.chezmoidata/linux/packages/archlinux.yaml`, `home/.chezmoidata/ollama.yaml`, `home/.chezmoidata/repos.json`.
- Pattern: scripts iterate over data collections rather than hard-coding package names.

## Entry Points

**Primary bootstrap:**
- Location: `chezmoi init --apply`, `chezmoi apply`
- Triggers: first install, re-apply after changes, refresh of generated home files.
- Responsibilities: render templates, execute lifecycle hooks, manage source-to-home deployment.

**Environment config:**
- Location: `home/.chezmoi.yaml.tmpl`
- Triggers: every apply/init.
- Responsibilities: detect runtime context, define feature flags, expose data consumed elsewhere.

**Shell startup:**
- Location: `home/dot_zshrc.tmpl`
- Triggers: interactive zsh sessions.
- Responsibilities: source `home/dot_zshrc.d/*.zsh.tmpl` fragments in order.

**Niri startup config:**
- Location: `home/private_dot_config/niri/config.kdl`
- Triggers: Niri session startup.
- Responsibilities: assemble modular Wayland compositor config.

## Architectural Constraints

- **Threading:** single-process, sequential provisioning; no concurrent installer orchestration is defined.
- **Global state:** machine classification lives in `.chezmoi.yaml.tmpl` and is reused across files via `.settings` and `.features`.
- **Circular imports:** none detected in template includes; the modular configs use one-way inclusion.
- **Platform gating:** platform- and workplace-specific files must remain behind `home/.chezmoiignore.tmpl` and template guards.

## Anti-Patterns

### Hard-coding package names in scripts

**What happens:** package choices are embedded directly in shell scripts.
**Why it's wrong:** it duplicates platform data and makes Arch/Debian/macOS variants harder to maintain.
**Do this instead:** read package lists from `home/.chezmoidata/linux/packages/archlinux.yaml` and similar data files.

### Putting platform checks directly in config fragments

**What happens:** application config files attempt to re-detect OS or profile.
**Why it's wrong:** it spreads environment logic across many files and makes behavior inconsistent.
**Do this instead:** centralize gating in `home/.chezmoi.yaml.tmpl` and `home/.chezmoiignore.tmpl`, then keep fragments focused on one application.

## Error Handling

**Strategy:** fail fast in scripts, skip cleanly in unsupported environments, and keep templates best-effort.

**Patterns:**
- Shell scripts start with `set -euo pipefail` or equivalent helper behavior (`home/.chezmoitemplates/common/script_helper`).
- Guards block execution on unsupported platforms or workplace profiles before any destructive work.
- Templates use environment detection and defaulting to avoid hard failures during rendering.

## Cross-Cutting Concerns

**Logging:** shell scripts print colored status messages through `info`, `warn`, `error`, and `success` from `home/.chezmoitemplates/common/script_helper`.
**Validation:** `home/.chezmoi.yaml.tmpl` validates runtime context through probes and feature flags before emitting dependent values.
**Authentication:** secrets and auth material are encrypted in repo and decrypted on apply; external auth-config files live under `home/private_dot_*` and `home/dot_zshrc.d/`.

---

*Architecture analysis: 2026-06-12*