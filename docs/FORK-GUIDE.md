# 🍴 Fork & Customize Guide

> How to adapt these dotfiles for your own setup.
>
> 🇧🇷 **Português:** Como fazer fork e adaptar esses dotfiles para o seu próprio ambiente.

## 🚧 Coming Soon

This guide is under construction (Phase 2). It will cover:

- [ ] **Personal info** — Files that need your username, email, and GPG key
- [ ] **chezmoi variables** — How `.chezmoi.yaml.tmpl` detects your environment
- [ ] **Encrypted files** — Why they won't work without your own age key
- [ ] **Package selection** — How `.chezmoidata/` controls what gets installed per OS
- [ ] **First fork checklist** — Step-by-step to get your fork running

---

## Quick Overview

### Files You Must Change

| File | What to change |
|------|---------------|
| `home/.chezmoi.yaml.tmpl` | Your git email, hostname patterns, work detection |
| `home/.chezmoidata/repos.json` | Your personal/work repositories |
| `home/private_dot_config/git/config.tmpl` | Your git username, email, signing key |

### Encrypted Files

This repo uses [age encryption](https://age-encryption.org) for 17 sensitive files (SSH keys, API tokens, VPN certs). These files **will not work** with a fork — you need to:

1. Generate your own age key: `age-keygen -o ~/.config/chezmoi/key.txt`
2. Update the recipient in `.chezmoi.yaml.tmpl`
3. Re-add your own secrets: `chezmoi add --encrypt ~/.ssh/id_ed25519`

### What You Get for Free

Everything that isn't encrypted works out of the box:
- Shell configuration (zsh + plugins)
- Terminal settings (tmux, kitty, wezterm)
- CLI tool configs (bat, delta, starship, fzf)
- Git aliases and delta diff theme

---

*[← Back to README](../README.md)*
