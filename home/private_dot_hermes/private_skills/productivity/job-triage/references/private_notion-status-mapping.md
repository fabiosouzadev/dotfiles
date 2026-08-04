# create-notion-card.sh — Status/Etapa Auto-Mapping

## Logic (implemented in `scripts/create-notion-card.sh`)

### Automatic Calculation (default)
Based on `score` + `email` presence:

| Score Range | Email Present | Status | Etapa |
|-------------|---------------|--------|-------|
| ≥ 70 | Yes | `Enviado` | `Aguardando retorno` |
| ≥ 70 | No | `Sem contato` | `Sem email` |
| 40-69 | Any | `Revisar manual` | `Análise necessária` |
| < 40 | Any | `Não aderente` | `Arquivado` |

### Manual Override (v1.2.0)
Environment variables to force status/etapa:
- `STATUS_PARAM` — força status (ex: `Enviado`)
- `ETAPA_PARAM` — força etapa (ex: `Candidatura enviada`)

**Usage:**
```bash
STATUS_PARAM="Enviado" ETAPA_PARAM="Candidatura enviada" \
NOTION_API_KEY="..." \
./scripts/create-notion-card.sh '{"title": "...", "score": 35, "email": "..."}'
```

**When used:** User explicitly requests candidacy for a score < 70 vacancy (e.g., "Siga com a candidatura da vaga acima, mesmo não aderente").

---

## Title Format
`"Empresa - Cargo (Score)"`
- Empresa: from JSON `company` field, or extracted via P1-P5 logic
- Cargo: from JSON `title` field
- Score: from JSON `score` field

---

## Database IDs (Critical)
- **Create pages**: `database_id` = `cb9a134b-ad3b-8306-8d52-81ed264d3f5b`
- **Query pages**: `data_source_id` = `b45a134b-ad3b-83c5-a4e8-07d467d825ba`

---

## Select Options (must match Notion exactly)

### Status Geral
- `Não aderente` (red)
- `Pra enviar` (default)
- `Enviado` (green)
- `Em processo` (blue)
- `Finalizado` (purple)
- `Aguardando retorno` (orange)
- `Sem contato` (gray)
- `Revisar manual` (yellow)

### Etapa Atual
- `Preparar candidatura`
- `Aguardando retorno`
- `Entrevista agendada`
- `Em processo`
- `Finalizado`
- `Cadastro pendente`
- `Aguardando análise`
- `Entrevista realizada`
- `Recebido/em análise`
- `Candidatura enviada`
- `Entrevista com Hunting`
- `Sem email`
- `Análise necessária`
- `Arquivado`

---

## Rate Limiting
Notion API: ~3 requests/second. Batch operations (cleanup) should sleep 400ms between requests.