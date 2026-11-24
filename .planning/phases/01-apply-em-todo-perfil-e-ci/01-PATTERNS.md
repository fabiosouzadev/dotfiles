# Phase 1: Apply em todo perfil e CI - Pattern Map

**Mapped:** 2026-11-24
**Files analyzed:** 11 files to create/modify
**Analogs found:** 9 / 11

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `.forgejo/workflows/validate.yml` | config | event-driven | None (new CI infrastructure) | no-analog |
| `home/.chezmoiscripts/unix/run_once_after_529-install-lazygit.sh.tmpl` | installer | file-I/O, CRUD | `home/.chezmoiscripts/unix/run_once_after_536-install-atuin.sh.tmpl` | exact |
| `home/.chezmoiscripts/unix/run_once_after_536-install-atuin.sh.tmpl` | installer | file-I/O, CRUD | `home/.chezmoiscripts/unix/run_once_after_529-install-lazygit.sh.tmpl` | exact |
| `home/.chezmoiscripts/unix/run_once_after_528-install-glab.sh.tmpl` | installer | file-I/O, CRUD | `home/.chezmoiscripts/unix/run_once_after_529-install-lazygit.sh.tmpl` | exact |
| `home/.chezmoiscripts/linux/run_once_after_504-install-ollama.sh.tmpl` | installer | file-I/O, CRUD | `home/.chezmoiscripts/unix/run_once_after_529-install-lazygit.sh.tmpl` | role-match |
| `home/.chezmoiscripts/darwin/run_once_after_504-install-ollama-darwin.sh.tmpl` | installer | file-I/O, CRUD | `home/.chezmoiscripts/linux/run_once_after_504-install-ollama.sh.tmpl` | exact |
| `home/.chezmoiscripts/unix/run_once_after_590-install-ai-tools.sh.tmpl` | installer | batch | None (unique pattern) | partial |
| `home/dot_zshrc.d/termux.zsh.tmpl` | config | N/A | `home/.chezmoi.yaml.tmpl` | role-match |
| `home/.chezmoitemplates/workplace/script_is_instivo` | guard | N/A | `home/.chezmoitemplates/workplace/script_is_zup` | exact |
| `home/.chezmoitemplates/linux/script_arch_based_only` | guard | N/A | `home/.chezmoitemplates/linux/script_linux_only` | role-match |
| `home/.chezmoiignore.tmpl` | config | N/A | Existing patterns in same file | self-reference |

## Pattern Assignments

### `.forgejo/workflows/validate.yml` (config, event-driven)

**Analog:** None — New CI infrastructure

**Pattern to follow:** Forgejo Actions (GitHub Actions-compatible syntax)

**Research guidance** (RESEARCH.md lines 525-597):
```yaml
# Source: .forgejo/workflows/validate.yml
name: Validate Dotfiles

on:
  push:
    branches: [main]

jobs:
  validate-templates:
    runs-on: docker
    strategy:
      fail-fast: false
      matrix:
        profile:
          - {name: "linux-personal", env: "CHEZMOI_PROFILE=personal"}
          - {name: "vps", env: "CHEZMOI_VPS=true"}
          - {name: "macos", env: "CHEZMOI_OS_OVERRIDE=darwin"}
          - {name: "termux", env: "CHEZMOI_PROFILE=termux"}
    
    steps:
      - name: Checkout
        uses: actions/checkout@v3
      
      - name: Install dependencies
        run: |
          apt-get update && apt-get install -y \
            curl \
            jq \
            shellcheck
      
      - name: Install chezmoi
        run: |
          sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin
      
      - name: Render templates (${{ matrix.profile.name }})
        run: |
          export ${{ matrix.profile.env }}
          export CHEZMOI_SKIP_SHELL_PROBES=true
          
          mkdir -p /tmp/rendered
          find home/.chezmoiscripts -name "*.sh.tmpl" | while read tmpl; do
            output="/tmp/rendered/$(basename "$tmpl" .tmpl)"
            chezmoi execute-template < "$tmpl" > "$output"
          done
      
      - name: Shellcheck (${{ matrix.profile.name }})
        run: |
          shellcheck --severity=warning /tmp/rendered/*.sh

  validate-compose:
    runs-on: docker
    steps:
      - name: Checkout
        uses: actions/checkout@v3
      
      - name: Install dependencies
        run: |
          apt-get update && apt-get install -y docker-compose-plugin
      
      - name: Validate Compose files
        run: |
          find home/dot_local/opt/stacks -name "compose.yaml.tmpl" | while read tmpl; do
            dir="$(dirname "$tmpl")"
            echo "Validating $dir"
            if [[ "$tmpl" == *.tmpl ]]; then
              chezmoi execute-template < "$tmpl" | docker compose -f - config -q
            else
              docker compose -f "$tmpl" config -q
            fi
          done
```

