# Workflow de Coleta LinkedIn — Passo a Passo

## Visão Geral

Este documento detalha o workflow de coleta de vagas do LinkedIn que funcionou na sessão de 2026-09-01. O objetivo era coletar até 100 vagas, processar com Fit Engine e salvar em JSON.

## Pré-requisitos

- Browser (Camofox) funcionando: verificar com `curl http://camofox:9377/` → HTTP 200
- Script `linkedin_parser_v5.py` disponível em `/opt/data/skills/productivity/job-process/scripts/`
- Diretório `/opt/data/cache/web/` existente para snapshots
- Diretório `/opt/data/cache/job-process/` existente para saída JSON

## Passo 1: Verificar Camofox

```bash
curl -s -o /dev/null -w "HTTP %{http_code}\n" http://camofox:9377/
# Esperado: HTTP 200 (ou código 2xx)
# Se retornar 000 ou erro de conexão: Camofox offline, comunicar usuário para reiniciar
```

**Se Camofox estiver OFF:** o usuário precisa subir manualmente no VPS (via `npm start` no diretório `camofox-browser` ou Docker). Não tentar levantar o Docker daemon se o usuário instruir o contrário.

## Passo 2: Navegar para busca do LinkedIn

```python
# Navegar para página de busca
browser_navigate(url="https://www.linkedin.com/jobs/search/?keywords=contractor%20developer%20remote&origin=JOB_SEARCH_HOME&searchId=a1b2c3d4e5f6&start=0")
```

**Queries testadas nesta sessão:**
| Query | Vagas encontradas |
|-------|-------------------|
| `contractor developer remote java python node` | 1000+ vagas nos EUA |
| `contractor developer remote` | 1000+ vagas nos EUA |

**Dica de query:** para focar em vagas freelance/contractor com menor concorrência, usar `f_EA=true` (menos de 10 candidaturas):
```
https://www.linkedin.com/jobs/search/?keywords=contractor%20developer%20remote&origin=JOB_SEARCH_HOME&searchId=a1b2c3d4e5f6&f_EA=true&start=0
```

## Passo 3: Fazer scroll para carregar vagas

Cada página do LinkedIn mostra ~20-25 vagas. Para coletar 100 vagas, precisamos de ~5 páginas.

```python
# Scroll 1 (carrega página 2)
browser_scroll(direction="down")

# Snapshot após scroll 1 para verificar que novos cards apareceram
browser_snapshot(full=True)
# Guardar path do snapshot: /opt/data/cache/web/browser-snapshot-<ts>.txt

# Repetir para páginas 3, 4, 5...
browser_scroll(direction="down")
browser_snapshot(full=True)
# etc.
```

**Nesta sessão:** foi feito scroll 4 vezes para carregar vagas das páginas 0-4. O snapshot final tinha 60 vagas únicas (LinkedIn pode ter limitado carregamento ou algumas vagas eram duplicadas).

**Quando o snapshot não mostra novos cards após scroll:** aguardar alguns segundos e tentar novamente, ou verificar se o modal de login bloqueou o carregamento (fechar modal e tentar novamente).

## Passo 4: Login Wall (se aparecer)

Durante coleta, o LinkedIn pode mostrar modal:
- "Entre para ver mais vagas"
- "Entre para ver quem você já conhece na empresa X"

**Identificar no snapshot:**
```yaml
- dialog "Entre para ver mais vagas":
  - heading "Entre para ver mais vagas" [level=2]
  - button "Fechar" [e10]: img
  - button "Continuar com o Google" [e1]: iframe
```

**Ação: fechar modal**
```python
browser_click(ref="e10")  # botão "Fechar"
```

Após fechar, continuar scroll normalmente. Não precisa fazer login.

## Passo 5: Executar parser v5

```bash
cd /opt/data/skills/productivity/job-process/scripts
python3 linkedin_parser_v5.py
```

**O que o parser faz:**
1. Encontra o snapshot mais recente em `/opt/data/cache/web/*.txt` (ordenado por mtime, reversed)
2. Prioriza snapshots com 5+ ocorrências de `jobs/view/`
3. Extrai vagas via regex no texto do snapshot
4. Processa cada vaga com Fit Engine
5. Salva JSON em `/opt/data/cache/job-process/linkedin_jobs_extracted.json`

