# Configuração Gmail - Contas Pessoal e Zup

## Visão Geral

Esta skill configura **duas contas Gmail** no Himalaya:
1. **Pessoal**: `fabiovanderlei.developer@gmail.com` (padrão)
2. **Zup (Corporativo)**: `fabio.vanderlei@zup.com.br`

Ambas usam **App Passwords** do Google armazenadas no `pass` (password-store).

---

## 1. Gerar App Passwords

### Pré-requisitos
- Conta Google com **2FA ativado**
- Acesso a: https://myaccount.google.com/apppasswords

### Criar App Passwords

#### Para conta Pessoal
1. Acesse: https://myaccount.google.com/apppasswords
2. Selecione "Mail" / "Outro (nome personalizado)"
3. Nome: **Himalaya Pessoal**
4. Clique "Criar"
5. **Copie a senha de 16 caracteres** (ex: `abcd efgh ijkl mnop`)

#### Para conta Zup
1. Mesmo processo, mas logado na conta `fabio.vanderlei@zup.com.br`
2. Nome: **Himalaya Zup**
3. Copie a senha de 16 caracteres

> ⚠️ **Importante**: App Passwords **expiram** se você trocar a senha principal ou desativar 2FA. Rotacione a cada 90 dias.

---

## 2. Armazenar no `pass` (password-store)

```bash
# Instalar pass (se necessário)
sudo apt-get update && sudo apt-get install -y pass gnupg2

# Inicializar (primeira vez)
pass init "seu-email@gmail.com"

# Salvar App Password Pessoal
pass insert gmail/himalaya-pessoal
# Cole a senha quando pedir (Ctrl+Shift+V ou botão direito)

# Salvar App Password Zup
pass insert gmail/himalaya-zup
# Cole a senha

# Verificar
pass show gmail/himalaya-pessoal
pass show gmail/himalaya-zup
```

---

## 3. Config.toml Completo

Local: `~/.config/himalaya/config.toml`

```toml
# ===========================================
# CONTA PESSOAL (Gmail) - DEFAULT
# ===========================================
[accounts.pessoal]
email = "fabiovanderlei.developer@gmail.com"
display-name = "Fábio Souza"
default = true

# IMAP - Receber emails
backend.type = "imap"
backend.server = "imap.gmail.com"
backend.port = 993
backend.tls = true
backend.login = "fabiovanderlei.developer@gmail.com"
backend.auth_type = "password"
backend.auth_cmd = "pass show gmail/himalaya-pessoal"

# SMTP - Enviar emails
message.send.backend.type = "smtp"
message.send.backend.server = "smtp.gmail.com"
message.send.backend.port = 465
message.send.backend.tls = true
message.send.backend.login = "fabiovanderlei.developer@gmail.com"
message.send.backend.auth_type = "password"
message.send.backend.auth_cmd = "pass show gmail/himalaya-pessoal"

# Aliases de pastas Gmail (OBRIGATÓRIO - plural!)
folder.aliases.inbox = "INBOX"
folder.aliases.sent = "[Gmail]/Sent Mail"
folder.aliases.drafts = "[Gmail]/Drafts"
folder.aliases.trash = "[Gmail]/Trash"
folder.aliases.archive = "[Gmail]/All Mail"

# ===========================================
# CONTA ZUP (Gmail Corporativo)
# ===========================================
[accounts.zup]
email = "fabio.vanderlei@zup.com.br"
display-name = "Fábio Souza (Zup)"

# IMAP
backend.type = "imap"
backend.server = "imap.gmail.com"
backend.port = 993
backend.tls = true
backend.login = "fabio.vanderlei@zup.com.br"
backend.auth_type = "password"
backend.auth_cmd = "pass show gmail/himalaya-zup"

# SMTP
message.send.backend.type = "smtp"
message.send.backend.server = "smtp.gmail.com"
message.send.backend.port = 465
message.send.backend.tls = true
message.send.backend.login = "fabio.vanderlei@zup.com.br"
message.send.backend.auth_type = "password"
message.send.backend.auth_cmd = "pass show gmail/himalaya-zup"

# Aliases de pastas
folder.aliases.inbox = "INBOX"
folder.aliases.sent = "[Gmail]/Sent Mail"
folder.aliases.drafts = "[Gmail]/Drafts"
folder.aliases.trash = "[Gmail]/Trash"
folder.aliases.archive = "[Gmail]/All Mail"
```