**Key principles:**
- Push to `main` branch triggers workflow (D-05)
- Matrix strategy for multi-profile testing (Linux, VPS, macOS, Termux)
- Profile simulation via environment variables (D-06)
- Validation only: render + lint, no apply (D-07)
- Skip encrypted files via `CHEZMOI_SKIP_SHELL_PROBES` and selective rendering (D-09)

---

### `home/.chezmoiscripts/unix/run_once_after_529-install-lazygit.sh.tmpl` (installer, file-I/O, CRUD)

**Analog:** `home/.chezmoiscripts/unix/run_once_after_536-install-atuin.sh.tmpl`

**Bug to fix:** Lines 37-38 use fragile `grep | sed` pattern

**Imports pattern** (lines 1-4):
```bash
#!/usr/bin/env bash

{{ template "common/script_is_not_ephemeral" . }}
{{ template "common/script_helper" . }}
```

**Core installer pattern** (lines 6-71):
```bash
# Install lazygit (Terminal UI for git)
info ">>>>>> 🦥 Installing lazygit 🦥 <<<<<<"

# Check if already installed
if command -v lazygit &> /dev/null; then
    info "lazygit is already installed: $(lazygit --version 2>&1 | head -1)"
    success ">>> 🦥 lazygit already installed 🦥"
    exit 0
fi

# Detect architecture
ARCH="$(uname -m)"
case "$ARCH" in
    x86_64)  LG_ARCH="x86_64" ;;
    aarch64) LG_ARCH="arm64" ;;
    # ... more cases
esac

# Detect OS
LG_OS="Linux"
case "$(uname -s)" in
    Darwin) LG_OS="Darwin" ;;
esac

# Get latest release version (PATTERN TO FIX)
info "Fetching latest lazygit release..."
# BEFORE: grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/'
# AFTER: Use jq -r '.tag_name | ltrimstr("v")'
```

**Version discovery pattern to adopt** (from RESEARCH.md lines 315-335):
```bash
# GitHub API (single latest release)
VERSION=$(curl -fsSL "https://api.github.com/repos/owner/repo/releases/latest" \
  ${GITHUB_TOKEN:+-H "Authorization: Bearer $GITHUB_TOKEN"} \
  | jq -r '.tag_name | ltrimstr("v")')

if [ -z "$VERSION" ] || [ "$VERSION" = "null" ]; then
  error "Could not determine latest version for tool"
  exit 1
fi
```

**Error handling pattern** (lines 40-43):
```bash
if [ -z "$LG_VERSION" ]; then
    error "Could not determine latest lazygit version"
    exit 1
fi
```

**Download and extract pattern** (lines 50-62):
```bash
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

info "Downloading: ${LG_URL}"
curl -fsSL "$LG_URL" -o "$TMPDIR/$LG_FILE"

info "Extracting..."
tar -xzf "$TMPDIR/$LG_FILE" -C "$TMPDIR"

# Install binary to ~/.local/bin (no sudo required)
mkdir -p "$HOME/.local/bin"
cp "$TMPDIR/lazygit" "$HOME/.local/bin/lazygit"
chmod +x "$HOME/.local/bin/lazygit"
```

