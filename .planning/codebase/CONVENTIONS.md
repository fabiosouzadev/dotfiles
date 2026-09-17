# CONVENTIONS.md — Padrões de Código, Estilo e Padrões

> 🧠 **From Hindsight memory (codebase map)** — Documento gerado pelo mapeamento do codebase fabiosouzadev/dotfiles em 2026-09-17.

## Convenções de Shell Script

### Estrutura Universal
```bash
#!/usr/bin/env bash
set -euo pipefail
{{ template "common/script_helper" . }}
{{ template "linux/script_linux_only" . }}     # SO guard
{{ template "common/script_is_not_ephemeral" . }} # CI guard
{{ template "workplace/script_is_not_zup" . }}    # Profile guard
info ">>>>>> Título <<<<"
# Lógica principal
success "Sucesso"
warn "Aviso"
die "Erro"
```

### Funções Helpers (`script_helper`)
- `info "msg"` — Log informativo
- `success "msg"` — Log de sucesso (magenta)
- `warn "msg"` — Log de aviso (stderr)
- `die "msg"` — Log de erro e exit 1
- `set -euo pipefail` — Strict mode

### Guards por SO
- `linux/script_linux_only` — `if not .chezmoi.os "linux" exit 0`
- `linux/script_ubuntu_only` — Ubuntu only
- `linux/script_arch_based_only` — Arch/EndeavourOS/CachyOS
- `darwin/script_darwin_only` — macOS only
- `windows/script_windows_only` — Windows only

### Guards por Perfil (Workplace)
- `workplace/script_is_vps` — Skip unless VPS
- `workplace/script_is_not_vps` — Skip if VPS
- `workplace/script_is_zup` — Skip unless Zup
- `workplace/script_is_not_zup` — Skip if Zup
- `workplace/script_is_instivo` — Skip unless Instivo

### Guards por Ambiente
- `common/script_is_not_ephemeral` — Skip if CI/cloud IDE (`.settings.ephemeral`)
- `common/script_is_not_headless` — Skip if headless (`.settings.headless`)
- `common/script_eval_mise` — Activate mise in shell
- `common/script_helper` — Set + print functions
- `common/script_validate_completions_path` — Ensure completion dirs exist

### Emojis e Mensagens
- `🤖` AI/Tools
- `🌐` Network/Web
- `🐑` Ollama
- `📝` Delta/formatters
- `🧠` ZRAM/Swap
- `⬇️` Downloads
- `✅` Success
- `❌` Errors/skip
- `>>>` Progress indicators

## Convenções de Zsh

### Modularização
- ZDOTDIR=$HOME, sourcing de `.zshrc.d/*.zsh`
- Numeração controla ordem de carregamento
- Modelines: `# vim: filetype=bash`

### Alias Pattern
```zsh
alias -- name=value  # consistente com --
alias -- bat=batcat # condicional por SO via template
alias -- work='cd ~/Workspaces/Work/Zup'
```

### Pattern de Módulo Zsh
1. **099** — Env vars base (EDITOR, GPG_TTY, DISPLAY, PATH)
2. **100** — Zinit installer
3. **101** — Zinit plugins + Starship + eza
4. **102-104** — Histórico, FZF, Keybindings
5. **190** — Zsh vi mode
6. **200-201** — Aliases gerais + git aliases
7. **300-312** — Ferramentas específicas
8. **504** — Zup env
9. **604-606** — AI tools
10. **999** — Autoload + compinit

## Convenções TOML

### Chezmoi Externals (`.chezmoiexternals/`)
```toml
[".config/app/path"]
type = "archive" | "git-repo" | "file"
url = "https://..."
exact = true/false
stripComponents = N
refreshPeriod = "168h"
include/exclude = ["pattern"]
```