---

## 4. Testar Configuração

```bash
# 1. Listar contas
himalaya account list
# Deve mostrar: pessoal (default) e zup

# 2. Testar IMAP (pessoal)
himalaya --account pessoal envelope list --page-size 3

# 3. Testar IMAP (zup)
himalaya --account zup envelope list --page-size 3

# 4. Enviar teste (pessoal → pessoal)
cat << 'EOF' | himalaya --account pessoal message write
To: fabiovanderlei.developer@gmail.com
Subject: ✅ Teste Himalaya Pessoal

Teste de envio da conta pessoal via skill productivity/himalaya-email
EOF

# 5. Enviar teste (zup → zup)
cat << 'EOF' | himalaya --account zup message write
To: fabio.vanderlei@zup.com.br
Subject: ✅ Teste Himalaya Zup

Teste de envio da conta corporativa Zup via skill productivity/himalaya-email
EOF

# 6. Verificar enviados
himalaya --account pessoal envelope list --mailbox "[Gmail]/Sent Mail" --page-size 2
himalaya --account zup envelope list --mailbox "[Gmail]/Sent Mail" --page-size 2
```

---

## 5. Trocar Conta Padrão

```bash
# Temporário (uma vez)
himalaya --account zup envelope list

# Permanente (editar config.toml)
# Mude: default = true para [accounts.zup]
# E remova default = true de [accounts.pessoal]
```

---

## 6. Segurança

| Item | Recomendação |
|------|--------------|
| App Passwords | Rotacione a cada 90 dias |
| `pass` | Use GPG forte (RSA 4096 ou Ed25519) |
| `config.toml` | Permissões 600 (`chmod 600 ~/.config/himalaya/config.toml`) |
| Backup | `pass git init` + push para repo privado criptografado |
| Logs | Não logue emails completos (apenas IDs/metadados) |

---

## 7. Referências

- [Gmail IMAP Settings](https://support.google.com/mail/answer/7126229)
- [Gmail SMTP Settings](https://support.google.com/mail/answer/7126229)
- [Google App Passwords](https://myaccount.google.com/apppasswords)
- [password-store](https://www.passwordstore.org/)

---

## 8. Opção: Senha via `.env` (Alternativa ao `pass`)

Se preferir não usar `pass`, pode armazenar a App Password no `.env` do Hermes:

### 1. Adicionar no `/opt/data/.env`
```bash
GMAIL_APP_PASSWORD=vrhm aagq frws zcrn
GMAIL_ZUP_APP_PASSWORD=senha_zup_aqui
```

### 2. Config.toml usando `auth_cmd` para ler do `.env`
```toml
[accounts.gmail]
default = true
email = "fabiovanderlei.developer@gmail.com"
display-name = "Fábio Souza"

imap.server = "imaps://imap.gmail.com:993"
imap.sasl.plain.username = "fabiovanderlei.developer@gmail.com"
imap.sasl.plain.password.cmd = "grep '^GMAIL_APP_PASSWORD=' /opt/data/.env | cut -d'=' -f2-"

smtp.server = "smtps://smtp.gmail.com:465"
smtp.sasl.plain.username = "fabiovanderlei.developer@gmail.com"
smtp.sasl.plain.password.cmd = "grep '^GMAIL_APP_PASSWORD=' /opt/data/.env | cut -d'=' -f2-"

mailbox.alias.inbox = "INBOX"
mailbox.alias.sent = "[Gmail]/Sent Mail"
mailbox.alias.drafts = "[Gmail]/Drafts"
mailbox.alias.trash = "[Gmail]/Trash"
mailbox.alias.archive = "[Gmail]/All Mail"
```

> ✅ **Testado e funcionando** (2026-07-30): IMAP + SMTP + Sent Mail salvando corretamente.
- [password-store](https://www.passwordstore.org/)