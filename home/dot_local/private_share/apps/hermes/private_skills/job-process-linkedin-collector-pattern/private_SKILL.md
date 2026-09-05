---
name: job-process-linkedin-collector-pattern
description: Freelance-First queries for LinkedIn cron. Never generic.
version: 1.0.0
author: Hermes Agent
platforms: [linux]
metadata:
  hermes:
    tags: [Jobs, LinkedIn, Fit, Notion, Cron, Freelance-First]
---

# LinkedIn Jobs Collector — Multi-Query Pattern (OBRIGATÓRIO)

## When to use
- Cron `fc6cc1763c57` (LinkedIn Collector) OR manual LinkedIn Jobs scrape
- Goal: coletar vagas que vão render no Fit Engine, não poluir o Notion

## Regra de ouro (4 execuções comprovadas)
**NUNCA** usar busca genérica sem filtro (ex: "Tech Lead of Software", "Developer", "Senior Engineer"). 4 cron runs (2026-08-31, 09-01, 09-03 manhã, 09-03 19:00 UTC) confirmaram **0% de aproveitamento** — retornam 100% vagas FIXED-CLT-empresas-US (Capital One, JPMorgan, SpaceX, Boeing, Booz Allen) sem descrição, todas rejeitadas pelo Fit Engine.

**SEMPRE** usar composição de queries com keywords Freelance-First + filtro de concorrência:

```bash
# 3+ queries paralelas (Multi-Query Pattern)
Q1: "Contractor Java Developer"  + f_EA=true + f_TPR=r604800
Q2: "Node.js Contractor"         + f_EA=true + f_TPR=r604800
Q3: "PHP Laravel Contractor"     + f_EA=true + f_TPR=r604800
Q4: "Freelance Developer Remote" + f_EA=true + f_TPR=r604800
```

- `f_EA=true` = menos de 10 candidaturas (filtra concorrência alta)
- `f_TPR=r604800` = publicadas na última semana (PastWeek)
- Combinar resultados, dedup por URL, processar via Fit Engine

## Heurística de fallback (descrição vazia)
Quando `job.description == ""` (login wall do LinkedIn bloqueia scrape completo):
- **NÃO** aplicar regras de rejeição automática por modality/contrato (exigem descrição)
- Calcular score parcial com: stack matches no título, seniority hint, IA focus, remote hint
- Definir prioridade como **`Avaliação manual - User Review`** com score parcial
- Upsertar no Notion para o usuário analisar manualmente
- Quando o usuário aprova manualmente no Notion, cron puxa descrição completa e recalcula fit definitivo

## Blockers do ambiente cron (2026-09-03)
- Container s6-overlay **NÃO tem `dockerd` no PATH**
- `/var/run/docker.sock` ausente
- `service`/`systemctl` não existem
- `dockerd &>/dev/null &` **NÃO recupera** o daemon — comando não executa
- Camofox (camofox:9377) responde HTTP 200 mas sessão LinkedIn indisponível sem docker rodando no host
- **Fallback quando docker down**: NÃO tentar nova coleta. Inspecionar cache existente, NÃO rodar pipeline em lixo, registrar blocker no log, reportar ao Telegram.

## Pipeline de pós-coleta
1. Salvar vagas em `/opt/data/cache/job-process/linkedin_jobs_100.json` (formato dict com chave `jobs`)
2. Se houver `linkedin_jobs_NN.json` órfão (NN != 100): tentar merge por URL em `_100.json` (dedup) — senão fica órfão (pitfall seção 12 do skill `job-process`)
3. Rodar `notion_upsert_pipeline.py` (lê APENAS `_100.json`)
4. Para cada vaga: aplicar regras Fit Engine (PJ Senior só rejeita se NÃO tem contractor/contract/freelance/B2B/1099 na descrição)

## Verification
- `tail -c 2000 /opt/data/home/.local/share/jobprocess/jobprocess.log`
- Notion DS `b45a134b-ad3b-83c5-a4e8-07d467d825ba` — query por `Criado:` no log
- Se vaga está em `_101.json` ou `_102.json` mas NÃO em `_100.json`: órfã, fazer merge

## Related
- Skill `job-process` seção 5b (Multi-Query Pattern) + 5c (heurística fallback)
- Skill `linkedin-automation` (browser_navigate + scroll + snapshot workflow)
- Skill `notion-mcp` (post_page gotchas)