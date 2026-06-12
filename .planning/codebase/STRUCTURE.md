# Codebase Structure

**Analysis Date:** Fri Jun 12 2026

## Directory Layout

```text
chezmoi-root/
├── home/                     # Source-of-truth home directory tree
├── docs/                     # Human docs for development, config, testing, architecture
├── .planning/                # GSD planning, maps, milestones, state
└── README.md                 # Project entry overview
```

## Directory Purposes

**`home/`:**
- Purpose: managed dotfiles and bootstrap logic that chezmoi renders into `$HOME`.
- Contains: templates, shell fragments, platform scripts, app configs, encrypted secrets placeholders, reusable templates, and platform data.
- Key files: `home/.chezmoi.yaml.tmpl`, `home/.chezmoidata/`, `home/.chezmoiscripts/`, `home/.chezmoitemplates/`, `home/dot_zshrc.d/`, `home/private_dot_config/`, `home/dot_screenlayout/`.

**`docs/`:**
- Purpose: narrative guides for setup, architecture, configuration, development, testing, and platform notes.
- Contains: markdown docs used by contributors and future planning phases.
- Key files: `docs/ARCHITECTURE.md`, `docs/CONFIGURATION.md`, `docs/DEVELOPMENT.md`, `docs/TESTING.md`, `docs/GETTING-STARTED.md`, `docs/FORK-GUIDE.md`.

**`.planning/`:**
- Purpose: workflow artifacts, codebase maps, milestone plans, and state tracking.
- Contains: `STATE.md`, `ROADMAP.md`, `PROJECT.md`, milestone phase folders, and generated codebase docs.
- Key files: `.planning/STATE.md`, `.planning/ROADMAP.md`, `.planning/codebase/*.md`, `.planning/milestones/*`.

## Key File Locations

**Entry Points:**
- `home/.chezmoi.yaml.tmpl`: core config and environment detection entry.
- `home/.chezmoiscripts/`: install/bootstrap entry points by platform and lifecycle.
- `home/dot_zshrc.d/`: shell startup fragments loaded in numeric order.
- `README.md`: project overview and contributor starting point.

**Configuration:**
- `home/.chezmoi.yaml.tmpl`: main generated chezmoi config.
- `home/.chezmoidata/`: environment- and platform-specific data.
- `home/.chezmoiexternals/*.toml.tmpl`: external source definitions.
- `home/.chezmoitemplates/`: reusable template snippets and guard logic.

**Core Logic:**
- `home/.chezmoiscripts/linux/`: Linux install and setup scripts.
- `home/.chezmoiscripts/darwin/`: macOS install and setup scripts.
- `home/.chezmoiscripts/windows/`: Windows install and setup scripts.
- `home/dot_zshrc.d/`: shell alias/plugin/session logic.
- `home/private_dot_config/`: app-specific configs such as `i3`, `tmux`, `dunst`, `mise`, `systemd`.

**Testing:**
- `docs/TESTING.md`: current manual validation approach.
- `docs/DEVELOPMENT.md`: dry-run/apply workflow for local verification.
- `.planning/codebase/TESTING.md`: mapped testing patterns.

## Naming Conventions

**Files:**
- Chezmoi source naming pattern encodes target path and permissions: `dot_`, `private_`, `executable_`, `encrypted_*.asc`.
- Template files end in `.tmpl` and often use descriptive kebab-case names.
- Numbered prefixes control execution and shell load order: `099-`, `100-`, `201-`, `530-`, `999-`.

**Directories:**
- Platform grouping first for scripts: `home/.chezmoiscripts/{linux,darwin,unix,windows}`.
- Concern grouping for shell startup: `home/dot_zshrc.d/`.
- Reusable template groups under `home/.chezmoitemplates/{common,linux,darwin,windows,workplace}`.

## Where to Add New Code

**New Feature:**
- Primary code: `home/.chezmoiscripts/<platform>/` for install/setup behavior, or `home/dot_zshrc.d/` for shell startup behavior.
- Tests: validate with `chezmoi apply --dry-run --verbose` and `chezmoi diff`; document smoke checks in `docs/TESTING.md` style.

**New Component/Module:**
- Implementation: `home/private_dot_config/<app>/` for app config, `home/.chezmoitemplates/<group>/` for reusable guards/helpers, or `home/.chezmoidata/` for data-driven package lists.

**Utilities:**
- Shared helpers: `home/.chezmoitemplates/common/` for script helper functions and `home/.chezmoitemplates/<platform>/` for guard snippets.

## Special Directories

**`home/.chezmoiscripts/`:**
- Purpose: executable bootstrap pipeline driven by chezmoi lifecycle hooks.
- Generated: No.
- Committed: Yes.

**`home/.chezmoitemplates/`:**
- Purpose: reusable template snippets used by scripts and configs.
- Generated: No.
- Committed: Yes.

**`home/.chezmoidata/`:**
- Purpose: data-only layer for OS/package/environment settings.
- Generated: No.
- Committed: Yes.

**`home/dot_zshrc.d/`:**
- Purpose: modular shell startup fragments loaded in order.
- Generated: No.
- Committed: Yes.

**`.planning/codebase/`:**
- Purpose: generated codebase map documents for GSD workflows.
- Generated: Yes.
- Committed: Yes.

---

*Structure analysis: Fri Jun 12 2026*
