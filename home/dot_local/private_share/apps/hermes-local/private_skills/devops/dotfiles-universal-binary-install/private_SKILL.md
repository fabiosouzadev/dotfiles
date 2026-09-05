---
name: dotfiles-universal-binary-install
description: "Install CLIs via GitHub Releases to ~/.local/bin, no sudo."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [dotfiles, binary, install, github, releases, universal]
    category: devops
requires_toolsets: [terminal, file]
supersedes: []
---

# Dotfiles Universal Binary Install Skill

**Trigger**: Use when installing CLI tools that aren't in package managers — download from GitHub Releases, verify checksums, install to `~/.local/bin` without sudo, generate shell completions.

**Goal**: Provide complete reference for universal binary installation patterns from `fabiosouzadev/dotfiles` enabling consistent, reproducible tool installation across OS/arch.

---

## 1. Pattern Overview

### Why Universal Binary Install?

| Scenario | Package Manager | Universal Binary |
|----------|-----------------|------------------|
| Tool not in apt/brew/pacman | ❌ | ✅ |
| Need specific version | ⚠️ | ✅ |
| No sudo access | ❌ | ✅ |
| ARM64 + x86_64 support | ⚠️ | ✅ |
| Reproducible across machines | ⚠️ | ✅ |

### Installation Flow

```
GitHub Releases API
       │
       ▼
Resolve latest version (or pinned)
       │
       ▼
Download asset for OS/arch
       │
       ▼
Verify SHA256 checksum
       │
       ▼
Extract binary
       │
       ▼
chmod +x
       │
       ▼
Move to ~/.local/bin/
       │
       ▼
Generate shell completions
       │
       ▼
✅ Ready to use
```

---

## 2. Helper Template (`.chezmoitemplates/common/script_install_binary`)

```go
{{ define "script_install_binary" }}
{{- $name := .name }}
{{- $repo := .repo }}
{{- $bin := .bin | default $name }}
{{- $version := .version | default "latest" }}
{{- $checksum_url := .checksum_url | default "" }}
{{- $asset_pattern := .asset_pattern | default "" }}
{{- $extract_cmd := .extract_cmd | default "" }}
{{- $completions_cmd := .completions_cmd | default "" }}

info "Installing {{ $name }}"

{{- /* Resolve version */}}
{{- if eq $version "latest" }}
{{-   $version_cmd := printf "curl -fsSL https://api.github.com/repos/%s/releases/latest | jq -r .tag_name" $repo }}
VERSION=$({{ $version_cmd }})
{{- else }}
VERSION="{{ $version }}"
{{- end }}

{{- /* Determine asset URL */}}
{{- if $asset_pattern }}
ASSET_URL=$(printf "{{ $asset_pattern }}" $VERSION)
{{- else }}
# Auto-detect: repo/releases/download/vX.Y.Z/tool_OS_ARCH.tar.gz
OS="{{ .chezmoi.os }}"
ARCH="{{ .chezmoi.arch }}"
{{- if eq .chezmoi.os "darwin" }}OS="Darwin"{{ end }}
{{- if eq .chezmoi.arch "amd64" }}ARCH="x86_64"{{ end }}
{{- if eq .chezmoi.arch "arm64" }}ARCH="arm64"{{ end }}
ASSET_URL="https://github.com/{{ $repo }}/releases/download/${VERSION}/{{ $name }}_${OS}_${ARCH}.tar.gz"
{{- end }}

{{- /* Download */}}
cd /tmp
curl -fsSL "$ASSET_URL" -o "{{ $name }}.archive"

{{- /* Verify checksum */}}
{{- if $checksum_url }}
CHECKSUM=$(curl -fsSL "{{ $checksum_url }}" | grep "{{ $name }}" | awk '{print $1}')
echo "$CHECKSUM  {{ $name }}.archive" | sha256sum -c -
{{- end }}

{{- /* Extract */}}
{{- if $extract_cmd }}
{{ $extract_cmd }}
{{- else }}
# Default: tar.gz with single binary
tar -xzf "{{ $name }}.archive" "{{ $bin }}" 2>/dev/null || tar -xzf "{{ $name }}.archive"
{{- end }}

{{- /* Install */}}
chmod +x "{{ $bin }}"
mkdir -p "{{ $.dirs.bin }}"
mv "{{ $bin }}" "{{ $.dirs.bin }}/{{ $bin }}"

success "{{ $name }} installed to {{ $.dirs.bin }}/{{ $bin }}"

{{- /* Generate completions */}}
{{- if $completions_cmd }}
{{ template "common/script_validate_completions_path" $ }}
{{ $completions_cmd }} > "{{ $.chezmoi.homeDir }}/.local/share/zsh/site-functions/_{{ $name }}"
success "Completions generated for {{ $name }}"
{{- end }}
{{ end }}
```

---

## 3. Usage in Scripts

### Simple Binary (single file in release)

```bash
# In run_once_after_300-install-tools.sh.tmpl

{{ template "common/script_install_binary" dict
  "name" "fzf"
  "repo" "junegunn/fzf"
  "version" "0.54.3"
  "asset_pattern" "https://github.com/junegunn/fzf/releases/download/%s/fzf-%s-linux_amd64.tar.gz"
  "completions_cmd" "fzf --zsh"
}}
```

