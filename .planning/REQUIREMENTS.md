# Requirements: fabiosouzadev/dotfiles

**Defined:** 2026-05-07
**Core Value:** Reprodutibilidade confiável — formatar qualquer máquina e ter o ambiente completo em minutos.

## v1 Requirements

### Documentation — Quick Start

- [ ] **DOC-01**: README contém one-liner de instalação para macOS
- [ ] **DOC-02**: README contém one-liner de instalação para Arch Linux
- [ ] **DOC-03**: README contém one-liner de instalação para Ubuntu
- [ ] **DOC-04**: README contém seção de pré-requisitos (chezmoi, age key, git)

### Documentation — Conteúdo Principal

- [ ] **DOC-05**: README contém visão geral do projeto (o que é, filosofia, para quem)
- [ ] **DOC-06**: README contém lista de features e ferramentas incluídas
- [ ] **DOC-07**: README contém estrutura de diretórios explicada
- [ ] **DOC-08**: README contém guia de fork e personalização com checklist

### Keymaps — Cheatsheets

- [ ] **KEY-01**: README contém cheatsheet de keybindings do tmux (sessions, windows, panes, navigation)
- [ ] **KEY-02**: README contém cheatsheet de keybindings do Neovim (navigation, editing, plugins)
- [ ] **KEY-03**: README contém cheatsheet de keybindings e aliases úteis do zsh

### Tech Debt — Duplicações

- [ ] **DEBT-01**: Blocos duplicados eliminados no `dot_bashrc.tmpl` (cd ~, dbus-launch)
- [ ] **DEBT-02**: Script `clone-my-repos` consolidado de `darwin/` + `linux/` para `unix/`
- [ ] **DEBT-03**: `dot_aider.conf.yaml.tmpl` simplificado (remover ~480 linhas de comentários)
- [ ] **DEBT-04**: Typo corrigido: `310-eval-starshipt.zsh.tmpl` → `310-eval-starship.zsh.tmpl`

### Tech Debt — Complexidade

- [ ] **DEBT-05**: AI tools tornados opt-in via feature flags no `.chezmoi.yaml.tmpl`
- [ ] **DEBT-06**: Detecção de ambiente no `.chezmoi.yaml.tmpl` refatorada para melhor legibilidade

### Performance

- [ ] **PERF-01**: Evals pesados no zsh startup lazy-loaded (mise, direnv, zoxide, starship)

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
| DOC-01 | Fase 1 | Pending |
| DOC-02 | Fase 1 | Pending |
| DOC-03 | Fase 1 | Pending |
| DOC-04 | Fase 1 | Pending |
| DOC-05 | Fase 1 | Pending |
| DOC-06 | Fase 1 | Pending |
| DOC-07 | Fase 1 | Pending |
| DOC-08 | Fase 2 | Pending |
| KEY-01 | Fase 3 | Pending |
| KEY-02 | Fase 4 | Pending |
| KEY-03 | Fase 5 | Pending |
| DEBT-01 | Fase 6 | Pending |
| DEBT-02 | Fase 6 | Pending |
| DEBT-03 | Fase 6 | Pending |
| DEBT-04 | Fase 6 | Pending |
| DEBT-05 | Fase 7 | Pending |
| DEBT-06 | Fase 7 | Pending |
| PERF-01 | Fase 8 | Pending |

**Coverage:**
- v1 requirements: 18 total
- Mapped to phases: 18
- Unmapped: 0 ✓

---
*Requirements defined: 2026-05-07*
*Last updated: 2026-05-07 after initial definition*
