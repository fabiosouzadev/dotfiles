# Dotfiles Hardening (fabiosouzadev/dotfiles)

## What This Is

Repositório chezmoi que descreve o ambiente completo do Fabio (shell, editores, CLIs, ferramentas de IA, segredos GPG) em macOS, Arch/Ubuntu/WSL, Termux, Windows e numa VPS pessoal na Oracle Cloud, que roda 13 stacks Docker Compose (Caddy, OmniRoute, Hermes, Hindsight, Synapse, Postgres, Qdrant, Redis, Ollama, Open WebUI, OpenKnowledge, Camofox, Uptime Kuma) e o Dockge. Este ciclo endurece e estabiliza o que já existe: corrige os 26 itens levantados em `docs/pontos-de-atencao.md`.

## Core Value

`chezmoi apply` funciona em todo perfil suportado, e a VPS não expõe nada administrativo à internet; o que é público passa só pelo Caddy em 80/443 com HTTPS.

## Requirements

### Validated

<!-- Já existe e funciona no repositório. -->

- ✓ Detecção de ambiente e perfis (`personal`, `work`, `vps`, mais `ephemeral`/`headless`) em `home/.chezmoi.yaml.tmpl`, com overrides `CHEZMOI_*` — existing
- ✓ Dados por plataforma em `home/.chezmoidata/` e feature flags (`features.ai.*`, `features.hermes.*`, etc.) — existing
- ✓ Bootstrap por plataforma em `home/.chezmoiscripts/{linux,darwin,unix,termux,vps,windows}/` (51 scripts) com guards reutilizáveis em `home/.chezmoitemplates/` — existing
- ✓ Zsh modular em `home/dot_zshrc.d/` (19 módulos + 4 criptografados) — existing
- ✓ Configs de apps em `home/private_dot_config/` — existing
- ✓ Segredos versionados com GPG (`encrypted_*.asc`, 41 arquivos) — existing
- ✓ Instalação de ferramentas de IA a partir de `home/.chezmoidata/ai_tools.yaml` — existing
- ✓ Stacks Docker Compose da VPS em `home/dot_local/opt/stacks/` e Dockge em `home/dot_local/opt/dockge/` — existing
- ✓ Sync de config/estado do Hermes e do OmniRoute (`hermes-sync`, `omniroute-sync`) — existing
- ✓ Documentação técnica em pt-BR em `docs/` — existing

### Active

<!-- Os 26 itens de docs/pontos-de-atencao.md. IDs entre parênteses. -->

**Exposição da VPS e segurança**
- [ ] (A1) Security list da Oracle reduzida a 80/443 (mais SSH/Tailscale) e documentada; containers publicam só 80/443 ou em `127.0.0.1`/IP do Tailscale; painéis administrativos só via Tailscale
- [ ] (A2) Clientes (Claude Code, Codex, opencode, openclaude) falam com o OmniRoute só por HTTPS ou Tailscale, nunca `http://` no IP público
- [ ] (A3) `docker.sock` não fica acessível por painel exposto (Dockge só via Tailscale; Uptime Kuma via proxy de socket somente leitura ou sem socket)
- [ ] (M1) `ALLOW_API_KEY_REVEAL=false` no OmniRoute
- [ ] (M9) Cliente do Hindsight aponta para rota que existe (HTTPS no Caddy ou Tailscale)

**`chezmoi apply` quebrado / bugs de template e script**
- [ ] (A4) Template do Ollama em modo root usa `.features.ollama.environments`
- [ ] (A5) `termux.zsh.tmpl` não referencia chave inexistente
- [ ] (M2) Composio e flag `multiplexer` instalam quando habilitados (`:=` → `=`)
- [ ] (M4) Instalação do Ollama em modo user preserva `~/.ollama/models`
- [ ] (B7) Ramo de versão fixa do Ollama no macOS usa a chave certa
- [ ] Guard `script_is_instivo` pode passar (hoje nunca passa) e `script_arch_based_only` decide de forma intencional sobre Arch puro

**Backup e recuperação**
- [ ] (A6) Backup diário de Postgres, Qdrant e volumes para Backblaze B2 via restic, com retenção e restore testado
- [ ] (A6) Documento em `docs/` com a configuração do backup (conta B2, bucket, chave, segredos no chezmoi, restore)
- [ ] (M10) Procedimento documentado de backup e recuperação da chave GPG

