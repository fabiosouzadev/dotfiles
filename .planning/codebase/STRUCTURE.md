# Structure — Organização do Repositório

> Estrutura de diretórios, convenções de nomenclatura e organização de arquivos.

## Visão Geral da Árvore

```
chezmoi/                              # Raiz do repositório Git
├── README.md                           # Documentação principal
├── .chezmoiroot                        # Marca o repo como source dir do chezmoi (contém "home")
├── .git/                               # Git repository
├── .planning/                          # Artefatos de planejamento GSD
│   └── codebase/                       # ← Documentos deste mapa
│       ├── STACK.md
│       ├── INTEGRATIONS.md
│       ├── ARCHITECTURE.md
│       ├── STRUCTURE.md
│       ├── CONVENTIONS.md
│       ├── TESTING.md
│       └── CONCERNS.md
├── docs/                               # Documentação detalhada
│   ├── ARCHITECTURE.md
│   ├── CONFIGURATION.md
│   ├── DEVELOPMENT.md
│   ├── FORK-GUIDE.md
│   ├── GETTING-STARTED.md
│   ├── HERMES-BACKUP.md
│   ├── KEYMAPS.md
│   ├── OMNIROUTE-BACKUP.md
│   ├── TESTING.md
│   ├── WINDOWS-SETUP.md
│   └── fork/
│       ├── CHEZMOI-VARS.md
│       └── SECRETS-GUIDE.md
└── home/                               # ← SOURCE OF TRUTH (tudo que vai para $HOME)
    ├── .chezmoi.yaml.tmpl              # Orquestrador central (detecção + features)
    ├── .chezmoiignore.tmpl             # Arquivos ignorados pelo chezmoi
    ├── .chezmoiexternals/             # Dependências externas auto-instaladas
    │   ├── atuin.toml.tmpl
    │   ├── firefox.toml.tmpl
    │   ├── git.toml.tmpl
    │   ├── i3.toml.tmpl
    │   ├── icons.toml.tmpl
    │   ├── tmux.toml.tmpl
    │   └── wallpapers.toml.tmpl
    ├── .chezmoidata/                  # Dados declarativos por plataforma
    │   ├── repos.json                 # Repositórios Git (pessoal + trabalho)
    │   ├── ai_tools.yaml              # Ferramentas de IA com feature flags
    │   ├── omniroute.yaml             # Config OmniRoute
    │   ├── ollama.yaml                # Modelos Ollama
    │   ├── idea.yaml                  # IntelliJ IDEA
    │   ├── darwin/                    # macOS-specific data
    │   ├── linux/                     # Linux-specific data
    │   ├── windows/                   # Windows-specific data
    │   ├── termux/                    # Android Termux data
    │   └── vps/                       # VPS-specific features
    ├── .chezmoiscripts/               # Scripts de bootstrap (hooks)
    │   ├── darwin/
    │   ├── linux/
    │   ├── unix/                      # Shared (macOS + Linux)
    │   ├── windows/
    │   └── termux/
    ├── .chezmoitemplates/             # Templates Go reutilizáveis
    │   ├── common/
    │   ├── darwin/
    │   ├── linux/
    │   ├── windows/
    │   └── workplace/
    ├── dot_* (arquivos públicos)       # Configurações compartilháveis
    │   ├── dot_zshrc.tmpl             # Entry point do zsh
    │   ├── dot_zshrc.d/               # Zsh modular (23 arquivos)
    │   ├── dot_bashrc                 # Bash config
    │   ├── dot_zprofile.tmpl          # Zsh login shell
    │   ├── dot_local/                 # ~/.local/ structure
    │   │   ├── opt/                   # Opt apps (dockge, stacks)
    │   │   ├── bin/                   # Binários user-space (omniroute-sync, hermes-sync)
    │   │   └── private_share/         # Shared private data (apps)
    │   ├── dot_qwen/                  # Qwen config
    │   ├── dot_m2/                    # Maven settings
    │   ├── dot_aws/                   # AWS config (encrypted)
    │   ├── dot_codex/                 # Codex config (encrypted)
    │   ├── dot_aider.conf.yaml.tmpl   # Aider config (encrypted)
    │   ├── dot_aider.model.settings.yaml.tmpl
    │   ├── dot_screenlayout/          # Screen layout scripts
    │   ├── dot_hindsight/             # Hindsight agent config
    │   ├── dot_claude/                # Claude Code config
    │   ├── dot_claude-code-router/    # Claude Code Router config
    │   ├── dot_keys/                  # age-encrypted keys/tokens
    │   └── dot_omniroute/             # OmniRoute encrypted state
    ├── private_dot_* (configurações privadas)
    │   ├── private_dot_ssh/           # SSH keys (3 pares + encrypted backups)
    │   ├── private_dot_config/        # App configs (secrets)
    │   │   ├── git/                   # Git multi-profile config
    │   │   ├── starship.toml          # Starship prompt
    │   │   ├── tmux/                  # tmux config
    │   │   ├── kitty/                 # Kitty terminal
    │   │   ├── hypr/                  # Hyprland WM
    │   │   ├── niri/                  # Niri WM
    │   │   ├── i3/                    # i3 WM
    │   │   ├── wezterm/               # Wezterm
    │   │   ├── bat/                   # bat config
    │   │   ├── vim/                   # (reference to neovim)
    │   │   ├── private_systemd/       # systemd user services
    │   │   │   └── private_user/
    │   │   │       ├── hermes-dashboard.service.tmpl
    │   │   │       └── omniroute.service.tmpl
    │   │   ├── private_atuin/         # Atuin private config
    │   │   ├── rbw/                   # Bitwarden CLI
    │   │   ├── glab-cli/              # GitLab CLI
    │   │   ├── aichat/                # Aichat config
    │   │   ├── opencode/              # OpenCode config
    │   │   ├── mise/                  # mise config
    │   │   ├── herdr/                 # Herdr config
    │   │   ├── dunst/                 # Dunst notifications
    │   │   ├── picom/                 # Picom compositor
    │   │   ├── greenclip.toml         # Greenclip
    │   │   ├── xorg.conf.d/           # X11 config
    │   │   ├── networkmanager_dmenu/  # Network manager dmenu
    │   │   ├── private_Antigravity/   # VS Code fork config
    │   │   └── autostart/             # Desktop autostart
    │   ├── private_dot_hermes/        # Hermes encrypted state
    │   ├── private_dot_coderabbit/    # CodeRabbit encrypted auth
    │   ├── private_dot_mozilla/       # Firefox private data
    │   ├── private_dot_wakatime.cfg.tmpl
    │   ├── private_dot_zup-worker/    # Zup worker encrypted token
    │   └── ...
    └── .aider.*                        # Aider history/cache (local only)
```

