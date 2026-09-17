# CONCERNS.md — Dívida Técnica, Riscos e Áreas de Atenção

> 🧠 **From Hindsight memory (codebase map)** — Mapeamento do codebase fabiosouzadev/dotfiles em 2026-09-17.

## Riscos Críticos 🔴

1. **Chaves Criptografadas no Git** — Comprometimento da key age expõe todos os secrets (30+ files) — `home/dot_keys/`, `private_dot_*`, `opt/stacks/*/encrypted_dot_env.asc`
2. **OmniRoute Dashboard Exposure** — Acesso direto via IP (157.151.13.223:20128) sem proxy reverso; mitigado via Caddy HTTPS mas ainda acessível
3. **Backup de Chaves SSH** — 3 chaves SSH (personal, VPS, Zup) criptografadas; risco se decryptadas
4. **OmniRoute Docker Build from GitHub** — Base image `diegosouzapw/omniroute` — dependência de repositório externo que pode desaparecer
5. **GPG Recipient Hardcoded** — E691C031009FB1DAA3A25125212D516F623C5747 em `.chezmoi.yaml.tmpl`

## Riscos Médios 🟡

6. **Claude Code Hooks Trust Hash** — sha256 hashes hardcoded em `private_config.toml.tmpl`; risco de injection se atualizados em conjunto
7. **API Keys via Env Vars** — OMNIROUTE_API_KEY, ANTHROPIC_AUTH_TOKEN expostos via env em Docker containers
8. **Multi-Profile Credential Leak** — Zup tokens carregados automaticamente se profile detectado como Zup (`504-zup.zsh.tmpl`)
9. **Docker Compose Secrets** — env vars acessíveis via `docker inspect`
10. **Coding Orchestrator Budget** — $5/noite pode ser esgotado por task mal configurado; execução não supervisionada
11. **Caddy Rule for Omniroute** — `run_once_after_530-install-caddy.sh.tmpl` é VPS-only; Caddy não instalado em desktop
12. **Herdr Config** — `private_dot_config/herdr/config.toml.tmpl` existe mas não há script de install; depende de instalação manual
13. **Camofox Browser Cookies** — LinkedIn cookies criptografados mas processo de rotacionamento não documentado
14. **Instivo VPN** — `encrypted_403-instivo.zsh.asc` — VPN específica do workplace, bloqueia instalações

## Dívida Técnica

15. **Scripts Numerados Manualmente** — Risco de conflito de numeração com múltiplos contributors; falta tool de validation
16. **Template Complexity** — `.chezmoi.yaml.tmpl` ~400+ linhas de Go template; debugging limitado (mitigado por `writeToStdout` debug)
17. **Multi-OS Support Surface** — 5 SOs = O(n) testing por SO adicionado; guards por SO ajudam mas não eliminam
18. **AI Agent Dependency Chain** — OmniRoute single point of failure para toda stack de IA
19. **Neovim Build Maintenance** — Compiled from source em non-managed (`run_once_before_223-compile-nvim.tmpl`) requer manutenção
20. **Tmux Compile** — Compiled from source em non-managed (`run_once_before_224-compile-tmux.tmpl`) — similar maintenance
21. **Zsh Version Fragmentation** — Diferentes versões via zinit vs instalação pacote por SO
22. **Docker Image Drift** — OmniRoute build from GitHub master (`release/v3.8.50` tag) — pin de versão necessário
23. **Qdrant version pin** — v1.19.1 pinned mas pode ter bugs de segurança
24. **Hindsight v0.9.2** — API worker: hindsight-vps (config em Hindsight compose)

## Problemas Conhecidos / Watchlist

25. **WSL GUI Detection** — Melhor esforço; falsos positivos possíveis (`$wslGuiProbe`)
26. **VPS Auto-Detection** — Depende de hostname (`instance-*`); `CHEZMOI_VPS` como override
27. **Chezmoi Version Compatibility** — Recursos avançados (ternary, output, env) requerem versão recente
28. **Paru/AUR dependency** — `run_once_before_199-install-paru.sh.tmpl` assume paru não instalado
29. **Dell WiFi Driver** — RTL8821CE (`run_once_before_103`) específico para Dell 3530; hardware muda = driver falha
30. **Niri Config** — Wayland compositor novo; config baseada em defaults, pode mudar entre versões
31. **Camofox Browser** — Depende de imagem `ghcr.io/jo-inc/camofox-browser:latest` — drift possível
32. **Herder Config** — Instalação não automatizada (sem script)
33. **Hindsight DB** — PostgreSQL 18 + pgvector; schema migration não documentado

## Áreas Frágeis

1. `.chezmoi.yaml.tmpl` — Template central, complexidade alta
2. `home/dot_keys/` — Criptografia de todos os secrets
3. `home/private_dot_ssh/` — Chaves de acesso a servidores (3 perfis)
4. `home/.chezmoiscripts/` — 60+ scripts de install por SO (superfície de falha)
5. Docker stacks — Dependência de Docker daemon, images externas
6. OmniRoute — Single point of failure para IA
7. `docs/` diretório vazio no snapshot atual (não existe)
8. Niri config — Wayland compositor em desenvolvimento

## Mitigações Principais

- **Encrypt at rest**: age/GPG em todos os secrets
- **Profile isolation**: personal/work/vps separados com chaves diferentes
- **CI/CD safety**: script_is_not_ephemeral guards
- **WOTF**: CHEZMOI_SKIP_SHELL_PROBES para controle manual
- **Backup selectivo**: Scripts hermes-sync/omniroute-sync sustentáveis
- **Reversibilidade**: Rollback explícito onde aplicável
- **Feature flags**: Desabilitar features sem remover código
- **Version pinning**: Docker tags, model versions

## Monitoramento Recomendado

| Área | Métrica | Frequência |
|------|---------|------------|
| Secrets | Rotation age/GPG keys | Semestral |
| AI Stack | Budget usage (Orchestrator) | Diária |
| Docker | Container health (Qdrant, Redis, etc.) | Semanal |
| VPS | Disk usage, backups, key expiry | Semanal |
| Hooks | GSD hash validation | Por atualização |
| Deps | Atualização versões (zinit, mise, Docker) | Mensal |
| OmniRoute | Docker build version drift | Mensal |
| Niri | Config compatibility com releases | Mensal |
| Camofox | Cookie rotation, browser updates | Semanal |

## Watchlist Prioridade

1. **Crítico**: age key compromise, OmniRoute exposure
2. **Alto**: Docker image drift, budget control, Herder install
3. **Médio**: Template complexity, multi-OS testing, Hindsight DB
4. **Baixo**: Script numbering, Zsh versions, Dell driver

