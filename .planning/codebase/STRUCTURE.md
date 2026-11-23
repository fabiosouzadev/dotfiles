---
last_mapped_commit: c2840b6cdfa7b1cdccbfa7c030396b2c931328a2
last_mapped_at: 2026-11-23
---
# Codebase Structure

**Analysis Date:** 2026-11-23

## Directory Layout

```
C:\Users\FVSSTAO\.local\share\chezmoi\
├── home/                                 # Chezmoi source directory (templates → ~)
│   ├── .chezmoi.yaml.tmpl               # Environment detection & feature flags
│   ├── .chezmoidata/                    # Platform-specific data (packages, tools)
│   │   ├── ai_tools.yaml                # AI tools (npm, curl, git-based)
│   │   ├── idea.yaml                    # IntelliJ IDEA config
│   │   ├── ollama.yaml                  # Ollama model definitions
│   │   ├── omniroute.yaml               # OmniRoute gateway config
│   │   ├── repos.json                   # Personal repo list for cloning
│   │   ├── darwin/                      # macOS packages & tools
│   │   ├── linux/                       # Linux packages & tools
│   │   │   ├── packages/                # Per-distro packages (archlinux, ubuntu)
│   │   │   ├── kernels.yaml             # Kernel definitions
│   │   │   ├── linux.wm.json            # Window manager configs
│   │   │   └── fonts.yaml               # Font packages
│   │   ├── vps/                         # VPS-specific configs
│   │   ├── windows/                     # Windows packages & tools
│   │   ├── termux/                      # Android Termux packages & tools
│   ├── .chezmoiexternals/               # External sources (Catppuccin, etc)
│   ├── .chezmoiignore.tmpl              # Ignore patterns (dynamic per profile)
│   ├── .chezmoiscripts/                 # Bootstrap lifecycle scripts
│   │   ├── darwin/                      # macOS-specific hooks
│   │   ├── linux/                       # Linux-specific hooks
│   │   ├── unix/                        # Shared Unix/Linux/macOS hooks
│   │   ├── vps/                         # VPS deployment hooks
│   │   ├── windows/                     # Windows-specific hooks (PowerShell)
│   │   └── termux/                      # Android Termux hooks
│   ├── .chezmoitemplates/               # Reusable template guards & snippets
│   │   ├── common/                      # Cross-platform helpers
│   │   │   ├── script_helper            # Colored output functions
│   │   │   ├── script_is_not_ephemeral  # Gate for non-CI/ephemeral
│   │   │   ├── script_is_not_headless   # Gate for GUI environments
│   │   │   ├── script_eval_mise         # Mise runtime eval helper
│   │   │   ├── script_validate_completions_path # Path validation
│   │   │   └── caddyfile_*.tmpl         # Caddy routing templates
│   │   ├── darwin/                      # macOS-specific helpers
│   │   ├── linux/                       # Linux-specific helpers
│   │   ├── windows/                     # Windows-specific helpers
│   │   └── workplace/                   # Work/managed machine helpers
│   ├── dot_zshrc.d/                     # Modular zsh configuration (27 files)
│   │   ├── 099-zshenv.zsh.tmpl          # Environment variables
│   │   ├── 100-install-zinit.zsh.tmpl   # Zinit plugin manager bootstrap
│   │   ├── 101-zinit-plugins.zsh.tmpl   # Plugin loading
│   │   ├── 102-history.zsh.tmpl         # History config
│   │   ├── 103-fzf.zsh.tmpl             # Fuzzy finder
│   │   ├── 104-keybindings.zsh.tmpl     # Keybindings
│   │   ├── 190-zsh-vi-mode.zsh.tmpl     # Vi mode
│   │   ├── 200-aliases.zsh.tmpl         # General aliases
│   │   ├── 200-atuin.zsh.tmpl           # Atuin shell history
│   │   ├── 201-git-aliases.zsh.tmpl     # Git shortcuts
│   │   ├── 302-aider.zsh.tmpl           # Aider CLI config
│   │   ├── 311-ollama.zsh.tmpl          # Ollama setup
│   │   ├── 312-source-composio.zsh.tmpl │ Composio framework
│   │   ├── 504-zup.zsh.tmpl             # Zup workplace tools
│   │   ├── 604-openclaude.zsh.tmpl      # OpenClaude CLI
│   │   ├── 605-omniroute.zsh.tmpl       # OmniRoute client
│   │   ├── 606-hermes.zsh.tmpl          # Hermes aliases
│   │   ├── 999-autoload-compinit.zsh.tmpl # Completion system
│   │   ├── termux.zsh.tmpl              # Termux-specific setup
│   │   ├── encrypted_300-ai-api-keys.zsh.asc     # API keys (GPG)
│   │   ├── encrypted_403-instivo.zsh.asc         # VPN config (GPG)
│   │   ├── encrypted_404-zup-keys.zsh.asc        # Work keys (GPG)
│   │   └── encrypted_405-github-keys.zsh.asc     # GitHub tokens (GPG)
│   ├── dot_bashrc                       # Bash fallback config
│   ├── dot_zprofile.tmpl                # Login shell init
│   ├── dot_zshrc.tmpl                   # Interactive shell loader
│   ├── dot_aws/                         # AWS CLI config
│   ├── dot_camofox/                     # CamoFox (privacy browser)
│   │   └── cookies/                     # Cookie definitions
│   ├── dot_claude/                      # Claude Desktop app settings
│   ├── dot_claude-code-router/          # Claude Code router config
│   ├── dot_codex/                       # Codex CLI config
│   ├── dot_hermes/                      # Hermes agent state
│   │   ├── hindsight/                   # Hindsight AI config
│   │   ├── home/                        # Hermes home directory
│   │   │   ├── documents/               # Document storage
│   │   │   └── dot_config/              # Config (himalaya, etc)
│   │   └── skills/                      # Hermes skills (devops, etc)
│   ├── dot_hindsight/                   # Hindsight AI automation
│   ├── dot_keys/                        # Key management utilities
│   ├── dot_m2/                          # Apple M2 utilities
│   ├── dot_qwen/                        # Qwen LLM config
│   ├── dot_screenlayout/                # Display configs
│   ├── dot_local/
│   │   ├── bin/                         # Executable scripts
│   │   │   ├── hermes-sync              # Hermes state sync script
│   │   │   └── omniroute-sync           # OmniRoute state sync script
│   │   └── opt/stacks/                  # Docker Compose service definitions (13 services)
│   │       ├── caddy/                   # Reverse proxy (TLS, routing)
│   │       ├── camofox/                 # Privacy proxy cache
│   │       ├── hermes/                  # Hermes agent daemon
│   │       ├── hindsight/               # Hindsight automation
│   │       ├── ollama/                  # Local LLM inference
│   │       ├── omniroute/               # AI gateway service
│   │       ├── openknowledge/           # Knowledge management
│   │       ├── openwebui/               # Web UI for Ollama
│   │       ├── postgres/                # PostgreSQL database
│   │       ├── qdrant/                  # Vector database
│   │       ├── redis/                   # Cache/message queue
│   │       ├── synapse/                 # Matrix homeserver
│   │       └── uptime-kuma/             # Uptime monitoring
│   ├── private_dot_config/              # App configs (encrypted)
│   │   ├── aichat/                      # AI chat CLI
│   │   ├── Antigravity/                 # Antigravity (private)
│   │   ├── atuin/                       # Atuin (private)
│   │   ├── autostart/                   # Systemd autostart scripts
│   │   ├── bat/                         # cat clone config
│   │   ├── dunst/                       # Notification daemon
│   │   ├── git/                         # Git config
│   │   ├── glab-cli/                    # GitLab CLI config
│   │   ├── herdr/                       # Hermes dashboard
│   │   ├── homebrew/                    # Homebrew config
│   │   ├── hypr/                        # Hyprland WM config
│   │   ├── i3/                          # i3 WM config
│   │   ├── kitty/                       # Kitty terminal config
│   │   ├── mise/                        # Runtime version manager
│   │   ├── networkmanager_dmenu/        # Network manager menu
│   │   ├── niri/                        # Niri WM config
│   │   ├── opencode/                    # OpenCode CLI config
│   │   ├── picom/                       # Compositor config
│   │   ├── private_systemd/             # Systemd user services
│   │   │   └── private_user/            # User-level services
│   │   │       └── hermes-dashboard.service.tmpl
│   │   ├── rbw/                         # Bitwarden CLI config
│   │   ├── starship.toml                # Starship prompt config
│   │   ├── tmux/                        # tmux multiplexer config
│   │   ├── wezterm/                     # WezTerm terminal config
│   │   ├── greenclip.toml               # Clipboard manager config
│   │   └── xorg.conf.d/                 # X11 configs
│   ├── private_dot_mozilla/             # Firefox profile
│   ├── private_dot_ssh/                 # SSH keys (private/encrypted)
│   ├── private_dot_zup-worker/          # Zup workplace configs
│   ├── private_dot_coderabbit/          # CodeRabbit (code review AI)
│   ├── private_dot_wakatime.cfg.tmpl    # WakaTime config (encrypted at deploy)
├── .claude/                              # Claude Desktop configuration
│   ├── agents/                          # Agent definitions (GSD framework)
│   ├── commands/                        # Custom slash commands
│   ├── gsd-core/                        # GSD orchestration core
│   ├── hooks/                           # Pre/post-tool execution hooks
│   ├── skills/                          # Skill definitions
│   └── scripts/                         # Utility scripts
├── .planning/                           # Project planning (GSD framework)
│   ├── codebase/                        # Codebase analysis docs (this file)
│   ├── graphs/                          # Knowledge graph (MemPalace)
│   └── roadmap.md                       # Phase roadmap
├── README.md                            # Project documentation
└── .git/                                # Git repository metadata
```

