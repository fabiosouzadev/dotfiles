# Integrations — Conexões e Integrações Externas

> Todas as integrações com sistemas, APIs e serviços externos que este repositório de dotfiles configura.

## Integrações de IA / Agentes

### Hermes Agent
- **Tipo**: Assistente pessoal com habilidades, memórias e automações
- **Configuração**: `~/.hermes/` (gerenciado via chezmoi, estado criptografado)
- **Dashboard Web**: Interface web na porta 9119, servido via systemd user service
- **Backup/Restore**: `hermes-sync` exporta config + SQL seletivo + manifest; restaura via `hermes-sync pull`
- **Integrações no dotfiles**:
  - `home/dot_zshrc.d/606-hermes.zsh.tmpl` — aliases e export de ambiente
  - `home/.chezmoiscripts/unix/run_once_after_590-install-ai-tools.sh.tmpl` — instalação condicional
  - `home/private_dot_config/private_systemd/private_user/hermes-dashboard.service.tmpl` — serviço systemd
  - `home/.hermes/skills/coding-orchestrator/` — skill de coding agents
- **Proxy reverso**: Caddy com subdomínio `hermes.fabiosouzadev.duckdns.org` (TLS gerenciado)
- **Autenticação**: Basic Auth configurável em `~/.hermes/config.yaml`
- **Feature flags**: `features.ai.hermes.*` em `.chezmoi.yaml.tmpl`

### OmniRoute
- **Tipo**: Gateway local/remoto de IA para agentes de código e chat
- **Configuração**: `~/.omniroute/` (gerenciado via chezmoi, estado criptografado)
- **Instalação**: Source build (Node.js via mise), script: `run_once_after_install-omniroute-from-source.sh.tmpl`
- **Dashboard Web**: Interface de login/gestão na porta 20128
- **Backup/Restore**: `omniroute-sync` exporta `config.sql` seletivo + `.env` + manifest; restaura via `omniroute-sync pull`
- **Integrações no dotfiles**:
  - `home/dot_zshrc.d/605-omniroute.zsh.tmpl` — export OMNIROUTE_API_KEY (age-decrypt)
  - `home/dot_codex/omniroute.config.toml.tmpl` — configuração do Codex
  - `home/private_dot_config/private_systemd/private_user/omniroute.service.tmpl` — serviço systemd
- **Proxy reverso**: Caddy com subdomínio `omniroute.fabiosouzadev.duckdns.org` (HTTPS) ou acesso direto `http://157.151.13.223:20128`
- **Autenticação**: Password via `INITIAL_PASSWORD` env var
- **Feature flags**: `features.ai.omniroute.*` em `.chezmoi.yaml.tmpl`
- **Versão**: `3.8.46` (configurável em `home/.chezmoidata/omniroute.yaml`)

### Coding Orchestrator
- **Tipo**: Orquestra agentes de código (Aider, Claude, Codex, Gemini, OpenCode) para execução noturna autônoma
- **Triggers**: GitHub label `coding-agent`, Telegram mention, webhook, cron noturno (`0 2 * * *`)
- **Isolamento**: Cada task roda em worktree Git isolada (`~/worktrees/task-<id>`)
- **Budget**: Total/noite $5, por task $2 via `--max-budget-usd`
- **Delivery**: Telegram, Notion, GitHub PR comments
- **Configuração**: Skill em `home/.hermes/skills/coding-orchestrator/`
- **Cron**: `coding-orchestrator-nightly` agendado via `run_onchange_after_610-deploy-hermes-cron-jobs.sh.tmpl`

### Ollama (LLM Local)
- **Tipo**: Inference de LLM local
- **Instalação**: Condicional por plataforma
  - Linux: `run_once_after_504-install-ollama.sh.tmpl` / `run_once_after_504-install-ollama-darwin.sh.tmpl`
  - VPS: modo root; local: modo user
- **Modelos**: Configurados em `.chezmoidata/ollama.yaml`
- **Zsh integration**: `dot_zshrc.d/311-ollama.zsh.tmpl`
- **Feature flag**: `features.ollama.install` / `features.ollama.mode`

