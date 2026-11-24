# Stack e integrações

Este documento descreve **com o que** o repositório é construído e **com quais serviços externos** ele conversa. A visão geral (quick start, perfis, estrutura de diretórios, faixas de numeração dos scripts) está no [README](../README.md); aqui o foco é o detalhe que o README não cobre.

> Todos os caminhos abaixo são relativos à raiz do repositório. O source state do chezmoi fica em `home/` (definido em `.chezmoiroot`).

---

## 1. Linguagens e formatos

O repositório não tem código de aplicação: é configuração, templates e scripts de bootstrap.

| Linguagem / formato | Onde aparece | Observação |
|---------------------|--------------|------------|
| Go `text/template` (+ funções sprig do chezmoi) | todo arquivo `*.tmpl` | é a "linguagem" principal: toda a lógica de detecção e gates vive em templates |
| Bash | `home/.chezmoiscripts/{linux,unix,darwin,termux,vps}/*.sh.tmpl`, `home/dot_local/bin/` | todos os scripts começam com `#!/usr/bin/env bash` |
| PowerShell | `home/.chezmoiscripts/windows/*.ps1.tmpl` | instalação via winget e Scoop |
| Zsh | `home/dot_zshrc.tmpl`, `home/dot_zshrc.d/*.zsh.tmpl` | shell interativo principal |
| YAML / JSON / TOML | `home/.chezmoidata/`, `home/.chezmoiexternals/`, configs de apps | dados consumidos pelos templates |
| Docker Compose | `home/dot_local/opt/stacks/*/compose.yaml.tmpl` | stacks da VPS |
| Caddyfile | `home/dot_local/opt/stacks/caddy/Caddyfile.tmpl` | reverse proxy da VPS |

Não há código Lua, Python, TypeScript ou JavaScript versionado neste repositório. O diretório `.claude/` (instalação local do GSD, com hooks em JavaScript) está no `.gitignore` e **não faz parte** do repositório.

---

## 2. Runtime e gerenciadores de pacotes

### mise

Instalado por `home/.chezmoiscripts/unix/run_once_after_503-install-mise.sh.tmpl` (via `curl https://mise.run | sh`). A configuração global está em `home/private_dot_config/mise/config.toml.tmpl` (não em `.tool-versions`):

| Ferramenta | Versões |
|------------|---------|
| `node` | `latest` e `lts` |
| `java` | `latest` e `21` |
| `go` | `latest` e `1.25.1` |
| `python` | `latest` |
| `uv` | `latest` |
| pacotes `npm:` | `typescript`, `eslint`, `jest`, `prettier`, `npx`, `@inkeep/open-knowledge` |

Os scripts que precisam do runtime do mise incluem o template `common/script_eval_mise`, que ativa os shims (`mise activate zsh --shims`).

### Pacotes do sistema por plataforma

| Plataforma | Gerenciador | Dados | Script |
|------------|-------------|-------|--------|
| Arch-based | `pacman` + `paru` (ou `yay`) para AUR | `home/.chezmoidata/linux/packages/archlinux.yaml` | `linux/run_onchange_before_201-install-arch-packages.sh.tmpl` |
| Ubuntu | `apt` | `home/.chezmoidata/linux/packages/ubuntu.json`, `ubuntu-gui.json` | `linux/run_onchange_before_202-install-ubuntu-packages.sh.tmpl` |
| macOS | MacPorts e Homebrew | `home/.chezmoidata/darwin/packages.toml` | `darwin/run_onchange_after_501-*` e `502-*` |
| Windows | winget e Scoop (buckets `main`, `extras`, `versions`, `nerd-fonts`) | `home/.chezmoidata/windows/packages.yaml` | `windows/run_onchange_before_201-*` e `202-*` |
| Termux | `pkg` | `home/.chezmoidata/termux/data.yaml` | `termux/run_once_before_099-termux-base-packages.sh.tmpl` |
| Linux (opcional) | Nix | — | `linux/run_once_before_207-install-nix.sh.tmpl` |

Atenção: o guard `linux/script_arch_based_only` só aceita `osid` contendo `endeavouros` ou `cachyos`. Um Arch "puro" (`linux-arch`) **não** passa por esse guard.

### Ferramentas instaladas fora dos gerenciadores

