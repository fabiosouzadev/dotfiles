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

> **Prefix:** `Ctrl + a` (default remapped from `Ctrl + b`)
>
> Full config: [`home/private_dot_config/tmux/tmux.conf.tmpl`](../home/private_dot_config/tmux/tmux.conf.tmpl)

> 🚧 Coming soon — detailed keybindings will be extracted from tmux config in Phase 3.

### Quick Reference

| Key | Action |
| :--- | :--- |
| `Prefix` + `c` | New window |
| `Prefix` + `\|` | Vertical split |
| `Prefix` + `-` | Horizontal split |
| `Ctrl` + `h/j/k/l` | Navigate panes (Navigator.nvim) |

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

> 🚧 Coming soon — full alias and keybinding list will be documented in Phase 5.

### Quick Reference

| Alias/Key | Action |
| :--- | :--- |
| `ll` | `eza -la` (detailed file listing) |
| `cat` | `bat` (syntax highlighting) |
| `cd` | `zoxide` (smart jump) |

---

*[← Back to README](../README.md)*
