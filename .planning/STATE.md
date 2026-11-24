---
gsd_state_version: "1.0"
current_phase: 01
current_phase_name: Apply em todo perfil e CI
status: executing
stopped_at: Phase 1 context gathered
last_updated: "2026-11-24T17:18:08.487Z"
last_activity: 2026-11-24
last_activity_desc: Phase 01 execution started
state_head: 2521f289c91d71334d22090bd501ed40e5a64389
progress:
  total_phases: 4
  completed_phases: 0
  total_plans: 6
  completed_plans: 0
  percent: 0
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-11-24)

**Core value:** `chezmoi apply` funciona em todo perfil suportado, e a VPS não expõe nada administrativo à internet; o que é público passa só pelo Caddy em 80/443 com HTTPS.
**Current focus:** Phase 01 — Apply em todo perfil e CI

## Current Position

Phase: 01 (Apply em todo perfil e CI) — EXECUTING
Plan: 1 of 6
Status: Executing Phase 01
Last activity: 2026-11-24 — Phase 01 execution started

Progress: [░░░░░░░░░░] 0%

## Performance Metrics

**Velocity:**
- Total plans completed: 0
- Average duration: -
- Total execution time: 0.0 hours

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| - | - | - | - |

**Recent Trend:**
- Last 5 plans: -
- Trend: -

*Updated after each plan completion*

## Accumulated Context

### Decisions

Decisions are logged in PROJECT.md Key Decisions table.
Recent decisions affecting current work:

- [Roadmap]: CI (REL-05) entra na Phase 1 junto com as correções de template, para validar as mudanças de compose e Caddyfile das fases seguintes.
- [Roadmap]: Rede (Phase 2) antes do backup (Phase 3): a exposição administrativa é o centro do core value, e o backup do Uptime Kuma depende do caminho de volume corrigido em REL-01.
- [Roadmap]: HYG-01 (domínio/IP em variáveis) fica na Phase 2 com NET-05/NET-06, porque mexem nos mesmos templates de cliente.

### Pending Todos

None yet.

### Blockers/Concerns

- [Phase 1]: o CI precisa rodar no Codeberg (Forgejo Actions ou Woodpecker), não no GitHub; os `encrypted_*.asc` exigem descriptografia desligada ou dados falsos.
- [Phase 2]: para o Caddy servir HTTPS em nomes `*.ts.net`, o container precisa acessar o tailscaled; validar na pesquisa da fase. NET-04 é manual (console da Oracle) e não pode trancar o SSH.
- [Phase 3]: o usuário cria a conta e o bucket no B2 no início da fase; o backup precisa caber nos 10 GB grátis.

## Deferred Items

Items acknowledged and deferred at milestone close, most recent first:

| Category | Item | Status | Deferred At | Milestone |
|----------|------|--------|-------------|-----------|
| *(none)* | | | | |

## Session Continuity

Last session: 2026-11-24T15:10:19.581Z
Stopped at: Phase 1 context gathered
Resume file: .planning/phases/01-apply-em-todo-perfil-e-ci/01-CONTEXT.md
