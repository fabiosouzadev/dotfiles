# Stack — Tecnologias e Ferramentas

> Mapeamento de todas as tecnologias, linguagens e ferramentas usadas neste repositório de dotfiles.

## Visão Geral

Este é um repositório de dotfiles gerenciado pelo [chezmoi](https://chezmoi.io), com foco em reprodutibilidade de ambientes de desenvolvimento em múltiplas plataformas (macOS, Linux Arch/Ubuntu, Windows WSL, Termux).

## Linguagens

| Linguagem | Uso | Onde |
|-----------|-----|------|
| **Shell (sh/bash/zsh)** | Scripts de bootstrap, hooks, aliases, configuração de shell | `.chezmoiscripts/`, `dot_zshrc.d/`, `dot_bashrc` |
| **Go templates** | Templates do chezmoi para configuração dinâmica | `.chezmoi.yaml.tmpl`, todos os `*.tmpl` |
| **YAML** | Listas de pacotes, configurações de IA, dados | `.chezmoidata/`, configs de apps |
| **TOML** | Configurações de ferramentas (mise, omniroute, rbw, etc.) | `dot_m2/`, `dot_codex/`, `.chezmoidata/` |
| **JSON** | Manifestos, configs de apps, repositórios | `.chezmoidata/repos.json`, `dot_claude/`, `dot_aider/` |
| **KDL** | Configuração do window manager Niri | `private_dot_config/niri/config.kdl` |
| **Lua** | Configuração do terminal Wezterm | `private_dot_config/wezterm/wezterm.lua.tmpl` |
| **CSS/HTML** | (indireto via Neovim/LazyVim, Starship) | Configurações externas |

## Gerenciador de Dotfiles

| Ferramenta | Versão/Comando | Papel |
|-----------|----------------|-------|
| **chezmoi** | `chezmoi init --apply` | Gerencia todos os dotfiles, templates e scripts |
| **age** | `age-keygen` | Criptografia de segredos (SSH keys, tokens, etc.) |
| **GPG** | Configurado em `.chezmoi.yaml.tmpl` | Alternativa de criptografia (recipient: `E691C031009FB1DAA3A25125212D516F623C5747`) |

## Shell e Terminal

| Componente | Detalhes | Localização |
|-----------|----------|-------------|
| **Shell principal** | Zsh (chsh -s zsh) | `dot_zsh.tmpl`, `dot_zshrc.d/` (23 arquivos modularizados) |
| **Gerenciador de plugins Zsh** | [Zinit](https://github.com/zdharma-continuum/zinit) | `dot_zshrc.d/100-install-zinit.zsh.tmpl` |
| **Prompt** | [Starship](https://starship.rs) | `101-zinit-plugins.zsh.tmpl`, `private_dot_config/starship.toml` |
| **Listagem de arquivos** | eza (antigo exa) | `101-zinit-plugins.zsh.tmpl` |
| **Busca de arquivos** | fzf | `dot_zshrc.d/103-fzf.zsh.tmpl` |
| **Histórico de shell** | Atuin | `dot_zshrc.d/200-atuin.zsh.tmpl` |
| **Autocompletar** | zsh completions via Zinit | `999-autoload-compinit.zsh.tmpl` |
| **Vi Mode** | zsh-vi-mode | `dot_zshrc.d/190-zsh-vi-mode.zsh.tmpl` |
| **Histórico de comandos** | zsh history config | `dot_zshrc.d/102-history.zsh.tmpl` |
| **Keybindings** | Atalhos customizados | `dot_zshrc.d/104-keybindings.zsh.tmpl` |
| **Shell de login** | zprofile | `dot_zprofile.tmpl` |

## Gerenciadores de Pacotes (por plataforma)

| Plataforma | Gerenciador | Scripts |
|-----------|-------------|---------|
| macOS | Homebrew + MacPorts | `.chezmoiscripts/darwin/` |
| Linux (Arch) | pacman / paru | `.chezmoiscripts/linux/` |
| Linux (Ubuntu) | apt | `.chezmoiscripts/linux/` |
| Windows | winget + Scoop | `.chezmoiscripts/windows/` |
| Termux | pkg (Android) | `.chezmoiscripts/termux/` |
| Universal (Unix) | Pre-compiled binaries via curl | `.chezmoiscripts/unix/` |

## Ferramentas CLI Instaladas

### Universal (binários user-space, sem sudo)
Instaladas via script compartilhado em `.chezmoiscripts/unix/`:

| Ferramenta | Método | Script |
|-----------|--------|--------|
| **mise** (versionador de runtime) | `curl https://mise.run \| sh` | `run_once_after_503-install-mise.sh.tmpl` |
| **delta** (diff beautifier) | Binary gh-release | `run_once_after_527-install-delta.sh.tmpl` |
| **glab** (GitLab CLI) | Binary gh-release | `run_once_after_528-install-glab.sh.tmpl` |
| **lazygit** | Binary gh-release | `run_once_after_529-install-lazygit.sh.tmpl` |
| **wakatime** | CLI install | `run_once_after_534-install-wakatime-cli.sh.tmpl` |
| **atuin** | CLI install | `run_once_after_536-install-atuin.sh.tmpl` |
| **aider** | curl install | `.chezmoiscripts/unix/` |
| **claude** (Anthropic) | curl install | `.chezmoiscripts/unix/` |
| **codex** (OpenAI) | npm | `ai_tools.yaml` |
| **speckit** (GitHub CLI) | gh-release | `run_once_after_521-install-speckit-github-cli.sh.tmpl` |
| **cursor-cli** | gh-release | `run_once_after_524-install-cursor-cli.sh.tmpl` |
| **coderabbit-cli** | gh-release | `run_once_after_515-install-coderabbit-cli.sh.tmpl` |

### Gerenciados via npm (feature-flag `coding_assistants` / `spec_tools`)
Em `home/.chezmoidata/ai_tools.yaml`:

opencode, copilot, qwen-code, kilocode, amp, codex, gemini, openclaude, freebuff, openspec, gsd-core, hindsight-coding-agent

### Gerenciados via curl (feature-flag `coding_assistants` / `spec_tools` / `multiplexer`)
Em `home/.chezmoidata/ai_tools.yaml`:

aider, claude, kiro, bobibm (bloqueado no workplace Zup), kimchi, beads, herdr, composio

## Ferramentas de IA / Agentes

| Componente | Descrição | Configuração |
|-----------|-----------|-------------|
| **Hermes Agent** | Assistente pessoal com habilidades, memórias e automações | `private_dot_hermes/`, `dot_zshrc.d/606-hermes.zsh.tmpl` |
| **OmniRoute** | Gateway de IA (roteador inteligente com fallback) | `dot_omniroute/`, `dot_zshrc.d/605-omniroute.zsh.tmpl`, `dot_codex/omniroute.config.toml.tmpl` |
| **Coding Orchestrator** | Orquestra agentes de código para execução noturna autônoma | Skill `coding-orchestrator` em `.hermes/skills/` |
| **Ollama** | LLM local (modo user no VPS, root no managed) | `dot_zshrc.d/311-ollama.zsh.tmpl`, `.chezmoidata/ollama.yaml` |
| **Aider** | Assistente de codificação CLI | `dot_aider.conf.yaml.tmpl`, `dot_aider.model.settings.yaml.tmpl` |
| **Claude Code** | Assistente da Anthropic | `dot_claude/settings.json.tmpl` |
| **OpenCode** | IDE agente | `private_dot_config/opencode/` |
| **Cody (Sourcegraph)** | Assistente de código | `private_dot_coderabbit/` |
| **Aichat** | Chat com LLMs locais | `private_dot_config/aichat/config.yaml.tmpl` |
| **Starship** | Prompt com suporte a LLMs | `private_dot_config/starship.toml` |

## Window Managers e Desktop

| Componente | Plataforma | Configuração |
|-----------|------------|-------------|
| **Hyprland** | Linux (Wayland) | `private_dot_config/hypr/hyprland.conf` |
| **i3** | Linux (X11) | `.chezmoiexternals/i3.toml.tmpl` |
| **Niri** | Linux (Wayland) | `private_dot_config/niri/config.kdl` |
| **picom** | Linux (compositor) | `private_dot_config/picom/picom.conf` |
| **dunst** | Linux (notificações) | `private_dot_config/dunst/` |
| **herder** | Linux (gerenciador de serviços user) | `private_dot_config/herder/` |
| **Polybar** | Linux (barra de status) | Referência em aliases |
| **Niri screenlayout** | Linux | `dot_screenlayout/` |

## Terminais e Editores

| Componente | Configuração |
|-----------|-------------|
| **tmux** | `private_dot_config/tmux/tmux.conf.tmpl` |
| **Wezterm** | `private_dot_config/wezterm/wezterm.lua.tmpl` |
| **Kitty** | `private_dot_config/kitty/kitty.conf` |
| **Neovim** | Externo (LazyVim/Kickstart), refs em `.chezmoidata/repos.json` |
| **Visual Studio Code** | `private_dot_config/private_Antigravity/` (fork do VS Code) |

## Configuração de Apps

| App | Configuração | Localização |
|-----|-------------|-------------|
| **Git** | Multi-profile com includes | `private_dot_config/git/config.tmpl` + includes (personal, vps, zup, agents) |
| **Starship** | Prompt customizado | `private_dot_config/starship.toml` |
| **bat** | Config + temas | `private_dot_config/bat/` |
| **eza** | Via Zinit | `dot_zshrc.d/` |
| **zoxide** | Smart cd | snippet em `dot_zshrc.d/101-zinit-plugins.zsh.tmpl` |
| **direnv** | Auto-carregamento | snippet em `dot_zshrc.d/101-zinit-plugins.zsh.tmpl` |
| **mise** | Versionador runtime | Script install + config externa |
| **rbw** (Bitwarden CLI) | Config | `private_dot_config/rbw/config.json` |
| **glab** (GitLab CLI) | Config | `private_dot_config/glab-cli/private_config.yml.tmpl` |
| **wakatime** | Config | `private_dot_wakatime.cfg.tmpl` |
| **greenclip** | Clipboard manager | `private_dot_config/greenclip.toml` |
| **i3 gaps** | Window manager | `.chezmoiexternals/i3.toml.tmpl` |

## Gerenciamento de Repositórios Git

| Perfil | Repositórios | Localização |
|--------|-------------|-------------|
| **personal** | personal, polybar-themes, wallpapers, kickstart.nvim, neovim | `.chezmoidata/repos.json` |
| **work (Zup)** | ms-interactions, flex-suspension-ms, bff-core-flex-service, claro-flex-rw-extensions | `.chezmoidata/repos.json` |

## Gerenciamento de Segredos

| Tipo de Segredo | Método | Exemplos |
|----------------|--------|---------|
| SSH keys | age encryption | `private_dot_ssh/encrypted_*.asc` |
| API tokens | age encryption | `dot_zshrc.d/encrypted_*.asc`, `private_dot_config/glab-cli/encrypted_*.asc` |
| AWS credentials | age encryption | `dot_aws/encrypted_private_credentials.asc` |
| CodeRabbit auth | age encryption | `private_dot_coderabbit/encrypted_*.asc` |
| Wakatime key | age encryption | `dot_keys/encrypted_*.asc` |
| Zup worker token | age encryption | `private_dot_zup-worker/encrypted_token.txt.asc` |
| Chave pessoal/servidor VPS | age encryption | `private_dot_ssh/encrypted_private_id_ed25519_*.asc` |
| Hindsight key | age encryption | `dot_keys/encrypted_hindsight-key.txt.asc` |
| Omniroute key (default) | age encryption | `dot_keys/encrypted_omniroute-key.txt.asc` |
| Omniroute key (Zup) | age encryption | `dot_keys/encrypted_omniroute-key-zup.txt.asc` |

## Infraestrutura de Serviços (systemd user)

| Serviço | Descrição | Template |
|---------|-----------|---------|
| **hermes-dashboard** | Interface web do Hermes (porta 9119) | `private_dot_config/private_systemd/private_user/hermes-dashboard.service.tmpl` |
| **omniroute** | Gateway OmniRoute (porta 20128, source build via Node/mise) | `private_dot_config/private_systemd/private_user/omniroute.service.tmpl` |

## Sincronização de Estado

| Ferramenta | Comando | Propósito |
|-----------|---------|-----------|
| **hermes-sync** | `hermes-sync push/pull/status/doctor` | Exporta/importa configuração e SQL seletivo do Hermes |
| **omniroute-sync** | `omniroute-sync push/pull/status/doctor` | Exporta/importa config SQL seletiva do OmniRoute |

## Versão do Documento

Gerado automaticamente pelo gsd-map-codebase em 2026-09-16.
