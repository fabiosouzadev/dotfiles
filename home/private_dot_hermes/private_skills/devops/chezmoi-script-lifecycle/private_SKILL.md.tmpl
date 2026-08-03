---
name: chezmoi-script-lifecycle
description: "Master chezmoi script lifecycle: run_once, run_onchange."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [chezmoi, scripts, lifecycle, run_once, run_onchange]
    category: devops
requires_toolsets: [terminal, file]
supersedes: []
---

# ChezMoi Script Lifecycle Skill

**Trigger**: Use when creating, debugging, or reviewing chezmoi scripts — understanding execution order, guard templates, idempotency patterns, and script composition.

**Goal**: Provide complete reference for script lifecycle patterns from `fabiosouzadev/dotfiles` enabling reliable, idempotent bootstrap scripts.

---

## 1. Script Types & Execution Order

### Naming Convention Determines Behavior

| Prefix | Trigger | Runs | Use Case |
|--------|---------|------|----------|
| `run_once_before_` | Before any files applied | Once per machine | Prereqs, repos, key imports |
| `run_once_after_` | After all files applied | Once per machine | Post-install config, services |
| `run_onchange_` | When script content changes | On every change | Config regeneration, symlinks |
| `run_onchange_before_` | Before files, on change | On every change | Pre-apply validation |
| `run_onchange_after_` | After files, on change | On every change | Post-apply hooks |

### Execution Order (ChezMoi Default)

```
1. run_once_before_*     (sorted alphanumerically)
2. run_onchange_before_* (sorted alphanumerically)
3. Apply all files (templates, copies, symlinks)
4. run_onchange_after_*  (sorted alphanumerically)
5. run_once_after_*      (sorted alphanumerically)
```

### Numbering Strategy (from `fabiosouzadev/dotfiles`)

```
100-199: Pre-install / Prerequisites
  100-109: Package managers (brew, apt, winget)
  110-119: External repos (apt repos, copr, etc.)
  120-129: Key imports (GPG, SSH, age)
  130-139: Runtime managers (mise, asdf, nvm)
  140-149: Shell setup (zsh, fish)

200-299: Core Configuration
  200-209: Dotfiles (zshrc, gitconfig, etc.)
  210-219: Window manager / Desktop
  220-229: Keyboard / Input
  230-239: Bluetooth / Hardware
  240-249: Fonts / Themes

300-399: Development Tools
  300-309: Language runtimes (go, node, python, rust)
  310-319: Editors (nvim, vscode, helix)
  320-329: Terminal tools (fzf, zoxide, atuin)
  330-339: Containers (docker, podman, distrobox)

400-499: Applications
  400-409: Browsers, comms
  410-419: Productivity
  420-429: Media

500-599: Post-Install / AI Tools
  500-509: AI tools (aider, claude, cursor)
  510-519: Hermes / OmniRoute
  520-529: Coding Orchestrator
  530-539: ComfyUI / ML

600-699: OnChange / Cron / Maintenance
  600-609: Cron jobs
  610-619: Hermes cron / sync
  620-629: OmniRoute cron / sync
  630-639: Backup scripts
  640-649: Update checks

900-999: Cleanup / Finalization
  999: Compinit / shell finalization
```

---

## 2. Script Structure Template

### Standard Script Header

```bash
#!/usr/bin/env bash
# {{ .chezmoi.sourceFile }} - {{ .chezmoi.sourceFileDir }}
# Description: {{ .description | default "Script description" }}
# Order: {{ .order | default "XXX" }}
# Profile: {{ .profile | default "all" }}

{{ template "common/script_is_not_ephemeral" . }}
{{ template "common/script_is_not_headless" . }}
{{ template "common/script_helper" . }}

set -euo pipefail

info ">>>>>> 📦 {{ .description }} 📦 <<<<<<"
```

### Script Footer

```bash
success ">>> ✅ {{ .description }} Completed ✅ <<<"
```

---

## 3. Guard Templates (Early Exit)

### Ephemeral Guard (CI, Codespaces, Containers)

```go
# .chezmoitemplates/common/script_is_not_ephemeral
{{ define "script_is_not_ephemeral" }}
{{- if .settings.ephemeral }}
exit 0
{{- end }}
{{ end }}
```

