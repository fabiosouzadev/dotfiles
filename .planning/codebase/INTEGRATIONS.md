# External Integrations

**Analysis Date:** 2026-06-12

## AI Gateway: OmniRoute

**OmniRoute** is the central AI API gateway. All AI tools (Claude Code, OpenCode, Aider, Codex, etc.) route through a single local endpoint.

- **Local endpoint**: `http://localhost:20128/v1`
- **VPS mode**: `http://vps-omniroute:20128/v1` via Tailscale
- **Auth**: Encrypted API key in `dot_keys/encrypted_omniroute-key.txt.asc`, decrypted at template apply time
- **Systemd service**: `omniroute.service` (Linux with systemd)
- **Health check**: `GET /health`
- **Dashboard**: `http://localhost:20128`
- **Models list**: `GET /v1/models`
- **Caddy reverse proxy**: `private_dot_config/caddy/Caddyfile.tmpl` (VPS only, adds HTTPS via domain)
- **Sync tool**: `private_dot_local/bin/executable_omniroute-sync.tmpl` — SQLite DB sync between machines

### OmniRoute Config Files
- **Claude Code**: `dot_claude/settings.json.tmpl` — Anthropic-compatible models via OmniRoute
- **OpenCode**: `private_dot_config/opencode/opencode.json.tmpl` — Multiple providers (OmniRoute, Fireworks)
- **Zsh env**: `dot_zshrc.d/605-omniroute.zsh.tmpl` — `OPENAI_BASE_URL`, `OPENAI_API_KEY`, aliases

## AI Coding Tools (CLI)

All tools are installed via `.chezmoiscripts/unix/` and configured through chezmoi templates.

### Claude Code
- **Install**: `run_once_after_516-install-claude-code.sh.tmpl`
- **Config**: `dot_claude/settings.json.tmpl`
- **Models via OmniRoute**: `claude-opus-4-8`, `claude-sonnet-4-6`, `claude-haiku-4-5-20251001`
- **Auth**: Encrypted `encrypted_omniroute-key.txt.asc`

### Claude Code Router
- **Config**: `dot_claude-code-router/config.json`
- **Routes**: Default→Gemini, Background→Ollama, Think→OpenRouter, Long Context→OpenRouter, Web Search→Gemini

### OpenCode
- **Install**: `run_once_after_508-install-opencode.sh.tmpl`
- **Config**: `private_dot_config/opencode/opencode.json.tmpl`
- **Theme**: Catppuccin
- **Default model**: `mimo-v2.5-pro`
- **Plugins**: `opencode-wakatime`
- **Providers**: OmniRoute (`@ai-sdk/openai-compatible`), Fireworks

### Aider
- **Install**: `run_once_after_510-install-aider-cli.sh.tmpl` (curl)
- **Config**: `dot_aider.conf.yaml.tmpl`, `dot_aider.model.settings.yaml.tmpl`
- **Editor**: nvim
- **Models**: Ollama (deepseek-coder, deepseek-r1, llama3.1), OpenRouter (deepseek-chat, kimi-dev-72b)

### Other AI Tools
| Tool | Install | Config |
|------|---------|--------|
| **Codex CLI** | `run_once_after_525-install-codex-cli.sh.tmpl` | `dot_codex/auth.json.tmpl`, `dot_codex/private_config.toml.tmpl` |
| **Copilot CLI** | `run_once_after_511-install-copilot-cli.sh.tmpl` | — |
| **Qwen Code CLI** | `run_once_after_512-install-qwen-code-cli.sh.tmpl` | `dot_qwen/settings.json` |
| **Gemini CLI** | `run_once_after_509-install-gemini-cli.sh.tmpl` | — |
| **Kilo Code CLI** | `run_once_after_513-install-kilo-code-cli.sh.tmpl` | — |
| **Kiro Code CLI** | `run_once_after_517-install-kiro-code-cli.sh.tmpl` | — |
| **Amp CLI** | `run_once_after_514-install-amp-cli.sh.tmpl` | — |
| **CodeRabbit CLI** | `run_once_after_515-install-coderabbit-cli.sh.tmpl` | `private_dot_coderabbit/` (encrypted) |
| **Cursor CLI** | `run_once_after_524-install-cursor-cli.sh.tmpl` | — |
| **OpenClaude** | `run_once_after_526-install-openclaude.sh.tmpl` | — |

## Ollama (Local LLM Server)

