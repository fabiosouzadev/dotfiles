---
phase: 1
plan_id: 01A
title: "README — Estrutura Base, Features e Quick Start"
wave: 1
depends_on: []
files_modified:
  - README.md
  - docs/KEYMAPS.md
  - docs/FORK-GUIDE.md
requirements:
  - DOC-01
  - DOC-02
  - DOC-03
  - DOC-04
  - DOC-05
  - DOC-06
  - DOC-07
autonomous: true
---

# Plan 01A: README — Estrutura Base, Features e Quick Start

## Objective

Reescrever completamente o `README.md` do repositório com identidade visual rica (emojis + badges), visão geral do projeto, lista completa de ferramentas, estrutura de diretórios explicada e comandos de instalação rápida por OS. Criar a pasta `docs/` com stubs para documentação futura (keymaps, fork guide).

## Must-Haves (Goal-Backward Verification)

1. README.md contém badges técnicos no topo (OS, license, chezmoi, zsh)
2. README.md contém seção de visão geral bilíngue (inglês principal)
3. README.md contém lista de features/ferramentas com emojis
4. README.md contém estrutura de diretórios com tree e descrições
5. README.md contém pré-requisitos (chezmoi, age, git)
6. README.md contém one-liner de instalação para macOS, Arch Linux e Ubuntu
7. README.md contém links para docs/ (keymaps, fork guide)
8. Diretório docs/ existe com stubs linkados

## Tasks

<task id="01A-T1" type="execute">
<title>Reescrever README.md completo</title>

<read_first>
- README.md (estado atual — one-liner)
- .planning/codebase/STACK.md (lista de ferramentas e tecnologias)
- .planning/codebase/STRUCTURE.md (estrutura de diretórios)
- .planning/codebase/INTEGRATIONS.md (AI tools e integrações)
- .planning/phases/01-readme-base-quick-start/01-CONTEXT.md (decisões do usuário)
- .planning/research/SUMMARY.md (best practices de README)
</read_first>

<action>
Reescrever `README.md` na raiz do repositório com a seguinte estrutura:

**1. Header com Badges**
```markdown
# 🏠 fabiosouzadev/dotfiles

![macOS](https://img.shields.io/badge/macOS-000000?style=flat-square&logo=apple&logoColor=white)
![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=flat-square&logo=arch-linux&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=flat-square&logo=ubuntu&logoColor=white)
![chezmoi](https://img.shields.io/badge/chezmoi-managed-blue?style=flat-square)
![Shell](https://img.shields.io/badge/shell-zsh-green?style=flat-square&logo=gnu-bash)
![License](https://img.shields.io/github/license/fabiosouzadev/dotfiles?style=flat-square)
```

**2. Descrição (bilíngue)**
Breve parágrafo em inglês descrevendo o que é o repositório.
Nota em português: "🇧🇷 Leia em português" com link para seção pt-br ou nota inline.

**3. 🚀 Quick Start**
One-liners de instalação por OS:
- macOS: `sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin init --apply fabiosouzadev`
- Arch Linux: `pacman -S chezmoi && chezmoi init --apply fabiosouzadev`
- Ubuntu: `sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin init --apply fabiosouzadev`

**4. 📋 Prerequisites / Pré-requisitos**
Lista: git, chezmoi, age (para decryptar segredos), Nerd Font (para ícones no terminal).

**5. 🛠 Features / O que está incluído**
Lista organizada por categoria com emojis:
- 🐚 Shell: Zsh + Zinit + Starship prompt
- ✏️ Editor: Neovim com LazyVim
- 🖥️ Terminal: tmux + Catppuccin Mocha + Navigator.nvim
- 🔧 CLI Tools: eza, bat, fd, fzf, zoxide, lazygit, yazi, delta
- 🤖 AI Tools: Claude Code, Aider, Gemini CLI, OpenCode, Ollama +17
- 📦 Runtime: mise (Java, Node, Go, Python) + Nix/Devenv
- 🔑 Security: age encryption (SSH, GPG, API keys)
- 🪟 WM (Linux): i3, Hyprland, Niri
- 🦊 Browser: Firefox Developer Edition (templated profiles)
- 🔄 Git: GPG signing, delta pager, conditional work includes

