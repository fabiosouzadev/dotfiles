# 🏠 fabiosouzadev/dotfiles

![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=flat-square&logo=ubuntu&logoColor=white)
![WSL](https://img.shields.io/badge/WSL-0078D4?style=flat-square&logo=windows&logoColor=white)
![Arch Linux](https://img.shields.io/badge/Arch-1793D1?style=flat-square&logo=arch-linux&logoColor=white)
![macOS](https://img.shields.io/badge/macOS-000000?style=flat-square&logo=apple&logoColor=white)
![Shell](https://img.shields.io/badge/shell-zsh-green?style=flat-square)
![chezmoi](https://img.shields.io/badge/chezmoi-managed-blue?style=flat-square)

Repositório de dotfiles gerenciado pelo [chezmoi](https://chezmoi.io), focado em reprodutibilidade, versionamento de configurações e bootstrap limpo de máquinas.  
O objetivo não é apenas manter arquivos de configuração, mas representar um ambiente de operação completo: shell, editor, terminal, ferramentas modernas, segredos criptografados, integração com IA local/remota e fluxos de sincronização.

> 🇧🇷 **Português:** Repositório pessoal de dotfiles, automações e infraestrutura local.  
> Repositório completo em `~/.local/share/chezmoi`.

---

## 🚀 Quick Start

### Ubuntu / WSL
```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin" init --apply fabiosouzadev
```

### Arch Linux
```bash
sudo pacman -S chezmoi
chezmoi init --apply fabiosouzadev
```

> ⚠️ Arquivos criptografados dependem da sua própria chave `age`.  
> Se for fork, gere uma nova chave e reencode os segredos antes de aplicar.

---

## 📋 Pré-requisitos

| Requisito | Motivo |
|-----------|--------|
| **git** | Clonar e versionar o repo |
| **chezmoi** | Gerenciar dotfiles de forma segura e reprodutível |
| **age** | Proteger segredos com criptografia moderna |
| **Nerd Font** | Ícones no terminal para `eza`, `yazi`, `starship`, etc. |

---

## 🏗️ O que este repositório representa

Ele não é apenas “alguns arquivos de shell”.  
Ele codifica:

- ambiente de shell modular com **zinit** e aliases versionados
- editor e multiplexor de terminal configurados
- ferramentas CLI modernas e suas configurações
- segredos criptografados com **age** e gerenciados via **chezmoi**
- integração com ferramentas de IA mediante gateway local (**OmniRoute**) e assistente pessoal (**Hermes**)
- scripts生命周期 por OS, incluindo instalação de pacotes, fontes, drivers e serviços
- fluxos de backup/restore seletivos para estado sensível, sem poluir o Git com histórico grande

---

## 📂 Estrutura

```
.
├── home/
│   ├── .chezmoi.yaml.tmpl                 # Detecção de SO e perfis
│   ├── .chezmoidata/                      # Pacotes por plataforma
│   │   ├── darwin/linux/windows/termux
│   ├── .chezmoiexternals/                 # Dependências externas
│   ├── .chezmoiscripts/                   # Hooks e bootstrap
│   │   ├── darwin/linux/unix/windows/termux
│   ├── .chezmoitemplates/                 # Guards/templates reutilizaveis
│   ├── dot_zshrc.d/                       # Zsh modular
│   ├── private_dot_config/                # Configs de apps
│   ├── private_dot_ssh/                   # Chaves e configs SSH
│   ├── private_dot_hermes/                # Estado criptografado do Hermes
│   ├── dot_omniroute/                     # Estado criptografado do OmniRoute
│   └── ...
├── docs/
│   ├── ARCHITECTURE.md
│   ├── CONFIGURATION.md
│   ├── GETTING-STARTED.md
│   ├── DEVELOPMENT.md
│   ├── HERMES-BACKUP.md
│   ├── OMNIROUTE-BACKUP.md
│   ├── KEYMAPS.md
│   ├── FORK-GUIDE.md
│   └── WINDOWS-SETUP.md
├── .planning/
└── README.md
```

---

## 🤖 Integrações: Hermes e OmniRoute

### Hermes
- Orquestra skills/memórias e automações pessoais.
- Estado criptografado versionado via `hermes-sync`.
- Documentação do modelo: `docs/HERMES-BACKUP.md`.

### OmniRoute
- Gateway local/remoto de IA para os agentes de código e chat.
- Config e segredos versionados de forma seletiva.
- Documentação do modelo: `docs/OMNIROUTE-BACKUP.md`.

---

## 🔐 O que entra e o que fica fora

**Entra no repo:**
- configurações estáveis e pequenas
- templates e scripts de bootstrap
- estado sensencial criptografado
- manifests/SQL seletivo

**Fica fora:**
- históricos grandes, caches, runtime state, logs e blobs binários
- estratégias de backup completo devem ser tratadas externamente

---

## 📖 Documentação

- `docs/GETTING-STARTED.md` — instalação detalhada
- `docs/ARCHITECTURE.md` — visão geral do ambiente e fluxos
- `docs/CONFIGURATION.md` — variáveis e ajustes
- `docs/DEVELOPMENT.md` — como contribuir no repo
- `docs/TESTING.md` — smoke checks úteis
- `docs/KEYMAPS.md` — atalhos tmux/nvim/zsh
- `docs/FORK-GUIDE.md` — como fork sem herdar segredos

---

## 🍴 Fork

Se quiser adaptar este ambiente para outro perfil/cliente/máquina:
- use `docs/FORK-GUIDE.md`
- gere seu próprio par de chaves `age`
- revise scripts e perfis antes de aplicar em produção

---

## 🙏 Créditos

- [chezmoi](https://chezmoi.io) — gerenciamento de dotfiles
- [zinit](https://github.com/zdharma-continuum/zinit) — plugins ZSH
- [starship](https://starship.rs) — prompt minimal
- [mise](https://mise.jdx.dev) — versionamento de runtime
- [age](https://age-encryption.org) — criptografia simples e moderna
- [Tailscale](https://tailscale.com) — VPN ponto a ponto
- **OmniRoute** — gateway de IA
- **Hermes Agent** — assistente pessoal

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/fabiosouzadev">@fabiosouzadev</a>
</p>
