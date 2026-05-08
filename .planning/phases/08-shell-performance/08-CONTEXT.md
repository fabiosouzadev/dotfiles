---
phase: 8
---

# Phase 8 Context: Performance — Shell Startup

## Domain
Otimização do tempo de carregamento do Zsh através de lazy-loading e remoção de redundâncias nos scripts em `home/dot_zshrc.d/`.

## Code Context & Research
- **Medição Inicial**: O tempo de startup médio é de ~4.3s (real), com picos de 5.8s. Extremamente lento para um shell moderno.
- **Redundância Identificada**: 
  - `starship` está sendo inicializado via `zinit` em `101-zinit-plugins.zsh.tmpl` (via `atclone`) E via `eval` em `310-eval-starship.zsh.tmpl`.
- **Gargalos de Eval**:
  - `mise activate zsh` (duas vezes!)
  - `zoxide init zsh`
  - `direnv hook zsh`
  - `starship init zsh`

## Decisions Captured
- **Remover Redundância**: Apagar o `310-eval-starship.zsh.tmpl` já que o Zinit cuida disso com `wait lucid`.
- **Lazy-Load via Zinit**: Aproveitaremos o motor do `zinit` para carregar `zoxide`, `direnv` e `mise` de forma assíncrona (`wait"0"`) após o primeiro prompt, removendo o bloqueio do startup.

## Canonical References
- `ROADMAP.md` (PERF-01)
- `home/dot_zshrc.d/101-zinit-plugins.zsh.tmpl`
- `home/dot_zshrc.d/3*`
