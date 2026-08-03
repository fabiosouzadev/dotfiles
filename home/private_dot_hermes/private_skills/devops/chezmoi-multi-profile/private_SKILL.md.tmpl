---
name: chezmoi-multi-profile
description: "Manage multi-profile chezmoi: personal, work, vps."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [chezmoi, profiles, multi-profile, feature-flags, work, vps]
    category: devops
requires_toolsets: [terminal, file]
supersedes: []
---

# ChezMoi Multi-Profile Skill

**Trigger**: Use when configuring or debugging multi-profile chezmoi setups — personal laptop, work laptop, VPS, each with distinct feature flags, packages, and configurations.

**Goal**: Provide complete reference for profile management patterns from `fabiosouzadev/dotfiles` enabling seamless switching between personal, work (Zup), and VPS (Oracle Cloud) environments.

---

## 1. Profile Architecture

### Three Profiles, One Repo

| Profile | Hostname Pattern | User | GUI | SSH | Use Case |
|---------|------------------|------|-----|-----|----------|
| **personal** | `*` (default) | fabio | ✅ | ❌ | Personal laptop (Linux/macOS/Windows) |
| **work** | `*zwpe0f96cn*` | fabio | ✅ | ❌ | Zup-issued laptop |
| **vps** | `instance-*` or `CHEZMOI_VPS` | ubuntu | ❌ | ✅ | Oracle Cloud ARM64 VPS |

### Profile Resolution Logic (`.chezmoi.yaml.tmpl`)

```go
{{- /* Workplace detection */}}
{{- $hostLower := lower .chezmoi.hostname }}
{{- $ismanaged := ($hostLower | contains "zwpe0f96cn") }}

{{- /* VPS detection */}}
{{- $isVps := or
    (env "CHEZMOI_VPS" | not | not)
    (hasPrefix "instance-" $hostLower)
    ($hostLower | contains "vps")
    ($hostLower | contains "vnic")
    (and (eq .chezmoi.os "linux") (eq .chezmoi.username "ubuntu") $sshSession (not $guiAvailable))
  }}

{{- /* Profile resolution: explicit > VPS > workplace > personal */}}
{{- $profile := env "CHEZMOI_PROFILE" | default ($ismanaged | ternary "work" "personal") }}
{{- if $isVps }}{{ $profile = "vps" }}{{ end }}

{{- /* Export for templates */}}
data:
  settings:
    profile: {{ $profile | quote }}
    vps: {{ $isVps }}
    ismanaged: {{ $ismanaged }}
```

---

## 2. Feature Flag Hierarchy

### Base Features (All Profiles)

```go
{{- $baseFeatures := dict
  "runtime" (dict "mise" true)
  "shell" (dict "zsh" true "zinit" true "fzf" true "zoxide" true "atuin" true)
  "editor" (dict "neovim" true "helix" true)
  "terminal" (dict "kitty" false "ghostty" false "wezterm" false)
  "ai" (dict
    "coding_assistants" true
    "hermes" (dict "dashboard" (dict "enabled" false))
    "omniroute" (dict "enabled" false)
    "coding_orchestrator" (dict "enabled" false)
    "ollama" (dict "enabled" false)
  )
  "gui" (dict "enabled" (not .settings.headless))
  "sudo" (dict "available" (and (not .settings.ephemeral) (not .settings.codespaces) (not .settings.devContainer)))
}}
```

### Profile-Specific Overrides

