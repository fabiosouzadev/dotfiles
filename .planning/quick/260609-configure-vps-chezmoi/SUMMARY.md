---
status: complete
date: 2026-06-09
---

# Quick Task Summary: Configurar chezmoi para VPS

## Objetivo
Configurar o chezmoi para instalar apenas o necessário no VPS (Oracle Cloud Free Tier), evitando pacotes de outros ambientes Ubuntu.

## Resultado

### Arquivos Modificados

1. **home/.chezmoiignore.tmpl** - Adicionada seção VPS-SPECIFIC FILTERS:
   - Ignora scripts de desktop/GUI quando `settings.vps` é true
   - Ignora drivers específicos (RTL8821CE, Cirrus)
   - Ignora window managers (i3, Niri)
   - Ignora virtualização
   - Ignora compilação de fonte (neovim, tmux)
   - Ignora configs de desktop (i3, niri, greenclip)

### Arquivos Criados (referência)

1. **vps-chezmoi-config.yaml** - Exemplo de configuração VPS
2. **vps-.chezmoiignore** - Exemplo de .chezmoiignore para VPS
3. **VPS-SETUP-GUIDE.md** - Guia completo de setup

## Configuração Essencial para VPS

O `.chezmoi.yaml.tmpl` já detecta VPS automaticamente e configura:

**Auto-detect VPS:**
- `settings.vps: true` (via CHEZMOI_VPS env, hostname, ou Ubuntu+ubuntu+SSH)
- `settings.osid: "linux"`
- `settings.guiAvailable: false`
- `settings.headless: true`

**Features otimizadas para VPS:**
```yaml
features:
  # DESABILITADO em VPS
  i3:
    enabled: false
  niri:
    enabled: false
  ai:
    coding_assistants: false
    spec_tools: false
    gsd: false
    ollama:
      install: false  # Sem GPU no VPS

  # HABILITADO em VPS
  ai:
    hermes:
      install: true
      mode: "vps-daemon"
    omniroute:
      install: true
      mode: "vps-server"
      domain: ""  # Configurar via CHEZMOI_OMNIROUTE_DOMAIN
      bind: "0.0.0.0"
  networking:
    tailscale:
      install: true
```

## Scripts que Rodam no VPS

### Essenciais:
1. `run_onchange_before_202-install-ubuntu-packages.sh.tmpl` - Pacotes básicos
2. `run_once_after_530-install-caddy.sh.tmpl` - Caddy (se tem domínio)
3. `run_once_after_555-install-tailscale.sh.tmpl` - Tailscale
4. `run_once_after_560-setup-vps-services.sh.tmpl` - Serviços VPS

### Ignorados (via .chezmoiignore):
- 15+ scripts de desktop/GUI
- 3 scripts de drivers
- 2 scripts de window managers
- 1 script de virtualização
- 3 scripts de compilação de fonte

## Próximos Passos do Usuário

1. **Auto-detectado:** O `.chezmoi.yaml.tmpl` já detecta VPS automaticamente e configura tudo:
   - Detecta via: `CHEZMOI_VPS=true`, hostname "vps", ou Ubuntu+ubuntu+SSH+sem GUI
   - Desabilita automaticamente: i3, niri, AI tools, ollama
   - Habilita automaticamente: omniroute (vps-server), hermes (vps-daemon), tailscale

2. **Para forçar detecção VPS** (se não detectado automaticamente):
   ```bash
   export CHEZMOI_VPS=true
   chezmoi apply
   ```

3. **Configurar domínio** (opcional, para Caddy):
   ```bash
   export CHEZMOI_OMNIROUTE_DOMAIN="omniroute.seudominio.com"
   chezmoi apply
   ```

4. **Pronto!** O chezmoi já vai instalar apenas o necessário para o VPS

## Arquivos Modificados
- `home/.chezmoi.yaml.tmpl` - Otimizado features para VPS (desabilita i3, niri, AI tools, ollama)
- `home/.chezmoiignore.tmpl` - Adicionada seção VPS-SPECIFIC FILTERS

## Arquivos Criados (referência)
- `.planning/quick/260609-configure-vps-chezmoi/PLAN.md`
- `.planning/quick/260609-configure-vps-chezmoi/vps-chezmoi-config.yaml`
- `.planning/quick/260609-configure-vps-chezmoi/vps-.chezmoiignore`
- `.planning/quick/260609-configure-vps-chezmoi/VPS-SETUP-GUIDE.md`