**Verification pattern** (lines 65-70):
```bash
if command -v lazygit &> /dev/null || [ -x "$HOME/.local/bin/lazygit" ]; then
    success ">>> 🦥 Installed lazygit: $("$HOME/.local/bin/lazygit" --version 2>&1 | head -1) 🦥"
else
    error "Failed to install lazygit"
    exit 1
fi
```

---

### `home/.chezmoiscripts/unix/run_once_after_536-install-atuin.sh.tmpl` (installer, file-I/O, CRUD)

**Analog:** `home/.chezmoiscripts/unix/run_once_after_529-install-lazygit.sh.tmpl`

**Bug to fix:** Lines 36-37 use fragile `grep | sed` pattern

**Same patterns as lazygit:** See lazygit patterns above. Key differences:
- Different architecture mapping (lines 18-26)
- Different OS suffix pattern (lines 29-32): `unknown-linux-musl` vs `apple-darwin`
- More complex extraction logic (lines 64-75) due to variable archive structure

**Extraction pattern specific to atuin** (lines 64-75):
```bash
# Install binary to ~/.local/bin (no sudo required)
mkdir -p "$HOME/.local/bin"
# The extracted directory name is usually atuin-ARCH-OS
CP_DIR="$TMPDIR/atuin-${ATUIN_ARCH}-${ATUIN_OS}"
if [ ! -d "$CP_DIR" ]; then
    # Sometimes just extracted directly or inside another folder
    if [ -f "$TMPDIR/atuin" ]; then
        cp "$TMPDIR/atuin" "$HOME/.local/bin/atuin"
    else
        error "Could not find atuin binary in extracted files."
        exit 1
    fi
else
    cp "$CP_DIR/atuin" "$HOME/.local/bin/atuin"
fi
```

**Apply same jq fix as lazygit.**

---

### `home/.chezmoiscripts/unix/run_once_after_528-install-glab.sh.tmpl` (installer, file-I/O, CRUD)

**Analog:** `home/.chezmoiscripts/unix/run_once_after_529-install-lazygit.sh.tmpl`

**Bug to fix:** Line 39 uses `grep -oP` which fails on macOS (GNU-specific)

**Imports pattern** (lines 1-6):
```bash
#!/usr/bin/env bash

{{ template "common/script_is_not_ephemeral" . }}
{{ template "workplace/script_is_zup" . }}

{{ template "common/script_helper" . }}
```

**Key difference:** Includes workplace guard `script_is_zup` (line 4)

**Version discovery bug** (lines 38-39):
```bash
# BEFORE: grep -oP '"tag_name":"\K[^"]+' (GNU-specific, fails on macOS)
# AFTER: Use jq -r '.[0].tag_name' (GitLab API returns array)
```

**GitLab API pattern** (from RESEARCH.md lines 325-326):
```bash
# GitLab API (array of releases, get first non-prerelease)
VERSION=$(curl -fsSL "https://gitlab.com/api/v4/projects/PROJECT_ID/releases" \
  | jq -r '.[0].tag_name')
```

**Completions pattern** (lines 65-66):
```bash
{{ template "common/script_validate_completions_path" $ }}
"$HOME/.local/bin/glab" completion -s zsh > "$HOME/.local/share/zsh/site-functions/_glab" 2>/dev/null || true
```

**Extract pattern specific to glab** (lines 60-63):
```bash
# The archive contains bin/glab
mkdir -p "$HOME/.local/bin"
cp "$TMPDIR/bin/glab" "$HOME/.local/bin/glab"
chmod +x "$HOME/.local/bin/glab"
```

---

### `home/.chezmoiscripts/linux/run_once_after_504-install-ollama.sh.tmpl` (installer, file-I/O, CRUD)

**Analog:** `home/.chezmoiscripts/unix/run_once_after_529-install-lazygit.sh.tmpl` (version discovery), self (existing patterns)

