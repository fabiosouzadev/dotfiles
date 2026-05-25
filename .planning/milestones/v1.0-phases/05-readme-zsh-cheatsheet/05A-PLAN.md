---
phase: 5
plan_id: 05A
title: "README — Cheatsheet Zsh"
wave: 1
depends_on: [1]
files_modified:
  - docs/KEYMAPS.md
requirements:
  - KEY-03
autonomous: true
---

# Plan 05A: README — Cheatsheet Zsh

## Objective

Documentar os atalhos e aliases customizados do `Zsh` na página central de documentação (`docs/KEYMAPS.md`). O layout consistirá de tabelas descritivas divididas em "General & Navigation Aliases", "Git Aliases (Essentials)", e "Zsh Keybindings & Tools".

## Must-Haves (Goal-Backward Verification)

1. Tabelas de keybindings do Zsh substituem o stub em `docs/KEYMAPS.md`.
2. Aliases gerais (eza, zoxide, nvim, bat) descritos com clareza.
3. Top 15 Git aliases documentados.
4. Atalhos de histórico (Ctrl-n/p) descritos.

## Tasks

<task id="05A-T1" type="execute">
<title>Substituir Stub do Zsh no KEYMAPS.md com Aliases Filtrados</title>

<read_first>
- .planning/phases/05-readme-zsh-cheatsheet/05-CONTEXT.md
- docs/KEYMAPS.md
</read_first>

<action>
Editar o arquivo `docs/KEYMAPS.md` substituindo a seção "## 🐚 Zsh" pelo novo conteúdo:
1. Criar a subseção e tabela **General & Navigation Aliases**.
2. Criar a subseção e tabela **Git Aliases (Essentials)**.
3. Criar a subseção e tabela **Zsh Keybindings & Tools**.
</action>

<acceptance_criteria>
- A seção `## 🐚 Zsh` deve possuir as três tabelas preenchidas adequadamente.
- Não há mais a referência "Coming soon" para a fase 5.
</acceptance_criteria>
</task>

## Verification Plan

### Automated Tests
1. `grep -i "Git Aliases (Essentials)" docs/KEYMAPS.md`

### Manual Verification
Ler o markdown gerado no VSCode para garantir consistência visual.
