#!/bin/bash
# list-inbox.sh - Listar últimos N emails
# Uso: ./list-inbox.sh --account <conta> --count <N> [--mailbox <pasta>]

set -euo pipefail

ACCOUNT="pessoal"
COUNT=10
MAILBOX="INBOX"

while [[ $# -gt 0 ]]; do
    case $1 in
        --account) ACCOUNT="$2"; shift 2 ;;
        --count) COUNT="$2"; shift 2 ;;
        --mailbox) MAILBOX="$2"; shift 2 ;;
        *) echo "Opção desconhecida: $1"; exit 1 ;;
    esac
done

himalaya --account "$ACCOUNT" envelope list \
    --mailbox "$MAILBOX" \
    --page-size "$COUNT" \
    --output table