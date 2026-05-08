# 🪟 Windows Setup Guide

> How the Windows package management works in this dotfiles repository.
>
> 🇧🇷 **Português:** Como funciona o gerenciamento de pacotes no Windows neste repositório.

## 📦 Package Managers

These dotfiles support two Windows package managers, running automatically when you execute `chezmoi apply` on a Windows machine.

> 🇧🇷 *Estes dotfiles suportam dois gerenciadores de pacotes para Windows, que são executados automaticamente ao rodar `chezmoi apply` em uma máquina Windows.*

| Manager | Script | Data File |
|---------|--------|-----------|
| **winget** | `run_onchange_before_201-install-winget-packages.ps1.tmpl` | `.chezmoidata/windows/packages.yaml` |
| **Scoop** | `run_onchange_before_202-install-scoop-packages.ps1.tmpl` | `.chezmoidata/windows/packages.yaml` |

---

## 🗂️ Data File Structure

All packages are declared in `.chezmoidata/windows/packages.yaml`:

```yaml
packages:
  windows:
    winget:
      - Microsoft.WindowsTerminal
      - Git.Git
      - Starship.Starship
      # ...add more winget IDs here

    scoop:
      buckets:
        - main
        - extras
        - nerd-fonts
      packages:
        - main/age
        - main/gnupg
        - extras/lazygit
        - nerd-fonts/JetBrainsMono-NF
        # ...add more scoop packages here
```

> 🇧🇷 *Todos os pacotes são declarados em `.chezmoidata/windows/packages.yaml`.*

---

## 🔍 How to Find Package IDs

### winget
```powershell
# Search for a package
winget search <name>

# Example
winget search firefox
```

### Scoop
```powershell
# Search for a package
scoop search <name>

# Example
scoop search delta
```

---

## 🔄 Comparison With Linux/macOS

The Windows implementation follows the exact same pattern as the other platforms:

| Platform | Manager | Data Key | Script |
|----------|---------|----------|--------|
| **macOS** | Homebrew | `packages.homebrew` | `darwin/run_onchange_after_502-*` |
| **macOS** | MacPorts | `packages.macports` | `darwin/run_onchange_after_501-*` |
| **Linux (Arch)** | pacman / paru | `packages.linux.arch` | `linux/run_onchange_before_201-*` |
| **Linux (Ubuntu)** | apt | `packages.linux.ubuntu` | `linux/run_onchange_before_202-*` |
| **Windows** | **winget** | `packages.windows.winget` | `windows/run_onchange_before_201-*` |
| **Windows** | **Scoop** | `packages.windows.scoop` | `windows/run_onchange_before_202-*` |

---

## ⚙️ How It Works

### winget script
1. Checks if `winget` is installed (requires **App Installer** from the Microsoft Store).
2. Updates winget sources.
3. Iterates over `packages.windows.winget` and installs each package if not already present.
4. Script is re-run by chezmoi whenever the data file changes (`run_onchange_`).

### Scoop script
1. Auto-installs Scoop if not found.
2. Adds the configured **buckets** (e.g., `extras`, `nerd-fonts`).
3. Installs each package listed under `packages.windows.scoop.packages`.
4. Supports bucket-prefixed format: `"extras/lazygit"` → scoop bucket `extras`, package `lazygit`.

---

## 🚀 Quick Start (Windows)

```powershell
# 1. Install chezmoi
winget install twpayne.chezmoi

# 2. Initialize from your repo
chezmoi init --apply https://github.com/<your-username>/dotfiles
```

> 🇧🇷 *`chezmoi apply` vai detectar que você está no Windows e executar automaticamente os scripts winget e Scoop.*

*[← Back to README](../README.md)*
