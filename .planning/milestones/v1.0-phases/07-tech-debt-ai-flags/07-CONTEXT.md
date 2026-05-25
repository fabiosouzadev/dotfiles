---
phase: 7
---

# Phase 7 Context: Tech Debt — Feature Flags AI Tools

## Domain
Configurações de variáveis no template raiz `.chezmoi.yaml.tmpl` e scripts condicionais de instalação de pacotes AI localizados em `home/.chezmoiscripts/unix/`.

## Code Context & Research
Atualmente, a pasta de scripts `unix/` possui diversos instaladores CLI para ferramentas de Inteligência Artificial sem um controle granular (tudo ou nada baseado no OS/`ismanaged`). 

Listagem de instaladores AI observados:
- `510-install-aider-cli.sh.tmpl`
- `511-install-copilot-cli.sh.tmpl`
- `516-install-claude-code.sh.tmpl`
- `520-install-openspec-cli.sh.tmpl`
- `523-install-gsd.sh.tmpl`
- `526-install-openclaude.sh.tmpl`
- Outros (`qwen-code-cli`, `cursor-cli`, `codex-cli`, etc).

No arquivo `home/.chezmoi.yaml.tmpl`, existe a chave `$features` a partir da linha 159 que contempla regras para sudo, systemd, ollama, mas faltam os *toggles* centrais de IA.

## Decisions Captured
- **Categorização**: Criaremos um bloco `ai` dentro de `features` no `chezmoi.yaml` contendo:
  - `coding_assistants` (Aider, Copilot, Claude Code, etc)
  - `spec_tools` (OpenSpec, OpenClaude)
  - `gsd` (O framework de automação)
- **Implementação nos Scripts**: Adicionaremos uma checagem if no topo de cada script `tmpl` correspondente, validando contra a flag recém-criada (ex: `{{ if .features.ai.coding_assistants }}`). Se for `false`, o script de instalação não será gerado/executado pelo Chezmoi.

## Canonical References
- `ROADMAP.md` (DEBT-05, DEBT-06)
- `home/.chezmoi.yaml.tmpl`
- `home/.chezmoiscripts/unix/*`