```go
{{- $features := merge $baseFeatures (dict) }}

{{- /* ===== PERSONAL LAPTOP ===== */}}
{{- if eq $profile "personal" }}
{{-   $features = merge $features (dict
      "ai" (dict
        "hermes" (dict "dashboard" (dict "enabled" false))
        "omniroute" (dict "enabled" false)
        "ollama" (dict "enabled" true)
        "local_llm" true
      )
      "gui" (dict "enabled" true "wayland" true "hyprland" true)
      "desktop" (dict
        "window_manager" true
        "fonts" true
        "drivers" true
        "bluetooth" true
        "audio" (dict "pipewire" true)
      )
      "development" (dict
        "containers" (dict "docker" true "distrobox" true)
        "kubernetes" (dict "kind" true "kubectl" true)
      )
    ) }}

{{- /* ===== WORK LAPTOP (ZUP) ===== */}}
{{- else if eq $profile "work" }}
{{-   $features = merge $features (dict
      "ai" (dict
        "hermes" (dict "dashboard" (dict "enabled" false))
        "omniroute" (dict "enabled" false)
        "coding_orchestrator" (dict "enabled" false)
        "ollama" (dict "enabled" false)
      )
      "gui" (dict "enabled" true "wayland" true "hyprland" true)
      "desktop" (dict
        "window_manager" true
        "fonts" true
        "drivers" false
        "bluetooth" true
      )
      "workplace" (dict
        "zup" true
        "vpn" (dict "instivo" true)
        "git" (dict "signing" true "email" "fabio.vanderlei@zup.com.br")
        "ssh" (dict "keys" ["work-ed25519"])
      )
      "development" (dict
        "containers" (dict "docker" false "podman" true)
        "kubernetes" false
      )
      "sudo" (dict "available" false)
    ) }}

{{- /* ===== VPS (ORACLE CLOUD ARM64) ===== */}}
{{- else if eq $profile "vps" }}
{{-   $features = merge $features (dict
      "ai" (dict
        "hermes" (dict
          "dashboard" (dict "enabled" true "port" 9119 "domain" "hermes.fabiosouzadev.duckdns.org")
          "agent_memory" true
        )
        "omniroute" (dict "enabled" true "port" 20128 "domain" "omniroute.fabiosouzadev.duckdns.org")
        "coding_orchestrator" (dict "enabled" true "schedule" "0 2 * * *" "budget_per_night" 5 "budget_per_task" 2)
        "ollama" (dict "enabled" false)
      )
      "gui" (dict "enabled" false)
      "desktop" (dict "window_manager" false "fonts" false "drivers" false "bluetooth" false "audio" false)
      "vps" (dict
        "dockge" true
        "caddy" true
        "tailscale" true
        "duckdns" true
        "agentmemory" true
        "monitoring" (dict "uptime_kuma" true "prometheus" false)
      )
      "development" (dict
        "containers" (dict "docker" true "dockge" true)
        "kubernetes" false
      )
      "sudo" (dict "available" true)
      "security" (dict "fail2ban" true "ufw" true "ssh_hardening" true)
    ) }}
{{- end }}

data:
  features: $features
```

---

## 3. Data Files Per Profile

### Structure

```
home/.chezmoidata/
├── common/
│   ├── packages.yaml          # Shared packages
│   ├── repos.yaml             # Shared repos
│   └── ai_tools.yaml          # Shared AI tools
├── darwin/
│   ├── packages.yaml          # macOS packages (brew)
│   ├── fonts.yaml             # macOS fonts
│   └── defaults.yaml          # macOS defaults
├── linux/
│   ├── packages.yaml          # Linux packages (apt/pacman/dnf)
│   ├── fonts.yaml             # Linux fonts
│   ├── nvidia.yaml            # NVIDIA drivers (non-VPS)
│   └── virtualbox.yaml        # VirtualBox (non-VPS)
├── windows/
│   ├── packages.yaml          # Windows packages (scoop/winget)
│   └── scoop_buckets.yaml
├── vps/
│   ├── packages.yaml          # VPS packages (minimal)
│   ├── features.yaml          # VPS feature overrides
│   └── secrets.toml.age       # VPS secrets (age-encrypted)
├── termux/
│   └── packages.yaml          # Termux packages
└── work/
    └── workplace.yaml         # Work-specific config
```

### Example: VPS Features Override (`.chezmoidata/vps/features.yaml`)

```yaml
ai:
  coding_assistants: true
  hermes:
    dashboard:
      enabled: true
      port: 9119
      domain: "hermes.fabiosouzadev.duckdns.org"
  omniroute:
    enabled: true
    port: 20128
    domain: "omniroute.fabiosouzadev.duckdns.org"
  coding_orchestrator:
    enabled: true
    schedule: "0 2 * * *"
    budget_per_night: 5
    budget_per_task: 2
  ollama:
    enabled: false

vps:
  dockge: true
  caddy: true
  tailscale: true
  duckdns: true
  agentmemory: true
```

### Loading in `.chezmoi.yaml.tmpl`

```go
{{- /* Load profile-specific data */}}
{{- $common := fromYaml (include ".chezmoidata/common/packages.yaml") }}
{{- $osData := fromYaml (include (printf ".chezmoidata/%s/packages.yaml" .chezmoi.os)) }}
{{- $vpsData := dict }}
{{- if .settings.vps }}
{{-   $vpsData = fromYaml (include ".chezmoidata/vps/packages.yaml") }}
{{- end }}

{{- /* Merge with profile precedence: common < os < vps */}}
{{- $packages := merge $common $osData }}
{{- $packages = merge $packages $vpsData }}

data:
  packages: $packages
```