## Directory Purposes

**home/:**
- Purpose: Chezmoi source directory; all files here are templates or config manifests deployed to `~` on apply
- Contains: `.chezmoi.yaml.tmpl`, dotfile templates (with `dot_` prefix → `.` and `private_` prefix → encrypt), scripts, data
- Key files: `.chezmoi.yaml.tmpl` (entry point for all config generation)

**.chezmoidata/:**
- Purpose: Store platform-specific package lists, tool definitions, service configs, and feature flags as structured data
- Contains: Per-OS YAML/JSON/TOML files defining `packages`, `ai_tools`, `features`, `ollama`, `omniroute`, `idea`, `repos`
- Key files: `linux/packages/archlinux.yaml`, `darwin/packages.toml`, `ai_tools.yaml` (central AI tool registry)

**.chezmoiscripts/:**
- Purpose: Execution hooks triggered during `chezmoi apply` in OS-specific order
- Contains: Numbered bash scripts (`run_before_NNN`, `run_once_NNN`, `run_onchange_NNN`) and PowerShell scripts for Windows, grouped by OS
- Key files: `unix/run_once_after_590-install-ai-tools.sh.tmpl` (installs AI tools), `vps/run_once_after_530-install-caddy.sh.tmpl` (VPS services)

**.chezmoitemplates/:**
- Purpose: Reusable template snippets included by scripts to avoid duplication
- Contains: Guard functions (`script_is_not_ephemeral`, `script_is_not_headless`, etc), helper macros, Caddyfile templates
- Key files: `common/script_helper` (color-coded output), `common/script_is_not_ephemeral` (gates non-ephemeral tools)

