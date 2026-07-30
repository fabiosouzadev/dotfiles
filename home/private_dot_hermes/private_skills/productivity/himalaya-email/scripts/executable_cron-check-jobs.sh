#!/bin/bash
# cron-check-jobs.sh - Verificador diário de vagas (executa 08:00 UTC)
# Requer: TELEGRAM_BOT_TOKEN, TELEGRAM_CHAT_ID no ambiente
# Uso: 0 8 * * * /opt/data/skills/productivity/himalaya-email/scripts/cron-check-jobs.sh

set -euo pipefail

# Configurações
ACCOUNT="pessoal"
SINCE=$(date -d "1 day ago" '+%Y-%m-%d')
KEYWORDS=("vaga" "oportunidade" "linkedin" "contratação" "tech lead" "arquiteto" "senior" "pleno" "lead" "staff" "principal")
TELEGRAM_API="https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage"

# Função para enviar mensagem Telegram
send_telegram() {
  local msg="$1"
  curl -s -X POST "$TELEGRAM_API" \
    -d chat_id="$TELEGRAM_CHAT_ID" \
    -d text="$msg" \
    -d parse_mode="Markdown" \
    > /dev/null
}

# Header
REPORT="📧 *Verificação de Vagas - $(date '+%d/%m/%Y %H:%M')*\n\n"

FOUND_ANY=false

for kw in "${KEYWORDS[@]}"; do
  # Buscar emails não lidos com palavra-chave no assunto
  RESULTS=$(himalaya --account "$ACCOUNT" envelope list \
    --search "from:linkedin.com SUBJECT $kw SINCE $SINCE" \
    --output json 2>/dev/null || echo "[]")
  
  COUNT=$(echo "$RESULTS" | jq 'length')
  
  if [[ "$COUNT" -gt 0 ]]; then
    FOUND_ANY=true
    REPORT+="🔍 *$kw* ($COUNT emails):\n"
    
    echo "$RESULTS" | jq -r '.[] | "\(.id)|\(.subject)|\(.from)|\(.date)"' | while IFS='|' read -r id subject from date; do
      # Truncar assunto se muito longo
      short_subject="${subject:0:80}"
      REPORT+="  • \`$id\` $short_subject...\n"
      REPORT+="    De: $from | $date\n"
    done
    REPORT+="\n"
  fi
done

if [[ "$FOUND_ANY" == false ]]; then
  REPORT+="✅ Nenhuma vaga nova encontrada nas últimas 24h."
fi

# Enviar relatório
send_telegram "$REPORT"

# Log local
echo "$(date '+%Y-%m-%d %H:%M:%S') - Verificação concluída. Encontrados: $FOUND_ANY" >> /var/log/himalaya-jobs.log