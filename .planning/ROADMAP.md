# Roadmap: Dotfiles Hardening (fabiosouzadev/dotfiles)

## Overview

Este ciclo endurece o repositório chezmoi e a VPS em quatro fases. Primeiro o `chezmoi apply` volta a funcionar em todo perfil e ganha um CI que barra regressões. Com essa rede de segurança, a VPS passa a expor à internet só o Caddy em 80/443, os painéis administrativos vão para a tailnet e a security list da Oracle é documentada e reduzida. Em seguida, os dados das stacks ganham backup diário fora da Oracle, com restore testado, recuperação da chave GPG documentada e alertas de recurso. Por fim, versões fixas, uma fonte única de versão do OmniRoute e a remoção de sobras deixam o ambiente reproduzível. Fonte de todos os requisitos: `docs/pontos-de-atencao.md`.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [ ] **Phase 1: Apply em todo perfil e CI** - Corrige templates e instaladores quebrados e põe um CI que renderiza cada perfil a cada push
- [ ] **Phase 2: Rede da VPS com Caddy e Tailscale** - Só 80/443 públicos pelo Caddy; painéis e clientes por HTTPS ou Tailscale; security list documentada e reduzida
- [ ] **Phase 3: Backup, restore e monitoramento** - Backup diário para o Backblaze B2 com restore testado, recuperação da chave GPG e alertas de disco e memória
- [ ] **Phase 4: Reprodutibilidade e higiene** - Versões fixas, fonte única de versão do OmniRoute, ajuste de produção medido e remoção de sobras

## Phase Details

### Phase 1: Apply em todo perfil e CI
**Goal**: `chezmoi apply` renderiza e executa sem erro em todo perfil suportado (Linux root e user, VPS, macOS, Termux), e qualquer regressão de template ou script é barrada automaticamente a cada push.
**Depends on**: Nothing (first phase)
**Requirements**: APPLY-01, APPLY-02, APPLY-03, APPLY-04, APPLY-05, APPLY-06, REL-04, REL-05
**Success Criteria** (what must be TRUE):
  1. `chezmoi execute-template` do instalador do Ollama em modo root (Linux pessoal) e do `termux.zsh.tmpl` (Termux) termina sem `map has no entry for key`, e fixar `features.ollama.version` numa versão específica também renderiza o instalador do macOS.
  2. Com `features.hermes.composio.enabled: true` o apply instala o Composio (e as ferramentas com flag `multiplexer`, quando ligada), e reinstalar o Ollama em modo user mantém `~/.ollama/models` e a chave de identidade.
  3. Um script protegido por `script_is_instivo` roda quando o contexto Instivo está ativo, e o comportamento de `script_arch_based_only` em Arch puro é intencional e está documentado no próprio guard.
  4. Os instaladores de Ollama, lazygit, atuin e glab descobrem a versão sem `grep`/`sed` frágil, abortam com mensagem clara quando a consulta falha, e o glab instala no macOS.
  5. Cada push no Codeberg dispara um CI que renderiza os templates dos perfis Linux, VPS, macOS e Termux com dados simulados, roda `shellcheck` nos scripts renderizados e `docker compose config` nas stacks, e falha se um bug como A4 ou A5 voltar.
**Plans:** 3/6 plans executed

Plans:
**Wave 1**
- [x] 01-01-PLAN.md — Harness de CI (`ci/render.sh` com 5 perfis simulados, shellcheck, `docker compose config`) e workflow Forgejo no Codeberg (wave 1)

**Wave 2** *(blocked on Wave 1 completion)*
- [x] 01-02-PLAN.md — Instaladores: helper de versão com jq (Ollama, lazygit, atuin, glab), A4, M4, B7 e glab no macOS (wave 2)
- [x] 01-03-PLAN.md — Templates: A5 (Termux), M2 (Composio), quebras de render em Arch e drivers, avisos de shellcheck (wave 2)