**dot_zshrc.d/:**
- Purpose: Modular zsh configuration loaded at shell startup
- Contains: 23 numbered `.zsh.tmpl` files and 4 encrypted `.asc` credential files
- Key files: `099-zshenv.zsh.tmpl` (env setup), `101-zinit-plugins.zsh.tmpl` (plugin manager), `300-ai-api-keys.zsh.asc` (encrypted keys)

**private_dot_config/:**
- Purpose: Application configuration files that require privacy/encryption
- Contains: Kitty, tmux, nvim, git, mise, Hyprland, systemd service templates, 28 app configurations total
- Key files: `private_systemd/private_user/hermes-dashboard.service.tmpl` (Hermes web UI), `git/config` (git settings)

**dot_local/opt/stacks/:**
- Purpose: Long-running services managed via Docker Compose
- Contains: `compose.yaml.tmpl` for each service (13 total), Dockerfiles, encrypted env files, restore scripts
- Services: caddy, camofox, hermes, hindsight, ollama, omniroute, openknowledge, openwebui, postgres, qdrant, redis, synapse, uptime-kuma
- Key files: `omniroute/compose.yaml.tmpl` (AI gateway), `caddy/Caddyfile.tmpl` (reverse proxy), `dockge/compose.yaml.tmpl` (UI - note: deployed via script, not in stacks/)

**.claude/:**
- Purpose: Claude Desktop application configuration and GSD (Goal-Driven Software Development) framework
- Contains: Agent definitions, hook scripts, GSD orchestration, skill definitions, command definitions
- Key files: `.claude/agents/gsd-codebase-mapper.md` (this codebase-mapping agent), hooks for context isolation

**.planning/:**
- Purpose: Project planning and decision tracking (GSD framework)
- Contains: Phase roadmaps, codebase analysis, decision graphs, learning artifacts
- Key files: `.planning/codebase/` (this analysis), `.planning/graphs/` (MemPalace knowledge graph), `roadmap.md` (phase tracking)

