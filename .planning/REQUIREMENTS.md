# Requirements: Dotfiles Hardening (fabiosouzadev/dotfiles)

**Defined:** 2026-11-24
**Core Value:** `chezmoi apply` funciona em todo perfil suportado, e a VPS não expõe nada administrativo à internet; o que é público passa só pelo Caddy em 80/443 com HTTPS.

Fonte: `docs/pontos-de-atencao.md` (ID original entre parênteses).

## v1 Requirements

### Rede e exposição da VPS (NET)

- [ ] **NET-01**: Usuário tem as regras atuais da security list da Oracle levantadas e documentadas em `docs/` (A1)
- [ ] **NET-02**: Nenhum container publica porta no host além de 80/443 do Caddy; o resto publica em `127.0.0.1` ou no IP do Tailscale, ou fica só na rede Docker (A1)
- [ ] **NET-03**: Usuário acessa os painéis administrativos (Dockge, dashboards do Hermes/Hindsight/OmniRoute, Qdrant, Uptime Kuma, noVNC/VNC do Camofox) só pela tailnet, com HTTPS servido pelo Caddy (A1, A3)
- [ ] **NET-04**: Security list da Oracle fica reduzida a 80/443 mais o necessário para SSH/Tailscale, sem perder o acesso à VPS (A1)
- [ ] **NET-05**: Claude Code, Codex, opencode e openclaude falam com o OmniRoute por HTTPS ou Tailscale, nunca por `http://` no IP público (A2)
- [ ] **NET-06**: Cliente do Hindsight (`dot_hindsight/coding-agent.json.tmpl`) aponta para uma rota que existe e é criptografada (M9)

### Segurança de serviços (SEC)

- [ ] **SEC-01**: Uptime Kuma não monta `docker.sock` com escrita (proxy somente leitura ou sem socket), e o Dockge com socket só é alcançável via Tailscale (A3)
- [ ] **SEC-02**: OmniRoute roda com `ALLOW_API_KEY_REVEAL=false` (M1)
- [ ] **SEC-03**: Usuário tem procedimento documentado para backup offline e recuperação da chave GPG, incluindo a importação antes do primeiro apply (M10)

### `chezmoi apply` e scripts (APPLY)

- [ ] **APPLY-01**: `chezmoi apply` renderiza o instalador do Ollama em modo root no Linux pessoal (`.features.ollama.environments`) (A4)
- [ ] **APPLY-02**: `chezmoi apply` renderiza `termux.zsh.tmpl` no Termux sem chave inexistente (A5)
- [ ] **APPLY-03**: Composio e ferramentas com flag `multiplexer` são instalados quando a flag está ligada (`:=` → `=` em `590-install-ai-tools`) (M2)
- [ ] **APPLY-04**: Reinstalar o Ollama em modo user preserva `~/.ollama/models` e a chave de identidade (M4)
- [ ] **APPLY-05**: Fixar a versão do Ollama no macOS não quebra o template (`.features.ollama.version`) (B7)
- [ ] **APPLY-06**: `script_is_instivo` passa quando o contexto Instivo está ativo, e `script_arch_based_only` tem comportamento intencional e documentado para Arch puro

### Backup e recuperação (BKP)

- [ ] **BKP-01**: VPS faz backup diário (systemd timer) de Postgres (`pg_dumpall`), Qdrant (snapshot) e volumes Docker relevantes (Open WebUI, OpenKnowledge, Uptime Kuma, Dockge) para o Backblaze B2 via restic (A6, B10)
- [ ] **BKP-02**: Backups têm retenção definida (`restic forget --prune`) e credenciais B2 e senha do restic guardadas como `encrypted_*.asc` (A6)
- [ ] **BKP-03**: Restore foi testado ao menos uma vez e o procedimento está documentado (A6)
- [ ] **BKP-04**: Usuário tem documento em `docs/` com a configuração do backup: criar conta e bucket no B2, chave de acesso, segredos no chezmoi, agendamento e restore (A6, pedido do usuário)

### Confiabilidade e reprodutibilidade (REL)

- [ ] **REL-01**: Caddy e Uptime Kuma sobem juntos sem conflito na porta 3001, e o volume do Uptime Kuma usa `{{ .chezmoi.homeDir }}` (M3)
- [ ] **REL-02**: Imagens e ferramentas com versão fixa: `ollama/ollama`, Ollama nativo, `caddy`, ferramentas do mise e `@inkeep/open-knowledge` no Dockerfile (M5)
- [ ] **REL-03**: OmniRoute tem uma única fonte de versão lida pelo compose; Dockerfile órfão e referências antigas removidos (M6)
- [ ] **REL-04**: Instaladores de Ollama, lazygit, atuin e glab descobrem a versão sem `grep`/`sed` frágil, falham com mensagem clara, e o glab funciona no macOS (M7)
- [ ] **REL-05**: CI renderiza os templates por perfil (Linux, VPS, macOS, Termux) com dados simulados, roda `shellcheck` nos scripts renderizados e `docker compose config` nas stacks (M8)
- [ ] **REL-06**: Uptime Kuma tem monitores de disco e memória, e o healthcheck do Hindsight está ativo (B10)

### Higiene (HYG)

- [ ] **HYG-01**: Domínio e IP da VPS vêm de variáveis de dados (`.chezmoidata/vps/`), sem hardcode nos templates (B1)
- [ ] **HYG-02**: ARENA_ELO_SYNC testado na versão atual do OmniRoute, com comentário registrando versão e resultado (B2)
- [ ] **HYG-03**: Bloco `chatgpt-web-codex-browser` removido ou com motivo da desativação registrado (B3)
- [ ] **HYG-04**: OmniRoute roda com `APP_LOG_LEVEL=info` (B4)
- [ ] **HYG-05**: Heap e limite de memória do container do OmniRoute dimensionados pelo uso medido (B5)
- [ ] **HYG-06**: `HISTSIZE`/`SAVEHIST` com valor finito (B6)
- [ ] **HYG-07**: Comentários de `hermes-sync` e `omniroute-sync` descrevem GPG, não age (B8)
- [ ] **HYG-08**: Log config duplicado do Synapse e `hyprland.conf.save` removidos (B9)

## v2 Requirements

(Nenhum — o usuário escolheu os 26 itens para a v1.)

## Out of Scope

| Feature | Reason |
|---------|--------|
| Kubernetes, réplicas de Postgres, Redis Cluster, vários OmniRoute com balanceamento, Envoy, Prometheus | VPS pessoal de um nó; o ponto único de falha se resolve com backup e restore testado |
| Trocar GPG por age | Não resolve o risco da chave única |
| Novas ferramentas, stacks ou plataformas | Este ciclo só endurece o que já existe |
| Backup no Object Storage da Oracle | Mesma conta da VPS; se a conta cair, perde os dois |
| Gerenciar a security list da Oracle por código (Terraform/OCI CLI) | Mudança é rara e manual; documentar basta neste ciclo |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|

**Coverage:**
- v1 requirements: 33 total
- Mapped to phases: 0
- Unmapped: 33 ⚠️

---
*Requirements defined: 2026-11-24*
*Last updated: 2026-11-24 after initial definition*