### Aider
- **Tipo**: Assistente de codificação CLI
- **Configuração**: `dot_aider.conf.yaml.tmpl`, `dot_aider.model.settings.yaml.tmpl`
- **Instalação**: curl install script
- **Histórico**: `.aider.chat.history.md`, `.aider.input.history`, `.aider.tags.cache.v4/`

### Claude Code
- **Tipo**: Assistente da Anthropic
- **Configuração**: `dot_claude/settings.json.tmpl`
- **Instalação**: curl install script

### Outros Agentes/Coding Assistants (via npm)
Instalados condicionalmente pelo `ai_tools.yaml` (feature-flag `coding_assistants`):
opencode, copilot, qwen-code, kilocode, amp, codex, gemini, openclaude, freebuff, ops, gsd-core, hindsight-coding-agent

### Cursor CLI
- **Instalação**: gh-release via `.chezmoiscripts/unix/run_once_after_524-install-cursor-cli.sh.tmpl`

### Sourcegraph Cody / CodeRabbit
- **Cody**: Extensão/source-na configuração
- **CodeRabbit**: `private_dot_coderabbit/encrypted_private_auth.json.asc`

## Integrações com Plataformas / APIs

| Plataforma | Tipo | Configuração | Segredo |
|-----------|------|-------------|---------|
| **GitHub** | Git, CLI (gh), API | Várias configurações SSH, GPG signing | `dot_keys/encrypted_405-github-keys.zsh.asc` |
| **GitLab** | CLI (glab), self-hosted | `private_dot_config/glab-cli/private_config.yml.tmpl` | `private_dot_config/glab-cli/encrypted_zup_token.txt.asc` |
| **Zup (trabalho)** | Workplace profile | `.chezmoi.yaml.tmpl` hostname detection | Vários tokens em `504-zup.zsh.tmpl` (age-encrypted) |
| **AWS** | Cloud | `dot_aws/private_config.tmpl` | `dot_aws/encrypted_private_credentials.asc` |
| **Ollama** | LLM local | `.chezmoidata/ollama.yaml`, `311-ollama.zsh.tmpl` | N/A |
| **Notion** | MCP para Coding Orchestrator | Context gathering via API | Referenciado no README |
| **mem0** | Memory para Coding Orchestrator | Context gathering | Referenciado no README |
| **Hermes MCP** | Model Context Protocol | `~/.hermes/mcp_servers.json` | Criptografado via hermes-sync |
| **Composio** | Integrações de agentes | curl install | Feature flag `composio.install` |

## Integrações de VPN / Rede

| Componente | Descrição | Configuração |
|-----------|-----------|-------------|
| **Tailscale** | VPN ponto a ponto | Script install + config: `run_once_after_556-configure-tailscale.sh.tmpl`, cron: `run_once_after_505-termux-tailscale.sh.tmpl` |
| **OpenVPN3** | VPN (Linux) | Script install: `run_once_after_554-install-openvpn3.sh.tmpl` |
| **Instivo** | VPN (trabalho, bloqueia no workplace Zup) | Template: `workplace/script_is_instivo` |
| **VPS SSH** | Acesso a servidor | `private_dot_ssh/` (3 chaves: pessoal, zup, vps) |
| **Known Hosts** | SSH known_hosts | `private_dot_ssh/private_known_hosts.tmpl` |

## Integrações de Cloud / DevOps

| Componente | Descrição | Configuração |
|-----------|-----------|-------------|
| **Herdr** | Gerenciador de serviços user | curl install (feature `multiplexer`) |
| **Caddy** | Proxy reverso (TLS gerenciado) | VPS install: `run_once_after_530-install-caddy.sh.tmpl` |
| **Camofox** | Proxy/firewall VPS | VPS install: `run_once_after_532-install-camofox.sh.tmpl` |
| **AgentMemory** | Memória para agentes | VPS install: `run_once_after_531-install-agentmemory.sh.tmpl` |
| **Dockge** | Docker Compose manager (VPS) | VPS install: `run_once_after_505-install-dockge.sh.tmpl` |
| **Docks** | Docker Compose stacks | `home/dot_local/opt/stacks/` |
| **Dockge** | Docker Compose manager (VPS) | VPS install: `run_once_after_505-install-dockge.sh.tmpl` |

