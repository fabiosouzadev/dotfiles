---
last_mapped_commit: d1d1c1c967319d6aa2852d6caaee2123acced521
last_mapped_at: 2026-11-23
---
# Technology Stack

**Analysis Date:** 2026-11-23

## Languages

**Primary:**
- **Bash/Shell (sh, bash, zsh)** - Primary scripting language for chezmoi automation, dotfiles management, and system bootstrap
- **Zsh** - Interactive shell configuration and aliases; primary shell environment with zinit plugin manager
- **Go** - Chezmoi itself is built in Go; used for template rendering and file management
- **YAML/TOML** - Configuration files, data files, and chezmoi templates
- **JSON** - Configuration for Claude Code (`.claude/settings.json.tmpl`), Auth configs, and application settings
- **PowerShell (.ps1)** - Windows-specific package installation scripts (`home/.chezmoiscripts/windows/`)
- **TypeScript/JavaScript** - Node.js-based tools and hooks (Claude Code hooks in `.claude/hooks/`)

**Secondary:**
- **Python** - Through tools like Atuin, WakaTime CLI, and various development utilities
- **Lua** - Configuration for Neovim and other Lua-based tools

## Runtime

**Environment:**
- **Mise (Multi-language version manager)** - Manages Node.js, Python, Rust, and other language runtimes
  - Installation: `home/.chezmoiscripts/unix/run_once_after_503-install-mise.sh.tmpl`
  - Node.js: LTS version via mise; used for OmniRoute, AI tools, and npm packages
  - Path: `~/.local/share/mise/shims` and `~/.local/share/mise/installs`

**Package Managers:**
- **npm** - Global Node.js packages for AI tools and CLI utilities
  - Lockfile: Implicit from package specs in `home/.chezmoidata/ai_tools.yaml`
- **Linux Distribution Package Managers:**
  - **pacman** (Arch Linux) - via paru for AUR packages
  - **apt** (Ubuntu/Debian)
  - **Homebrew** (macOS)
  - **MacPorts** (macOS alternative)
- **Scoop** (Windows) - Windows package manager with buckets: main, extras, versions, nerd-fonts
- **Winget** (Windows) - Microsoft's package manager for modern Windows apps
- **Nix** (Linux optional) - Declarative package manager on select platforms

## Frameworks

**Core Infrastructure:**
- **Chezmoi** (`https://chezmoi.io`) - Dotfiles management, template rendering, encrypted secret handling
  - Configuration: `home/.chezmoi.yaml.tmpl` - Complex environment detection and feature flags
  - Encryption: GPG-based encryption with recipient: `E691C031009FB1DAA3A25125212D516F623C5747`

**Terminal & Shell:**
- **Zsh** with **Zinit** - Zsh plugin manager for modular plugin loading
  - Plugins: Defined in `home/dot_zshrc.d/101-zinit-plugins.zsh.tmpl`
- **Starship** - Minimal prompt styling
- **Atuin** - Shell history management with sync
- **Fzf** - Fuzzy finder for file/command selection
- **Yazi** - Terminal file manager
- **Eza** - Modern `ls` replacement
- **LazGit** - Interactive git UI

**Testing & Quality:**
- Not detected in this dotfiles repository

**Build/Dev:**
- **Just** - Command runner for tasks
- **Make** - Traditional build automation
- **Git** - Version control with Git Bash/Git CLI integration

## Key Dependencies

**Critical AI/Coding Tools (NPM & Curl):**
- **OmniRoute** (`3.8.46` via source) - Smart AI router with auto-fallback; Node.js-based
  - Config: `home/.chezmoidata/omniroute.yaml`
  - Service: `home/private_dot_config/private_systemd/private_user/omniroute.service.tmpl`
  - Environment: `~/.omniroute/.env`
- **AI Harness Tools** (NPM global):
  - `@opengsd/gsd-core@latest` - GSD coding orchestrator framework
  - `aider` - Pair programming AI via curl installer
  - `claude` - Claude AI CLI via curl installer
  - `@qwen-code/qwen-code` - Qwen code completion
  - `@kilocode/cli` - Kilo code assistant
  - `@sourcegraph/amp@latest` - Sourcegraph Cody
  - `@openai/codex@latest` - OpenAI Codex CLI
  - `@github/copilot@prerelease` - GitHub Copilot CLI
  - Other tools: OpenCode, Freebuff, KimChi, Beads
- **Ollama** - Local LLM hosting
  - Models: qwen2.5-coder:0.5b, qwen2.5-coder:1.5b, gemma4:e2b, gemma4:e4b
  - Config: `home/.chezmoidata/ollama.yaml`
  - Env: `OLLAMA_HOST=127.0.0.1:11434`, context length 8192, CPU-only

