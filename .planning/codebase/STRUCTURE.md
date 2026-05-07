# Directory Structure

> Last mapped: 2026-05-07

## Root Layout

```
chezmoi/
├── .chezmoiroot              # Points to `home` as the chezmoi source root
├── .git/                     # Git repository
├── README.md                 # Install command (one-liner)
└── home/                     # ← CHEZMOI SOURCE ROOT
    ├── .chezmoi.yaml.tmpl    # Main chezmoi config (environment detection)
    ├── .chezmoidata/          # Data files consumed by templates
    ├── .chezmoiexternals/     # External resource definitions
    ├── .chezmoiignore.tmpl    # OS-conditional ignore rules
    ├── .chezmoiremovedscripts/ # Deprecated scripts
    ├── .chezmoiscripts/       # Lifecycle hook scripts
    ├── .chezmoitemplates/     # Reusable template fragments
    ├── dot_*                  # Home directory dotfiles
    ├── private_dot_*          # Private home directory dotfiles
    └── ...
```

## Key Directories

### `.chezmoidata/` — Template Data
```
.chezmoidata/
├── darwin/
│   ├── fonts.yaml             # macOS font definitions
│   └── packages.toml          # Homebrew, MacPorts, Cask, MAS packages
├── linux/
│   ├── fonts.yaml             # Linux font definitions
│   ├── kernels.yaml           # Linux kernel packages
│   ├── linux.wm.json          # Window manager packages (i3, niri) per distro
│   └── packages/
│       ├── archlinux.yaml     # Arch Linux packages (core, extra, AUR, devops, virt)
│       └── ubuntu.json        # Ubuntu/Debian packages
├── windows/
│   ├── fonts.yaml             # Windows font definitions
│   └── packages.yaml          # Windows package definitions
├── ollama.yaml                # Ollama models & environment config
└── repos.json                 # Git repos to auto-clone (personal, work, other)
```

### `.chezmoiexternals/` — External Dependencies
```
.chezmoiexternals/
├── firefox.toml.tmpl          # Firefox profiles/extensions
├── git.toml.tmpl              # Catppuccin git-delta theme
├── i3.toml.tmpl               # i3 themes/configs
├── icons.toml.tmpl            # Icon theme packs
├── tmux.toml.tmpl             # TPM (Tmux Plugin Manager)
└── wallpapers.toml.tmpl       # Wallpaper collections
```