**Usage**: Place at TOP of script (before shebang processing in some shells)
```bash
{{ template "common/script_is_not_ephemeral" . }}
#!/usr/bin/env bash
...
```

### Headless Guard (No GUI, SSH, WSL, Termux, Container)

```go
# .chezmoitemplates/common/script_is_not_headless
{{ define "script_is_not_headless" }}
{{- if .settings.headless }}
exit 0
{{- end }}
{{ end }}
```

### Workplace Guard (Block on Work Machines)

```go
# .chezmoitemplates/common/script_is_not_workplace
{{ define "script_is_not_workplace" }}
{{- if .features.workplace.zup }}
exit 0
{{- end }}
{{ end }}
```

### Sudo Guard (Require/Block Sudo)

```go
# .chezmoitemplates/common/script_requires_sudo
{{ define "script_requires_sudo" }}
{{- if not .features.sudo.available }}
error "This script requires sudo but it's not available"
exit 1
{{- end }}
{{ end }}

# .chezmoitemplates/common/script_no_sudo
{{ define "script_no_sudo" }}
{{- if .features.sudo.available }}
warn "Running with sudo available - some operations may need adjustment"
{{- end }}
{{ end }}
```

---

## 4. Helper Templates (Shared Functions)

### Common Helpers (`.chezmoitemplates/common/script_helper`)

```go
{{ define "script_helper" }}
# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
info() { echo -e "${BLUE}[INFO]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

# Utility functions
command_exists() { command -v "$1" >/dev/null 2>&1; }
file_exists() { [[ -f "$1" ]]; }
dir_exists() { [[ -d "$1" ]]; }
is_macos() { [[ "$(uname -s)" == "Darwin" ]]; }
is_linux() { [[ "$(uname -s)" == "Linux" ]]; }
is_windows() { [[ "$(uname -s)" =~ ^(MINGW|MSYS|CYGWIN) ]]; }

# Package manager detection
has_apt() { command_exists apt; }
has_brew() { command_exists brew; }
has_pacman() { command_exists pacman; }
has_dnf() { command_exists dnf; }
has_yay() { command_exists yay; }
has_paru() { command_exists paru; }

# Install helpers
install_apt() { sudo apt update && sudo apt install -y "$@"; }
install_brew() { brew install "$@"; }
install_pacman() { sudo pacman -S --noconfirm "$@"; }
install_dnf() { sudo dnf install -y "$@"; }
{{ end }}
```

### Mise Evaluation (`.chezmoitemplates/common/script_eval_mise`)

```go
{{ define "script_eval_mise" }}
{{- if .features.runtime.mise }}
eval "$(mise activate bash)"
{{- end }}
{{ end }}
```

### Completion Path Validation (`.chezmoitemplates/common/script_validate_completions_path`)

```go
{{ define "script_validate_completions_path" }}
mkdir -p "{{ $.chezmoi.homeDir }}/.local/share/zsh/site-functions"
{{ end }}
```

### Binary Install Helper (`.chezmoitemplates/common/script_install_binary`)

```go
{{ define "script_install_binary" }}
{{- $name := .name }}
{{- $url := .url }}
{{- $bin := .bin | default $name }}
{{- $checksum := .checksum | default "" }}
info "Installing {{ $name }}"
cd /tmp
curl -fsSL "{{ $url }}" -o "{{ $bin }}"
{{- if $checksum }}
echo "{{ $checksum }}  {{ $bin }}" | sha256sum -c -
{{- end }}
chmod +x "{{ $bin }}"
mkdir -p "{{ $.dirs.bin }}"
mv "{{ $bin }}" "{{ $.dirs.bin }}/{{ $bin }}"
success "{{ $name }} installed to {{ $.dirs.bin }}/{{ $bin }}"
{{ end }}
```

---

## 5. Idempotency Patterns

### 1. Check Before Install

```bash
# BAD: Always runs
curl -fsSL https://example.com/install.sh | bash

# GOOD: Check first
if ! command_exists toolname; then
  info "Installing toolname..."
  curl -fsSL https://example.com/install.sh | bash
else
  info "toolname already installed, skipping"
fi
```

