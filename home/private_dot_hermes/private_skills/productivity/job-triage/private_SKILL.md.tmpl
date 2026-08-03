---
name: job-triage
description: "Use when user sends job links: scores, auto-applies, Notion."
version: 1.1.0
author: fabiosouzadev
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [jobs, triage, automation, notion, himalaya, linkedin, cv]
    homepage: https://github.com/fabiosouzadev/job-triage
prerequisites:
  env_vars: [NOTION_API_KEY, TELEGRAM_BOT_TOKEN, TELEGRAM_CHAT_ID, GMAIL_APP_PASSWORD]
  commands: [himalaya, curl, python3]
---

# Job Triage System

Sistema completo de **triagem automática de vagas** + **candidatura automatizada** para perfil Tech Lead/Arquiteto Sênior.

## Fluxo Principal

```
Link da vaga → Extração de conteúdo → Scoring (0-100) → Decisão:
  ├─ Score ≥ 70 + Email → Auto-candidatura (Python smtplib + CV)
  ├─ Score ≥ 70 sem Email → Card Notion "Sem contato" / "Sem email"
  ├─ Score 40-69 → Card Notion "Revisar manual" / "Análise necessária"
  └─ Score < 40 → Card Notion "Não aderente" / "Arquivado"
```

## Perfil do Candidato (Hardcoded no Skill)

| Atributo | Valor |
|----------|-------|
| **Nome** | Fábio Souza |
| **Localização** | Londrina/PR |
| **Contrato** | Apenas PJ/Freelance, 100% Remoto (Híbrido só Londrina) |
| **Senioridade** | Tech Lead (1) > Arquiteto (2) > Sênior (3) |
| **Stack Core** | Node.js/NestJS, Java/Spring Boot, Python/Django |
| **Cloud/Infra** | AWS (Lambda, ECS, RDS, API Gateway), GCP, Azure, K8s, CI/CD |
| **Domínio** | Fintech, Gateways de Pagamento, PCI-DSS, Microsserviços |
| **IA** | LLMs, Langfuse, Generative AI, Agentes de código |
| **CV** | `/opt/data/home/documents/curriculo_atualizado_ats.pdf` |
| **LinkedIn** | `https://www.linkedin.com/in/fabiosouzadev/` |
| **Email** | `fabiovanderlei.developer@gmail.com` |

## Scoring Weights (Configurável)

| Critério | Peso | Pontuação Máxima |
|----------|------|------------------|
| Stack Match (Node/Java/Python) | 30% | 30 pts |
| Contrato PJ + 100% Remoto | 25% | 25 pts |
| Senioridade (TL/Arquiteto/Sr) | 20% | 20 pts |
| Fintech/Pagamentos/PCI-DSS | 15% | 15 pts |
| IA/LLMs/Generative AI | 10% | 10 pts |
| **Total** | **100%** | **100 pts** |

**Thresholds:**
- **≥ 70**: Auto-candidatura via Python smtplib (se tem email) ou Notion "Sem contato"
- **40-69**: Notion "Revisar manual" / "Análise necessária"
- **< 40**: Notion "Não aderente" / "Arquivado"

## Notion Database Schema

Database ID: `b45a134b-ad3b-83c5-a4e8-07d467d825ba` (Kanban "Job Process")

| Propriedade | Tipo | Mapeamento |
|-------------|------|------------|
| Name | Title | Título da vaga + empresa |
| Empresa | Rich Text | Nome da empresa/recrutadora |
| Link Vaga | Rich Text | URL original |
| Descrição | Rich Text | Texto extraído da vaga |
| Modalidade | Multi-select | PJ, CLT, Cooperado, Remoto |
| Etapa Atual | Select | Preparar candidatura, Aguardando retorno, Entrevista agendada, Em processo, Finalizado, Cadastro pendente, Aguardando análise, Entrevista realizada, Recebido/em análise, Candidatura enviada, Entrevista com Hunting, Sem email, Análise necessária, Arquivado |
| Status Geral | Select | Não aderente, Pra enviar, Enviado, Em processo, Finalizado, Aguardando retorno, Sem contato, Revisar manual |
| Tags | Multi-select | Stack tags (Node.js, NestJS, Java, Spring Boot, Python, AWS, AI, etc.) |
| Score | Number | 0-100 (calculado) |
| Data Candidatura | Date | Quando aplicou |
| Canal Envio | Multi-select | Email, WhatsApp, LinkedIn |
| CV Enviado | Checkbox | Se currículo foi anexado |
| Anotações Etapa | Rich Text | Logs, motivos, observações |

## Integrações

### Email (Python smtplib — primary)

Script `scripts/send-application.sh` usa **Python smtplib direto** com MIME correto:
- `multipart/mixed` > `multipart/alternative` (text/plain + text/html) + attachment
- From: "Fábio Souza" <fabiovanderlei.developer@gmail.com>
- Anexo: CV PDF obrigatório
- Body: HTML (negrito, links clicáveis) + text/plain fallback

> **Fallback**: `templates/email-application.mml` para Himalaya se smtplib falhar.

### Telegram (Visual Results)
- Bot token + Chat ID do `.env`
- Cards com imagem (print da vaga), score, botões "Candidatar/Ignorar"
- Entrega via `TELEGRAM_BOT_TOKEN` + `TELEGRAM_CHAT_ID`

