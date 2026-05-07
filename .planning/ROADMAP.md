# Roadmap: fabiosouzadev/dotfiles

**Criado:** 2026-05-07
**Modo:** Vertical MVP
**Fases:** 8 | **Requisitos v1:** 18

---

## Milestone 1: Documentação & Manutenibilidade

### Fase 1: README — Estrutura Base e Quick Start
**Objetivo:** Entregar um README funcional com identidade visual, visão geral do projeto e comandos de instalação rápida por OS.
**Modo:** mvp
**Requisitos:** DOC-01, DOC-02, DOC-03, DOC-04, DOC-05, DOC-06, DOC-07
**Critérios de Sucesso:**
1. README contém header com nome do projeto, descrição e filosofia
2. One-liner de instalação funcional para macOS, Arch Linux e Ubuntu
3. Seção de pré-requisitos lista chezmoi, age e git
4. Lista de features/ferramentas incluídas está completa
5. Estrutura de diretórios explicada com tree e descrições

### Fase 2: README — Guia de Fork e Personalização
**Objetivo:** Tornar o repo fork-friendly com guia passo-a-passo de como adaptar os dotfiles para outro usuário.
**Modo:** mvp
**Requisitos:** DOC-08
**Critérios de Sucesso:**
1. Checklist de "primeiro fork" lista todos os arquivos que precisam de alteração pessoal
2. Explica quais variáveis mudar no `.chezmoi.yaml.tmpl`
3. Aviso sobre arquivos encrypted (não funcionam sem age key própria)
4. Explica como `.chezmoidata/` controla pacotes por OS

### Fase 3: README — Cheatsheet de Keymaps do tmux
**Objetivo:** Documentar todos os keybindings customizados do tmux extraídos do `tmux.conf.tmpl`.
**Modo:** mvp
**Requisitos:** KEY-01
**Critérios de Sucesso:**
1. Tabela de keybindings organizada por contexto (sessions, windows, panes, navigation, copy-mode)
2. Prefix configurado está documentado no topo
3. Integração com Navigator.nvim está explicada
4. Plugins e suas funcionalidades estão listados

### Fase 4: README — Cheatsheet de Keymaps do Neovim
**Objetivo:** Documentar os keybindings principais do Neovim e integração com tmux.
**Modo:** mvp
**Requisitos:** KEY-02
**Critérios de Sucesso:**
1. Tabela com keybindings de navegação, edição e plugins principais
2. Leader key documentada
3. Integração com tmux via Navigator.nvim explicada
4. Referência ao repositório de configuração do Neovim (se separado)

### Fase 5: README — Cheatsheet de Zsh Keybindings e Aliases
**Objetivo:** Documentar aliases úteis e keybindings do zsh.
**Modo:** mvp
**Requisitos:** KEY-03
**Critérios de Sucesso:**
1. Aliases de navegação (eza, zoxide) documentados
2. Aliases de git documentados
3. Keybindings customizados do zsh documentados
4. Integração com fzf explicada

### Fase 6: Tech Debt — Correções Rápidas
**Objetivo:** Resolver itens de dívida técnica simples e de baixo risco.
**Modo:** mvp
**Requisitos:** DEBT-01, DEBT-02, DEBT-03, DEBT-04
**Critérios de Sucesso:**
1. `dot_bashrc.tmpl` sem blocos duplicados (cd ~, dbus-launch)
2. Script `clone-my-repos` existe apenas em `unix/`, removido de `darwin/` e `linux/`
3. `dot_aider.conf.yaml.tmpl` contém apenas configuração ativa (~10 linhas)
4. Arquivo renomeado de `310-eval-starshipt.zsh.tmpl` para `310-eval-starship.zsh.tmpl`

### Fase 7: Tech Debt — Feature Flags para AI Tools
**Objetivo:** Tornar instalação de AI tools opt-in via feature flags, reduzindo tempo de setup e complexidade.
**Modo:** mvp
**Requisitos:** DEBT-05, DEBT-06
**Critérios de Sucesso:**
1. `.chezmoi.yaml.tmpl` contém flags para categorias de AI tools (coding assistants, spec tools, etc.)
2. Scripts de instalação de AI tools verificam feature flags antes de executar
3. Detecção de ambiente no `.chezmoi.yaml.tmpl` refatorada com blocos mais legíveis
4. Documentação das feature flags no README

### Fase 8: Performance — Otimização do Shell Startup
**Objetivo:** Reduzir o tempo de startup do zsh com lazy-loading de ferramentas pesadas.
**Modo:** mvp
**Requisitos:** PERF-01
**Critérios de Sucesso:**
1. Evals pesados (mise, direnv, zoxide, starship) usam lazy-loading via zinit
2. Tempo de startup do zsh medido antes e depois (meta: <500ms)
3. Todas as ferramentas continuam funcionando normalmente após lazy-load
4. Nenhuma regressão em funcionalidade do shell

---

## Dependências entre Fases

```
Fase 1 (README Base) ─────→ Fase 2 (Fork Guide)
                      ├───→ Fase 3 (tmux Keymaps)
                      ├───→ Fase 4 (nvim Keymaps)
                      └───→ Fase 5 (zsh Keymaps)

Fase 6 (Correções Rápidas) ── independente
Fase 7 (Feature Flags) ────── independente (mas depois de Fase 6 recomendado)
Fase 8 (Shell Startup) ────── independente (mas depois de Fase 7 recomendado)
```

**Nota:** Fases 2-5 dependem de Fase 1 (estrutura do README). Fases 6-8 são independentes e podem rodar em paralelo com as fases de documentação.
