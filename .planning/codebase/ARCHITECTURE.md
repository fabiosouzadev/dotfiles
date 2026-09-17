# ARCHITECTURE.md — Padrões Arquiteturais, Camadas e Fluxos de Dados

> 🧠 **From Hindsight memory (codebase map)** — Documento gerado pelo mapeamento do codebase fabiosouzadev/dotfiles em 2026-09-17.

## Filosofia Arquitetural

O repositório implementa uma arquitetura de **dotfiles como infraestrutura** — cada configuração é um recurso declarável, versionado e reprodutível. A arquitetura segue os princípios:

1. **Declarativa**: Tudo gerenciado pelo chezmoi com templates Go
2. **Modular**: Zsh modularizado, configs por feature, scripts numerados por ordem de execução
3. **Multi-plataforma**: Suporte a Linux (Arch/Ubuntu), macOS, Windows (WSL/Scoop), Termux
4. **Perfilável**: 3 perfis (personal, work/Zup, vps) com detecção automática
5. **Segura por padrão**: Segredos criptografados com age/GPG, nunca em texto claro

## Padrões Arquiteturais

### Chezmoi Convention Layer
```
chezmoi source dir/
├── home/                    → home dir dotfiles (dot_* → ~/*)
│   ├── .chezmoi.yaml.tmpl   → Configuração principal (detecção SO/perfil)
│   ├── .chezmoiexternals/   → Dependências externas (TOML-managed)
│   ├── .chezmoiscripts/     → Scripts de lifecycle por SO
│   │   ├── darwin/ linux/ unix/ windows/ termux/ vps/
│   ├── .chezmoitemplates/   → Templates/guards reutilizáveis
│   │   ├── common/ (6 guards): is_not_ephemeral, is_not_headless, eval_mise, helper, validate_completions_path, caddyfile_hermes
│   │   ├── platform/ (darwin/linux/windows/termux)
│   │   └── workplace/ (is_vps, is_zup, is_not_vps, is_not_zup, is_instivo)
│   └── dot_*                → Arquivos de configuração
├── docs/                    → Documentação
├── .planning/               → Documentação de projeto (GSD)
└── README.md                → Guia do repositório
```

### Convenção de Nomenclatura de Scripts
Os scripts de instalação seguem numeração por prioridade:
- `run_before_XXX-` → Executado antes dos scripts com número maior
- `run_once_after_XXX-` → Executado uma vez após instalação
- `run_onchange_after_XXX-` → Executado quando arquivos mudam
- Números indicam ordem de execução (ex: `504` antes de `515`)

### Padrão de Templates Go
```go template
{{- /* comentário */ -}}
{{ if condition }}
...
{{ end -}}

{{- $var := expression -}}
{{ include "path/to/template" | decrypt | trim }}
```

### Template de Detecção de Ambiente
`.chezmoi.yaml.tmpl` implementa detecção sofisticada:
1. CI indicators (env vars) — GitHub Actions, GitLab, Travis, etc.
2. Cloud IDEs (Codespaces, Gitpod, Replit)
3. Container heuristics (cgroup, .dockerenv)
4. Remote/SSH session detection
5. TTY/interactive detection
6. GUI detection (DISPLAY/WAYLAND)
7. SO específico (WSL, macOS, Linux distro)
8. Perfil/Workplace detection (personal/work/VPS)
9. Hardware hints (Dell 3530/3520, Linux-on-MacBook)

### Fluxo de Dados: Inicialização

```
Usuário clona repo → chezmoi init --apply
        ↓
  .chezmoi.yaml.tmpl renderizado
        ↓
  Detecção de SO/Perfil/Ambiente
        ↓
  .chezmoiscripts/{os}/ executados em ordem numérica
        ↓
  Pacotes instalados → Configs → Services → Secrets decryptados
        ↓
  Shell configs carregados (.zshrc → dot_zshrc.d/*.zsh)
```

### Fluxo de Dados: Criptografia de Segredos

```
Arquivo original (texto claro)
        ↓
  age encrypt (ou GPG)
        ↓
  encrypted_*.asc armazenado no git
        ↓
  Template usa: {{ include $path | decrypt | trim }}
        ↓
  Valor descriptografado injetado em runtime
```

### Fluxo de Dados: IA Stack

