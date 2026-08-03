---
name: chezmoi-ignore-patterns
description: "Configure .chezmoiignore.tmpl for conditional exclusion."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [chezmoi, ignore, patterns, conditional, exclusion]
    category: devops
requires_toolsets: [terminal, file]
supersedes: []
---

# ChezMoi Ignore Patterns Skill

**Trigger**: Use when configuring which files chezmoi should NOT deploy — conditional exclusion by OS, profile, VPS, headless, ephemeral, or workplace.

**Goal**: Provide complete reference for ignore pattern patterns from `fabiosouzadev/dotfiles` enabling precise control over what gets deployed to each target machine.

---

## 1. Ignore File Architecture

### Two-Layer Ignore System

| File | Purpose | Template? |
|------|---------|-----------|
| `.chezmoiignore.tmpl` | Main ignore file with Go template conditionals | ✅ Yes |
| `.chezmoiignore` | Static patterns (rarely used) | ❌ No |

### Processing Order

```
1. Read .chezmoiignore.tmpl
2. Execute as Go template (with full data context)
3. Parse resulting patterns
4. Apply to source tree during apply/diff/status
```

---

## 2. Pattern Syntax

### Basic Patterns (gitignore-compatible)

```
# Exact file
exact-file.txt

# Directory (all contents)
dir/
dir/**

# Glob patterns
*.log
*.tmp
**/node_modules/**

# Negation (force include)
!important.log

# Comments
# This is a comment
```

### Template Conditionals (Go Template)

```go
{{- if .settings.vps }}
# Only on VPS
.vps-only/
{{- end }}

{{- if not .settings.vps }}
# Only on NON-VPS
.desktop-only/
{{- end }}

{{- if .features.workplace.zup }}
# Only on Zup workplace
.work-only/
{{- end }}
```

---

## 3. Complete `.chezmoiignore.tmpl` from Repo

### Header

```go
# {{ .chezmoi.sourceFile }} - Auto-generated ignore patterns
# Profile: {{ .settings.profile }}
# OS: {{ .chezmoi.os }}/{{ .chezmoi.arch }}
# VPS: {{ .settings.vps }}
# Ephemeral: {{ .settings.ephemeral }}
# Headless: {{ .settings.headless }}
# Workplace: {{ .features.workplace.zup }}

# ===== UNIVERSAL EXCLUDES (all profiles) =====
.git/
.gitignore
.github/
.gitlab/
.vscode/
.idea/
*.swp
*.swo
*~
.DS_Store
Thumbs.db
*.bak
*.orig
```

### Profile-Specific Excludes

```go
{{- /* ===== VPS EXCLUDES (desktop stuff not needed) ===== */}}
{{- if .settings.vps }}
# Window managers & desktop
.chezmoiscripts/linux/run_once_before_216-install-wm.sh.tmpl
.chezmoiscripts/linux/run_once_after_220-configure-wm.sh.tmpl
.chezmoiscripts/linux/run_once_after_230-configure-keyboard.sh.tmpl
.chezmoiscripts/linux/run_once_after_240-configure-bluetooth.sh.tmpl
.chezmoiscripts/linux/run_once_after_245-configure-audio.sh.tmpl

# GUI applications
.chezmoiscripts/linux/run_once_after_400-install-browsers.sh.tmpl
.chezmoiscripts/linux/run_once_after_410-install-comms.sh.tmpl
.chezmoiscripts/linux/run_once_after_420-install-productivity.sh.tmpl

# Desktop data files
.chezmoidata/linux/fonts.yaml
.chezmoidata/linux/nvidia.yaml
.chezmoidata/linux/virtualbox.yaml
.chezmoidata/linux/nixos.yaml

# Config directories (GUI)
.mozilla/**
.config/gtk-*/
.config/qt*/
.config/kde*/
.config/plasma*/
.config/autostart/**
.config/systemd/user/*.service
.local/share/applications/**

# Fonts (not needed on headless)
.local/share/fonts/**

# X11/Wayland
.Xauthority
.xsession-errors*
.config/monitors.xml
{{- end }}
```

### Non-VPS Excludes (VPS-specific stuff)

```go
{{- /* ===== NON-VPS EXCLUDES (VPS-only stuff) ===== */}}
{{- if not .settings.vps }}
# VPS infrastructure scripts
.chezmoiscripts/vps/**

# VPS data files
.chezmoidata/vps/**

# Server configs
.config/caddy/**
.config/dockge/**
.config/tailscale/**
.config/duckdns/**
.config/fail2ban/**
.config/ufw/**

# systemd services (VPS)
.config/systemd/system/*.service
{{- end }}
```

### Workplace Excludes (Zup-specific)