### 2. Version Check

```bash
# Install specific version only if missing or wrong
DESIRED_VERSION="1.21.0"
if command_exists go; then
  CURRENT_VERSION=$(go version | awk '{print $3}' | sed 's/go//')
  if [[ "$CURRENT_VERSION" == "$DESIRED_VERSION" ]]; then
    info "Go $DESIRED_VERSION already installed"
    exit 0
  fi
fi
info "Installing Go $DESIRED_VERSION..."
```

### 3. File Content Check (run_onchange)

```bash
# run_onchange scripts should be idempotent by nature
# but verify target state before writing

generate_config() {
  cat > "$CONFIG_FILE" <<'EOF'
# Generated by chezmoi - do not edit directly
setting = "value"
EOF
}

# Only write if changed
NEW_CONTENT=$(generate_config)
if [[ -f "$CONFIG_FILE" ]] && [[ "$(cat "$CONFIG_FILE")" == "$NEW_CONTENT" ]]; then
  info "Config unchanged, skipping"
else
  echo "$NEW_CONTENT" > "$CONFIG_FILE"
  success "Config updated"
fi
```

### 4. Service Management Idempotency

```bash
enable_service() {
  local service=$1
  if systemctl is-enabled --quiet "$service"; then
    info "$service already enabled"
  else
    info "Enabling $service..."
    sudo systemctl enable --now "$service"
  fi
}

disable_service() {
  local service=$1
  if systemctl is-enabled --quiet "$service"; then
    info "Disabling $service..."
    sudo systemctl disable --now "$service"
  else
    info "$service already disabled"
  fi
}
```

---

## 6. OS-Specific Script Patterns

### Linux-Specific (`.chezmoiscripts/linux/`)

```bash
#!/usr/bin/env bash
{{ template "common/script_is_not_ephemeral" . }}
{{ template "common/script_helper" . }}

{{- if eq .chezmoi.osid "ubuntu" }}
# Ubuntu/Debian specific
export DEBIAN_FRONTEND=noninteractive
apt update
apt install -y package1 package2
{{- else if eq .chezmoi.osid "arch" }}
# Arch specific
pacman -Syu --noconfirm package1 package2
{{- else if eq .chezmoi.osid "fedora" }}
# Fedora specific
dnf install -y package1 package2
{{- end }}
```

### macOS-Specific (`.chezmoiscripts/darwin/`)

```bash
#!/usr/bin/env bash
{{ template "common/script_is_not_ephemeral" . }}
{{ template "common/script_helper" . }}

# Homebrew packages
brew bundle --file={{ .chezmoi.sourceDir }}/home/.chezmoidata/darwin/Brewfile

# macOS defaults
defaults write com.apple.dock autohide -bool true
killall Dock
```

### Windows-Specific (`.chezmoiscripts/windows/`)

```powershell
# .chezmoiscripts/windows/run_once_after_100-install-scoop.ps1.tmpl
{{ template "common/script_is_not_ephemeral" . }}

# Scoop buckets
scoop bucket add extras
scoop install git nodejs python

# Windows settings
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1
```

---

## 7. Advanced Patterns from `fabiosouzadev/dotfiles`

### 1. AI Tools Install (Universal Binary Pattern)

```bash
# home/.chezmoiscripts/unix/run_once_after_590-install-ai-tools.sh.tmpl
#!/usr/bin/env bash

{{ template "common/script_is_not_ephemeral" . }}
{{ template "common/script_eval_mise" . }}
{{ template "common/script_helper" . }}

info ">>>>>> 🤖 Installing AI Tools 🤖 <<<<<<<"

# NPM-based tools
{{- range .ai_tools.npm }}
{{- $enabled := $.features.ai.coding_assistants }}
{{- if and $enabled (not .block_on_workplace) }}
info "Installing {{ .name }} (NPM)"
{{ .env | default "" }} npm install -g {{ .package }}
{{- if .completions_cmd }}
{{ template "common/script_validate_completions_path" $ }}
{{ .completions_cmd }} > "{{ $.chezmoi.homeDir }}/.local/share/zsh/site-functions/_{{ .name }}"
{{- end }}
{{- end }}
{{- end }}

# Curl-install tools (binary downloads)
{{- range .ai_tools.curl }}
{{- $enabled := $.features.ai.coding_assistants }}
{{- if and $enabled (not .block_on_workplace) }}
info "Installing {{ .name }} (curl)"
{{ .script | default (printf "curl -fsSL %s | bash" .url) | indent 2 }}
{{- if .completions_cmd }}
{{ template "common/script_validate_completions_path" $ }}
{{ .completions_cmd }} > "{{ $.chezmoi.homeDir }}/.local/share/zsh/site-functions/_{{ .name }}"
{{- end }}
{{- end }}
{{- end }}

success ">>> 🤖 AI Tools Installed 🤖"
```

