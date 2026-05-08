---
phase: 6
plan_id: 06A
title: "Tech Debt — Correções Rápidas"
status: complete
---

# Plan 06A Summary: Tech Debt — Correções Rápidas

## What was accomplished

- **DEBT-01**: Removidos os blocos espúrios e repetidos no final do `home/dot_bashrc.tmpl` (`cd ~` e `dbus-launch`). O arquivo agora termina limpamente sem chamadas sobrepostas.
- **DEBT-02**: O script de clone foi unificado. Em vez de manter cópias exatas em `linux/` e `darwin/`, o arquivo agora reside unicamente em `home/.chezmoiscripts/unix/run_onchange_after_605-clone-my-repos.sh.tmpl`.
- **DEBT-03**: O enorme boilerplate com mais de 480 linhas comentadas do `dot_aider.conf.yaml.tmpl` foi limpo. Sobraram apenas as ~5 linhas ativas referenciando o `nvim`.
- **DEBT-04**: O erro de digitação de "*starshipt*" foi corrigido, e o arquivo em `dot_zshrc.d/` foi devidamente renomeado para `310-eval-starship.zsh.tmpl`.

## Issues Encountered & Resolved
- Nenhuma. As modificações eram de baixo risco e foram commitadas de forma coesa na branch principal sob a referência `55bc281`.

## Testing / Verification
- O commando do Git registrou uma exclusão líquida de 628 linhas do repositório, atestando a limpeza da dívida técnica.
