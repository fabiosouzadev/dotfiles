# Arquitetura

Este documento descreve como o repositório funciona por dentro: de onde
vêm os dados, como os scripts decidem se rodam e como os arquivos chegam
em `~`. O [README](../README.md) cobre o uso (instalação, perfis, overrides
por variável de ambiente, lista de stacks). Aqui o foco é o mecanismo.

Para o mapa de diretórios, veja [estrutura.md](estrutura.md).

---

## Visão geral

O repositório é um source state do [chezmoi](https://chezmoi.io). O arquivo
`.chezmoiroot` na raiz contém apenas `home`, então tudo que o chezmoi
enxerga está em `home/`. Fora dele ficam só `README.md`, `docs/`,
`.planning/` e o `.gitignore`.

Um `chezmoi apply` passa por quatro camadas:

```text
1. Config     home/.chezmoi.yaml.tmpl
              detecta o ambiente -> .settings, .dirs, .features, .gpg
                 |
2. Dados      home/.chezmoidata/**  (YAML, JSON, TOML)
              pacotes, fontes, ferramentas de IA, flags extras
                 |
3. Filtro     home/.chezmoiignore.tmpl
              remove do apply o que não se aplica ao OS/perfil
                 |
4. Execução   scripts "before" -> arquivos (home/ -> ~) -> scripts "after"
              os scripts incluem guards de home/.chezmoitemplates/
```

Fontes externas (`home/.chezmoiexternals/`) entram junto com os arquivos:
o chezmoi baixa arquivos, arquivos compactados e repositórios git de
upstream para caminhos dentro de `~/.config`.

---

## 1. Camada de configuração

`home/.chezmoi.yaml.tmpl` é o template do arquivo de configuração do
chezmoi. Ele roda no `chezmoi init` (e é re-renderizado quando o template
muda) e produz quatro chaves em `data`:

| Chave | Conteúdo |
|-------|----------|
| `settings` | booleanos e strings do ambiente detectado |
| `dirs` | caminhos derivados de `.chezmoi.homeDir` (`local`, `src`, `bin`, `workspaces.*`) |
| `features` | flags calculadas a partir do ambiente |
| `gpg` | caminho do binário `gpg` (no Windows, o do Scoop) |

O mesmo arquivo define `encryption: gpg`, o `recipient` da chave GPG,
`edit.command: nvim` e `diff.pager: delta`.

### Sondagens

As sondagens usadas para preencher `settings`:

| Sinal | Como é detectado |
|-------|------------------|
| `ci` | variáveis `CI`, `GITHUB_ACTIONS`, `GITLAB_CI`, `TRAVIS`, `CIRCLECI`, `JENKINS_URL`, `BUILDKITE`, `DRONE`, `TF_BUILD`, `CI_SERVER` |
| `codespaces`, `gitpod`, `replit` | `CODESPACES`, `GITPOD_WORKSPACE_ID`, `REPL_ID` |
| `devContainer` | `REMOTE_CONTAINERS`, `DEVCONTAINER`, `DEVCONTAINERS` |
| `wsl` | Linux com `microsoft` no `osrelease` do kernel |
| `inContainer` | `/proc/1/cgroup`, `/.dockerenv` (só no Linux), Distrobox, Lima, Kubernetes e usuários típicos de container (`root`, `vscode`, `vagrant`, `ubuntu`) |
| `ssh` | `SSH_CONNECTION`, `SSH_CLIENT`, `SSH_TTY` |
| `tty` | `stdinIsATTY` |
| `guiAvailable` | `DISPLAY`/`WAYLAND_DISPLAY`; no macOS sempre `true`; no WSL exige também socket X11 ou `xdpyinfo` |
| `vps` | Linux com hostname contendo `vps`/`vnic`, começando com `instance-` (Oracle Cloud), ou Ubuntu + usuário `ubuntu` + SSH + sem GUI |
| `termux` | `TERMUX_VERSION` |
| `ismanaged` / `workplace` | hostname de máquinas corporativas conhecidas; define `workplace` como `Zup` ou `Itau` |
| `linuxonmac`, `dell3530`, `dell3520` | substrings do hostname (ajustes de hardware) |

Os valores derivados:

- `ephemeral` = CI ou Codespaces ou devcontainer ou Gitpod ou Replit.
- `headless` = sem TTY, ou sem GUI, ou WSL, ou container, ou SSH, ou Termux.
- `interactive` = tem TTY e não é headless.
- `osid` = `linux-<id da distro>` no Linux (ex.: `linux-ubuntu`,
  `linux-endeavouros`); nos demais, só o OS (`darwin`, `windows`).
- `profile` = `personal` por padrão, `work` em máquina gerenciada e `vps`
  quando a sondagem de VPS dá positivo (a regra de VPS é avaliada por
  último e vence).

Quando há TTY, o template imprime um resumo do que detectou. Para ver o
resultado completo, use `chezmoi data`.

### Flags calculadas no template

O dicionário `features` gerado pelo template contém apenas flags que
dependem do ambiente:

| Flag | Valor |
|------|-------|
| `sudo.enabled` | `true` fora de máquina gerenciada |
| `systemd.enabled` | Linux e não gerenciada |
| `runtime.background_services` | não gerenciada |
| `kernels.install` | `false` |
| `rtl8821ce.install` | hostname `dell3530` |
| `i3.enabled`, `niri.enabled` | fora da VPS |
| `ollama.install` | fora da VPS |
| `ollama.mode` | `root` com sudo e systemd; senão `user` |

---

## 2. Camada de dados

Os arquivos de `home/.chezmoidata/` são lidos pelo chezmoi e mesclados com
o `data` do arquivo de configuração. Vários deles também declaram chaves
dentro de `features`, então o namespace `.features` que os templates veem
é a combinação de várias fontes:

| Origem | Chaves |
|--------|--------|
| `.chezmoi.yaml.tmpl` | `sudo`, `systemd`, `runtime`, `kernels`, `rtl8821ce`, `i3`, `niri`, `ollama.install`, `ollama.mode` |
| `ai_tools.yaml` | `features.ai.{coding_assistants, harness, harness_tools, spec_tools, multiplexer}` |
| `ollama.yaml` | `features.ollama.{version, path, environments, localmodels, models}` |
| `idea.yaml` | `features.idea.{install.<os>, version, workplaces}` |
| `repos.json` | `features.repos.{personal, other, work}` |
| `vps/features.yaml` | `features.{dockge, tailscale, hermes.*}` |

Além de `features`, os dados definem chaves de topo: `ai_tools`,
`packages`, `fonts`, `linux` (kernels), `omniroute`, `repos` e `termux`.

### Exemplo: ferramentas de IA

`ai_tools.yaml` lista ferramentas em três grupos, cada uma com um
`feature_flag`:

| Grupo | Entradas | Instalação |
|-------|----------|------------|
| `npm` | 11 | `npm install -g <package>` |
| `curl` | 10 | `curl <url> \| <shell>` |
| `github` | 1 | `git clone` |

O script `unix/run_once_after_590-install-ai-tools.sh.tmpl` percorre os
três grupos com `range`, resolve o `feature_flag` contra `features.ai.*`
e pula entradas com `block_on_workplace` igual ao `workplace` atual. Se a
entrada tiver `completions_cmd`, a completion é gravada em
`~/.local/share/zsh/site-functions/`. O script inteiro é pulado na VPS
(`workplace/script_is_not_vps`) e em ambientes efêmeros.

Esse é o padrão geral: a lista vive em dados, o script só itera. Os
scripts de pacotes (`run_onchange_before_201-install-arch-packages`,
`202-install-ubuntu-packages`, os de Homebrew/MacPorts e os de
winget/Scoop) seguem a mesma ideia.

---

## 3. Camada de filtro

`home/.chezmoiignore.tmpl` é renderizado com os mesmos dados e decide o
que fica fora do apply:

| Condição | O que é ignorado |
|----------|------------------|
| `osid` não contém `linux` | scripts/dados de Linux, `.mozilla`, `.config/systemd` |
| `osid` não contém `windows` | scripts/dados de Windows, `AppData`, `scoop` |
| `osid` não contém `darwin` | scripts/dados de macOS, `Library/LaunchAgents` |
| Windows | `.bashrc`, `.zshrc`, `.zshrc.d`, scripts `unix/` |
| fora do Termux | scripts/dados de Termux |
| VPS | scripts de desktop: WM, Bluetooth, teclado Xorg, fontes, drivers, virtualização, Nix, VPN Instivo, paru, compilação de nvim/tmux; configs de i3/niri/greenclip |
| fora da VPS | scripts `vps/`, `hermes-sync`, `omniroute-sync` |
| hostname contém `omarchy` | praticamente tudo (inclusive todos os scripts) |
| `workplace` = `Itau` | praticamente tudo (inclusive todos os scripts e `.config`) |

Ou seja: o filtro faz a seleção grossa (por OS e perfil) e os guards
dentro dos scripts fazem a seleção fina.

---

## 4. Camada de execução

### Ordem dos scripts

Os scripts ficam em `home/.chezmoiscripts/<plataforma>/`. Pelo modelo do
chezmoi:

1. todos os scripts `*_before_*` rodam antes de qualquer arquivo ser
   escrito;
2. os arquivos de `home/` são aplicados em `~`;
3. todos os scripts `*_after_*` rodam no final.

Dentro de cada fase a ordem é alfabética pelo nome. O tipo do script
(`once` ou `onchange`) controla **se** ele roda, não **quando**:

| Tipo | Roda quando |
|------|-------------|
| `run_once_` | na primeira vez que aquele conteúdo é visto (o chezmoi guarda o hash) |
| `run_onchange_` | sempre que o conteúdo renderizado muda |

Como os templates `run_onchange_` incluem os dados que consomem, editar
uma lista em `.chezmoidata/` muda o script renderizado e dispara a
reinstalação. É o caso dos pacotes, das fontes, dos modelos do Ollama e
do clone de repositórios (`unix/run_onchange_after_605-clone-my-repos`).

O prefixo numérico (`NNN-`) agrupa os scripts por assunto e orienta a
ordem. As faixas usadas estão no README. Como os scripts estão em
subdiretórios diferentes (`linux/`, `unix/`, `vps/`...), não conte com uma
ordem exata entre scripts de pastas diferentes dentro da mesma fase. Se
um script depende de outro, coloque a dependência na fase `before` ou
faça o script verificar o pré-requisito (como o `590` faz com o `mise`
via `common/script_eval_mise`).

Hoje há 51 scripts:

| Pasta | Qtde | Exemplos |
|-------|------|----------|
| `linux/` | 24 | kernels, zram, drivers, paru, Nix, WM, nvim/tmux compilados, Ollama, IDEA, VPN |
| `unix/` | 11 | mise, CodeRabbit, Spec Kit, Cursor CLI, glab, lazygit, WakaTime, atuin, Tailscale, IA, repos |
| `darwin/` | 5 | MacPorts, Homebrew, tmux, Ollama, IDEA |
| `vps/` | 4 | Dockge, Caddy, agentmemory, Camofox |
| `windows/` | 4 | winget, Scoop, glab, IDEA (PowerShell) |
| `termux/` | 3 | pacotes base, SSH, Tailscale |

### Guards

Um guard é um template de `home/.chezmoitemplates/` que, incluído no topo
do script, renderiza um `exit 0` quando a condição não vale. Como a
decisão é tomada na renderização, o script pulado vira praticamente só
`exit 0`. A lista completa de guards está no README.

Estrutura típica de um script bash:

```bash
#!/usr/bin/env bash
{{ template "common/script_helper" . }}  # set -euo pipefail + helpers
{{ template "common/script_is_not_ephemeral" . }} # sai em CI/devcontainer
{{ template "linux/script_linux_only" . }}       # sai fora do Linux
{{ template "workplace/script_is_vps" . }}       # sai fora da VPS

{{ if not .features.dockge.install }}            # flag de feature
exit 0
{{ end }}
```

Alguns detalhes dos guards que não são óbvios:

- `linux/script_arch_based_only` aceita apenas `osid` contendo
  `endeavouros` ou `cachyos`; Arch "puro" (`linux-arch`) não passa.
- `workplace/script_is_vps` e `script_is_not_vps` imprimem uma mensagem
  com `info` antes de sair; por isso precisam vir depois de
  `common/script_helper`.
- O guard `exit 0` também funciona nos scripts PowerShell (o
  `windows/run_once_after_528-install-glab.ps1.tmpl` usa
  `workplace/script_is_zup`).

### Tratamento de erro

- `common/script_helper` começa com `set -euo pipefail`, então todo
  script bash que o inclui falha no primeiro erro. Os scripts de Termux
  não usam o helper e declaram `set -euo pipefail` por conta própria.
- Os quatro scripts PowerShell usam `$ErrorActionPreference = "Stop"`.
- Um script que sai com código diferente de zero interrompe o
  `chezmoi apply`. Um `run_once_` que falhou não é marcado como
  executado e roda de novo no próximo apply.
- Não há log estruturado: a saída é a das funções `info`, `warn`,
  `error` e `success`, com cores ANSI.

---

## Fluxo do shell

`home/dot_zshrc.tmpl` vira `~/.zshrc`, define `ZDOTDIR=$HOME` e faz
`source` de cada `~/.zshrc.d/*.zsh`. A ordem é a do glob (alfabética),
por isso os módulos têm prefixo numérico.

No destino os módulos criptografados perdem o prefixo `encrypted_` e a
extensão `.asc`, então se intercalam com os demais pelo número:

```text
099-zshenv.zsh
100-install-zinit.zsh ... 201-git-aliases.zsh
300-ai-api-keys.zsh        <- vindo de encrypted_300-...asc
302-aider.zsh  311-ollama.zsh  312-source-composio.zsh
403-instivo.zsh  404-zup-keys.zsh  405-github-keys.zsh   <- criptografados
504-zup.zsh
604-openclaude.zsh  605-omniroute.zsh  606-hermes.zsh
999-autoload-compinit.zsh
termux.zsh                 <- letras vêm depois dos dígitos
```

Alguns módulos são condicionais e saem vazios quando não se aplicam:
`312-source-composio` (VPS com Hermes e Composio ligados), `504-zup`
(`workplace` = `Zup`) e `termux` (só no Termux).

`home/dot_zprofile.tmpl` só ajusta o `PATH` do MacPorts no macOS.
`home/dot_bashrc` é um `.bashrc` convencional e independente; ele não
carrega `~/.zshrc.d/`.

---

## Segredos

- Criptografia GPG (`encryption: gpg`), com o `recipient` definido em
  `home/.chezmoi.yaml.tmpl`. O caminho do `gpg` é resolvido no próprio
  template (`lookPath` no Unix, Scoop no Windows).
- No source state, um arquivo criptografado tem o atributo `encrypted_`
  e a extensão `.asc`. Há 41 arquivos assim em `home/`: módulos do zsh,
  chaves SSH, credenciais AWS, tokens (glab, Zup, CodeRabbit), chaves em
  `dot_keys/`, `.env` e chaves dos stacks, estado do Hermes e o backup de
  configuração do OmniRoute.
- `private_` **não** criptografa: só aplica permissões restritas (sem
  acesso para grupo e outros). Muitos arquivos combinam os dois
  (`encrypted_private_...`).
- Para criar um segredo novo: `chezmoi add --encrypt <arquivo>`.

### Sincronização de estado (VPS)

`hermes-sync` e `omniroute-sync` (em `home/dot_local/bin/`, instalados só
na VPS) fazem o caminho inverso: copiam o estado pequeno e estável do
serviço (configuração, `.env`, manifestos, um dump SQL seletivo) de volta
para o source state com `chezmoi add --encrypt`. O commit e o push ficam
por sua conta: os scripts só imprimem os comandos `git` sugeridos.
Os dois têm os mesmos subcomandos: `export`, `push` (exporta e adiciona
ao chezmoi), `pull` (restaura o estado), `status` e `doctor` (verifica se
nenhum arquivo proibido entrou no source).

Bancos SQLite de runtime, logs, caches e sessões ficam de fora por design.
O backup do OmniRoute fica em
`home/dot_local/opt/stacks/omniroute/restore/`.

---

## Serviços da VPS

Há duas formas de rodar serviços:

| Forma | Onde | Como sobe |
|-------|------|-----------|
| Docker Compose | `home/dot_local/opt/stacks/<nome>/` (13 stacks) | pelo Dockge ou `docker compose up -d` |
| systemd de usuário | `home/private_dot_config/private_systemd/private_user/` | `hermes-dashboard.service`, `omniroute.service` |

O Dockge tem compose próprio em `home/dot_local/opt/dockge/` (fora de
`stacks/`) e é o único serviço que um script sobe automaticamente
(`vps/run_once_after_505-install-dockge`). Os scripts de Caddy,
agentmemory e Camofox instalam essas ferramentas no host (apt, npm,
diretório `~/camofox`), independentes dos stacks de mesmo nome. Os demais
stacks são só arquivos: o apply os coloca em `~/.local/opt/stacks/` e
quem decide subir é você.

---

## Pontos de atenção

Inconsistências encontradas no código ao escrever este documento:

- `workplace/script_is_instivo` compara `workplace` com `Instivo`, mas o
  template só atribui `Zup` ou `Itau`. Na prática os scripts que dependem
  dele (`linux/554-install-openvpn3`, `linux/655-configure-vpn-instivo`,
  `unix/515-install-coderabbit-cli`) sempre saem sem fazer nada.
- `common/caddyfile_hermes.tmpl` define o bloco `caddyfile/hermes` usando
  `features.ai.hermes.dashboard.*`, que não existe nos dados (o Hermes
  está em `features.hermes`). O bloco também não é chamado por nenhum
  arquivo.
- Os scripts de Ollama leem `features.ollama.*`, mas em dois pontos usam
  `features.ai.ollama.*` (a versão fixa no macOS e as variáveis do
  override do systemd no Linux), que não está definido.
- No `590-install-ai-tools`, os ramos `multiplexer` (grupo npm) e
  `composio.install` usam `:=` em vez de `=`, o que cria uma variável nova
  e deixa a flag original em `false`.
- `.chezmoiignore.tmpl` ignora `.config/dusnt/**` no bloco `omarchy`
  (provável erro de digitação de `dunst`).
- Os comentários de `hermes-sync` e `omniroute-sync` falam em "age", mas
  o repositório usa GPG.
