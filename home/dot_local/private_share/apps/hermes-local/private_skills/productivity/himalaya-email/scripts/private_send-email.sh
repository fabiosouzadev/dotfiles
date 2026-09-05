#!/bin/bash
# send-email.sh - Envio rápido de emails via Himalaya
# Uso: ./send-email.sh --account <conta> --to <email> --subject <assunto> --body <corpo> [--attach <arquivo>]

set -euo pipefail

ACCOUNT="pessoal"
TO=""
SUBJECT=""
BODY=""
ATTACH=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --account) ACCOUNT="$2"; shift 2 ;;
        --to) TO="$2"; shift 2 ;;
        --subject) SUBJECT="$2"; shift 2 ;;
        --body) BODY="$2"; shift 2 ;;
        --attach) ATTACH="$2"; shift 2 ;;
        *) echo "Opção desconhecida: $1"; exit 1 ;;
    esac
done

if [[ -z "$TO" || -z "$SUBJECT" || -z "$BODY" ]]; then
    echo "Uso: $0 --account <conta> --to <email> --subject <assunto> --body <corpo> [--attach <arquivo>]"
    exit 1
fi

# Obter email da conta (From)
FROM_EMAIL=$(himalaya --account "$ACCOUNT" account list --output json 2>/dev/null | jq -r '.[] | select(.default==true) | .email' 2>/dev/null || echo "$ACCOUNT")

if [[ -n "$ATTACH" && -f "$ATTACH" ]]; then
    # Com anexo - usar MML template
    B64=$(base64 -w 0 "$ATTACH")
    FILENAME=$(basename "$ATTACH")
    MIMETYPE=$(file --mime-type -b "$ATTACH")

    cat << EOF | himalaya --account "$ACCOUNT" template send
From: $FROM_EMAIL
To: $TO
Subject: $SUBJECT
Content-Type: multipart/mixed; boundary="mixed123"

--mixed123
Content-Type: text/plain; charset=utf-8

$BODY

--mixed123
Content-Type: $MIMETYPE; name="$FILENAME"
Content-Disposition: attachment; filename="$FILENAME"
Content-Transfer-Encoding: base64

$B64
--mixed123--
EOF
else
    # Sem anexo - usar message compose (mais simples)
    himalaya --account "$ACCOUNT" message compose \
        --from "$FROM_EMAIL" \
        --to "$TO" \
        --subject "$SUBJECT" \
        --body "$BODY" \
        --send
fi

echo "✅ Email enviado para $TO (assunto: $SUBJECT)"