---
wave: 1
depends_on: []
files_modified:
  - home/.chezmoi.yaml.tmpl
  - home/.chezmoidata/ai_tools.yaml
  - home/.chezmoiscripts/run_once_09-install-hermes.sh.tmpl
requirements:
  - HERME-01
  - HERME-02
  - HERME-04
autonomous: true
---

# Phase 9 Plan: Hermes Agent Integration

**Phase:** 09-hermes-agent  
**Objective:** Integrar Hermes Agent ao dotfiles via feature flags e instalação automatizada  
**Mode:** Vertical MVP  

## Overview

Esta fase adiciona o Hermes Agent (https://github.com/NousResearch/hermes-agent) como uma ferramenta de IA opcional no ecossistema de dotfiles. A integração segue os padrões estabelecidos na fase 7 (Feature Flags para AI Tools), garantindo coexistência sem conflitos com Claude Code, Aider, e outras tools existentes.

## Success Criteria

1. ✓ Feature flag `ai.coding_assistants.hermes.enabled` adicionada e funcional
2. ✓ Script de instalação via chezmoi funciona em macOS
3. ✓ Instalação é idempotente (rodar múltiplas vezes não quebra)
4. ✓ Coexistência validada com outras AI tools

## Must-Haves

- HERME-01: Feature flag no `.chezmoi.yaml.tmpl`
- HERME-02: Script run_once de instalação
- HERME-04: Idempotência da instalação
- HERME-05: Documentação básica no README

## Plans

### Plan 09A: Feature Flag Configuration

**Wave:** 1  
**Depends on:** None  
**Files:** `.chezmoi.yaml.tmpl`, `.chezmoidata/ai_tools.yaml`

<read_first>
1. `home/.chezmoi.yaml.tmpl` — verificar estrutura existente do dict $ai.tools
2. `home/.chezmoidata/ai_tools.yaml` — verificar como tools são definidas
3. `.planning/spikes/002-hermes-feature-flag/README.md` — padrão recomendado
</read_first>

<acceptance_criteria>
1. `home/.chezmoi.yaml.tmpl` contém `"hermes" (dict "install" false)` dentro de `$ai.tools`
2. Template compila sem erros: `chezmoi execute-template < home/.chezmoi.yaml.tmpl`
3. Estrutura é consistente com `"openclaw" (dict "install" false)` existente
</acceptance_criteria>

<action>
Adicionar ao dict `$ai.tools` em `.chezmoi.yaml.tmpl` (após openclaw):
```yaml
"hermes" (dict "install" false)
```

Verificar posição: deve estar dentro do dict, antes do fechamento `)`.
</action>

---

### Plan 09B: Installation Script

**Wave:** 1  
**Depends on:** 09A  
**Files:** `home/.chezmoiscripts/run_once_09-install-hermes.sh.tmpl`

<read_first>
1. `home/.chezmoiscripts/` — verificar padrão de scripts run_once existentes
2. `home/.chezmoiscripts/run_once_install-aider.sh.tmpl` — exemplo similar (curl install)
3. `.planning/spikes/001-hermes-install-unix/README.md` — research sobre instalação
</read_first>

<acceptance_criteria>
1. Script existe em `home/.chezmoiscripts/run_once_09-install-hermes.sh.tmpl`
2. Script verifica `{{ .ai.tools.hermes.install }}` antes de executar
3. Script executa `curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash`
4. Script é idempotente (verifica se `~/.hermes/hermes` existe antes de instalar)
5. Script tem exec permission e shebang correto
</acceptance_criteria>

<action>
Criar `home/.chezmoiscripts/run_once_09-install-hermes.sh.tmpl`:
- Shebang: `#!/bin/bash`
- Verificação da feature flag usando chezmoi template
- Verificação de existência: `test -f ~/.hermes/hermes` ou `which hermes`
- Execução condicional do install script
- Mensagens de log apropriadas
</action>

---

### Plan 09C: AI Tools Data Integration

**Wave:** 1  
**Depends on:** 09A  
**Files:** `home/.chezmoidata/ai_tools.yaml`

<read_first>
1. `home/.chezmoidata/ai_tools.yaml` — estrutura atual de definição de tools
</read_first>

<acceptance_criteria>
1. `home/.chezmoidata/ai_tools.yaml` contém entrada para hermes na seção `curl`
2. Estrutura segue o padrão: `name`, `url`, `shell`, `feature_flag`, `condition`
3. Feature flag é `coding_assistants`
</acceptance_criteria>

<action>
Adicionar à seção `curl` de `ai_tools.yaml`:
```yaml
- name: hermes
  url: "https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh"
  shell: bash
  feature_flag: coding_assistants
  condition: "hermes.install"
```

Nota: A `condition` referencia o path dentro do dict de AI tools.
</action>

---

### Plan 09D: Idempotency Verification

**Wave:** 1  
**Depends on:** 09B  
**Files:** N/A (verification only)

<read_first>
1. `.planning/spikes/001-hermes-install-unix/README.md` — seção "How to Run" e "What to Expect"
</read_first>

<acceptance_criteria>
1. Rodar instalação uma vez: hermes instalado e funcionando
2. Rodar instalação segunda vez: não quebra, detecta que já existe
3. `hermes doctor` passa após instalação
4. `which hermes` retorna caminho válido
</acceptance_criteria>

<action>
Testar manualmente:
```bash
# Primeira instalação
chezmoi apply
which hermes
hermes doctor

# Segunda instalação (idempotência)
chezmoi apply
# Deve completar sem erros, não reinstalar desnecessariamente
```

Documentar resultados no SUMMARY.md.
</action>

---

### Plan 09E: Coexistence Validation

**Wave:** 1  
**Depends on:** 09B, 09D  
**Files:** N/A (verification only)

<read_first>
1. `.planning/spikes/004-hermes-integration/README.md` — testes de coexistência
</read_first>

<acceptance_criteria>
1. Com Hermes instalado, Claude Code ainda funciona: `claude --version`
2. Com Hermes instalado, Aider ainda funciona: `aider --version`
3. Com Hermes instalado, OpenCode ainda funciona: `opencode --version`
4. Todas as configs em seus diretórios respectivos não foram modificadas:
   - `~/.claude/` — inalterado
   - `~/.aider.conf.yml` — inalterado
   - `~/.config/opencode/` — inalterado
   - `~/.hermes/` — novo, isolado
</acceptance_criteria>

<action>
Executar testes de coexistência:
```bash
# Verificar tools existentes
claude --version
aider --version
opencode --version
hermes --version

# Verificar isolamento de configs
ls -la ~/.claude/
ls -la ~/.hermes/
# Devem ser diretórios separados
```

Se houver conflitos, documentar e ajustar.
</action>

---

### Plan 09F: Documentation

**Wave:** 1  
**Depends on:** 09A, 09B, 09E  
**Files:** `README.md`

<read_first>
1. `README.md` — seção de AI tools existente
</read_first>

<acceptance_criteria>
1. README.md contém menção ao Hermes na seção de AI tools
2. Documentação explica: (a) como habilitar, (b) comando para iniciar, (c) como configurar provider
3. Exemplo de feature flag está correto
</acceptance_criteria>

<action>
Adicionar à seção de AI tools do README.md:
- Nome: Hermes Agent
- Descrição breve: Agente de IA auto-melhorável do NousResearch
- Como habilitar: setar `ai.coding_assistants.hermes.enabled: true` no `.chezmoi.yaml`
- Comando: `hermes`
- Configuração de provider: `hermes model` (interativo)
</action>

---

## Verification

### Pre-execution Checklist

- [ ] 09A: Feature flag adicionada ao template
- [ ] 09B: Script de instalação criado
- [ ] 09C: AI tools data atualizado
- [ ] 09D: Idempotência testada
- [ ] 09E: Coexistência validada
- [ ] 09F: Documentação adicionada

### Post-execution Verification

```bash
# 1. Verificar feature flag
grep -A 1 '"hermes"' ~/.local/share/chezmoi/home/.chezmoi.yaml.tmpl

# 2. Verificar script existe
ls -la ~/.local/share/chezmoi/home/.chezmoiscripts/run_once_09-install-hermes.sh.tmpl

# 3. Testar template
cd ~/.local/share/chezmoi/home && chezmoi execute-template < .chezmoi.yaml.tmpl > /tmp/test.yaml

# 4. Verificar hermes instalado (após apply)
which hermes
hermes --version

# 5. Verificar coexistência
claude --version && aider --version && opencode --version
```

### Success Criteria Verification

| Criterion | Check |
|-----------|-------|
| HERME-01: Feature flag funciona | `grep '"hermes"' .chezmoi.yaml.tmpl` |
| HERME-02: Instalação via chezmoi | `ls .chezmoiscripts/run_once_09*` |
| HERME-03: Coexistência | `which hermes && which claude` |
| HERME-04: Idempotência | Rodar `chezmoi apply` 2x |
| HERME-05: Documentação | `grep -i hermes README.md` |

---

## Dependencies

```
09A (Feature Flag) ──┬──→ 09B (Install Script) ──┬──→ 09D (Idempotency)
                     │                           │
                     └──→ 09C (AI Tools Data)    └──→ 09E (Coexistence)
                                                          │
                                                          ↓
                                                    09F (Documentation)
```

## Notes

- **Instalação manual:** Se o usuário preferir, pode sempre usar o one-liner diretamente: `curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash`
- **Update:** Hermes tem comando próprio `hermes update` para atualizações
- **Uninstall:** Remover `~/.hermes/` e `~/.local/bin/hermes`, e limpar shell config
- **WSL:** Spike 003 validou que funciona, mas não é primary target desta fase

---

*Plan created: 2026-05-13*  
*Phase: 09-hermes-agent*  
*Mode: MVP (Vertical Slice)*
