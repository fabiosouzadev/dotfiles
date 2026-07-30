# Composição de Mensagens - MML Syntax

## Visão Geral

O Himalaya suporta **MML (MIME Meta Language)** para criar emails complexos:
- Multipart (HTML + texto)
- Anexos
- Imagens inline
- Assinaturas

Use `himalaya template send` (stdin) para máxima flexibilidade.

---

## 1. Email Simples (Texto Plano)

```bash
cat << 'EOF' | himalaya template send
From: você@gmail.com
To: destino@email.com
Subject: Assunto simples
Content-Type: text/plain; charset=utf-8

Corpo do email em texto plano.
Múltiplas linhas funcionam.
EOF
```

---

## 2. HTML + Texto Plano (Multipart/Alternative)

```bash
cat << 'EOF' | himalaya template send
From: você@gmail.com
To: destino@email.com
Subject: Email com HTML
Content-Type: multipart/alternative; boundary="alt123"

--alt123
Content-Type: text/plain; charset=utf-8

Versão texto para clientes antigos.

--alt123
Content-Type: text/html; charset=utf-8

<h1>Título HTML</h1>
<p>Com <strong>formatação</strong>, <a href="https://exemplo.com">links</a>.</p>
<ul>
  <li>Item 1</li>
  <li>Item 2</li>
</ul>

--alt123--
EOF
```

---

## 3. Com Anexo (Multipart/Mixed)

```bash
# 1. Codificar anexo em base64 (sem quebras de linha)
base64 -w 0 relatorio.pdf > relatorio.b64

# 2. Enviar com template
cat << 'EOF' | himalaya template send
From: você@gmail.com
To: destino@email.com
Subject: Relatório em anexo
Content-Type: multipart/mixed; boundary="mixed456"

--mixed456
Content-Type: text/plain; charset=utf-8

Segue o relatório solicitado.

--mixed456
Content-Type: application/pdf; name="relatorio.pdf"
Content-Disposition: attachment; filename="relatorio.pdf"
Content-Transfer-Encoding: base64

$(cat relatorio.b64)
--mixed456--
EOF
```

---

## 4. HTML + Anexo + Imagem Inline (Multipart/Related + Mixed)

```bash
base64 -w 0 logo.png > logo.b64
base64 -w 0 documento.pdf > doc.b64

cat << 'EOF' | himalaya template send
From: você@gmail.com
To: destino@email.com
Subject: Relatório com logo
Content-Type: multipart/mixed; boundary="outer"

--outer
Content-Type: multipart/related; boundary="related"

--related
Content-Type: multipart/alternative; boundary="alt"

--alt
Content-Type: text/plain; charset=utf-8

Relatório mensal - ver HTML ou PDF anexo.

--alt
Content-Type: text/html; charset=utf-8

<html><body>
<h1>Relatório Mensal</h1>
<img src="cid:logo@empresa.com" alt="Logo" width="200"/>
<p>Dados do mês...</p>
</body></html>

--alt--
--related
Content-Type: image/png; name="logo.png"
Content-Disposition: inline; filename="logo.png"
Content-ID: <logo@empresa.com>
Content-Transfer-Encoding: base64

$(cat logo.b64)
--related--
--outer
Content-Type: application/pdf; name="relatorio.pdf"
Content-Disposition: attachment; filename="relatorio.pdf"
Content-Transfer-Encoding: base64

$(cat doc.b64)
--outer--
EOF
```

---

## 5. Reply / Forward (Usando Templates)

### Reply automático
```bash
# 1. Ler email original
himalaya message read 123 --account pessoal > original.txt

# 2. Extrair headers necessários (Message-ID, References)
# 3. Compor reply
cat << 'EOF' | himalaya template send
From: você@gmail.com
To: remetente@original.com
Subject: Re: Assunto original
In-Reply-To: <message-id-do-original>
References: <message-id-do-original>
Content-Type: text/plain; charset=utf-8

Obrigado pelo email.

Sua resposta aqui.

--
Sua assinatura
EOF
```

### Forward
```bash
cat << 'EOF' | himalaya template send
From: você@gmail.com
To: novo@destino.com
Subject: Fwd: Assunto original
Content-Type: multipart/mixed; boundary="fwd123"

--fwd123
Content-Type: text/plain; charset=utf-8

Encaminhando mensagem abaixo.

--fwd123
Content-Type: message/rfc822

[Cole aqui o email original completo com headers]
--fwd123--
EOF
```

---

## 6. Scripts Auxiliares

### encode-attachment.sh
```bash
#!/bin/bash
# Uso: ./encode-attachment.sh arquivo.pdf > arquivo.b64
FILE="$1"
base64 -w 0 "$FILE"
```

### send-with-attachment.sh
```bash
#!/bin/bash
# Uso: ./send-with-attachment.sh conta destino assunto corpo arquivo.pdf

ACCOUNT="$1"
TO="$2"
SUBJECT="$3"
BODY="$4"
ATTACH="$5"

B64=$(base64 -w 0 "$ATTACH")
FILENAME=$(basename "$ATTACH")
MIMETYPE=$(file --mime-type -b "$ATTACH")

cat << EOF | himalaya --account "$ACCOUNT" template send
From: $(himalaya --account "$ACCOUNT" account list --output json | jq -r '.[] | select(.default==true) | .email')
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
```

---

## 7. Headers Úteis

| Header | Uso |
|--------|-----|
| `From` | Remetente (deve ser conta autenticada) |
| `To` | Destinatário(s) - vírgula para múltiplos |
| `Cc` | Cópia |
| `Bcc` | Cópia oculta |
| `Subject` | Assunto |
| `In-Reply-To` | Message-ID do email original (reply) |
| `References` | Cadeia de Message-IDs (thread) |
| `Reply-To` | Email para respostas |
| `Content-Type` | MIME type + boundary |
| `Content-Disposition` | `attachment` ou `inline` |
| `Content-ID` | Para imagens inline (`cid:...`) |

---

## 8. Boas Práticas

1. **Sempre use `text/plain` + `text/html`** (multipart/alternative)
2. **Boundary único** por nível (use timestamp/uuid)
3. **Base64 sem quebras** (`base64 -w 0`)
4. **Teste com `himalaya template send`** antes de automatizar
5. **Não use `message write` para anexos** - use MML templates
6. **Valide TOML** antes de mudar config: `python3 -c "import tomllib; tomllib.load(open('config.toml', 'rb'))"`

---

## 9. Referência Rápida de Estruturas MIME

```
multipart/mixed
  ├── text/plain
  ├── text/html
  └── application/pdf (attachment)

multipart/alternative
  ├── text/plain
  └── text/html

multipart/related
  ├── multipart/alternative
  │   ├── text/plain
  │   └── text/html (com <img src="cid:...">)
  └── image/png (inline, Content-ID: <...>)

multipart/mixed (completo)
  ├── multipart/related (HTML + imagens inline)
  └── application/pdf (anexo)
```

---

## 10. Debug de Templates

```bash
# Ver MIME gerado (sem enviar)
cat template.mml | himalaya template send 2>&1 | head -50

# Salvar como .eml para inspecionar
cat template.mml | himalaya template send > email.eml
# Abrir no Thunderbird / VS Code / mutt
```