**Infrastructure:**
- **Tailscale** - Zero-trust VPN and mesh networking for remote access
- **Caddy** (VPS only) - Reverse proxy with automatic TLS
  - Config: `home/.chezmoitemplates/common/caddyfile_hermes.tmpl`
- **Dockge** (VPS) - Docker GUI management
- **Hermes** - Personal AI assistant and automation orchestrator
  - Dashboard service: `home/private_dot_config/private_systemd/private_user/hermes-dashboard.service.tmpl`
  - Port: 9119 (default), domain: `hermes.fabiosouzadev.duckdns.org`
  - Feature flags in `home/.chezmoidata/vps/features.yaml`
- **AgentMemory** - Persistent memory server for AI coding agents (VPS only)
  - NPM: `@agentmemory/agentmemory`
- **Composio** - Tool integration framework for AI agents (optional, VPS)
- **CamoFox** (VPS) - Browser automation/privacy tool

**Development Utilities:**
- **GitHub CLI** (`gh`) - GitHub API automation
- **GitLab CLI** (`glab`) - GitLab API automation
- **DBeaver** - Database client
- **Postman** - API testing tool
- **Bruno** - API client alternative
- **Obsidian** - Note-taking application
- **Delta** - Git diff enhancer
- **WakaTime CLI** - Activity tracking
- **Cursor CLI** - Cursor IDE CLI wrapper
- **CodeRabbit CLI** - Code review automation
- **SpecKit** - OpenAPI/Spec tooling
- **LocalSend** - LAN file sharing
- **Brave Browser** - Privacy-focused Chromium browser

**Docker/Virtualization:**
- **Docker** - Container runtime (Linux)
- **Podman** - Podman container runtime (Linux alternative)
- **Docker Compose** / **Podman Compose** - Multi-container orchestration
- **Nerdctl** - containerd CLI compatibility
- **Distrobox** - Container-based distro environment
- **QEMU/KVM** - Full virtualization
- **Libvirt** - Virtualization management

**Cryptography & Security:**
- **age** (`age-encryption.org`) - Modern encryption for secrets
- **GPG** - GNU Privacy Guard for encryption/decryption
  - Windows path: `~/scoop/apps/gnupg/current/bin/gpg.exe`
  - Linux: `gpg` or `gpg2`
- **Bitwarden** - Password manager
- **SOPS** - Secrets Operations for encrypted file management

**Fonts:**
- **Nerd Fonts** - Monospace fonts with icon glyphs for terminal and editor
  - Arch: via `nerd-fonts` scoop bucket
  - Darwin/Linux: Custom font installation scripts

## Configuration

**Environment:**
- **Chezmoi template engine** (`Go text/template`) - Conditional rendering based on OS, profile, and features
  - Variables: `$profile`, `$ephemeral`, `$headless`, `$interactive`, `$isVps`, `$osID`, `$hostname`
  - Conditionals for: CI environments, cloud IDEs, containers, WSL, SSH, managed vs personal, VPS vs local
- **Feature flags** (`home/.chezmoidata/` and `home/.chezmoi.yaml.tmpl`):
  - `features.ai.harness` - Install coding assistant tools
  - `features.ai.hermes.enabled` - Enable Hermes personal assistant
  - `features.ai.hermes.dashboard.enabled` - Hermes web dashboard
  - `features.ai.hermes.agentmemory.enabled` - AgentMemory server
  - `features.ollama.install` - Install Ollama LLM
  - `features.systemd.enabled` - Systemd user services
  - Environ overrides: `CHEZMOI_*` prefix env vars

**Build:**
- **Mise configuration** (`.tool-versions` via mise install)
- **GPG encryption** in chezmoi for secrets:
  - Encrypted files: `home/dot_keys/encrypted_*.txt.asc`
  - Recipient: `E691C031009FB1DAA3A25125212D516F623C5747`
  - Args: `--quiet`

## Platform Requirements

**Development:**
- Bash/POSIX shell support (WSL on Windows, native on Linux/macOS)
- Git 2.0+
- Chezmoi binary in PATH
- Age key pair for secret decryption
- Nerd Font for terminal icons

**Production (VPS):**
- Ubuntu Linux on Oracle Cloud (auto-detected as `instance-*` hostname)
- Systemd user services enabled
- Node.js LTS via mise
- 2+ CPU cores recommended
- Outbound HTTPS (443) for Caddy ACME/TLS

**Supported OS:**
- **Linux**: Arch Linux, Ubuntu, Debian, Termux (Android)
- **macOS**: Darwin (Intel & ARM/Apple Silicon via linuxonmac detection)
- **Windows**: Windows 11 (via WSL or native PowerShell)
- **Docker/Containers**: Codespaces, Gitpod, Replit, Distrobox, Lima VM, Docker containers

---

*Stack analysis: 2026-11-23*
