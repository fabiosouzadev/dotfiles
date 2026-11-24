# fabiosouzadev/dotfiles

![chezmoi](https://img.shields.io/badge/chezmoi-managed-blue?style=flat-square)
![Shell](https://img.shields.io/badge/shell-zsh-green?style=flat-square)
![Arch Linux](https://img.shields.io/badge/Arch-1793D1?style=flat-square&logo=arch-linux&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=flat-square&logo=ubuntu&logoColor=white)
![macOS](https://img.shields.io/badge/macOS-000000?style=flat-square&logo=apple&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-0078D4?style=flat-square&logo=windows&logoColor=white)
![Termux](https://img.shields.io/badge/Termux-000000?style=flat-square&logo=android&logoColor=white)

Dotfiles gerenciados pelo [chezmoi](https://chezmoi.io). Um único repositório descreve o ambiente completo — shell, terminal, editores, ferramentas CLI, ferramentas de IA, segredos criptografados e os serviços da VPS — e se adapta sozinho à máquina onde é aplicado.

---

## Quick Start

**Linux / WSL / macOS**

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin" init --apply fabiosouzadev
```

**Arch Linux**

```bash
sudo pacman -S chezmoi
chezmoi init --apply fabiosouzadev
```

**Windows (PowerShell)**

```powershell
winget install twpayne.chezmoi
chezmoi init --apply fabiosouzadev
```

**Atualizar uma máquina existente**

```bash
chezmoi update        # git pull + apply
chezmoi diff          # ver o que mudaria antes de aplicar
```

> **Segredos:** os arquivos `encrypted_*.asc` são criptografados com **GPG**. Sem a chave privada correspondente o `apply` falha nesses arquivos. Em um fork, troque o `recipient` em `home/.chezmoi.yaml.tmpl` e recriptografe (ou remova) os segredos.

### Pré-requisitos

| Requisito | Para quê |
|-----------|----------|
| `git` | clonar o repositório |
| `chezmoi` | aplicar templates, scripts e segredos |
| `gpg` | descriptografar os arquivos `.asc` (no Windows: `scoop install gnupg`) |
| Nerd Font | ícones no terminal (`eza`, `yazi`, `starship`) |

---

## Como funciona

```text
chezmoi apply
  │
  ├─ 1. Detecção de ambiente   home/.chezmoi.yaml.tmpl
  │     OS, distro, CI, container, WSL, GUI/headless, SSH, VPS, Termux, máquina gerenciada
  │     → perfil (personal | work | vps) + feature flags
  │
  ├─ 2. Dados                   home/.chezmoidata/
  │     listas de pacotes, fontes, ferramentas de IA e serviços por plataforma
  │
  ├─ 3. Scripts                 home/.chezmoiscripts/<plataforma>/
  │     run_onchange_before_* → run_once_before_* → (arquivos) → run_once_after_* / run_onchange_after_*
  │
  └─ 4. Arquivos                home/ → ~
        dot_ → .   private_ → permissão restrita   encrypted_*.asc → descriptografado
```

### Perfis e detecção

O perfil padrão é `personal`. Ele muda automaticamente para:

- **`work`** — em máquinas gerenciadas (detectadas pelo hostname); desliga sudo, systemd e serviços em background.
- **`vps`** — em instâncias Oracle Cloud / Ubuntu via SSH sem GUI; liga Dockge, Caddy, Tailscale, Hermes e afins.

Além do perfil, o template calcula `ephemeral` (CI, Codespaces, Gitpod, devcontainer), `headless` e `interactive`, usados pelos scripts para decidir o que instalar.

Overrides por variável de ambiente:

| Variável | Efeito |
|----------|--------|
| `CHEZMOI_PROFILE` | força o perfil (`personal`, `work`, `vps`) |
| `CHEZMOI_VPS` | força a detecção de VPS |
| `CHEZMOI_FORCE_GUI` / `CHEZMOI_FORCE_HEADLESS` | força o modo gráfico ou headless |
| `CHEZMOI_SKIP_SHELL_PROBES` | pula as sondagens via `sh` (útil em ambientes restritos) |

### Guards reutilizáveis

Os scripts começam com templates de `home/.chezmoitemplates/` que encerram com `exit 0` quando a condição não se aplica:

```text
common/    script_is_not_ephemeral  script_is_not_headless  script_helper  script_eval_mise
linux/     script_linux_only  script_arch_based_only  script_ubuntu_only
darwin/    script_darwin_only
windows/   script_windows_only
workplace/ script_is_vps  script_is_not_vps  script_is_zup  script_is_not_zup  script_is_instivo
```

`common/script_helper` fornece `info`, `warn`, `error` e `success` para saída colorida.

---

## Estrutura

```text
.
├── .chezmoiroot                 # aponta o source state para home/
├── README.md
├── docs/                        # documentação técnica (não é aplicada no $HOME)
└── home/
    ├── .chezmoi.yaml.tmpl       # detecção de ambiente, perfis, feature flags, GPG
    ├── .chezmoidata/            # pacotes e ferramentas por plataforma
    │   ├── ai_tools.yaml        # ferramentas de IA (npm, curl, github)
    │   ├── ollama.yaml  omniroute.yaml  idea.yaml  repos.json
    │   └── darwin/ linux/ windows/ termux/ vps/
    ├── .chezmoiexternals/       # temas e plugins de upstream (atuin, git, i3, tmux, ícones, wallpapers…)
    ├── .chezmoiscripts/         # bootstrap por plataforma
    │   └── darwin/ linux/ unix/ termux/ vps/ windows/
    ├── .chezmoitemplates/       # guards e snippets compartilhados
    ├── dot_zshrc.d/             # zsh modular (ordem pelo prefixo numérico)
    ├── private_dot_config/      # configs de apps (kitty, wezterm, tmux, hypr, niri, i3, git, mise, starship…)
    ├── private_dot_ssh/         # chaves e config SSH
    ├── dot_hermes/              # config e estado criptografado do Hermes
    ├── dot_claude/ dot_codex/ dot_qwen/   # configs de assistentes de código
    └── dot_local/
        ├── bin/                 # hermes-sync, omniroute-sync
        └── opt/stacks/          # stacks Docker Compose da VPS
```

### Faixas de numeração dos scripts

| Faixa | Conteúdo |
|-------|----------|
| `099–199` | base do sistema: kernels, swap/zram, drivers, paru, pacotes Termux |
| `200–299` | pacotes do sistema e ferramentas core: zsh, fzf, nix, devops, virtualização, WM, nvim/tmux compilados |
| `500–599` | runtimes e ferramentas: mise, Ollama, delta, lazygit, glab, atuin, IDEA, Tailscale, ferramentas de IA |
| `600–699` | pós-configuração: clone dos repositórios pessoais, VPN |

---

## Shell

`~/.zshrc` carrega os módulos de `~/.zshrc.d/` em ordem alfabética:

| Módulo | Função |
|--------|--------|
| `099-zshenv` | variáveis de ambiente |
| `100-install-zinit` / `101-zinit-plugins` | gerenciador de plugins e plugins |
| `102-history` / `200-atuin` | histórico e busca com atuin |
| `103-fzf` / `104-keybindings` / `190-zsh-vi-mode` | fuzzy finder, atalhos, modo vi |
| `200-aliases` / `201-git-aliases` | aliases |
| `302-aider` `311-ollama` `312-source-composio` `604-openclaude` `605-omniroute` `606-hermes` | integrações de IA |
| `504-zup` | ferramentas do trabalho |
| `999-autoload-compinit` | completions (sempre por último) |
| `encrypted_3xx/4xx-*.zsh.asc` | chaves de API e tokens (criptografados) |

`~/.bashrc` é um bashrc padrão e não carrega os módulos de `~/.zshrc.d/`.

---

## Ferramentas de IA

Definidas em `home/.chezmoidata/ai_tools.yaml` e instaladas por `unix/run_once_after_590-install-ai-tools.sh.tmpl`, controladas pelas flags `features.ai.*` (`coding_assistants`, `harness`, `harness_tools`, `spec_tools`, `multiplexer`).

- **npm:** OpenCode, GitHub Copilot CLI, Qwen Code, Kilo Code, Amp, Codex, OpenClaude, OpenSpec, GSD, Hindsight coding agents…
- **curl / github:** Claude Code, Aider, Kiro, Beads, herdr, Composio, Antigravity CLI…
- **Local:** Ollama, instalado fora da VPS. Os modelos listados em `home/.chezmoidata/ollama.yaml` só são baixados com `localmodels.enabled: true` (hoje `false`).

---

## VPS

No perfil `vps`, os scripts de `home/.chezmoiscripts/vps/` instalam Dockge, Caddy, AgentMemory e CamoFox, e os stacks de `home/dot_local/opt/stacks/` ficam disponíveis para subir pelo Dockge ou com `docker compose up -d`:

| Stack | Papel |
|-------|-------|
| `caddy` | reverse proxy com TLS automático |
| `omniroute` | gateway de IA com fallback entre provedores |
| `hermes` | assistente pessoal e automações |
| `hindsight` | memória para agentes |
| `ollama` / `openwebui` | LLM local e interface web |
| `postgres` / `redis` / `qdrant` | banco, cache/rate-limit e vetores |
| `synapse` | servidor Matrix |
| `openknowledge` | base de conhecimento |
| `camofox` | automação de navegador |
| `uptime-kuma` | monitoramento de disponibilidade |

Segredos dos stacks ficam em `encrypted_*.asc` no próprio diretório de cada stack. O estado do Hermes e do OmniRoute é sincronizado com `hermes-sync` e `omniroute-sync`.

---

## Segredos

- Criptografia **GPG** (`encryption: gpg` em `home/.chezmoi.yaml.tmpl`); o chezmoi descriptografa no `apply`.
- Arquivos sensíveis usam o prefixo `encrypted_` e a extensão `.asc`.
- Para adicionar um novo segredo: `chezmoi add --encrypt ~/caminho/do/arquivo`.
- `.env*`, caches, logs e históricos grandes ficam fora do repositório.

> Guarde um backup da chave GPG privada fora deste repositório. Sem ela os arquivos `.asc` não podem ser recuperados.

---

## Desenvolvimento

```bash
chezmoi cd                                   # abrir o source dir
chezmoi execute-template < arquivo.tmpl      # renderizar um template isolado
chezmoi data                                 # ver perfil, flags e dados calculados
chezmoi apply --dry-run --verbose            # simular o apply
chezmoi state delete-bucket --bucket=scriptState   # forçar run_once_ a rodar de novo
```

Convenções:

- Gate por feature flag primeiro, depois pelo guard de OS/ambiente.
- Caminhos derivados de `.chezmoi.homeDir`, nunca absolutos.
- Scripts bash incluem `common/script_helper`, que ativa `set -euo pipefail`; PowerShell com `$ErrorActionPreference = "Stop"`.
- Um script, uma responsabilidade, numerado na faixa correta.

A documentação técnica detalhada (arquitetura, estrutura, stack, convenções e [pontos de atenção](docs/pontos-de-atencao.md)) fica em [`docs/`](docs/README.md).

---

## Créditos

[chezmoi](https://chezmoi.io) · [zinit](https://github.com/zdharma-continuum/zinit) · [starship](https://starship.rs) · [mise](https://mise.jdx.dev) · [atuin](https://atuin.sh) · [Tailscale](https://tailscale.com) · [Catppuccin](https://catppuccin.com)

<p align="center">
  Feito por <a href="https://codeberg.org/fabiosouzadev">**@fabiosouzadev**</a>
</p>
