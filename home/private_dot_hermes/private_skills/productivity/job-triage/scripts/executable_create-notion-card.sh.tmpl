#!/bin/bash
# create-notion-card.sh
# Cria card no Notion Kanban Job Process

set -euo pipefail

# Uso: create-notion-card.sh <json_data> <status> <etapa>
# json_data: JSON string com dados da vaga

JSON_DATA="${1:-}"
STATUS="${2:-}"
ETAPA="${3:-}"

if [[ -z "$JSON_DATA" ]]; then
    echo "Uso: $0 '<json_data>' [status] [etapa]"
    exit 1
fi

# Config
NOTION_API_KEY="${NOTION_API_KEY:-}"
DATABASE_ID="cb9a134b-ad3b-8306-8d52-81ed264d3f5b"  # Database ID do Notion (Job Process)

if [[ -z "$NOTION_API_KEY" ]]; then
    echo "❌ NOTION_API_KEY não definido no ambiente"
    exit 1
fi

# Usar Python para extrair campos do JSON e formatar para Notion
EXTRACTED=$(python3 -c "
import json, sys, re
data = json.loads(sys.argv[1])

# Campos básicos
title = data.get('title', data.get('Name', 'Vaga sem título'))
url = data.get('url', data.get('url_vaga', data.get('Link_Vaga', '')))
content = data.get('content', data.get('descricao', data.get('Descrição', '')))
score = data.get('score', 0)
email = data.get('email', data.get('Email', ''))
tags = data.get('tags', data.get('Tags', ['tech']))
# Extrair empresa - prioridade para campo já calculado pelo triage.py
empresa = data.get('company', data.get('empresa', data.get('Empresa', '')))
if not empresa and content:
    # Tentar extrair empresa do domínio do email
    email_match = re.search(r'@([\w.-]+)', content)
    if email_match:
        domain = email_match.group(1)
        # Remover TLDs comuns
        domain = re.sub(r'\.(com|br|org|net|io|co|me|ai|gov|edu)(\.(br|com|org))?$', '', domain)
        if domain and len(domain) > 2:
            empresa = domain.capitalize()
    
    # Se não achou no email, tentar padrões no texto
    if not empresa:
        patterns = [
            r'(?i)empresa[:\\s]+([^\\n]+)',
            r'(?i)company[:\\s]+([^\\n]+)',
            r'(?i)post(?:ado)?[:\\s]+([^\\n]+)',
            r'(?i)autor[:\\s]+([^\\n]+)',
            # @usuario mas NÃO domínios de email
            r'@(\\w+)(?![.\\w]*\\.(com|br|org|net|io|co|me|ai))',
        ]
        for pat in patterns:
            m = re.search(pat, content)
            if m:
                empresa = m.group(1).strip()
                break

# Se ainda não tem, usar primeira palavra relevante
if not empresa and content:
    lines = content.strip().split('\n')
    for line in lines[:5]:
        line = line.strip()
        if line and not line.startswith(('🔥', '🚀', 'VAGA:', 'Teste', 'Oportunidade')):
            words = line.split()
            for w in words[:3]:
                if w[0].isupper() and len(w) > 2:
                    empresa = w
                    break
            if empresa:
                break

# Determinar status e etapa baseado no score e email
if score >= 70 and email and email != 'null':
    status_calc = 'Enviado'
    etapa_calc = 'Aguardando retorno'
elif score >= 70 and (not email or email == 'null'):
    status_calc = 'Sem contato'
    etapa_calc = 'Sem email'
elif score >= 40:
    status_calc = 'Revisar manual'
    etapa_calc = 'Análise necessária'
else:
    status_calc = 'Não aderente'
    etapa_calc = 'Arquivado'

# Modalidade
modalidade = data.get('modalidade', data.get('Modalidade', ['PJ','Remoto']))
mod_objs = [{'name': m} for m in modalidade]

# Tags
tags_objs = [{'name': t} for t in tags]

# Canal Envio
if email and email != 'null':
    canal = '[{\"name\": \"Email\"}]'
else:
    canal = '[]'

# Anotações
anotacoes = f'Triagem automática - score {score}'

# Output
print(title)
print(empresa)
print(url)
print(content)
print(json.dumps(mod_objs))
print(etapa_calc)
print(status_calc)
print(json.dumps(tags_objs))
print('')
print(canal)
print(anotacoes)
print(status_calc)
print(etapa_calc)
" "$JSON_DATA")

TITLE_RAW=$(echo "$EXTRACTED" | sed -n '1p')
EMPRESA_RAW=$(echo "$EXTRACTED" | sed -n '2p')
URL_VAGA=$(echo "$EXTRACTED" | sed -n '3p')
DESCRICAO=$(echo "$EXTRACTED" | sed -n '4p')
MODALIDADE_ARRAY=$(echo "$EXTRACTED" | sed -n '5p')
ETAPA_VAL=$(echo "$EXTRACTED" | sed -n '6p')
STATUS_VAL=$(echo "$EXTRACTED" | sed -n '7p')
TAGS_ARRAY=$(echo "$EXTRACTED" | sed -n '8p')
DATA_CANDIDATURA=$(echo "$EXTRACTED" | sed -n '9p')
CANAL_ENVIO_ARRAY=$(echo "$EXTRACTED" | sed -n '10p')
ANOTACOES=$(echo "$EXTRACTED" | sed -n '11p')
STATUS_VAL_FINAL=$(echo "$EXTRACTED" | sed -n '12p')
ETAPA_VAL_FINAL=$(echo "$EXTRACTED" | sed -n '13p')

# Usar os valores calculados (sobrescreve os passados como parâmetro)
STATUS_VAL="$STATUS_VAL_FINAL"
ETAPA_VAL="$ETAPA_VAL_FINAL"

# Título melhorado: "Empresa - Cargo (Score)"
SCORE=$(echo "$JSON_DATA" | python3 -c "import json, sys; print(json.load(sys.stdin).get('score', 0))")
TITLE="${EMPRESA_RAW} - ${TITLE_RAW} (${SCORE})"

# Se data_candidatura vazia, usar hoje
if [[ -z "$DATA_CANDIDATURA" ]]; then
    DATA_CANDIDATURA=$(date +%Y-%m-%d)
fi

# Construir payload (apenas campos que existem no database)
# Truncar campos longos para evitar erro de validação (max 2000 chars)
TITLE_TRUNC=$(echo "$TITLE" | cut -c1-100)
EMPRESA_TRUNC=$(echo "$EMPRESA_RAW" | cut -c1-200)
URL_TRUNC=$(echo "$URL_VAGA" | cut -c1-2000)
DESC_TRUNC=$(echo "$DESCRICAO" | cut -c1-2000)
ANOT_TRUNC=$(echo "$ANOTACOES" | cut -c1-2000)

PAYLOAD=$(cat <<EOF
{
  "parent": { "database_id": "$DATABASE_ID" },
  "properties": {
    "Name": { "title": [{ "text": { "content": "$TITLE_TRUNC" } }] },
    "Empresa": { "rich_text": [{ "text": { "content": "$EMPRESA_TRUNC" } }] },
    "Link Vaga": { "rich_text": [{ "text": { "content": "$URL_TRUNC" } }] },
    "Descrição": { "rich_text": [{ "text": { "content": "$DESC_TRUNC" } }] },
    "Modalidade": { "multi_select": $MODALIDADE_ARRAY },
    "Etapa Atual": { "select": { "name": "$ETAPA_VAL" } },
    "Status Geral": { "select": { "name": "$STATUS_VAL" } },
    "Tags": { "multi_select": $TAGS_ARRAY },
    "Data Candidatura": { "date": { "start": "$DATA_CANDIDATURA" } },
    "Canal Envio": { "multi_select": $CANAL_ENVIO_ARRAY },
    "Anotações Etapa": { "rich_text": [{ "text": { "content": "$ANOT_TRUNC" } }] }
  }
}
EOF
)

# Enviar para Notion
echo "📝 Criando card no Notion: $TITLE"
RESPONSE=$(curl -s -X POST "https://api.notion.com/v1/pages" \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Notion-Version: 2025-09-03" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD")

PAGE_ID=$(echo "$RESPONSE" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('id', ''))")
PAGE_URL=$(echo "$RESPONSE" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('url', ''))")

if [[ -n "$PAGE_ID" ]]; then
    echo "✅ Card criado com sucesso!"
    echo "   ID: $PAGE_ID"
    echo "   URL: $PAGE_URL"
    echo "   Status: $STATUS_VAL | Etapa: $ETAPA_VAL"
    exit 0
else
    echo "❌ Falha ao criar card no Notion"
    echo "$RESPONSE" | python3 -m json.tool
    exit 1
fi