---
status: complete
description: Templates chezmoi para instalar glab (GitLab CLI) para a instancia self-hosted da ClaroBrasil
---

# Quick Task: install-glab — Concluido

## Resultado
Templates chezmoi para instalar o `glab` (GitLab CLI) em Linux/WSL e Windows 11, todos sem sudo, filtrados por workplace ZUP.

## Plataformas

| OS | Asset | Instalacao | Binario |
|----|-------|------------|---------|
| Linux/WSL | `.tar.gz` | `~/.local/bin/glab` | `~/.local/bin/glab` |
| Windows | `.zip` | `%LOCALAPPDATA%\bin\` | `glab.exe` + PATH user |

## Configuracao

| Variavel | Onde seta | Valor |
|----------|-----------|-------|
| `GITLAB_HOST` | zsh (505-glab.zsh.tmpl) + Windows env | `https://gitdev.clarobrasil.mobi` |
| `GITLAB_TOKEN` | usuario via `ZUP_GITLAB_TOKEN` | Token pessoal do GitLab |

## Arquivos
- `home/.chezmoiscripts/unix/run_once_after_528-install-glab.sh.tmpl` — install Linux/WSL
- `home/.chezmoiscripts/windows/run_once_after_528-install-glab.ps1.tmpl` — install Windows
- `home/dot_zshrc.d/505-glab.zsh.tmpl` — env vars zsh

## Detalhes Tecnicos
- Versao detectada via GitLab API (`/api/v4/projects/34675721/releases`)
- Arquitetura auto-detectada: amd64/arm64 (Linux), ARM64/x64 (Windows)
- Completions zsh geradas via `glab completion -s zsh`
- Idempotente: skipa se ja instalado
- `GITLAB_HOST` no Windows persiste como variavel de ambiente do usuario
- `GITLAB_TOKEN` no Windows deve ser setado manualmente pelo usuario

## Pos-instalacao
1. Adicionar `ZUP_GITLAB_TOKEN=<token>` ao shell (ou setar via `[System.Environment]::SetEnvironmentVariable` no Windows)
2. Rodar `glab auth login --hostname gitdev.clarobrasil.mobi` para autenticar
3. Testar: `glab repo list`
