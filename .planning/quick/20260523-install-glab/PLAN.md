---
status: complete
---

# Quick Task: install-glab

## Objetivo
Templates chezmoi para instalar o `glab` (GitLab CLI) apontando para a instancia self-hosted da ClaroBrasil em `gitdev.clarobrasil.mobi`:
- Instalacao user-local (sem sudo)
- Suporte a Linux/WSL e Windows 11
- Configuracao automatica do `GITLAB_HOST`
- Token via variavel de ambiente (`ZUP_GITLAB_TOKEN`)
- Completions zsh geradas automaticamente
- Filtrado por workplace (so instala no ambiente ZUP/ClaroBrasil)

## Abordagem (chezmoi way)
1. `home/.chezmoiscripts/unix/run_once_after_528-install-glab.sh.tmpl` — Linux/WSL
2. `home/.chezmoiscripts/windows/run_once_after_528-install-glab.ps1.tmpl` — Windows 11
3. `home/dot_zshrc.d/505-glab.zsh.tmpl` — env vars zsh (WSL/Linux)
4. Usa templates existentes: `script_helper`, `script_is_not_ephemeral`, `script_is_zup`, `script_validate_completions_path`
5. GitLab API para detectar versao mais recente
6. Binario para `~/.local/bin/` (Linux) ou `%LOCALAPPDATA%\bin\` (Windows)