Várias CLIs são baixadas direto do upstream por scripts em `home/.chezmoiscripts/unix/`:

| Ferramenta | Origem | Script |
|------------|--------|--------|
| CodeRabbit CLI | `curl` do instalador oficial | `run_once_after_515-install-coderabbit-cli.sh.tmpl` |
| Spec Kit (`specify-cli`) | `uv tool install` a partir de `github/spec-kit` | `run_once_after_521-install-speckit-github-cli.sh.tmpl` |
| Cursor CLI | `curl` do instalador oficial | `run_once_after_524-install-cursor-cli.sh.tmpl` |
| glab | release do GitLab | `run_once_after_528-install-glab.sh.tmpl` (e `.ps1` no Windows) |
| lazygit | release do GitHub | `run_once_after_529-install-lazygit.sh.tmpl` |
| wakatime-cli | release do GitHub | `run_once_after_534-install-wakatime-cli.sh.tmpl` |
| atuin | release do GitHub | `run_once_after_536-install-atuin.sh.tmpl` |
| Tailscale | `tailscale.com/install.sh` (só Linux) | `run_once_after_556-configure-tailscale.sh.tmpl` |

No shell, o zinit também baixa binários de releases do GitHub (`from"gh-r"`): `starship`, `eza`, `ripgrep`, `fd` e `bat` — veja `home/dot_zshrc.d/101-zinit-plugins.zsh.tmpl`.

### Externals

`home/.chezmoiexternals/` puxa temas e assets de upstream com `refreshPeriod = "168h"` (semanal): temas Catppuccin para atuin e delta, temas de polybar/rofi e wallpapers. Os externals de Firefox e ícones estão comentados.

---

## 3. Ferramentas principais do ambiente

Lista curta do que está efetivamente declarado nos dados de pacotes ou scripts (não é exaustiva):

- **Shell:** zsh + zinit, starship, atuin, fzf, zsh-vi-mode, zoxide.
- **Terminal / arquivos:** kitty, wezterm, tmux (compilado de fonte em `linux/run_once_before_224-*` e `darwin/run_once_before_225-*`), yazi, eza, bat, delta.
- **Editor:** neovim (compilado em `linux/run_once_before_223-compile-nvim.tmpl`), IntelliJ IDEA Community (versão fixada em `home/.chezmoidata/idea.yaml`).
- **Git:** `github-cli`, glab, lazygit, delta (também configurado como pager do `chezmoi diff`).
- **Containers e virtualização (Arch):** docker, docker-compose, podman, podman-compose, nerdctl, distrobox, qemu, libvirt.
- **Clientes:** DBeaver, Postman, Obsidian, Brave, LocalSend e MongoDB Compass (AUR); Bruno e Podman Desktop no Windows (winget).
- **Segredos:** gnupg, `age` e `sops` aparecem como pacotes instalados, mas **o chezmoi usa GPG** (seção 6).

---

## 4. Ferramentas de IA

### Assistentes de código

Declarados em `home/.chezmoidata/ai_tools.yaml` e instalados por `home/.chezmoiscripts/unix/run_once_after_590-install-ai-tools.sh.tmpl`. Esse script **não roda na VPS** (guard `workplace/script_is_not_vps`) nem em ambientes efêmeros.

Cada entrada tem um `feature_flag` que aponta para `features.ai.*` no mesmo arquivo:

| Flag | Exemplos de ferramentas |
|------|------------------------|
| `harness` | opencode, copilot, qwen-code, kilocode, amp, codex, openclaude, freebuff, aider, claude, kiro, kimchi, antigravity cli, pi, deepseek-harness |
| `spec_tools` | openspec, gsd-core, beads |
| `harness_tools` | hindsight-coding-agent |
| `multiplexer` | herdr |
| `composio.install` | composio |

Três métodos de instalação: `npm` (`npm install -g`), `curl` (pipe para o shell indicado) e `github` (clone em `~/.local/src/<nome>`). A chave opcional `block_on_workplace` impede a instalação em uma máquina de trabalho específica (ex.: `bobibm` bloqueado em `Zup`). Ferramentas com `completions_cmd` geram completions em `~/.local/share/zsh/site-functions/`.