**Wave 3** *(blocked on Wave 2 completion)*
- [ ] 01-04-PLAN.md — Guards documentados (Instivo legado, Arch puro), remoção do coderabbit, docs do CI e do plano B, texto de APPLY-06 (wave 3)
- [ ] 01-05-PLAN.md — Regressões nomeadas e autoteste por mutação: o CI falha se A4/A5/M2/M4/B7 voltarem (wave 3)

**Wave 4** *(blocked on Wave 3 completion)*
- [ ] 01-06-PLAN.md — Ativar Actions no Codeberg, push e confirmar a primeira execução verde (checkpoint, wave 4)

**Notas**: o remoto é o Codeberg (não há `.github/`), então o CI roda em Forgejo Actions ou Woodpecker, a decidir no planejamento. Os `encrypted_*.asc` exigem descriptografia desligada ou dados falsos no CI. Os guards de APPLY-06 ficam em `home/.chezmoitemplates/workplace/script_is_instivo` e `home/.chezmoitemplates/linux/script_arch_based_only`; esse item não consta de `docs/pontos-de-atencao.md`.

### Phase 2: Rede da VPS com Caddy e Tailscale
**Goal**: Da internet só se alcança o Caddy em 80/443 com HTTPS; painéis administrativos e o `docker.sock` só ficam ao alcance da tailnet; todo cliente fala com a VPS por canal criptografado; e a security list da Oracle está documentada e reduzida sem perder o acesso à VPS.
**Depends on**: Phase 1
**Requirements**: NET-01, NET-02, NET-03, NET-04, NET-05, NET-06, SEC-01, SEC-02, REL-01, HYG-01
**Success Criteria** (what must be TRUE):
  1. Existe em `docs/` (pt-BR) o registro das regras da security list da Oracle antes e depois da mudança, com o caminho de volta para o caso de o SSH ou o Tailscale pararem de responder.
  2. Na VPS, `ss -tlnp` e `docker ps` mostram só 80/443 publicados em todas as interfaces; o resto escuta em `127.0.0.1`, no IP do Tailscale ou só na rede Docker; os serviços que continuam públicos respondem por subdomínio HTTPS na 443; e Caddy e Uptime Kuma sobem juntos, em qualquer ordem, sem conflito na 3001.
  3. De um dispositivo na tailnet o usuário abre por HTTPS, servido pelo Caddy, o Dockge, os dashboards do Hermes, do Hindsight e do OmniRoute, o Qdrant, o Uptime Kuma e o noVNC do Camofox; de fora da tailnet nenhum deles responde; o Uptime Kuma não monta `docker.sock` com escrita; e o dashboard do OmniRoute não revela chaves de API.
  4. Claude Code, Codex, opencode, openclaude e o cliente do Hindsight funcionam com URLs HTTPS ou Tailscale renderizadas a partir de variáveis em `home/.chezmoidata/vps/`, e uma busca pelo IP público e por `duckdns.org` nos templates não encontra nada fora dessas variáveis.
  5. Depois de o usuário reduzir a security list a 80/443 (mais o necessário para SSH/Tailscale), o SSH e o Tailscale continuam funcionando, e um scan externo das portas listadas em A1 de `docs/pontos-de-atencao.md` não encontra nenhuma aberta.
**Plans**: TBD
**Ordem interna**: NET-01 (documentar a security list atual) antes de qualquer mudança de rede. HYG-01 antes de NET-05 e NET-06, porque mexem nos mesmos templates de cliente. NET-05 e NET-06 antes de NET-04, senão os clientes que ainda usam `http://<IP>:20129` quebram. NET-04 por último.
**Ação manual**: NET-04 é feita pelo usuário no console da Oracle, com uma sessão SSH aberta e o caminho de volta já documentado.