## Convenções de Nomenclatura

### Prefixos de Arquivos

| Prefixo | Significado | Exemplo |
|---------|-------------|---------|
| `dot_` | Arquivo que será vinculado para $HOME | `dot_zshrc` → `~/.zshrc` |
| `private_dot_` | Arquivo privado (não compartilhado, ou sensível) | `private_dot_config/` |
| `encrypted_` | Arquivo criptografado com age | `encrypted_private_id_ed25519_personal.asc` |
| `run_once_after_NNN-` | Script executado uma vez após NNN | `run_once_after_503-install-mise.sh.tmpl` |
| `run_onchange_after_NNN-` | Script re-executado quando muda após NNN | `run_onchange_after_605-clone-my-repos.sh.tmpl` |
| `run_once_before_NNN-` | Script executado uma vez antes de NNN | `run_once_before_204-init-zsh.sh.tmpl` |
| `run_onchange_before_NNN-` | Script re-executado quando muda antes de NNN | `run_onchange_before_201-install-arch-packages.sh.tmpl` |
| `*.tmpl` | Template Go text/template | `dot_zshrc.tmpl`, `config.tmpl` |
| `*.asc` | Arquivo criptografado com age | `encrypted_omniroute-key.txt.asc` |
| `executable_` | Script que será executável | `executable_omniroute-sync` |

### Numeração de Scripts

```
0xx  → Base packages e setup inicial (Termux, etc.)
1xx  → Core tools e ambiente (zsh, nix, kernels, drivers)
2xx  → Desenvolvimento (fonts, window managers, compilação nvim/tmux)
3xx  → AI/CLI tools (aider, claude, ollama)
5xx  → Serviços e integrações (mise, caddy, tailscale)
6xx  → Post-install (cron, sync, clone repos)
```