```go
{{- /* ===== WORKPLACE EXCLUDES (Zup laptop only) ===== */}}
{{- if .features.workplace.zup }}
# These ARE included on work - nothing to exclude here
# But we exclude work stuff on NON-work machines below
{{- end }}

{{- /* ===== NON-WORK EXCLUDES (Zup stuff not on personal) ===== */}}
{{- if not .features.workplace.zup }}
# Zup VPN & tools
.chezmoiscripts/linux/run_once_after_530-setup-zup-vpn.sh.tmpl
.chezmoiscripts/linux/run_once_after_535-setup-zup-tools.sh.tmpl

# Work data
.chezmoidata/work/**

# Work configs
.config/instivo/**
.config/bob/**
.config/aws/**

# Work SSH keys (handled separately)
.ssh/id_ed25519_work*
.ssh/config.work*
{{- end }}
```

### OS-Specific Excludes

```go
{{- /* ===== LINUX-ONLY EXCLUDES (not on macOS/Windows) ===== */}}
{{- if not (eq .chezmoi.os "linux") }}
.chezmoiscripts/linux/**
.chezmoidata/linux/**
.config/systemd/**
.local/share/applications/**
{{- end }}

{{- /* ===== MACOS-ONLY EXCLUDES ===== */}}
{{- if not (eq .chezmoi.os "darwin") }}
.chezmoiscripts/darwin/**
.chezmoidata/darwin/**
.Brewfile
.config/karabiner/**
.config/yabai/**
.config/skhd/**
{{- end }}

{{- /* ===== WINDOWS-ONLY EXCLUDES ===== */}}
{{- if not (eq .chezmoi.os "windows") }}
.chezmoiscripts/windows/**
.chezmoidata/windows/**
scoop/**
.chocolatey/**
{{- end }}
```

### Ephemeral/Headless Excludes

```go
{{- /* ===== EPHEMERAL EXCLUDES (CI, Codespaces, containers) ===== */}}
{{- if .settings.ephemeral }}
# Heavy installs
.chezmoiscripts/*/run_once_after_300-*.sh.tmpl
.chezmoiscripts/*/run_once_after_400-*.sh.tmpl
.chezmoiscripts/*/run_once_after_500-*.sh.tmpl

# GUI/Desktop
.chezmoiscripts/linux/run_once_before_216-install-wm.sh.tmpl
.chezmoidata/linux/fonts.yaml

# Secrets that may not be available
.chezmoidata/**/secrets.toml.age
{{- end }}

{{- /* ===== HEADLESS EXCLUDES (no GUI, SSH, WSL, Termux) ===== */}}
{{- if .settings.headless }}
# Window managers
.chezmoiscripts/linux/run_once_before_216-install-wm.sh.tmpl
.chezmoiscripts/linux/run_once_after_220-configure-wm.sh.tmpl

# GUI apps
.chezmoiscripts/*/run_once_after_400-*.sh.tmpl

# Audio/Bluetooth
.chezmoiscripts/linux/run_once_after_245-configure-audio.sh.tmpl
.chezmoiscripts/linux/run_once_after_240-configure-bluetooth.sh.tmpl
.chezmoidata/linux/nvidia.yaml

# Fonts (minimal on headless)
.chezmoidata/linux/fonts.yaml
{{- end }}
```

### Architecture-Specific Excludes

```go
{{- /* ===== ARM64 EXCLUDES (no x86_64 binaries) ===== */}}
{{- if eq .chezmoi.arch "arm64" }}
.chezmoidata/common/x86_64-only.yaml
# Note: Most tools now support ARM64, but some proprietary don't
{{- end }}

{{- /* ===== X86_64 EXCLUDES ===== */}}
{{- if eq .chezmoi.arch "amd64" }}
.chezmoidata/common/arm64-only.yaml
{{- end }}
```

### Private/Secret Excludes (never deploy unencrypted)

```go
{{- /* ===== SECRET EXCLUDES (never deploy plaintext) ===== */}}
# Age private key
.config/chezmoi/age.key
.config/chezmoi/identity.age

# GPG private keys
.gnupg/secring.gpg
.gnupg/private-keys-v1.d/**

# SSH private keys (unless .age encrypted)
.ssh/id_*
.ssh/id_*.pub
!**.age
!**.asc

# Plaintext secrets
**/secrets.yaml
**/secrets.toml
**/secrets.json
**/.env
**/.env.*
!**.age
!**.asc
!**.example
!**.template
```

---

## 4. Advanced Patterns

### Conditional Negation (Force Include)

```go
# Exclude all .log files...
*.log

# ...but include this specific one
!important.log

# Exclude all node_modules...
**/node_modules/**

# ...but include this nested one (rare)
!**/node_modules/.package-lock.json
```

### Directory Trailing Slash Semantics

| Pattern | Matches |
|---------|---------|
| `dir/` | Directory `dir` and ALL contents |
| `dir` | File OR directory named `dir` |
| `dir/**` | All contents of `dir` recursively |
| `dir/*` | Direct children of `dir` only |

