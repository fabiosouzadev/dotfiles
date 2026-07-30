# Troubleshooting - Himalaya Email

## Problemas Comuns e Soluções

---

## 1. Erro: `Invalid credentials` / `Authentication failed`

### Causas
- App Password incorreto
- App Password expirado/revogado
- 2FA desativado na conta Google
- Conta bloqueada por atividade suspeita

### Solução
```bash
# 1. Verificar se pass tem a senha correta
pass show gmail/himalaya-pessoal
pass show gmail/himalaya-zup

# 2. Gerar NOVO App Password
# Acesse: https://myaccount.google.com/apppasswords
# Crie novo "Himalaya Pessoal" / "Himalaya Zup"

# 3. Atualizar no pass
pass insert gmail/himalaya-pessoal  # cole nova senha
pass insert gmail/himalaya-zup      # cole nova senha

# 4. Testar
himalaya --account pessoal envelope list --page-size 1
```

---

## 2. Erro: `No backend matching 'auto' is configured for this account`

### Causas
- Sintaxe TOML incorreta no `config.toml`
- Seção `[accounts.nome]` mal formada
- Campos `backend.*` não reconhecidos

### Solução
```bash
# Validar sintaxe TOML
python3 -c "import tomllib; tomllib.load(open('/home/ubuntu/.config/himalaya/config.toml', 'rb'))"
# Se der erro: corrigir sintaxe

# Verificar estrutura
himalaya account list
# Deve mostrar backend: imap, smtp
```

### Formato Correto (v1.2.0+)
```toml
[accounts.pessoal]
email = "você@gmail.com"
default = true

# IMPORTANTE: campos flat com underscore, não sub-tabelas
backend.type = "imap"
backend.server = "imap.gmail.com"
backend.port = 993
backend.tls = true
backend.login = "você@gmail.com"
backend.auth_type = "password"
backend.auth_cmd = "pass show gmail/himalaya-pessoal"

# SMTP - use message.send.backend.* (não backend.*)
message.send.backend.type = "smtp"
message.send.backend.server = "smtp.gmail.com"
message.send.backend.port = 465
message.send.backend.tls = true
message.send.backend.login = "você@gmail.com"
message.send.backend.auth_type = "password"
message.send.backend.auth_cmd = "pass show gmail/himalaya-pessoal"

# PASTAS GMAIL - OBRIGATÓRIO usar folder.aliases (plural, dotted)
folder.aliases.inbox = "INBOX"
folder.aliases.sent = "[Gmail]/Sent Mail"
folder.aliases.drafts = "[Gmail]/Drafts"
folder.aliases.trash = "[Gmail]/Trash"
folder.aliases.archive = "[Gmail]/All Mail"
```

---

## 3. Erro: `Secret command not found` / `pass: command not found`

### Causa
`password-store` (pass) não instalado

### Solução
```bash
# Ubuntu/Debian
sudo apt-get update && sudo apt-get install -y pass gnupg2

# Inicializar (primeira vez)
pass init "seu-email@gmail.com"

# Verificar
pass show gmail/himalaya-pessoal
```

---

## 4. Emails enviados não aparecem em "Sent" / Duplicatas

### Causa
`folder.aliases.sent` não configurado ou usando sintaxe antiga (`folder.alias` singular)

### Sintoma
- Email enviado via SMTP OK
- Mas Himalaya falha ao salvar cópia em "Sent"
- Retorno de erro → script reenvia → **emails duplicados**

### Solução
```toml
# SEMPRE usar folder.aliases (plural, dotted keys)
folder.aliases.sent = "[Gmail]/Sent Mail"

# NÃO usar (v1.1.x - ignorado no v1.2+):
# [accounts.pessoal.folder.alias]
# sent = "[Gmail]/Sent Mail"
```

---

## 5. Anexos não vão / Email chega corrompido

### Causa
MIME mal formado ao usar `message write` com anexos grandes

### Solução
Use **MML templates** (`template send`) para anexos:

