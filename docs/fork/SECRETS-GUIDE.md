# 🔐 Secrets & Encryption Guide

> Dealing with encrypted files (age key) in your fork.
> 
> 🇧🇷 **Português:** Lidando com arquivos encriptados (chave age) no seu fork.

This repository uses [age encryption](https://age-encryption.org) natively integrated with Chezmoi to securely store sensitive files like SSH keys, API tokens, and VPN certificates in the public GitHub repository.
> 🇧🇷 *Este repositório usa encriptação age nativamente integrada com o Chezmoi para armazenar com segurança arquivos sensíveis como chaves SSH, tokens de API e certificados VPN no repositório público do GitHub.*

## ⚠️ The Problem / O Problema

All files in this repository starting with `encrypted_` are encrypted using **MY** personal public key. This means **they will fail to decrypt on your machine**.
> 🇧🇷 *Todos os arquivos neste repositório que começam com `encrypted_` estão encriptados usando a **MINHA** chave pública pessoal. Isso significa que **eles falharão ao decriptar na sua máquina**.*

Examples of files you won't be able to read:
- `home/private_dot_ssh/encrypted_id_ed25519`
- Any API keys or environment variables that are encrypted.

---

## 🛠️ The Solution / A Solução

To fix this and use encryption for your own secrets, you need to generate your own key and re-encrypt your files. Follow these steps:
> 🇧🇷 *Para corrigir isso e usar a encriptação para os seus próprios segredos, você precisa gerar sua própria chave e re-encriptar seus arquivos. Siga estes passos:*

### 1. Generate your own age key / Gere sua própria chave age

Run the following command to generate a new key pair:
> 🇧🇷 *Rode o seguinte comando para gerar um novo par de chaves:*

```bash
mkdir -p ~/.config/chezmoi
age-keygen -o ~/.config/chezmoi/key.txt
```

This will create a `key.txt` file containing your public and private keys. **Never commit this file to git!**
> 🇧🇷 *Isso criará um arquivo `key.txt` contendo suas chaves pública e privada. **Nunca commite este arquivo no git!***

### 2. Update your recipient / Atualize seu recipiente

Get your **Public Key** from the `key.txt` file (it starts with `age1...`) and update the `recipient` field in your `home/.chezmoi.yaml.tmpl`:
> 🇧🇷 *Pegue a sua **Chave Pública** do arquivo `key.txt` (ela começa com `age1...`) e atualize o campo `recipient` no seu `home/.chezmoi.yaml.tmpl`:*

```yaml
encryption: "age"
age:
  identity: "~/.config/chezmoi/key.txt"
  recipient: "age1YOUR_NEW_PUBLIC_KEY_HERE"
```

### 3. Re-encrypt your own secrets / Re-encripte seus próprios segredos

Now you can delete all my `encrypted_` files from your fork, and add your own securely using Chezmoi:
> 🇧🇷 *Agora você pode deletar todos os meus arquivos `encrypted_` do seu fork, e adicionar os seus próprios com segurança usando o Chezmoi:*

```bash
# Example: Adding your SSH key securely
chezmoi add --encrypt ~/.ssh/id_ed25519
```

Chezmoi will automatically encrypt the file using your new public key and save it as `encrypted_id_ed25519` in the repository!
> 🇧🇷 *O Chezmoi irá automaticamente encriptar o arquivo usando sua nova chave pública e salvá-lo como `encrypted_id_ed25519` no repositório!*

---

*[← Back to Fork Guide](../FORK-GUIDE.md)*
