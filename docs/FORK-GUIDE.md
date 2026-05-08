int# 🍴 Fork & Customize Guide

> How to adapt these dotfiles for your own setup.
> 
> 🇧🇷 **Português:** Como fazer fork e adaptar esses dotfiles para o seu próprio ambiente.

Welcome! If you're forking this repository, you'll need to change a few variables and secrets so it works for you instead of me. This guide acts as your central index.
> 🇧🇷 *Bem-vindo! Se você fez fork deste repositório, precisará alterar algumas variáveis e segredos para que funcione para você e não para mim. Este guia atua como seu índice central.*

## 📋 First Fork Checklist / Checklist do Primeiro Fork

Follow these steps in order after cloning your fork:
> 🇧🇷 *Siga estes passos na ordem após clonar seu fork:*

1. [ ] **Update your variables / Atualize suas variáveis**
   Read the [Chezmoi Variables Guide](fork/CHEZMOI-VARS.md) to update your email, hostname, and git settings.
   > 🇧🇷 *Leia o [Guia de Variáveis do Chezmoi](fork/CHEZMOI-VARS.md) para atualizar seu email, hostname e configurações do git.*

2. [ ] **Handle encrypted files / Lide com arquivos encriptados**
   Read the [Secrets & Encryption Guide](fork/SECRETS-GUIDE.md) to generate your own `age` key and re-encrypt sensitive files.
   > 🇧🇷 *Leia o [Guia de Segredos e Encriptação](fork/SECRETS-GUIDE.md) para gerar sua própria chave `age` e re-encriptar arquivos sensíveis.*

3. [ ] **Apply the changes / Aplique as alterações**
   Once everything is updated, run `chezmoi apply` to apply your personal configuration!
   > 🇧🇷 *Assim que tudo estiver atualizado, rode `chezmoi apply` para aplicar sua configuração pessoal!*

---

## 🎁 What works out-of-the-box? / O que você ganha de graça?

Everything that isn't encrypted or explicitly tied to my email will work automatically! This includes:
> 🇧🇷 *Tudo que não for encriptado ou explicitamente atrelado ao meu email funcionará automaticamente! Isso inclui:*

- **Shell & Terminal:** Zsh plugins, Starship prompt, Wezterm/Kitty configs.
- **CLI Tools:** configurations for `bat`, `delta`, `fzf`, `eza`, `zoxide`.
- **Editor:** Neovim + LazyVim configurations.
- **Window Managers:** Hyprland, i3, and Niri configurations.

*[← Back to README](../README.md)*