```bash
# Codificar anexo em base64
base64 -w 0 arquivo.pdf > arquivo.b64

# Template MML
cat << 'EOF' | himalaya template send
From: você@gmail.com
To: destino@email.com
Subject: Com anexo
Content-Type: multipart/mixed; boundary="boundary123"

--boundary123
Content-Type: text/plain; charset=utf-8

Segue o arquivo.

--boundary123
Content-Type: application/pdf; name="arquivo.pdf"
Content-Disposition: attachment; filename="arquivo.pdf"
Content-Transfer-Encoding: base64

$(cat arquivo.b64)
--boundary123--
EOF
```

---

## 6. Timeout / Conexão lenta IMAP/SMTP

### Causas
- Rede instável
- Firewall bloqueando portas 993/465
- Gmail rate limiting

### Soluções
```bash
# Testar conectividade
telnet imap.gmail.com 993
telnet smtp.gmail.com 465

# Aumentar timeout (variável de ambiente)
HIMALAYA_TIMEOUT=60 himalaya envelope list

# Debug verbose
RUST_LOG=debug himalaya envelope list
```

---

## 7. Busca não encontra emails (IMAP SEARCH)

### Causas
- Formato de data errado (IMAP usa DD-MMM-YYYY)
- Encoding de caracteres especiais
- Limite de resultados do servidor

### Formato de Data IMAP
```bash
# Correto: DD-MMM-YYYY (ex: 30-Jul-2026)
date -d "2026-07-30" '+%d-%b-%Y'
# Saída: 30-Jul-2026

# No script search-email.sh, converte automaticamente
```

### Buscar por remetente
```bash
# Exato
himalaya envelope list --search 'FROM "linkedin.com"'

# Contém
himalaya envelope list --search 'FROM "linkedin"'

# Assunto + remetente
himalaya envelope list --search 'FROM "linkedin.com" SUBJECT "vaga"'
```

---

## 8. Erro: `Parse TOML config error` / `unknown field`

### Causa
Campo não suportado pela versão do Himalaya instalada

### Verificar versão
```bash
himalaya --version
```

### Campos suportados (v0.7+)
| Seção | Campos válidos |
|-------|----------------|
| `backend` | type, server, port, tls, starttls, login, auth_type, auth_cmd, auth_raw, sasl, timeout |
| `message.send.backend` | type, server, port, tls, starttls, login, auth_type, auth_cmd, auth_raw |
| `folder.aliases` | inbox, sent, drafts, trash, archive, junk, spam |

---

## 9. Permissões / Arquivos

```bash
# Config deve ser legível apenas pelo usuário
chmod 600 ~/.config/himalaya/config.toml

# pass store
chmod 700 ~/.password-store
chmod 600 ~/.password-store/gmail/himalaya-*
```

---

## 10. Debug Avançado

```bash
# Log completo
RUST_LOG=trace himalaya --account pessoal envelope list 2>&1 | head -100

# Ver raw IMAP commands
himalaya imap --account pessoal id
himalaya imap --account pessoal list ""

# Testar SMTP direto
echo "test" | himalaya --account pessoal message compose \
  --to "você@gmail.com" --subject "teste" --send
```

---

## Checklist Rápido (Quando Nada Funciona)

- [ ] `himalaya --version` → versão compatível
- [ ] `pass show gmail/himalaya-pessoal` → retorna senha de 16 chars
- [ ] `himalaya account list` → mostra `imap, smtp` nos backends
- [ ] `telnet imap.gmail.com 993` → conecta
- [ ] `telnet smtp.gmail.com 465` → conecta
- [ ] `config.toml` tem `folder.aliases.sent = "[Gmail]/Sent Mail"`
- [ ] App Password gerado **hoje** (não expirado)
- [ ] 2FA **ativo** na conta Google
- [ ] Permissões `config.toml` = 600

---

## Contatos Úteis

- [Himalaya GitHub Issues](https://github.com/pimalaya/himalaya/issues)
- [Himalaya Discord](https://discord.gg/pimalaya)
- [Gmail IMAP/SMTP Docs](https://support.google.com/mail/answer/7126229)
- [password-store](https://www.passwordstore.org/)