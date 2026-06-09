# Análise de Scripts do Chezmoi - O que é Realmente Necessário

**Data:** 2026-06-09
**Plataforma atual:** macOS (darwin)
**Features habilitadas:** AI tools, i3, niri, personal_repos

---

## Resumo Executivo

O repositório possui **40+ scripts** de instalação. Para um setup macOS mínimo, apenas **3 scripts são essenciais**. O resto são nice-to-have ou opcionais.

---

## Scripts Essenciais (sempre executam)

Estes scripts são necessários para qualquer funcionamento básico:

| Script | Descrição | Por que é essencial |
|--------|-----------|---------------------|
| `run_onchange_after_502-install-darwin-packages-homebrew.sh.tmpl` | Instala Homebrew e todos os pacotes brew/cask | Core do sistema de pacotes macOS |
| `run_onchange_after_501-install-darwin-packages-macports.sh.tmpl` | Instala pacotes via Macports | Complementa Homebrew para pacotes específicos |
| `run_once_after_503-install-mise.sh.tmpl` | Instala Mise (version manager) | Gerencia versões de linguagens (Node, Python, etc) |

**Total: 3 scripts**

---

## Scripts Nice-to-have (melhoram experiência)

Estes melhoram a produtividade mas não são estritamente necessários:

| Script | Descrição | Vale a pena? |
|--------|-----------|--------------|
| `run_once_after_529-install-lazygit.sh.tmpl` | Lazygit - TUI para git | Sim, se usa git frequentemente |
| `run_once_after_530-install-atuin.sh.tmpl` | Atuin - Histórico de shell mágico | Sim, para quem usa muito terminal |

**Total: 2 scripts**

---

## Scripts Opcionais (feature flags ou específicos)

Estes só devem ser instalados se você realmente usa a funcionalidade:

### AI Tools (feature flag: `ai.coding_assistants`)
| Script | Descrição | Quando instalar |
|--------|-----------|-----------------|
| `run_once_after_510-install-ai-tools.sh.tmpl` | Ferramentas AI (opencode, copilot, etc) | Se usa assistentes de código |
| `run_once_after_504-install-ollama-darwin.sh.tmpl` | Ollama - LLM local | Se quer rodar LLMs localmente |
| `run_once_after_512-install-hermes.sh.tmpl` | Hermes Agent | Se usa Hermes |
| `run_once_after_523-install-gsd.sh.tmpl` | GSD (Get Shit Done) | Se usa GSD workflow |

### Spec Tools (feature flag: `ai.spec_tools`)
| Script | Descrição | Quando instalar |
|--------|-----------|-----------------|
| `run_once_after_521-install-speckit-github-cli.sh.tmpl` | Spec tools GitHub CLI | Se usa spec tools |

### IDEs e Editores
| Script | Descrição | Quando instalar |
|--------|-----------|-----------------|
| `run_once_after_530-install-idea-community.sh.tmpl` | IntelliJ IDEA Community | Se usa IntelliJ |
| `run_once_after_524-install-cursor-cli.sh.tmpl` | Cursor CLI | Se usa Cursor |

### Git CLIs
| Script | Descrição | Quando instalar |
|--------|-----------|-----------------|
| `run_once_after_528-install-glab.sh.tmpl` | GitLab CLI (glab) | Se usa GitLab |
| `run_once_after_515-install-coderabbit-cli.sh.tmpl` | CodeRabbit CLI | Se usa CodeRabbit |

### Outros
| Script | Descrição | Quando instalar |
|--------|-----------|-----------------|
| `run_once_after_531-install-wakatime-cli.sh.tmpl` | WakaTime - Trackamento de tempo | Se quer trackar tempo de coding |
| `run_once_before_225-compile-tmux.sh.tmpl` | Compilar tmux do fonte | Se precisa de versão específica do tmux |

**Total: 12 scripts opcionais**

---

## Scripts Linux-only (não executam no macOS)

Estes scripts só rodam em Linux e são ignorados no macOS:

| Categoria | Scripts | Exemplos |
|-----------|---------|----------|
| **Arch Linux** | 15+ | Pacotes pacman, paru, drivers |
| **Ubuntu** | 5+ | Pacotes apt, PPAs |
| **Drivers** | 3 | RTL8821CE, Cirrus, etc |
| **Window Managers** | 2 | i3, Niri |
| **DevOps** | 3 | Docker, Podman, k9s |
| **Virtualização** | 1 | QEMU, libvirt |
| **VPS/Server** | 3 | Caddy, Tailscale, services |
| **Compilação** | 2 | Neovim, tmux from source |

**Total: ~35 scripts Linux-only**

---

## Como Customizar a Instalação

### Opção 1: Desabilitar features via chezmoi.yaml

Edite `~/.config/chezmoi/chezmoi.yaml`:

```yaml
data:
  features:
    ai:
      coding_assistants: false  # Desabilita AI tools
      gsd: false                # Desabilita GSD
      hermes:
        install: false          # Desabilita Hermes
      ollama:
        install: false          # Desabilita Ollama
      spec_tools: false         # Desabilita spec tools
    personal_repos: false       # Não clonar repos pessoais
```

### Opção 2: Criar .chezmoiignore

Crie `~/.local/share/chezmoi/.chezmoiignore` para ignorar scripts específicos:

```
# Ignorar AI tools
home/.chezmoiscripts/unix/run_once_after_510-install-ai-tools.sh.tmpl
home/.chezmoiscripts/unix/run_once_after_512-install-hermes.sh.tmpl
home/.chezmoiscripts/unix/run_once_after_523-install-gsd.sh.tmpl
home/.chezmoiscripts/darwin/run_once_after_504-install-ollama-darwin.sh.tmpl

# Ignorar IDEs
home/.chezmoiscripts/darwin/run_once_after_530-install-idea-community.sh.tmpl
home/.chezmoiscripts/unix/run_once_after_524-install-cursor-cli.sh.tmpl

# Ignorar Git CLIs extras
home/.chezmoiscripts/unix/run_once_after_528-install-glab.sh.tmpl
home/.chezmoiscripts/unix/run_once_after_515-install-coderabbit-cli.sh.tmpl

# Ignorar compilação de tmux
home/.chezmoiscripts/darwin/run_once_before_225-compile-tmux.sh.tmpl
```

### Opção 3: Modo mínimo (só essenciais)

Para instalar apenas o mínimo:

1. Desabilite todas as features AI
2. Crie .chezmoiignore para scripts opcionais
3. Mantenha apenas:
   - Homebrew packages
   - Macports packages
   - Mise

---

## Recomendação Final

Para um setup **mínimo e funcional**, mantenha apenas:

1. **Homebrew packages** (apps essenciais)
2. **Macports packages** (ferramentas de sistema)
3. **Mise** (version manager)

Adicione gradualmente:
- **Lazygit** - se usa git muito
- **Atuin** - se usa muito terminal
- **AI tools** - se usa assistentes de código

Evite instalar:
- Múltiplos IDEs (escolha 1-2)
- Múltiplos browsers (escolha 1-2)
- Ferramentas de virtualização (se não usa)
- Drivers específicos (se não tem o hardware)

---

*Análise gerada em 2026-06-09*