**6. 📂 Structure / Estrutura**
Tree simplificada do repo com descrições inline:
```
.
├── home/                    # chezmoi source root (.chezmoiroot)
│   ├── .chezmoiscripts/     # lifecycle hooks (run_once_, run_onchange_)
│   │   ├── darwin/          # macOS-specific scripts
│   │   ├── linux/           # Linux-specific scripts
│   │   └── unix/            # shared scripts
│   ├── dot_config/          # ~/.config/ managed apps
│   ├── dot_zshrc.d/         # modular zsh config (numbered)
│   └── ...
├── docs/                    # detailed documentation
│   ├── KEYMAPS.md           # tmux, neovim, zsh cheatsheets
│   └── FORK-GUIDE.md        # how to fork and customize
└── README.md                # this file
```

**7. ⌨️ Keymaps**
Breve menção com link: "See [docs/KEYMAPS.md](docs/KEYMAPS.md) for tmux, Neovim, and zsh keybinding cheatsheets."

**8. 🍴 Fork Guide**
Breve menção com link: "See [docs/FORK-GUIDE.md](docs/FORK-GUIDE.md) for how to adapt these dotfiles."

**9. 📝 License**
MIT (ou a license que o repo usa atualmente).

**10. 🙏 Acknowledgments**
Credits e inspirações (chezmoi, catppuccin, etc.)
</action>

<acceptance_criteria>
- README.md contém `![macOS]` badge
- README.md contém `![Arch Linux]` badge
- README.md contém `![Ubuntu]` badge
- README.md contém `![chezmoi]` badge
- README.md contém `## 🚀 Quick Start`
- README.md contém `sh -c "$(curl -fsLS get.chezmoi.io)"`
- README.md contém `pacman -S chezmoi`
- README.md contém `## 📋 Prerequisites`
- README.md contém `## 🛠 Features`
- README.md contém `## 📂 Structure`
- README.md contém `docs/KEYMAPS.md`
- README.md contém `docs/FORK-GUIDE.md`
- README.md tem mais de 100 linhas
</acceptance_criteria>
</task>

<task id="01A-T2" type="execute">
<title>Criar docs/ com stubs para Keymaps e Fork Guide</title>

<read_first>
- .planning/phases/01-readme-base-quick-start/01-CONTEXT.md (decisões sobre docs separados)
</read_first>

<action>
Criar diretório `docs/` na raiz do repositório com dois arquivos stub:

**docs/KEYMAPS.md:**
```markdown
# ⌨️ Keymaps & Shortcuts

> Cheatsheets for tmux, Neovim, and zsh keybindings used in this dotfiles setup.

## Contents

- [tmux](#-tmux)
- [Neovim](#-neovim)
- [Zsh](#-zsh)

---

## 🖥️ tmux

> Coming soon — see Phase 3

## ✏️ Neovim

> Coming soon — see Phase 4

## 🐚 Zsh

> Coming soon — see Phase 5

---

*[Back to README](../README.md)*
```

**docs/FORK-GUIDE.md:**
```markdown
# 🍴 Fork & Customize Guide

> How to adapt these dotfiles for your own setup.

## Coming Soon

This guide will cover:
- [ ] Files you need to change (username, email, GPG key)
- [ ] How `.chezmoi.yaml.tmpl` variables work
- [ ] Dealing with encrypted files (age key)
- [ ] How `.chezmoidata/` controls packages per OS
- [ ] First fork checklist

---

*[Back to README](../README.md)*
```
</action>

<acceptance_criteria>
- File `docs/KEYMAPS.md` exists
- File `docs/KEYMAPS.md` contains `# ⌨️ Keymaps`
- File `docs/KEYMAPS.md` contains `## 🖥️ tmux`
- File `docs/FORK-GUIDE.md` exists
- File `docs/FORK-GUIDE.md` contains `# 🍴 Fork`
- File `docs/FORK-GUIDE.md` contains `chezmoi.yaml.tmpl`
</acceptance_criteria>
</task>

## Verification

After completing all tasks:
1. `cat README.md | wc -l` should return > 100
2. `grep -c '##' README.md` should return >= 7 (7+ sections)
3. `test -f docs/KEYMAPS.md && echo OK` should return OK
4. `test -f docs/FORK-GUIDE.md && echo OK` should return OK
5. Visual check: README renders correctly on GitHub with badges, emojis, tree structure