### Binary in Archive (tar.gz with folder)

```bash
{{ template "common/script_install_binary" dict
  "name" "delta"
  "repo" "dandavison/delta"
  "version" "0.16.5"
  "bin" "delta"
  "extract_cmd" "tar -xzf delta.archive --strip-components=1 delta-*/delta"
  "completions_cmd" "delta --generate-completion zsh"
}}
```

### Go Binary (direct binary download)

```bash
{{ template "common/script_install_binary" dict
  "name" "lazygit"
  "repo" "jesseduffield/lazygit"
  "version" "0.40.2"
  "asset_pattern" "https://github.com/jesseduffield/lazygit/releases/download/v%s/lazygit_%s_Linux_x86_64.tar.gz"
  "extract_cmd" "tar -xzf lazygit.archive lazygit"
  "completions_cmd" "lazygit --generate-completion zsh"
}}
```

### NPM Package (alternative pattern)

```bash
info "Installing tldr (NPM)"
npm install -g tldr
{{ template "common/script_validate_completions_path" . }}
tldr --generate-completion zsh > "{{ .chezmoi.homeDir }}/.local/share/zsh/site-functions/_tldr"
```

---

## 4. AI Tools Installation Pattern (from repo)

### `home/.chezmoiscripts/unix/run_once_after_590-install-ai-tools.sh.tmpl`

```bash
#!/usr/bin/env bash

{{ template "common/script_is_not_ephemeral" . }}
{{ template "common/script_eval_mise" . }}
{{ template "common/script_helper" . }}

info ">>>>>> 🤖 Installing AI Tools 🤖 <<<<<<<"

{{- /* NPM-based AI tools */}}
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

{{- /* Curl-install AI tools (binary downloads) */}}
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

### Data File: `home/.chezmoidata/common/ai_tools.yaml`

```yaml
npm:
  - name: "aider"
    package: "aider-chat"
    completions_cmd: "aider --completion-zsh"
    block_on_workplace: false
  
  - name: "claude-code"
    package: "@anthropic-ai/claude-code"
    completions_cmd: "claude completion zsh"
    block_on_workplace: true
  
  - name: "continue"
    package: "continue"
    completions_cmd: "continue --completion zsh"
    block_on_workplace: false

curl:
  - name: "opencode"
    url: "https://opencode.ai/install.sh"
    script: "curl -fsSL https://opencode.ai/install.sh | bash"
    completions_cmd: "opencode completion zsh"
    block_on_workplace: false
  
  - name: "amp"
    url: "https://ampcode.com/install.sh"
    script: "curl -fsSL https://ampcode.com/install.sh | bash"
    completions_cmd: "amp completion zsh"
    block_on_workplace: false
```

---

## 5. Runtime Manager Installation (Mise)

### Pattern for Mise Plugins

```bash
# Install mise itself first
{{ template "common/script_install_binary" dict
  "name" "mise"
  "repo" "jdx/mise"
  "version" "2024.12.0"
  "asset_pattern" "https://github.com/jdx/mise/releases/download/v%s/mise-v%s-linux-x64.tar.gz"
  "completions_cmd" "mise completion zsh"
}}

# Then use mise for language runtimes
eval "$(mise activate bash)"

# Install languages via mise (no sudo, version pinned)
mise install go@1.21.0
mise install node@20.10.0
mise install python@3.11.0
mise install rust@stable

# Global default versions
mise use --global go@1.21.0
mise use --global node@20.10.0
```

---

## 6. Checksum Verification Strategies

### 1. Checksums File in Release

```go
{{- $checksum_url := printf "https://github.com/%s/releases/download/%s/checksums.txt" $repo $VERSION }}
```

### 2. Separate Checksum Asset

```go
{{- $checksum_url := printf "https://github.com/%s/releases/download/%s/%s_SHA256SUMS" $repo $VERSION $name }}
```

### 3. Inline Checksum (pinned version)

```bash
# Hardcoded for reproducible builds
EXPECTED_SHA256="abc123..."
echo "$EXPECTED_SHA256  tool.archive" | sha256sum -c -
```

### 4. Cosign/Slsa Verification (advanced)

```bash
# Verify sigstore signature
cosign verify-blob --signature tool.sig --certificate tool.crt tool.archive
```

---

## 7. Completion Generation Patterns

### Zsh Completions

```bash
# Tool has built-in completion command
tool --generate-completion zsh > ~/.local/share/zsh/site-functions/_tool

# Tool uses cobra (common pattern)
tool completion zsh > ~/.local/share/zsh/site-functions/_tool

# Tool uses clap (Rust)
tool completions zsh > ~/.local/share/zsh/site-functions/_tool

# Manual completion (rare)
cat > ~/.local/share/zsh/site-functions/_tool <<'EOF'
#compdef tool
_tool() {
  local -a commands
  commands=(
    'command1:Description'
    'command2:Description'
  )
  _describe 'tool' commands
}
_tool
EOF
```

### Bash/Fish Completions

```bash
# Bash
tool completion bash > ~/.local/share/bash-completion/completions/tool

