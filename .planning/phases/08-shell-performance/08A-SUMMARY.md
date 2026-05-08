---
phase: 8
plan_id: 08A
title: "Performance — Shell Startup"
status: complete
---

# Plan 08A Summary: Performance — Shell Startup

## What was accomplished

- **Otimização de Startup**: Reduzimos o tempo de inicialização do Zsh de **~4.3s** para **~2.1s** (redução de ~50%).
- **Zinit Turbo Mode**: Implementamos o carregamento assíncrono (`wait"0" lucid`) para as ferramentas mais pesadas: `starship`, `zoxide`, `direnv`, `mise` e `ccr`.
- **Limpeza de Dívida Técnica**: Removemos 5 arquivos de configuração redundantes ou obsoletos na pasta `home/dot_zshrc.d/`.
- **Resiliência**: Adicionamos verificações de segurança (`command -v`) para garantir que o shell não gere erros caso alguma ferramenta não esteja instalada no momento do startup.

## Issues Encountered & Resolved
- **Fake Plugin Error**: Corrigi um erro onde o Zinit tentou baixar um plugin inexistente (`skip-node-check`). Resolvido usando `zinit snippet /dev/null` como gatilho de `atload`.
- **Ghost Files**: Identificamos e removemos arquivos que não estavam na origem mas causavam erros no destino.

## Testing / Verification
- Benchmarks realizados via `/usr/bin/time zsh -i -c exit`.
- Funcionalidade dos comandos `z`, `mise` e `direnv` verificada após o carregamento assíncrono.