### `.chezmoiscripts/` — Installation Scripts
```
.chezmoiscripts/
├── darwin/                    # macOS-only scripts
│   ├── run_onchange_after_501-install-darwin-packages-macports.sh.tmpl
│   ├── run_onchange_after_502-install-darwin-packages-homebrew.sh.tmpl
│   └── run_onchange_after_605-clone-my-repos.sh.tmpl
├── linux/                     # Linux-only scripts (25 scripts)
│   ├── run_once_before_100-install-linux-kernels.sh.tmpl
│   ├── run_once_before_102-configure-swapfile-zram.sh.tmpl
│   ├── run_once_before_103-install-rtl8821ce-driver.sh.tmpl
│   ├── run_once_before_104-install-cirrus-driver-for-macbook.tmpl
│   ├── run_once_before_199-install-paru.sh.tmpl
│   ├── run_onchange_before_201-install-arch-packages.sh.tmpl
│   ├── run_onchange_before_202-install-ubuntu-packages.sh.tmpl
│   ├── run_once_before_204-init-zsh.sh.tmpl
│   ├── run_once_before_205-configure-keyboard-xorg.sh.tmpl
│   ├── run_once_before_206-install-fzf.sh.tmpl
│   ├── run_once_before_207-install-nix.sh.tmpl
│   ├── run_once_before_214-install-devops.sh.tmpl
│   ├── run_once_before_215-install-virtualisation.sh.tmpl
│   ├── run_once_before_216-install-wm.sh.tmpl
│   ├── run_once_before_220-configure-bluetooth-arch.sh.tmpl
│   ├── run_once_before_223-compile-nvim.tmpl
│   ├── run_once_before_224-compile-tmux.tmpl
│   ├── run_once_after_504-install-ollama.sh.tmpl
│   ├── run_onchange_after_505-install-ollama-models.sh.tmpl
│   ├── run_onchange_after_506-install-fonts.sh.tmpl
│   ├── run_once_after_522-install-openclaw.sh.tmpl
│   ├── run_once_after_554-install-openvpn3.sh.tmpl
│   ├── run_once_after_555-install-tailscale.sh.tmpl
│   ├── run_once_after_655-configure-vpn-instivo.sh.tmpl
│   └── run_onchange_after_605-clone-my-repos.sh.tmpl
├── unix/                      # Cross-unix scripts (17 scripts — AI tool installs)
│   ├── run_once_after_503-install-mise.sh.tmpl
│   ├── run_once_after_508-install-opencode.sh.tmpl
│   ├── run_once_after_509-install-gemini-cli.sh.tmpl
│   ├── run_once_after_510-install-aider-cli.sh.tmpl
│   ├── run_once_after_511-install-copilot-cli.sh.tmpl
│   ├── run_once_after_512-install-qwen-code-cli.sh.tmpl
│   ├── run_once_after_513-install-kilo-code-cli.sh.tmpl
│   ├── run_once_after_514-install-amp-cli.sh.tmpl
│   ├── run_once_after_515-install-coderabbit-cli.sh.tmpl
│   ├── run_once_after_516-install-claude-code.sh.tmpl
│   ├── run_once_after_517-install-kiro-code-cli.sh.tmpl
│   ├── run_once_after_520-install-openspec-cli.sh.tmpl
│   ├── run_once_after_521-install-speckit-github-cli.sh.tmpl
│   ├── run_once_after_523-install-gsd.sh.tmpl
│   ├── run_once_after_524-install-cursor-cli.sh.tmpl
│   ├── run_once_after_525-install-codex-cli.sh.tmpl
│   └── run_once_after_526-install-openclaude.sh.tmpl
└── windows/                   # Windows-only scripts
    ├── run_onchange_before_201-install-winget-packages.sh.tmpl
    └── run_onchange_before_202-install-scoop-packages.sh.tmpl
```

### `.chezmoitemplates/` — Reusable Guards
```
.chezmoitemplates/
├── common/
│   ├── script_eval_mise
│   ├── script_helper
│   ├── script_is_not_ephemeral
│   ├── script_is_not_headless
│   └── script_validate_completions_path
├── darwin/
│   └── script_darwin_only
├── linux/
│   ├── script_arch_based_only
│   ├── script_linux_only
│   └── script_ubuntu_only
├── windows/
│   └── script_windows_only
└── workplace/
    ├── script_is_instivo
    ├── script_is_not_zup
    └── script_is_zup
```

### Shell Configuration (`dot_zshrc.d/`)
```
dot_zshrc.d/
├── 099-zshenv.zsh.tmpl                    # Env vars
├── 100-install-zinit.zsh.tmpl             # Plugin manager
├── 101-zinit-plugins.zsh.tmpl             # Plugin declarations
├── 102-history.zsh.tmpl                   # History settings
├── 103-fzf.zsh.tmpl                       # Fuzzy finder
├── 104-keybindings.zsh.tmpl               # Key bindings
├── 200-aliases.zsh.tmpl                   # General aliases
├── 201-git-aliases.zsh.tmpl               # Git aliases
├── encrypted_300-ai-api-keys.zsh.age      # AI API keys (encrypted)
├── 301-source-openclaw.zsh.tmpl           # OpenClaw integration
├── 302-aider.zsh.tmpl                     # Aider integration
├── 303-mise.zsh.tmpl                      # mise activation
├── 304-tailscale.zsh.tmpl                 # Tailscale helpers
├── 305-eval-claude-code-router.zsh.tmpl   # Claude router eval
├── 308-eval-direnv.zsh.tmpl               # direnv eval
├── 309-eval-zoxide.zsh.tmpl               # zoxide eval
├── 310-eval-starshipt.zsh.tmpl            # starship eval
├── 311-ollama.zsh.tmpl                    # Ollama env & helpers
├── encrypted_403-instivo.zsh.age          # Instivo work keys
├── encrypted_404-zup-keys.zsh.age         # Zup work keys
├── encrypted_405-github-keys.zsh.age      # GitHub keys
├── 504-zup.zsh.tmpl                       # Zup utility
├── 603-openclaude.zsh.tmpl                # OpenClaude helpers
└── 999-autoload-compinit.zsh.tmpl         # Completion init
```