```
Usuário → Claude Code / Codex / Gemini / Aider
        ↓
  OmniRoute (gateway local)
        ↓
  ├── Modelo local: Ollama (11434)
  ├── Modelo remoto: Anthropic/GPT/Gemini via proxy
  └── Fallback automático entre provedores
        ↓
  Resposta → Usuário / Agente / Cron Job
```

### Fluxo de Dados: Hermes

```
Hermes Agent (serviço Docker)
        ↓
  ├── Skills: private_skills/ (devops, productivity, research)
  ├── Memórias: Qdrant (vector store, PostgreSQL+pgvector)
  ├── Dashboard: Porta 9119 (via Caddy reverse proxy)
  ├── Gateway: systemd service / Docker container (porta 8642)
  ├── Telegram: Interação via bot
  ├── Multi-personalidades: helpful, concise, technical, creative,
  │   teacher, kawaii, catgirl, pirate, shakespeare, surfer, noir
  └── MCP: Hindsight, Notion, Composio
```

### Fluxo de Dados: Coding Orchestrator

```
Trigger (GitHub label / Telegram / Webhook / Cron 02:00 UTC)
        ↓
  Coding Orchestrator
        ↓
  Context gathering (GitHub API, Git diff, Notion MCP, mem0)
        ↓
  Seleção de agente (Aider padrão via OmniRoute, Claude, Codex, Gemini, OpenCode)
        ↓
  Worktree isolada: ~/worktrees/task-<id>
        ↓
  Execução com budget ($5/noite, $2/task)
        ↓
  Delivery (Telegram, Notion, GitHub PR comments)
```

### Fluxo de Dados: Docker Networking

```
Edge Network (external):
  Caddy (80/443) ←→ reverse proxy para:
    ├── hermes:8642 (API) e hermes:9119 (Dashboard)
    ├── omniroute:20128/20129/20132 (API/Dashboard)
    ├── camofox:9377 (Browser automation)
    └── openwebui:8080 (Ollama UI)

Internal Network:
  ├── postgres-hindsight (PostgreSQL 18 + pgvector)
  ├── redis (8.6.5-alpine, persistence on)
  ├── qdrant (v1.19.1, vector store)
  └── omniroute (build from source, turbo)
```

## Camadas do Sistema

### Camada 1 — OS Kernel & Init
- systemd (Linux) / launchd (macOS) / service management (Termux)
- Kernel management: `run_once_before_100-install-linux-kernels.sh.tmpl`
- RTL8821CE WiFi driver: `run_once_before_103-install-rtl8821ce-driver.sh.tmpl`
- Cirrus driver (MacBook): `run_once_before_104-install-cirrus-driver-for-macbook.tmpl`
- Bluetooth (Arch): `run_once_before_220-configure-bluetooth-arch.sh.tmpl`

### Camada 2 — Package Manager
- pacman/paru (Arch), apt (Ubuntu), brew/macports (macOS), scoop/winget (Windows), pkg (Termux)
- Package lists via templates: `.packages.linux.arch.{core,extra,multilib,aur,devops,virtualisation}`, `.packages.linux.ubuntu.{apt,gui,ppas}`
- Managed by scripts numerados por SO

### Camada 3 — Runtimes
- **mise**: versionamento de runtimes (Node, Go, Python, Rust, etc.) — `run_once_after_503-install-mise.sh.tmpl`
- Install scripts com `mise implode` para upgrade clean

### Camada 4 — Shell & Terminal
- Zsh + zinit + plugins (fast-syntax-highlighting, autosuggestions, completions, history-search)
- Starship prompt, Atuin history, fzf fuzzy finder
- Terminal multiplexing: tmux (compiled from source on non-managed) + TPM
- Window managers: i3 (X11) e Niri (Wayland) — feature-flagged, VPS skip
- **Niri config**: `private_dot_config/niri/` (config.kdl + cfg/{autostart,keybinds,input,display,layout,animations,rules,misc}.kdl)

### Camada 5 — Editor & IDE
- Neovim (default editor, compiled from source on non-managed VMs)
  - `run_once_before_223-compile-nvim.tmpl` — nightly build for managed, release for non-managed + tree-sitter
- Claude Code, Cursor, Codex, Gemini CLI, OpenCode
- Coderabbit CLI (`run_once_after_515-install-coderabbit-cli.sh.tmpl`)
- IntelliJ IDEA Community (Darwin, Linux — feature-flagged by workplace)
- Speckit GitHub CLI (`run_once_after_521-install-speckit-github-cli.sh.tmpl`)