### Template Variable Scoping

```go
{{- /* These variables available in .chezmoiignore.tmpl */}}
{{- /* .chezmoi.os, .chezmoi.arch, .chezmoi.hostname, .chezmoi.username */}}
{{- /* .settings.profile, .settings.vps, .settings.ephemeral, .settings.headless */}}
{{- /* .features.workplace.zup, .features.sudo.available, .features.ai.* */}}
{{- /* .dirs.home, .dirs.config, .dirs.data, .dirs.cache, .dirs.bin */}}

# Example: Exclude based on home dir path
{{- if contains "codespaces" .dirs.home }}
.codespaces-only/**
{{- end }}
```

---

## 5. Testing Ignore Patterns

### Dry Run with Verbose

```bash
# Show what would be ignored
chezmoi ignored --verbose

# Show with custom data
chezmoi ignored --verbose --data='{"settings":{"vps":true,"profile":"vps"}}'
```

### Unit Tests

```bash
#!/usr/bin/env bash
# test_ignore.sh

test_ignore() {
  local data=$1
  local path=$2
  local should_ignore=$3  # true/false
  
  ignored=$(chezmoi ignored --data="$data" "$path" 2>&1)
  is_ignored=$([[ "$ignored" == *"true"* ]] && echo "true" || echo "false")
  
  if [[ "$is_ignored" == "$should_ignore" ]]; then
    echo "✅ PASS: $path ignored=$is_ignored (expected=$should_ignore)"
  else
    echo "❌ FAIL: $path ignored=$is_ignored (expected=$should_ignore)"
  fi
}

# VPS: WM scripts ignored
test_ignore '{"settings":{"vps":true}}' \
  ".chezmoiscripts/linux/run_once_before_216-install-wm.sh.tmpl" "true"

# Personal: WM scripts NOT ignored
test_ignore '{"settings":{"vps":false,"profile":"personal"}}' \
  ".chezmoiscripts/linux/run_once_before_216-install-wm.sh.tmpl" "false"

# Work: Zup VPN NOT ignored
test_ignore '{"settings":{"profile":"work"},"features":{"workplace":{"zup":true}}}' \
  ".chezmoiscripts/linux/run_once_after_530-setup-zup-vpn.sh.tmpl" "false"

# Personal: Zup VPN ignored
test_ignore '{"settings":{"profile":"personal"}}' \
  ".chezmoiscripts/linux/run_once_after_530-setup-zup-vpn.sh.tmpl" "true"
```

---

## 6. Debugging Ignore Issues

```bash
# Show final resolved ignore patterns
chezmoi execute-template home/.chezmoiignore.tmpl | head -100

# Trace why a file is/isn't ignored
chezmoi status --verbose 2>&1 | grep -E "(ignored|IGNORED)"

# Check specific file
chezmoi ignored "home/.chezmoiscripts/linux/run_once_before_216-install-wm.sh.tmpl"

# List all ignored files
chezmoi ignored --all | grep true
```

---

## 7. Common Issues & Fixes

| Issue | Cause | Fix |
|-------|-------|-----|
| File deployed when should be ignored | Template conditional wrong | Check `.chezmoiignore.tmpl` logic, test with `chezmoi ignored` |
| File ignored when should deploy | Overly broad pattern | Use more specific pattern, check negation `!` |
| VPS gets desktop configs | `.settings.vps` false | Ensure VPS detection works, check `.chezmoi.yaml.tmpl` |
| Work config on personal | `.features.workplace.zup` true | Verify hostname detection, add explicit override |
| Template syntax error | Unclosed `{{- if }}` | Validate with `chezmoi execute-template home/.chezmoiignore.tmpl` |
| Negation not working | Parent dir ignored | Negation only works if parent not ignored |

---

## 8. Related Skills

| Skill | Relationship |
|-------|--------------|
| `chezmoi-architecture` | Prerequisite: understands data flow |
| `chezmoi-template-patterns` | Ignore file uses Go templates |
| `chezmoi-environment-detection` | Variables from detection used in ignore |
| `chezmoi-multi-profile` | Profile-specific exclusion |
| `chezmoi-script-lifecycle` | Scripts excluded per profile |
| `chezmoi-secret-management` | Secrets excluded from deploy |

---

## 9. References

- **ChezMoi ignore docs**: https://www.chezmoi.io/user-guide/ignore/
- **ChezMoi template ignore**: https://www.chezmoi.io/user-guide/templates/ignore/
- **Repo ignore**: `fabiosouzadev/dotfiles` → `home/.chezmoiignore.tmpl`
- **Gitignore syntax**: https://git-scm.com/docs/gitignore

---

*Generated via Loop Engineering Mode — Phase 4: Skill Creation. Validated against live repo analysis.*