### Phase 3: Backup, restore e monitoramento
**Goal**: Se o disco ou a instância da VPS se perderem, ou se a chave GPG sumir, o usuário recupera dados e segredos seguindo documentos testados; falta de disco ou de memória vira alerta antes de derrubar um serviço.
**Depends on**: Phase 2
**Requirements**: BKP-01, BKP-02, BKP-03, BKP-04, SEC-03, REL-06, HYG-07
**Success Criteria** (what must be TRUE):
  1. Um systemd timer na VPS roda todo dia `pg_dumpall`, snapshot do Qdrant e cópia dos volumes do Open WebUI, OpenKnowledge, Uptime Kuma e Dockge para o Backblaze B2 via restic, e `restic snapshots` mostra um snapshot por dia, com a retenção aplicada por `restic forget --prune`.
  2. A senha do restic e as credenciais do B2 existem no repositório só como `encrypted_*.asc`; nenhuma delas aparece em texto claro.
  3. O usuário restaurou ao menos uma vez, a partir do B2 e fora dos dados de produção, o Postgres, o Qdrant e um volume, seguindo o documento em `docs/` (pt-BR) que cobre conta e bucket no B2, chave de acesso, segredos no chezmoi, agendamento e restore.
  4. O usuário tem procedimento documentado para guardar a chave GPG offline e importá-la numa máquina nova antes do primeiro apply, e os comentários de `hermes-sync` e `omniroute-sync` descrevem GPG, não age.
  5. O Uptime Kuma alerta quando o disco ou a memória da VPS passam do limite configurado, e o Hindsight aparece como `healthy` ou `unhealthy` em `docker ps`.
**Plans**: TBD
**Ação manual**: no início da fase o usuário cria a conta e o bucket no Backblaze B2 e gera a chave de acesso.

### Phase 4: Reprodutibilidade e higiene
**Goal**: Reaplicar o repositório amanhã produz o mesmo ambiente de hoje: imagens e ferramentas têm versão fixa, o OmniRoute tem uma única fonte de versão e configuração de produção baseada em uso medido, e o repositório não carrega sobras.
**Depends on**: Phase 1, Phase 2
**Requirements**: REL-02, REL-03, HYG-02, HYG-03, HYG-04, HYG-05, HYG-06, HYG-08
**Success Criteria** (what must be TRUE):
  1. `ollama/ollama`, o Ollama nativo, `caddy`, as ferramentas do mise e o `@inkeep/open-knowledge` do Dockerfile do OpenKnowledge têm versão explícita, sem `latest` nem tag solta, e o CI continua verde.
  2. A versão do OmniRoute é definida só em `home/.chezmoidata/omniroute.yaml` e lida pelo compose; o Dockerfile órfão e as referências a versões antigas não existem mais.
  3. O OmniRoute roda com `APP_LOG_LEVEL=info`, com heap e `deploy.resources.limits` dimensionados a partir do uso medido com `docker stats`, e a medição fica registrada.
  4. O ARENA_ELO_SYNC foi testado na versão atual do OmniRoute e o comentário registra versão e resultado; o bloco `chatgpt-web-codex-browser` foi removido ou tem o motivo da desativação registrado.
  5. Só existe um log config do Synapse (o referenciado em `homeserver.yaml.tmpl`), `hyprland.conf.save` não existe mais, e um zsh novo carrega com `HISTSIZE` e `SAVEHIST` finitos.
**Plans**: TBD
**Notas**: depende da Phase 1 porque fixar a versão do Ollama no macOS precisa da correção de APPLY-05 e porque o CI valida os templates alterados. Roda depois da Phase 2 porque mexe nos mesmos composes do OmniRoute e do Caddy.

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Apply em todo perfil e CI | 3/6 | In Progress | - |
| 2. Rede da VPS com Caddy e Tailscale | 0/TBD | Not started | - |
| 3. Backup, restore e monitoramento | 0/TBD | Not started | - |
| 4. Reprodutibilidade e higiene | 0/TBD | Not started | - |