**Confiabilidade e reprodutibilidade**
- [ ] (M3) Sem conflito na porta 3001; volume do Uptime Kuma sem caminho fixo `/home/ubuntu`
- [ ] (M5) Dependências com versão fixa (Ollama, Caddy, mise, OpenKnowledge)
- [ ] (M6) Uma única fonte de versão do OmniRoute; Dockerfile órfão e restos removidos
- [ ] (M7) Descoberta de versão nos instaladores sem `grep`/`sed` frágil (jq, `releases/latest/download` ou mise), glab funcionando no macOS
- [ ] (M8) CI que renderiza os templates por perfil, roda `shellcheck` e `docker compose config`

**Higiene e manutenção**
- [ ] (B1) Domínio e IP da VPS em variáveis de dados, não hardcoded
- [ ] (B2) ARENA_ELO_SYNC testado na versão atual, com comentário atualizado
- [ ] (B3) Bloco `chatgpt-web-codex-browser` documentado ou removido
- [ ] (B4) OmniRoute em `APP_LOG_LEVEL=info`
- [ ] (B5) Heap e limite de memória do OmniRoute dimensionados pelo uso real
- [ ] (B6) `HISTSIZE` finito
- [ ] (B8) Comentários dos scripts de sync dizem GPG, não age
- [ ] (B9) Arquivos duplicados/sobras removidos
- [ ] (B10) Monitoramento: volume do Uptime Kuma no backup, alertas de disco/memória, healthcheck do Hindsight reativado

### Out of Scope

- Kubernetes, réplicas de Postgres, Redis Cluster, balanceamento de vários OmniRoute, Envoy, Prometheus — VPS pessoal de um nó; ponto único de falha se resolve com backup e restore testado
- Trocar GPG por age — não resolve o risco da chave única
- Novas ferramentas, stacks ou plataformas — este ciclo só endurece o que já existe
- Backup no Object Storage da Oracle — mesma conta da VPS; se a conta cair, perde os dois

## Context

- Brownfield: mapa do código em `.planning/codebase/` (com erros conhecidos) e documentação verificada em `docs/` (pt-BR). `docs/pontos-de-atencao.md` é a fonte dos requisitos.
- A VPS fica na Oracle Cloud (Always Free) e **tem firewall no provedor (security list)**: o usuário abre uma porta manualmente para cada serviço novo. A exposição real é o conjunto de portas abertas na security list, que não está versionado no repositório. Portas publicadas pelo Docker passam por fora do `ufw`, então a security list é a única barreira hoje. A1 passa a ser: levantar as portas abertas, reduzir a 80/443 (mais o necessário para Tailscale/SSH) e documentar.
- Tailscale já está habilitado na VPS (`home/.chezmoidata/vps/features.yaml`).
- Os bugs de template (A4, A5, M2) foram confirmados com `chezmoi execute-template` (chezmoi v2.73.3).
- O usuário trabalha em pt-BR; documentação voltada a ele em `docs/` deve ser em pt-BR.
- Commits seguem Conventional Commits em inglês, direto em `main`, remoto no Codeberg.

## Constraints

- **Plataformas**: mudanças não podem quebrar nenhum perfil (Linux pessoal, work/WSL, VPS, macOS, Termux, Windows) — o repositório é o mesmo para todos
- **Segredos**: nenhum valor sensível em texto claro; tudo como `encrypted_*.asc` (GPG, recipient em `home/.chezmoi.yaml.tmpl`)
- **Custo**: soluções grátis ou dentro de cotas grátis (Oracle Always Free, Backblaze B2 10 GB)
- **Acesso à VPS**: mexer em portas e firewall não pode trancar o acesso SSH/Tailscale; cada mudança de rede precisa de caminho de volta
- **Ação manual**: criar conta e bucket no Backblaze e alterar a security list da Oracle são feitos pelo usuário no console, quando a fase correspondente chegar

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Escopo v1 = os 26 itens (Alta, Média e Baixa) | Escolha do usuário | — Pending |
| Público só pelo Caddy em 80/443; painéis administrativos só via Tailscale, também servidos pelo Caddy | Hoje cada serviço novo exige abrir porta na security list e trafega em HTTP; com Tailscale não é preciso abrir porta nenhuma para painéis. Caddy pode emitir certificado para `*.ts.net` | — Pending |
| Security list da Oracle documentada em `docs/` | Regras de firewall não estão no repositório; precisam de registro para auditar e recriar | — Pending |
| Backup no Backblaze B2 com restic | Fora da conta Oracle, 10 GB grátis, sem cartão, suporte nativo no restic | — Pending |
| Documentar a configuração do backup em `docs/` ao chegar na fase | Pedido do usuário | — Pending |
| Documentação voltada ao usuário em pt-BR | Preferência do usuário | ✓ Good |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-11-24 after initialization*