## Integrações de Desktop / GUI

| Componente | Descrição | Configuração |
|-----------|-----------|-------------|
| **Hyprland** | Window manager Wayland | `private_dot_config/hypr/hyprland.conf` |
| **Niri** | Window manager Wayland | `private_dot_config/niri/config.kdl` |
| **i3** | Window manager X11 | `.chezmoiexternals/i3.toml.tmpl` |
| **Picom** | Compositor X11 | `private_dot_config/picom/picom.conf` |
| **Dunst** | Notificações | `private_dot_config/dunst/` |
| **Kitty** | Terminal GPU | `private_dot_config/kitty/kitty.conf` |
| **Wezterm** | Terminal multplatform | `private_dot_config/wezterm/wezterm.lua.tmpl` |
| **tmux** | Multiplexador de terminal | `private_dot_config/tmux/tmux.conf.tmpl` |
| **Polybar** | Barra de status | Referência em aliases |
| **Firefox** | Browser | `.chezmoiexternals/firefox.toml.tmpl`, `private_dot_mozilla/private_firefox/` |
| **VS Code (Antigravity)** | Editor | `private_dot_config/private_Antigravity/User/` |

## Integrações de Ferramentas de Desenvolvimento

| Ferramenta | Tipo | Configuração |
|-----------|------|-------------|
| **Neovim** | Editor (LazyVim/Kickstart) | Externo, refs em `.chezmoidata/repos.json` |
| **mise** | Versionador de runtime | Install script + config externa |
| **Atuin** | Histórico de shell aprimorado | `.chezmoiexternals/atuin.toml.tmpl`, `dot_zshrc.d/200-atuin.zsh.tmpl` |
| **rbw** | Bitwarden CLI | `private_dot_config/rbw/config.json` |
| **WakaTime** | Tracking de produtividade | `private_dot_wakatime.cfg.tmpl`, `dot_keys/encrypted_wakatime-key.txt.asc` |
| **Greenclip** | Clipboard manager | `private_dot_config/greenclip.toml` |
| **Starship** | Prompt cross-shell | `private_dot_config/starship.toml` |
| **Aichat** | Chat local | `private_dot_config/aichat/config.yaml.tmpl` |
| **Hindsight** | Coding agent alternativo | `home/dot_hindsight/coding-agent.json.tmpl`, `dot_keys/encrypted_hindsight-key.txt.asc` |

## Integrações com Git / Repositórios

| Tipo | Descrição | Configuração |
|-----|-----------|-------------|
| **Multi-profile Git** | Configuração por contexto | `private_dot_config/git/config.tmpl` + includes (personal, personal-ssh, vps, zup, agents) |
| **SSH Keys** | 3 chaves gerenciadas | `private_dot_ssh/` (pessoal, zup, vps) |
| **GPG Signing** | Assinatura de commits | Configurado em `config.tmpl`, recipient: `E691C031009FB1DAA3A25125212D516F623C5747` |
| **Clone de Repos** | Automação de bootstrap | `.chezmoiscripts/unix/run_onchange_after_605-clone-my-repos.sh.tmpl` |
| **Repositórios pessoais** | 5 repositórios | `.chezmoidata/repos.json` |
| **Repositórios trabalho** | 4 repositórios (Zup) | `.chezmoidata/repos.json` |

## Integrações de Desktop Autostart

| Componente | Descrição |
|-----------|-----------|
| **Monitor Setup** | `private_dot_config/autostart/monitor-setup.desktop` — auto-configuration de monitores no boot X11 |

## Versão do Documento

Gerado automaticamente pelo gsd-map-codebase em 2026-09-16.
