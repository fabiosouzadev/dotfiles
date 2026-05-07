# Phase 1 Context: README — Estrutura Base e Quick Start

**Phase:** 1
**Date:** 2026-05-07
**Areas discussed:** 4 (Idioma, Profundidade, Estilo Visual, Formato Keymaps)

## Domain

Criar o README.md completo do repositório de dotfiles com identidade visual, visão geral do projeto, lista de ferramentas, estrutura de diretórios e comandos de instalação rápida por OS.

## Decisions

### Idioma
- **README bilíngue**: Conteúdo principal em inglês (alcance GitHub) com seções/notas em português onde fizer sentido para o autor.

### Estrutura do Conteúdo
- **README enxuto com docs separados**: README principal é a porta de entrada — conciso e escaneável. Documentação detalhada (keymaps, guia de fork) vai em arquivos separados dentro de `docs/`.
- **Keymaps em doc separado**: Cheatsheets de tmux, Neovim e zsh ficam em `docs/keymaps.md` (ou arquivos separados por ferramenta), linkados do README.

### Estilo Visual
- **Rico em emojis**: Emojis nos headers de seção (🚀, 🛠, 📂, ⌨️, etc.) para tornar o README visualmente atraente e escaneável.
- **Badges técnicos no topo**: Badges de OS support (macOS, Linux, Windows), license, chezmoi, shell (zsh). Sem badges de vaidade (stars, repo size).

### Formato de Keymaps
- **Tabelas markdown inline**: Keybindings documentados em tabelas markdown padrão (não `<details>` colapsáveis). Formato: `| Key | Action |` agrupados por contexto.

## Code Context

### Reusable Assets
- README atual (`README.md`): Apenas one-liner de install — será completamente reescrito.
- Codebase map (`.planning/codebase/STRUCTURE.md`): Fonte autoritativa para a seção de estrutura de diretórios.
- Codebase map (`.planning/codebase/STACK.md`): Fonte autoritativa para lista de ferramentas/features.

### Established Patterns
- Chezmoi source root em `home/` (via `.chezmoiroot`)
- Scripts numerados (100-699) para ordenação
- Configuração zsh modular via `dot_zshrc.d/`
- Catppuccin Mocha como tema visual consistente

### Integration Points
- `README.md` na raiz do repo (fora de `home/`, não gerenciado pelo chezmoi)
- `docs/` será um novo diretório na raiz do repo

## Canonical Refs

| File | Purpose |
|------|---------|
| `.planning/codebase/STACK.md` | Source for features/tools list |
| `.planning/codebase/STRUCTURE.md` | Source for directory structure section |
| `.planning/codebase/INTEGRATIONS.md` | Source for AI tools and integrations |
| `.planning/research/SUMMARY.md` | README best practices from research |

## Deferred Ideas

- Screenshots/GIFs do terminal em ação — seria ótimo mas adiciona complexidade de manutenção. Considerar em fase futura.

---
*Context captured: 2026-05-07*
