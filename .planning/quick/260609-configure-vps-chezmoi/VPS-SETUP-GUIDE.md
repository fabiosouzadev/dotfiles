# Guia de Setup do Chezmoi para VPS (Oracle Cloud Free Tier)

**Data:** 2026-06-09
**VPS:** Oracle Cloud Free Tier (Ubuntu)
**Objetivo:** Instalar apenas o necessário para OmniRoute + Hermes Agent

---

## Pré-requisitos

1. VPS Oracle Cloud Free Tier com Ubuntu 22.04/24.04
2. Acesso SSH configurado
3. Usuário `ubuntu` (padrão Oracle)

---

## Passo 1: Instalar dependências básicas

```bash
# Atualizar sistema
sudo apt update -y && sudo apt upgrade -y

# Instalar dependências do chezmoi
sudo apt install -y curl git gpg jq

# Instalar chezmoi
curl -fsSL https://get.chezmoi.io | sh -s -- -b "$HOME/.local/bin"
```

---

## Passo 2: Clonar repositório de dotfiles

```bash
# Clonar seus dotfiles
cd ~
git clone https://github.com/seu-usuario/dotfiles.git .local/share/chezmoi
```

---

## Passo 3: Configurar para VPS

### Opção A: Usar configuração pré-definida (Recomendado)

```bash
# Copiar configuração VPS
cp ~/.local/share/chezmoi/.planning/quick/260609-configure-vps-chezmoi/vps-chezmoi-config.yaml ~/.config/chezmoi/chezmoi.yaml

# Copiar .chezmoiignore para VPS
cp ~/.local/share/chezmoi/.planning/quick/260609-configure-vps-chezmoi/vps-.chezmoiignore ~/.local/share/chezmoi/.chezmoiignore
```

### Opção B: Editar manualmente

Edite `~/.config/chezmoi/chezmoi.yaml`:

```yaml
data:
  settings:
    vps: true                    # MARCA COMO VPS
    osid: "linux"                # Linux
    guiAvailable: false          # Sem GUI
    headless: true               # Headless
    hostname: "vps-oracle"       # Hostname do VPS
    username: "ubuntu"           # Usuário padrão
    ssh: true                    # SSH habilitado

  features:
    ai:
      hermes:
        install: true            # Hermes Agent
      omniroute:
        install: true            # OmniRoute
        mode: "vps-server"       # Modo servidor
        domain: ""               # Seu domínio (opcional)
      ollama:
        install: false           # Sem GPU, sem Ollama
      coding_assistants: false   # Sem assistentes de código
      gsd: false                 # Sem GSD
      spec_tools: false          # Sem spec tools

    i3:
      enabled: false             # Sem window manager
    niri:
      enabled: false             # Sem window manager
    kernels:
      install: false             # Sem kernels extras
    rtl8821ce:
      install: false             # Sem driver WiFi
```

---

## Passo 4: Aplicar configuração

```bash
# Inicializar chezmoi
chezmoi init

# Aplicar (dry run primeiro)
chezmoi apply --dry-run

# Aplicar de verdade
chezmoi apply
```

---

## Passo 5: Verificar instalação

```bash
# Verificar se OmniRoute está instalado
which omniroute || echo "OmniRoute não instalado"

# Verificar se Hermes está instalado
which hermes || echo "Hermes não instalado"

# Verificar se Caddy está instalado
which caddy || echo "Caddy não instalado"

# Verificar se Tailscale está instalado
which tailscale || echo "Tailscale não instalado"

# Verificar serviços
systemctl --user list-units | grep -E "(omniroute|hermes|caddy)"
```

---

## Passo 6: Configurar OmniRoute

### 6.1 Configurar domínio (opcional)

Se tem domínio, edite `~/.config/chezmoi/chezmoi.yaml`:

```yaml
data:
  features:
    ai:
      omniroute:
        domain: "omniroute.seudominio.com"
```

### 6.2 Configurar Caddyfile

O Caddyfile é gerenciado pelo chezmoi em `~/.config/caddy/Caddyfile`.

Exemplo básico:

```
omniroute.seudominio.com {
    reverse_proxy localhost:3000
}
```

### 6.3 Reiniciar serviços

```bash
# Recarregar configurações
systemctl --user daemon-reload

# Iniciar OmniRoute
systemctl --user enable --now omniroute.service

# Reiniciar Caddy
sudo systemctl restart caddy
```

---

## Passo 7: Configurar Tailscale

```bash
# Instalar Tailscale (se não instalou pelo chezmoi)
curl -fsSL https://tailscale.com/install.sh | sh

# Autenticar
sudo tailscale up

# Verificar status
tailscale status
```

---

## Scripts que rodam no VPS

### Essenciais (sempre executam):
1. `run_onchange_before_202-install-ubuntu-packages.sh.tmpl` - Pacotes básicos
2. `run_once_after_530-install-caddy.sh.tmpl` - Caddy (se tem domínio)
3. `run_once_after_555-install-tailscale.sh.tmpl` - Tailscale
4. `run_once_after_560-setup-vps-services.sh.tmpl` - Serviços VPS

### Opcionais (feature flags):
1. `run_once_after_504-install-ollama.sh.tmpl` - Ollama (desabilitado por padrão)
2. `run_once_after_512-install-hermes.sh.tmpl` - Hermes Agent
3. `run_once_after_510-install-ai-tools.sh.tmpl` - AI tools (desabilitado)

### Ignorados (via .chezmoiignore):
1. Scripts de desktop/GUI
2. Drivers específicos
3. Window managers
4. Virtualização
5. Compilação de fonte (neovim, tmux)

---

## Solução de Problemas

### "Está instalando coisas desnecessárias"

1. Verifique se `settings.vps: true` está configurado
2. Verifique se `.chezmoiignore` está no lugar certo
3. Rode `chezmoi diff` para ver o que será alterado

### "OmniRoute não inicia"

1. Verifique os logs: `journalctl --user -u omniroute.service`
2. Verifique se a porta está livre: `ss -tlnp | grep :3000`
3. Verifique se o serviço está habilitado: `systemctl --user status omniroute.service`

### "Caddy não funciona"

1. Verifique os logs: `sudo journalctl -u caddy.service`
2. Verifique se o domínio está apontando para o VPS
3. Verifique se a porta 80/443 está aberta no security list do Oracle

### "Quero instalar mais coisas"

1. Edite `~/.config/chezmoi/chezmoi.yaml`
2. Habilite as features necessárias
3. Rode `chezmoi apply`

---

## Comandos Úteis

```bash
# Ver o que seria instalado
chezmoi apply --dry-run

# Ver diff antes de aplicar
chezmoi diff

# Forçar reaplicação
chezmoi apply --force

# Verificar arquivos gerenciados
chezmoi managed

# Verificar arquivos não gerenciados
chezmoi unmanaged

# Verificar estado do chezmoi
chezmoi state
```

---

## Checklist de Segurança

- [ ] SSH configurado com chave pública
- [ ] Firewall configurado (Oracle Cloud Security List)
- [ ] Tailscale autenticado
- [ ] OmniRoute configurado (se usando domínio)
- [ ] Caddy configurado (se usando domínio)
- [ ] Senhas e chaves não commitadas no repositório

---

*Guia gerado em 2026-06-09*
