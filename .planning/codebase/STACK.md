# Technology Stack

> Last mapped: 2026-05-07

## Core Technology

| Component | Technology | Version/Details |
|-----------|-----------|-----------------|
| **Dotfile Manager** | [chezmoi](https://chezmoi.io) | Current (installed via `get.chezmoi.io`) |
| **Template Engine** | Go text/template | Built into chezmoi |
| **Encryption** | [age](https://age-encryption.org) | Asymmetric encryption with recipient key |
| **Primary Shell** | Zsh | With Zinit plugin manager |
| **Secondary Shell** | Bash | Fallback/compatibility |
| **Editor** | Neovim (nvim) | Compiled from source on some machines |

## Languages & Templating

- **Go Templates** (`.tmpl` suffix) — Used extensively for conditional OS/environment logic
- **Shell Script** (bash/zsh) — Installation scripts, hook scripts
- **YAML** — Data files (`.chezmoidata/`), Ollama config, package lists
- **JSON** — Repos data, window manager packages, AI tool configs
- **TOML** — Externals config, package lists, starship prompt
- **KDL** — Niri window manager config
- **Lua** — WezTerm terminal config

## Runtime Version Manager

| Tool | Purpose | Config File |
|------|---------|-------------|
| **mise** | Multi-language runtime manager | `private_dot_config/mise/config.toml.tmpl` |

### Managed Runtimes (via mise)
- **Java**: latest + 21
- **Node.js**: 24
- **Go**: 1.25.1
- **npm packages**: npx, prettier

## Package Managers

| OS | Package Manager | Data Source |
|----|----------------|-------------|
| **macOS** | MacPorts (primary), Homebrew (secondary) | `.chezmoidata/darwin/packages.toml` |
| **Arch Linux** | pacman + paru (AUR helper) | `.chezmoidata/linux/packages/archlinux.yaml` |
| **Ubuntu** | apt | `.chezmoidata/linux/packages/ubuntu.json` |
| **Windows** | winget + scoop | `.chezmoidata/windows/packages.yaml` |

## Shell Ecosystem

### Zsh Configuration (`dot_zshrc.d/`)
Modular numbered configuration files sourced in order:

| Range | Purpose | Examples |
|-------|---------|----------|
| 099-100 | Environment + Plugin Manager (Zinit) | `099-zshenv.zsh.tmpl`, `100-install-zinit.zsh.tmpl` |
| 101-104 | Plugins, History, FZF, Keybindings | `101-zinit-plugins.zsh.tmpl`, `102-history.zsh.tmpl` |
| 200-201 | Aliases (general + git) | `200-aliases.zsh.tmpl`, `201-git-aliases.zsh.tmpl` |
| 300 | AI API keys (encrypted) | `encrypted_300-ai-api-keys.zsh.age` |
| 301-311 | Tool integrations (mise, direnv, zoxide, starship, ollama) | `303-mise.zsh.tmpl`, `309-eval-zoxide.zsh.tmpl` |
| 400-405 | Work-specific keys (encrypted) | `encrypted_403-instivo.zsh.age`, `encrypted_404-zup-keys.zsh.age` |
| 504 | zup utility function | `504-zup.zsh.tmpl` |
| 603 | OpenClaude integration | `603-openclaude.zsh.tmpl` |
| 999 | Autoload/compinit | `999-autoload-compinit.zsh.tmpl` |

### Zinit Plugins
Plugin manager: **Zinit** — installed via git clone in `100-install-zinit.zsh.tmpl`

## Terminal Emulators

| Terminal | Config Location | Format |
|----------|----------------|--------|
| **Kitty** | `private_dot_config/kitty/kitty.conf` | INI-like |
| **WezTerm** | `private_dot_config/wezterm/wezterm.lua.tmpl` | Lua (templated) |
| **Ghostty** | Installed via packages | — |

## Terminal Multiplexer

**tmux** with TPM (Tmux Plugin Manager)
- Config: `private_dot_config/tmux/tmux.conf.tmpl`
- Theme: Catppuccin Mocha (v2.1.3)
- Plugins: tpm, tmux-yank, tmux-resurrect, tmux-continuum
- Navigator.nvim integration for seamless vim/tmux navigation

## CLI Tools

| Tool | Purpose |
|------|---------|
| `eza` | Modern `ls` replacement |
| `bat` | Cat with syntax highlighting |
| `fd` | Modern `find` replacement |
| `fzf` | Fuzzy finder |
| `zoxide` | Smart `cd` replacement |
| `lazygit` | Terminal UI for git |
| `yazi` | Terminal file manager |
| `starship` | Cross-shell prompt |
| `delta` | Git diff pager (Catppuccin theme) |
| `direnv` | Directory-specific environment |
| `jq` | JSON processor |
| `btop`/`htop` | System monitors |
| `k9s` | Kubernetes TUI |

## Prompt & Theme

- **Prompt**: Starship (`private_dot_config/starship.toml`)
- **Color Theme**: Catppuccin Mocha (applied across git-delta, tmux, bat, and other tools)

## Chezmoi Configuration

| Feature | Value |
|---------|-------|
| **Editor** | nvim |
| **Encryption** | age |
| **Age identity** | `~/.config/chezmoi/key.txt` |
| **Age recipient** | `age1dv82ds88umzeuuwlayrpwdceflj96femz6ryuqhh8jgxtrl6vvgs0k4mmy` |
| **Diff format** | git |
| **Diff pager** | delta |
| **Root** | `home` (via `.chezmoiroot`) |

## Dependencies (External via `.chezmoiexternals/`)

| External | Type | Source |
|----------|------|--------|
| Catppuccin gitconfig | file | GitHub (catppuccin/delta) |
| TPM (Tmux Plugin Manager) | git-repo | GitHub (tmux-plugins/tpm) |
| i3 themes | conditional | via `.chezmoiexternals/i3.toml.tmpl` |
| Firefox profiles | conditional | via `.chezmoiexternals/firefox.toml.tmpl` |
| Wallpapers | conditional | via `.chezmoiexternals/wallpapers.toml.tmpl` |
| Icon packs | conditional | via `.chezmoiexternals/icons.toml.tmpl` |
