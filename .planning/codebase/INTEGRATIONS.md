# External Integrations

> Last mapped: 2026-05-07

## AI Coding Tools

The dotfiles manage an extensive AI coding tools ecosystem:

### CLI-based AI Tools (installed via `home/.chezmoiscripts/unix/`)

| Tool | Install Script | Config Location |
|------|---------------|-----------------|
| **Claude Code** | `run_once_after_516-install-claude-code.sh.tmpl` | — |
| **Claude Code Router** | `dot_claude-code-router/config.json` | Routes to Gemini, OpenRouter, Ollama |
| **Aider** | `run_once_after_510-install-aider-cli.sh.tmpl` | `dot_aider.conf.yaml.tmpl`, `dot_aider.model.settings.yaml.tmpl` |
| **OpenCode** | `run_once_after_508-install-opencode.sh.tmpl` | `private_dot_config/opencode/opencode.json` |
| **Gemini CLI** | `run_once_after_509-install-gemini-cli.sh.tmpl` | — |
| **Copilot CLI** | `run_once_after_511-install-copilot-cli.sh.tmpl` | — |
| **Qwen Code CLI** | `run_once_after_512-install-qwen-code-cli.sh.tmpl` | `dot_qwen/settings.json` |
| **Kilo Code CLI** | `run_once_after_513-install-kilo-code-cli.sh.tmpl` | — |
| **Amp CLI** | `run_once_after_514-install-amp-cli.sh.tmpl` | — |
| **CodeRabbit CLI** | `run_once_after_515-install-coderabbit-cli.sh.tmpl` | `private_dot_coderabbit/encrypted_private_auth.json.age` |
| **Kiro Code CLI** | `run_once_after_517-install-kiro-code-cli.sh.tmpl` | — |
| **Codex CLI** | `run_once_after_525-install-codex-cli.sh.tmpl` | `dot_codex/private_config.toml.tmpl` |
| **OpenClaude** | `run_once_after_526-install-openclaude.sh.tmpl` | `603-openclaude.zsh.tmpl` |
| **OpenSpec CLI** | `run_once_after_520-install-openspec-cli.sh.tmpl` | — |
| **SpecKit GitHub CLI** | `run_once_after_521-install-speckit-github-cli.sh.tmpl` | — |
| **Cursor CLI** | `run_once_after_524-install-cursor-cli.sh.tmpl` | — |
| **GSD** | `run_once_after_523-install-gsd.sh.tmpl` | — |
| **Antigravity** | Installed via package managers | `private_dot_config/private_Antigravity/` |
| **AIChat** | System package (Arch) | `private_dot_config/aichat/config.yaml.tmpl` |

### AI Providers Configuration

#### Claude Code Router (`dot_claude-code-router/config.json`)
Routes requests across multiple providers:
- **Default**: Gemini → `gemini-2.5-flash`
- **Background**: Ollama → `qwen2.5-coder:1.5b`
- **Think**: OpenRouter → `openai/gpt-oss-20b:free`
- **Long Context**: OpenRouter → `openai/gpt-oss-20b:free` (threshold: 60k tokens)
- **Web Search**: Gemini → `gemini-2.5-flash`

#### OpenCode (`private_dot_config/opencode/opencode.json`)
Configured with Ollama and OpenRouter providers, models include:
- kimi-k2.6/k2.5:cloud, qwen3.5/3-coder:cloud, glm-5.1/4.7:cloud, gemma4, gpt-oss:120b-cloud

#### AIChat (`private_dot_config/aichat/config.yaml.tmpl`)
Providers: Ollama (local), Gemini API, OpenRouter

## Ollama (Local LLM Server)

| Config | Location |
|--------|----------|
| **Data** | `.chezmoidata/ollama.yaml` |
| **Install Script** | `run_once_after_504-install-ollama.sh.tmpl` (Linux) |
| **Model Pull** | `run_onchange_after_505-install-ollama-models.sh.tmpl` |
| **Zsh Integration** | `dot_zshrc.d/311-ollama.zsh.tmpl` |