**Bugs to fix:**
1. Line 96: `.features.ai.ollama.environments` should be `.features.ollama.environments`
2. Lines 23, 28-30: Fragile version discovery + destructive deletion in user mode
3. Missing jq validation and error handling

**Imports pattern** (lines 1-6):
```bash
#!/usr/bin/env bash

{{ template "common/script_helper" . -}}
{{ template "linux/script_linux_only" . -}}
{{ template "common/script_is_not_ephemeral" . -}}
{{ template "workplace/script_is_not_vps" . }}
```

**Template variable initialization** (lines 8-11):
```bash
INSTALL_DIR= {{- .dirs.local }}
LOG_DIR={{ .features.ollama.path.logs }}
SRC_DIR={{ .dirs.src }}
BIN_DIR={{ .dirs.bin }}
```

**Conditional installation block** (lines 13-14):
```bash
{{- if .features.ollama.install }}

info ">>> 🐑 Installing Ollama in mode {{ .features.ollama.mode }}  🐑"
```

**Version discovery pattern to fix** (lines 22-26):
```bash
{{- if eq .features.ollama.version "latest" }}
# BEFORE: curl -s ... | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
# AFTER: Use jq with proper validation
OLLAMA_VERSION=$(curl -fsSL "https://api.github.com/repos/ollama/ollama/releases/latest" \
  ${GITHUB_TOKEN:+-H "Authorization: Bearer $GITHUB_TOKEN"} \
  | jq -r '.tag_name')

if [ -z "$OLLAMA_VERSION" ] || [ "$OLLAMA_VERSION" = "null" ]; then
  error "Could not determine latest Ollama version"
  exit 1
fi
{{- else }}
OLLAMA_VERSION="{{ .features.ollama.version }}"
{{- end }}
```

**Selective deletion pattern for user mode** (lines 28-30, TO FIX):
```bash
# BEFORE (deletes everything including models):
# rm -rf "$HOME/.ollama"

# AFTER (preserve models and identity):
# Remove only binaries/libs, preserve data
rm -f "$INSTALL_DIR/bin/ollama"
rm -rf "$INSTALL_DIR/lib/ollama"
# Keep ~/.ollama/models/ and ~/.ollama/id_* files
```

**Template key bug** (line 96):
```bash
# BEFORE:
{{ range .features.ai.ollama.environments -}}

# AFTER:
{{ range .features.ollama.environments -}}
```

---

### `home/.chezmoiscripts/darwin/run_once_after_504-install-ollama-darwin.sh.tmpl` (installer, file-I/O, CRUD)

**Analog:** `home/.chezmoiscripts/linux/run_once_after_504-install-ollama.sh.tmpl`

**Bugs to fix:**
1. Line 14: `.features.ai.ollama.version` should be `.features.ollama.version`
2. Line 12: Fragile version discovery with `grep | sed`

**Imports pattern** (lines 1-5):
```bash
#!/usr/bin/env bash

{{ template "common/script_helper" . -}}
{{- template "darwin/script_darwin_only" . -}}
{{ template "common/script_is_not_ephemeral" . }}
```

**Version discovery pattern to fix** (lines 11-15):
```bash
{{- if eq .features.ollama.version "latest" }}
# BEFORE: curl -s ... | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
# AFTER: Use jq with proper validation
OLLAMA_VERSION=$(curl -fsSL "https://api.github.com/repos/ollama/ollama/releases/latest" \
  ${GITHUB_TOKEN:+-H "Authorization: Bearer $GITHUB_TOKEN"} \
  | jq -r '.tag_name')

if [ -z "$OLLAMA_VERSION" ] || [ "$OLLAMA_VERSION" = "null" ]; then
  error "Could not determine latest Ollama version"
  exit 1
fi
{{- else }}
# BEFORE: {{ .features.ai.ollama.version }}
# AFTER: {{ .features.ollama.version }}
OLLAMA_VERSION="{{ .features.ollama.version }}"
{{- end }}
```

