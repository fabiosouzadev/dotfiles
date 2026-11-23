---
last_mapped_commit: d1d1c1c967319d6aa2852d6caaee2123acced521
last_mapped_at: 2026-11-23
---
# External Integrations

**Analysis Date:** 2026-11-23

## APIs & External Services

**AI & Coding Assistants:**
- **Anthropic Claude** - LLM API via OmniRoute gateway
  - SDK/Client: OmniRoute (local gateway)
  - Config: `home/dot_claude/settings.json.tmpl`
  - Auth: OmniRoute token stored in encrypted file
  - Base URL: `http://193.123.97.209:20129/v1` (OmniRoute endpoint)
  - Env vars: `ANTHROPIC_BASE_URL`, `ANTHROPIC_AUTH_TOKEN`
  
- **OpenAI API** - GPT models via OmniRoute gateway
  - SDK/Client: OmniRoute
  - Config: `home/dot_codex/auth.json.tmpl`
  - Auth: OmniRoute token
  - Env var: `OPENAI_API_KEY`

- **GitHub Copilot** - Via `@github/copilot@prerelease` NPM package
  - Feature flag: `features.ai.harness`
  - Env var: `GITHUB_COPILOT_TOKEN`

- **Qwen Code Assistant** - Via `@qwen-code/qwen-code` NPM package
  - Feature flag: `features.ai.harness`

- **Gemini (Google)** - Code completion via Gemini CLI
  - Feature flag: `features.ai.harness`

- **Deepseek** - Deepseek harness via GitHub clone
  - URL: `https://github.com/deepseek-ai/deepseek-harness`
  - Feature flag: `features.ai.harness`

- **Zhipu Glm (GLM4)** - API for large model inference
  - Env var: `ZAI_OPENAI_API_KEY` (via Zhipu gateway)
  - Base URL: `https://open.bigmodel.cn/api/paas/v4/`

- **Cerebras** - Inference API
  - Env var: `CEREBRAS_OPENAI_BASE_URL` (via Zup config)
  - Feature flag: `features.ai.harness`

- **Aider** - Pair programming AI tool
  - Installer: Curl from `https://aider.chat/install.sh`
  - Feature flag: `features.ai.harness`

**Version Control & Repository:**
- **GitHub API** - Via `gh` (GitHub CLI)
  - Auth: `GITHUB_TOKEN` environment variable
  - Used in: Release fetching, issue management, PR operations
  - Config in: `home/dot_zshrc.d/504-zup.zsh.tmpl`

- **GitLab API** - Via `glab` (GitLab CLI)
  - Installed via: `home/.chezmoiscripts/unix/run_once_after_528-install-glab.sh.tmpl`
  - Auth: `GITLAB_TOKEN` (inferred from GitLab patterns)

**Code Review & Analysis:**
- **CodeRabbit** - Automated code review
  - CLI: `@coderabbit/coderabbit` (NPM)
  - Installer: `home/.chezmoiscripts/unix/run_once_after_515-install-coderabbit-cli.sh.tmpl`

- **SpecKit** - OpenAPI specification tools
  - CLI: `@speckit/spec-kit-github-cli`
  - Installer: `home/.chezmoiscripts/unix/run_once_after_521-install-speckit-github-cli.sh.tmpl`

**Telemetry & Activity Tracking:**
- **WakaTime** - Developer activity and time tracking
  - CLI: `wakatime-cli`
  - Installer: `home/.chezmoiscripts/unix/run_once_after_534-install-wakatime-cli.sh.tmpl`
  - Env var: `WAKATIME_API_KEY` (inferred)

**Cloud Infrastructure:**
- **DuckDNS** - Dynamic DNS for custom domains
  - Domain: `fabiosouzadev.duckdns.org`
  - Used for: Hermes dashboard and OmniRoute web access
  - Feature flag: VPS profile

- **Oracle Cloud** - VPS hosting provider
  - Detection: Hostname starts with `instance-` or env `CHEZMOI_VPS`
  - Security: Oracle Cloud Security List must allow inbound traffic

- **Tailscale** - Zero-trust VPN mesh networking
  - Feature flag: `features.tailscale.enabled`
  - Installer: `home/.chezmoiscripts/unix/run_once_after_556-configure-tailscale.sh.tmpl`
  - Enables: Remote access to local services and mesh networking

## Data Storage

**Databases:**
- **DBeaver** - Database client (UI only, no server integration)
  - Supported: PostgreSQL, MySQL, MongoDB, Cassandra, etc.
  - Installation: Windows (Winget), Linux (Arch AUR), macOS (Homebrew)

- **MongoDB Compass** - MongoDB GUI client
  - Installation: Arch AUR (`mongodb-compass-bin`)
  - Windows Scoop: via `extras/models` bucket

**File Storage:**
- **Local filesystem only** - No cloud storage integrations detected
- **LocalSend** - LAN-based file sharing (not cloud storage)
  - Installation: Arch AUR (`localsend-bin`)

**Caching:**
- **Ollama** - Local LLM caching and serving
  - Models stored in: `~/.ollama/`
  - Configuration: `home/.chezmoidata/ollama.yaml`

## Authentication & Identity

**Auth Provider:**
- **Custom via OmniRoute gateway** - Local proxy authentication
  - Implementation: Token-based auth with encrypted keys
  - Encrypted keys: `home/dot_keys/encrypted_omniroute-key.txt.asc`, `home/dot_keys/encrypted_omniroute-key-zup.txt.asc`
  - Decryption: GPG with recipient `E691C031009FB1DAA3A25125212D516F623C5747`