## Key File Locations

**Entry Points:**
- `home/.chezmoi.yaml.tmpl`: Main config file; defines all environment detection and data loading
- `home/dot_zshrc.tmpl`: Zsh entry point; loads modular config from `dot_zshrc.d/`
- `home/dot_bashrc`: Bash fallback for systems without zsh

**Configuration:**
- `home/.chezmoiexternals/git.toml.tmpl`: External sources (Catppuccin theme for delta/git)
- `home/.chezmoiignore.tmpl`: File patterns to exclude from apply (dynamic per profile)

**Core Logic:**
- `home/.chezmoiscripts/unix/run_once_after_590-install-ai-tools.sh.tmpl`: Installs npm/curl/git-based AI tools
- `home/.chezmoiscripts/unix/run_once_after_503-install-mise.sh.tmpl`: Sets up runtime version manager
- `home/.chezmoiscripts/vps/run_once_after_530-install-caddy.sh.tmpl`: Sets up reverse proxy on VPS
- `home/.chezmoiscripts/linux/run_once_before_207-install-nix.sh.tmpl`: Nix package manager setup

**Testing/Validation:**
- `home/.chezmoiscripts/linux/run_once_before_204-init-zsh.sh.tmpl`: Validates zsh installation
- `home/.chezmoitemplates/common/script_validate_completions_path`: Path validation helper

**Shell Configuration:**
- `home/dot_zshrc.d/101-zinit-plugins.zsh.tmpl`: Zinit plugin manager + plugins
- `home/dot_zshrc.d/104-keybindings.zsh.tmpl`: Vi-mode keybindings
- `home/dot_zshrc.d/605-omniroute.zsh.tmpl`: OmniRoute client initialization
- `home/dot_zshrc.d/606-hermes.zsh.tmpl`: Hermes agent CLI shortcuts

**AI/Automation:**
- `home/dot_local/bin/hermes-sync`: Script to sync Hermes agent state
- `home/dot_local/bin/omniroute-sync`: Script to sync OmniRoute gateway state
- `home/dot_local/opt/stacks/omniroute/compose.yaml.tmpl`: OmniRoute Docker Compose

**Encrypted State:**
- `home/dot_zshrc.d/encrypted_300-ai-api-keys.zsh.asc`: AI API keys (GPG-encrypted)
- `home/dot_zshrc.d/encrypted_403-instivo.zsh.asc`: Instivo VPN keys (GPG-encrypted)
- `home/dot_zshrc.d/encrypted_404-zup-keys.zsh.asc`: Zup workplace keys (GPG-encrypted)
- `home/dot_zshrc.d/encrypted_405-github-keys.zsh.asc`: GitHub tokens (GPG-encrypted)
- `home/private_dot_config/private_systemd/private_user/hermes-dashboard.service.tmpl`: Hermes service with secrets
- `home/dot_local/opt/stacks/omniroute/encrypted_dot_env.asc`: OmniRoute credentials (GPG-encrypted)

## Naming Conventions

**Files:**
- `dot_*`: Becomes `.` when deployed (e.g., `dot_zshrc` → `~/.zshrc`)
- `private_dot_*`: Becomes `.` AND is encrypted on disk (e.g., `private_dot_ssh` → `~/.ssh`, always encrypted)
- `encrypted_*`: Specifies file is GPG/age encrypted; chezmoi decrypts on apply
- `*.tmpl`: Templated file processed by chezmoi's Go templating engine
- `.asc`: GPG-encrypted file; suffix indicates encryption format
- `run_before_NNN`, `run_once_NNN`, `run_onchange_NNN`: Script execution hooks with numeric order

**Directories:**
- `.chezmoiscripts/{OS}/`: OS-specific scripts grouped by platform
- `run_before_NNN`, `run_once_NNN`, `run_onchange_NNN`: Numeric prefixes control execution order
- `private_dot_config/`: Config files that should be encrypted
- `dot_local/opt/stacks/`: Docker Compose service definitions (long-running services)
- `dot_local/bin/`: Executable scripts deployed to `~/.local/bin/`

## Where to Add New Code

**New Bootstrap Script:**
- For installation/configuration hooks: Create `home/.chezmoiscripts/{OS}/{run_before_|run_once_|run_onchange_}NNN-{name}.sh.tmpl` or `.ps1.tmpl` for Windows
- Use `{{ template "common/script_helper" . }}` for colored output
- Gate execution with `{{ template "common/script_is_not_ephemeral" . }}` or workplace guards as needed
- Increment `NNN` to control execution order: `001`-`099` pre-setup, `100`-`199` package managers, `200`-`299` core tools, `500`-`599` tools, `600`-`699` services

