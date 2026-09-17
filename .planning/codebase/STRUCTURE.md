# STRUCTURE.md — Layout de Diretórios e Organização

> 🧠 **From Hindsight memory (codebase map)** — Documento gerado pelo mapeamento do codebase fabiosouzadev/dotfiles em 2026-09-17.

## Estrutura Raiz

```
/home/fabio.souza/.local/share/chezmoi/
├── .git/                          # Versionamento Git (main, v1.0 tag)
├── home/                          → $HOME (dotfiles mapeados)
├── docs/                    → Documentação do projeto
├── .planning/                     → Documentação GSD/Planejamento
│   └── codebase/                  ← documentos deste mapa
└── README.md                → Guia principal do repo
```

## Estrutura de `home/` (Dotfiles)

### Configuração Central
- `.chezmoi.yaml.tmpl` — Configuração principal chezmoi (detecção SO/perfil/feature flags, ~400 linhas de template)
- `.chezmoidata/` — Dados por plataforma (darwin/linux/windows/termux)
- `.chezmoiexternals/` — Dependências externas (TOML-managed downloads)
  - `git.toml.tmpl` — catppuccin/delta themes
  - `atuin.toml.tmpl` — catppuccin/atuin themes
  - `i3.toml.tmpl` — polybar-themes + rofi-themes
  - `tmux.toml.tmpl` — tmux-plugins/tpm (git repo)
  - `wallpapers.toml.tmpl` — wallpapers repo (git repo)
  - `firefox.toml.tmpl` — FF-ULTIMA/FirefoxGX (comentado)
  - `icons.toml.tmpl` — Papirus (comentado)
- `.chezmoiscripts/` — Scripts de lifecycle por SO (numerados)
- `.chezmoitemplates/` — Templates/guards reutilizáveis

### Dotfiles Principais
- `dot_zprofile.tmpl` — Zsh login (PATH, MacPorts Darwin only)
- `dot_zshrc.tmpl` — Zsh config principal (ZDOTDIR, .zshrc.d)
- `dot_bashrc` — Bash config (herança Ubuntu default)
- `dot_zshrc.d/` — Zsh modular (arquivos numerados 099-999 + encrypted + termux)
- `dot_codex/` — Codex/Claude Code configs (auth, omniroute config, private config)
- `dot_qwen/` — Qwen Code config (settings.json)
- `dot_claude/` — Claude Code settings (hooks, MCP, permissions, theme)
- `dot_aws/` — AWS SSO config + encrypted creds (ClaroCorp)
- `dot_keys/` — Chaves criptografadas (Omniroute, Hindsight, Wakatime, GitHub, Zup, Instivo, SSH)
- `dot_local/` — ~/.local (bin, share, opt)
- `dot_screenlayout/` — Display management (xrandr scripts)