- **Hermes Authentication** - Basic HTTP Auth
  - Configuration: `~/.hermes/config.yaml` via `dashboard.basic_auth`
  - Method: Username/password basic authentication

- **GitHub OAuth** - Via GitHub CLI (`gh`)
  - Automatic: `gh auth login` on first use
  - Token stored: System credential manager

- **Multiple SSO Integrations** (inferred from env vars):
  - GitHub personal access token: `GITHUB_PERSONAL_ACCESS_TOKEN`
  - GitHub app token: `GITHUB_TOKEN`
  - Various workspace-specific tokens (Zup workspace)

## Monitoring & Observability

**Error Tracking:**
- Not detected

**Logs:**
- **Systemd Journal** - For service logs (Linux only)
  - Services: OmniRoute, Hermes Dashboard, AgentMemory
  - Config: `StandardOutput=journal`, `StandardError=journal` in service files
  - Tail logs: `journalctl --user -u omniroute -f`

## CI/CD & Deployment

**Hosting:**
- **Oracle Cloud Compute** - VPS for Hermes and OmniRoute services
  - Auto-detected via VPS profile (`$isVps` flag)
  - Runs: Caddy reverse proxy, Hermes dashboard, OmniRoute gateway

**CI Pipeline:**
- **GitHub Actions** - Detected for CI/CD
  - Detection: `GITHUB_ACTIONS` env var
  - Used in: Deployment automation, testing, releases

- **GitLab CI** - Support included
  - Detection: `GITLAB_CI` env var

- **Other CI Platforms Supported:**
  - Travis CI, CircleCI, Buildkite, Drone, Azure DevOps, Jenkins

## Environment Configuration

**Required env vars (Core):**
- `CHEZMOI_PROFILE` - Set profile: `personal`, `work`, `vps` (auto-detected if not set)
- `ANTHROPIC_BASE_URL` - OmniRoute endpoint
- `ANTHROPIC_AUTH_TOKEN` - OmniRoute API key
- `OPENAI_API_KEY` - For OpenAI models
- `GITHUB_TOKEN` - GitHub API access
- `GITHUB_PERSONAL_ACCESS_TOKEN` - Personal GitHub token
- `GITHUB_COPILOT_TOKEN` - Copilot CLI auth

**Optional Overrides (Feature Control):**
- `CHEZMOI_VPS` - Force VPS profile detection
- `CHEZMOI_FORCE_GUI` - Force GUI availability
- `CHEZMOI_FORCE_HEADLESS` - Force headless mode
- `CHEZMOI_SKIP_SHELL_PROBES` - Skip expensive shell probes
- `CHEZMOI_HERMES_DASHBOARD_PORT` - Hermes port (default 9119)
- `CHEZMOI_HERMES_DASHBOARD_HOST` - Hermes bind address (default 127.0.0.1 local, 0.0.0.0 VPS)
- `CHEZMOI_HERMES_DASHBOARD_DOMAIN` - Hermes domain
- `CHEZMOI_OMNIROUTE_DASHBOARD_PORT` - OmniRoute port (default 20128)
- `CHEZMOI_OMNIROUTE_BIND` - OmniRoute bind address
- `CHEZMOI_OMNIROUTE_DOMAIN` - OmniRoute domain

**Workspace-Specific (Zup Integrations):**
- `ZUP_GITHUB_PERSONAL_ACCESS_TOKEN` - Zup GitHub token
- `ZUP_GITHUB_TOKEN` - Zup workspace GitHub token
- `ZUP_GITHUB_COPILOT_TOKEN` - Zup Copilot token
- `ZUP_OPENROUTER_OPENAI_BASE_URL` - Zup OpenRouter endpoint
- `ZUP_CEREBRAS_OPENAI_BASE_URL` - Zup Cerebras endpoint
- `ZAI_API_KEY` - Zup Zhipu GLM API key (for both OpenAI and Anthropic base URLs)

**OmniRoute-Specific:**
- `INITIAL_PASSWORD` - OmniRoute dashboard password (default: CHANGEME)

**Hermes Dashboard:**
- Basic Auth credentials in: `~/.hermes/config.yaml` (`dashboard.basic_auth`)

**Secrets location:**
- Primary: `.env` files (`.omniroute/.env`, `~/.hermes/.env`)
- Encrypted: `home/dot_keys/encrypted_*.txt.asc` (GPG-encrypted)
- Managed by: Chezmoi encryption/decryption on apply

## Webhooks & Callbacks

**Incoming:**
- **GitHub Webhooks** - Trigger coding orchestrator
  - Labels: `coding-agent` triggers Hermes automation
  - Handler: `coding-orchestrator` skill in Hermes
  
- **Telegram Webhook** - Integration for bot mentions
  - Mention: `@hermes coding-agent:` triggers task
  - Handler: Hermes Telegram bot interface

**Outgoing:**
- **GitHub PR Comments** - Coding orchestrator delivers results
  - Integration: Automated PR comments on task completion
  
- **Telegram Messages** - Delivery of AI task results
  - Integration: Status updates and results sent via Telegram bot
  
- **Notion Pages** - Task tracking and documentation
  - Integration: MCP (Model Context Protocol) for Notion API
  - Used by: Coding orchestrator for context gathering and result logging

---

*Integration audit: 2026-11-23*
