# Technology Stack

**Analysis Date:** 2026-06-12

## Core Technology

| Component | Technology | Details |
|-----------|-----------|---------|
| **Dotfile Manager** | [chezmoi](https://chezmoi.io) | Go-based, installed via `get.chezmoi.io` |
| **Template Engine** | Go text/template | Built into chezmoi (`.tmpl` suffix) |
| **Encryption** | [age](https://age-encryption.org) | Asymmetric; GPG also used |
| **Source Root** | `home/` | Configured via `.chezmoiroot` at repo root |
| **Config Output** | `~/.config/chezmoi/chezmoi.yaml` | Generated from `home/.chezmoi.yaml.tmpl` |

## Languages & Templating

- **Go Templates** (`.tmpl`) — Extensive conditional logic for OS, hostname, workplace detection
- **Shell Script** (bash/zsh) — Installation scripts in `.chezmoiscripts/`, hook scripts
- **YAML** — Package lists, Ollama config, AI tools manifest, feature flags
- **JSON** — Repos data, window manager packages, AI tool configs
- **TOML** — macOS Homebrew packages, starship prompt, greenclip
- **KDL** — Niri window manager config
- **Lua** — WezTerm terminal config
- **INI** — Kitty config, Firefox profiles, picom

## Shell Ecosystem

**Primary Shell:** Zsh
**Plugin Manager:** Zinit (installed via git clone in `100-install-zinit.zsh.tmpl`)
**Modular Config:** `dot_zshrc.d/` — Numbered `.zsh` files sourced in order by `dot_zshrc.tmpl`

| Range | Purpose | Key Files |
|-------|---------|-----------|
| 099–100 | Environment + Zinit install | `099-zshenv.zsh.tmpl`, `100-install-zinit.zsh.tmpl` |
| 101–104 | Plugins, History, FZF, Keybindings | `101-zinit-plugins.zsh.tmpl`, `103-fzf.zsh.tmpl` |
| 190 | Zsh Vi Mode | `190-zsh-vi-mode.zsh.tmpl` |
| 200–201 | Aliases | `200-aliases.zsh.tmpl`, `201-git-aliases.zsh.tmpl` |
| 301 | OpenClaw source | `301-source-openclaw.zsh.tmpl` |
| 302 | Aider | `302-aider.zsh.tmpl` |
| 311 | Ollama | `311-ollama.zsh.tmpl` |
| 504 | Zup work keys | `504-zup.zsh.tmpl` |
| 604 | OpenClaude | `604-openclaude.zsh.tmpl` |
| 605 | OmniRoute | `605-omniroute.zsh.tmpl` |
| 999 | Autoload/compinit | `999-autoload-compinit.zsh.tmpl` |

**Fallback Shell:** Bash — `dot_bashrc.tmpl`

## Runtime Version Manager

**Tool:** [mise](https://mise.jdx.dev/) — Multi-language runtime manager
**Config:** `private_dot_config/mise/config.toml.tmpl`

### Managed Runtimes:
- **Node.js**: LTS + latest
- **Java**: latest + 21
- **Go**: 1.25.1
- **Python**: latest
- **uv**: latest
- **npm global tools**: npx, prettier

### Isolated Dev Environments (Nix/Devenv)
Located in `private_dot_local/private_share/environments/`:
- **Projects**: `instivo-ms-auth`, `instivo-ms-fornecedor`, `instivo-receiving-conference-ms`, `novo-site-puroar`
- **Languages**: Java, Node.js, PHP, Python
- **Config**: `devenv.yaml` per project

## Package Managers

| OS | Primary | Secondary | Data Source |
|----|---------|-----------|-------------|
| **Arch Linux** | pacman (core/extra/multilib) | paru (AUR) | `.chezmoidata/linux/packages/archlinux.yaml` |
| **Ubuntu** | apt + PPAs + custom sources | — | `.chezmoidata/linux/packages/ubuntu.json` |
| **macOS** | Homebrew (brew/cask/tap) | MacPorts, MAS | `.chezmoidata/darwin/packages.toml` |
| **Windows** | winget | Scoop | `.chezmoidata/windows/packages.yaml` |

### Cross-platform Universal Binary Install Pattern
Scripts in `home/.chezmoiscripts/unix/` download pre-compiled binaries to `~/.local/bin/` (no sudo). Covers: lazygit, delta, glab, etc.

## Terminal & Multiplexer

| Tool | Config | Notes |
|------|--------|-------|
| **Kitty** | `private_dot_config/kitty/kitty.conf` | Catppuccin Mocha theme, Fira Nerd Font Mono |
| **WezTerm** | `private_dot_config/wezterm/wezterm.lua.tmpl` | Lua config, WSL default domain, Rosé Pine Moon theme |
| **Ghostty** | Installed via packages | — |
| **tmux** | `private_dot_config/tmux/tmux.conf.tmpl` | TPM, Catppuccin Mocha, vim navigation integration |

## CLI Tools

| Tool | Purpose | Config |
|------|---------|--------|
| `eza` | Modern `ls` | — |
| `bat` | Cat with syntax highlighting | Catppuccin theme |
| `fd` | Modern `find` | — |
| `fzf` | Fuzzy finder | `103-fzf.zsh.tmpl` |
| `zoxide` | Smart `cd` | `309-eval-zoxide.zsh.tmpl` |
| `lazygit` | Terminal git UI | — |
| `yazi` | Terminal file manager | — |
| `starship` | Cross-shell prompt | `private_dot_config/starship.toml` |
| `delta` | Git diff pager | Catppuccin Mocha, side-by-side |
| `direnv` | Dir-specific env | `.envrc` |
| `jq` | JSON processor | — |
| `btop`/`htop` | System monitors | — |
| `k9s` | Kubernetes TUI | — |
| `just` | Command runner | — |
| `atuin` | Shell history | `200-atuin.zsh.tmpl` |
| `fastfetch` | System info | — |
| `obsidian` | Notes | — |

## Prompt & Theme

- **Prompt**: Starship (`private_dot_config/starship.toml`)
- **Color Theme**: Catppuccin Mocha (git-delta, tmux, bat, kitty, wezterm)

## Chezmoi Configuration

| Feature | Value |
|---------|-------|
| **Editor** | nvim |
| **Encryption** | age + GPG |
| **Age identity** | `~/.config/chezmoi/key.txt` |
| **GPG key** | `E691C031009FB1DAA3A25125212D516F623C5747` |
| **Diff format** | git |
| **Diff pager** | delta |
| **Root** | `home` (via `.chezmoiroot`) |

## Dependencies (External)

| External | Type | Source |
|----------|------|--------|
| Catppuccin gitconfig | file | GitHub (catppuccin/delta) |
| TPM (Tmux Plugin Manager) | git-repo | GitHub (tmux-plugins/tpm) |
| i3 themes | conditional | `.chezmoiexternals/i3.toml.tmpl` |
| Firefox profiles | conditional | `.chezmoiexternals/firefox.toml.tmpl` |
| Wallpapers | conditional | `.chezmoiexternals/wallpapers.toml.tmpl` |
| Icon packs | conditional | `.chezmoiexternals/icons.toml.tmpl` |

## Data Sources

| File | Format | Purpose |
|------|--------|---------|
| `.chezmoidata/ai_tools.yaml` | YAML | AI tool definitions (npm packages + curl installs) |
| `.chezmoidata/ollama.yaml` | YAML | Ollama config, env vars, model list |
| `.chezmoidata/repos.json` | JSON | Git repos to auto-clone |
| `.chezmoidata/linux/linux.wm.json` | JSON | WM packages per flavor (i3, niri) |
| `.chezmoidata/linux/fonts.yaml` | YAML | Font packages |
| `.chezmoidata/linux/kernels.yaml` | YAML | Linux kernel config |
| `.chezmoidata/darwin/fonts.yaml` | YAML | macOS font packages |
| `.chezmoidata/windows/fonts.yaml` | YAML | Windows font packages |
| `.chezmoidata/idea.yaml` | YAML | IntelliJ IDE config |

---

*Stack analysis: 2026-06-12*