### Diretórios Privados (`private_dot_*`)
- `private_dot_ssh/` — Chaves SSH (criptografadas + públicas: VPS, personal, Zup)
- `private_dot_config/` — Configs privados de apps
  - `git/config.{personal,personal-ssh,vps,zup,agents}.inc.tmpl` — Git multi-perfil (assinatura GPG por perfil!)
  - `niri/` — Compositor Wayland (config.kdl + 8 cfg/*.kdl)
  - `bat/themes/Catppuccin Mocha.tmTheme`
  - `herdr/config.toml.tmpl` — Herdr config (Tokyo Night, terminal, keys, ui)
  - `rust/config.toml.tmpl` — Rust config
  - `dunst/empty_dunstrc` — Dunst config
  - `wezterm/wezterm.lua.tmpl` — WezTerm config
  - `mozilla/private_firefox/` — Firefox profiles (profiles.ini, installs.ini, user.js)
  - `private_systemd/private_user/` — systemd services (omniroute, hermes-dashboard)
  - `wakatime/cfg/` — Wakatime config
- `private_dot_hermes/` — Estado Hermes (criptografado)
- `private_dot_wakatime.cfg.tmpl` — Wakatime config (decrypt)
- `private_dot_mozilla/private_firefox/` — Firefox profiles
- `private_dot_config/private_share/apps/` — Apps privados compartilhados

### Aplicações Privadas (`private_share/apps/`)
- `hermes-local/` — Config, secrets, skills (devops, productivity, research), documents
  - `private_skills/devops/` — 14+ skills (chezmoi-*, dockge, omniroute*, dotfiles-*, linkedin*)
  - `private_skills/productivity/` — job-triage, linkedin-*, himalaya-email
  - `private_skills/hermes-mcp-setup/` — MCP setup scripts/references
  - `private_skills/research/` — loop-engineering-web-extraction
- `private_hermes/` — Hindsight config (`hindsight/private_config.json.tmpl`), documents
- `caddy/` — Caddyfile (reverse proxy)
- `camofox/` — Cookies (encrypted), browser config

## Estrutura de `.chezmoiscripts/`

### Por SO (~60+ scripts numerados)
- **darwin/** (5) — macOS package managers, Ollama, IDEA, tmux compile
- **linux/** (25+) — Kernels, Zsh init, package managers (paru/nix/devops/virtualisation), WMs, Bluetooth, swap/ZRAM, Neovim compile, tmux compile, keyboard config
- **unix/** (18) — Mise, AI tools, Coding Orchestrator, Hermes sync tools, language tools, Atuin, Caddy
- **windows/** (3) — Scoop/Winget packages, IDEA Community
- **termux/** (3) — Android setup, SSH, Tailscale, base packages
- **vps/** (4) — Dockge, Caddy, Agentmemory, Camofox (VPS-only)

### Convenção
`{run_before|run_once|run_onchange}_NNN-{desc}.{sh|ps1}.tmpl`

## Estrutura de `.chezmoitemplates/`

- **common/** (6 files):
  - `script_is_not_ephemeral` — Skip in CI/cloud IDEs
  - `script_is_not_headless` — Skip without GUI
  - `script_eval_mise` — Activate mise
  - `script_helper` — Pretty print functions (info/success/warn/die), set -euo pipefail
  - `script_validate_completions_path` — Ensure completions dir exists
  - `caddyfile_hermes.tmpl` — define "caddyfile/hermes" (reverse proxy config)
- **platform/** (6 files): darwin_only, linux_only, ubuntu_only, arch_based_only (endeavouros/cachyos), windows_only, linux_on_mac
- **workplace/** (5 files): is_vps, is_zup, is_not_vps, is_not_zup, is_instivo

## Estrutura de `docs/`

> Nota: docs/ existe no repositório mas não está no snapshot atual do filesystem. Documentação referência: ARCHITECTURE.md, CONFIGURATION.md, GETTING-STARTED.md, HERMES-BACKUP.md, OMNIROUTE-BACKUP.md, KEYMAPS.md, FORK-GUIDE.md, WINDOWS-SETUP.md.

## Docker Stacks (`home/dot_local/opt/stacks/`)

Cada stack em `<name>/`:
- `compose.yaml.tmpl` — Docker Compose config (30+ linhas cada)
- `encrypted_dot_env.asc` — Env vars criptografados
- `Dockerfile` — (Omniroute only)

**11+ Stacks**: Ollama, Open WebUI, OmniRoute (build: turbo), Hermes (multi-network), Hindsight (pg18+pgvector), Qdrant v1.19.1, Redis 8.6.5-alpine (persistence), Uptime Kuma (`:3001`), Camofox (browser), Caddy (multi-port reverse proxy), Dockge (VPS), Hindsight (PostgreSQL+pgvector+Hindsight v0.9.2)

## Configuração Niri (Wayland)

`home/private_dot_config/niri/`:
- `config.kdl` — Main config (includes all cfg/*.kdl)
- `cfg/autostart.kdl` — Startup apps (polkit-gnome)
- `cfg/keybinds.kdl` — Keybindings (mod + XKB)
- `cfg/input.kdl` — Keyboard xkb settings
- `cfg/display.kdl` — Output configuration
- `cfg/layout.kdl` — Window placement, gaps 16px
- `cfg/animations.kdl` — Animation settings
- `cfg/rules.kdl` — Window rules (WezTerm workaround)
- `cfg/misc.kdl` — Hotkey overlay, CSD

## Convenções de Nomeação

| Padrão | Propósito | Exemplo |
|--------|-----------|---------|
| `dot_*` | Arquivo de dotfile (chezmoi → ~/*) | `dot_zshrc.tmpl` → `~/.zshrc` |
| `run_before_XXX-*` | Script antes de numeral maior | `run_before_204-init-zsh.sh.tmpl` |
| `run_once_after_XXX-*` | Script instalação única | `run_once_after_503-install-mise.sh.tmpl` |
| `run_onchange_after_XXX-*` | Script ao mudar config | `run_onchange_after_605-clone-my-repos.sh.tmpl` |
| `encrypted_*.asc` | Arquivo criptografado (age/GPG) | `encrypted_omniroute-key.txt.asc` |
| `*.tmpl` | Template Go | `dot_zshrc.tmpl` |
| `private_*` | Arquivo privado (sensitivo) | `private_dot_ssh/` |
| `executable_*` | Executável incluído no repo | `executable_hermes-sync` |
| `private_SKILL.md` | Skill privada Hermes | `private_skills/devops/...` |

## Zsh Modular (`dot_zshrc.d/`) — Detalhamento

Ordem de carregamento por numeração:
1. **099** — Env vars base (EDITOR, GPG_TTY, DISPLAY, PATH)
2. **100** — Zinit installer (clone + source)
3. **101** — Zinit plugins: fast-syntax-highlighting, autosuggestions, completions, history-search-multi-word; Starship; eza
4. **102** — Histórico config (HISTSIZE=1B, EXTENDED_HISTORY, autocd)
5. **103** — FZF key bindings + completion
6. **104** — Keybindings vi mode
7. **190** — Zsh vi mode plugin (ZVM)
8. **200** — Aliases gerais (nvim→v, bat/cat, eza, grep→rg, df, du, reload, direnv, work/personal dirs)
9. **200** — Atuin (shell history sync, zsh-vi-mode compat)
10. **201** — Git aliases extensos (35+ aliases: g, gl, gp, gd, gcm, etc.)
11. **302** — Aider env setup
12. **311** — Ollama aliases (start/stop/restart/status + Open WebUI docker alias)
13. **312** — Composio install path (Zup + hermes)
14. **504** — Zup workplace env (OLLAMA, GITHUB, GEMINI, CURSOR, OPENCODE API keys)
15. **604** — Claude Code config (providers, models, hooks)
16. **605** — OmniRoute API key (age decrypt)
17. **606** — Hermes aliases (Linux systemd / macOS) + universal management aliases
18. **999** — Autoload + compinit
19. **Encrypted** — Chaves API/SSH (loaded via decrypt)
20. **Termux** — Termux-specific config

## Git Multi-Perfil (Detalhamento)

`.chezmoi.yaml.tmpl` define:
```toml
gpg:
  recipient: E691C031009FB1DAA3A25125212D516F623C5747
```

Git configs por perfil (assinaturas GPG diferentes!):
- **Personal**: Fabio Souza, email fabiosouzadev@users.noreply.github.com, signingkey F587673EDB1A5C95
- **Agentic** (agents): email 1536954+fabiosouzadev@users.noreply.github.com, signingkey 232EFD8553CB22E5
- **Zup**: Fabio Vanderlei de Souza (Zup), fabio.vanderlei@zup.com.br, signingkey BA7F642CFD8466A1
- **VPS**: Fabio Souza, signingkey C75A6078DAFE3B88
- **Personal SSH**: ssh -i ~/.ssh/id_ed25519_personal
- **VPS SSH**: ssh -i ~/.ssh/id_ed25519_vps
- **Zup SSH**: ssh -i ~/.ssh/id_ed25519_zup