### Feature Flags em `.chezmoi.yaml.tmpl`
```toml
features = {
  ai.hermes.enabled = true
  ai.hermes.dashboard.port = 9119
  ai.hermes.dashboard.isolated = true
  ai.coding_orchestrator.install = true
  ai.coding_orchestrator.cron_schedule = "0 2 * * *"
  ai.coding_orchestrator.nightly_budget_usd = 5
  ai.coding_orchestrator.per_task_budget_usd = 2
  ollama.install = true
  ollama.mode = "user"
  i3.enabled = true
  niri.enabled = true
  sudo.enabled = true/false
  systemd.enabled = true/false
  kernels.install = false
  rtl8821ce.install = false
  dockge.install = true
  hermes.agentmemory.enabled = true
  hermes.camofox.enabled = true
  hermes.composio.enabled = true
  idea.install = { darwin = true }
  idea.workplaces = ["Zup"]
}
```

## Convenções de Configuração JSON

### Claude Code (`private_config.toml.tmpl`)
- Model: `opus[1m]`
- Reasoning: `xhigh`
- Context window: 400000
- Hooks: sha256 trust hashes (todos os hooks GSD)
- MCP: Hindsight server
- Permissions: explicit allow/deny

### Codex (`omniroute.config.toml.tmpl`)
```toml
model = "omniroute/coding"
oss_provider = "omniroute"
model_provider = "omniroute"
model_reasoning_effort = "xhigh"
model_context_window = 400000
```

### Hermes Config (`private_share/apps/hermes-local/config.yaml.tmpl`)
- Model: omniroute/agents via OMNIROUTE_BASE_URL
- Reasoning: high
- Max turns: 150
- Agention: helpful, concise, technical, creative, teacher, kawaii, catgirl, pirate, shakespeare, surfer, noir

### Hindsight Config (`private_share/apps/private_hermes/hindsight/private_config.json.tmpl`)
- Mode: local_external
- API: http://hindsight:8888
- Bank: hermes-bank
- Memory mode: hybrid
- Auto retain/recall: true

### Qwen Config (`home/dot_qwen/settings.json.tmpl`)
- Auth: qwen-oauth
- Theme: GitHub dark
- Vim mode: true

## Convenções de Git

### Commit Messages
- Prefixos: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`
- Escopo: `feat(gitconfig):`, `chore(chezmoi):`, `docs(codebase):`
- Conventional Commits

### GitConfig Multi-Perfil
- `config.tmpl` — Base config + profile-specific include
- `config.personal.inc.tmpl` — Fabio Souza, signingkey F587673EDB1A5C95
- `config.personal-ssh.inc.tmpl` — SSH key personal
- `config.vps.inc.tmpl` — Fabio Souza, signingkey C75A6078DAFE3B88, ssh id_ed25519_vps
- `config.zup.inc.tmpl` — Fabio Vanderlei (Zup), signingkey BA7F642CFD8466A1
- `config.agents.inc.tmpl` — Agentic, signingkey 232EFD8553CB22E5

### GPG Signing
Todos os commits assinados via GPG (`gpgsign = true`) com chave E691C031009FB1DAA3A25125212D516F623C5747

## Convenções de Go Templates

### Variáveis
- Locais: `{{- $var := expression -}}`
- Contexto: `.chezmoi.*`, `.dirs.*`, `.settings.*`, `.features.*`
- Compartilhadas: `{{ template "name" . }}`

### Condicionais
```go template
{{ if condition }}...{{ end }}
{{- if .settings.vps }}...{{ else }}...{{ end -}}
{{- $guiAvailable := ternary true (ternary false ...) ... -}}
```

### Decrypt
```go template
{{ include $path | decrypt | trim }}
```

### Debug Output
```go template
{{- if $interactiveTTY -}}
{{- writeToStdout "Profile: %s\n" $profile -}}
{{- end -}}
```

## Convenções de Criptografia

### age Encryption (primária)
- Chaves age por máquina (nunca no git)
- Arquivos: `encrypted_<descricao>.asc`
- Decrypt via: `{{ include ... | decrypt | trim }}`

### GPG Encryption (secundária)
- Recipient: E691C031009FB1DAA3A25125212D516F623C5747
- Config: `.chezmoi.yaml.tmpl` → `gpg: recipient`, `encryption: gpg`
- Arquivos PGP messages para credenciais AWS

### Nomenclatura
- `encrypted_<descricao>.asc` — GPG/age
- `encrypted_private_<descricao>.asc` — Altamente sensível

## Convenções Docker Compose

### Pattern por Stack
```yaml
# compose.yaml.tmpl
services:
  main:
    image: ... # ou build: ./
    env_file: .env  # encrypted_dot_env.asc
    environment:
      - PUID={{ .chezmoi.uid }}
      - PGID={{ .chezmoi.gid }}
    volumes:
      - ...
    restart: unless-stopped
    networks:
      - edge-network # ou internal
