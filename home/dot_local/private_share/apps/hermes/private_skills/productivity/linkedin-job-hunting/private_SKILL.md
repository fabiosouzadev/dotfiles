---
name: linkedin-job-hunting
description: "Hunt LinkedIn jobs: scrape, extract, send via Himalaya."
version: "1.0.0"
tags: ["linkedin", "job-search", "career", "automation", "himalaya", "email"]
---

# LinkedIn Job Hunting Workflow

## Purpose
Automate the full cycle: monitor LinkedIn feed for target roles -> extract structured job data -> generate tailored applications -> send via Himalaya email with attachments.

## Scope
This skill integrates linkedin-automation (feed scraping) with himalaya-email (sending applications) into a cohesive workflow. It covers both:
- **Feed monitoring** (`/feed/`) — scroll-infinite, monitor posts for target roles
- **Job search pagination** (`/jobs/search-results/?...`) — page-based pagination with "Próxima" button

It captures user preferences for:
- 100% remote, PJ/CLT roles
- Target stacks: IA Agêntica/MCP/LLMs, PHP/Laravel, Node/Nest.js, Arquitetura
- Senior Staff / Tech Lead / Arquiteto level
- Short sprints, checklists, gamification

## Workflow

### 1. Feed Collection & Filtering
```bash
# Use linkedin-automation patterns
browser_navigate("https://www.linkedin.com/feed/")
# Scroll, snapshot, extract posts matching keywords
# Keywords: "IA Agêntica", "MCP", "LLM", "PHP", "Laravel", "Node", "Nest", "Arquiteto", "Senior Staff", "Tech Lead", "Remoto", "PJ"
```

### 2. Job Extraction & Structuring
Extract to JSON with schema:
```json
{
  "id": "unique_id",
  "author": "Recruiter Name",
  "headline": "Role at Company",
  "text": "Full description",
  "time": "2h / 3d",
  "contact_email": "email@domain.com",
  "contact_whatsapp": "(XX) XXXXX-XXXX",
  "apply_link": "https://...",
  "type": "VAGA|PROMOCAO|POST",
  "tags": ["Java", "Remote", "Senior", "AWS"],
  "priority": "ALTA|MEDIA|BAIXA",
  "notes": "Why this matches"
}
```

### 3. Application Material Generation
Templates by role type:
- templates/senior-staff-architect.md — highlights architecture, scaling, mentoring
- templates/ia-agentica.md — highlights MCP, Hermes, LLMs in SDLC
- templates/php-laravel.md — highlights PHP/Laravel + modern practices
- templates/node-nest-gcp.md — highlights Nest.js, GCP, K8s

Merge strategy: Base template + role-specific highlights + job-specific keywords.

### 4. Email Sending via Himalaya

