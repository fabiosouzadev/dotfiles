# INTEGRATIONS.md — Serviços Externos, APIs e Integrações

> 🧠 **From Hindsight memory (codebase map)** — Documento gerado pelo mapeamento do codebase fabiosouzadev/dotfiles em 2026-09-17.

## Gateways e Provedores de IA

### OmniRoute (v3.8.50)
- **Tipo**: Gateway local/remoto de IA (model router) com web dashboard
- **API**: http://193.123.97.209:20129/v1 (OpenAI-compatible)
- **Dashboard**: http://157.151.13.223:20128 (acesso direto) / https://omniroute.fabiosouzadev.duckdns.org/ (via Caddy)
- **Extra ports**: 20129 (API), 20132 (aux)
- **Auth**: Password via `INITIAL_PASSWORD` env var
- **Deployment**: Docker Compose, build from GitHub (turbo, 4096MB memory)
  - Base image: `diegosouzapw/omniroute:3.8.49-web`
  - Extends com `@qoder-ai/qodercli` (npm global)
  - Dockerfile: `home/dot_local/opt/stacks/omniroute/Dockerfile`
- **Config**: `home/dot_codex/omniroute.config.toml.tmpl` — model=omniroute/coding, reasoning=xhigh, context=400K
- **Service**: `private_dot_config/private_systemd/private_user/omniroute.service.tmpl` (Node.js, env_file)
- **Docker**: `dot_local/opt/stacks/omniroute/compose.yaml.tmpl` + encrypted_dot_env.asc
- **Chave API**: Criptografada com age — `home/dot_keys/encrypted_omniroute-key.txt.asc` (e `-zup` variant)
- **Sync tool**: `home/dot_local/bin/executable_omniroute-sync` — sync config.sql, manifest, backup-note (encrypted)

### Claude Code (Anthropic via OmniRoute)
- **Config**: `home/dot_claude/private_config.toml.tmpl`
- **Auth**: `home/dot_codex/auth.json.tmpl` → OPENAI_API_KEY via age decrypt
- **Modelos**: `omniroute/roteia-coding`, `omniroute/reasoning`, `omniroute/coding`, `omniroute/openrouter-testing`
- **Hooks**: GSD lifecycle hooks (SessionStart, PostToolUse, PreToolUse, Stop, SubagentStop, PreCompact, FileChanged, UserPromptSubmit)
  - Todos os hooks com trust via sha256 hashes
  - GSD hooks: gsd-context-monitor, gsd-read-injection-scanner, gsd-graphify-update, gsd-phase-boundary, gsd-prompt-guard, gsd-read-guard, gsd-workflow-guard, gsd-worktree-path-guard, gsd-validate-commit, gsd-config-reload, gsd-statusline
- **MCP**: Hindsight server (`/home/fabio.souza/.hindsight/coding-agents/dist/mcp-server.js`, HINDSIGHT_MCP_HARNESS=codex)
- **Permissions Claude**:
  - Allow: `Bash(npx gsd-core *)`, `Read(.planning/*)`, `Write(.planning/*)`, `Read(STATE.md)`, `Write(STATE.md)`
  - Deny: `Read(.env)`, `Read(.env.*)`, `Read(.secrets)`

### Qwen Code
- **Config**: `home/dot_qwen/settings.json.tmpl`
- **Auth**: Qwen OAuth (`security.auth.selectedType: qwen-oauth`)
- **Theme**: GitHub dark
- **Hooks**: GSD hooks adaptados (qwen-sessionstart, qwen-hook, qwen-stop) — stop hook 60s
- **MCP**: Hindsight (`HINDSIGHT_MCP_HARNESS = "qwen-code"`)

### Ollama (Local)
- **Tipo**: LLM local
- **Install Linux**: `run_once_after_504-install-ollama.sh.tmpl` (user/root mode by platform)
  - Features: `.features.ollama.install`, `.features.ollama.mode`, `.features.ollama.version`, `.features.ollama.path.logs`, `.features.ollama.localmodels.enabled`, `.features.ollama.models`
