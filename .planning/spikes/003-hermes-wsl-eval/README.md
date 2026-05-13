---
spike: 003
name: hermes-wsl-eval
type: standard
validates: "Given WSL2 Ubuntu, when instalamos Hermes, then funciona igual ao Linux nativo ou identificamos gaps"
verdict: PENDING
related: [001]
tags: [wsl, ubuntu, eval, windows, compatibility]
---

# Spike 003: Hermes WSL2 Evaluation

## What This Validates

Avaliar se o comportamento do Hermes Agent no WSL2 Ubuntu difere do Linux nativo ou macOS. Documentar gaps específicos do WSL.

## Context

### WSL2 Characteristics
- Kernel Linux real (não emulação)
- Filesystem crossover (Windows <-> Linux)
- Networking diferente (localhost compartilhado)
- Serviços systemd podem ter nuances

### Hermes Features Potencialmente Afetados

| Feature | WSL Risk | Notes |
|---------|----------|-------|
| CLI/TUI | Low | Terminal funciona igual |
| Gateway | Medium | Port binding, localhost | 
| File access | Medium | Paths Windows vs Linux |
| Voice/TTS | High | ffmpeg, audio drivers |
| Browser integration | High | WSL não tem GUI nativa |

## Research

### WSL-Specific Considerations

#### 1. Installation Script
O script oficial detecta WSL? Como?

```bash
# Verificar detecção WSL no install.sh
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | grep -i wsl
```

#### 2. Gateway / Network
Hermes gateway usa portas específicas?
- Telegram bot: webhook vs polling
- Discord: websocket
- Local APIs: porta ???

WSL2 tem networking própria que mudou ao longo do tempo:
- WSL1: compartilhava network stack
- WSL2: VM com próprio IP (mas localhost forwarded)

#### 3. Filesystem Paths
Hermes armazena configs/skills em `~/.hermes/`
- WSL path: `\\wsl$\Ubuntu\home\user\.hermes`
- Acessível do Windows Explorer

## How to Test

### Prerequisites
- WSL2 Ubuntu instalado
- Windows Terminal ou similar

### Installation Test

```bash
# No WSL2:
# 1. Pre-checks
uname -a  # verificar WSL
cat /proc/version

# 2. Instalar
 curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash

# 3. Post-checks
hermes doctor
ls -la ~/.hermes/
```

### Feature Test Matrix

| Test | Linux Nativo | WSL2 | Delta |
|------|--------------|------|-------|
| Instalação | ✓ | ? | |
| CLI básico | ✓ | ? | |
| hermes doctor | ✓ | ? | |
| Config persistence | ✓ | ? | |
| Skill creation | ✓ | ? | |
| (Opcional) Gateway | ? | ? | |

### Specific WSL Tests

```bash
# Test 1: Path handling
hermes config get | grep path

# Test 2: Network (se gateway)
# Verificar portas em uso
netstat -tlnp | grep hermes

# Test 3: File permissions
ls -la ~/.hermes/
getfacl ~/.hermes/  # se disponível

# Test 4: Audio (se aplicável)
# hermes voice features - provavelmente não funciona no WSL sem config extra
```

## Investigation Trail

### Test 1: Basic Installation

**Status:** ⏳ Pending

**Expected:** Mesmo comportamento Linux/macOS
**Actual:** [preencher após teste]

### Test 2: Config Path Resolution

**Status:** ⏳ Pending

WSL paths podem ser acessadas via `\wsl$` do Windows.
Isso afeta algo no Hermes?

### Test 3: (Optional) Gateway Test

**Status:** ⏳ Pending

Se testar gateway, verificar:
- Port binding funciona?
- Acessível do host Windows?
- Acessível de fora?

## What to Expect

### Success Criteria (WSL Compatibility)

- ✅ Instalação funciona sem modificações
- ✅ CLI opera normalmente
- ✅ Configs persistem em `~/.hermes/`
- ✅ Nenhum erro específico de WSL em `hermes doctor`

### Expected Gaps

Possíveis limitações WSL (documentar se existirem):

⚠️ **Gateway/Portas**
- Pode precisar configuração específica de bind address

⚠️ **Audio/Voice**
- TTS provavelmente não funciona sem pulseaudio/pipewire no Windows

⚠️ **Browser/Dashboard**
- Se hermes tem UI web, precisa abrir browser no Windows host

## Results

**Verdict:** PENDING

### Compatibility Summary

```
Feature          | Status | Notes
-----------------|--------|------------------
Installation     | ?      |
CLI/TUI          | ?      |
Config/Storage   | ?      |
Skills           | ?      |
Memory/Search    | ?      |
Gateway          | ?      | (if tested)
Voice/TTS        | ?      | Likely N/A
```

### Recommendation

[Após teste, recomendar:]

- **Full Support:** WSL funciona igual ao Linux nativo
- **Partial Support:** Funciona com limitações documentadas
- **Not Recommended:** Bloquear instalação em WSL

### WSL-Specific Notes for Users

[Se aplicável, documentar workarounds necessários]

Example:
```
# Se gateway precisar bind em todas interfaces:
hermes gateway --host 0.0.0.0

# Acessar do Windows:
# http://localhost:PORT/ (WSL2 forwarda automaticamente)
```
