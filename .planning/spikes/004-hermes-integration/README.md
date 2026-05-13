---
spike: 004
name: hermes-integration
type: standard
validates: "Given dotfiles existentes, when Hermes é instalado via chezmoi, then não conflita com Claude Code, Aider, OpenCode"
verdict: PENDING
related: [001, 002]
tags: [integration, coexistence, ai-tools, claude, aider, opencode]
---

# Spike 004: Hermes Integration with Existing AI Tools

## What This Validates

Validar que Hermes Agent coexiste sem conflitos com o ecossistema existente de AI tools nos dotfiles:
- **Claude Code** (Anthropic) - instalado via script oficial
- **Aider** - instalado via install.sh
- **OpenCode** - instalado via npm
- **Outros:** Gemini CLI, Codex, etc.

## Research

### Existing AI Tools Inventory

De `.chezmoidata/ai_tools.yaml`:

| Tool | Install Method | Location | Config Dir |
|------|---------------|----------|------------|
| opencode | npm global | npm prefix | ~/.config/opencode/ |
| copilot | npm global | npm prefix | ~/.config/ |
| codex | npm global | npm prefix | ~/.config/codex/ |
| gemini | npm global | npm prefix | ~/.cache/gemini/ |
| aider | curl \| sh | ~/.local/bin/ | ~/.aider.conf.yml |
| claude | curl \| sh | ~/.local/bin/ | ~/.claude/ |
| kiro | curl \| bash | ~/.kiro/ | ~/.kiro/ |

### Hermes Characteristics

| Aspect | Hermes | Risk |
|--------|--------|------|
| Install location | ~/.hermes/ | ✅ Isolado |
| Binary | ~/.local/bin/hermes | ✅ Padrão |
| Config | ~/.hermes/config/ | ✅ Isolado |
| Skills | ~/.hermes/skills/ | ✅ Isolado |
| Python | ~/.hermes/.venv/ | ✅ Isolado (uv venv) |
| Node | ~/.hermes/node/ | ⚠️ Verificar conflito |

### Potential Conflict Areas

#### 1. Python Environment
- Hermes usa `uv` para criar venv em `~/.hermes/`
- Sistema pode ter uv via mise
- **Risk Level:** Low (isolado em ~/.hermes/)

#### 2. Node/npm
- Hermes instala Node próprio?
- Verificar em install.sh
- **Risk Level:** Medium (se instalar global)

#### 3. Portas (se usar gateway)
- Claude Code usa porta?
- Aider é CLI only
- Hermes gateway - verificar portas padrão
- **Risk Level:** Low (sem gateway por padrão)

#### 4. Shell Completions
- Todos competem por espaço no .zshrc
- Hermes adiciona ao shell config automaticamente
- **Risk Level:** Medium (zshrc pollution)

#### 5. API Keys
- Hermes lê de ~/.hermes/config/
- Claude: ~/.claude/
- Aider: ~/.aider.conf.yml (ou env)
- **Risk Level:** Low (diretórios separados)

## How to Test

### Pre-Installation Inventory

```bash
# Listar tools existentes
which opencode
which claude
which aider
which codex
which gemini
which hermes  # deve falhar

# Verificar diretórios
ls -la ~/.config/ | grep -E "opencode|claude|codex"
ls -la ~/.local/bin/ | wc -l  # baseline

# Verificar zshrc
wc -l ~/.zshrc
grep -c "hermes" ~/.zshrc  # deve ser 0
```

### Install Hermes

```bash
# Instalar (usando feature flag quando disponível)
# ou manualmente para este spike
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
```

### Coexistence Tests

