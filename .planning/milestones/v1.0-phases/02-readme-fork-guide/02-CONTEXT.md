---
phase: 2
---

# Phase 2 Context: README — Guia de Fork e Personalização

## Domain
Criação do guia passo-a-passo ensinando como um novo usuário deve clonar, adaptar variáveis (`.chezmoi.yaml.tmpl`), lidar com arquivos encriptados (`age`) e personalizar o repositório para seu próprio uso.

## Decisions Captured

### Estrutura do Guia
- O conteúdo será dividido em múltiplos arquivos focados (ex: índice principal `FORK-GUIDE.md` ligando a outros guias mais específicos como gestão de segredos ou variáveis do chezmoi), em vez de uma única página super longa.

### Profundidade Didática
- Assumir que o usuário já conhece o funcionamento básico do `chezmoi` e da ferramenta `age`.
- O foco da documentação será puramente nas **peculiaridades deste repositório** (ex: o que alterar em `.chezmoi.yaml.tmpl`, dependências OS-specific geridas em `.chezmoidata/`).

### Estratégia de Idioma
- O conteúdo será 100% bilíngue (Inglês e Português espelhados nas respectivas seções).

## Canonical References
- `ROADMAP.md`
- `docs/FORK-GUIDE.md` (Stub atual)

## Deferred Ideas
- Nenhuma.
