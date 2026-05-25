---
phase: 5
---

# Phase 5 Context: README — Cheatsheet Zsh

## Domain
Documentação de aliases globais, atalhos do git e atalhos de teclado do Zsh configurados na pasta `home/dot_zshrc.d/`.

## Decisions Captured
- **Filtro de Git Aliases**: Não listaremos todas as ~50 entradas do `201-git-aliases.zsh.tmpl`. Apenas as essenciais/principais de uso diário e as customizadas complexas (ex: `gcop` com fzf).
- **Formatação**: Seguiremos o mesmo modelo de tabelas descritivas implementado na Fase 3 do tmux.

## Code Context & Research
- **Gerais (200-aliases.zsh.tmpl)**:
  - `v`/`n`/`vi`/`vim` mapeados para `nvim`
  - `cat` sobreposto por `bat` (ou `batcat` no Ubuntu)
  - Comandos de listagem (`l`, `la`, `ll`, `ls`, `tree`) mapeados para uso extenso e rico do `eza`.
  - Navegação de workspace: `work`, `personal`
- **Git (201-git-aliases.zsh.tmpl)** (Filtrados para destaque):
  - Essenciais: `g` (git), `gs` (status), `ga`/`gaa` (add), `gc`/`gcm` (commit), `gps`/`gpl` (push/pull), `gco`/`gcb` (checkout).
  - Destaques customizados: `gcop` (git branch com seleção em `fzf` via pipe).
- **Keybindings (104-keybindings.zsh.tmpl)**:
  - `Ctrl + p` -> history-search-backward
  - `Ctrl + n` -> history-search-forward

## Canonical References
- `ROADMAP.md`
- `docs/KEYMAPS.md`
- `home/dot_zshrc.d/*`