### Camofox (Opcional - LinkedIn autenticado)
- Para raspar vagas do feed LinkedIn logado
- URL: `http://camofox:9377` (Docker network)
- Cookie file: `/opt/data/camofox-data/cookies/linkedin.txt`

## Estrutura do Skill

```
skills/productivity/job-triage/
├── SKILL.md
├── references/
│   ├── scoring-rules.md       # Regras detalhadas de pontuação
│   ├── notion-schema.md       # Schema completo da database
│   ├── cv-profile.md          # Perfil extraído do CV
│   └── linkedin-scraping-lessons.md  # Lições: scraping, MIME, score thresholds
├── scripts/
│   ├── triage.py              # Script principal: recebe URL → score → ação
│   ├── extract-content.py     # Extrai texto de URL (web_extract + Camofox fallback)
│   ├── score-vaga.py          # LLM scoring com pesos configuráveis
│   ├── send-application.sh    # Envia email via Python smtplib (CV + LinkedIn)
│   ├── create-notion-card.sh  # Cria card no Notion Kanban
│   └── telegram-card.py       # Gera card visual Telegram
├── templates/
│   ├── email-application.mml  # Template MML para Himalaya (fallback)
│   └── notion-card.json       # Payload base para criar página
└── schemas/
    └── triage-config.json     # Schema validação config
```

## Uso

```bash
# Triagem de uma vaga (link do LinkedIn, site empresa, etc.)
/opt/data/skills/productivity/job-triage/scripts/triage.py "https://linkedin.com/jobs/view/12345"

# Ou via skill carregada
skill_load("productivity/job-triage")
./scripts/triage.py "https://..."
```

## Configuração (.env necessário)

```bash
NOTION_API_KEY=ntn_xxx...
TELEGRAM_BOT_TOKEN=xxx:xxx
TELEGRAM_CHAT_ID=123456789
GMAIL_APP_PASSWORD=vrhm aagq frws zcrn  # App Password Gmail (16 chars)
# Opcional para Camofox:
CAMOFOX_URL=http://camofox:9377
CAMOFOX_API_KEY=xxx
```

## Pitfalls & Lessons Learned

1. **Notion token truncado no .env** — O `.env` tinha `ntn_43...HfuU` (literal). Sempre validar token completo antes de chamar API.
2. **Database ID vs Data Source ID** — Notion API v2025-09-03 usa `data_source_id` para queries, `database_id` para criar páginas. Ambos disponíveis no objeto da database.
3. **Himalaya anexo + body** — `himalaya message write --attach` funciona, mas MML template é mais confiável para emails ricos. Ver `references/message-composition.md` no skill himalaya-email.
4. **CV em PDF** — Local fixo: `/opt/data/home/documents/curriculo_atualizado_ats.pdf`. Validar existência antes de enviar.
5. **LinkedIn scraping** — Público funciona com `web_extract`; autenticado precisa Camofox + cookies. Cookies em `/opt/data/camofox-data/cookies/linkedin.txt` (read-only mount).
6. **Arquivamento em massa** — `PATCH /pages/{id} {"archived": true}` limpa database. Rate limit ~3 req/s.
7. **Email MIME (Critical Fix)** — Himalaya MML piped com `--attach` criou multipart malformado: HTML fonte visível, variáveis não expandidas (heredoc quoted), From sem display name. **Fix**: Python smtplib direto com `multipart/mixed` > `multipart/alternative` + attachment. Ver `references/linkedin-scraping-lessons.md`.
8. **Bash heredoc expansion** — Use **unquoted** delimiters (`<<EOF`) para expandir variáveis `${VAR}`; quoted (`<<'EOF'`) = literal. Ver `references/linkedin-scraping-lessons.md`.
9. **Thresholds válidos:** ≥70 auto-apply (Python smtplib), 40-69 revisar manual, <40 arquivar.
11. **Notion cards — Títulos e Status automáticos** — Script `create-notion-card.sh` agora:
    - Título: `"Empresa - Cargo (Score)"` (ex: `"GrooveTech - Engenheiro de Software Sênior (40)"`)
    - Empresa extraída via regex do conteúdo (`Empresa:`, `Company:`, `Post:`, `@usuario`, ou primeira palavra capitalizada)
    - Status/Etapa calculados automaticamente pelo score + presença de email
    - 22 cards existentes atualizados em lote via script Python (`update_notion_cards.py`)

12. **Notion API v2025-09-03: Database ID vs Data Source ID** — Para queries usar `data_source_id` (`b45a134b-ad3b-83c5-a4e8-07d467d825ba`); para criar páginas usar `database_id` (`cb9a134b-ad3b-8306-8d52-81ed264d3f5b`). Ambos no mesmo objeto database.

## Próximos Passos (Roadmap)

- [ ] Implementar `scripts/triage.py` completo (orquestra extração → scoring → ação)
- [ ] Adicionar suporte a múltiplos CVs (perfil backend, fullstack, architect)
- [ ] Cron job diário: varrer feed LinkedIn via Camofox → triagem automática
- [ ] Dashboard Telegram: `/vagas` lista cards Notion com status
- [ ] Integração com `blogwatcher` para newsletters de vagas (RemoteOK, etc.)
- [ ] Feedback loop: marcar "Entrevista agendada" → ajustar pesos do scoring