- **Data/Config**: `.chezmoidata/ollama.yaml`
- **Linux Install**: `run_once_after_504-install-ollama.sh.tmpl`
- **Model Pull**: `run_onchange_after_505-install-ollama-models.sh.tmpl`
- **Zsh Integration**: `dot_zshrc.d/311-ollama.zsh.tmpl`

### Ollama Environment
| Variable | Value |
|----------|-------|
| `OLLAMA_HOST` | `127.0.0.1:11434` |
| `OLLAMA_CONTEXT_LENGTH` | 8192 |
| `OLLAMA_MAX_LOADED_MODELS` | 1 |
| `OLLAMA_KEEP_ALIVE` | 20m |
| `OLLAMA_NUM_PARALLEL` | 1 |
| `OLLAMA_NUM_THREADS` | 2 |
| `OLLAMA_NEW_ENGINE` | 1 |
| `OLLAMA_LLM_LIBRARY` | cpu |

### Models
- `qwen2.5-coder:0.5b` — Code completion
- `qwen2.5-coder:1.5b` — Code completion
- `gemma4:e2b` — General
- `gemma4:e4b` — General

## OpenClaw (AI Agent)

- **Install**: `run_once_after_522-install-openclaw.sh.tmpl`
- **Config**: `private_dot_openclaw/private_openclaw.json.tmpl`
- **Credentials**: `private_dot_openclaw/private_credentials/` (age-encrypted)
- **Telegram**: `private_dot_openclaw/private_telegram/private_update-offset-default.json`
- **Workspace files**: `IDENTITY.md.tmpl`, `SOUL.md.tmpl`, `AGENTS.md.tmpl`, `TOOLS.md.tmpl`, `USER.md.tmpl`

## AIChat
- **Config**: `private_dot_config/aichat/config.yaml.tmpl`
- **Providers**: Ollama (local), Gemini API, OpenRouter, OpenAI-compatible

## API Providers & Keys

### Configured via Zup Workplace (`dot_zshrc.d/504-zup.zsh.tmpl`)
All provider keys reference `$ZUP_*` env vars (set externally, not in chezmoi):

| Provider | Env Vars | Use Case |
|----------|----------|----------|
| **Ollama** | `OLLAMA_API_KEY` | Local LLM |
| **GitHub** | `GITHUB_TOKEN`, `GH_TOKEN`, `GITHUB_COPILOT_TOKEN` | Git, Copilot |
| **Gemini** | `GEMINI_API_KEY` | Gemini models |
| **Cursor** | `CURSOR_API_KEY` | Cursor IDE |
| **OpenCode** | `OPENCODE_API_KEY` | OpenCode AI |
| **OpenRouter** | `OPENROUTER_API_KEY`, `OPENROUTER_OPENAI_BASE_URL` | Multi-model router |
| **Sweep AI** | `SWEEP_TOKEN` | Sweep AI |
| **DeepSeek** | `DEEPSEEK_API_KEY` | DeepSeek models |
| **Cloudflare** | `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_API_KEY`, `CF_AIG_TOKEN` | Workers AI, AI Gateway |
| **Zhipu AI** | `ZAI_API_KEY` | Chinese AI providers |
| **Cerebras** | `CEREBRAS_API_KEY` | Cerebras models |
| **Mistral** | `MISTRAL_API_KEY` | Mistral models |
| **Fireworks** | `FIREWORKS_API_KEY` | Fireworks AI |
| **KiloCode** | `KILOCODE_API_KEY` | KiloCode |
| **GitLab** | `GITLAB_TOKEN`, `GITLAB_HOST` | Zup/Claro Brasil self-hosted |

### Configured via OmniRoute (encrypted in repo)
| Provider | Env Vars | Config File |
|----------|----------|-------------|
| **Anthropic** | `ANTHROPIC_AUTH_TOKEN` | `dot_claude/settings.json.tmpl` |
| **OpenAI** | `OPENAI_API_KEY` | `dot_codex/auth.json.tmpl`, `dot_zshrc.d/605-omniroute.zsh.tmpl` |

## Git & GitHub

- **GPG signing**: Enabled (key: `F587673EDB1A5C95`)
- **Credential helper**: `gh auth git-credential`
- **Diff**: delta with Catppuccin Mocha theme, side-by-side
- **Work config**: Conditional include for `config.zup.inc` when `workplace == "Zup"`
- **VPS config**: Conditional include for `config.vps.inc`