**macOS-specific installation pattern** (lines 17-32):
```bash
info ">>> Downloading Ollama version ${OLLAMA_VERSION}..."

curl -fL "https://github.com/ollama/ollama/releases/download/${OLLAMA_VERSION}/Ollama-darwin.zip" -o /tmp/Ollama-darwin.zip

info ">>> Extracting to /Applications..."
unzip -q -o /tmp/Ollama-darwin.zip -d /Applications
rm /tmp/Ollama-darwin.zip

# Create symlink for CLI if it doesn't exist
if [ ! -L /usr/local/bin/ollama ]; then
  info ">>> Setting up CLI symlink..."
  sudo mkdir -p /usr/local/bin
  sudo ln -sf /Applications/Ollama.app/Contents/Resources/ollama /usr/local/bin/ollama
fi

success "🐑 Ollama Installed version: $(/Applications/Ollama.app/Contents/Resources/ollama -v) 🐑"
```

---

### `home/.chezmoiscripts/unix/run_once_after_590-install-ai-tools.sh.tmpl` (installer, batch)

**Analog:** None (unique pattern — iterates over data structure to install multiple tools)

**Bug to fix:** Lines 18, 40, 57 use `:=` to reassign `$featureEnabled`, creating local variables that immediately go out of scope

**Imports pattern** (lines 1-6):
```bash
#!/usr/bin/env bash

{{ template "common/script_is_not_ephemeral" . }}
{{ template "common/script_eval_mise" . }}
{{ template "common/script_helper" . }}
{{ template "workplace/script_is_not_vps" . }}
```

**Variable initialization** (line 10):
```bash
{{- $chezmoi := .chezmoi -}}
```

**Variable shadowing bug pattern** (lines 14-18):
```bash
# BEFORE (creates local variable with :=):
{{- $featureEnabled := false -}}
# ... condition checks ...
{{- if eq .feature_flag "multiplexer" }}{{ $featureEnabled := and (not $.settings.vps ) ($.features.ai.multiplexer) }}{{- end -}}

# AFTER (reassigns existing variable with =):
{{- $featureEnabled := false -}}
# ... condition checks ...
{{- if eq .feature_flag "multiplexer" }}{{ $featureEnabled = and (not $.settings.vps ) ($.features.ai.multiplexer) }}{{- end -}}
```

**Fix applies to:**
- Line 18: NPM tools section
- Line 40: CURL tools section
- Line 57: GitHub tools section

**Iteration pattern for NPM tools** (lines 12-31):
```bash
{{- /* Install NPM tools */ -}}
{{ range .ai_tools.npm }}
{{- $featureEnabled := false -}}
{{- if eq .feature_flag "harness" }}{{ $featureEnabled = $.features.ai.harness }}{{- end -}}
# ... more conditions with = not := ...

{{ if and $featureEnabled (not $blocked) }}
info ">>>> Installing {{ .name }} (NPM) <<<"
{{ if hasKey . "env" }}{{ .env }} {{ end }}npm install -g {{ .package }}
{{- end }}
{{- end }}
```

**Key principle:** Use `=` for reassignment, `:=` only for initial declaration

---

### `home/dot_zshrc.d/termux.zsh.tmpl` (config, N/A)

**Analog:** `home/.chezmoi.yaml.tmpl` (template key access patterns)

**Bug to fix:** Line 124 uses `.features.ai.omniroute.domain` which doesn't exist

**Template conditional** (line 1):
```bash
{{- if .settings.termux -}}
```

**Template key access bug** (line 124):
```bash
# BEFORE (key path doesn't exist):
local vps_ip="{{ .features.ai.omniroute.domain | default "fabiosouzadev.duckdns.org" }}"

# AFTER (use existing key or dig function):
local vps_ip="{{ .termux.ssh.vps_host | default "fabiosouzadev.duckdns.org" }}"
# OR use dig for safe nested access:
local vps_ip="{{ dig "ai" "omniroute" "domain" "fabiosouzadev.duckdns.org" .features }}"
```

