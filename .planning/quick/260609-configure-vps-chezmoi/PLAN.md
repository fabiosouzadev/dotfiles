# Quick Task: Configurar chezmoi para VPS (Oracle Cloud Free Tier)

**Objetivo:** Configurar o chezmoi para instalar apenas o necessário no VPS, evitando pacotes de outros ambientes Ubuntu.

## Contexto

- VPS: Oracle Cloud Free Tier (Ubuntu)
- Uso: OmniRoute + Hermes Agent
- Problema: chezmoi instala coisas desnecessárias de outros ambientes

## Análise

### O que o VPS precisa:

1. **OmniRoute** - Servidor de roteamento AI
2. **Hermes Agent** - Agente de IA
3. **Caddy** - Reverse proxy (para domínio)
4. **Tailscale** - VPN
5. **Ferramentas básicas** - git, curl, etc.

### O que NÃO precisa (GUI/desktop):

- Browsers (chromium, brave, firefox, chrome)
- Editores (VS Code, VSCodium, Cursor, IntelliJ)
- Apps desktop (Signal, Obsidian, VLC, etc.)
- Window managers (i3, Niri)
- Drivers (RTL8821CE, Cirrus)
- Ferramentas de virtualização (QEMU, libvirt)
- Fontes desktop
- Ollama (se não vai rodar LLMs localmente)

## Tarefas

### Tarefa 1: Criar configuração VPS para chezmoi

**Ação:** Criar arquivo de configuração VPS que:
1. Define `settings.vps: true`
2. Configura `features.ai.omniroute.mode: "vps-server"`
3. Configura `features.ai.hermes.install: true`
4. Desabilita features desnecessárias

**Arquivo:** Criar exemplo de configuração VPS

### Tarefa 2: Criar .chezmoiignore para VPS

**Ação:** Criar `.chezmoiignore` que:
1. Ignora scripts de desktop/GUI
2. Ignora drivers específicos
3. Ignora window managers
4. Ignora apps desktop

### Tarefa 3: Criar guia de setup VPS

**Ação:** Criar guia passo-a-passo:
1. Como configurar o chezmoi para VPS
2. Quais features habilitar
3. Como verificar se está funcionando

**Verificação:** Guia criado em `.planning/quick/260609-configure-vps-chezmoi/VPS-SETUP-GUIDE.md`

## Prioridade
- **Alta** - Configuração VPS

## Tempo Estimado
- Tarefa 1: 10 minutos
- Tarefa 2: 10 minutos
- Tarefa 3: 10 minutos
