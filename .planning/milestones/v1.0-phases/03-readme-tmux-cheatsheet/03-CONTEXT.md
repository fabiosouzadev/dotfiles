---
phase: 3
---

# Phase 3 Context: README — Cheatsheet tmux

## Domain
Documentação de atalhos e keybindings customizados do tmux baseados no arquivo `home/private_dot_config/tmux/tmux.conf.tmpl`.

## Decisions Captured

### Localização do Cheatsheet
- **Tudo junto em `docs/KEYMAPS.md`:** O cheatsheet de tmux não ficará em um arquivo separado, mas será adicionado diretamente à seção correspondente no arquivo `KEYMAPS.md` existente (que futuramente também abrigará Zsh e Neovim).

### Formatação Visual das Teclas
- **Estilo Descritivo:** Usaremos uma linguagem mais amigável e legível como `Prefix + c` ou `Ctrl-b c` em vez de simbologias truncadas.

## Code Context & Research
- O tmux prefix não está customizado no config, portanto o prefix default `Ctrl-b` deve ser explicitado no topo.
- Bindings de sessão: `Prefix + Ctrl-c`, `Prefix + Ctrl-r`
- Bindings de janela: `Prefix + c`, `Prefix + r`, `Prefix + Ctrl-p`, `Prefix + Ctrl-n`, `Prefix + l`, `Prefix + Tab`, `Prefix + Ctrl-h`, `Prefix + Ctrl-l`
- Navegação (Navigator.nvim): `Ctrl-h/j/k/l` para navegar os painéis transparentemente entre vim e tmux.
- Plugins instalados e a documentar: `tmux-yank`, `tmux-resurrect` (S = salvar, R = restaurar), `tmux-continuum`.
- Popups/Ferramentas: `Prefix + g` (lazygit), `Prefix + k` (k9s), `Prefix + z` (yazi), `Prefix + Ctrl-a` (aichat).

## Canonical References
- `ROADMAP.md`
- `docs/KEYMAPS.md` (Stub atual)
- `home/private_dot_config/tmux/tmux.conf.tmpl`

## Deferred Ideas
- Nenhuma.
