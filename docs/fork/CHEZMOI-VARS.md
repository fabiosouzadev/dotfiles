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

## 4. AI Features (`features.ai`)

This repository includes a robust AI development environment. You can enable or disable specific AI tools in `.chezmoi.yaml.tmpl`:

```yaml
features:
  ai:
    coding_assistants: true  # Aider, Claude Code, Copilot, etc.
    spec_tools: true         # OpenSpec, SpecKit, etc.
    gsd: true                # Get Shit Done (GSD) workflow tools
    ollama:
      install: true          # Local AI inference
      mode: "user"           # user, root, or compile
      localmodels: false     # Auto-pull models defined in ollama.yaml
    openclaw:
      install: false         # OpenClaw assistant
```

- **Coding Assistants**: Installs CLI tools like `aider`, `claude-code`, and `copilot`.
- **Ollama**: If `install` is true, it sets up Ollama. The `mode` determines if it's installed via script (`user`), system-wide (`root`), or compiled from source.
- **Local Models**: If `localmodels` is true, it will automatically pull the models listed in `home/.chezmoidata/ollama.yaml`.

---

## 5. Hardcoded Hostnames & Hardware Detection

The `.chezmoi.yaml.tmpl` uses hostname matching to detect specific machines. **If you fork this repo, you must update these values:**

```yaml
# Work machine detection (managed profile)
$ismanaged := ($hostLower | contains "zwpe0f96cn")

# Hardware-specific optimizations
$dell3530 := ($hostLower | contains "dell3530")
$dell3520 := ($hostLower | contains "dell3520")
```

- **`zwpe0f96cn`**: Hostname pattern for the author's corporate laptop. When matched, enables the `work` profile and disables `sudo`/`systemd` features.
- **`dell3530` / `dell3520`**: Hostname patterns for specific Dell laptops. When matched, enables hardware-specific features like Ollama compile mode and the RTL8821CE Wi-Fi driver.

Replace these with your own hostname patterns, or remove the hardware-specific blocks if not needed.

---

*[← Back to Fork Guide](../FORK-GUIDE.md)*
