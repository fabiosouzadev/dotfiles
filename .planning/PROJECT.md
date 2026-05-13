# fabiosouzadev/dotfiles

## O Que É

Repositório de dotfiles cross-platform gerenciado por chezmoi, suportando macOS, Arch Linux, Ubuntu e Windows/WSL. Fornece um ambiente de desenvolvimento completo com shell configurado (zsh), editor (Neovim), multiplexador (tmux), ferramentas CLI modernas, ecossistema de AI coding tools, e gerenciamento de segredos via age encryption. O objetivo é manter um setup reproduzível, bem documentado e colaborativo.

## Valor Principal

**Reprodutibilidade confiável**: formatar qualquer máquina e ter o ambiente de desenvolvimento completo funcionando em minutos, sem surpresas.

## Requisitos

### Validados

<!-- Inferido do código existente (.planning/codebase/) -->

- ✓ Gerenciamento declarativo de dotfiles via chezmoi com templates Go — existente
- ✓ Suporte multi-OS: macOS (Darwin), Arch Linux, Ubuntu, Windows/WSL — existente
- ✓ Detecção automática de ambiente (CI, headless, container, desktop, work/personal) — existente
- ✓ Instalação automatizada de pacotes por OS (Homebrew, pacman/paru, apt, winget/scoop) — existente
- ✓ Shell modular (zsh) com plugins via Zinit e configuração numerada — existente
- ✓ Neovim como editor padrão com integração Navigator.nvim/tmux — existente
- ✓ tmux com TPM, tema Catppuccin Mocha e resurrect/continuum — existente
- ✓ Prompt cross-shell via Starship — existente
- ✓ Gerenciamento de runtimes via mise (Java, Node, Go) — existente
- ✓ Ambientes de desenvolvimento isolados via Nix/Devenv — existente
- ✓ Ecossistema de CLI tools modernos (eza, bat, fd, fzf, zoxide, lazygit, yazi, delta) — existente
- ✓ 17+ AI coding tools instalados via scripts (Claude Code, Aider, OpenCode, Gemini CLI, etc.) — existente
- ✓ Ollama local com modelos pré-configurados e roteamento via claude-code-router — existente
- ✓ Criptografia de segredos via age (17 arquivos: SSH, GPG, API keys, VPN certs) — existente
- ✓ Git configurado com GPG signing, delta como diff pager, conditional includes para work — existente
- ✓ Window managers Linux (i3, Hyprland, Niri) com configs completas — existente
- ✓ VPN (Tailscale, OpenVPN3) e credenciais de trabalho (Zup, Instivo) — existente
- ✓ Firefox Developer Edition com perfis templatizados — existente
- ✓ Auto-clone de repositórios pessoais e de trabalho — existente

### Ativos

<!-- Escopo atual — construindo em direção a estes -->

- ✓ README completo com quick-start de instalação por OS (Milestone 1)
- ✓ README com cheatsheets de keymaps (tmux, Neovim, zsh) (Milestone 1)
- ✓ README com guia de fork e personalização para contribuidores (Milestone 1)
- ✓ Eliminar duplicações no `dot_bashrc.tmpl` (Milestone 2)
- ✓ Consolidar script `clone-my-repos` em `crossplatform/` com execução no Windows (Milestone 2)
- ✓ Tornar AI tools data-driven via `ai_tools.yaml` (Milestone 2)
- ✓ Simplificar configurações redundantes e remover completions estáticos de shell (Milestone 2)

### Ativos

<!-- Escopo atual — construindo em direção a estes -->

- [ ] Otimizar startup time do zsh (lazy-load evals pesados)
- [ ] Simplificar `dot_aider.conf.yaml.tmpl` (480 linhas de comentários, 1 linha ativa)
- [ ] Corrigir typo em `310-eval-starshipt.zsh.tmpl`
- [ ] Documentar procedimento de backup da chave `age`

### Fora de Escopo

- Migrar de chezmoi para outro dotfile manager — investimento existente é sólido
- Reescrever configs de WM (i3/niri/hyprland) — funcionam bem como estão
- Suporte a shells além de zsh/bash — complexidade sem benefício claro
- GUI para gerenciar dotfiles — CLI-first é a filosofia do projeto
- Pipeline de CI/CD — adiado para v2

## Contexto

- **Desenvolvedor**: Fabio Souza, Fullstack (Java/Node/Go/Python), usa macOS como máquina principal, Arch Linux como desktop secundário, WSL com Ubuntu no trabalho.
- **Perfis de trabalho**: Personal (padrão) e Work (Zup/Instivo), detectados por hostname
- **Tema visual**: Catppuccin Mocha aplicado consistentemente (tmux, delta, bat, etc.)
- **Mapa do codebase**: Disponível em `.planning/codebase/` (7 documentos: STACK, ARCHITECTURE, STRUCTURE, CONVENTIONS, TESTING, INTEGRATIONS, CONCERNS)
- **Dívida técnica principal**: Documentada em `.planning/codebase/CONCERNS.md`

## Restrições

- **Compatibilidade**: Qualquer mudança deve manter compatibilidade com macOS e Arch Linux (ambientes ativos)
- **Segurança**: Nenhum segredo em plaintext no repositório — age encryption obrigatória
- **Idiomas do chezmoi**: Seguir convenções do chezmoi (prefixos, templates, lifecycle hooks)
- **Retrocompatibilidade**: Scripts `run_once_` já executados não podem ser renomeados sem cleanup

## Decisões Chave

| Decisão | Justificativa | Resultado |
|---------|---------------|-----------|
| README como prioridade #1 | Serve duplo propósito: referência pessoal + colaboração GitHub | — Pendente |
| Manutenibilidade antes de features | Reduzir dívida técnica antes de adicionar complexidade | — Pendente |
| Manter chezmoi como base | Investimento grande, funciona bem, comunidade ativa | ✓ Bom |
| Catppuccin Mocha como tema padrão | Consistência visual cross-tool | ✓ Bom |
| age para criptografia | Simples, sem dependência de GPG para encryption at rest | ✓ Bom |
| CI/CD adiado para v2 | Foco atual em documentação e manutenibilidade | — Pendente |

## Evolução

Este documento evolui nas transições de fase e nos limites de milestone.

**Após cada transição de fase** (via `/gsd-transition`):
1. Requisitos invalidados? → Mover para Fora de Escopo com razão
2. Requisitos validados? → Mover para Validados com referência da fase
3. Novos requisitos surgiram? → Adicionar aos Ativos
4. Decisões a registrar? → Adicionar às Decisões Chave
5. "O Que É" ainda preciso? → Atualizar se divergiu

**Após cada milestone** (via `/gsd-complete-milestone`):
1. Revisão completa de todas as seções
2. Verificar Valor Principal — ainda é a prioridade certa?
3. Auditar Fora de Escopo — as razões ainda são válidas?
4. Atualizar Contexto com estado atual

---
*Última atualização: 2026-05-13 após conclusão do Milestone 2 (Manutenibilidade)*
