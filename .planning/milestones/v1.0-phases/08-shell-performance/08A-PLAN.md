---
phase: 8
plan_id: 08A
title: "Performance — Shell Startup"
wave: 1
depends_on: [7]
files_modified:
  - home/dot_zshrc.d/310-eval-starship.zsh.tmpl
  - home/dot_zshrc.d/303-mise.zsh.tmpl
  - home/dot_zshrc.d/308-eval-direnv.zsh.tmpl
  - home/dot_zshrc.d/309-eval-zoxide.zsh.tmpl
  - home/dot_zshrc.d/101-zinit-plugins.zsh.tmpl
requirements:
  - PERF-01
autonomous: true
---

# Plan 08A: Performance — Shell Startup

## Objective

Reduzir o tempo de startup do Zsh movendo ferramentas pesadas de inicialização síncrona para o modo assíncrono do Zinit.

## Must-Haves (Goal-Backward Verification)

1. Redução do tempo de startup para < 1s.
2. Manter funcionalidade de `mise`, `direnv`, `zoxide` e `starship`.
3. Remoção de arquivos redundantes.

## Tasks

<task id="08A-T1" type="execute">
<title>Remover Redundâncias e Limpar Evals Síncronos</title>
<action>
1. Deletar `home/dot_zshrc.d/310-eval-starship.zsh.tmpl`.
2. Esvaziar os conteúdos de `303-mise`, `308-direnv` e `309-zoxide` mantendo apenas comentários (para não quebrar o chezmoi caso queira voltar atrás).
</action>
</task>

<task id="08A-T2" type="execute">
<title>Implementar Turbo Mode no Zinit</title>
<action>
Adicionar ao final de `home/dot_zshrc.d/101-zinit-plugins.zsh.tmpl`:
```zsh
zinit ice wait"0" lucid as"command" atload'eval "$(zoxide init zsh)"'
zinit light skip-node-check

zinit ice wait"0" lucid as"command" atload'eval "$(direnv hook zsh)"'
zinit light skip-node-check

zinit ice wait"0" lucid as"command" atload'eval "$(mise activate zsh)"'
zinit light skip-node-check
```
</action>
</task>

<task id="08A-T3" type="execute">
<title>Benchmark e Registro</title>
<action>
Rodar a medição de tempo e comparar com os ~4.3s originais.
</action>
</task>

## Verification Plan

### Automated Tests
1. `for i in {1..5}; do /usr/bin/time zsh -i -c exit; done`