---

## 4. Conditional Script Execution

### In `.chezmoiignore.tmpl`

```go
{{- /* Exclude VPS scripts on non-VPS */}}
{{- if (not .settings.vps) }}
.chezmoiscripts/vps/**
{{- end }}

{{- /* Exclude desktop scripts on VPS */}}
{{- if .settings.vps }}
.chezmoiscripts/linux/run_once_before_216-install-wm.sh.tmpl
.chezmoiscripts/linux/run_once_after_220-configure-wm.sh.tmpl
.chezmoiscripts/linux/run_once_after_230-configure-keyboard.sh.tmpl
.chezmoiscripts/linux/run_once_after_240-configure-bluetooth.sh.tmpl
.chezmoidata/linux/fonts.yaml
.chezmoidata/linux/nvidia.yaml
.chezmoidata/linux/virtualbox.yaml
.chezmoidata/linux/nixos.yaml
.mozilla/**
.config/gtk-*/
.config/qt*/
.config/systemd/user/*.service
{{- end }}

{{- /* Exclude work scripts on non-work */}}
{{- if (not .features.workplace.zup) }}
.chezmoiscripts/linux/run_once_after_530-setup-zup-vpn.sh.tmpl
.chezmoidata/work/**
{{- end }}
```

### In Script Templates (Guards)

```bash
#!/usr/bin/env bash

# Ephemeral guard (CI, Codespaces, etc.)
{{ template "common/script_is_not_ephemeral" . }}

# Headless guard (VPS, SSH, WSL, container, Termux)
{{ template "common/script_is_not_headless" . }}

# Workplace guard (block on Zup laptop)
{{ template "common/script_is_not_workplace" . }}

# VPS-only guard
{{- if not .settings.vps }}
exit 0
{{- end }}

{{ template "common/script_helper" . }}
{{ template "common/script_requires_sudo" . }}

info ">>>>>> 🖥️ VPS-Only Script 🖥️ <<<<<<"
```

---

## 5. Workplace-Specific Configurations

### Zup Workplace (`.chezmoidata/work/workplace.yaml`)

```yaml
git:
  email: "fabio.vanderlei@zup.com.br"
  signing_key: "work-gpg-key-id"
  gpg_program: "gpg"

ssh:
  keys:
    - name: "work-ed25519"
      path: "~/.ssh/id_ed25519_work"
      host: "github.com"
      user: "git"

vpn:
  instivo:
    config_url: "https://vpn.instivo.com/config.ovpn"
    autostart: false

tools:
  bob: true              # Bob the builder (Zup internal)
  aws_profile: "zup-prod"
  kubectl_context: "zup-cluster"

shell:
  aliases:
    zup-deploy: "bob deploy"
    zup-logs: "bob logs"
```

### In Zsh Template (`dot_zshrc.tmpl`)

```go
{{- if .features.workplace.zup }}
# Zup Workplace Configuration
source "{{ .chezmoi.homeDir }}/.config/zup-env.zsh"

# Work-specific aliases
alias zup-deploy="bob deploy"
alias zup-logs="bob logs --tail=100"
alias zup-shell="bob shell"

# VPN helper
zup-vpn() {
  sudo openvpn --config ~/.config/instivo/config.ovpn
}
{{- end }}
```

---

## 6. Testing Profiles

### Dry Run with Profile Override

```bash
# Test personal profile
chezmoi apply --dry-run --verbose --data='{"settings":{"profile":"personal","vps":false,"ismanaged":false}}'

# Test work profile
chezmoi apply --dry-run --verbose --data='{"settings":{"profile":"work","vps":false,"ismanaged":true}}'

# Test VPS profile
chezmoi apply --dry-run --verbose --data='{"settings":{"profile":"vps","vps":true,"ismanaged":false}}'
```

### Unit Tests

```bash
#!/usr/bin/env bash
# test_profiles.sh

test_profile() {
  local profile=$1
  local vps=$2
  local ismanaged=$3
  local expected_feature=$4
  
  data="{\"settings\":{\"profile\":\"$profile\",\"vps\":$vps,\"ismanaged\":$ismanaged}}"
  output=$(chezmoi execute-template --data="$data" home/.chezmoi.yaml.tmpl)
  
  if echo "$output" | grep -q "$expected_feature"; then
    echo "✅ PASS: $profile - $expected_feature"
  else
    echo "❌ FAIL: $profile - $expected_feature missing"
  fi
}

# Personal: ollama enabled
test_profile "personal" "false" "false" "ollama.*enabled.*true"

# Work: ollama disabled, zup enabled
test_profile "work" "false" "true" "ollama.*enabled.*false"
test_profile "work" "false" "true" "zup.*true"

# VPS: hermes dashboard enabled, no gui
test_profile "vps" "true" "false" "hermes.*dashboard.*enabled.*true"
test_profile "vps" "true" "false" "gui.*enabled.*false"
```

