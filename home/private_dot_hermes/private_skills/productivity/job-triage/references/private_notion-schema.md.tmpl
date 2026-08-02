# Notion Database Schema - Job Process

## Database Info
- **Database ID**: `cb9a134b-ad3b-8306-8d52-81ed264d3f5b` (para criar páginas)
- **Data Source ID**: `b45a134b-ad3b-83c5-a4e8-07d467d825ba` (para queries)
- **Parent Page**: `38fa134b-ad3b-802b-be9d-e41f684f7384`
- **URL**: https://app.notion.com/p/cb9a134bad3b83068d5281ed264d3f5b

## Propriedades Completas

| Property ID | Name | Type | Options/Config |
|-------------|------|------|----------------|
| `title` | Name | Title | - |
| `%40pxe` | Empresa | Rich Text | - |
| `t%5Dg%5D` | Link Vaga | Rich Text | - |
| `%3FztH` | Descrição | Rich Text | - |
| `%3C%5Bdn` | Modalidade | Multi-select | PJ (yellow), CLT (green), Cooperado (orange), Remoto (brown) |
| `%3EpRM` | Etapa Atual | Select | Preparar candidatura (gray), Aguardando retorno (yellow), Entrevista agendada (blue), Em processo (green), Finalizado (purple), Cadastro pendente (brown), Aguardando análise (orange), Entrevista realizada (pink), Recebido/em análise (red), Candidatura enviada (default), Entrevista com Hunting (default) |
| `FjCI` | Status Geral | Select | Não aderente (red), Pra enviar (orange), Enviado (green), Em processo (blue), Finalizado (purple), Aguardando retorno (pink) |
| `x%40sU` | Tags | Multi-select | 60+ tags técnicas (Node.js, NestJS, Java, Spring Boot, Python, AWS, AI, etc.) |
| `sxA%3F` | Salário | Number | Format: number |
| `e%5E%3E_` | Obs Salário | Rich Text | - |
| `%7DFvZ` | Data Candidatura | Date | - |
| `ao%7D%40` | Canal Envio | Multi-select | Email (blue), WhatsApp (green), LinkedIn (default) |
| `YjTj` | Entrevista Tech | Date | - |
| `_%60uX` | Entrevista Manager | Date | - |
| `qzEu` | Entrevista Time | Date | - |
| `ykl%3E` | Entrevista Hunting | Date | - |
| `bHfQ` | Ent. Alocação | Date | - |
| `~Fpi` | Ent. Tech Alocado | Date | - |
| `AYWg` | Anotações Etapa | Rich Text | - |

## Mapeamento Status → Etapa Atual

| Status Geral | Etapa Atual Sugerida |
|--------------|---------------------|
| Não aderente | (qualquer) |
| Pra enviar | Preparar candidatura |
| Enviado | Candidatura enviada |
| Em processo | Em processo / Entrevista agendada |
| Finalizado | Finalizado |
| Aguardando retorno | Aguardando retorno / Aguardando análise |

## Criar Página (Payload Exemplo)

```json
{
  "parent": { "database_id": "cb9a134b-ad3b-8306-8d52-81ed264d3f5b" },
  "properties": {
    "Name": { "title": [{ "text": { "content": "Tech Lead Node.js - Empresa X" } }] },
    "Empresa": { "rich_text": [{ "text": { "content": "Empresa X" } }] },
    "Link Vaga": { "rich_text": [{ "text": { "content": "https://linkedin.com/jobs/view/123" } }] },
    "Descrição": { "rich_text": [{ "text": { "content": "Texto extraído da vaga..." } }] },
    "Modalidade": { "multi_select": [{ "name": "PJ" }, { "name": "Remoto" }] },
    "Etapa Atual": { "select": { "name": "Preparar candidatura" } },
    "Status Geral": { "select": { "name": "Pra enviar" } },
    "Tags": { "multi_select": [{ "name": "Node.js" }, { "name": "NestJS" }, { "name": "AWS" }] },
    "Score": { "number": 85 },
    "Data Candidatura": { "date": { "start": "2026-07-31" } },
    "Canal Envio": { "multi_select": [] },
    "CV Enviado": { "checkbox": false },
    "Anotações Etapa": { "rich_text": [{ "text": { "content": "Triagem automática - score 85" } }] }
  }
}
```

## Query Database (Data Source ID)

```bash
curl -X POST "https://api.notion.com/v1/data_sources/b45a134b-ad3b-83c5-a4e8-07d467d825ba/query" \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Notion-Version: 2025-09-03" \
  -H "Content-Type: application/json" \
  -d '{"filter": {"property": "Status Geral", "select": {"equals": "Pra enviar"}}}'
```

## Rate Limits
- ~3 requests/second average
- Batch operations: sleep 0.3s entre requests
- Use `page_size: 100` para listar tudo