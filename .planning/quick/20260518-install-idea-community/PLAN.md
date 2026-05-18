---
status: complete
description: Template chezmoi para instalar IntelliJ IDEA Community Edition sem sudo
---

# Quick Task: install-idea-community

## Objetivo
Criar template chezmoi para instalar IntelliJ IDEA Community Edition que:
- Baixa automaticamente a versao mais recente do GitHub (JetBrains/intellij-community)
- Permite fixar uma versao via chezmoidata (`.features.idea.version`)
- Detecta arquitetura (x86_64 / aarch64)
- NAO usa sudo — instala em diretorio do usuario (~/.local/share/idea-ic)
- Cria symlink em ~/.local/bin e desktop entry
- Usa padroes do projeto: script_helper, script_is_not_ephemeral, script_linux_only
- Feature flag: `.features.idea.install`

## Abordagem (chezmoi way)
1. `.chezmoidata/idea.yaml` — config com feature flag e versao opcional
2. `.chezmoiscripts/linux/run_once_after_530-install-idea-community.sh.tmpl` — template
3. Usa templates existentes: script_helper, script_is_not_ephemeral, script_linux_only
4. GitHub API com fallback sem jq
5. Symlink + desktop entry
