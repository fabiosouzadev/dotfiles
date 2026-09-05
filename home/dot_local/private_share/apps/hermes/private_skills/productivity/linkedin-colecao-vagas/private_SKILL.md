---
name: linkedin-colecao-vagas
description: "Workflow coleta LinkedIn: scroll, snapshot, parser v5."
version: 1.0.0
author: auto-generated
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [LinkedIn, Jobs, Coleta, Parser, Fit Engine, Browser, Cron]
    homepage: https://github.com/fabiosouzadev/job-process
prerequisites:
  commands: [python3]
  browser: [camofox]
---

# LinkedIn Coleta de Vagas — Scroll + Snapshot + Parser

Skill complementar ao `job-process` para coleta sistemática de vagas do LinkedIn via browser (Camofox). Documenta o workflow completo que funcionou: **navegar → scroll → snapshot → parser v5 → Fit Engine → JSON**.

---

## 1. Quando usar

- Usuário pediu coleta de N vagas (ex: 100 vagas) do LinkedIn
- Precisa extrair títulos, empresas, URLs, localizações do feed de busca do LinkedIn
- Quer processar com Fit Engine e salvar em JSON para posterior análise/Notion

**Não usar** quando:
- Apenas precisa abrir detalhe de uma vaga específica (use `browser_navigate` direto para a URL da vaga)
- Vaga já está no Notion e precisa apenas de atualização de status (use APIs do Notion)

---

## 2. Workflow Completo

### Passo 1: Navegar para busca do LinkedIn

```python
browser_navigate(url="https://www.linkedin.com/jobs/search/?keywords=contractor%20developer%20remote&origin=JOB_SEARCH_HOME&searchId=a1b2c3d4e5f6&start=0")
```

**Dica:** usar queries com palavras-chave de modality (contractor, freelance, PJ, remote) para aumentar taxa de aproveitamento — ver Lições no `job-process` seção 5b.

### Passo 2: Scroll para carregar mais vagas

Cada scroll carrega uma nova página de resultados (20-25 vagas). Para atingir 100 vagas, fazer scroll repetidamente:

```python
for _ in range(4):  # 5 pages × 20 vagas = 100 vagas
    browser_scroll(direction="down")
    # Aguardar carregamento (o snapshot anterior confirma que novos cards apareceram)
```

**Observação prática (2026-09-01):** cada `browser_scroll` + `browser_snapshot` pode demorar alguns segundos. Se o snapshot não mostrar novos cards após scroll, aguardar e tentar novamente. LinkedIn pode limitar carregamento após muitos scrolls.

### Passo 3: Capturar snapshot completo

```python
browser_snapshot(full=True)
```

O snapshot é salvo automaticamente em `/opt/data/cache/web/browser-snapshot-<timestamp>.txt`. O parser lê o snapshot mais recente automaticamente.

### Passo 4: Executar parser v5

```bash
cd /opt/data/skills/productivity/job-process/scripts
python3 linkedin_parser_v5.py
```

O parser:
1. Encontra o snapshot mais recente em `/opt/data/cache/web/*.txt`
2. Extrai vagas via regex direto no texto (`- /url: https://www.linkedin.com/jobs/view/...`)
3. Para cada vaga: título, empresa, URL, localização
4. Processa com Fit Engine (chama `fit_engine.calculate_fit`)
5. Salva JSON em `/opt/data/cache/job-process/linkedin_jobs_extracted.json`

### Passo 5: Verificar resultado

O parser imprime resumo no terminal:
- Total coletadas
- Aprovadas pelo Fit (não rejeitadas)
- Fit ≥ 60, Fit ≥ 80
- Remotas, com empresa
- Top 15 por Fit Score

---

## 3. Parser v5 — Como funciona

O parser `scripts/linkedin_parser_v5.py` usa **regex direto no texto** em vez de regex multilinha complexa (que falhou nos parsers v2/v3/v4). O padrão de extração:

```python
# Encontrar todas as URLs de vagas no snapshot
job_url_pattern = r'- /url:\s*(https?://[^\s]+jobs/view/[^\s]+)'

# Para cada URL encontrada, extrair contexto (-XX chars antes, +500 chars depois)
# Título: aparece no link ANTES da URL: - link "Título" [ref]:
# Empresa: heading level=4 depois da URL: - heading "Empresa" [level=4]:
# Localização: - text: depois da URL
```

**Gotcha:** O título da vaga está no `- link "Título" [ref]:` ANTES da linha `- /url: ...`. O contexto antes da URL (200 chars) precisa capturar isso.

**Gotcha:** A empresa está no heading level=4 DEPOIS da URL. Usar contexto de +500 chars depois da URL.

**Pitfall (v4 falhou):** regex multilinha complexa que tentava capturar tudo de uma vez (`listitem > link + /url + heading level=3 + heading level=4`) falhou porque a estrutura do snapshot é mais irregular do que previsto. Solução: regex simples para URLs + contexto ao redor.

---

## 4. Login Wall durante coleta

Durante scroll pela página de busca, o LinkedIn pode mostrar modal de login ("Entre para ver mais vagas" ou "Entre para ver quem você já conhece na empresa X").

**Fluxo:**
1. Capturar snapshot → identificar modal (dialog "Entre para ver...")
2. Clicar no botão "Fechar" (`browser_click(ref="e1")` — botão "Fechar" do modal)
3. Continuar scroll

