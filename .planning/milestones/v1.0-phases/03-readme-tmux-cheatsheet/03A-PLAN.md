---
phase: 3
plan_id: 03A
title: "README — Cheatsheet tmux"
wave: 1
depends_on: [1]
files_modified:
  - docs/KEYMAPS.md
requirements:
  - KEY-01
autonomous: true
---

# Plan 03A: README — Cheatsheet tmux

## Objective

Documentar todos os atalhos customizados do `tmux` extraídos da configuração real (`tmux.conf.tmpl`). Os atalhos serão inseridos no arquivo central `docs/KEYMAPS.md`, agrupados por categorias (Sessões e Janelas, Painéis, Ferramentas) e utilizando um estilo descritivo (ex: `Prefix + c`).

## Must-Haves (Goal-Backward Verification)

1. Tabelas de keybindings divididas por contexto na seção `## 🖥️ tmux`.
2. Prefix default (`Ctrl + b`) explícito.
3. Menção e documentação dos atalhos do Navigator.nvim.
4. Menção e documentação dos plugins (Yank, Resurrect, Continuum).

## Tasks

<task id="03A-T1" type="execute">
<title>Substituir Stub do tmux no KEYMAPS.md com Atalhos Completos</title>

<read_first>
- .planning/phases/03-readme-tmux-cheatsheet/03-CONTEXT.md
- docs/KEYMAPS.md
</read_first>

<action>
Editar o arquivo `docs/KEYMAPS.md` substituindo o bloco do `tmux` (linhas 15-32 aproximadamente) pelo novo conteúdo que incluirá:
1. O Prefix (`Ctrl-b`).
2. Tabela de **Sessions & Windows** (New, Rename, Next, Previous, Last, etc).
3. Tabela de **Panes** (Split, Swap, Resize, Zoom).
4. Tabela de **Copy Mode & Clipboard** (Enter, Paste, vi-like selection).
5. Tabela de **Popups & Apps** (lazygit, yazi, k9s, aichat).
6. Explicação dos plugins: Navigator.nvim, Resurrect, e Continuum.
</action>

<acceptance_criteria>
- A seção `## 🖥️ tmux` deve conter as 4 tabelas de atalhos.
- Deve remover a frase "Coming soon".
- Estilo descritivo mantido (`Prefix + c`).
</acceptance_criteria>
</task>

## Verification Plan

### Automated Tests
1. `cat docs/KEYMAPS.md | grep -i "Sessions & Windows"`

### Manual Verification
Ler o `KEYMAPS.md` para garantir que a renderização markdown está legível.