Gaps numéricos são intencionais para inserções futuras (ex: gap entre 505 e 530).

## Convenções de Diretórios

```
home/.chezmoiscripts/{os}/     → Scripts por SO (darwin, linux, unix, windows, termux)
home/.chezmoidata/{os}/        → Dados por SO (darwin, linux, windows, termux, vps)
home/.chezmoitemplates/{os}/   → Templates por SO (common, darwin, linux, windows, workplace)
home/private_dot_config/       → Todos os configs privados de apps
home/private_dot_*             → Dados privados por aplicação (hermes, coderabbit, ssh, etc.)
home/dot_*                     → Configs públicos/compartilháveis
home/dot_local/                → ~/.local/ (binários, opt, share)
```

## Convenções de Arquivos

| Tipo | Extensão | Template? | Criptografia? |
|------|----------|-----------|--------------|
| Shell script | `.sh.tmpl` | Sim (Go template) | Não |
| PowerShell | `.ps1.tmpl` | Sim | Não |
| Config text | `.tmpl` | Sim | Não |
| Segredo age | `.asc` | Não | Sim (age) |
| Dados YAML | `.yaml`, `.yml` | Não* | Não |
| Dados JSON | `.json` | Não | Não |
| Dados TOML | `.toml` | Não | Não |
| Chave age | `.txt` (local) | Não | Não |
| Texto puro | Qualquer | Não | Não |

*Alguns YAMLs usam Go template syntax quando necessário (ex: `.chezmoi.yaml.tmpl`).

## Princípios de Organização

1. **Separação público/privado**: Arquivos que podem ser compartilhados em fork público usam `dot_`; sensíveis usam `private_dot_`.

2. **Separação template/original**: Tudo que é versionado no Git é a fonte (template). O resultado final vive em `$HOME` e nunca é versionado.

3. **Dados vs lógica**: Listas de pacotes e configurações estáticas vivem em `.chezmoidata/`; lógica de instalação vive em `.chezmoiscripts/`.

4. **Templates reutilizáveis**: Guards e helpers Go vivem em `.chezmoitemplates/` e são incluídos via `{{ template "..." . }}`.

5. **Numeração ordenada**: Scripts possuem numeração que define a ordem de execução, facilitando adição de novos scripts sem quebrar a sequência.

6. **Extensões indicam processamento**: `.tmpl` = será processado pelo chezmoi; sem `.tmpl` = copiado como-is.

## Arquivos de Referência Cruzada

| Documento | Descreve |
|-----------|----------|
| `docs/ARCHITECTURE.md` | Visão arquitetural e fluxos |
| `docs/CONFIGURATION.md` | Variáveis de ambiente e feature flags |
| `docs/GETTING-STARTED.md` | Instalação |
| `docs/DEVELOPMENT.md` | Como contribuir |
| `docs/TESTING.md` | Testes e verificação |
| `docs/KEYMAPS.md` | Atalhos tmux/nvim/zsh |
| `docs/HERMES-BACKUP.md` | Modelo de backup Hermes |
| `docs/OMNIROUTE-BACKUP.md` | Modelo de backup OmniRoute |
| `docs/FORK-GUIDE.md` | Como fazer fork |
| `docs/fork/CHEZMOI-VARS.md` | Guia de variáveis do chezmoi |
| `docs/fork/SECRETS-GUIDE.md` | Guia de encriptação |
| `docs/WINDOWS-SETUP.md` | Setup Windows |

## Estatísticas do Repositório

| Categoria | Quantidade |
|-----------|-----------|
| Arquivos em `home/` (excluindo .git, caches, db) | ~220+ |
| Scripts de bootstrap (`.chezmoiscripts/`) | 51 |
| Arquivos Zsh modularizados (`dot_zshrc.d/`) | 23 |
| Templates Go reutilizáveis (`.chezmoitemplates/`) | 16 |
| Dependências externas (`.chezmoiexternals/`) | 7 |
| Arquivos de dados por SO (`.chezmoidata/`) | 17 |
| Documentação (`docs/`) | 13 |
| Arquivos `.tmpl` (templates) | ~80+ |
| Arquivos `.asc` (criptografados) | ~15+ |
| Secrets criptografados | ~17 |

## Versão do Documento

Gerado automaticamente pelo gsd-map-codebase em 2026-09-16.