### 2. Repo Cloning with Worktrees

```bash
# home/.chezmoiscripts/unix/run_onchange_after_605-clone-my-repos.sh.tmpl
#!/usr/bin/env bash

{{ template "common/script_is_not_ephemeral" . }}
{{ template "common/script_helper" . }}

info ">>>>>> 📂 Cloning Repositories 📂 <<<<<<<"

{{- range $workspace, $repos := .repos.work.workplaces }}
  {{- if or (eq $.settings.profile "work") (eq $.settings.profile "personal") }}
info "Workspace: {{ $workspace }}"
mkdir -p "{{ $.dirs.workspaces.$workspace }}"
  {{- range $repos }}
  REPO_URL="{{ .repo }}"
  TARGET_DIR="{{ $.dirs.workspaces.$workspace }}/{{ .name }}"
  
  if [[ -d "$TARGET_DIR" ]]; then
    info "Repo {{ .name }} exists, pulling latest"
    git -C "$TARGET_DIR" pull --ff-only
  else
    info "Cloning {{ .name }}..."
    git clone "$REPO_URL" "$TARGET_DIR"
  fi
  
  {{- if .worktree }}
  # Create worktrees for feature branches
  cd "$TARGET_DIR"
  git worktree list | grep -q "{{ .worktree.branch }}" || \
    git worktree add "../{{ .name }}-{{ .worktree.branch }}" "{{ .worktree.branch }}"
  {{- end }}
  {{- end }}
{{- end }}

success ">>> 📂 Repositories Cloned 📂"
```

### 3. VPS Bootstrap (Dockge, Caddy, Tailscale)

```bash
# home/.chezmoiscripts/vps/run_once_after_500-setup-vps-infra.sh.tmpl
#!/usr/bin/env bash

{{ template "common/script_is_not_ephemeral" . }}
{{ template "common/script_requires_sudo" . }}
{{ template "common/script_helper" . }}

info ">>>>>> 🖥️ VPS Infrastructure Setup 🖥️ <<<<<<<"

# Dockge - Docker management UI
info "Setting up Dockge..."
mkdir -p /opt/dockge
curl -fsSL https://raw.githubusercontent.com/louislam/dockge/master/compose.yaml -o /opt/dockge/compose.yaml
curl -fsSL https://raw.githubusercontent.com/louislam/dockge/master/.env.example -o /opt/dockge/.env
# Configure .env with domain, etc.
cd /opt/dockge && docker compose up -d

# Caddy - Reverse proxy with auto TLS
info "Setting up Caddy..."
apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/caddy-stable-archive-keyring.gpg] https://dl.cloudsmith.io/public/caddy/stable/deb/debian any-version main" > /etc/apt/sources.list.d/caddy-stable.list
apt update && apt install -y caddy

# Tailscale VPN
info "Setting up Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh
# Auth key from secrets
TAILSCALE_AUTH_KEY="{{ .vps_secrets.tailscale_auth_key }}"
tailscale up --auth-key="$TAILSCALE_AUTH_KEY" --hostname="{{ .chezmoi.hostname }}"

# DuckDNS for dynamic DNS
info "Setting up DuckDNS..."
mkdir -p /opt/duckdns
cat > /opt/duckdns/update.sh <<'EOF'
#!/bin/bash
curl -s "https://www.duckdns.org/update?domains={{ .vps_secrets.duckdns_domain }}&token={{ .vps_secrets.duckdns_token }}&ip="
EOF
chmod +x /opt/duckdns/update.sh
# systemd timer for periodic updates

success ">>> 🖥️ VPS Infrastructure Ready 🖥️"
```

