<!-- generated-by: gsd-doc-writer -->
# 🏠 fabiosouzadev/dotfiles

![macOS](https://img.shields.io/badge/macOS-000000?style=flat-square&logo=apple&logoColor=white)
![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=flat-square&logo=arch-linux&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=flat-square&logo=ubuntu&logoColor=white)
![Windows](https://img.shields.io/badge/WSL-0078D4?style=flat-square&logo=windows&logoColor=white)
![chezmoi](https://img.shields.io/badge/chezmoi-managed-blue?style=flat-square)
![Shell](https://img.shields.io/badge/shell-zsh-green?style=flat-square&logo=gnu-bash)

Cross-platform dotfiles managed by [chezmoi](https://chezmoi.io), supporting **macOS**, **Arch Linux**, **Ubuntu**, and **Windows/WSL**. A fully reproducible development environment with a configured shell, editor, terminal multiplexer, modern CLI tools, AI coding assistants, and encrypted secrets — ready to go in minutes on any machine.

> 🇧🇷 **Português:** Dotfiles cross-platform gerenciados com chezmoi. Setup completo de desenvolvimento com shell, editor, multiplexador, ferramentas CLI modernas, assistentes de IA e segredos criptografados — pronto em minutos em qualquer máquina.

---

## 🚀 Quick Start

Bootstrap a new machine with a single command:

**macOS / Ubuntu / WSL:**

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin init --apply fabiosouzadev
```

**Arch Linux:**

```bash
pacman -S chezmoi
chezmoi init --apply fabiosouzadev
```

> ⚠️ **Note:** Encrypted files (SSH keys, API tokens, VPN certs) require your own [age](https://age-encryption.org) key. See [Prerequisites](#-prerequisites) below.

---

## 📋 Prerequisites

Before running the install command, make sure you have:

| Requirement | Why | Install |
|-------------|-----|---------|
| **git** | Clone the repository | Pre-installed on most systems |
| **chezmoi** | Dotfile manager | `sh -c "$(curl -fsLS get.chezmoi.io)"` |
| **age** | Decrypt secrets (SSH, GPG, API keys) | `brew install age` / `pacman -S age` / `apt install age` |
| **Nerd Font** | Icons in terminal (Starship, eza, yazi) | Installed automatically via scripts |

### 🔑 Age Key Setup

If you're forking this repo, you'll need to generate your own age key:

```bash
age-keygen -o ~/.config/chezmoi/key.txt
```

Then re-encrypt all secrets with your public key. See [docs/FORK-GUIDE.md](docs/FORK-GUIDE.md) for details.

---

## 🛠 Features

### 🐚 Shell
- **Zsh** with [Zinit](https://github.com/zdharma-continuum/zinit) plugin manager
- Modular configuration via numbered files (`dot_zshrc.d/`)
- [Starship](https://starship.rs) cross-shell prompt
- Extensive aliases for git, navigation, and daily tasks

### ✏️ Editor
- **Neovim** (compiled from source on some systems)
- Seamless tmux integration via Navigator.nvim

### 🖥️ Terminal Multiplexer
- **tmux** with [TPM](https://github.com/tmux-plugins/tpm) plugin manager
- 🎨 Catppuccin Mocha theme (v2.1.3)
- Session persistence via tmux-resurrect + tmux-continuum
- Unified navigation with Neovim (Ctrl+h/j/k/l)

### 🔧 Modern CLI Tools
| Tool | Replaces | Purpose |
|------|----------|---------|
| [eza](https://eza.rocks) | `ls` | File listing with icons & git status |
| [bat](https://github.com/sharkdp/bat) | `cat` | Syntax highlighting & line numbers |
| [fd](https://github.com/sharkdp/fd) | `find` | Fast, user-friendly file search |
| [fzf](https://github.com/junegunn/fzf) | — | Fuzzy finder for everything |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | `cd` | Smart directory jumping |
| [Atuin](https://atuin.sh/) | — | Magical shell history synced across devices (auto-installed via binary) |
| [zsh-vi-mode](https://github.com/jeffreytse/zsh-vi-mode) | — | Vi mode for ZSH |
| [lazygit](https://github.com/jesseduffield/lazygit) | — | Terminal UI for git (auto-installed via binary) |
| [yazi](https://yazi-rs.github.io) | — | Terminal file manager |
| [delta](https://github.com/dandavison/delta) | `diff` | Beautiful git diffs (Catppuccin) |
| [starship](https://starship.rs) | PS1 | Cross-shell prompt |
| [direnv](https://direnv.net) | — | Per-directory environment variables |

### 🤖 AI Coding Tools
17+ AI assistants and tools installed via automated scripts, with **OmniRoute** as the central AI API gateway for Claude Code, OpenCode, Aider, Codex, and others.

| Category | Tools |
|----------|-------|
| **Coding Assistants** | Claude Code, Aider, Gemini CLI, OpenCode, Copilot CLI, Cursor CLI, Codex CLI, Amp, Kilo Code, Qwen Code, Kiro, **Hermes Agent** |
| **Spec & Review** | OpenSpec, SpecKit, CodeRabbit |
| **Orchestration** | claude-code-router, GSD, OpenClaude |
| **Local Inference** | Ollama (pre-configured models) |
| **Gateway** | OmniRoute (`http://localhost:20128/v1`, VPS via Tailscale, Caddy on VPS) |

#### OmniRoute
- **Instalação**: via `npm install -g omniroute@<version>` (gerenciado pelo mise/node 24)
- **Config**: `~/.omniroute/.env` (STORAGE_ENCRYPTION_KEY) + `~/.omniroute/config.sql` (config semântica)
- **Backup/Restore**: `omniroute-sync {push|pull|status|doctor}` — sincroniza estado via chezmoi criptografado
- **Atualização**: `omniroute-update [version]` — ex: `omniroute-update 3.8.35`
- **Serviço**: systemd user (`omniroute.service`) ou direto via `omniroute`

#### 🔄 Hermes Sync
- **Backup**: `hermes-sync push` ou alias `hermes-sync-push`
- **Restore**: `hermes-sync pull` ou alias `hermes-sync-pull`
- **O que faz**: Sincroniza **apenas o estado do Hermes Agent** (config, secrets, memories, kanban semantic SQL, skills manifest) via chezmoi criptografado + manifest
- **Localização**: `~/.local/bin/hermes-sync`
- **Escopo**: Backup seletivo do Hermes Agent (exclui state.db, sessions, logs, cache, código fonte)

#### 🔄 OmniRoute Sync
- **Backup**: `omniroute-sync push`
- **Restore**: `omniroute-sync pull`
- **O que faz**: Sincroniza **apenas o estado do OmniRoute** (banco, secrets, config) via chezmoi criptografado
- **Localização**: `~/.local/bin/omniroute-sync`
- **Escopo**: Backup seletivo do OmniRoute (exclui logs, cache, runtime state)

### 📦 Runtime Management
- **[mise](https://mise.jdx.dev)** — Multi-language version manager (Java, Node.js, Go, Python)
- **[Nix/Devenv](https://devenv.sh)** — Isolated, reproducible project environments
- **[Nerd Font](https://www.nerdfonts.com)** — FiraCode Nerd Font (icons in starship, eza, yazi)

### 🖥️ Terminals
| Tool | Config | Notes |
|------|--------|-------|
| **Kitty** | `private_dot_config/kitty/kitty.conf` | Catppuccin Mocha, Fira Nerd Font |
| **WezTerm** | `private_dot_config/wezterm/wezterm.lua.tmpl` | Lua config, WSL default domain |
| **Ghostty** | Installed via packages | — |

### 🌐 Networking & VPN
- **[Tailscale](https://tailscale.com)** — Mesh VPN for VPS/client connectivity
- **OpenVPN3** — Work VPN (Instivo)
- **[Caddy](https://caddyserver.com)** — Reverse proxy on VPS (HTTPS, security headers)

### 🔑 Security & Secrets
- **17 encrypted files** via [age](https://age-encryption.org) (SSH keys, GPG keys, API tokens, VPN certs)
- Git commits signed with GPG
- Conditional git includes for work profiles (Zup, Instivo)
- **[rbw](https://github.com/rbw/rbw)** — Bitwarden CLI for password management

### 🪟 Window Managers (Linux)
- **i3** — Tiling WM for X11
- **Hyprland** — Dynamic tiling for Wayland
- **Niri** — Scrollable tiling for Wayland (modular KDL config)

### 🦊 Browser
- **Firefox Developer Edition** — Templated profiles with custom `user.js`

---

## 📂 Structure

```
.
├── home/                          # 📁 chezmoi source root (via .chezmoiroot)
│   ├── .chezmoi.yaml.tmpl         # ⚙️ Environment detection (OS, work/personal)
│   ├── .chezmoidata/              # 📊 Package lists & data per OS
│   │   ├── darwin/                #    macOS packages (Homebrew, MacPorts)
│   │   ├── linux/                 #    Linux packages (Arch, Ubuntu)
│   │   └── windows/               #    Windows packages (winget, scoop)
│   ├── .chezmoiexternals/         # 🔗 External deps (TPM, Catppuccin, etc.)
│   ├── .chezmoiscripts/           # 🔄 Lifecycle hooks
│   │   ├── darwin/                #    macOS-only (packages, fonts, repos)
│   │   ├── linux/                 #    Linux-only (25 scripts: packages, WM, VPN)
│   │   ├── unix/                  #    Shared (19 scripts: AI tools, mise, lazygit, atuin)
│   │   └── windows/               #    Windows-only (winget, scoop)
│   ├── .chezmoitemplates/         # 🧩 Reusable template guards
│   ├── dot_zshrc.d/               # 🐚 Modular zsh config (numbered 099-999)
│   ├── private_dot_config/        # ⚙️ App configs (~30 apps)
│   │   ├── git/                   #    Git config with conditional includes
│   │   ├── mise/                  #    Runtime version manager
│   │   ├── niri/                  #    Niri WM (modular KDL)
│   │   ├── tmux/                  #    tmux + Catppuccin Mocha
│   │   └── ...                    #    kitty, wezterm, starship, bat, etc.
│   └── private_dot_local/         # 📁 Local data
│       └── environments/          #    Nix/Devenv project environments
├── docs/                          # 📖 Detailed documentation
│   ├── ARCHITECTURE.md            #    System design & data flow
│   ├── CONFIGURATION.md           #    Environment variables & settings
│   ├── GETTING-STARTED.md         #    Detailed installation guide
│   ├── DEVELOPMENT.md             #    Contribution & dev workflow
│   ├── TESTING.md                 #    Testing procedures
│   ├── KEYMAPS.md                 #    Keybinding cheatsheets
│   └── FORK-GUIDE.md              #    How to fork & customize
├── .planning/                     # 🗺 GSD workflow state
│   ├── codebase/                  #    Generated codebase docs (STACK, ARCH, CONCERNS...)
│   └── milestones/                #    Phase plans and progress
└── README.md                      # 👈 You are here
```

---

## 📖 Documentation

For detailed information, see:
- [Architecture](docs/ARCHITECTURE.md) — How the system is designed.
- [Configuration](docs/CONFIGURATION.md) — Available variables and settings.
- [Getting Started](docs/GETTING-STARTED.md) — Detailed setup instructions.
- [Development](docs/DEVELOPMENT.md) — How to contribute.
- [Testing](docs/TESTING.md) — How tests are structured.
- [Fork Guide](docs/FORK-GUIDE.md) — How to fork and customize.
- [Keymaps](docs/KEYMAPS.md) — Tmux, Neovim, and Zsh cheatsheets.

---

## ⌨️ Keymaps

Cheatsheets for tmux, Neovim, and zsh keybindings:

👉 **[docs/KEYMAPS.md](docs/KEYMAPS.md)**

---

## 🍴 Fork & Customize

Want to use these dotfiles as a starting point for your own setup?

👉 **[docs/FORK-GUIDE.md](docs/FORK-GUIDE.md)**

---

## 🎨 Theme

[Catppuccin Mocha](https://github.com/catppuccin/catppuccin) is applied consistently across:
- tmux (status bar + panes)
- git delta (diff highlighting)
- bat (syntax highlighting)
- Starship (prompt accents)

---

## 🙏 Acknowledgments

- [chezmoi](https://chezmoi.io) — Dotfile management done right
- [Catppuccin](https://github.com/catppuccin/catppuccin) — Soothing pastel theme
- [Zinit](https://github.com/zdharma-continuum/zinit) — Flexible Zsh plugin manager
- [Starship](https://starship.rs) — The minimal, blazing-fast prompt
- [mise](https://mise.jdx.dev) — Dev tools, any language, any tool
- [age](https://age-encryption.org) — Simple, modern encryption
- [Tailscale](https://tailscale.com) — Zero-config VPN
- OmniRoute — AI gateway

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/fabiosouzadev">@fabiosouzadev</a>
</p>