**Safe nested key access pattern** (from RESEARCH.md lines 393-401):
```bash
# Use existing keys: .termux.ssh.vps_host instead of inventing new paths
# Use dig for safe nested access: {{ dig "ai" "omniroute" "domain" "default-value" .features }}
# Validate keys exist: {{ if hasKey .features "ai" }}{{ if hasKey .features.ai "omniroute" }}...{{ end }}{{ end }}
```

**Reference analog** (from `home/.chezmoi.yaml.tmpl` lines 50, 100-101):
```bash
{{- $profile := env "CHEZMOI_PROFILE" -}}
{{- $forceGUI := env "CHEZMOI_FORCE_GUI" | not | not -}}
{{- $forceHeadless := env "CHEZMOI_FORCE_HEADLESS" | not | not -}}
```

---

### `home/.chezmoitemplates/workplace/script_is_instivo` (guard, N/A)

**Analog:** `home/.chezmoitemplates/workplace/script_is_zup`

**Change:** Add documentation comment explaining legacy status

**Current pattern** (lines 1-3):
```bash
{{ if not (eq .settings.workplace "Instivo") }}
exit 0
{{ end }}
```

**Pattern to add** (documentation header):
```bash
{{- /*
LEGACY GUARD: Never passes (user no longer works at Instivo)
This guard is kept in the repository for reference but is intentionally disabled.
Current workplace: Zup (alocado no Itaú)
See: D-01, D-02 in phase 1 context
*/ -}}
{{ if not (eq .settings.workplace "Instivo") }}
exit 0
{{ end }}
```

**Reference analog** (`home/.chezmoitemplates/workplace/script_is_zup`):
```bash
{{ if not (eq .settings.workplace "Zup") }}
exit 0
{{ end }}
```

---

### `home/.chezmoitemplates/linux/script_arch_based_only` (guard, N/A)

**Analog:** `home/.chezmoitemplates/linux/script_linux_only`

**Change:** Document behavior, optionally expand to pure Arch if no exclusive dependencies found

**Current pattern** (lines 1-3):
```bash
{{- if not (or (.settings.osid | lower | contains "endeavouros") (.settings.osid | lower | contains "cachyos")) }}
exit 0
{{- end }}
```

**Pattern to add** (documentation + possible expansion):
```bash
{{- /*
ARCH-BASED GUARD: Restricts to Arch-based distributions
Currently allows: EndeavourOS, CachyOS
Optionally includes: Pure Arch (linux-arch) if no exclusive dependencies
See: Claude's Discretion in phase 1 context
*/ -}}
{{- if not (or 
  (.settings.osid | lower | contains "endeavouros") 
  (.settings.osid | lower | contains "cachyos")
  {{- /* ADD IF NO EXCLUSIVE DEPENDENCIES: */ -}}
  {{- /* (eq .settings.osid "linux-arch") */ -}}
) }}
exit 0
{{- end }}
```

**Reference analog** (`home/.chezmoitemplates/linux/script_linux_only`):
```bash
{{- if not (eq .chezmoi.os "linux") }}
exit 0
{{- end }}
```

**Research task:** Check scripts 655, 515, 201, 214, 215, 220 for EndeavourOS/CachyOS-specific dependencies

---

### `home/.chezmoiignore.tmpl` (config, N/A)

**Analog:** Self-reference (existing patterns in same file)

**Change:** Remove coderabbit references (line search needed), optionally add CI encrypted file patterns

**Existing pattern structure** (lines 1-161):
```bash
README.md

# Distro-specific scripts
{{- if not (.settings.osid | lower | contains "linux" ) }}
.chezmoiscripts/linux/**
# ... more patterns
{{- end }}

# === VPS-SPECIFIC FILTERS ===
{{- if .settings.vps }}
# Window managers - not needed on VPS
.chezmoiscripts/linux/run_once_before_216-install-wm.sh.tmpl
# ... more patterns
{{- end }}
```

**Pattern to add** (CI encrypted file handling, D-09):
```bash
# === CI FILTERS ===
# Skip encrypted files in CI (no GPG key available)
{{- if env "CI" }}
encrypted_*
{{- end }}
```

