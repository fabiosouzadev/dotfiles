# Lições Aprendidas - Envio de Emails com Himalaya

## Configuração Obrigatória no config.toml

O erro `No From: header found in raw message` ocorre quando o `config.toml` não tem os campos `email` e `display-name`:

```toml
[accounts.gmail]
default = true
email = "seu-email@gmail.com"          # OBRIGATÓRIO
display-name = "Seu Nome"              # OBRIGATÓRIO

imap.server = "imaps://imap.gmail.com:993"
# ... resto da config
```

## Envio com Anexo - Método Simples (himalaya v0.6+)

O script original usava `template send` com MML manual, mas o **método nativo `--attach` do `message compose` é muito mais simples**:

```bash
himalaya --account gmail message compose \
    --from "seu-email@gmail.com" \
    --to "destino@email.com" \
    --subject "Assunto" \
    --body "Corpo do email" \
    --attach "/caminho/arquivo.pdf" \
    --send
```

## O que NÃO fazer

1. **Não use `template send` com MML manual** para anexos simples - é complexo e propenso a erros
2. **Não dependa do comando `file`** para detectar MIME type - pode não estar instalado
3. **Não omita `email` e `display-name`** no config.toml - causa erro "No From header"

## Verificação Rápida Antes de Enviar

```bash
# Testar se conta está configurada corretamente
himalaya --account gmail envelope list --page-size 1

# Verificar campos obrigatórios
himalaya account list --output json | jq '.[] | select(.default==true) | {email, display_name}'
```

## Detecção de MIME Type com Fallback

```bash
if command -v file >/dev/null 2>&1; then
    MIMETYPE=$(file --mime-type -b "$ATTACH")
else
    case "${ATTACH##*.}" in
        pdf) MIMETYPE="application/pdf" ;;
        txt) MIMETYPE="text/plain" ;;
        png) MIMETYPE="image/png" ;;
        jpg|jpeg) MIMETYPE="image/jpeg" ;;
        *) MIMETYPE="application/octet-stream" ;;
    esac
fi
```