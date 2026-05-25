# Phase 8: Discussion Log

**Date:** 2026-05-08
**Mode:** Discuss
**Phase:** 8 — Performance — Shell Startup

## Q1: Método de Otimização
- **Options Presented:** Lazy-loading manual (funções wrapper) ou delegação para o Zinit (turbosync).
- **Strategy:** Usaremos o Zinit para gerenciar o carregamento retardado (`wait`) das ferramentas que injetam ambientes via `eval`. Isso é mais limpo do que criar dezenas de funções wrapper no arquivo de configuração.

## Q2: Redundância do Starship
- **Observation:** O usuário já possui uma regra de `zinit ice` para o starship que gera o `init.zsh`. O arquivo `310-eval-starship.zsh.tmpl` é redundante.
- **Decision:** Remover o arquivo de eval manual e confiar no gerenciamento do plugin manager.

## Q3: Fluxo de Commit
- **User Instruction:** "Este trabalho eu quero revisar".
- **Decision:** Não faremos commit automático. Após a aplicação das mudanças e medição final, o usuário fará a revisão e o commit.
