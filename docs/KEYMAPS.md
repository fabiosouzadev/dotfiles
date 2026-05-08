# ⌨️ Keymaps & Shortcuts

> Cheatsheets for tmux, Neovim, and zsh keybindings used in this dotfiles setup.
>
> 🇧🇷 **Português:** Atalhos de teclado para tmux, Neovim e zsh configurados nestes dotfiles.

## Contents

- [tmux](#️-tmux)
- [Neovim](#️-neovim)
- [Zsh](#-zsh)

---

## 🖥️ tmux

> **Prefix:** `Ctrl + b` (Default)
>
> Full config: [`home/private_dot_config/tmux/tmux.conf.tmpl`](../home/private_dot_config/tmux/tmux.conf.tmpl)

### Sessions & Windows

| Key | Action |
| :--- | :--- |
| `Prefix` + `Ctrl-c` | New session |
| `Prefix` + `Ctrl-r` | Rename session |
| `Prefix` + `c` | New window |
| `Prefix` + `r` | Rename window |
| `Prefix` + `Ctrl-n` / `Ctrl-p` | Next / Previous window |
| `Prefix` + `l` / `Tab` | Last active window |
| `Prefix` + `Ctrl-h` / `Ctrl-l` | Jump to window on left / right |

### Panes

| Key | Action |
| :--- | :--- |
| `Prefix` + `%` | Vertical split |
| `Prefix` + `"` | Horizontal split |
| `Prefix` + `>` / `<` | Swap current pane with next / previous |
| `Prefix` + `+` | Zoom / Unzoom pane |
| `Prefix` + `H/J/K/L` | Resize pane (by 5 cells) |

### Copy Mode & Clipboard

| Key | Action |
| :--- | :--- |
| `Prefix` + `Enter` | Enter copy mode |
| `v` | Begin selection (vi-style) |
| `y` | Copy selection & cancel |
| `Prefix` + `P` | Paste buffer |
| `H` / `L` | Start of line / End of line (in copy mode) |

*System clipboard integration is configured for X11, Wayland, and macOS automatically.*

### Popups & Tools

| Key | Action |
| :--- | :--- |
| `Prefix` + `g` | Open **lazygit** |
| `Prefix` + `k` | Open **k9s** |
| `Prefix` + `z` | Open **yazi** |
| `Prefix` + `Ctrl-a`| Open **aichat** |

### Plugins & Integrations

- **Navigator.nvim**: Use `Ctrl` + `h/j/k/l` to transparently navigate between Neovim splits and tmux panes.
- **tmux-resurrect**: Save session with `Prefix` + `S`. Restore with `Prefix` + `R`.
- **tmux-continuum**: Automatically saves sessions every 10 minutes.
- **tmux-yank**: Integrated for cross-platform clipboard support.

---

## ✏️ Neovim

> **Leader:** `Space`
>
> Config: External Neovim repository (not managed in this dotfiles repo)

> 🚧 Coming soon — detailed keybindings will be documented in Phase 4.

### Quick Reference

| Key | Action |
| :--- | :--- |
| `Ctrl` + `h/j/k/l` | Navigate splits (integrated with tmux) |

---

## 🐚 Zsh

> Config: [`home/dot_zshrc.d/`](../home/dot_zshrc.d/)
>
> Aliases: [`200-aliases.zsh.tmpl`](../home/dot_zshrc.d/200-aliases.zsh.tmpl) and [`201-git-aliases.zsh.tmpl`](../home/dot_zshrc.d/201-git-aliases.zsh.tmpl)

### General & Navigation Aliases

| Alias / Key | Action |
| :--- | :--- |
| `v`, `n`, `vi`, `vim` | Open `nvim` |
| `cat` | Run `bat` (with syntax highlighting) |
| `ls`, `ll`, `la`, `l`, `tree` | Smart directory listing using `eza` |
| `df`, `du` | Disk usage human-readable (`-h`) |
| `reload` | Source `~/.zshrc` |
| `work`, `personal` | Jump to workspace directories |

### Git Aliases (Essentials)

| Alias | Action |
| :--- | :--- |
| `g`, `gs` | `git`, `git status` |
| `ga`, `gaa` | `git add`, `git add --all` |
| `gc`, `gcm` | `git commit -v`, `git commit -m` |
| `gac` | `git add -A && git commit -v` |
| `gco`, `gcb`, `gbr` | `git checkout`, `git checkout -b`, `git branch` |
| `gcop` | `git branch \| fzf \| xargs git checkout` |
| `gpl`, `gps` | `git pull`, `git push` |
| `gl`, `glo` | `git log` (oneline, graph, decorated) |
| `gd` | `git diff` |

### Zsh Keybindings & Tools

| Key | Action |
| :--- | :--- |
| `Ctrl` + `p` | History search backward |
| `Ctrl` + `n` | History search forward |
| `cd` | Powered by `zoxide` (smart jump) |

---

*[← Back to README](../README.md)*