```bash
# Test 1: Todos os comandos disponíveis?
opencode --version
claude --version
aider --version
codex --version
hermes --version

# Test 2: Isolamento de config
ls ~/.hermes/  # deve existir
ls ~/.hermes/config/  # configs hermes
ls ~/.claude/  # configs claude (inalterado?)

# Test 3: Shell config
grep -n "hermes" ~/.zshrc
wc -l ~/.zshrc  # comparar com baseline
# Esperado: +2-3 linhas para hermes

# Test 4: Python environments
which python3  # deve ser do mise
ls ~/.hermes/.venv/  # venv isolado hermes
# Verificar que hermes não alterou PATH do python global

# Test 5: Simultaneous usage (quick test)
# Abrir 3 terminais e rodar cada tool com --help
# Ou sequencialmente:
hermes --help > /dev/null && echo "Hermes OK"
claude --help > /dev/null && echo "Claude OK"
aider --help > /dev/null && echo "Aider OK"
```

### Conflict Detection

```bash
# Procurar sinais de conflito
# 1. Erros de import Python
grep -r "ImportError" ~/.hermes/ 2>/dev/null || echo "No import errors"

# 2. Conflito de portas (se aplicável)
# netstat -tlnp | grep -E "claude|hermes|aider"

# 3. Filesystem conflicts
find ~ -name "*hermes*" -o -name "*claude*" | grep -E "\.(lock|tmp|cache)$"

# 4. Environment variables
env | grep -iE "hermes|claude|aider|openai|anthropic"
```

## Investigation Trail

### Test 1: Clean Coexistence

**Status:** ⏳ Pending

Instalar Hermes em ambiente com tools existentes.

**Checklist:**
- [ ] Instalação completa sem erros
- [ ] Tools existentes ainda funcionam
- [ ] Hermes funciona
- [ ] Nenhum erro de conflito de arquivo

### Test 2: Resource Conflicts

**Status:** ⏳ Pending

Testar uso simultâneo (se aplicável).

**Question:** Hermes mantém daemon em background?
- Se sim, verificar conflito de recursos
- Se não (CLI only), risco é mínimo

### Test 3: Shell Config Impact

**Status:** ⏳ Pending

**Baseline:** ___ linhas no .zshrc antes
**After install:** ___ linhas

**Expected:** Hermes adiciona ~5-10 linhas (initialization)

**Check:** Não quebrou sintaxe do .zshrc?
```bash
zsh -n ~/.zshrc  # syntax check
```

## What to Expect

### Success Criteria

- ✅ Hermes instala sem afetar tools existentes
- ✅ Todos os comandos (`hermes`, `claude`, `aider`, `opencode`) funcionam
- ✅ Configs isoladas (sem overwrite)
- ✅ Shell config (.zshrc) ainda válido
- ✅ Python/Node environments não conflitam

### Expected Behavior

```
User workflow:
1. hermes        → inicia conversa TUI
2. claude        → inicia Claude Code
3. aider         → inicia Aider com editor
4. opencode      → inicia OpenCode

Todas independentes, sem interferência.
```

### Risk Mitigations (if needed)

Se houver conflitos:

| Conflict | Mitigation |
|----------|------------|
| Node versions | Usar Node do mise (system) |
| Python PATH | Garantir hermes isola venv |
| zshrc bloat | Documentar ordem de inicialização |
| Port binding | Configurar portas diferentes |

## Results

**Verdict:** PENDING

### Coexistence Matrix

```
Tool     | With Hermes | Notes
---------|-------------|-------
Claude   | ?           |
Aider    | ?           |
OpenCode | ?           |
Codex    | ?           |
Gemini   | ?           |
Others   | ?           |
```

### Integration Requirements

[Para feature flag e instalação automática:]

- **Pode instalar junto:** Sim/Com ressalvas/Não
- **Ordem de instalação:** Importante/Irrelevante
- **Cleanup necessário:** Sim/Não

### User Guidance

[Documentar para README final:]

```markdown
Hermes coexiste com outras AI tools. Cada tool mantém:
- Binário isolado em ~/.local/bin/
- Configuração em diretório próprio
- Ambiente Python/Node isolado

Uso recomendado:
- Hermes: para sessões longas, gateway, automações
- Claude Code: para coding sessions complexas
- Aider: para pair programming com editor
- OpenCode: para [use case específico]
```
