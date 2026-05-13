---
spike: 002
name: hermes-feature-flag
type: standard
validates: "Given .chezmoi.yaml.tmpl, when adicionamos flag ai.coding_assistants.hermes.enabled, then template gera config correta"
verdict: PENDING
related: [001, 004]
tags: [config, chezmoi, feature-flag, template]
---

# Spike 002: Hermes Feature Flag Integration

## What This Validates

Validar que a feature flag para Hermes segue o padrão estabelecido no projeto para AI tools:
- Integração com `.chezmoi.yaml.tmpl`
- Estrutura compatível com `.chezmoidata/ai_tools.yaml`
- Padrão similar ao OpenClaw (já existente)

## Research

### Existing Pattern Analysis

#### `.chezmoi.yaml.tmpl` (linhas 166-181)

```yaml
{{- $ai := dict
  "tools" (dict
    "coding_assistants" true
    "spec_tools"        true
    "gsd"               true

    "ollama" (dict
    "install"      true
    "mode"         $ollamaMode
    "localmodels"  false
    )

    "openclaw" (dict "install" false)
  )
-}}
```

#### `.chezmoidata/ai_tools.yaml`

Tools são categorizadas por:
- `feature_flag`: qual flag controla (coding_assistants, spec_tools)
- Tipo de instalação: `npm`, `curl`, `mise`

### Hermes Characteristics

- **Tipo de instalação:** Script curl (similar a aider, claude)
- **Categoria:** coding_assistants (agente de código)
- **Configuração:** Sem provider inicial (usuário configura depois)
- **Local:** `~/.hermes/` (isolado)

## Proposed Integration

### Option A: Simple Flag (like OpenClaw)

```yaml
"hermes" (dict "install" false)
```

**Pros:** Simples, consistente com openclaw
**Cons:** Menos flexível para configurações futuras

### Option B: Dict com Configurações

```yaml
"hermes" (dict
  "install"   false
  "provider"  ""  # vazio = usuário configura
  "gateway"   false  # não iniciar gateway por padrão
)
```

**Pros:** Extensível
**Cons:** Mais complexo, YAGNI?

### Recommendation: Option A (start simple)

Seguir padrão openclaw: `hermes (dict "install" false)`

## How to Test

### 1. Template Modification

Adicionar a `.chezmoi.yaml.tmpl`:

```yaml
    "openclaw" (dict "install" false)
    "hermes" (dict "install" false)  # NOVO
```

### 2. Validation Script

```bash
# Testar template
cd /home/fabio.souza/.local/share/chezmoi/home
chezmoi execute-template < .chezmoi.yaml.tmpl > /tmp/test-chezmoi.yaml

# Verificar se hermes aparece
grep -A 2 '"hermes"' /tmp/test-chezmoi.yaml
```

### 3. Data File Integration

Adicionar a `.chezmoidata/ai_tools.yaml`:

```yaml
curl:
  - name: hermes
    url: "https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh"
    shell: bash
    feature_flag: coding_assistants
    condition: "hermes.install"
```

**Question:** O install script hermes já faz tudo (instala uv, python, etc). Precisamos de wrapper?

## Investigation Trail

### Test 1: Template Syntax

**Status:** ⏳ Pending

Validar que a sintaxe do dict é correta.

### Test 2: Data Integration

**Status:** ⏳ Pending

Como integrar com o sistema existente de instalação?

Opções:
1. Adicionar tipo novo no ai_tools.yaml
2. Criar script run_once separado
3. Usar existing_script com modificações

### Test 3: Conditional Installation

**Status:** ⏳ Pending

Testar que hermes só instala quando `ai.tools.coding_assistants` e `hermes.install` são true.

## What to Expect

### Success Criteria

- ✅ Template compila sem erros (`chezmoi execute-template`)
- ✅ Flag aparece na configuração gerada
- ✅ Estrutura consistente com openclaw
- ✅ Condicional de instalação funciona

### Pattern Consistency Check

```
openclaw: (dict "install" false)
hermes:   (dict "install" false)

✓ Mesmo padrão
✓ Fácil de entender
✓ Fácil de migrar para dict expandido no futuro
```

## Results

**Verdict:** PENDING

### Implementation Notes

[Após testes, documentar exatamente quais arquivos modificar]

### Files to Modify

1. `.chezmoi.yaml.tmpl` - Adicionar hermes ao dict $ai.tools
2. `.chezmoidata/ai_tools.yaml` - Adicionar entry ou criar novo script
3. Criar script de instalação em `home/.chezmoiscripts/` ?

### Migration Path

Se no futuro quisermos configurações avançadas:
```yaml
# v1 (atual)
"hermes" (dict "install" false)

# v2 (futuro)
"hermes" (dict 
  "install" true
  "config" (dict
    "provider" "openrouter"
    "gateway" false
  )
)
```

A v1 é subset da v2 - compatível.