---

## 8. Testing Scripts

### Dry Run

```bash
# Test script rendering without executing
chezmoi execute-template home/.chezmoiscripts/linux/run_once_after_100-install-packages.sh.tmpl

# Test with custom data
chezmoi execute-template --data='{"settings":{"vps":true}}' home/.chezmoiscripts/unix/run_once_after_590-install-ai-tools.sh.tmpl
```

### Unit Test Framework

```bash
#!/usr/bin/env bash
# test_scripts.sh

test_script() {
  local script=$1
  local data=$2
  local expected_pattern=$3
  
  output=$(chezmoi execute-template --data="$data" "$script" 2>&1)
  if echo "$output" | grep -q "$expected_pattern"; then
    echo "✅ PASS: $script"
  else
    echo "❌ FAIL: $script"
    echo "  Expected pattern: $expected_pattern"
    echo "  Output: $output"
  fi
}

# Test ephemeral guard
test_script "home/.chezmoiscripts/linux/run_once_after_100-install-packages.sh.tmpl" \
  '{"settings":{"ephemeral":true}}' \
  "exit 0"

# Test headless guard
test_script "home/.chezmoiscripts/linux/run_once_after_200-install-wm.sh.tmpl" \
  '{"settings":{"headless":true}}' \
  "exit 0"

# Test VPS-only script on non-VPS
test_script "home/.chezmoiscripts/vps/run_once_after_500-setup-vps-infra.sh.tmpl" \
  '{"settings":{"vps":false}}' \
  "exit 0"
```

---

## 9. Debugging Scripts

```bash
# Trace script execution
chezmoi apply --trace 2>&1 | grep -E "(run_once|run_onchange|executing)"

# Dry run with verbose
chezmoi apply --dry-run --verbose 2>&1 | grep -A5 "script"

# Execute single script manually
chezmoi execute-template home/.chezmoiscripts/linux/run_once_after_100-install-packages.sh.tmpl | bash -x

# Check script permissions
ls -la ~/.local/share/chezmoi/home/.chezmoiscripts/
```

---

## 10. Common Issues & Fixes

| Issue | Cause | Fix |
|-------|-------|-----|
| Script runs in CI | Missing ephemeral guard | Add `{{ template "common/script_is_not_ephemeral" . }}` |
| GUI script runs on VPS | Missing headless guard | Add `{{ template "common/script_is_not_headless" . }}` |
| Workplace script runs at work | Missing workplace guard | Add `{{ template "common/script_is_not_workplace" . }}` |
| `command not found` in script | Missing `script_eval_mise` | Add `{{ template "common/script_eval_mise" . }}` |
| Sudo fails in Codespaces | Sudo not available | Check `.features.sudo.available` |
| Script runs multiple times | Wrong prefix | Use `run_once_` for one-time, `run_onchange_` for config |
| Order wrong | Alphanumeric sorting | Use consistent numbering (000-999) |

---

## 11. Related Skills

| Skill | Relationship |
|-------|--------------|
| `chezmoi-architecture` | Prerequisite: understands script layer |
| `chezmoi-template-patterns` | Scripts are templates with Go syntax |
| `chezmoi-environment-detection` | Guards use detection flags |
| `chezmoi-secret-management` | Scripts decrypt secrets at runtime |
| `chezmoi-ignore-patterns` | Exclude scripts per profile |
| `dotfiles-universal-binary-install` | Pattern used in scripts |
| `dotfiles-vps-bootstrap` | VPS-specific scripts |

---

## 12. References

- **ChezMoi script docs**: https://www.chezmoi.io/user-guide/run-scripts/
- **ChezMoi script ordering**: https://www.chezmoi.io/reference/scripts/
- **Repo scripts**: `fabiosouzadev/dotfiles` → `.chezmoiscripts/{linux,darwin,windows,unix,vps}/`, `.chezmoitemplates/common/`

---

*Generated via Loop Engineering Mode — Phase 4: Skill Creation. Validated against live repo analysis.*