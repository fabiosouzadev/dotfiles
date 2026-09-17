# TESTING.md — Estrutura de Testes e Validação

> 🧠 **From Hindsight memory (codebase map)** — Documento gerado pelo mapeamento do codebase fabiosouzadev/dotfiles em 2026-09-17.

## Abordagem de Testes

O repositório não possui testes automatizados tradicionais. A validação é feita via:

### 1. Chezmoi Apply (Teste Principal)
```bash
chezmoi apply --verbose
```
Verifica se todos os templates renderizam sem erros.

### 2. Chezmoi Diff
```bash
chezmoi diff
```
Compara estado atual vs. fonte — detecta drift.

### 3. Chezmoi Verify
```bash
chezmoi cd && chezmoi verify
```
Valida correspondência destino/template.

### 4. Shell Syntax Validation
```bash
zsh -n ~/.zshrc
for f in ~/.zshrc.d/*.zsh; do zsh -n "$f"; done
```

### 5. CI Detection
`.chezmoi.yaml.tmpl` detecta CI automaticamente. Em CI: hooks desativados, scripts ephemeral ignorados.

### 6. Docker Compose Config Validation
```bash
docker compose -f <stack>/compose.yaml config
```

### 7. GPG/Age Decrypt Verification
```bash
gpg --decrypt encrypted_file.asc    # GPG
age -d -i ~/.age/key.txt file.asc   # age
chezmoi cat ~/path/to/encrypted      # Chezmoi decrypt
```

## Smoked Checks por Área

### Shell
- Zsh syntax: `zsh -n ~/.zshrc` + cada `.zshrc.d/*.zsh`
- Module sourcing na inicialização

### IA Stack
- **OmniRoute**: `curl http://localhost:20128/health`
- **Ollama**: `curl http://localhost:11434/api/tags`
- **Open WebUI**: `curl http://localhost:8080`
- **Claude Code**: `codex --version`
- **Hermes Dashboard**: `curl http://localhost:9119/healthz`

### Docker
```bash
docker compose -f <stack>/compose.yaml config  # valide configs
docker compose -f <stack>/compose.yaml ps      # verifique containers
docker compose -f <stack>/compose.yaml logs    # verifique logs
```

### Network/Proxy
- Caddy: `curl http://localhost:8642/healthz`
- Verificar portas: `ss -tlnp`

### SSH
```bash
ssh -T git@github.com                # GitHub access
ssh -o ConnectTimeout=5 vps-host     # VPS connectivity
ssh -i ~/.ssh/id_ed25519_vps ...     # VPS key
```

## Testes por Plataforma

| Plataforma | O que testar |
|------------|------------|
| **Linux (Arch)** | pacman/paru, i3, Niri, systemd, kernel, zram |
| **Linux (Ubuntu)** | apt, Caddy, systemd |
| **macOS** | brew, macports, Launchd, tmux compile |
| **Windows WSL** | Scoop, Winget, GUI detection |
| **Termux** | pkg, SSH setup, Tailscale |

## Testes de Criptografia

### age
```bash
age -d -i <keyfile> < encrypted_file.asc
```

### GPG
```bash
gpg --decrypt encrypted_file.asc
gpg --list-keys E691C031009FB1DAA3A25125212D516F623C5747
```

### Chezmoi
```bash
chezmoi cat ~/.path/to/encrypted  # requer chave local
chezmoi diff                        # detecta drift incluindo secrets
```

## Áreas que Precisam de Testes

1. **Templates Go complexos**: `.chezmoi.yaml.tmpl` (~400 linhas de lógica) — validar todos os paths de detecção
2. **Fluxo de criptografia**: age decrypt em todos os 30+ encrypted_* files
3. **Multi-OS matrix**: 5 SOs × 3 perfis = 15 combinações
4. **CI/CD pipeline**: GitHub Actions para validação automática de templates
5. **OmniRoute config**: model_provider, model, reasoning_effort validations
6. **Docker networking**: edge vs internal networks, Caddy routing
7. **Hermes config**: 311 linhas de YAML, múltiplas personalidades, MCP servers
8. **Feature flags**: todas as combinações de features.enabled/disabled

## Convenções de Smoke Checks (docs/TESTING.md)

A documentação de testes detalhada vive em `docs/TESTING.md`.

## Monitoramento Contínuo

| Check | Frequência | Como |
|-------|-----------|------|
| Docker health | Semanal | `docker ps` + healthchecks |
| Secrets validity | Semestral | age/GPG key rotation |
| AI stack connectivity | Diária | curl endpoints |
| VPS disk/backups | Semanal | manual |
| Feature flag drift | Mensal | `chezmoi diff` |

