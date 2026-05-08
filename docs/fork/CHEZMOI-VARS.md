# ⚙️ Chezmoi Variables Guide

> How to configure `.chezmoi.yaml.tmpl` and `.chezmoidata/` for your own environment.
> 
> 🇧🇷 **Português:** Como configurar `.chezmoi.yaml.tmpl` e `.chezmoidata/` para o seu próprio ambiente.

This repository uses Chezmoi templates. When you run `chezmoi init`, it generates a `~/.config/chezmoi/chezmoi.yaml` configuration file based on the template. Here is what you need to change.
> 🇧🇷 *Este repositório usa templates do Chezmoi. Quando você roda `chezmoi init`, ele gera um arquivo de configuração `~/.config/chezmoi/chezmoi.yaml` baseado no template. Aqui está o que você precisa alterar.*

---

## 1. `home/.chezmoi.yaml.tmpl`

This is the most important file for adapting the dotfiles. You **must** open it in your fork and modify the personal variables at the top:
> 🇧🇷 *Este é o arquivo mais importante para adaptar os dotfiles. Você **deve** abri-lo no seu fork e modificar as variáveis pessoais no topo:*

```yaml
data:
  # 🔴 CHANGE THESE TO YOUR OWN INFO / MUDE PARA SUAS INFORMAÇÕES
  email: "your.email@example.com"
  signingkey: "YOUR_GPG_KEY_ID"
```

These variables are used to automatically template your `~/.gitconfig` and other files. If you don't change them, your git commits will use my email!
> 🇧🇷 *Essas variáveis são usadas para gerar automaticamente o seu `~/.gitconfig` e outros arquivos. Se você não alterá-las, seus commits do git usarão meu email!*

---

## 2. `.chezmoidata/repos.json`

This file contains a list of Git repositories that are automatically cloned when you set up your machine.
> 🇧🇷 *Este arquivo contém uma lista de repositórios Git que são clonados automaticamente quando você configura sua máquina.*

You should edit `home/.chezmoidata/repos.json` to include your own personal and work repositories:
> 🇧🇷 *Você deve editar `home/.chezmoidata/repos.json` para incluir seus próprios repositórios pessoais e de trabalho:*

```json
{
  "personal_repos": [
    "git@github.com:yourusername/your-project.git"
  ],
  "work_repos": [
    "git@github.com:yourcompany/work-project.git"
  ]
}
```

---

## 3. Package Management (OS Specifics)

This repository automatically installs packages based on your Operating System (macOS, Arch Linux, or Ubuntu). The lists of packages are stored in the `.chezmoidata/` folder:
> 🇧🇷 *Este repositório instala pacotes automaticamente baseado no seu Sistema Operacional. As listas de pacotes são armazenadas na pasta `.chezmoidata/`:*

- `packages_darwin.yaml` (macOS Homebrew)
- `packages_archlinux.yaml` (Arch Linux pacman)
- `packages_ubuntu.yaml` (Ubuntu apt)

If you want to add or remove default software from your fork, simply edit these files!
> 🇧🇷 *Se você quiser adicionar ou remover softwares padrão do seu fork, simplesmente edite estes arquivos!*

---

*[← Back to Fork Guide](../FORK-GUIDE.md)*