**Pattern to remove:** Search for `coderabbit` references and remove (D-03)
```bash
# SEARCH: grep -n "coderabbit" home/.chezmoiignore.tmpl
# REMOVE: Any lines referencing run_once_after_515-install-coderabbit-cli.sh.tmpl
```

---

## Shared Patterns

### Authentication/Authorization Guards
**Source:** `home/.chezmoitemplates/workplace/`, `home/.chezmoitemplates/linux/`, `home/.chezmoitemplates/common/`
**Apply to:** All scripts

**Pattern:**
```bash
{{ template "common/script_is_not_ephemeral" . }}
{{ template "linux/script_linux_only" . }}
{{ template "workplace/script_is_not_vps" . }}
```

**Usage:**
- `script_is_not_ephemeral`: Skip in CI/containers
- `script_*_only`: OS-specific guard (linux, darwin, windows)
- `script_is_vps` / `script_is_not_vps`: VPS profile guard
- `script_is_zup` / `script_is_instivo`: Workplace context guard

### Error Handling and Logging
**Source:** `home/.chezmoitemplates/common/script_helper`
**Apply to:** All scripts

**Pattern** (lines 1-7):
```bash
set -euo pipefail

# Pretty print functions
info()    { echo -e "\033[1;34m[INFO]\033[0m $*"; }
warn()    { echo -e "\033[1;33m[WARN]\033[0m $*"; }
error()   { echo -e "\033[1;31m[ERROR]❌ $*\033[0m"; }
success() { echo -e "\033[1;32m[SUCCESS]✅ $*\033[0m"; }
```

**Usage:**
```bash
{{ template "common/script_helper" . }}

info "Starting installation..."
error "Failed to download"
success "Installation complete"
```

### Version Discovery with jq
**Source:** RESEARCH.md lines 315-335
**Apply to:** All installer scripts that query GitHub/GitLab APIs

**GitHub pattern:**
```bash
# GitHub API (single latest release)
VERSION=$(curl -fsSL "https://api.github.com/repos/owner/repo/releases/latest" \
  ${GITHUB_TOKEN:+-H "Authorization: Bearer $GITHUB_TOKEN"} \
  | jq -r '.tag_name | ltrimstr("v")')

if [ -z "$VERSION" ] || [ "$VERSION" = "null" ]; then
  error "Could not determine latest version for tool"
  exit 1
fi
```

**GitLab pattern:**
```bash
# GitLab API (array of releases, get first)
VERSION=$(curl -fsSL "https://gitlab.com/api/v4/projects/PROJECT_ID/releases" \
  | jq -r '.[0].tag_name')

if [ -z "$VERSION" ] || [ "$VERSION" = "null" ]; then
  error "Could not determine latest version for tool"
  exit 1
fi
```

**Key principles:**
- Use `jq -r` for raw string output (no quotes)
- Always validate result is non-empty and not "null"
- Accept `GITHUB_TOKEN` when available to avoid rate limits
- Use `curl -f` to fail on HTTP errors

### Safe Download and Extraction
**Source:** All installer scripts
**Apply to:** All file download operations

**Pattern:**
```bash
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

info "Downloading: ${URL}"
if ! curl -fsSL "$URL" -o "$TMPDIR/$FILE"; then
    error "Failed to download from $URL"
    exit 1
fi

info "Extracting..."
tar -xzf "$TMPDIR/$FILE" -C "$TMPDIR"

# Install to ~/.local/bin (no sudo required)
mkdir -p "$HOME/.local/bin"
cp "$TMPDIR/binary" "$HOME/.local/bin/binary"
chmod +x "$HOME/.local/bin/binary"
```

**Key principles:**
- Use temporary directory with cleanup trap
- Always check download success with `if !` or `||`
- Use `curl -f` to fail on HTTP errors
- Install to `~/.local/bin` when possible (no sudo required)

