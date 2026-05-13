# Spike Manifest

## Idea

Integrar o Hermes Agent (https://github.com/NousResearch/hermes-agent) ao repositório de dotfiles do fabiosouzadev. Hermes é um agente de IA auto-melhorável do NousResearch que oferece CLI TUI completa, gateway multi-plataforma (Telegram, Discord, etc), e sistema de skills/memória.

## Requirements

Design decisions que emergiram durante o spike:

- **Instalação via script oficial**: usar o one-liner do NousResearch, não gerenciador de pacotes
- **Controle via feature flag**: seguir padrão existente `ai.coding_assistants.hermes.enabled`
- **Sem provider inicial**: usuário configura via `hermes model` após instalação
- **Suporte macOS + Linux**: spike 001 valida ambos, spike 003 avalia WSL especificamente
- **Coexistência**: Hermes deve funcionar sem conflitar com Claude Code, Aider, OpenCode existentes
- **Integração com mise/uv**: usar Python/Node do ambiente, não conflitar com gerenciadores existentes

## Spikes

| # | Name | Type | Validates | Verdict | Tags |
|---|------|------|-----------|---------|------|
| 001 | hermes-install-unix | standard | Instalação funciona em macOS e Linux via script oficial | PENDING | install,macos,linux,unix |
| 002 | hermes-feature-flag | standard | Feature flag integra corretamente com `.chezmoi.yaml.tmpl` | PENDING | config,chezmoi,feature-flag |
| 003 | hermes-wsl-eval | standard | WSL2 Ubuntu comportamento vs Linux nativo | PENDING | wsl,ubuntu,eval |
| 004 | hermes-integration | standard | Coexistência com Claude Code, Aider, OpenCode | PENDING | integration,coexistence,ai-tools |
