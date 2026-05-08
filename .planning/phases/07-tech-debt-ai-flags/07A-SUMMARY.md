---
phase: 7
plan_id: 07A
title: "Tech Debt — Feature Flags AI Tools"
status: complete
---

# Plan 07A Summary: Tech Debt — Feature Flags AI Tools

## What was accomplished

- **Refatoração do Config Root**: O arquivo `home/.chezmoi.yaml.tmpl` agora possui um dicionário granular de Inteligência Artificial dentro da chave `.features.ai`.
- **Categorização de Ferramentas**: Criamos três "toggles" de controle: `coding_assistants` (para CLIs de chat e editores), `spec_tools` (para frameworks de especificação) e `gsd` (para o framework de automação de tarefas).
- **Proteção de Instalação (Guards)**: Implementamos verificações de template em 14 scripts de instalação em `home/.chezmoiscripts/unix/`. Se um grupo de ferramentas estiver desativado no config, o Chezmoi agora ignora completamente o script durante o `apply`, poupando tempo de rede e CPU.
- **Documentação de Fork**: Atualizamos o `docs/FORK-GUIDE.md` para incluir a etapa de gerenciamento dessas funcionalidades como parte do checklist de personalização.

## Issues Encountered & Resolved
- Nenhuma. A estrutura de templates do Chezmoi permitiu uma implementação limpa via blocos `if`.

## Testing / Verification
- Renderização do template validada. Os scripts continuam ativos por padrão (`true`), mas agora podem ser desligados via edição de uma única linha no `.chezmoi.yaml.tmpl`.
