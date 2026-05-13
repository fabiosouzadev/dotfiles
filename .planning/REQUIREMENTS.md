# Requirements: fabiosouzadev/dotfiles

**Defined:** 2026-05-07
**Core Value:** Reprodutibilidade confiável — formatar qualquer máquina e ter o ambiente completo em minutos.

## v1 Requirements

### Documentation — Quick Start

- [x] **DOC-01**: README contém one-liner de instalação para macOS
- [x] **DOC-02**: README contém one-liner de instalação para Arch Linux
- [x] **DOC-03**: README contém one-liner de instalação para Ubuntu
- [x] **DOC-04**: README contém seção de pré-requisitos (chezmoi, age key, git)

### Documentation — Conteúdo Principal

- [x] **DOC-05**: README contém visão geral do projeto (o que é, filosofia, para quem)
- [x] **DOC-06**: README contém lista de features e ferramentas incluídas
- [x] **DOC-07**: README contém estrutura de diretórios explicada
- [x] **DOC-08**: README contém guia de fork e personalização com checklist

### Keymaps — Cheatsheets

- [x] **KEY-01**: README contém cheatsheet de keybindings do tmux (sessions, windows, panes, navigation)
- [x] **KEY-02**: README contém cheatsheet de keybindings do Neovim (navigation, editing, plugins) [SKIPPED - Managed Externally]
- [x] **KEY-03**: README contém cheatsheet de keybindings e aliases úteis do zsh

### Tech Debt — Duplicações

- [x] **DEBT-01**: Blocos duplicados eliminados no `dot_bashrc.tmpl` (cd ~, dbus-launch)
- [x] **DEBT-02**: Script `clone-my-repos` consolidado de `darwin/` + `linux/` para `unix/`
- [x] **DEBT-03**: `dot_aider.conf.yaml.tmpl` simplificado (remover ~480 linhas de comentários)
- [x] **DEBT-04**: Typo corrigido: `310-eval-starshipt.zsh.tmpl` → `310-eval-starship.zsh.tmpl`

### Tech Debt — Complexidade

- [x] **DEBT-05**: AI tools tornados opt-in via feature flags no `.chezmoi.yaml.tmpl`
- [x] **DEBT-06**: Detecção de ambiente no `.chezmoi.yaml.tmpl` refatorada para melhor legibilidade

### Performance

- [x] **PERF-01**: Evals pesados no zsh startup lazy-loaded (mise, direnv, zoxide, starship)

## AI Tools Integration

### Hermes Agent

- [x] **HERME-01**: Feature flag `ai.coding_assistants.hermes.enabled` adicionada ao `.chezmoi.yaml.tmpl`
- [x] **HERME-02**: Script de instalação do Hermes via chezmoi (run_once) funciona em macOS
- [x] **HERME-03**: Hermes coexiste sem conflitos com Claude Code, Aider, OpenCode
- [x] **HERME-04**: Instalação é idempotente (rodar novamente não quebra)
- [x] **HERME-05**: Documentação no README sobre Hermes (como usar, provider config)

## v2 Requirements

### CI/CD

- **CI-01**: GitHub Actions com `chezmoi apply --dry-run` em containers multi-OS
- **CI-02**: ShellCheck linting para scripts `.sh.tmpl`

## Out of Scope

| Feature | Reason |
|---------|--------|
| Migrar de chezmoi para outro manager | Investimento existente sólido, sem benefício claro |
| Reescrever configs de WM (i3/niri/hyprland) | Funcionam bem, sem necessidade de mudança |
| Suporte a shells além de zsh/bash | Complexidade sem benefício |
| GUI para gerenciar dotfiles | CLI-first é a filosofia |
| Auto-gerar README inteiro de configs | Perde personalidade e legibilidade |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| DOC-01 | Fase 1 | Done |
| DOC-02 | Fase 1 | Done |
| DOC-03 | Fase 1 | Done |
| DOC-04 | Fase 1 | Done |
| DOC-05 | Fase 1 | Done |
| DOC-06 | Fase 1 | Done |
| DOC-07 | Fase 1 | Done |
| DOC-08 | Fase 2 | Done |
| KEY-01 | Fase 3 | Done |
| KEY-02 | Fase 4 | Skipped |
| KEY-03 | Fase 5 | Done |
| DEBT-01 | Fase 6 | Done |
| DEBT-02 | Fase 6 | Done |
| DEBT-03 | Fase 6 | Done |
| DEBT-04 | Fase 6 | Done |
| DEBT-05 | Fase 7 | Done |
| DEBT-06 | Fase 7 | Done |
| PERF-01 | Fase 8 | Done |
| HERME-01 | Fase 9 | Done |
| HERME-02 | Fase 9 | Done |
| HERME-03 | Fase 9 | Done |
| HERME-04 | Fase 9 | Done |
| HERME-05 | Fase 9 | Done |

**Coverage:**
- v1 requirements: 18 total (all mapped)
- v2 + Hermes requirements: 8 total
- Mapped to phases: 23
- Unmapped: 0 ✓

---
*Requirements defined: 2026-05-07*
*Last updated: 2026-05-07 after initial definition*