- **Install Darwin**: `run_once_after_504-install-ollama-darwin.sh.tmpl`
- **Models**: `run_onchange_after_505-install-ollama-models.sh.tmpl` (template-driven model list)
- **Aliases**: `home/dot_zshrc.d/311-ollama.zsh.tmpl` (start/stop/restart/status + Open WebUI docker alias)
- **UI**: Open WebUI (:8080, OLLAMA_BASE_URL=http://ollama:11434)

### Coding Orchestrator (Agentes Autônomos)
- **Tipo**: Orquestra agentes de código para execução noturna autônoma
- **Triggers**: GitHub label `coding-agent`, Telegram `@hermes coding-agent:`, webhook, cron 02:00 UTC
- **Install**: `.chezmoiscripts/unix/run_once_after_540-install-coding-orchestrator.sh.tmpl`
- **Cron Deploy**: `.chezmoiscripts/unix/run_onchange_after_610-deploy-hermes-cron-jobs.sh.tmpl`
- **Budget**: $5/noite total, $2/task via `--max-budget-usd`
- **Worktree**: `~/worktrees/task-<id>` (isolamento Git)
- **Agents**: Aider (padrão via OmniRoute), Claude Code, Codex CLI, Gemini CLI, OpenCode
- **Context**: GitHub API, Git diff, Notion MCP, mem0 memory
- **Delivery**: Telegram, Notion, GitHub PR comments

### Agentmemory (VPS)
- **Tipo**: Persistent memory server para AI coding agents
- **Install VPS**: `run_once_after_531-install-agentmemory.sh.tmpl`
- **Condition**: Requires `.features.hermes.enabled` AND `.features.hermes.agentmemory.enabled`

### Camofox (Browser Automation, VPS)
- **Tipo**: Browser automation (navegador headless)
- **Install VPS**: `run_once_after_532-install-camofox.sh.tmpl`
- **Condition**: Requires `.features.hermes.enabled` AND `.features.hermes.camofox.enabled`
- **Docker**: `dot_local/opt/stacks/camofox/compose.yaml.tmpl` (porta 9377)
- **Paths**: cookies, profiles, traces (persistent)

### Coderabbit / Cursor / Speckit / GitHub CLI
- Coderabbit: `run_once_after_515-install-coderabbit-cli.sh.tmpl` — feature flag `features.ai.coding_assistants`
- Cursor CLI: `run_once_after_524-install-cursor-cli.sh.tmpl`
- Speckit: `run_once_after_521-install-speckit-github-cli.sh.tmpl` — feature flag `features.ai.spec_tools`
- GitHub CLI (glab): `run_once_after_528-install-glab.sh.tmpl`

## Repositórios Git

### GitHub (fabiosouzadev/dotfiles)
- **Origin**: `git@github.com:fabiosouzadev/dotfiles.git`
- **Branch**: main
- **Tag**: v1.0

### Chezmoi Externals (Downloads Automáticos via TOML)
| Arquivo | Tipo | URL |
|---------|------|-----|
| `git.toml.tmpl` | file | catppuccin/delta gitconfig |
| `atuin.toml.tmpl` | archive | catppuccin/atuin themes (zip) |
| `i3.toml.tmpl` | archive | polybar-themes + rofi-themes (zip) |
| `tmux.toml.tmpl` | git-repo | tmux-plugins/tpm |
| `wallpapers.toml.tmpl` | git-repo | wallpapers.git (skip headless) |
| `firefox.toml.tmpl` | (comentado) | FF-ULTIMA / FirefoxGX |
| `icons.toml.tmpl` | (comentado) | Papirus |

## Cloud / VPS

### Oracle Cloud (VPS)
- **Detecção**: hostname começa com `instance-` ou profile=vps
- **Chave SSH**: `home/private_dot_ssh/encrypted_private_id_ed25519_vps.asc`
- **Chave readonly**: `encrypted_private_readonly_ssh-key-oracle-dev-2.key.asc`
- **Known Hosts**: `home/private_dot_ssh/private_known_hosts.tmpl`
- **Chave pública**: `id_ed25519_vps.pub`, `id_ed25519_zup.pub`, `id_ed25519_personal.pub`

### Zup (Workplace)
- **Perfil**: Detectado automaticamente (hostname contém `zwpe0f96cn`)
- **Chaves**: `home/dot_zshrc.d/encrypted_404-zup-keys.zsh.asc`
- **API Keys** (em `504-zup.zsh.tmpl`): OLLAMA_API_KEY, GITHUB_PAT, GH_TOKEN, GITHUB_TOKEN, GITHUB_COPILOT_TOKEN, GEMINI_API_KEY, CURSOR_API_KEY, OPENCODE_API_KEY
- **Git**: fabio.vanderlei@zup.com.br, signingkey BA7F642CFD8466A1, ssh id_ed25519_zup

### AWS (ClaroCorp SSO)
- **Config**: `home/dot_aws/private_config.tmpl`
- **SSO**: clarocorp.awsapps.com, account 319569500149, role ViewOnlyAccess, region us-east-1
- **Credenciais**: `home/dot_aws/encrypted_private_credentials.asc` (PGP encrypted)

### GitHub Keys pessoais
- `home/dot_zshrc.d/encrypted_405-github-keys.zsh.asc`

## VPN

- **Tailscale**: VPN ponto a ponto — `run_once_after_556-configure-tailscale.sh.tmpl` (unix), `run_once_after_101-termux-tailscale.sh.tmpl` (termux)
- **Instivo**: VPN alternativa — `run_once_after_655-configure-vpn-instivo.sh.tmpl`, template guard `workplace/script_is_instivo`, key `encrypted_403-instivo.zsh.asc`

## Gestão de Segredos

### Criptografia
- **age**: Criptografia simétrica moderna (primária)
- **GPG**: Criptografia assimétrica (secundária, recipient E691C031009FB1DAA3A25125212D516F623C5747)

### Arquivos Criptografados
| Arquivo | Conteúdo |
|---------|----------|
| `dot_keys/encrypted_omniroute-key*.asc` | API Key OmniRoute (pessoal + Zup) |
| `dot_keys/encrypted_hindsight-key.txt.asc` | Hindsight API key |
| `dot_keys/encrypted_wakatime-key.txt.asc` | Wakatime API key |
| `dot_keys/encrypted_404-zup-keys.zsh.asc` | Chaves Zup (APIs) |
| `dot_keys/encrypted_405-github-keys.zsh.asc` | GitHub tokens |
| `dot_keys/encrypted_403-instivo.zsh.asc` | Instivo VPN config |
| `dot_keys/encrypted_300-ai-api-keys.zsh.asc` | API genéricas |
| `dot_keys/encrypted_private_readonly_ssh-key-oracle-dev-2.key.asc` | Chave readonly VPS |
| `dot_aws/encrypted_private_credentials.asc` | AWS SSO creds |
| `private_dot_ssh/encrypted_private_id_ed25519_vps.asc` | Chave VPS SSH |
| `private_dot_coderabbit/encrypted_private_auth.json.asc` | Coderabbit auth |
| `private_dot_wakatime.cfg.tmpl` | Wakatime config |
| `dot_local/opt/stacks/*/encrypted_dot_env.asc` | Docker stack env vars (11+ stacks) |
| `private_share/apps/hermes-local/encrypted_private_dot_env.asc` | Hermes local env |
| `private_share/apps/private_hermes/encrypted_private_dot_env.asc` | Hermes private env |
| `private_share/apps/hermes-local/home/documents/encrypted_curriculo_atualizado_ats.pdf.asc` | CV/resume |
| `private_share/apps/hermes-local/home/bin/encrypted_executable_himalaya.asc` | Himalaya binary |
| `private_share/apps/camofox/cookies/encrypted_linkedin.txt.asc` | LinkedIn cookies |
| `private_share/apps/hermes-local/private_skills/hermes-mcp-setup/` | MCP config templates |
| `home/private_dot_mozilla/private_firefox/profiles.ini.tmpl` | Firefox profile paths |
| `home/private_dot_mozilla/private_firefox/installs.ini.tmpl` | Firefox installs |

## Services e Daemons

### systemd (Linux VPS)
- **omniroute.service**: OmniRoute gateway (Node.js, portas 20128/20129/20132)
- **hermes-dashboard.service**: Hermes Dashboard (porta 9119, --isolated)
- Location: `home/private_dot_config/private_systemd/private_user/`

### Docker Compose Stacks (11+)
| Stack | Porta(s) | Propósito |
|-------|----------|-----------|
| Caddy | 80/443 → 8642/9119/20128/20129/20132 | Reverse proxy multi-serviço |
| Hermes | 8642 (API), 9119 (Dashboard) | Agent gateway |
| Hindsight | (internal) | PostgreSQL 18 + pgvector + Hindsight v0.9.2 |
| OmniRoute | (build turbo, 20128/20129) | AI Gateway |
| Ollama | 11434 (expose) | LLM local |
| Open WebUI | 8080 | Ollama UI |
| Qdrant | 6333/6334/6335 (expose) | Vector store |
| Redis | 6379 (expose, persistence on) | Cache/sessão |
| Uptime Kuma | 3001 | Monitoring |
| Camofox | 9377 | Browser automation |
| Dockge | 5001 (implied) | Stack manager (VPS only) |

### Networking
- **Edge network**: Caddy, Open WebUI, Camofox, Uptime Kuma (external: true)
- **Hindsight internal**: PostgreSQL + Hindsight
- **Camofox network**: Hermes ↔ Camofox
- Docker socket: Uptime Kuma has access

## Proxy Reverso / Web (Caddy — Detalhado)

Caddyfile (`home/dot_local/private_share/apps/caddy/Caddyfile.tmpl`):
```
(common) { encode zstd gzip; security headers; json log }
http://:8642 → reverse_proxy hermes:8642 (read_timeout 300s)
http://:9119  → reverse_proxy hermes:9119 (Dashboard)
http://:20128 → reverse_proxy omniroute:20128 (Dashboard)
http://:20129 → reverse_proxy omniroute:20129 (API)
http://:20132 → reverse_proxy omniroute:20132 (aux)
```
- Zstd gzip encoding
- Security headers (nosniff, frame, referrer)
- JSON log to stdout

### Hindsight Stack (PostgreSQL + pgvector)
- PostgreSQL 18 database: `hindsight`
- User: `hindsight`
- Hindsight image: `ghcr.io/vectorize-io/hindsight:0.9.2`
- Worker ID: `hindsight-vps`
- Internal DB connection: `postgresql://hindsight:${HINDSIGHT_POSTGRES_PASSWORD}@postgres-hindsight:5432/hindsight`
- Networks: hindsight-internal-network, hindsight-network

## Integrações de Automação

### Telegram
- Hermes Agent: Interação via bot
- Coding Orchestrator: Trigger via mention `@hermes coding-agent:`

### GitHub Webhooks
- Coding Orchestrator: Trigger via label `coding-agent`

### Notion MCP
- Context gathering para Coding Orchestrator
- Delivery de resultados via Notion
- Config: `private_share/apps/hermes-local/private_skills/hermes-mcp-setup/references/private_mcp-servers.md.tmpl`

### Composio
- Integração social/automation via zsh (`312-source-composio.zsh.tmpl`)
- Path: `$HOME/.composio` (Zup + hermes)
- MCP Server config em hermes

### Mem0 / Qdrant
- Memória vetorizada para context gathering do Coding Orchestrator
- Qdrant v1.19.1 (Docker stack)

## Herder (Desktop App)
- **Config**: `private_dot_config/herdr/config.toml.tmpl`
- Theme: Tokyo Night
- Multi-agent desktop environment

## Cron Jobs
- **Coding Orchestrator**: `0 2 * * *`
- **Hermes Cron**: `run_onchange_after_610-deploy-hermes-cron-jobs.sh.tmpl`
- **Himalaya Email**: `executable_cron-check-jobs.sh`, `executable_cron_job_triage.py`
- **LinkedIn**: Jobs collecting pattern, cron jobs

## Ferramentas de Sync/Backup

| Tool | Script | Propósito |
|------|--------|-----------|
| hermes-sync | `dot_local/bin/executable_hermes-sync` | Backup Hermes (config, secrets, memories, manifests) |
| omniroute-sync | `dot_local/bin/executable_omniroute-sync` | Backup OmniRoute (config, SQL, manifest) |