#### Prerequisites
- himalaya installed (curl -sSL https://raw.githubusercontent.com/pimalaya/himalaya/master/install.sh | PREFIX=~/.local sh)
- config.toml with required fields (see below)
- Gmail App Password in .env

#### Required config.toml fields
```toml
[accounts.gmail]
default = true
email = "seu-email@gmail.com"        # OBRIGATÓRIO - fixes "No From header" error
display-name = "Seu Nome"            # OBRIGATÓRIO

imap.server = "imaps://imap.gmail.com:993"
imap.sasl.plain.username = "seu-email@gmail.com"
imap.sasl.plain.password.cmd = "grep '^GMAIL_APP_PASSWORD=' /opt/data/.env | cut -d'=' -f2-"

smtp.server = "smtps://smtp.gmail.com:465"
smtp.sasl.plain.username = "seu-email@gmail.com"
smtp.sasl.plain.password.cmd = "grep '^GMAIL_APP_PASSWORD=' /opt/data/.env | cut -d'=' -f2-"

mailbox.alias.inbox = "INBOX"
mailbox.alias.sent = "[Gmail]/Sent Mail"
mailbox.alias.drafts = "[Gmail]/Drafts"
mailbox.alias.trash = "[Gmail]/Trash"
mailbox.alias.archive = "[Gmail]/All Mail"
```

#### Send command (himalaya v0.6+)
```bash
himalaya --account gmail message compose \
    --from "seu-email@gmail.com" \
    --to "recruiter@company.com" \
    --subject "Candidatura: Role - Seu Nome" \
    --body "$(cat cover_letter.txt)" \
    --attach "/path/to/cv.pdf" \
    --send
```

Key lesson: Use --attach flag on message compose (native, simple) — NOT template send with manual MML (complex, error-prone).

### 5. Tracking & Follow-up
- Log applications to CSV/Notion: date, company, role, contact, status
- Set reminders for follow-up (7 days)
- Track response rates by template/stack

## User Preferences (Embedded)

| Preference | Value |
|------------|-------|
| Language | PT-BR with informal nicknames (Amigo, Amigão, Camarada, Meu Nobre) |
| Response style | Direct, tool-backed, checklist-driven |
| Sprint style | Short, concrete deliverables, "Pode seguir" = proceed |
| Target roles | Senior Staff / Tech Lead / Arquiteto |
| Target stacks | IA Agêntica, MCP, LLMs no SDLC, PHP/Laravel, Node/Nest.js, Go, Arquitetura |
| Work model | 100% Remoto, PJ preferred, CLT acceptable if high value |
| Application priority | IA Agêntica > Node/Arquitetura > PHP/Laravel > Java Moderno > Java Legado |

## References
- references/send-email-lessons.md — Himalaya email troubleshooting
- references/job-extraction-schema.json — JSON schema for job data
- references/linkedin-job-search-extraction.md — Page structure and extraction patterns
- references/parse-recipes.md — Parse recipes for snapshot data (Python, heuristics, examples)

## Scripts
- scripts/apply-to-job.sh — end-to-end: generate cover letter -> send email -> log application
- scripts/monitor-feed.sh — daily feed scrape + filter -> notify new matches

## Maintenance
- Test Himalaya auth monthly: `himalaya --account gmail envelope list --page-size 1`
- Update LinkedIn selectors when UI changes
- Rotate Gmail App Passwords every 90 days

---

## LinkedIn Job Search: Pagination & Extraction Patterns

### Busca com paginação (não scroll infinito)

A página de resultados da busca (`/jobs/search-results/?...`) **não é scroll infinito** como o feed. A paginação usa botões num painel inferior:
- Botões: "Página 1", "Página 2", "Página 3" ... e "Próxima"
- Ref IDs variam por sessão (ex: `e73`, `e74`, `e75`, `e76`)

**Estratégia de paginação:**
1. Extrair vagas da página atual via snapshot
2. Clicar em "Próxima" ou na página seguinte
3. Esperar carregar (snapshot confirmando mudança de conteúdo)
4. Repetir até atingir a contagem desejada ou esgotar páginas
5. Cada clique de paginação pode causar falha 410/404 no Camofox — se falhar, reconectar via `browser_navigate` com a mesma URL e retranscrever

**Limite prático:** cada página carrega ~23-25 vagas. Para 100 vagas, estima-se 4-5 páginas.

### Extração de dados: snapshot vs console JS

**FALHA CONHECIDA:** Executar `browser_console` com código JS complexo (`evaluate`) frequentemente causa:
- `410 Client Error: Gone` — sessão tab fechada no Camofox
- `NameResolutionError` / `Max retries exceeded` — Camofox caiu entre commands

**Abordagem confiável:**
1. `browser_snapshot(full=true)` → captura estado atual da página
2. Ler o snapshot via `read_file` (caminho retornado no footer do snapshot, ex: `/opt/data/cache/web/browser-snapshot-*.txt`)
3. Parse dos dados a partir da estrutura HTML/markdown do snapshot

**Por que snapshot funciona melhor:**
- O snapshot é uma captura estática do DOM no momento da chamada — não depende de manter sessão ativa
- O console JS executa em tempo real e a sessão pode expirar durante execução longa ou devido a instabilidade do Camofox
- O snapshot contém os dados completos dos parágrafos que compõem as cards de vaga

**Importante:** Após cada ação crítica (click, paginação), verificar se a página carregou via snapshot. Se o snapshot vier vazio ou com erro, reconectar via `browser_navigate` com a URL atual.

### Parse do snapshot de resultados de busca

O snapshot de uma página de resultados contém as cards de vaga em estrutura `main:` → `button` → `paragraph` elements.

**Estrutura típica de uma card:**
```
- button "Título da Vaga (Vaga verificada) Empresa Localização ... Candidate-se" [eX]:
  - paragraph: Título da Vaga
  - paragraph: Empresa
  - paragraph: Localização (ex: "São Paulo, SP (Híbrido)")
  - paragraph: Indicadores ("Anunciada há X", "Promovida", "Visto", "X conexões trabalham aqui")
```

**Campos para extrair (para Job Process):**
- `title`: primeira linha do texto da card (ex: "Tech Lead - Java (Conta Digital)")
- `company`: segunda linha (ex: "Porto", "B3", "Nubank")
- `location`: terceira linha com modality (ex: "São Paulo, SP (Híbrido)")
- `modality`: parse de "Remoto", "Híbrido", "Presencial" da string de localização
- `time_posted`: extrair padrão "há X" (ex: "há 3 semanas", "há 4 dias")
- `is_promoted`: badge "Promovida" presente
- `is_verified`: badge "Vaga verificada" presente
- `is_selected`: "Selecionada" ou "Você seria um dos melhores candidatos" presente
- `connection_count`: parse "X conexões" ou "X ex-alunos"
- `has_apply_link`: se "Candidate-se" está presente

**Edge cases:**
- Cards promovidas aparecem no topo e têm badge "Promovida"
- Cards "Selecionada"/"Você seria um dos melhores candidatos" são recomendações personalizadas
- Algumas cards podem ter company vazia (parse defensivo)
- Location pode variar: "São Paulo, SP (Híbrido)", "São Paulo e Região (Presencial)", "Osasco, SP", "Barueri, SP", "Remoto", etc.
- O link curto `lnkd.in/p/...` pode redirecionar para post público que requer login para visualização completa — se pedir login, registrar e avisar, não tentar contornar

### Scripts de parse (execute_code)

Para extração programática após ter o snapshot, usar `execute_code` com leitura do arquivo snapshot e parse via regex/linhas:

```python
from hermes_tools import read_file

snapshot = read_file(path="/opt/data/cache/web/browser-snapshot-XXXX.txt")
content = snapshot["content"]

# Parse: cada vaga é um button com multiple paragraphs
# Extrair blocos que contêm "Fechar vaga de" no aria-label ou no texto
import re

vagas = []
# Coordenar por posições dos parágrafos no snapshot
lines = content.split("\n")
i = 0
while i < len(lines):
    line = lines[i].strip()
    if "Fechar vaga de" in line or "Selecionada," in line:
        # Esta é uma card — extrair titulo, empresa, local das próximas linhas
        ...
    i += 1
```

Detalhes de implementação no file de referência.

---

## Remote Browser Troubleshooting (Camofox)

### Sinais de Camofox down

Antes de qualquer operação do browser, verificar:
```bash
curl -s -o /dev/null -w '%{http_code}' http://camofox:9377/
```
- `200` → operacional
- `000` ou `could not resolve host` → offline
- Timeout → instável, testar novamente

### Sequência de recuperação quando cai

1. **Verificar Docker daemon:** `docker ps` — se falhar com "Cannot connect to the Docker daemon", o daemon caiu
2. **Subir Docker daemon:** Executar `dockerd` em background (via terminal com `background=true` + `notify_on_complete`)
3. **Aguardar socket:** Verificar `/var/run/docker.sock` existe
4. **Verificar containers:** `docker ps` para ver se Camofox subiu sozinho ou se precisa iniciar manualmente
5. **Reconectar browser:** `browser_navigate` com a URL alvo para recriar sessão

**Observação:** neste ambiente o Docker daemon pode não estar disponível (dockerd não encontrado, sem systemctl/service). Se assim for, a recuperação depende de ação externa (restart do container em nível de infraestrutura).

### Instabilidade inter-operação

O Camofox pode responder `200` no curl e ainda assim falhar em operações subsequentes (click, scroll, console evaluate) com erros `410 Gone` ou `NameResolutionError`. Isso indica que a sessão/tab específica travou.

**Mitigação:**
- Após cada click/scroll crítico, verificar se a página carregou via snapshot
- Se snapshot vier vazio ou com erro, reconectar via `browser_navigate` com a URL atual
- Para extração de dados, preferir `browser_snapshot` sobre `browser_console` — o snapshot é mais resistente a instabilidade de sessão
- Não fazer retry infinito de operações que falharem — após 2-3 tentativas sem sucesso, pausar e informar o usuário

### Login do LinkedIn

Após reconnect do browser, o LinkedIn pode pedir login ("Olá novamente", "Entre para visualizar mais conteúdos"). Se a sessão estiver válida, clicar em "Entrar como Fabio Souza" ou usar botão de login. Se pedir credenciais novamente, avisar o usuário — não tentar injetar credenciais manualmente.

---

## Feed-Based Job Monitoring (extensão do skill)

### Monitoramento contínuo do feed

O feed do LinkedIn (`/feed/`) usa scroll infinito e é mais estável que a busca de vagas. Para monitoramento contínuo:

1. Navegar para o feed
2. Fazer scroll para carregar mais posts
3. Extrair posts que combinam com keywords alvo
4. Filtrar por stack/role/remote

**Keywords alvo do usuário:**
- IA Agêntica, MCP, LLMs no SDLC
- PHP, Laravel
- Node, Nest.js
- Arquitetura de Software
- Senior Staff, Tech Lead, Arquiteto
- Remoto, PJ

### Destaques do feed vs busca

- **Feed**: posts orgânicos de recrutadores/empresas, scroll infinito, mais volátil (posts aparecem/desaparecem)
- **Busca de vagas**: resultados estruturados, paginação, mais estável, com badges (Visto, Promovida, Vaga verificada)
- **Remote browser availability (Camofox)**: LinkedIn automation in this environment depends on the Camofox remote browser being up at `http://camofox:9377/`. Before driving LinkedIn via `browser_navigate`/clicks/scrolls, verify that `curl -s -o /dev/null -w '%{http_code}' http://camofox:9377/` returns a usable code (200-range). If it fails, the LinkedIn workflow will stall at session/browser level and should not be retried blindly. Typical startup hints seen in this environment: `npm start` inside the `camofox-browser` directory, or the container form `docker run -p 9377:9377 -e CAMOFOX_PORT=9377 jo-inc/camofox-browser`. When the remote browser is down, prefer to pause LinkedIn browser work and resume after it is reachable rather than looping failed clicks.