# Pontos de atenção

Levantamento de dívida técnica, bugs, riscos de segurança e lacunas deste repositório de dotfiles (chezmoi, fonte em `home/`) e das stacks Docker da VPS pessoal.

Este documento parte de `.planning/codebase/CONCERNS.md`, mas cada item foi conferido no código. O que não se confirmou foi corrigido ou descartado (veja [Itens revisados e descartados](#itens-revisados-e-descartados)). Também entraram problemas novos, encontrados durante a verificação.

Revisado em: 2026-11-24.

## Resumo

| Prioridade | Itens |
|---|---|
| Alta | 6 |
| Média | 10 |
| Baixa | 10 |

Critério usado:

- **Alta**: expõe credenciais ou o host, quebra o `chezmoi apply` ou pode causar perda de dados sem volta.
- **Média**: bug real com efeito limitado, ou fragilidade que tende a quebrar com o tempo.
- **Baixa**: higiene, reaproveitamento do repositório ou risco pequeno.

---

## Prioridade Alta

### A1. Portas HTTP publicadas em todas as interfaces da VPS

- **Problema:** o Caddy publica no host, sem TLS e sem filtro de origem, várias portas além da 80/443: 3001 (Uptime Kuma), 6333 (Qdrant), 8008 (Synapse), 8084 (Open WebUI), 8085 (OpenKnowledge), 8642 e 9119 (Hermes gateway e dashboard), 9999 (dashboard do Hindsight), 20128, 20129 e 20132 (OmniRoute: dashboard, API e WebSocket). O Camofox também publica direto a API (9377), o noVNC (6080) e o VNC (5901), com `VNC_BIND=0.0.0.0`. O Dockge publica a 5001.
- **Onde:**
  - `home/dot_local/opt/stacks/caddy/compose.yaml.tmpl`
  - `home/dot_local/opt/stacks/caddy/Caddyfile.tmpl` (blocos `http://:<porta>`)
  - `home/dot_local/opt/stacks/camofox/compose.yaml.tmpl`
  - `home/dot_local/opt/dockge/compose.yaml.tmpl`
- **Impacto:** o script `home/.chezmoiscripts/vps/run_once_after_530-install-caddy.sh.tmpl` libera só 80/443 no `ufw`, mas portas publicadas pelo Docker passam por fora do `ufw`, porque o Docker escreve as próprias regras de iptables. Sem um firewall externo (security list do provedor), esses serviços ficam acessíveis pela internet em HTTP puro. Isso inclui o Qdrant, os dashboards e o navegador do Camofox, que guarda cookies de sessão. O repositório não mostra se existe esse firewall externo.
- **Sugestão:** publicar só 80/443 e servir os demais serviços por subdomínio HTTPS no Caddy. Para acesso administrativo, publicar em `127.0.0.1:<porta>` ou no IP do Tailscale, que já está habilitado em `home/.chezmoidata/vps/features.yaml`. Conferir e documentar as regras do firewall do provedor.

### A2. Chave da API do OmniRoute trafegando em texto claro

- **Problema:** vários clientes falam com a API do OmniRoute por `http://` direto no IP público da VPS, na porta 20129. O IP está hardcoded nesses arquivos.
- **Onde:**
  - `home/dot_claude/settings.json.tmpl`
  - `home/dot_codex/private_config.toml.tmpl`
  - `home/private_dot_config/opencode/opencode.json.tmpl`
  - `home/dot_zshrc.d/604-openclaude.zsh.tmpl`
- **Impacto:** o cabeçalho de autenticação (a chave da API) e o conteúdo dos prompts passam pela internet sem criptografia. Qualquer ponto no caminho consegue capturar a chave e usar a cota dos provedores de LLM.
- **Sugestão:** usar a URL HTTPS do domínio, que já existe para o dashboard (`OMNIROUTE_PUBLIC_BASE_URL`), ou o endereço do Tailscale. Tirar o IP dos templates e colocá-lo numa variável de dados (veja B1).

### A3. `docker.sock` montado em serviços acessíveis pela rede

- **Problema:** o Dockge (porta 5001 publicada, `DOCKGE_ENABLE_CONSOLE=true`) e o Uptime Kuma montam `/var/run/docker.sock`.
- **Onde:**
  - `home/dot_local/opt/dockge/compose.yaml.tmpl`
  - `home/dot_local/opt/stacks/uptime-kuma/compose.yaml.tmpl`
- **Impacto:** quem controla o socket do Docker tem, na prática, root no host. Se alguém comprometer o login de um desses painéis, ou se eles ficarem expostos (A1), a VPS inteira fica comprometida.
- **Sugestão:** deixar o Dockge acessível só por Tailscale ou túnel SSH. No Uptime Kuma, usar um proxy de socket somente leitura (por exemplo `docker-socket-proxy`) ou tirar a montagem se o monitoramento de containers não for necessário.

### A4. Template do Ollama quebra no modo `root` (Linux pessoal)

- **Problema:** o bloco de override do systemd faz `range .features.ai.ollama.environments`, mas essa chave não existe. As variáveis estão em `.features.ollama.environments` (`home/.chezmoidata/ollama.yaml`). Testado com `chezmoi execute-template`, o resultado é `map has no entry for key "ollama"`.
- **Onde:** `home/.chezmoiscripts/linux/run_once_after_504-install-ollama.sh.tmpl`
- **Impacto:** o modo `root` é o padrão em Linux não gerenciado, com sudo e systemd, fora da VPS (veja `home/.chezmoi.yaml.tmpl`). Nesses hosts o chezmoi não consegue renderizar o script, e o `chezmoi apply` falha. Scripts `run_once_` são renderizados a cada apply para calcular o hash, então a falha se repete sempre.
- **Sugestão:** trocar por `.features.ollama.environments`. Depois, validar com `chezmoi execute-template < arquivo` num perfil Linux.

### A5. Template do Termux quebra por chave inexistente

- **Problema:** a função `qr-ssh` usa `{{ .features.ai.omniroute.domain | default "..." }}`. Como a chave `omniroute` não existe em `.features.ai`, o template falha antes de chegar ao `default` (confirmado com `chezmoi execute-template`).
- **Onde:** `home/dot_zshrc.d/termux.zsh.tmpl`
- **Impacto:** no Termux (`.settings.termux` verdadeiro), o `chezmoi apply` falha nesse arquivo.
- **Sugestão:** usar o valor que já existe, `.termux.ssh.vps_host` (`home/.chezmoidata/termux/data.yaml`), ou proteger o acesso com `dig "ai" "omniroute" "domain" "<padrão>" .features`.

### A6. Sem backup dos dados persistentes das stacks

- **Problema:** não existe rotina de backup (nem `pg_dump`, nem snapshot) para o PostgreSQL, que guarda dados do Synapse, do Hindsight e de outros serviços, nem para o Qdrant ou para os volumes Docker (Open WebUI, OpenKnowledge, Uptime Kuma, Dockge). O que existe é parcial: `home/dot_local/bin/executable_omniroute-sync` e `home/dot_local/bin/executable_hermes-sync` versionam, criptografadas no chezmoi, só a configuração e o estado essencial do OmniRoute e do Hermes. Os próprios scripts avisam que não são backup completo.
- **Onde:**
  - `home/dot_local/opt/stacks/postgres/`
  - `home/dot_local/opt/stacks/qdrant/`
  - `home/dot_local/opt/stacks/synapse/`
  - `home/dot_local/opt/stacks/hindsight/`
- **Impacto:** se o disco da VPS falhar ou a instância for perdida, histórico do Matrix, memórias do Hindsight e embeddings se perdem para sempre. Migrar para outra VPS exige trabalho manual.
- **Sugestão:** criar um job agendado (systemd timer ou cron) com `pg_dumpall`, snapshot do Qdrant pela API e cópia para fora da VPS, por exemplo com `restic` para um storage externo. Documentar e testar o restore pelo menos uma vez.

---

## Prioridade Média

### M1. `ALLOW_API_KEY_REVEAL=true` no OmniRoute

- **Problema:** o dashboard permite revelar as chaves de API cadastradas.
- **Onde:** `home/dot_local/opt/stacks/omniroute/compose.yaml.tmpl`
- **Impacto:** junto com o dashboard publicado em HTTP na porta 20128 (A1), uma sessão do dashboard comprometida entrega todas as chaves dos provedores. `REQUIRE_API_KEY=true` reduz o risco, mas não o elimina.
- **Sugestão:** usar `ALLOW_API_KEY_REVEAL=false` e ligar só quando precisar. Acessar o dashboard apenas pelo domínio HTTPS ou pelo Tailscale.

### M2. Composio nunca é instalado (variável sombreada no template)

- **Problema:** no instalador de ferramentas de IA, o caso `composio.install` usa `{{ $featureEnabled := ... }}` (com `:=`) dentro de um `if`. Isso cria uma nova variável, que só vale dentro do bloco. A variável de fora continua `false`. O mesmo acontece no caso `multiplexer` da seção NPM, que hoje não afeta nada porque nenhuma ferramenta NPM usa essa flag. Comportamento confirmado com `chezmoi execute-template`.
- **Onde:** `home/.chezmoiscripts/unix/run_once_after_590-install-ai-tools.sh.tmpl` (lista em `home/.chezmoidata/ai_tools.yaml`)
- **Impacto:** o Composio não é instalado mesmo com `features.hermes.composio.enabled: true`, e nenhum erro aparece.
- **Sugestão:** trocar `:=` por `=` nessas linhas.

### M3. Conflito na porta 3001 entre Caddy e Uptime Kuma

- **Problema:** as duas stacks publicam `3001:3001` no host.
- **Onde:**
  - `home/dot_local/opt/stacks/caddy/compose.yaml.tmpl`
  - `home/dot_local/opt/stacks/uptime-kuma/compose.yaml.tmpl`
- **Impacto:** a stack que subir por último falha com "port is already allocated". A ordem de subida decide qual delas funciona. Além disso, o volume do Uptime Kuma usa o caminho fixo `/home/ubuntu/...` em vez de `{{ .chezmoi.homeDir }}`.
- **Sugestão:** tirar o `ports` do Uptime Kuma, que já está na `edge-network` e é servido pelo Caddy em `monitoring-...`, e parametrizar o caminho do volume.

### M4. Instalação do Ollama em modo `user` apaga `~/.ollama`

- **Problema:** o modo `user` (WSL ou máquina gerenciada) roda `rm -rf "$HOME/.ollama"` antes de instalar.
- **Onde:** `home/.chezmoiscripts/linux/run_once_after_504-install-ollama.sh.tmpl`
- **Impacto:** apaga os modelos baixados (podem ser vários GB) e a chave de identidade do Ollama sempre que o script roda de novo, por exemplo após `chezmoi state delete-bucket` ou ao mudar o conteúdo do script.
- **Sugestão:** remover só os binários e as bibliotecas antigas (`$INSTALL_DIR/bin/ollama`, `$INSTALL_DIR/lib/ollama`) e preservar `~/.ollama/models`.

### M5. Dependências sem versão fixa

- **Problema:** várias dependências seguem a versão mais recente, sem fixação:
  - imagem `ollama/ollama:latest`
  - `version: "latest"` para o Ollama nativo
  - `caddy:alpine` sem versão
  - várias ferramentas em `latest` no mise (node, java, go, python, uv e pacotes npm, entre eles `@inkeep/open-knowledge`)
  - `npm install -g @inkeep/open-knowledge` sem versão no Dockerfile do OpenKnowledge
- **Onde:**
  - `home/dot_local/opt/stacks/ollama/compose.yaml.tmpl`
  - `home/.chezmoidata/ollama.yaml`
  - `home/dot_local/opt/stacks/caddy/compose.yaml.tmpl`
  - `home/private_dot_config/mise/config.toml.tmpl`
  - `home/dot_local/opt/stacks/openknowledge/Dockerfile`
- **Impacto:** o ambiente não é reproduzível, uma atualização pode quebrar algo sem aviso e fica difícil voltar à versão anterior. A maioria das outras imagens já está fixada (Synapse por SHA, Qdrant, Redis, Hindsight, Hermes, Open WebUI, Camofox).
- **Sugestão:** fixar versões nos pontos acima e atualizar de forma intencional, com Renovate ou revisão periódica. Observação: `openknowledge:latest` é só a tag da imagem construída localmente. O problema real está no `npm install` sem versão dentro do Dockerfile.

### M6. Versões do OmniRoute divergentes e restos de configuração antiga

- **Problema:** o repositório tem quatro referências diferentes ao OmniRoute:
  - o compose usa `ghcr.io/cheaper-inference/omniroute:3.8.54-web-bun`
  - o `Dockerfile` da stack parte de `diegosouzapw/omniroute:3.8.49-web` e não é usado pelo compose (não há `build:`)
  - `home/.chezmoidata/omniroute.yaml` declara a versão `3.8.46`, mas nenhum template lê esse valor
  - o serviço comentado `chatgpt-web-codex-browser` aponta para `release/v3.8.51` do repositório antigo
- **Onde:**
  - `home/dot_local/opt/stacks/omniroute/compose.yaml.tmpl`
  - `home/dot_local/opt/stacks/omniroute/Dockerfile`
  - `home/.chezmoidata/omniroute.yaml`
- **Impacto:** não fica claro qual versão é a oficial. A imagem também mudou de publicador (de `diegosouzapw` para `cheaper-inference`), um sinal de risco de manutenção em projeto de terceiros.
- **Sugestão:** manter uma única fonte de versão (o dado em `.chezmoidata` usado pelo compose), apagar o Dockerfile órfão ou ligá-lo ao compose, e acompanhar o repositório upstream. Ter em mente uma alternativa, como o LiteLLM, caso o projeto pare.

### M7. Descoberta frágil da versão mais recente nos instaladores

- **Problema:** os instaladores descobrem a última versão consultando a API do GitHub com `curl | grep | sed`, sem `jq`, sem token e sem validar o formato da versão. No Ollama Linux e macOS a chamada usa `curl -s`, sem `-f`. O glab consulta a API do **GitLab** com `grep -oP`, e essa opção não existe no `grep` BSD do macOS, embora o script tente suportar Darwin.
- **Onde:**
  - `home/.chezmoiscripts/linux/run_once_after_504-install-ollama.sh.tmpl`
  - `home/.chezmoiscripts/darwin/run_once_after_504-install-ollama-darwin.sh.tmpl`
  - `home/.chezmoiscripts/unix/run_once_after_529-install-lazygit.sh.tmpl`
  - `home/.chezmoiscripts/unix/run_once_after_536-install-atuin.sh.tmpl`
  - `home/.chezmoiscripts/unix/run_once_after_528-install-glab.sh.tmpl`
- **Impacto:** quando a API do GitHub bloqueia por limite de requisições (60 por hora sem token) ou muda o formato da resposta, a versão sai vazia. Lazygit, atuin e glab detectam isso e abortam com mensagem. O Ollama só falha depois, num download com URL inválida. No macOS o glab sempre falha.
- **Sugestão:** usar `jq -r .tag_name`, ou os redirecionamentos `releases/latest/download/...`, ou `gh api`. Aceitar `GITHUB_TOKEN` quando houver. No glab, trocar `grep -oP` por `jq`. Uma alternativa melhor é instalar essas ferramentas pelo mise, que já está no repositório.

### M8. Nenhuma validação automática (CI, lint, renderização)

- **Problema:** o repositório não tem CI (não há `.github/`), nem `shellcheck`, nem `docker compose config`, nem teste que renderize os templates por perfil.
- **Onde:**
  - `home/.chezmoiscripts/` (51 scripts)
  - `home/dot_local/opt/stacks/*/compose.yaml.tmpl` (13 stacks, mais `home/dot_local/opt/dockge/`)
  - `home/.chezmoi.yaml.tmpl` (cerca de 280 linhas de detecção de perfil)
- **Impacto:** erros como A4, A5 e M2 só aparecem no `chezmoi apply` da máquina afetada.
- **Sugestão:** um workflow simples que, para cada perfil (Linux, VPS, macOS, Termux), rode `chezmoi execute-template` sobre todos os `.tmpl` com dados simulados, depois `shellcheck` nos scripts renderizados e `docker compose config` nas stacks. Os arquivos `.asc` exigem desligar a descriptografia ou usar dados falsos no CI.

### M9. Cliente do Hindsight aponta para uma porta não publicada

- **Problema:** a configuração do agente de código usa `http://<IP público da VPS hardcoded>:8888`, mas o compose do Hindsight só faz `expose` da porta 8888 (rede interna) e o Caddy não a publica.
- **Onde:**
  - `home/dot_hindsight/coding-agent.json.tmpl`
  - `home/dot_local/opt/stacks/hindsight/compose.yaml.tmpl`
- **Impacto:** a configuração provavelmente não funciona fora da VPS. Se um dia a porta for publicada para corrigir isso, vai trafegar em HTTP puro (A2).
- **Sugestão:** criar uma rota HTTPS no Caddy para a API do Hindsight, ou acessar pelo Tailscale, e ajustar o template.

### M10. Todos os segredos dependem de uma única chave GPG

- **Problema:** o repositório tem 41 arquivos `.asc` (GPG, `encryption: gpg` em `home/.chezmoi.yaml.tmpl`): credenciais AWS, chaves SSH, `.env` das stacks, dumps de configuração, cookies. A recuperação da chave privada não está documentada.
- **Onde:** arquivos `encrypted_*.asc` em `home/` (por exemplo `home/dot_keys/`, `home/private_dot_ssh/`, `home/dot_local/opt/stacks/*/`)
- **Impacto:** perder a chave GPG significa perder o acesso a todos os segredos. O bootstrap de uma máquina nova também depende de importar essa chave antes do primeiro apply.
- **Sugestão:** manter uma cópia offline da chave (papel ou mídia cifrada) e uma subchave de criptografia com data de validade. Documentar no README o passo de importação e de recuperação. O age não é necessário: dá para trocar, mas não resolve o problema da chave única.

---

## Prioridade Baixa

### B1. Domínio e IP hardcoded

- **Problema:** os subdomínios `*-fabiosouzadev.duckdns.org` e o IP público da VPS aparecem escritos direto em vários templates.
- **Onde:**
  - `home/dot_local/opt/stacks/caddy/Caddyfile.tmpl`
  - `home/dot_local/opt/stacks/omniroute/compose.yaml.tmpl`
  - `home/dot_local/opt/stacks/synapse/`
  - `home/dot_local/opt/stacks/openknowledge/compose.yaml.tmpl`
  - `home/dot_hermes/config.yaml.tmpl`
  - `home/.chezmoidata/termux/data.yaml`
  - os clientes listados em A2
- **Impacto:** trocar de VPS ou de domínio exige buscar e substituir em vários arquivos. O repositório também fica difícil de reaproveitar.
- **Sugestão:** criar algo como `vps.domain` e `vps.host` em `.chezmoidata/vps/` e referenciar por template.

### B2. `ARENA_ELO_SYNC_ENABLED=false` com comentário possivelmente desatualizado

- **Problema:** o sync de ELO está desligado com o comentário `#Erro nesta versão`, que foi escrito para uma versão anterior. A imagem atual é a 3.8.54.
- **Onde:** `home/dot_local/opt/stacks/omniroute/compose.yaml.tmpl`
- **Impacto:** um recurso pode estar desligado sem necessidade.
- **Sugestão:** testar na versão atual e registrar no comentário a versão e o erro observado.

### B3. Serviço `chatgpt-web-codex-browser` desativado

- **Problema:** o serviço e a rede dedicada estão comentados, junto com `CHATGPT_WEB_CODEX_CDP_URL`.
- **Onde:** `home/dot_local/opt/stacks/omniroute/compose.yaml.tmpl`
- **Impacto:** o recurso do OmniRoute que usa esse navegador fica indisponível. O motivo da desativação não está registrado.
- **Sugestão:** registrar o motivo ou remover o bloco. Se for reativar, manter a rede isolada que o próprio comentário recomenda.

### B4. OmniRoute em `APP_LOG_LEVEL=debug`

- **Problema:** a produção roda com log em nível debug.
- **Onde:** `home/dot_local/opt/stacks/omniroute/compose.yaml.tmpl`
- **Impacto:** gera mais volume em disco e pode gravar detalhes de requisições nos logs.
- **Sugestão:** usar `info` no dia a dia e `debug` só para investigar problemas.

### B5. Heap de 8 GB no OmniRoute sem limite no container

- **Problema:** `OMNIROUTE_MEMORY_MB=8192` e `--max-old-space-size=8192`, sem `deploy.resources.limits`. O Camofox, por exemplo, tem limite.
- **Onde:** `home/dot_local/opt/stacks/omniroute/compose.yaml.tmpl`
- **Impacto:** o OmniRoute é um gateway e não roda modelos, então 8 GB tende a sobrar, não a faltar. Se houver vazamento de memória, ele pode disputar RAM com Postgres, Synapse e os outros serviços da mesma VPS.
- **Sugestão:** medir o uso real (`docker stats`) e definir heap e limite do container de acordo.

### B6. Histórico do zsh com `HISTSIZE=1000000000`

- **Problema:** o histórico está configurado para um bilhão de entradas.
- **Onde:** `home/dot_zshrc.d/102-history.zsh.tmpl`
- **Impacto:** pequeno na prática. As opções `hist_ignore_all_dups` e `hist_save_no_dups` contêm o crescimento, e o atuin (`home/dot_zshrc.d/200-atuin.zsh.tmpl`) já faz a busca. Ainda assim, o zsh carrega o arquivo inteiro na memória a cada shell.
- **Sugestão:** usar um valor finito, como 100 mil ou 1 milhão de entradas, e deixar o histórico de longo prazo para o atuin.

### B7. Ramo latente quebrado no instalador do Ollama para macOS

- **Problema:** quando a versão não é `latest`, o script lê `.features.ai.ollama.version`, uma chave que não existe. O correto é `.features.ollama.version`.
- **Onde:** `home/.chezmoiscripts/darwin/run_once_after_504-install-ollama-darwin.sh.tmpl`
- **Impacto:** hoje não tem efeito, porque a versão é `latest`. Se alguém fixar a versão (M5), o template passa a quebrar no macOS.
- **Sugestão:** corrigir a chave junto com A4.

### B8. Comentários dizem "age", mas o repositório usa GPG

- **Problema:** os cabeçalhos dos scripts de sync descrevem a criptografia como "Chezmoi + age", mas a configuração usa `encryption: gpg` e os arquivos são `.asc` (PGP).
- **Onde:**
  - `home/dot_local/bin/executable_omniroute-sync`
  - `home/dot_local/bin/executable_hermes-sync`
- **Impacto:** a documentação engana quem precisar recuperar os segredos.
- **Sugestão:** atualizar os comentários.

### B9. Arquivos duplicados e sobras

- **Problema:** há dois arquivos de log config do Synapse com conteúdo idêntico. Só `matrix-fabiosouzadev.duckdns.org.log.config.tmpl` é referenciado em `homeserver.yaml.tmpl`, e a outra cópia (sem hífen) sobrou. Existe também `home/private_dot_config/hypr/hyprland.conf.save`, um backup de editor.
- **Onde:**
  - `home/dot_local/opt/stacks/synapse/data/`
  - `home/private_dot_config/hypr/`
- **Impacto:** confusão na manutenção e arquivos extras gravados no home.
- **Sugestão:** remover os arquivos que sobraram.

### B10. Monitoramento parcial

- **Problema:** o Uptime Kuma existe (`home/dot_local/opt/stacks/uptime-kuma/`), mas os monitores e alertas ficam no volume do container, fora do repositório. Também não há alertas de disco, memória ou expiração de certificado documentados. O healthcheck do Hindsight está comentado.
- **Onde:**
  - `home/dot_local/opt/stacks/uptime-kuma/compose.yaml.tmpl`
  - `home/dot_local/opt/stacks/hindsight/compose.yaml.tmpl`
- **Impacto:** se o volume se perder, a configuração de monitoramento vai junto. Problemas de recurso só aparecem quando um serviço cai.
- **Sugestão:** incluir o volume do Uptime Kuma no backup (A6), criar monitores de disco e memória (por exemplo um push monitor alimentado por cron) e reativar o healthcheck do Hindsight.

---

## Itens revisados e descartados

Pontos de `.planning/codebase/CONCERNS.md` que foram corrigidos acima ou descartados por não se confirmarem ou não fazerem sentido para uma VPS pessoal:

| Afirmação original | Situação |
|---|---|
| "Sem monitoramento" | Corrigido: existe a stack Uptime Kuma. O que falta está em B10. |
| "Considerar criptografia age" | Descartado: o repositório usa GPG, e trocar não resolve o risco da chave única (M10). |
| "Rotacionar o histórico para 50 milhões de linhas" | Descartado: o valor não faz sentido. B6 sugere um limite realista. |
| Scripts sem `set -euo pipefail` | Descartado: todos os scripts bash incluem `common/script_helper`, que define `set -euo pipefail`. |
| Imagem `diegosouzapw/omniroute:3.8.52-web` | Corrigido: o compose usa `ghcr.io/cheaper-inference/omniroute:3.8.54-web-bun` (M6). |
| Health check do OmniRoute "sem timeout" | Descartado: o compose define `timeout: 5s`. |
| Memória do OmniRoute "insuficiente" | Invertido: o risco é sobrar heap sem limite no container (B5). |
| Hindsight depende do Qdrant | Descartado: o compose do Hindsight não referencia o Qdrant, ele usa a rede do Postgres. |
| Riscos de permissão SSH no entrypoint do OpenKnowledge | Descartado: o script usa `install -m 600/700`, `StrictHostKeyChecking yes` e valida os segredos. |
| `openknowledge:latest` como imagem sem versão | Corrigido: é a tag local do build. O problema real é o `npm install` sem versão (M5). |
| glab "usa a API do GitHub" | Corrigido: usa a API do GitLab, com `grep -oP` (M7). |
| 56 scripts em `.chezmoiscripts/` | Corrigido: são 51. |
| Números de linha citados | Removidos: só os caminhos de arquivo foram mantidos. |
| Réplicas de Postgres, Redis Cluster, Kubernetes, balanceamento de várias instâncias do OmniRoute, serviço de rate limit dedicado (Envoy), JWT/HMAC no lugar de allowlist, Prometheus | Fora do escopo: é uma VPS pessoal com um único nó. O ponto de falha único se resolve com backup e restore testado (A6), não com cluster. |
| Gargalo de rate limit no Redis | Descartado: não há volume de tráfego que justifique. |
| Confirmados sem alteração | ARENA_ELO_SYNC desligado (B2), `ALLOW_API_KEY_REVEAL=true` (M1), 41 arquivos `.asc` (M10), `HISTSIZE=1000000000` (B6), descoberta de versão com `grep`/`sed` no Ollama, lazygit e atuin (M7). |