Se o modal aparecer novamente após scroll, repita o fechamento. Não precisa fazer login — fechar o modal permite continuar navegando no feed público.

---

## 5. Pitfall: Cron Job com Drift de Configuração

### Sintoma
Cron job falha com erro:
```
RuntimeError: Skipped to prevent unintended spend: global inference config drifted 
since this job was created (provider 'custom' -> 'nous'; model 'omniroute/agents' -> 
'upstage/solar-pro4:free'), and this job is unpinned. No inference call was made.
```

### Causa
O cron job foi criado com provider/model que já mudaram no sistema. O sistema bloqueia execução para evitar gasto não intencional.

### Solução

**Opção A — Recriar o cron job (recomendado):**
```bash
cronjob action=remove job_id=<JOB_ID>
cronjob action=create \
  --name "LinkedIn Jobs Collector" \
  --prompt "<prompt completo do workflow>" \
  --schedule "0 16 * * *" \
  --deliver "telegram:644615401:14880" \
  --skills "job-process"
```

**Opção B — Tentar atualizar provider/model (nem sempre funciona):**
```bash
cronjob action=update \
  job_id=<JOB_ID> \
  provider=nous \
  model=upstage/solar-pro4:free
```
Se retornar "No updates provided", use a Opção A.

### Prevenção
Sempre testar o cron job criado com `cronjob action=run job_id=<JOB_ID>` imediatamente após criação para confirmar que o provider/model estão alinhados com o ambiente atual antes de confiar na execução automática.

---

---

## 6. Instabilidade do Camofox (Operational Pitfall)

### Sintoma
Durante coleta em massa (scroll + snapshot repetidos), o Camofox pode falhar com:
```
Cannot connect to Camofox at http://camofox:9377. 
Is the server running? Start with: npm start (in camofox-browser dir)
```

### Causa
O Camofox é um processo Node.js que pode cair após uso intensivo ou timeout. Não é um erro do parser ou do workflow — é infraestrutura.

### Recuperação (roteiro rápido)
1. Verificar se está rodando: `curl -s http://localhost:9377/ -o /dev/null -w "%{http_code}"` (000 = down)
2. Se down, subir: `cd /opt/data/camofox-browser && npm start` (em background com `terminal(background=true)`)
3. Aguardar ~10-15 segundos para inicialização
4. Verificar: nova requisição `curl` deve retornar HTTP 200 ou similar
5. Retomar coleta a partir do último snapshot salvo (o parser lê o snapshot mais recente automaticamente)

**Importante:** O parser `linkedin_parser_v5.py` lê o snapshot mais recente em `/opt/data/cache/web/*.txt`, então mesmo após reinício do Camofox, é só continuar scrollando e rodar o parser novamente — não perde os dados já coletados.

### Prevenção
- Após cada `browser_scroll`, verificar se o snapshot tem novos cards antes de continuar
- Se o Camofox cair, não repetir scrolls sem reiniciar — isso gera snapshots vazios

## 7. AWS Não é Dependência do Fluxo

**Instrução do usuário (2026-09-01):** "Hermes, esqueça isso de AWS. vc nao precisa de AWS para o fluxo que estamos fazendo, cuidado"

### Significado operacional
- O pipeline de coleta LinkedIn → Fit Engine → Notion **não depende de AWS**
- Qualquer referência a AWS em descrições de vagas é **stack da vaga**, não dependência do fluxo
- Não usar credenciais AWS, Secrets Manager, ou qualquer serviço AWS como parte do pipeline
- O Fit Engine e os scripts operam localmente com Python stdlib + Camofox + Notion MCP

## 8. Gap: Notion Não Está Atualizado Automaticamente

### Status (2026-09-01)
As vagas aprovadas pelo Fit Engine **não estão sendo gravadas no Notion automaticamente**. O parser extrai e salva em JSON local, mas não faz upsert no Notion.

### Causa
O script `linkedin_parser_v5.py` é um parser standalone que processa snapshots locais e salva JSON. Ele não integra com o Notion MCP. A integração Notion existe no skill `job-process` (via `notion_upsert.py`) mas não foi invocada nesta sessão de coleta.

### Como integrar (quando necessário)
1. Usar `mcp__Notion__API_query_data_source` para verificar se a vaga já existe (dedup por URL)
2. Se nova: `mcp__Notion__API_post_page` para criar página com propriedades (Fit Score, Prioridade, etc.)
3. Se existente: `mcp__Notion__API_patch_page` para atualizar Fit Score e `Etapa Atual`

O script `notion_upsert.py` (já existe em `scripts/`) implementa essa lógica e deve ser chamado após o parser.

### Ação recomendada
Quando o usuário perguntar "as vagas estão no Notion?", a resposta correta é verificar e, se necessário, rodar o upsert. Não assumir que estão.

---

## 10. Referências

---

## 7. Arquivos relacionados

- `scripts/linkedin_parser_v5.py` — Parser que extrai vagas do snapshot e processa com Fit Engine
- `scripts/fit_engine.py` — Motor de Fit Score (parte do skill job-process)
- `/opt/data/cache/job-process/linkedin_jobs_extracted.json` — Saída padrão da coleta