# Fish
tool completion fish > ~/.config/fish/completions/tool.fish
```

---

## 8. Idempotency & Version Pinning

### Version Pinning in Data Files

```yaml
# home/.chezmoidata/common/versions.yaml
tools:
  fzf: "0.54.3"
  delta: "0.16.5"
  lazygit: "0.40.2"
  mise: "2024.12.0"
  yq: "4.43.1"
  jq: "1.7.1"
  bat: "0.24.0"
  eza: "0.18.0"
  zoxide: "0.9.4"
  atuin: "18.2.0"
```

### Check Before Install

```bash
# In script template
DESIRED_VERSION="{{ .tools.fzf }}"
if command -v fzf &>/dev/null; then
  CURRENT_VERSION=$(fzf --version | awk '{print $1}')
  if [[ "$CURRENT_VERSION" == "$DESIRED_VERSION" ]]; then
    info "fzf $DESIRED_VERSION already installed"
    exit 0
  fi
fi
# Proceed with install...
```

---

## 9. OS/Arch Asset Resolution

### Automatic Asset Detection

```go
{{- /* Helper to resolve asset URL for any tool */}}
{{- $os := .chezmoi.os }}
{{- $arch := .chezmoi.arch }}

{{- /* Normalize OS */}}
{{- if eq $os "darwin" }}{{ $os = "Darwin" }}{{ end }}
{{- if eq $os "linux" }}{{ $os = "Linux" }}{{ end }}
{{- if eq $os "windows" }}{{ $os = "Windows" }}{{ end }}

{{- /* Normalize Arch */}}
{{- if eq $arch "amd64" }}{{ $arch = "x86_64" }}{{ end }}
{{- if eq $arch "arm64" }}{{ $arch = "aarch64" }}{{ end }}
{{- if eq $arch "386" }}{{ $arch = "i386" }}{{ end }}

{{- /* Common patterns */}}
{{- $patterns := list
  (printf "%s_%s_%s.tar.gz" $name $os $arch)
  (printf "%s-%s-%s.tar.gz" $name $os $arch)
  (printf "%s_%s_%s.zip" $name $os $arch)
-}}
```

---

## 10. Testing Binary Install

### Dry Run

```bash
# Test template rendering
chezmoi execute-template --data='{"tools":{"fzf":"0.54.3"}}' \
  home/.chezmoitemplates/common/script_install_binary \
  > /tmp/test_install.sh

# Check generated script
bash -n /tmp/test_install.sh
```

### Verify Installation

```bash
#!/usr/bin/env bash
# verify_installs.sh

tools=("fzf" "delta" "lazygit" "mise" "yq" "jq" "bat" "eza" "zoxide" "atuin")

for tool in "${tools[@]}"; do
  if command -v "$tool" &>/dev/null; then
    version=$("$tool" --version 2>/dev/null | head -1)
    echo "✅ $tool: $version"
  else
    echo "❌ $tool: NOT INSTALLED"
  fi
done

# Check completions
for tool in "${tools[@]}"; do
  if [[ -f "$HOME/.local/share/zsh/site-functions/_$tool" ]]; then
    echo "✅ Completion: $tool"
  else
    echo "⚠️  Completion missing: $tool"
  fi
done
```

---

## 11. Common Issues & Fixes

| Issue | Cause | Fix |
|-------|-------|-----|
| `command not found` after install | `~/.local/bin` not in PATH | Add `export PATH="$HOME/.local/bin:$PATH"` to 099-environment.zsh |
| Checksum mismatch | Version changed, checksum not updated | Update checksum in data file or use `latest` with checksums.txt |
| Wrong binary for arch | Asset pattern doesn't match | Verify release assets naming, adjust pattern |
| Permission denied | Binary not executable | `chmod +x` before move |
| Completion not working | fpath not set | Add `fpath=("$HOME/.local/share/zsh/site-functions" $fpath)` to 099-environment.zsh |
| Tool already installed via package manager | Conflict | Check first: `if ! command -v tool; then install; fi` |

---

## 12. Related Skills

| Skill | Relationship |
|-------|--------------|
| `chezmoi-script-lifecycle` | Scripts use this pattern |
| `chezmoi-template-patterns` | Helper is a Go template |
| `chezmoi-multi-profile` | Different tools per profile |
| `chezmoi-ignore-patterns` | Exclude heavy tools on ephemeral |
| `dotfiles-zsh-modular` | Completions integrate with Zsh |
| `dotfiles-vps-bootstrap` | Minimal tools on VPS |

---

## 13. References

- **GitHub Releases API**: https://docs.github.com/en/rest/releases/releases
- **Mise docs**: https://mise.jdx.dev/
- **Repo AI tools**: `fabiosouzadev/dotfiles` → `home/.chezmoidata/common/ai_tools.yaml`, `.chezmoiscripts/unix/run_once_after_590-install-ai-tools.sh.tmpl`
- **Helper template**: `home/.chezmoitemplates/common/script_install_binary`

---

*Generated via Loop Engineering Mode — Phase 4: Skill Creation. Validated against live repo analysis.*