### Camada 6 — AI & Agents
- **OmniRoute**: Gateway AI (Docker, v3.8.50, turbo build, multi-port)
  - Dockerfile: `dot_local/opt/stacks/omniroute/Dockerfile`
  - Image: `diegosouzapw/omniroute:3.8.49-web` base + qoder-ai/qodercli
- **Ollama**: LLM local (user/root mode by platform)
  - Models: `run_onchange_after_505-install-ollama-models.sh.tmpl` (template-driven list)
  - Open WebUI (`:8080`, OLLAMA_BASE_URL=http://ollama:11434)
- **Hermes Agent**: Agente pessoal com Docker stack
  - Config: `private_share/apps/hermes-local/config.yaml.tmpl` (311 linhas)
  - Features: hermes.dashboard, hermes.agentmemory, hermes.camofox, hermes.composio
  - Personalidades: helpful, concise, technical, creative, teacher, kawaii, catgirl, pirate, shakespeare, surfer, noir
  - MCP Servers: Hindsight, Notion, Composio
- **Camofox**: Browser automation (`:9377`)
  - Cookies, profiles, traces dirs persistentes
- **Coding Orchestrator**: Agentes autônomos noturnos
  - Install: `run_once_after_540-install-coding-orchestrator.sh.tmpl`
  - Cron deploy: `run_onchange_after_610-deploy-hermes-cron-jobs.sh.tmpl`
- **Agentmemory**: Persistent memory server (VPS only)
  - Install: `run_once_after_531-install-agentmemory.sh.tmpl`

### Camada 7 — Infrastructure & DevOps
- **Docker Compose** (11+ stacks em `dot_local/opt/stacks/`):
  - Caddy (reverse proxy, edge network, UFWS auto-config), Camofox, Hermes, Hindsight (pg18+pgvector), Omniroute, Ollama, Open WebUI, Qdrant (v1.19.1), Redis (8.6.5-alpine), Uptime Kuma (`:3001`), Dockge (stack manager)
  - Cada stack: compose.yaml.tmpl + encrypted_dot_env.asc
- **Caddy**: Reverse proxy (portas 8642/9119/20128/20129/20132)
  - Caddyfile: `private_share/apps/caddy/Caddyfile.tmpl` (reverse proxy + WebSocket + healthz)
- **Tailscale**: VPN ponto a ponto
- **AWS SSO** (ClaroCorp): `private_dot_config/git/config.tmpl` integrado
- **Dockge**: Stack manager UI (VPS only, feature-flagged)

### Camada 8 — Secrets & Security
- age encryption, GPG, encrypted files
- private_dot_* directories (chezmoi-managed private)
- SSH keys, API keys, credentials (todos criptografados)
- Swap/ZRAM extreme config: `run_once_before_102-configure-swapfile-zram.sh.tmpl`
- Keyboard X11 config: `run_once_before_205-configure-keyboard-xorg.sh.tmpl`

## Abstrações Principais

### Perfiles (`.chezmoi.yaml.tmpl`)
- **personal**: Desktop pessoal, sem sudo, sem systemd
- **work (Zup)**: Workplace, chaves Zup, APIs corporativas
- **vps**: Oracle Cloud, auto-detectado, com sudo e systemd

### Feature Flags
Configurados em `.chezmoi.yaml.tmpl`:
- `features.ai.*`: hermes (enabled, dashboard, composio, camofox, agentmemory), coding_orchestrator, coding_assistants, spec_tools, multiplexer, ollama (install, mode, version, path, localmodels, models), i3, niri, sudo, systemd, kernels, rtl8821ce, dockge
- `features.idea.install/workplaces`: IntelliJ per-workplace install

### Guard Templates (`.chezmoitemplates/`)
- **common/**: `script_is_not_ephemeral`, `script_is_not_headless`, `script_eval_mise`, `script_helper`, `script_validate_completions_path`, `caddyfile_hermes.tmpl` (define)
- **platform/**: `darwin_only`, `linux_only`, `ubuntu_only`, `arch_based_only` (endeavouros/cachyos), `windows_only`
- **workplace/**: `script_is_vps`, `script_is_zup`, `script_is_not_vps`, `script_is_not_zup`, `script_is_instivo`

### Template Data Structures
- `.dirs.local/bin/src` — Caminhos para ~/.local
- `.dirs.workspaces.{personal,others,work,zup}` — Diretórios de trabalho
- `.packages.linux.arch.{core,extra,multilib,aur,devops,virtualisation}` — Listas de pacotes Arch
- `.packages.linux.ubuntu.{apt,gui,ppas}` — Listas de pacotes Ubuntu
- `.features.hermes.{enabled,dashboard.port/host/domain,isolated,agentmemory.enabled,camofox.enabled,composio.enabled}` — Feature Hermes

## Entry Points

| Entry Point | Propósito |
|-------------|-----------|
| `home/.chezmoi.yaml.tmpl` | Configuração central do chezmoi + detecção |
| `home/dot_zprofile.tmpl` | Zsh login shell (PATH, MacPorts) |
| `home/dot_zshrc.tmpl` | Zsh config loader (ZDOTDIR, .zshrc.d) |
| `home/dot_bashrc` | Bash config (herança Ubuntu default) |
| `home/dot_zshrc.d/099-zshenv.zsh.tmpl` | Env vars base (EDITOR, DISPLAY, PATH) |
| `home/dot_zshrc.d/999-autoload-compinit.zsh.tmpl` | Compinit autoload |
| `.chezmoiscripts/{os}/run_once_*` | Bootstrap scripts por SO |
| `home/dot_local/bin/executable_*` | Ferramentas customizadas (hermes-sync, omniroute-sync) |

## Ferramentas de Backup/Sync

### hermes-sync (`home/local/bin/executable_hermes-sync`)
Modelo sustentável para backup do Hermes:
- **Entra**: config.yaml, .env, auth.json, memories, cron jobs, gateway state, manifests (SQL, TSV)
- **Não entra**: state.db, sessions, logs, cache, node_modules, backups tar.gz
- Modelo: arquivos pequenos estáveis + SQL seletivo + manifest → chezmoi add --encrypt → git push

### omniroute-sync (`home/local/bin/executable_omniroute-sync`)
Sincronização seletiva de estado OmniRoute:
- **Criptografados**: .env, config.sql, sync/manifest.json, sync/backup-note.txt
- **Forbidden patterns**: private_backup.tar.gz, private_storage.sqlite, private_call_logs, private_logs
- Modelo: config pequena + secrets + export seletivo SQLite + manifest

## Abordagem Multi-OS

```
                    ┌───────────┐
                    │  macOS    │ ← brew, macports, zsh, i3 (não), Docker
                    └─────┬─────┘
                          │
         ┌────────────────┼────────────────┐
         │                │                │
    ┌────▼────┐    ┌─────▼─────┐   ┌──────▼──────┐
    │ Linux   │    │  WSL      │   │   Termux    │
    │ Arch    │    │ (Windows) │   │ (Android)   │
    │ Ubuntu  │    │           │   │             │
    └────┬────┘    └─────┬─────┘   └──────┬──────┘
         │               │                │
         └───────────────┼────────────────┘
                         │
                    ┌────▼────┐
                    │Shared   │ ← git, chezmoi, zsh, AI tools
                    │ Tools   │
                    └─────────┘
```

## Docker Networking Layout

```
                    Internet
                       │
                   ┌───▼───┐
                   │ Caddy │ (80/443 → edge network)
                   └───┬───┘
                       │
          ┌────────────┼──────────────┐
          │            │              │
     hermes:9119  omniroute:20128  openwebui:8080
     hermes:8642  omniroute:20129  camofox:9377
     (via HTTPS)  (via HTTPS)      (via HTTPS)
          │
    ┌─────┼──────┐
    │     │      │
  pg18   Redis  Qdrant  (hindsight internal network)
  +pgvector         (expose only, no ports)
```

## Conventions Detalhadas de Script

### Pattern de Script Linux
```bash
#!/usr/bin/env bash
set -euo pipefail
{{ template "common/script_helper" . }}
{{ template "linux/script_linux_only" . }}
{{ template "common/script_is_not_ephemeral" . }}
{{ template "workplace/script_is_not_zup" . }}
info ">>>>>> Título <<<<"
# Lógica principal
success "Sucesso"
```

### Success/Error Helpers
- `info "msg"` — Log informativo
- `success "msg"` — Log de sucesso (magenta)
- `warn "msg"` — Log de aviso
- `die "msg"` — Log de erro e exit 1