**Saída esperada:**
```
============================================================
📊 LinkedIn Jobs Parser v5 + Fit Engine
============================================================

📄 Snapshot: browser-snapshot-<ts>.txt (XX,XXX bytes)

🔍 Extraídas: N vagas únicas
💾 Salvo: /opt/data/cache/job-process/linkedin_jobs_extracted.json

============================================================
📊 RESUMO EXECUÇÃO
============================================================
Total coletadas:           N
Aprovadas (não rejeitadas): M
Fit ≥ 60 (P3+):            P
Fit ≥ 80 (P1/P2):          Q
Remotas:                   R
Com empresa:              N
...
```

## Passo 6: Verificar resultado

```bash
# Ler o JSON salvo
python3 -c "
import json
with open('/opt/data/cache/job-process/linkedin_jobs_extracted.json') as f:
    data = json.load(f)
print(f'Total: {data[\"total\"]}')
print(f'Snapshot: {data[\"snapshot\"]}')
for job in data['jobs'][:5]:
    print(f\"  [{job['fit_score']}pts] {job['priority']:8s} | {job['title'][:50]}\")
    print(f\"           {job['company']} | {job['modality']} | Remote: {'✅' if job['remote'] else '❌'}\")
"
```

## Passo 7: Acessar vagas de alto fit (opcional)

Para vagas com Fit ≥ 80 (P1/P2), acessar detalhe completo:

```python
# Pega URL da vaga do JSON
browser_navigate(url="<URL_DA_VAGA>")
# Capturar snapshot do detalhe
browser_snapshot(full=True)
# Extrair descrição completa via browser_console se necessário
```

**Pitfall:** ao acessar detalhe de vaga, pode aparecer modal de login ("Entre para ver quem você já conhece na empresa X"). Fechar com `browser_click(ref=\"e1\")` e tentar extrair via JS.

## Passo 8: Rodar via cron job (automatização)

Para automatizar a coleta diária, criar cron job:

```bash
cronjob action=create \
  --name "LinkedIn Jobs Collector - 100 vagas" \
  --prompt "## LinkedIn Jobs Collector — Coleta 100 vagas

### Objetivo
Coletar até 100 vagas do LinkedIn Jobs, processar com Fit Engine, salvar em JSON e reportar.

### Passo a passo
1. Navegar no LinkedIn Jobs para busca de vagas
2. Fazer scroll para carregar mais vagas (repetir até ~100 vagas)
3. Capturar snapshot completo
4. Executar python3 linkedin_parser_v5.py
5. Reportar resumo: total, aprovadas, top 10 por Fit Score, quantidade remote

### Saída esperada
Resumo em texto + arquivo JSON salvo em /opt/data/cache/job-process/linkedin_jobs_extracted.json" \
  --schedule "0 16 * * *" \
  --deliver "telegram:644615401:14880" \
  --skills "job-process"
```

**Importante:** testar o cron job imediatamente após criação com `cronjob action=run job_id=<JOB_ID>`. Se retornar erro de drift de configuração (provider/model desatualizados), recriar o cron job.

## Troubleshooting

### Parser retorna 0 vagas

1. Verificar se há snapshots recentes: `ls -lt /opt/data/cache/web/*.txt | head`
2. Verificar conteúdo do snapshot: `grep -c "jobs/view/" /opt/data/cache/web/browser-snapshot-<ts>.txt`
3. Se contagem for 0: snapshot não tem vagas, precisa navegar e scroll novamente
4. Se contagem > 0 mas parser retorna 0: regex pode não estar matchando, verificar formato do snapshot

### "No updates provided" ao atualizar cron job

Significa que provider/model já estavam corretos e o sistema não aceita update vazio. Para corrigir drift:
1. Remover cron antigo: `cronjob action=remove job_id=<JOB_ID>`
2. Criar novo: `cronjob action=create ...` (com provider/model corretos)

### Camofox fora durante coleta

1. Comunicar usuário: "Camofox caiu, preciso reiniciar ou você prefere que eu use outro caminho?"
2. Aguardar usuário subir Camofox
3. Continuar coleta de onde parou (navegar novamente para a mesma URL de busca)