### Auto-cloned Repos (via `.chezmoidata/repos.json`)
- **Personal**: `personal`, `polybar-themes`, `wallpapers`, `neovim`, `kickstart.nvim`
- **Zup Work**: `ms-interactions`, `flex-suspension-ms` (Claro Brasil GitLab)
- **Other**: `LazyVim/starter`, `kickstart.nvim`, `LazyVim/LazyVim`

## VPN & Networking

| Service | Install Script | Integration |
|---------|---------------|-------------|
| **Tailscale** | `run_once_after_555-install-tailscale.sh.tmpl` | `304-tailscale.zsh.tmpl` |
| **OpenVPN3** | `run_once_after_554-install-openvpn3.sh.tmpl` | Instivo VPN config |
| **Instivo VPN** | `run_once_after_655-configure-vpn-instivo.sh.tmpl` | Encrypted VPN certs |

## Cloud & DevOps

| Service | Tools | Config |
|---------|-------|--------|
| **AWS** | AWS CLI v2 | `dot_aws/private_config.tmpl` (region: us-east-2), encrypted credentials |
| **GitHub** | `gh` CLI | Git credential helper |
| **GitLab** | `glab` CLI | `private_dot_config/glab-cli/private_config.yml.tmpl` |
| **Docker/Podman** | docker, podman, nerdctl, distrobox, buildx | Installed via packages |
| **Kubernetes** | k9s, openlens | — |
| **DevPod** | devpod | — |

## Password Management

| Tool | Config | Purpose |
|------|--------|---------|
| **rbw** (Bitwarden CLI) | `private_dot_config/rbw/config.json` | CLI password manager |
| **Bitwarden** | Installed via packages | GUI password manager |
| **Ente Auth** | Installed on macOS | 2FA authenticator |
| **GnuPG** | `private_dot_gnupg/` (encrypted) | GPG keys |

## Infrastructure

| Component | Technology | Config |
|-----------|-----------|--------|
| **Reverse Proxy** (VPS) | Caddy | `private_dot_config/caddy/Caddyfile.tmpl` — HTTPS, security headers |
| **Encryption** | age + GPG | `dot_keys/` (encrypted), `~/.config/chezmoi/key.txt` |
| **Secrets** | age-encrypted files | Decrypted at template apply time via `{{ include $key \| decrypt \| trim }}` |
| **Cross-machine sync** | OmniRoute Sync | `executable_omniroute-sync.tmpl` — encrypted SQLite export |

## Browsers

| Browser | Platform | Config |
|---------|----------|--------|
| **Firefox Developer** | Linux | Templated profiles, custom `user.js.tmpl` |
| **Brave Nightly** | Linux, macOS | — |
| **Google Chrome Beta** | macOS | — |
| **Chromium** | macOS, Linux (Ubuntu) | — |

## Window Managers (Linux)

| WM | Config | Type |
|----|--------|------|
| **i3** | `private_dot_config/i3/config` | X11 tiling |
| **Hyprland** | `private_dot_config/hypr/hyprland.conf` | Wayland compositor |
| **Niri** | `private_dot_config/niri/config.kdl` | Scrollable tiling Wayland |

### WM Components
- **Bar**: Polybar (i3), Waybar (niri)
- **Launcher**: Rofi (i3), Fuzzel (niri)
- **Notifications**: Dunst (i3), Mako (niri)
- **Clipboard**: greenclip (i3), cliphist (niri)
- **Compositor**: picom (i3)
- **Idle/Lock**: swaylock, swayidle (niri)

## Secrets Architecture

All secrets follow the same pattern:
1. Encrypted with `age` at rest in `dot_keys/` or `private_*` directories
2. Decrypted during `chezmoi apply` via Go template syntax:
   ```
   {{ $key := joinPath .chezmoi.sourceDir "dot_keys" "encrypted_*-key.txt.asc" -}}
   {{ include $key | decrypt | trim }}
   ```
3. Written to the target file as plaintext in `$HOME`
4. Never committed to git unencrypted

**Key files** (notable existence only):
- `dot_keys/encrypted_omniroute-key.txt.asc` — OmniRoute API key
- `dot_keys/encrypted_freemodels-key.txt.asc` — Free models API key
- Encrypted files in `private_dot_gnupg/`, `private_dot_aws/`, `private_dot_coderabbit/`, `private_dot_openclaw/private_credentials/`

---

*Integration audit: 2026-06-12*