### Application Configs (`private_dot_config/`)
```
private_dot_config/
├── aichat/config.yaml.tmpl       # AIChat provider config
├── autostart/                    # XDG autostart entries
├── bat/config + themes/          # Bat syntax highlighter
├── dunst/                        # Notification daemon (Linux)
├── git/config.tmpl + config.zup.inc.tmpl  # Git configuration
├── greenclip.toml                # Clipboard manager
├── homebrew/Brewfile.tmpl + ...  # Homebrew bundle (macOS)
├── hypr/hyprland.conf            # Hyprland WM config
├── i3/config + scripts/          # i3 WM config (22KB)
├── kitty/kitty.conf              # Kitty terminal
├── mise/config.toml.tmpl         # Runtime version manager
├── networkmanager_dmenu/          # Network manager menu
├── niri/                         # Niri WM config
│   ├── config.kdl                # Main entrypoint
│   └── cfg/                      # Modular config parts (keybinds, rules, etc.)
├── opencode/opencode.json        # OpenCode AI tool config
├── picom/                        # Compositor (Linux X11)
├── private_Antigravity/          # Antigravity IDE config
├── rbw/config.json               # Bitwarden CLI config
├── starship.toml                 # Prompt config
├── tmux/tmux.conf.tmpl           # Tmux config (270 lines)
├── wezterm/wezterm.lua.tmpl      # WezTerm terminal config
└── xorg.conf.d/                  # X.org display config
```

### Reproducible Environments (`private_dot_local/private_share/environments/`)
```
environments/
├── java.nix, node.nix, php.nix            # Language base configurations
├── flake-python-versions.nix              # Python flake base
├── instivo-ms-auth/                       # Project-specific dev environment
│   ├── devenv.nix, devenv.lock, dot_envrc
├── instivo-ms-fornecedor/                 # Nix flake environment
│   └── flake.nix, flake.lock
└── instivo-receiving-conference-ms/       # Project-specific dev environment
```

### Web Browser Profiles (`private_dot_mozilla/`)
```
private_dot_mozilla/
└── private_firefox/
    ├── installs.ini.tmpl, profiles.ini.tmpl     # Firefox profile routing
    ├── private_fabiosouzadev.default/user.js.tmpl
    └── private_fabiosouzadev.dev-edition-default/user.js.tmpl
```

### Secrets & Encrypted Files
```
# SSH keys
private_dot_ssh/encrypted_private_readonly_zup_ed25519.age
private_dot_ssh/encrypted_private_readonly_zup_ed25519.pub.age

# GPG keys
private_dot_gnupg/encrypted_zup_private.gpg.age
private_dot_gnupg/encrypted_zup_public.gpg.age

# Cloud credentials
dot_aws/encrypted_private_credentials.age

# VPN certificates
private_dot_local/private_share/vpn/encrypted_fabiosouza.crt.age
private_dot_local/private_share/vpn/encrypted_instivo.ovpn.age
private_dot_local/private_share/vpn/encrypted_ca.crt.age
private_dot_local/private_share/vpn/encrypted_fabiosouza.key.age

# API keys & tokens (in zshrc.d)
dot_zshrc.d/encrypted_300-ai-api-keys.zsh.age
dot_zshrc.d/encrypted_403-instivo.zsh.age
dot_zshrc.d/encrypted_404-zup-keys.zsh.age
dot_zshrc.d/encrypted_405-github-keys.zsh.age

# Service auth
private_dot_coderabbit/encrypted_private_auth.json.age
private_dot_openclaw/encrypted_dot_env.age
private_dot_openclaw/private_credentials/encrypted_private_telegram-pairing.json.age
private_dot_openclaw/private_credentials/encrypted_private_telegram-default-allowFrom.json.age
```

## File Statistics

| Category | Count |
|----------|-------|
| **Total files** | ~202 |
| **Encrypted files** | 17 |
| **Template files** (.tmpl) | ~65+ |
| **Shell scripts** | ~47 |
| **Config files** | ~30 |
| **Data files** | ~10 |
