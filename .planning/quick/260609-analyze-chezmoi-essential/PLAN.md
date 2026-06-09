# Quick Task: Analisar scripts do chezmoi e identificar o que é realmente necessário

**Objetivo:** Analisar todos os scripts de instalação do chezmoi e categorizar por necessidade, permitindo ao usuário instalar apenas o que realmente precisa.

## Contexto

O repositório de dotfiles possui 40+ scripts de instalação para diferentes plataformas (macOS, Linux, Windows). Muitos são opcionais ou dependem de features específicas. O usuário quer uma análise clara do que é essencial vs opcional.

## Análise Atual

**Plataforma atual:** macOS (darwin)
**Features habilitadas:** AI tools (coding_assistants, gsd, hermes, ollama, spec_tools), i3, niri, personal_repos
**Features desabilitadas:** kernels, rtl8821ce, openclaw, systemd

## Tarefas

### Tarefa 1: Mapear scripts por plataforma e categorizar

**Ação:** Criar documento de análise categorizando todos os scripts:

1. **Essenciais** (sempre executam):
   - `run_onchange_after_502-install-darwin-packages-homebrew.sh.tmpl` - Homebrew packages
   - `run_onchange_after_501-install-darwin-packages-macports.sh.tmpl` - Macports packages
   - `run_once_after_503-install-mise.sh.tmpl` - Version manager

2. **Nice-to-have** (melhoram experiência):
   - `run_once_after_529-install-lazygit.sh.tmpl` - Git TUI
   - `run_once_after_530-install-atuin.sh.tmpl` - Shell history

3. **Opcionais** (feature flags ou específicos):
   - `run_once_after_510-install-ai-tools.sh.tmpl` - AI tools (feature flag)
   - `run_once_after_504-install-ollama-darwin.sh.tmpl` - Ollama (feature flag)
   - `run_once_after_512-install-hermes.sh.tmpl` - Hermes (feature flag)
   - `run_once_after_523-install-gsd.sh.tmpl` - GSD tool
   - `run_once_after_528-install-glab.sh.tmpl` - GitLab CLI
   - `run_once_after_521-install-speckit-github-cli.sh.tmpl` - Spec tools
   - `run_once_after_515-install-coderabbit-cli.sh.tmpl` - CodeRabbit
   - `run_once_after_524-install-cursor-cli.sh.tmpl` - Cursor CLI
   - `run_once_after_531-install-wakatime-cli.sh.tmpl` - WakaTime
   - `run_once_before_225-compile-tmux.sh.tmpl` - Compilar tmux do fonte
   - `run_once_after_530-install-idea-community.sh.tmpl` - IntelliJ IDEA

4. **Linux-only** (não executam no macOS):
   - Scripts de Arch Linux, Ubuntu, drivers, WM, etc.

**Verificação:** Documento criado em `.planning/quick/260609-analyze-chezmoi-essential/ANALYSIS.md`

### Tarefa 2: Criar guia de customização

**Ação:** Criar guia mostrando como:
1. Desabilitar features via `chezmoi.yaml`
2. Comentar/remover scripts indesejados
3. Criar .chezmoiignore para scripts específicos

**Verificação:** Guia criado em `.planning/quick/260609-analyze-chezmoi-essential/CUSTOMIZATION-GUIDE.md`

## Prioridade
- **Alta** - Análise completa dos scripts
- **Média** - Guia de customização

## Tempo Estimado
- Tarefa 1: 15 minutos
- Tarefa 2: 10 minutos
