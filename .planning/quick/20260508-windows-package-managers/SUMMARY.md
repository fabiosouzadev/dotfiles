---
slug: windows-package-managers
status: complete
---

# Quick Task Summary: Windows Package Managers

## What was done
1. **Expandido `.chezmoidata/windows/packages.yaml`** — Preenchemos a lista de pacotes winget (30+ apps) e scoop (buckets + packages), seguindo os mesmos padrões das listas Linux e macOS.
2. **Criado `run_onchange_before_201-install-winget-packages.ps1.tmpl`** — Script PowerShell que lê `packages.windows.winget` e instala via `winget`, com verificação de instalação prévia.
3. **Criado `run_onchange_before_202-install-scoop-packages.ps1.tmpl`** — Script PowerShell que auto-instala o Scoop se necessário, configura buckets e instala pacotes com suporte ao formato `bucket/package`.
4. **Removidos os `.sh.tmpl` vazios** — Substituídos pelos `.ps1.tmpl` corretos para PowerShell.
5. **Criado `docs/WINDOWS-SETUP.md`** — Documentação bilíngue explicando o funcionamento do suporte Windows, tabela comparativa com Linux/macOS, e guia para encontrar IDs de pacotes.

## Key Design Decisions
- Chezmoi já isola os scripts na pasta `windows/` automaticamente para rodar apenas no Windows.
- O formato `run_onchange_` garante que os scripts rodam toda vez que o `packages.yaml` muda.
- O hash `{{ .packages.windows.* | toJson | sha256sum }}` no header do script é o mecanismo que o chezmoi usa para detectar mudanças.
- Suporte ao formato `bucket/package` do Scoop (ex: `extras/lazygit`).
