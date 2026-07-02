# 🏠 fabiosouzadev/dotfiles

![macOS](https://img.shields.io/badge/macOS-000000?style=flat-square&logo=apple&logoColor=white)
![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=flat-square&logo=arch-linux&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=flat-square&logo=ubuntu&logoColor=white)
![Windows](https://img.shields.io/badge/WSL-0078D4?style=flat-square&logo=windows&logoColor=white)
![chezmoi](https://img.shields.io/badge/chezmoi-managed-blue?style=flat-square)
![Shell](https://img.shields.io/badge/shell-zsh-green?style=flat-square&logo=gnu-bash)

Cross‑platform dotfiles managed by [chezmoi](https://chezmoi.io), providing a fully reproducible development environment for **macOS**, **Arch Linux**, **Ubuntu**, and **Windows/WSL**. The repository bundles a tuned shell, editor, terminal multiplexer, modern CLI tools, AI coding assistants, encrypted secrets, and service orchestration (OmniRoute, Hermes) – ready to bootstrap in minutes.

> 🇧🇷 **Português:** Dotfiles multiplataforma gerenciados com chezmoi. Ambiente de desenvolvimento completo com shell, editor, multiplexador, ferramentas CLI modernas, assistentes de IA e segredos criptografados – pronto em minutos em qualquer máquina.

---

## 🚀 Quick Start

Bootstrap a new machine with a single command:

### macOS / Ubuntu / WSL
```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin init --apply fabiosouzadev
```

### Arch Linux
```bash
pacman -S chezmoi
chezmoi init --apply fabiosouzadev
```

> ⚠️ **Note:** Encrypted files (SSH keys, API tokens, VPN certificates, etc.) require your own **age** key. See the *Prerequisites* section below.

---

## 📋 Prerequisites

Before running the install command, ensure you have:

| Requirement | Why | Install |
|-------------|-----|---------|
| **git** | Clone the repository | Pre‑installed on most systems |
| **chezmoi** | Dotfile manager | `sh -c "$(curl -fsLS get.chezmoi.io)"` |
| **age** | Decrypt secrets (SSH, GPG, API keys) | `brew install age` / `pacman -S age` / `apt install age` |
| **Nerd Font** | Icons in terminal (Starship, eza, yazi) | Installed automatically via bootstrap scripts |

### 🔑 Setting up your age key (if forking)
If you fork this repo, generate your own age key and re‑encrypt all secrets:

```bash
age-keygen -o ~/.config/chezmoi/key.txt
# Then follow the instructions in docs/FORK-GUIDE.md
```

---

## 🏗️ Repository Overview

```
.
├── home/                     # ← chezmoi source root (see .chezmoiroot)
│   ├── .chezmoi.yaml.tmpl   # ⚙️ Environment detection (OS, work/personal)
│   ├── .chezmoidata/        # 📊 Package lists & data per OS
│   │   ├── darwin/          #    macOS packages (Homebrew, MacPorts)
│   │   ├── linux/           #    Linux packages (Arch, Ubuntu)
│   │   └── windows/         #    Windows packages (winget, scoop)
│   ├── .chezmoiexternals/   # 🔗 External dependencies (TPM, Catppuccin, etc.)
│   ├── .chezmoiscripts/     # 🔄 Lifecycle hooks (pre/post install, OS‑specific)
│   │   ├── darwin/          #    macOS‑only
│   │   ├── linux/           #    Linux‑only (≈25 scripts)
│   │   ├── unix/            #    Shared (≈19 scripts: AI tools, mise, lazygit, atuin…)
│   │   └── windows/         #    Windows‑only
│   ├── .chezmoitemplates/   # 🧩 Reusable template guards
│   ├── dot_zshrc.d/         # 🐚 Modular zsh configuration (numbered 099‑999)
│   ├── private_dot_config/  # ⚙️ Application configs (~30 apps)
│   │   ├── git/             #    Git config with conditional includes
│   │   ├── mise/            #    Runtime version manager
│   │   ├── tmux/            #    tmux + Catppuccin Mocha
│   │   └── …                #    kitty, wezterm, starship, bat, etc.
│   └── private_dot_local/   # 📁 Local data
│       └── environments/    #    Nix/Devenv project environments
├── docs/                    # 📖 Detailed documentation
│   ├── ARCHITECTURE.md
│   ├── CONFIGURATION.md
│   ├── GETTING-STARTED.md
│   ├── DEVELOPMENT.md
│   ├── TESTING.md
│   ├── KEYMAPS.md
│   └── FORK-GUIDE.md
├── .planning/               # 🗺 GSD workflow state (stack, concerns, milestones)
└── README.md                # 👈 You are here
```

### 🔐 Secrets Management
All sensitive data (SSH keys, API tokens, VPN certificates, etc.) are encrypted with **age** and managed by chezmoi’s built‑in encryption (`chezmoi add --encrypt`).  
The public age key must be placed at `~/.config/chezmoi/key.txt` on each host.  
Encrypted files live under `home/` with the `.asc` suffix (e.g., `dot_ssh/encrypted_private_id_ed25519_vps.asc`).

### 🤖 AI Coding Infrastructure
- **OmniRoute** – central API gateway for local and remote LLMs (Claude Code, OpenCode, Aider, Codex, etc.).  
  *Installed via `mise` (Node 24) and configured via `~/.omniroute/.env` + `~/.omniroute/config.sql`.*  
  *Backup/restore of selective state (config, secrets, semantic SQL) is handled by the `omniroute-sync` tool (`push|pull|status|doctor`).*
- **Hermes Agent** – the assistant you are currently interacting with; its own encrypted state (memories, skills, config) is synchronized via `hermes-sync`.
- Numerous other AI tools are installed automatically (see the **AI Coding Tools** table in the original README).

### ⚙️ Runtime & Development Tooling
- **[mise](https://mise.jdx.dev)** – version manager for Node, Java, Go, Python, etc.  
- **Nix/Devenv** – isolated, reproducible project environments (optional).  
- **Direnv** – per‑directory environment variables.  
- **Atuin** – magical, synchronized shell history.  
- **LazyGit, yazi, delta, eza, bat, fd, fzf, zoxide** – modern CLI replacements.  
- **Starship** – cross‑shell prompt.  
- **Zinit** – Zsh plugin manager.  

### 🧪 Development & Contribution
See the dedicated documents in `docs/`:
- **DEVELOPMENT.md** – contributing guide, coding style, and workflow.
- **TESTING.md** – how tests are structured and executed.
- **FORK-GUIDE.md** – how to fork and customize this dotfiles repo.
- **CONFIGURATION.md** – reference for environment variables and toggles.
- **KEYMAPS.md** – cheat‑sheet for tmux, Neovim, and Zsh bindings.

### 📖 Additional Documentation
- **ARCHITECTURE.md** – high‑level design and data flow.
- **GETTING-STARTED.md** – step‑by‑step installation guide.
- **HERMES-BACKUP.md** & **OMNIROUTE-BACKUP.md** – details on the selective backup model for Hermes and OmniRoute.
- **WINDOWS-SETUP.md** – Windows/WSL‑specific notes.

### 🙏 Acknowledgments
- [chezmoi](https://chezmoi.io) – dotfile management done right  
- [Catppuccin Mocha](https://github.com/catppuccin/catppuccin) – unifying pastel theme  
- [Zinit](https://github.com/zdharma-continuum/zinit) – flexible Zsh plugin manager  
- [Starship](https://starship.rs) – minimal, blazing‑fast prompt  
- [mise](https://mise.jdx.dev) – dev tools, any language, any tool  
- [age](https://age-encryption.org) – simple, modern encryption  
- [Tailscale](https://tailscale.com) – zero‑config VPN  
- OmniRoute – AI gateway  
- Hermes Agent – personal AI assistant  

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/fabiosouzadev">@fabiosouzadev</a>
</p>