### Ollama Models
- `qwen2.5-coder:0.5b`, `:1.5b`, `:3b` — Code completion & coding
- `qwen3:4b` — Fast answers (OpenClaw)
- `llama3.2:3b` — General (OpenClaw)
- `gemma3n:e2b` — General (OpenClaw)

### Ollama Environment
- Host: `127.0.0.1:11434`
- Context length: 64000
- Max loaded models: 2
- KV Cache: q5_0
- Flash attention enabled

## OpenClaw

| Config | Location |
|--------|----------|
| **Install** | `run_once_after_522-install-openclaw.sh.tmpl` |
| **Config** | `private_dot_openclaw/private_openclaw.json.tmpl` |
| **Credentials** | `private_dot_openclaw/private_credentials/` (encrypted) |
| **Telegram Integration** | `private_dot_openclaw/private_telegram/` |
| **Zsh Integration** | `dot_zshrc.d/301-source-openclaw.zsh.tmpl` |

## Git & GitHub

| Feature | Details |
|---------|---------|
| **User** | Fabio Souza (`fabiovanderlei.developer@gmail.com`) |
| **GPG Signing** | Enabled (key: `9D79F9FD64781516`) |
| **Credential Helper** | `gh auth git-credential` |
| **Diff Tool** | delta (Catppuccin theme, side-by-side) |
| **Work Git Config** | Conditional include for `Workspaces/Work/Zup/` path |

### Git Repos (auto-cloned via `run_onchange_after_605-clone-my-repos.sh.tmpl`)
- **Personal**: personal, polybar-themes, wallpapers, neovim config, kickstart.nvim
- **Work (Zup)**: ms-interactions, flex-suspension-ms (Claro Brasil GitLab)
- **Others**: LazyVim starter, kickstart.nvim upstream, LazyVim source

## VPN & Networking

| Service | Details |
|---------|---------|
| **Tailscale** | Installed via script (`run_once_after_555-install-tailscale.sh.tmpl`), zsh integration (`304-tailscale.zsh.tmpl`) |
| **OpenVPN3** | Installed on Linux (`run_once_after_554-install-openvpn3.sh.tmpl`) |
| **Instivo VPN** | Work VPN config (`run_once_after_655-configure-vpn-instivo.sh.tmpl`) |
| **VPN Certs** | Encrypted age files in `private_dot_local/private_share/vpn/` |

## Cloud & DevOps

| Service | Purpose |
|---------|---------|
| **AWS** | CLI configured, credentials encrypted (`dot_aws/encrypted_private_credentials.age`) |
| **GitHub CLI** | Credential helper for git |
| **Docker/Podman** | Container runtimes (Linux: docker+podman, macOS: podman+colima+lima) |
| **Kubernetes** | k9s TUI tool |
| **DevPod** | Dev environments |

## Password Management

| Tool | Config |
|------|--------|
| **rbw** (Bitwarden CLI) | `private_dot_config/rbw/config.json` |
| **Bitwarden** (GUI) | Installed via package managers |
| **Ente Auth** | Installed on macOS |
| **GnuPG** | GPG keys encrypted with age (`private_dot_gnupg/`) |

## Window Managers (Linux)

| WM | Config | Features |
|----|--------|----------|
| **i3** | `private_dot_config/i3/config` (22KB) | Full config with polybar, rofi, picom, dunst |
| **Hyprland** | `private_dot_config/hypr/hyprland.conf` | Wayland compositor |
| **Niri** | `private_dot_config/niri/config.kdl` | Scrollable tiling Wayland |

## Browser

| Browser | Platform |
|---------|----------|
| Firefox Developer Edition | Linux (with managed profiles via externals) |
| Brave Nightly | Both |
| Chromium | macOS |
| Google Chrome Beta | macOS |
