---
status: complete
---

# Quick Task: install-idea-community — Concluido

## Resultado
Templates chezmoi para Linux, macOS e Windows, todos sem sudo:

- **Feature flag por OS:** `.features.idea.install.{linux,darwin,windows}` — controle independente por SO
- **Workplace filter:** `.features.idea.workplaces` — filtro adicional por ambiente (vazio = todos)
- **Versao:** Auto-detecta via GitHub API ou fixa via `.features.idea.version`
- **Arquitetura:** Auto-detecta x86_64/arm64 em todos os OS
- **Idempotente:** Skipa se ja instalado (comparando versao no macOS)

## Plataformas

| OS | Asset | Instalacao | Binario |
|----|-------|------------|---------|
| Linux | `.tar.gz` | `~/.local/share/idea-ic-<ver>/` | symlink `~/.local/bin/idea` |
| macOS | `.dmg` | `~/Applications/IntelliJ IDEA CE.app` | symlink `~/.local/bin/idea` |
| Windows | `.win.zip` | `%LOCALAPPDATA%\idea-ic-<ver>\` | wrapper `idea.cmd` + atalho desktop |

## Arquivos
- `home/.chezmoidata/idea.yaml` — config (install, version)
- `home/.chezmoiscripts/linux/run_once_after_530-install-idea-community.sh.tmpl`
- `home/.chezmoiscripts/darwin/run_once_after_530-install-idea-community.sh.tmpl`
- `home/.chezmoiscripts/windows/run_once_after_530-install-idea-community.ps1.tmpl`

## Testes
- Sintaxe bash validada (Linux)
- Deteccao de versao testada (retorna `2026.1.2`)
- URL de download validada (HTTP 200) para todos os assets
