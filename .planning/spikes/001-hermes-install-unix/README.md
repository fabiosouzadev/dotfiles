---
spike: 001
name: hermes-install-unix
type: standard
validates: "Given macOS ou Linux, when instalamos via script oficial, then hermes CLI funciona sem conflitos com mise/uv"
verdict: PENDING
related: [002, 004]
tags: [install, macos, linux, unix, hermes, nousresearch]
---

# Spike 001: Hermes Install on Unix (macOS/Linux)

## What This Validates

Validar que o script de instalação oficial do Hermes Agent funciona corretamente em ambientes Unix (macOS e Linux), sem conflitar com:
- mise (gerenciador de runtimes já configurado)
- uv (Python package manager)
- Node/npm existentes
- Outras AI tools já instaladas

## Research

### Installation Methods

| Approach | Script/Command | Pros | Cons | Status |
|----------|---------------|------|------|--------|
| Official one-liner | `curl -fsSL .../install.sh \| bash` | Oficial, atualizado, instala dependências | Requer curl, executa código remoto | **Chosen** |
| Manual setup | Clone + setup-hermes.sh | Mais controle, auditável | Mais passos, manual | Alternative |
| Homebrew (fórmula) | `brew install hermes` | Nativo macOS | Não existe ainda | N/A |

**Chosen approach:** Official one-liner - é o método recomendado e testado pelo NousResearch.

### Key Dependencies

De acordo com a documentação, o installer instala automaticamente:
- uv (Python package manager) - pode conflitar se já existir
- Python 3.11
- Node.js
- ripgrep
- ffmpeg

**Risk:** Conflito com mise/uv existentes. Precisamos verificar se o script detecta e reusa ferramentas existentes.

### Script Behavior

Fonte: https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh

O script:
1. Detecta OS (macOS, Linux, Windows)
2. Instala uv se não existir
3. Cria venv em `~/.hermes/`
4. Instala hermes via uv
5. Cria symlink em `~/.local/bin/hermes`
6. Configura shell (bashrc/zshrc)

## How to Run

### Pre-flight Checks

```bash
# Verificar se hermes já existe
which hermes
ls -la ~/.hermes/
ls -la ~/.local/bin/hermes

# Verificar mise/uv
which mise
which uv
mise list  # ver runtimes ativos

# Backup (opcional)
cp ~/.zshrc ~/.zshrc.pre-hermes
```

### Execute Installation

```bash
# Script oficial
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
```

### Verification

```bash
# 1. Verificar instalação
which hermes
hermes --version

# 2. Testar CLI básica
hermes doctor

# 3. Verificar conflitos
# - mise ainda funciona?
mise list

# - uv do hermes não sobrescreveu uv do sistema?
which uv
uv --version

# 4. Verificar shell config
# O script modificou .zshrc/.bashrc?
grep -n "hermes" ~/.zshrc

# 5. Verificar PATH
ls -la ~/.local/bin/hermes
echo $PATH | grep -o "hermes"
```

## Investigation Trail

### Test 1: macOS Installation

**Status:** ⏳ Pending

**Setup:**
- macOS ( Darwin )
- mise já instalado
- uv via mise
- Node via mise

**Steps:**
1. Executar one-liner
2. Documentar output
3. Verificar conflitos

**Results:**
- [ ] Instalação completou sem erros?
- [ ] hermes comando disponível?
- [ ] mise ainda funciona?
- [ ] Python/Node não conflitaram?

### Test 2: Linux Installation (Arch/Ubuntu)

**Status:** ⏳ Pending

**Setup:**
- Arch Linux ou Ubuntu
- Similar setup com mise

**Expected:** Mesmo comportamento do macOS

### Test 3: Reinstall / Update

**Status:** ⏳ Pending

**Question:** O que acontece se rodar o script novamente?

## What to Expect

### Success Criteria

- ✅ `hermes` comando disponível no PATH
- ✅ `hermes doctor` passa sem erros críticos
- ✅ mise/uv do usuário não foram sobrescritos
- ✅ Shell config (.zshrc) modificada corretamente
- ✅ Instalação idempotente (rodar 2x não quebra)

### Failure Scenarios

- ❌ Script sobrescreve uv do mise
- ❌ Conflito de Python versions
- ❌ hermes não encontra dependências
- ❌ Modificações agressivas no shell config

## Results

**Verdict:** PENDING

### Summary

[Após execução, documentar:]

### Key Findings

- [ ] Script detecta ferramentas existentes?
- [ ] uv do hermes isola do sistema?
- [ ] Tempo de instalação: ___ minutos
- [ ] Tamanho em disco: ___ MB

### Integration Notes

[Notas para spike 002 (feature flag) e 004 (integration)]

### Blockers (if any)

[Listar se houver impedimentos para integração]
