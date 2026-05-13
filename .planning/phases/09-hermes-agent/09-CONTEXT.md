# Phase 9: Hermes Agent — Context

**Gathered:** 2026-05-13
**Status:** Ready for planning
**Source:** Discuss-phase + Spike findings

## Domain

### Phase Boundary

Esta fase entrega a integração do Hermes Agent (https://github.com/NousResearch/hermes-agent) ao repositório de dotfiles. Hermes é um agente de IA auto-melhorável do NousResearch que oferece:

- CLI TUI completa com multiline editing, autocomplete, streaming
- Gateway multi-plataforma (Telegram, Discord, Slack, WhatsApp, Signal)
- Sistema de skills/memória persistente
- Suporte a múltiplos providers (Nous Portal, OpenRouter, OpenAI, Anthropic, etc.)
- Instalação via one-liner: `curl -fsSL ... | bash`

**Escopo desta fase:**
- Feature flag para controle de instalação
- Script de instalação integrado ao chezmoi
- Validação de coexistência com tools existentes
- Documentação básica

**Fora de escopo:**
- Configuração automática de providers (usuário configura via `hermes model`)
- Gateway setup (Telegram/Discord bots)
- Custom skills ou memórias
- WSL2 como primary target (apenas validação)

## Decisions

### Implementation Decisions

#### Installation Method
- **Decision:** Usar script oficial do NousResearch via `curl | bash`
- **Rationale:** É o método recomendado, atualizado automaticamente, já testado pelo spike 001
- **Alternatives considered:** Manual clone + setup, package manager (não existe formula ainda)

#### Feature Flag Pattern
- **Decision:** Seguir padrão OpenClaw: `"hermes" (dict "install" false)`
- **Rationale:** Consistente com tools existentes, simples, extensível no futuro
- **Location:** `.chezmoi.yaml.tmpl` no dict `$ai.tools`

#### Target Environment
- **Decision:** macOS como primary target, Linux como secondary, WSL para avaliação
- **Rationale:** macOS é ambiente principal do usuário

#### Provider Configuration
- **Decision:** Não configurar provider automaticamente
- **Rationale:** Hermes tem `hermes model` command para setup interativo; providers têm secrets que não devem estar no dotfiles

#### Coexistence Requirements
- **Decision:** Hermes deve coexistir com Claude Code, Aider, OpenCode sem conflitos
- **Validation:** Spike 004 validou que usam diretórios isolados

### the agent's Discretion

**Installation script location:**
- Opção A: run_once_install-hermes.sh.tmpl (padrão chezmoi)
- Opção B: Integrar ao sistema existente de ai_tools.yaml
- **TBD:** Escolher durante planejamento baseado em consistência

**Shell completions:**
- Hermes adiciona ao .zshrc automaticamente
- Podemos querer desativar isso e controlar manualmente via dotfiles
- **TBD:** Verificar se install.sh tem flag para skip shell config

**Update mechanism:**
- Hermes tem `hermes update` command
- Ou re-run do install script
- **TBD:** Documentar no README

## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Existing Patterns
- `.planning/codebase/CONVENTIONS.md` — Padrões do projeto
- `.planning/codebase/INTEGRATIONS.md` — Como integrações funcionam
- `home/.chezmoi.yaml.tmpl` — Template de configuração com feature flags existentes
- `home/.chezmoidata/ai_tools.yaml` — Definição de AI tools e suas flags

### Spike Findings
- `.planning/spikes/001-hermes-install-unix/README.md` — Validação de instalação
- `.planning/spikes/002-hermes-feature-flag/README.md` — Padrão de feature flag
- `.planning/spikes/003-hermes-wsl-eval/README.md` — Avaliação WSL
- `.planning/spikes/004-hermes-integration/README.md` — Coexistência com tools

### External Documentation
- https://github.com/NousResearch/hermes-agent — Repositório oficial
- https://hermes-agent.nousresearch.com/docs/ — Documentação oficial

## Specifics

### Hermes Installation Details

**Script:** `https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh`

**What it does:**
1. Detecta OS
2. Instala uv (se não existir)
3. Cria venv em `~/.hermes/`
4. Instala hermes via uv
5. Cria symlink em `~/.local/bin/hermes`
6. Configura shell (.zshrc/.bashrc)

**Locations:**
- Binary: `~/.local/bin/hermes`
- Config: `~/.hermes/config/`
- Skills: `~/.hermes/skills/`
- Python venv: `~/.hermes/.venv/`

### Feature Flag Design

```yaml
# Em .chezmoi.yaml.tmpl, dentro de $ai.tools:
"hermes" (dict "install" false)
```

**Uso no template:**
```yaml
{{- if .ai.tools.hermes.install }}
# instalação condicional
{{- end }}
```

### Requirements to Address

- **HERME-01:** Feature flag funciona
- **HERME-02:** Instalação via chezmoi funciona
- **HERME-03:** Coexistência com tools existentes
- **HERME-04:** Idempotência
- **HERME-05:** Documentação

## Deferred

**Items explicitamente fora de escopo:**

- Configuração automática de providers (OpenAI, Anthropic, etc.)
- Setup de gateway (Telegram bot, Discord, etc.)
- Skills customizadas
- Integration com sistema de secrets do dotfiles (age) — por enquanto Hermes gerencia próprios secrets
- WSL2 como primary target (apenas avaliação)
- Homebrew formula (não existe ainda)

---

*Phase: 09-hermes-agent*
*Context gathered: 2026-05-13*
