# Integração Aider + OmniRoute

## Configuração Funcional (Validada em 2026-07-17)

### Variáveis de Ambiente Necessárias
```bash
export OPENAI_API_KEY="$OMNIROUTE_API_KEY"
export OMNIROUTE_API_KEY="sk-..."  # Do .env do Hermes
export OMNIROUTE_BASE_URL="http://localhost:20128/v1"
```

### Comando Aider Correto
```bash
aider \
  --model openai/omniroute/work \
  --openai-api-base http://localhost:20128/v1 \
  --message "Sua task aqui" \
  --yes \
  --no-show-model-warnings
```

### Flags Importantes
| Flag | Valor | Por que |
|------|-------|---------|
| `--model` | `openai/omniroute/work` | Prefixo `openai/` obrigatório para LiteLLM |
| `--openai-api-base` | `http://localhost:20128/v1` | Aponta para OmniRoute local |
| `--yes` | - | Modo não-interativo |
| `--no-show-model-warnings` | - | Reduz ruído |

### Erros Comuns e Soluções

| Erro | Causa | Fix |
|------|-------|-----|
| `unrecognized arguments: --api-base` | Flag errada | Use `--openai-api-base` |
| `OPENAI_API_KEY not set` | Env var faltando | `export OPENAI_API_KEY=$OMNIROUTE_API_KEY` |
| `LLM Provider NOT provided` | Modelo sem prefixo | Use `openai/omniroute/work` não `omniroute/work` |
| `AuthenticationError` | Key inválida | Verificar `OMNIROUTE_API_KEY` no `.env` |

### Exemplo Completo Funcionando
```bash
cd /seu/repo
OPENAI_API_KEY="$OMNIROUTE_API_KEY" aider \
  --model openai/omniroute/work \
  --openai-api-base http://localhost:20128/v1 \
  --message "Create a hello.sh script that prints Hello World" \
  --yes
```

### Output Esperado
```
Aider v0.86.2
Model: openai/omniroute/work with whole edit format
Git repo: .git with 1 files
Repo-map: using 1024 tokens, auto refresh

hello.sh

#!/bin/bash

echo "Hello World"

Tokens: 775 sent, 15 received.

hello.sh
Applied edit to hello.sh
Commit abc1234 feat: add hello.sh script that prints Hello World
```

## Integração no Orchestrator

O script `run-agent.sh` usa esta configuração:

```bash
AGENT_CMD="OPENAI_API_KEY=\"$OMNIROUTE_API_KEY\" aider \
  --model openai/omniroute/work \
  --openai-api-base http://localhost:20128/v1 \
  --max-tokens 8192 \
  --yes \
  --no-show-model-warnings \
  --message '$FULL_PROMPT'"
```

## Notas Importantes

1. **OmniRoute deve estar rodando** na porta 20128 (`systemctl --user status omniroute`)
2. **Modelo `omniroute/work`** é o modelo padrão configurado no Hermes
3. **Budget control** não é nativo no Aider — usar token counting aproximado ou migrar para Claude Code quando tiver auth
4. **Git commits** são feitos automaticamente pelo Aider com `--yes`