### Profile Simulation in CI
**Source:** `home/.chezmoi.yaml.tmpl` lines 50, 100-101, 118
**Apply to:** CI workflow and local validation scripts

**Environment variables:**
```bash
# Profile override
export CHEZMOI_PROFILE=personal        # or vps, termux
export CHEZMOI_VPS=true                # Force VPS mode
export CHEZMOI_FORCE_GUI=true          # Force GUI available
export CHEZMOI_FORCE_HEADLESS=true     # Force headless mode
export CHEZMOI_SKIP_SHELL_PROBES=true  # Skip expensive OS probes
```

**Usage in CI:**
```yaml
- name: Render templates (vps)
  run: |
    export CHEZMOI_VPS=true
    export CHEZMOI_SKIP_SHELL_PROBES=true
    chezmoi execute-template < script.tmpl > /tmp/rendered.sh
```

### Template Safe Key Access
**Source:** RESEARCH.md lines 393-401
**Apply to:** All template files that access nested keys

**Patterns:**
```bash
# Use existing keys instead of inventing new paths
{{ .termux.ssh.vps_host | default "fallback" }}

# Use dig for safe nested access
{{ dig "ai" "omniroute" "domain" "default-value" .features }}

# Validate keys exist before access
{{ if hasKey .features "ai" }}
  {{ if hasKey .features.ai "omniroute" }}
    {{ .features.ai.omniroute.domain }}
  {{ end }}
{{ end }}
```

**Common pitfalls:**
- Accessing non-existent nested keys crashes rendering before `default` can apply
- Go templates evaluate left-to-right: `.features.ai.omniroute.domain` tries to access `.ai` first

---

## No Analog Found

Files with no close match in the codebase (planner should use RESEARCH.md patterns instead):

| File | Role | Data Flow | Reason |
|------|------|-----------|--------|
| `.forgejo/workflows/validate.yml` | config | event-driven | First CI workflow for this project; pattern defined in RESEARCH.md |

---

## Files to Delete

| File | Reason |
|------|--------|
| `home/.chezmoiscripts/unix/run_once_after_515-install-coderabbit-cli.sh.tmpl` | User no longer uses CodeRabbit (D-03) |

**Additional cleanup:** Remove references to coderabbit in:
- `home/.chezmoiignore.tmpl` (if present)
- Documentation files (if present)

---

## Metadata

**Analog search scope:** 
- `home/.chezmoiscripts/**/*.sh.tmpl` (43 scripts)
- `home/.chezmoitemplates/**/*` (16 guards and helpers)
- `home/dot_local/opt/stacks/*/compose.yaml.tmpl` (13 stacks)
- `home/.chezmoi*.tmpl` (3 config files)

**Files scanned:** 75 files total

**Pattern extraction date:** 2026-11-24

**Git tracking verification:** All analog paths verified with `git ls-files`

**Key patterns identified:**
1. Installer scripts follow consistent structure: guards → check installed → detect arch/os → fetch version → download → extract → verify
2. Version discovery transitioning from `grep | sed` to `jq` (portable, robust)
3. Guards use early exit pattern: `{{ if not condition }}exit 0{{ end }}`
4. Template helper functions provide consistent logging and error handling
5. Profile simulation via `CHEZMOI_*` environment variables enables CI testing without real OS
6. CI follows validation-only pattern: render + lint, never apply

**Cross-platform considerations:**
- `grep -P` (GNU-specific) must be avoided in unix/ and darwin/ scripts
- `jq` required as dependency on all platforms (Linux, macOS, Termux)
- Architecture detection varies by tool (amd64 vs x86_64, arm64 vs aarch64)
- OS naming varies by tool (Linux vs linux, Darwin vs macOS, apple-darwin vs unknown-linux-musl)

**Security considerations:**
- Encrypted files (`encrypted_*.asc`) never decrypted in CI (D-09)
- No secrets in repository; CI uses dummy data or env var overrides
- Downloads use official release URLs (github.com, gitlab.com)
- Scripts prefer `~/.local/bin` over system paths (no sudo required)