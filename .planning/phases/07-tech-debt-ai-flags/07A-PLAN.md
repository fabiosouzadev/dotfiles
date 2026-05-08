---
phase: 7
plan_id: 07A
title: "Tech Debt — Feature Flags AI Tools"
wave: 1
depends_on: [6]
files_modified:
  - home/.chezmoi.yaml.tmpl
  - home/.chezmoiscripts/unix/run_once_after_510-install-aider-cli.sh.tmpl
  - home/.chezmoiscripts/unix/run_once_after_511-install-copilot-cli.sh.tmpl
  - home/.chezmoiscripts/unix/run_once_after_512-install-qwen-code-cli.sh.tmpl
  - home/.chezmoiscripts/unix/run_once_after_513-install-kilo-code-cli.sh.tmpl
  - home/.chezmoiscripts/unix/run_once_after_514-install-amp-cli.sh.tmpl
  - home/.chezmoiscripts/unix/run_once_after_515-install-coderabbit-cli.sh.tmpl
  - home/.chezmoiscripts/unix/run_once_after_516-install-claude-code.sh.tmpl
  - home/.chezmoiscripts/unix/run_once_after_517-install-kiro-code-cli.sh.tmpl
  - home/.chezmoiscripts/unix/run_once_after_520-install-openspec-cli.sh.tmpl
  - home/.chezmoiscripts/unix/run_once_after_521-install-speckit-github-cli.sh.tmpl
  - home/.chezmoiscripts/unix/run_once_after_523-install-gsd.sh.tmpl
  - home/.chezmoiscripts/unix/run_once_after_524-install-cursor-cli.sh.tmpl
  - home/.chezmoiscripts/unix/run_once_after_525-install-codex-cli.sh.tmpl
  - home/.chezmoiscripts/unix/run_once_after_526-install-openclaude.sh.tmpl
  - docs/FORK-GUIDE.md
requirements:
  - DEBT-05
  - DEBT-06
autonomous: true
---

# Plan 07A: Tech Debt — Feature Flags AI Tools

## Objective

Implementar granularidade no controle de instalação de ferramentas de IA no repositório.

## Must-Haves (Goal-Backward Verification)

1. Novos grupos de feature flags no `home/.chezmoi.yaml.tmpl`.
2. Scripts de instalação tornam-se inertes se a flag estiver desligada.
3. Documentação clara sobre como ligar/desligar esses grupos.

## Tasks

<task id="07A-T1" type="execute">
<title>Refatorar .chezmoi.yaml.tmpl</title>
<action>
Inserir no dicionário `$features` o bloco `ai` com as chaves:
- `coding_assistants`: true
- `spec_tools`: true
- `gsd`: true
</action>
</task>

<task id="07A-T2" type="execute">
<title>Injetar Guards nos Scripts de Instalação</title>
<action>
Adicionar a condição `{{ if .features.ai.<CATEGORY> }}` no início de cada script listado em `files_modified`, envolvendo todo o conteúdo original.
</action>
</task>

<task id="07A-T3" type="execute">
<title>Documentar Flags no FORK-GUIDE.md</title>
<action>
Adicionar seção sobre Feature Flags explicando como personalizar as ferramentas de IA via template.
</action>
</task>

## Verification Plan

### Manual Verification
1. Rodar `chezmoi apply --dry-run` e validar se os scripts aparecem na saída de renderização (visto que a flag padrão é true).
2. Tentar setar uma flag para `false` localmente e validar se o script correspondente deixa de ser renderizado.
