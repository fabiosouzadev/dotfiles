# Estrutura do repositório

Mapa dos diretórios e das convenções de nome. A visão resumida está no
[README](../README.md#estrutura); aqui cada pasta é detalhada, com o que
ela vira no destino e onde colocar coisas novas. Para entender como as
peças se conectam no `apply`, veja [arquitetura.md](arquitetura.md).

---

## Raiz

| Caminho | Papel |
|---------|-------|
| `.chezmoiroot` | contém `home`; faz o chezmoi usar `home/` como source state |
| `home/` | source state: tudo que é aplicado em `~` (250 arquivos) |
| `docs/` | esta documentação |
| `.planning/codebase/` | mapeamento do código usado pelo fluxo GSD (em inglês) |
| `README.md` | visão geral e uso |
| `.gitignore` | ignora `.claude/` (instalação local do GSD, não versionada) |

Nada fora de `home/` é aplicado na máquina.

---

## `home/`: arquivos especiais do chezmoi

```text
home/
├── .chezmoi.yaml.tmpl      config: detecção de ambiente, flags, GPG
├── .chezmoiignore.tmpl     filtro por OS, perfil e workplace
├── .chezmoidata/           dados (YAML/JSON/TOML)
├── .chezmoiexternals/      downloads de upstream
├── .chezmoiscripts/        scripts de bootstrap por plataforma
└── .chezmoitemplates/      guards e snippets incluídos pelos scripts
```

Nenhum desses é copiado para `~`: o chezmoi os interpreta.

### `.chezmoidata/`

```text
.chezmoidata/
├── ai_tools.yaml           ferramentas de IA (npm, curl, github) + features.ai
├── idea.yaml               IntelliJ IDEA Community: versão e OS habilitados
├── ollama.yaml             versão, variáveis de ambiente e modelos do Ollama
├── omniroute.yaml          versão e método de instalação do OmniRoute
├── repos.json              repositórios a clonar (personal, other, work)
├── darwin/
│   ├── fonts.yaml
│   └── packages.toml
├── linux/
│   ├── fonts.yaml
│   ├── kernels.yaml
│   ├── linux.wm.json
│   └── packages/
│       ├── archlinux.yaml
│       ├── ubuntu.json
│       └── ubuntu-gui.json
├── termux/data.yaml        pacotes e destino SSH do Termux
├── vps/features.yaml       flags da VPS: dockge, tailscale, hermes.*
└── windows/
    ├── fonts.yaml
    └── packages.yaml
```

### `.chezmoiexternals/`

Sete arquivos `.toml.tmpl`. Os ativos baixam:

| Arquivo | Destino | Origem |
|---------|---------|--------|
| `atuin.toml.tmpl` | `.config/atuin/themes` | Catppuccin para atuin |
| `git.toml.tmpl` | `.config/git/themes/catppuccin.gitconfig` | Catppuccin para delta |
| `i3.toml.tmpl` | `.config/polybar`, `.config/rofi` | temas pessoais (GitHub) |
| `tmux.toml.tmpl` | `.config/tmux/plugins/tpm` | TPM (git-repo) |
| `wallpapers.toml.tmpl` | `.config/wallpapers` | repositório pessoal (git-repo) |

`firefox.toml.tmpl` e `icons.toml.tmpl` estão com todas as entradas
comentadas. Os externals com `refreshPeriod` são revalidados a cada
`168h`.

### `.chezmoiscripts/`

| Pasta | Scripts | Linguagem |
|-------|---------|-----------|
| `linux/` | 24 | bash |
| `unix/` | 11 | bash (Linux e macOS) |
| `darwin/` | 5 | bash |
| `vps/` | 4 | bash |
| `windows/` | 4 | PowerShell (`.ps1.tmpl`) |
| `termux/` | 3 | bash |

Por tipo: 17 `run_once_before_`, 25 `run_once_after_`,
4 `run_onchange_before_` e 5 `run_onchange_after_`.

Três scripts de Linux não têm `.sh` no nome
(`104-install-cirrus-driver-for-macbook.tmpl`, `223-compile-nvim.tmpl`,
`224-compile-tmux.tmpl`); eles rodam pelo shebang.

### `.chezmoitemplates/`

```text
.chezmoitemplates/
├── common/
│   ├── script_helper                    set -euo pipefail + info/warn/...
│   ├── script_is_not_ephemeral          sai em CI/cloud IDE/devcontainer
│   ├── script_is_not_headless           sai sem GUI
│   ├── script_eval_mise                 ativa o mise (shims) se existir
│   ├── script_validate_completions_path cria as pastas de completion zsh/bash
│   └── caddyfile_hermes.tmpl            bloco Caddy do Hermes (não usado hoje)
├── darwin/script_darwin_only
├── linux/
│   ├── script_linux_only
│   ├── script_arch_based_only           EndeavourOS ou CachyOS
│   └── script_ubuntu_only
├── windows/script_windows_only
└── workplace/
    ├── script_is_vps / script_is_not_vps
    ├── script_is_zup / script_is_not_zup
    └── script_is_instivo
```

---

## `home/`: arquivos aplicados em `~`

### Shell

| Source | Destino | Observação |
|--------|---------|------------|
| `dot_zshrc.tmpl` | `~/.zshrc` | carrega `~/.zshrc.d/*.zsh` |
| `dot_zshrc.d/` | `~/.zshrc.d/` | 19 módulos `.zsh.tmpl` + 4 `encrypted_*.zsh.asc` |
| `dot_zprofile.tmpl` | `~/.zprofile` | só `PATH` do MacPorts no macOS |
| `dot_bashrc` | `~/.bashrc` | bashrc padrão, independente do zsh |

A tabela de módulos do zsh está no README.

### `private_dot_config/` -> `~/.config/`

22 diretórios e 3 arquivos soltos. O `private_` só restringe permissões;
a maior parte do conteúdo é texto puro ou template.

| Grupo | Itens |
|-------|-------|
| Terminal e prompt | `kitty/`, `wezterm/`, `tmux/`, `starship.toml` |
| Desktop Linux | `hypr/`, `i3/`, `niri/`, `picom/`, `dunst/`, `autostart/`, `xorg.conf.d/`, `networkmanager_dmenu/`, `greenclip.toml` |
| CLI | `bat/`, `git/`, `glab-cli/`, `mise/`, `rbw/`, `private_atuin/`, `homebrew/` |
| IA e editores | `aichat/`, `opencode/`, `herdr/`, `private_Antigravity/` |
| Serviços | `private_systemd/private_user/` (`hermes-dashboard.service`, `omniroute.service`) |

`git/` usa um `config.tmpl` principal e arquivos de include por contexto
(`config.personal.inc`, `config.personal-ssh.inc`, `config.zup.inc`,
`config.vps.inc`, `config.agents.inc`). `homebrew/` gera `Brewfile`,
`Caskfile` e `Masfile`. Não há configuração de Neovim neste diretório.

### Outros dotfiles

| Source | Conteúdo |
|--------|----------|
| `dot_aws/` | config e credenciais AWS (credenciais criptografadas) |
| `dot_camofox/cookies/` | cookie criptografado usado pelo Camofox |
| `dot_claude/` | `settings.json` do Claude Code |
| `dot_claude-code-router/` | `config.json` do Claude Code Router |
| `dot_codex/` | config do Codex CLI, inclusive perfil via OmniRoute |
| `dot_qwen/` | `settings.json` do Qwen Code |
| `dot_hindsight/` | `coding-agent.json` do Hindsight |
| `dot_hermes/` | config do Hermes, `.env` e token criptografados, skill `devops/linkedin-camofox-cookie-import`, config do Hindsight para o Hermes |
| `dot_keys/` | arquivos de chave criptografados (Hindsight, OmniRoute, WakaTime) |
| `dot_m2/` | `settings.xml` do Maven |
| `dot_screenlayout/` | scripts de detecção e layout de monitores (i3) |
| `private_dot_ssh/` | chaves SSH criptografadas, `.pub` em texto e `known_hosts` |
| `private_dot_mozilla/` | perfis do Firefox (`user.js`, `profiles.ini`) |
| `private_dot_coderabbit/` | auth do CodeRabbit (criptografado) |
| `private_dot_zup-worker/` | token do trabalho (criptografado) |
| `private_dot_wakatime.cfg.tmpl` | `~/.wakatime.cfg` |

### `dot_local/` -> `~/.local/`

```text
dot_local/
├── bin/
│   ├── executable_hermes-sync       só na VPS
│   └── executable_omniroute-sync    só na VPS
└── opt/
    ├── dockge/compose.yaml.tmpl     sobe via vps/505-install-dockge
    └── stacks/                      13 stacks Docker Compose
        ├── caddy/          Caddyfile.tmpl + compose
        ├── camofox/        compose + .env
        ├── hermes/         compose
        ├── hindsight/      compose + .env
        ├── ollama/         compose + .env
        ├── omniroute/      compose + Dockerfile + .env + restore/
        ├── openknowledge/  compose + Dockerfile + entrypoint.sh + secrets/
        ├── openwebui/      compose
        ├── postgres/       compose + .env + init-databases.sh
        ├── qdrant/         compose + .env
        ├── redis/          compose
        ├── synapse/        compose + .env + data/ + chaves
        └── uptime-kuma/    compose
```

Todo `compose.yaml` é template (`compose.yaml.tmpl`). Os `.env` estão no
source como `encrypted_dot_env.asc`. O único stack com `restore/` é o
`omniroute`. O papel de cada stack está no README.

---

## Convenções de nome

### Atributos do chezmoi

| Atributo | Efeito no destino |
|----------|-------------------|
| `dot_` | vira `.` (`dot_zshrc.tmpl` -> `~/.zshrc`) |
| `private_` | permissões restritas; **não** criptografa |
| `encrypted_` + `.asc` | arquivo criptografado com GPG; o chezmoi descriptografa no apply e remove prefixo e extensão |
| `executable_` | marca o arquivo como executável |
| `empty_` | mantém o arquivo mesmo vazio (ex.: `dunst/empty_dunstrc`) |
| `readonly_` | arquivo somente leitura (ex.: chave da Oracle em `private_dot_ssh/`) |
| `literal_` | encerra o parsing de atributos (ex.: `i3/scripts/executable_literal_empty_workspace`) |
| `.tmpl` | renderizado como template Go antes de ser escrito |

Os atributos se combinam, como em
`encrypted_private_id_ed25519_personal.asc` -> `~/.ssh/id_ed25519_personal`
com permissão restrita.

### Scripts

```text
run_<once|onchange>_<before|after>_<NNN>-<descricao>.<sh|ps1>.tmpl
```

- `once` / `onchange`: quando o script roda (uma vez ou a cada mudança).
- `before` / `after`: antes ou depois de os arquivos serem aplicados.
- `NNN`: número de três dígitos na faixa do assunto (faixas no README).

### Módulos do zsh

```text
NNN-<nome>.zsh.tmpl                 módulo normal
encrypted_NNN-<nome>.zsh.asc        módulo com segredos
```

O número define a ordem de carga, e `999-autoload-compinit` fica por
último entre os numerados.

---

## Onde adicionar coisas novas

**Script de bootstrap**

1. Crie em `home/.chezmoiscripts/<plataforma>/` seguindo o padrão de nome.
   Use `unix/` para o que vale em Linux e macOS.
2. Comece com `{{ template "common/script_helper" . }}` e os guards
   necessários; em PowerShell use `$ErrorActionPreference = "Stop"`.
3. Se o script deve sumir por inteiro em algum perfil, considere também
   uma entrada em `home/.chezmoiignore.tmpl` (é assim que os scripts de
   desktop saem da VPS).

**Pacote ou ferramenta**

- Pacote do sistema: no arquivo da distro em `home/.chezmoidata/`
  (`linux/packages/archlinux.yaml`, `linux/packages/ubuntu.json`,
  `darwin/packages.toml`, `windows/packages.yaml`).
- Ferramenta de IA: uma entrada em `ai_tools.yaml` no grupo certo, com
  `feature_flag` e, se fizer sentido, `completions_cmd` ou
  `block_on_workplace`.

**Módulo do zsh**

- `home/dot_zshrc.d/NNN-<nome>.zsh.tmpl`. Para condicionar por
  ambiente, envolva o conteúdo em `{{ if ... }}` como fazem `504-zup` e
  `termux`.
- Segredos: `chezmoi add --encrypt ~/.zshrc.d/NNN-<nome>.zsh`, que gera o
  `encrypted_NNN-<nome>.zsh.asc`.

**Configuração de app**

- `home/private_dot_config/<app>/`. Use `.tmpl` quando o conteúdo variar
  por OS ou perfil, e `chezmoi add --encrypt` para o que tiver segredo.
- Se o app não existe em algum perfil, ignore o caminho em
  `home/.chezmoiignore.tmpl`.

**Stack Docker (VPS)**

1. `home/dot_local/opt/stacks/<nome>/compose.yaml.tmpl`.
2. Segredos em `.env` adicionados com `chezmoi add --encrypt`
   (viram `encrypted_dot_env.asc`).
3. Se o serviço for público, configure a rota em
   `home/dot_local/opt/stacks/caddy/Caddyfile.tmpl`.
4. Suba pelo Dockge ou com `docker compose up -d`. Não é preciso um script
   de instalação por stack.

**Flag de feature**

- Depende do ambiente: calcule em `home/.chezmoi.yaml.tmpl`, no
  dicionário `features`.
- É uma escolha fixa: declare em `features` dentro do arquivo de dados
  correspondente em `home/.chezmoidata/` (ex.: `vps/features.yaml`).
- Confira o resultado com `chezmoi data`.
