#!/bin/bash
# read-email.sh - Ler email completo por ID
# Uso: ./read-email.sh --account <conta> --id <ID> [--mailbox <caixa>] [--full]

set -euo pipefail

ACCOUNT="pessoal"
ID=""
MAILBOX="INBOX"
FULL=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --account) ACCOUNT="$2"; shift 2 ;;
    --id) ID="$2"; shift 2 ;;
    --mailbox) MAILBOX="$2"; shift 2 ;;
    --full) FULL=true; shift ;;
    *) echo "Opção desconhecida: $1"; exit 1 ;;
  esac
done

if [[ -z "$ID" ]]; then
  echo "Uso: $0 --account <conta> --id <ID> [--mailbox <caixa>] [--full]"
  exit 1
fi

if [[ "$FULL" == true ]]; then
  himalaya --account "$ACCOUNT" message export "$ID" --full --mailbox "$MAILBOX"
else
  himalaya --account "$ACCOUNT" message read "$ID" --mailbox "$MAILBOX"
fi