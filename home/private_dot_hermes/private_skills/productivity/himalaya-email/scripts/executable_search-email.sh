#!/bin/bash
# search-email.sh - Buscar emails por remetente/assunto/data
# Uso: ./search-email.sh --account <conta> [--from <remetente>] [--subject <assunto>] [--since <data>] [--until <data>] [--count <N>]

set -euo pipefail

ACCOUNT="pessoal"
FROM=""
SUBJECT=""
SINCE=""
UNTIL=""
COUNT=20

while [[ $# -gt 0 ]]; do
  case $1 in
    --account) ACCOUNT="$2"; shift 2 ;;
    --from) FROM="$2"; shift 2 ;;
    --subject) SUBJECT="$2"; shift 2 ;;
    --since) SINCE="$2"; shift 2 ;;
    --until) UNTIL="$2"; shift 2 ;;
    --count) COUNT="$2"; shift 2 ;;
    *) echo "Opção desconhecida: $1"; exit 1 ;;
  esac
done

# Construir query IMAP SEARCH
QUERY=""

if [[ -n "$FROM" ]]; then
  QUERY="$QUERY FROM $FROM"
fi

if [[ -n "$SUBJECT" ]]; then
  QUERY="$QUERY SUBJECT $SUBJECT"
fi

if [[ -n "$SINCE" ]]; then
  # Converter YYYY-MM-DD para DD-MMM-YYYY (formato IMAP)
  SINCE_IMAP=$(date -d "$SINCE" '+%d-%b-%Y' 2>/dev/null || echo "$SINCE")
  QUERY="$QUERY SINCE $SINCE_IMAP"
fi

if [[ -n "$UNTIL" ]]; then
  UNTIL_IMAP=$(date -d "$UNTIL" '+%d-%b-%Y' 2>/dev/null || echo "$UNTIL")
  QUERY="$QUERY BEFORE $UNTIL_IMAP"
fi

# Executar busca
himalaya --account "$ACCOUNT" envelope list --search "$QUERY" --page-size "$COUNT"