> Limitação conhecida: para `multiplexer` (bloco npm) e `composio.install`, o script usa `:=` dentro de um `{{ if }}`, o que cria uma variável nova no escopo do bloco em vez de reatribuir `$featureEnabled`. Na prática essas entradas nunca são instaladas por esse caminho. Veja [convenções](convencoes-e-testes.md#armadilhas-de-template).

### Ollama

- Dados em `home/.chezmoidata/ollama.yaml`; instalação em `linux/run_once_after_504-install-ollama.sh.tmpl` e `darwin/run_once_after_504-install-ollama-darwin.sh.tmpl`.
- `features.ollama.install` é `false` na VPS; o modo (`root` ou `user`) depende de ter sudo e systemd.
- Variáveis exportadas por `home/dot_zshrc.d/311-ollama.zsh.tmpl`: host em `127.0.0.1:11434`, contexto de 8192 tokens, backend só CPU, um modelo carregado por vez.
- Modelos listados: `qwen2.5-coder:0.5b`, `qwen2.5-coder:1.5b`, `gemma4:e2b`, `gemma4:e4b`. O download só acontece se `localmodels.enabled` for `true` (hoje está `false`).

### OmniRoute (gateway de LLM)

OmniRoute é o ponto central: Claude Code, Codex, OpenCode, OpenClaude e Hermes falam com ele em vez de falar direto com os provedores.

- **Na VPS:** stack Docker em `home/dot_local/opt/stacks/omniroute/` com a imagem `ghcr.io/cheaper-inference/omniroute:3.8.54-web-bun`. Portas expostas pelo Caddy: `20128` (dashboard), `20129` (API compatível com OpenAI/Anthropic) e `20132` (WebSocket/streaming).
- **Fora do Docker:** existe uma unit systemd de usuário em `home/private_dot_config/private_systemd/private_user/omniroute.service.tmpl`, que roda `~/.local/src/OmniRoute/bin/omniroute.mjs serve` com o Node LTS do mise e lê `~/.omniroute/.env`.
- `home/.chezmoidata/omniroute.yaml` fixa `version: "3.8.46"` e `method: "source"`, mas **nenhum template ou script lê esse arquivo hoje** — a versão efetiva da VPS é a tag da imagem acima.
- Backup/restauração do estado: `home/dot_local/bin/executable_omniroute-sync` (só na VPS, ver `.chezmoiignore.tmpl`).

### Como os clientes de IA se autenticam

| Arquivo | Variáveis / campos |
|---------|-------------------|
| `home/dot_claude/settings.json.tmpl` | `ANTHROPIC_BASE_URL` (endpoint do OmniRoute), `ANTHROPIC_AUTH_TOKEN` |
| `home/dot_codex/auth.json.tmpl`, `private_config.toml.tmpl` | `OPENAI_API_KEY`; provider customizado com `env_key = "OMNIROUTE_API_KEY"` |
| `home/private_dot_config/opencode/opencode.json.tmpl` | `apiKey` do provider OmniRoute |
| `home/dot_zshrc.d/604-openclaude.zsh.tmpl` | `OPENAI_BASE_URL`, `OPENAI_API_KEY` (o resto do arquivo são exemplos comentados de outros provedores) |
| `home/dot_zshrc.d/605-omniroute.zsh.tmpl` | `OMNIROUTE_API_KEY` |
| `home/dot_hindsight/coding-agent.json.tmpl` | `apiToken` do Hindsight |

O valor sempre vem de um arquivo criptografado em `home/dot_keys/`, lido com `include ... | decrypt`. Em máquinas com `workplace = "Zup"`, os templates trocam `encrypted_omniroute-key.txt.asc` por `encrypted_omniroute-key-zup.txt.asc`.

### Hermes

Assistente pessoal (agente) com dashboard web.

- Configuração em `home/dot_hermes/config.yaml.tmpl`: modelo via provider customizado apontando para `${OMNIROUTE_BASE_URL}`, memória via Hindsight, navegador via CamoFox.
- Plataformas habilitadas no config: **Telegram** e **Matrix** (o Matrix é o Synapse da própria VPS).
- Servidores MCP configurados: Notion (`mcp.notion.com`, OAuth), Composio, Hindsight (banco de memória pessoal) e OpenKnowledge (via `mcp-remote`).
- Execução: imagem `nousresearch/hermes-agent:v0.23.3` no stack `home/dot_local/opt/stacks/hermes/`; também há a unit `hermes-dashboard.service.tmpl`, que roda `hermes dashboard --port 9119 --host 0.0.0.0` lendo `~/.hermes/.env`.
- O dashboard tem `basic_auth` configurado no `config.yaml`.
- Skill versionada: `home/dot_hermes/skills/devops/linkedin-camofox-cookie-import/`.
- Backup do estado: `home/dot_local/bin/executable_hermes-sync`.

---

## 5. VPS: serviços e rede

A lista de stacks e seus papéis já está no [README](../README.md#vps). Detalhes complementares:

### Imagens fixadas

| Stack | Imagem |
|-------|--------|
| caddy | `caddy:alpine` |
| camofox | `ghcr.io/jo-inc/camofox-browser:1.19.0` |
| hermes | `nousresearch/hermes-agent:v0.23.3` |
| hindsight | `ghcr.io/vectorize-io/hindsight:1.2.3` |
| ollama | `ollama/ollama:latest` |
| omniroute | `ghcr.io/cheaper-inference/omniroute:3.8.54-web-bun` |
| openknowledge | build local (`Dockerfile` no diretório do stack), tag `openknowledge:latest` |
| openwebui | `ghcr.io/open-webui/open-webui:v0.13.0` |
| postgres | `pgvector/pgvector:pg18` |
| qdrant | `qdrant/qdrant:v1.20` |
| redis | `redis:8.6.5-alpine` |
| synapse | `ghcr.io/element-hq/synapse:sha-5e78aad` |
| uptime-kuma | `louislam/uptime-kuma:2` |

### Rede e portas

- Todos os stacks entram na rede Docker externa **`edge-network`**, que precisa existir antes (`docker network create edge-network`). O OpenKnowledge usa também uma rede própria.
- O Caddy é o ponto de entrada principal: publica `80`, `443` (TCP e UDP/HTTP3) e também as portas de cada serviço, repassando pelo nome do container (`uptime-kuma:3001`, `synapse:8008`, `openwebui:8080`, `hermes:8642` e `hermes:9119`, `hindsight:9999`, `omniroute:20128/20129/20132`, entre outros). Fora do Caddy, o stack do CamoFox publica as próprias portas (API e VNC/noVNC) e o `uptime-kuma` também declara a `3001`.
- Os hostnames públicos são subdomínios DuckDNS no padrão `<serviço>-fabiosouzadev.duckdns.org` (monitoring, matrix, chat, notes, omniroute), definidos no `Caddyfile.tmpl`. Não há script de atualização do DuckDNS no repositório.

### Scripts de VPS

| Script | O que faz | Flag |
|--------|-----------|------|
| `vps/run_once_after_505-install-dockge.sh.tmpl` | sobe o Dockge em `~/.local/opt/dockge` | `features.dockge.install` |
| `vps/run_once_after_530-install-caddy.sh.tmpl` | instala o Caddy via apt (repositório Cloudsmith) e libera 80/443 no UFW | — |
| `vps/run_once_after_531-install-agentmemory.sh.tmpl` | `npm install -g @agentmemory/agentmemory` e habilita `agentmemory.service` | `features.hermes.agentmemory.enabled` |
| `vps/run_once_after_532-install-camofox.sh.tmpl` | instala `camofox-browser` em `~/camofox` e habilita `camofox.service` | `features.hermes.camofox.enabled` |

Pontos de atenção:

- As flags da VPS estão em `home/.chezmoidata/vps/features.yaml`. O chezmoi carrega **todos** os arquivos de `.chezmoidata/` (inclusive subdiretórios), então essas flags existem em qualquer máquina; quem restringe à VPS são os guards `workplace/script_is_vps` e o `.chezmoiignore.tmpl`.
- As units `agentmemory.service` e `camofox.service` **não estão no repositório**; o `enable` usa `|| true` e falha silenciosamente se a unit não existir.
- O script do Dockge espera um `compose.yaml` em `~/.local/opt/dockge`, mas o download está comentado.
- Lembrete do próprio script do Caddy: na Oracle Cloud é preciso liberar 80/443 também na Security List da VCN.

### Tailscale

`unix/run_once_after_556-configure-tailscale.sh.tmpl`, controlado por `features.tailscale.enabled`. Instala no Linux, habilita `tailscaled` e só avisa se não estiver autenticado (`sudo tailscale up` é manual). Não roda em máquinas Zup. No Termux há um script próprio (`termux/run_once_after_101-termux-tailscale.sh.tmpl`).

---

## 6. Segredos e criptografia

- **GPG**, não age: `encryption: gpg` em `home/.chezmoi.yaml.tmpl`, com um único `recipient` e `--quiet`.
- O executável do GPG é resolvido no template: no Windows, `~/scoop/apps/gnupg/current/bin/gpg.exe`; nos demais, `gpg` ou `gpg2` no `PATH`.
- Onde ficam os segredos:
  - `home/dot_keys/encrypted_*.txt.asc` — chaves de API consumidas por outros templates via `include | decrypt`.
  - `home/dot_zshrc.d/encrypted_3xx/4xx-*.zsh.asc` — variáveis de ambiente (tokens de IA, GitHub e trabalho).
  - `home/dot_local/opt/stacks/*/encrypted_dot_env.asc` — `.env` de cada stack.
  - `home/dot_hermes/encrypted_*`, `home/dot_aws/encrypted_private_credentials.asc` e outros.
- Os comentários de `executable_hermes-sync` ainda dizem "age/chezmoi"; isso está desatualizado — o fluxo real é `chezmoi add --encrypt`, que usa o GPG configurado.

Procedimento para adicionar segredos: ver [README, seção Segredos](../README.md#segredos).

---

## 7. Outras integrações

| Integração | Onde | Observação |
|------------|------|------------|
| GitHub | `github-cli`, clones SSH em `home/.chezmoidata/repos.json` (aplicados por `unix/run_onchange_after_605-clone-my-repos.sh.tmpl`) | tokens ficam nos `.zsh.asc` criptografados |
| GitLab | `glab` + `home/private_dot_config/glab-cli/` | — |
| WakaTime | `home/private_dot_wakatime.cfg.tmpl` (chave de `dot_keys/`), plugin zinit `wakatime-zsh-plugin` | — |
| AWS | `home/dot_aws/private_config.tmpl` (perfil SSO) + credenciais criptografadas | ambiente de trabalho |
| Maven | `home/dot_m2/settings.xml.tmpl` (mirror para um repositório AWS CodeArtifact) | ambiente de trabalho |
| Zup | `home/dot_zshrc.d/504-zup.zsh.tmpl` (só renderiza com `workplace = "Zup"`) | mapeia variáveis `ZUP_*` para `GITHUB_COPILOT_TOKEN`, `ZAI_*` (Z.AI/GLM), `CEREBRAS_*`, Ollama etc. |
| Logs | units systemd de usuário com `StandardOutput=journal` | `journalctl --user -u omniroute -f` |

Não há CI/CD configurado neste repositório (não existe `.github/` nem pipeline de GitLab). As variáveis `GITHUB_ACTIONS`, `GITLAB_CI`, `TRAVIS` etc. aparecem apenas na **detecção** de ambiente efêmero em `home/.chezmoi.yaml.tmpl`.

---

## 8. Plataformas suportadas

| Plataforma | Como é detectada |
|------------|-----------------|
| Linux (Arch-based, Ubuntu) | `.chezmoi.os` + `osRelease.id` → `settings.osid` (ex.: `linux-ubuntu`) |
| WSL | `osrelease` do kernel contém `microsoft` |
| macOS | `.chezmoi.os == "darwin"`; hostname via `scutil` |
| MacBook rodando Linux | hostname contém `macbook` (`settings.linuxonmac`) |
| Windows | `.chezmoi.os == "windows"`; ignora todo o zsh e `.chezmoiscripts/unix` |
| Termux | variável `TERMUX_VERSION` |
| VPS | hostname `instance-*`, contendo `vps`/`vnic`, `CHEZMOI_VPS`, ou Ubuntu + usuário `ubuntu` + SSH sem GUI |
| Ambientes efêmeros | CI, Codespaces, Gitpod, Replit, devcontainer |

A detecção de container (Distrobox, Lima, `/.dockerenv`, cgroup, Kubernetes) alimenta `settings.inContainer`, que conta para `headless`, mas **não** torna o ambiente efêmero.
