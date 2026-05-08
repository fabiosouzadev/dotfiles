---
slug: windows-package-managers
status: complete
---

# Quick Task: Windows Package Managers (winget + scoop)

## Objective
Implementar scripts de instalação de pacotes para Windows via `winget` e `scoop`, lendo os dados de `.chezmoidata/windows/packages.yaml` — seguindo o mesmo padrão já utilizado no Arch, Ubuntu e macOS.

## Files Modified
- `home/.chezmoidata/windows/packages.yaml` — Dados de pacotes expandidos
- `home/.chezmoiscripts/windows/run_onchange_before_201-install-winget-packages.ps1.tmpl` — Script winget (PowerShell)
- `home/.chezmoiscripts/windows/run_onchange_before_202-install-scoop-packages.ps1.tmpl` — Script scoop (PowerShell)
- `docs/WINDOWS-SETUP.md` — Documentação sobre o suporte Windows

## Decisions
- Scripts em PowerShell (`.ps1.tmpl`) em vez de bash: o chezmoi no Windows usa PowerShell como shell padrão.
- Os arquivos `.sh.tmpl` vazios pré-existentes foram removidos e substituídos pelos `.ps1.tmpl` corretos.
- A estrutura de dados `packages.windows.winget` e `packages.windows.scoop` já existia no YAML, porém `winget` estava vazio.
- Padrão de guards (`{{ if .packages.windows.winget }}`) idêntico ao dos scripts Linux.
