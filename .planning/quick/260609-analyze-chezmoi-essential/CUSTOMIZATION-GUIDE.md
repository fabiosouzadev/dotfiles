# Guia de Customização dos Dotfiles

**Data:** 2026-06-09
**Objetivo:** Como instalar apenas o que você realmente precisa

---

## Visão Geral

O sistema de dotfiles usa **feature flags** e **templates** para controlar o que é instalado. Você pode customizar em 3 níveis:

1. **Feature flags** - Controle macro (AI tools, window managers, etc)
2. **.chezmoiignore** - Ignorar scripts específicos
3. **Editing data files** - Remover pacotes específicos

---

## Nível 1: Feature Flags (Recomendado)

Edite `~/.config/chezmoi/chezmoi.yaml`:

```yaml
data:
  features:
    # === AI TOOLS ===
    ai:
      coding_assistants: true   # opencode, copilot, claude, etc
      gsd: true                 # Get Shit Done
      hermes:
        install: true           # Hermes Agent
      ollama:
        install: true           # Ollama (LLM local)
        localmodels: false      # Baixar modelos automaticamente
        mode: "user"            # "user" ou "system"
      openclaw:
        install: false          # OpenClaw
      spec_tools: true          # openspec, get-shit-done

    # === WINDOW MANAGERS ===
    i3:
      enabled: true             # i3 window manager
    niri:
      enabled: true             # Niri (Wayland)

    # === OUTROS ===
    kernels:
      install: false            # Kernels Linux extras
    personal_repos: true        # Clonar repos pessoais
    rtl8821ce:
      install: false            # Driver WiFi RTL8821CE
    runtime:
      background_services: true # Serviços em background
    systemd:
      enabled: false            # Systemd (Linux)
```

### Exemplos de Configuração

#### Setup Mínimo (só produtividade básica)
```yaml
data:
  features:
    ai:
      coding_assistants: false
      gsd: false
      hermes:
        install: false
      ollama:
        install: false
      spec_tools: false
    personal_repos: false
```

#### Setup Developer (com AI tools)
```yaml
data:
  features:
    ai:
      coding_assistants: true
      gsd: true
      hermes:
        install: true
      ollama:
        install: true
      spec_tools: true
    personal_repos: true
```

#### Setup Mínimo Linux (só ferramentas essenciais)
```yaml
data:
  features:
    i3:
      enabled: false
    niri:
      enabled: false
    kernels:
      install: false
    rtl8821ce:
      install: false
```

---

## Nível 2: .chezmoiignore (Ignorar Scripts Específicos)

Crie `~/.local/share/chezmoi/.chezmoiignore`:

```
# Formato: um padrão por linha
# Usa gitignore syntax

# === IGNORAR AI TOOLS ===
home/.chezmoiscripts/unix/run_once_after_510-install-ai-tools.sh.tmpl
home/.chezmoiscripts/unix/run_once_after_512-install-hermes.sh.tmpl
home/.chezmoiscripts/unix/run_once_after_523-install-gsd.sh.tmpl
home/.chezmoiscripts/darwin/run_once_after_504-install-ollama-darwin.sh.tmpl

# === IGNORAR IDEs ===
home/.chezmoiscripts/darwin/run_once_after_530-install-idea-community.sh.tmpl
home/.chezmoiscripts/unix/run_once_after_524-install-cursor-cli.sh.tmpl

# === IGNORAR GIT CLIs EXTRAS ===
home/.chezmoiscripts/unix/run_once_after_528-install-glab.sh.tmpl
home/.chezmoiscripts/unix/run_once_after_515-install-coderabbit-cli.sh.tmpl

# === IGNORAR COMPILAÇÃO ===
home/.chezmoiscripts/darwin/run_once_before_225-compile-tmux.sh.tmpl

# === IGNORAR FERRAMENTAS OPCIONAIS ===
home/.chezmoiscripts/unix/run_once_after_531-install-wakatime-cli.sh.tmpl
home/.chezmoiscripts/unix/run_once_after_521-install-speckit-github-cli.sh.tmpl
```

### Padrões Úteis

```gitignore
# Ignorar todos os scripts AI
home/.chezmoiscripts/**/run_once_after_51*.sh.tmpl
home/.chezmoiscripts/**/run_once_after_52*.sh.tmpl

# Ignorar scripts Linux-only
home/.chezmoiscripts/linux/**

# Ignorar scripts de compilação
home/.chezmoiscripts/**/run_once_before_22*.sh.tmpl
```

---

## Nível 3: Editing Data Files (Avançado)

Edite os arquivos de dados para remover pacotes específicos:

### macOS - Homebrew
Edite `home/.chezmoidata/darwin/packages.toml`:

```toml
[packages.homebrew]
brew = [
    'lazygit',
    'lazyjournal',
    'atuin'
    # Remova o que não precisa
]

cask = [
    # Apps essenciais
    'bitwarden',
    'spotify',
    'visual-studio-code',
    'kitty',
    'raycast',
    # Remova o resto
]
```

### Linux - Arch
Edite `home/.chezmoidata/linux/packages/archlinux.yaml`:

```yaml
packages:
  linux:
    arch:
      core:
        - gzip
        - make
        - tar
      extra:
        - bat
        - eza
        - fd
        - git
        - htop
        - jq
        - lazygit
        - ripgrep
        # Remova o resto
```

### AI Tools
Edite `home/.chezmoidata/ai_tools.yaml`:

```yaml
ai_tools:
  npm:
    - name: opencode
      package: "opencode-ai"
      feature_flag: coding_assistants
    # Remova outros que não usa
  curl:
    - name: claude
      url: "https://claude.ai/install.sh"
      shell: bash
      feature_flag: coding_assistants
    # Remova outros que não usa
```

---

## Comandos Úteis

```bash
# Ver o que seria instalado (dry run)
chezmoi apply --dry-run

# Aplicar mudanças
chezmoi apply

# Forçar reaplicação de um script específico
chezmoi apply --force --include scripts

# Ver diff antes de aplicar
chezmoi diff

# Verificar arquivos gerenciados
chezmoi managed

# Verificar arquivos não gerenciados
chezmoi unmanaged
```

---

## Fluxo de Trabalho Recomendado

1. **Primeira vez:** Use o setup padrão (tudo habilitado)
2. **Após 1 semana:** Identifique o que não usa
3. **Desabilite:** Via feature flags ou .chezmoiignore
4. **Refine:** Edite data files para remover pacotes específicos
5. **Documente:** Adicione suas preferências no .chezmoiignore

---

## Solução de Problemas

### "Script não está rodando"
- Verifique se está no .chezmoiignore
- Verifique se a feature flag está habilitada
- Rode `chezmoi apply --verbose` para ver detalhes

### "Quero remover um pacote já instalado"
- Remova do data file
- Rode `chezmoi apply`
- O pacote NÃO será desinstalado automaticamente
- Desinstale manualmente: `brew uninstall <pacote>` ou `pacman -R <pacote>`

### "Mudei de ideia, quero restaurar"
- Remova a linha do .chezmoiignore
- Rode `chezmoi apply`

---

*Guia gerado em 2026-06-09*