```

### Network Strategy
- **Edge**: Caddy, Open WebUI, Camofox, Uptime Kuma (external: true)
- **Hindsight internal**: PostgreSQL, Hindsight
- **Custom**: Camofox network (Hermes ↔ Camofox)
- **All internal**: Qdrant, Redis, OmniRoute

## Convenção de Numeração de Scripts

| Faixa | Categoria | Exemplo |
|-------|-----------|---------|
| 000-099 | Env/Zsh init | N/A |
| 100-199 | Runtimes/Shell | 100-install-zinit, 103-fzf |
| 200-299 | Aliases/History | 200-aliases, 201-git-aliases |
| 300-399 | Ferramentas | 311-ollama, 302-aider |
| 500-599 | Instalações | 504-zup, 590-install-ai-tools |
| 600-699 | AI/Config | 604-openclaude, 606-hermes |
| 999 | Compinit | 999-autoload-compinit |

## Padrões de Segurança

1. **Secrets nunca em texto claro**: age/GPG encrypt em todos os arquivos
2. **Diretórios privados**: `private_dot_*` para dados sensíveis
3. **Profile-based access**: personal/work/vps separados
4. **CI/CD safety**: `script_is_not_ephemeral` guards
5. **Hooks trust via sha256**: GSD hooks validados
6. **MCP deny rules**: `.env`, `.env.*`, `.secrets` negados explicitamente
7. **SSH key isolation**: 3 chaves separadas (personal, VPS, Zup) com diferentes signing keys

## Padrões de Documentação

- `README.md` — Guia principal (badges, quick start, structure)
- `docs/` — Documentação detalhada (8+ docs)
- Comentários inline em português
- Modelines em scripts shell
- Nomenclatura consistente

## Conventions Específicas Docker Compose

- `restart: unless-stopped` padrão
- `PUID`/`PGID` para Linux permissions (chezmoi.uid/gid)
- `env_file: .env` (encrypted) para secrets
- Build: `diegosouzapw/omniroute` base para OmniRoute
- Healthchecks: PostgreSQL, Redis, Qdrant (quando habilitados)

## Herder Config Patterns
- Theme: Tokyo Night (dark)
- Terminal mode: auto
- Update channel: stable
- Keys: ctrl+b prefix (tmux-like)
- Mouse capture: true
- Pane borders: true

ça

1. Secrets sempre criptografados (age/GPG)
2. Diretórios privados: `private_dot_*`
3. Profile-based access: personal/work/vps
4. Hooks Claude/Codex com sha256 trust hashes
5. MCP deny rules: .env, .env.*, .secrets
6. CI/CD safety: script_is_not_ephemeral guards
7. SSH key isolation: 3 chaves separadas
8. GPG commit signing: todos os commits assinados

## Padrões de Documentação

- README.md — Guia principal (badges, quick start, structure)
- docs/ — Documentação detalhada
- Comentários inline em português
- Modelines em scripts shell
- Nomenclatura consistente (veja STRUCTURE.md)

## Conventions Herder/App Configs

### Herdr (Desktop App)
- Theme: Tokyo Night, auto_switch: false
- Terminal: default shell, auto mode
- Keys: ctrl+b prefix
- Mouse capture: true, pane borders: true

### Caddyfile (Reverse Proxy)
- zstd gzip encoding
- Security headers (nosniff, frame, referrer)
- JSON log to stdout
- WebSocket support (Upgrade headers)
- Health check endpoint /healthz
- Reverse proxy com transport http timeouts

