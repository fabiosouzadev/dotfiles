---
phase: 6
plan_id: 06A
title: "Tech Debt — Correções Rápidas"
wave: 1
depends_on: [5]
files_modified:
  - home/dot_bashrc.tmpl
  - home/dot_aider.conf.yaml.tmpl
  - home/.chezmoiscripts/unix/run_onchange_after_605-clone-my-repos.sh.tmpl
  - home/dot_zshrc.d/310-eval-starship.zsh.tmpl
requirements:
  - DEBT-01
  - DEBT-02
  - DEBT-03
  - DEBT-04
autonomous: true
---

# Plan 06A: Tech Debt — Correções Rápidas

> **Nota de Execução**: Este plano foi executado de forma imediata (Direct Execution) com a aprovação explícita do usuário, pulando a etapa de rascunho de artefato.

## Objective

Resolver itens pendentes de dívida técnica simples no repositório.

## Tasks (Executed)

1. **Bashrc Cleanup**: Localizar e remover as três chamadas duplicadas de `cd ~` e as verificações redundantes do `dbus-launch` no `dot_bashrc.tmpl`.
2. **Aider Config Simplification**: Apagar as +400 linhas comentadas do arquivo default do `dot_aider.conf.yaml.tmpl`, mantendo apenas a chave ativa `editor: nvim` e os cabeçalhos.
3. **DRY Chezmoiscripts**: Mover os scripts de clone de repositórios que estavam divididos e duplicados nas pastas `linux/` e `darwin/` para o diretório de execução genérica `unix/`, centralizando a instrução.
4. **Typo Fix**: Renomear `310-eval-starshipt.zsh.tmpl` para `310-eval-starship.zsh.tmpl`.