**New Modular Zsh Config:**
- Create `home/dot_zshrc.d/NNN-{name}.zsh.tmpl`
- Increment `NNN` to load in correct order (099-100 framework, 101-199 plugins, 200-399 aliases/integrations, 500+ workspace, 600+ external, 999 completion)
- Encrypted credentials go in `encrypted_NNN-{name}.zsh.asc` with same number

**New Application Config:**
- Create `home/private_dot_config/{app_name}/` subdirectory
- If sensitive (passwords, tokens): Use `.tmpl` files; encrypt via `chezmoi encrypt` or mark `private_`
- Register path in `.chezmoiignore.tmpl` if should not be deployed

**New Platform-Specific Data:**
- Add package/tool definitions to `home/.chezmoidata/{os}/packages.yaml` or `home/.chezmoidata/ai_tools.yaml`
- Use feature flags (`$.features.*`) to gate conditional installation
- Reference in bootstrap scripts via `{{ range .packages.* }}` or `{{ range .ai_tools.npm }}`

**New Docker Compose Service:**
- Create `home/dot_local/opt/stacks/{service_name}/` directory
- Create `compose.yaml.tmpl` with service definition
- Add optional `Dockerfile` if custom image needed
- Create `.env.asc` for encrypted environment variables if needed
- Create `Dockerfile` or other supporting files if needed
- Add bootstrap script `home/.chezmoiscripts/vps/run_once_after_NNN-install-{service_name}.sh.tmpl` to deploy
- Reference service name in Caddy config (`home/.chezmoitemplates/common/caddyfile_*.tmpl`) if public-facing

**New Encrypted File:**
- Create plaintext version
- Run `chezmoi encrypt ~/path/to/file` to generate `.asc` version
- Replace plaintext with `.asc` version in repo
- Chezmoi will auto-decrypt on apply

## Special Directories

**`.chezmoiscripts/{os}/` with Ordering:**
- `001`-`099`: Pre-setup (kernels, drivers, package managers)
- `100`-`199`: Package manager setup
- `200`-`299`: Core runtime installation (zsh, nix, fzf)
- `500`-`599`: Tools and applications (mise, Ollama, IDEA, Atuin)
- `600`-`699`: Services and long-running daemons (Hermes, OmniRoute, Caddy)

**`.chezmoitemplates/`:**
- **Not deployed to `~`** — Used only for templating includes
- Each subdirectory matches OS or use-case (darwin, linux, windows, common, workplace)
- Files contain shell guards or macro definitions

**`private_dot_config/private_systemd/private_user/`:**
- Systemd user services deployed to `~/.config/systemd/user/`
- Each `.service.tmpl` file templated with feature flags and paths
- Services auto-reloaded by `systemctl --user daemon-reload` in deploy scripts

**`.chezmoiignore.tmpl`:**
- Patterns to exclude from `chezmoi apply`
- Generated dynamically based on ephemeral/headless/vps profile (e.g., GUI services excluded on headless)

**`dot_local/opt/stacks/*/restore/`:**
- Backup/restore scripts for persistent data (databases, configs)
- Synced externally via `*-sync` scripts (e.g., `omniroute-sync`, `hermes-sync`)
- Encrypted manifest files track what's been synced

## Architecture Guidance for New Additions

**Modular, not monolithic:** Split config into separate `.zsh` modules by concern (aliases, keybinds, integrations). Never append to a 1000-line config file.

**Template first, then static:** Use Go templating for conditional deployment based on OS, profile, or feature flags. Static files are for configs that don't vary.

**Encrypt sensitive data:** Any file with credentials, tokens, or private info must be `.asc` encrypted. Use `chezmoi encrypt` to generate.

**Use data-driven scripts:** Define packages/tools in `.chezmoidata/` and loop over them in scripts. Don't hardcode tool lists.

**Guard bootstrap scripts:** Every script should gate on `{{ template "common/script_is_not_ephemeral" . }}` or appropriate workplace guard to prevent noise in CI/containers.

**Maintain numerical ordering:** Use 3-digit prefixes in script/module names to keep execution order clear. Document ordering scheme in comments.

**Cross-platform support:** Scripts in `home/.chezmoiscripts/` are OS-specific (unix/ for POSIX, windows/ for PowerShell); ensure proper file extensions (.sh.tmpl vs .ps1.tmpl)

---

*Structure analysis: 2026-11-23*