---

## 7. Switching Profiles Manually

### Temporary Override (Single Apply)

```bash
# Force VPS profile on any machine
CHEZMOI_PROFILE=vps chezmoi apply

# Force personal profile on work machine
CHEZMOI_PROFILE=personal chezmoi apply
```

### Permanent Override (Environment)

```bash
# In ~/.bashrc or ~/.zshrc.local
export CHEZMOI_PROFILE=personal
export CHEZMOI_VPS=false
```

### Via ChezMoi Config

```toml
# ~/.config/chezmoi/chezmoi.yaml
data:
  settings:
    profile: "personal"
    vps: false
```

---

## 8. Adding a New Profile

### 1. Add Detection Logic

```go
# In .chezmoi.yaml.tmpl
{{- $isNewProfile := or
    (env "CHEZMOI_NEWPROFILE" | not | not)
    ($hostLower | contains "newprofile-identifier")
  }}
```

### 2. Add to Profile Resolution

```go
{{- $profile := env "CHEZMOI_PROFILE" | default ($ismanaged | ternary "work" ($isNewProfile | ternary "newprofile" "personal")) }}
{{- if $isVps }}{{ $profile = "vps" }}{{ end }}
{{- if $isNewProfile }}{{ $profile = "newprofile" }}{{ end }}
```

### 3. Add Feature Overrides

```go
{{- else if eq $profile "newprofile" }}
{{-   $features = merge $features (dict
      "ai" (dict "hermes" (dict "dashboard" (dict "enabled" false)))
      "custom_feature" true
    ) }}
```

### 4. Add Data Files

```
home/.chezmoidata/newprofile/
├── packages.yaml
└── features.yaml
```

### 5. Add Ignore Patterns

```go
{{- if (not (eq .settings.profile "newprofile")) }}
.chezmoiscripts/newprofile/**
.chezmoidata/newprofile/**
{{- end }}
```

---

## 9. Debugging Profiles

```bash
# Show resolved profile and features
chezmoi execute-template home/.chezmoi.yaml.tmpl | grep -A 100 "features:"

# Show settings
chezmoi execute-template home/.chezmoi.yaml.tmpl | grep -A 20 "settings:"

# Trace which profile branch executed
chezmoi apply --trace 2>&1 | grep -E "(personal|work|vps|profile)"

# List all profile-specific files
find home -path "*/personal/*" -o -path "*/work/*" -o -path "*/vps/*" | sort
```

---

## 10. Common Issues & Fixes

| Issue | Cause | Fix |
|-------|-------|-----|
| Work config on personal machine | Hostname contains `zwpe0f96cn` | Make detection more specific or override `CHEZMOI_PROFILE` |
| VPS profile not detected | Heuristics failed | Set `CHEZMOI_VPS=true` in VPS environment |
| Feature not overriding | Merge order wrong | Ensure profile merge happens AFTER base merge |
| Script runs on wrong profile | Missing guard | Add `{{- if not .settings.vps }}exit 0{{- end }}` |
| Package missing on OS | Data file not loaded | Check `.chezmoidata/{os}/packages.yaml` exists |

---

## 11. Related Skills

| Skill | Relationship |
|-------|--------------|
| `chezmoi-architecture` | Prerequisite: understands data flow |
| `chezmoi-template-patterns` | Templates use feature flags |
| `chezmoi-environment-detection` | Profile resolution logic |
| `chezmoi-script-lifecycle` | Guards use profile flags |
| `chezmoi-ignore-patterns` | Conditional exclusion per profile |
| `chezmoi-secret-management` | Profile-specific secrets (VPS) |
| `dotfiles-workplace-zup` | Work profile specifics |
| `dotfiles-vps-bootstrap` | VPS profile specifics |

---

## 12. References

- **Repo profile logic**: `fabiosouzadev/dotfiles` → `home/.chezmoi.yaml.tmpl` (lines 1-200)
- **ChezMoi data merging**: https://www.chezmoi.io/user-guide/templates/data/
- **Profile docs**: `docs/CONFIGURATION.md`

---

*Generated via Loop Engineering Mode — Phase 4: Skill Creation. Validated against live repo analysis.*