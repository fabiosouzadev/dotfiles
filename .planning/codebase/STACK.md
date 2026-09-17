# STACK.md — Stack Tecnológico e Dependências

> 🧠 **From Hindsight memory (codebase map)** — Documento gerado pelo mapeamento do codebase fabiosouzadev/dotfiles em 2026-09-17.

## Visão Geral

Repositório de dotfiles gerenciado pelo [chezmoi](https://chezmoi.io) (`~/.local/share/chezmoi`), focado em reprodutibilidade, versionamento de configurações e bootstrap limpo de máquinas. Codifica um ambiente de operação completo: shell, editor, terminal, ferramentas modernas, segredos criptografados, integração com IA local/remota e fluxos de sincronização.

## Linguagens e Runtimes

| Linguagem | Uso | Versão |
|-----------|-----|--------|
| **Zsh** | Shell principal | 5.x |
| **Bash** | Shell secundário | 4.x |
| **Go** | OmniRoute (build Docker) | 1.x |
| **Node.js** (via mise) | OmniRoute, Herdr, Claude, Codex | LTS |
| **Python** | Wakatime CLI, hermes-agent, scripts | 3.x |
| **Rust** (via mise) | tree-sitter, ferramentas | latest |
| **Age** | Criptografia de segredos | v1.x |
| **GPG** | Criptografia alternativa | 2.x |
| **Docker/Compose** | 11+ stacks locais | 24.x |

## Gerenciador de Runtimes — mise

- **mise**: versionamento unificado de runtimes (Node, Python, Go, Rust, etc.)
- Install: `curl https://mise.run | sh` → `~/.local/bin/mise`
- Upgrade: `mise implode -y` + reinstall
- Ativado nos shells via `eval "$(mise activate zsh --shims)"`
- Install script: `run_once_after_503-install-mise.sh.tmpl`

## Gerenciador de Pacotes por Plataforma

| SO | Gerenciador | Scripts |
|----|-------------|---------|
| Linux (Arch/EndeavourOS/CachyOS) | pacman + paru/yay (AUR) | `run_onchange_before_201-install-arch-packages.sh.tmpl`, `run_once_before_199-install-paru.sh.tmpl` |
| Linux (Ubuntu) | apt + PPAs | `run_onchange_before_202-install-ubuntu-packages.sh.tmpl` |
| macOS | Homebrew + MacPorts | `run_onchange_after_502-install-darwin-packages-homebrew.sh.tmpl`, `run_onchange_after_501-install-darwin-packages-macports.sh.tmpl` |
| Windows (WSL) | Scoop + Winget | `run_onchange_before_201-install-winget-packages.ps1.tmpl` |
| Termux (Android) | pkg | `run_once_before_099-termux-base-packages.sh.tmpl` |

## Template Data — Listas de Pacotes

Scripts usam template data para listas de pacotes dinâmicas:
- `.packages.linux.arch.{core,extra,multilib,aur,devops,virtualisation}` — Arch packages
- `.packages.linux.ubuntu.{apt,gui,ppas,not_in_repos}` — Ubuntu packages
- `.packages.linux.wm` — Window managers (i3, niri)
- `.linux.arch.kernels` — Kernel packages (Arch)

## Ferramentas CLI Instaladas

### Shell & Terminal
- **zsh** + **zinit** (plugins: fast-syntax-highlighting, autosuggestions, completions, history-search-multi-word)
- **Starship** prompt (via zinit, auto-install from gh-r)
- **eza** (modern ls replacement)
- **bat** (modern cat, cat→bat alias on non-Ubuntu)
- **fzf** (fuzzy finder + key bindings)
- **Atuin** (magical shell history with sync, zsh-vi-mode compat)
- **zsh-vi-mode** (ZVM)
- **tmux** (compiled from source on non-managed) + TPM

### Editor & IDE
- **Neovim** (default editor, compiled from source — nightly for managed, release + tree-sitter v0.25.10 for non-managed)
- **Claude Code** (`private_config.toml.tmpl`)
- **Cursor** CLI
- **Codex** CLI
- **Gemini CLI**, **OpenCode**
- **Coderabbit** CLI, **Speckit** GitHub CLI, **gh** (GitHub CLI)
- **IntelliJ IDEA Community** (Darwin/Linux, per-workplace install)

### IA / LLM
- **Ollama** (user/root mode) + **Open WebUI** (`:8080`)
- **OmniRoute** (v3.8.50, Docker, turbo build, multi-port)
- **Hermes Agent** (multi-agent, 12 personalities, Docker stack)
- **Coding Orchestrator** (autonomous nightly coding)
- **Agentmemory** (VPS — persistent memory server)
- **Camofox** (VPS — browser automation)

### Dev/Productivity
- **lazygit**, **delta**, **gh**, **glab**, **wakatime**, **himalaya** (email)
- **hermes-sync**, **omniroute-sync** (backup tools)
- **Docker** + **Compose**
- **Caddy** (reverse proxy, VPS-only install)
- **Dockge** (stack manager, VPS-only, feature-flagged)
- **Tailscale** (VPN), **OpenVPN3**, **Instivo** (VPN)

### System (Linux)
- Kernel management (100), ZRAM+ZSWAP extreme (102), Bluetooth (220), X11 keyboard (205), virtualization (215), devops (214), WMs (216), RTL8821CE (103), Cirrus/macbook (104), Nix (207), paru (199), nvim compile (223), tmux compile (224), swapfile (102), nix (207)

## Shell e Terminal

- **Shell principal**: Zsh modular em `home/dot_zshrc.d/` (numerada 099-999)
- **Prompt**: Starship via zinit
- **Histórico**: Atuin
- **Edição**: Neovim (default, `edit: command: nvim`)
- **Multiplexador**: tmux + TPM
- **Display**: i3 (X11), Niri (Wayland), multi-monitor xrandr

## Gerenciador de Dotfiles

- **chezmoi**: gerencia todos com templates Go
- Scripts de lifecycle: `.chezmoiscripts/` por SO (darwin/linux/unix/windows/termux/vps) — 60+ scripts
- Dependências externas: `.chezmoiexternals/` (TOML-managed: git repos, archives)
- Templates reutilizáveis: `.chezmoitemplates/` (6 common + platform + workplace guards)

## Docker Stacks — 11+ Stacks

| Stack | Portas | Propósito |
|-------|--------|-----------|
| Caddy | 80/443 → 8642/9119/20128/20129/20132 | Reverse proxy multi-serviço |
| Hermes | 8642 (API), 9119 (Dashboard) | Agent gateway multi-agent |
| Hindsight | (internal) | PostgreSQL 18 + pgvector + v0.9.2 |
| OmniRoute | (build turbo) | AI Gateway v3.8.50 |
| Ollama | 11434 (expose) | LLM local |
| Open WebUI | 8080 | Ollama UI |
| Qdrant | 6333/6334/6335 | Vector store |
| Redis | 6379 | Cache (persistence on) |
| Uptime Kuma | 3001 | Monitoring |
| Camofox | 9377 | Browser automation |
| Dockge | 5001 (implied) | Stack manager (VPS) |

### Docker Networking
- **Edge** (external: true): Caddy, Open WebUI, Camofox, Uptime Kuma
- **Hindsight internal**: PostgreSQL + Hindsight
- **Camofox network**: Hermes ↔ Camofox
- **All internal**: Qdrant, Redis, OmniRoute

## Portas Expostas

| Porta | Serviço | Acesso |
|-------|---------|--------|
| 80/443 | Caddy | Internet |
| 8642/9119 | Hermes | Via Caddy + direct VPS |
| 20128/20129/20132 | OmniRoute | Via Caddy + direct IP |
| 3001 | Uptime Kuma | Docker only |
| 8080 | Open WebUI | Docker only |
| 9377 | Camofox | Docker only |
| 11434/6333/6379 | Ollama/Qdrant/Redis | Docker only |

## Ferramentas de IA e Agentes — Detalhamento

### OmniRoute (Gateway)
- Deploy: Docker Compose, build from GitHub (turbo, 4096MB)
- Base: `diegosouzapw/omniroute:3.8.49-web` + `@qoder-ai/qodercli`
- Ports: 20128 (dashboard), 20129 (API), 20132 (aux)
- Auth: Password via INITIAL_PASSWORD
- Sync: `home/dot_local/bin/executable_omniroute-sync`

### Claude Code (Anthropic via OmniRoute)
- Config: `home/dot_claude/private_config.toml.tmpl`
- Auth: `home/dot_codex/auth.json.tmpl` (age decrypt)
- Hooks: GSD lifecycle with sha256 trust hashes
- MCP: Hindsight server

### Hermes Agent
- Config: `private_share/apps/hermes-local/config.yaml.tmpl` (311 linhas)
- 12 personalities: helpful, concise, technical, creative, teacher, kawaii, catgirl, pirate, shakespeare, surfer, noir
- Feature-flagged: dashboard, agentmemory (VPS), camofox (VPS), composio (Zup)
- MCP: Hindsight, Notion, Composio
- Sync: `home/local/bin/executable_hermes-sync`

### Coding Orchestrator
- Triggers: GitHub `coding-agent` label, Telegram, webhook, cron 02:00 UTC
- Budget: $5/noite, $2/task
- Worktree isolation: `~/worktrees/task-<id>`

## Configuração de Editor — Neovim

### Build
- **Managed**: GitHub nightly + tree-sitter v0.25.10
- **Non-managed**: Compile from source (`run_once_before_223-compile-nvim.tmpl`)

## Detecção de Ambiente (`.chezmoi.yaml.tmpl`)

### Perfis
- **personal**: Default, hostname ≠ zwpe0f96cn
- **work (Zup)**: hostname contém `zwpe0f96cn` ou `CHEZMOI_PROFILE=work`
- **vps**: hostname `instance-*`, `CHEZMOI_VPS=true`, Ubuntu+Ubuntu user+SSH no GUI

### Indicadores
- CI/CD: GitHub Actions, GitLab, Travis, etc.
- Cloud IDE: Codespaces, Gitpod, Replit
- Container: DISTROBOX, LIMA, .dockerenv, cgroup, root/vscode/ubuntu
- Remote: SSH_CONNECTION, SSH_CLIENT, SSH_TTY
- GUI: DISPLAY, WAYLAND, macOS, WSL, CHEZMOI_FORCE_GUI/HEADLESS
- Mobile: TERMUX_VERSION

## Ferramentas de Backup/Sync

| Tool | Script | Propósito |
|------|--------|-----------|
| hermes-sync | `dot_local/bin/executable_hermes-sync` | Backup Hermes (config, secrets, memories, manifests) |
| omniroute-sync | `dot_local/bin/executable_omniroute-sync` | Backup OmniRoute (config, SQL, manifest) |

### Modelo Sustentável
- Arquivos pequenos estáveis + SQL seletivo + manifest
- `chezmoi add --encrypt` → git push
- NÃO inclui: state.db, logs, cache, tar.gz monolíticos

## Ferramentas Desktop

- **Herdr**: Desktop app config (`private_dot_config/herdr/config.toml.tmpl` — Tokyo Night)
- **Hermes Dashboard**: systemd service (porta 9119, --isolated)
- **Niri**: Wayland compositor (`private_dot_config/niri/`)

