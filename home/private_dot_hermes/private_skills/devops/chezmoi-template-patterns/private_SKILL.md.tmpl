---
name: chezmoi-template-patterns
description: "Master Go templates in chezmoi: functions, composition."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [chezmoi, templates, go-templates, templating, patterns]
    category: devops
requires_toolsets: [terminal, file]
supersedes: []
---

# ChezMoi Template Patterns Skill

**Trigger**: Use when writing, debugging, or reviewing chezmoi templates — especially complex conditionals, data merging, template composition, and function pipelines.

**Goal**: Provide a complete reference for Go template patterns as used in real-world chezmoi repos (like `fabiosouzadev/dotfiles`), enabling correct, maintainable, and performant templates.

---

## 1. Go Template Fundamentals in ChezMoi

### Syntax Basics

```go
{{ /* comment */ }}
{{ .variable }}                    // Print variable
{{ .settings.vps }}                // Nested access
{{ "literal string" }}             // Literal
{{ $var := "value" }}              // Variable assignment
{{ $var = "new value" }}           // Variable reassignment
{{ if condition }}...{{ end }}     // Conditional
{{ if condition }}...{{ else }}...{{ end }}
{{ range .list }}...{{ end }}      // Loop
{{ template "name" . }}            // Include template (passes current context)
{{ template "name" $ }}            // Include template (passes root context)
{{ define "name" }}...{{ end }}    // Define named template
```

### Context (`.`) — The Most Important Concept

| Context | When | Access |
|---------|------|--------|
| `.` (root) | Top-level template | `.chezmoi`, `.settings`, `.features`, `.dirs` |
| `.` (in range) | Inside `{{ range .list }}` | Current list item (`.name`, `.package`, etc.) |
| `.` (in template) | Inside `{{ template "name" . }}` | Whatever was passed (`.` or `$`) |
| `$` | Always | Root context (never changes) |

**Critical**: Always use `$` to access root variables inside loops or nested templates:
```go
{{ range .ai_tools.npm }}
  {{ $root := $ }}                    // Save root
  {{ .name }}                         // Current item
  {{ $.settings.vps }}                // Root access (works!)
  {{ $root.settings.vps }}            // Explicit root access
{{ end }}
```

---

## 2. Essential ChezMoi Functions

### String Functions

| Function | Example | Result |
|----------|---------|--------|
| `contains` | `{{ contains "vps" .chezmoi.hostname }}` | bool |
| `hasPrefix` | `{{ hasPrefix "instance-" .chezmoi.hostname }}` | bool |
| `hasSuffix` | `{{ hasSuffix ".tmpl" .chezmoi.sourceFile }}` | bool |
| `lower` | `{{ lower .chezmoi.os }}" → "linux" | string |
| `upper` | `{{ upper .chezmoi.arch }}` → "ARM64" | string |
| `replace` | `{{ replace .chezmoi.hostname "." "-" }}` | string |
| `split` | `{{ split .chezmoi.hostname "." }}` | []string |
| `join` | `{{ join (split .chezmoi.hostname ".") "-" }}` | string |
| `trim` | `{{ trim "  hello  " }}` → "hello" | string |
| `quote` | `{{ quote "hello world" }}` → `"hello world"` | string |
| `squote` | `{{ squote "hello world" }}` → `'hello world'` | string |

### List/Map Functions

| Function | Example | Result |
|----------|---------|--------|
| `len` | `{{ len .ai_tools.npm }}` | int |
| `first` | `{{ (first .ai_tools.npm).name }}` | first item |
| `last` | `{{ (last .ai_tools.npm).name }}` | last item |
| `index` | `{{ index .features.ai "coding_assistants" }}` | map value |
| `keys` | `{{ keys .features.ai }}` | []string |
| `values` | `{{ values .features.ai }}` | []values |
| `hasKey` | `{{ hasKey .features.ai "hermes" }}` | bool |
| `dict` | `{{ dict "a" 1 "b" 2 }}` | map |
| `merge` | `{{ merge .defaults .overrides }}` | merged map |
| `omit` | `{{ omit .settings "ephemeral" }}` | map without key |
| `pick` | `{{ pick .settings "vps" "profile" }}` | map with only keys |

### Conditional Functions

| Function | Example | Result |
|----------|---------|--------|
| `ternary` | `{{ ternary "yes" "no" .settings.vps }}` | "yes" or "no" |
| `coalesce` | `{{ coalesce .env.VAR "default" }}` | first non-empty |
| `empty` | `{{ empty .settings.vps }}` | bool |
| `not` | `{{ not .settings.vps }}` | bool |
| `or` | `{{ or .a .b .c }}` | first truthy |
| `and` | `{{ and .a .b .c }}` | last if all truthy |
| `eq` / `ne` / `lt` / `le` / `gt` / `ge` | `{{ eq .chezmoi.os "linux" }}` | bool |

### Path/OS Functions

| Function | Example | Result |
|----------|---------|--------|
| `osPath` | `{{ osPath ".config" "chezmoi" }}` | platform-specific path |
| `expandPath` | `{{ expandPath "~/.config" }}` | absolute path |
| `base` | `{{ base "/home/user/.zshrc" }}` → ".zshrc" | string |
| `dir` | `{{ dir "/home/user/.zshrc" }}` → "/home/user" | string |
| `cleanPath` | `{{ cleanPath "a//b/../c" }}` → "a/c" | string |

### Crypto/Encoding

| Function | Example | Result |
|----------|---------|--------|
| `sha256` | `{{ sha256 "secret" }}` | hex string |
| `toJson` | `{{ toJson .settings }}` | JSON string |
| `toYaml` | `{{ toYaml .features }}` | YAML string |
| `fromJson` | `{{ fromJson $jsonStr }}` | map |
| `fromYaml` | `{{ fromYaml $yamlStr }}` | map |

---

## 3. Data Access Patterns

### Root Variables (Available Everywhere)

```go
// Built-in chezmoi vars
.chezmoi.os              // "linux", "darwin", "windows"
.chezmoi.arch            // "amd64", "arm64"
.chezmoi.hostname        // "instance-20240101"
.chezmoi.username        // "ubuntu", "fabio"
.chezmoi.homeDir         // "/home/ubuntu"
.chezmoi.sourceDir       // "/home/ubuntu/.local/share/chezmoi"
.chezmoi.version         // "2.47.0"
.chezmoi.sourceFile      // current template path
.chezmoi.sourceFileDir   // directory of current template

// Custom vars from .chezmoi.yaml.tmpl data.output
.settings.vps            // bool
.settings.ephemeral      // bool
.settings.headless       // bool
.settings.profile        // "personal" | "work" | "vps"
.settings.osid           // "ubuntu", "arch", "fedora"
.settings.interactiveTTY // bool
.settings.guiAvailable   // bool
.settings.sshSession     // bool
.settings.wsl            // bool
.settings.inContainer    // bool
.settings.termux         // bool
.settings.codespaces     // bool
.settings.devContainer   // bool
.settings.gitpod         // bool
.settings.replit         // bool

.features.ai.coding_assistants
.features.ai.hermes.dashboard.enabled
.features.ai.hermes.dashboard.port
.features.ai.hermes.dashboard.domain
.features.ai.omniroute.enabled
.features.ai.coding_orchestrator.enabled

.dirs.local
.dirs.bin
.dirs.workspaces.personal
.dirs.workspaces.zup
```

### Accessing `.chezmoidata/` Files

```go
// In .chezmoi.yaml.tmpl — loaded via `include` or `fromYaml`
{{ $ai_tools := fromYaml (include ".chezmoidata/ai_tools.yaml") }}
{{ $vps_features := fromYaml (include ".chezmoidata/vps/features.yaml") }}

// Then passed via data.output to all templates
data:
  ai_tools: $ai_tools
  vps_features: $vps_features
```

### In Script Templates — Range Loops

```go
{{- range .ai_tools.npm }}
  {{- $enabled := $.features.ai.coding_assistants }}
  {{- if and $enabled (not .block_on_workplace) }}
  info "Installing {{ .name }} (NPM)"
  {{ .env | default "" }} npm install -g {{ .package }}
  {{- end }}
{{- end }}
```

---

## 4. Conditionals — Patterns & Anti-Patterns

### ✅ Good: Simple Ternary for Values

```go
# In .chezmoi.yaml.tmpl
port: {{ ternary 9119 20128 .settings.vps }}
domain: {{ ternary "local" "hermes.fabiosouzadev.duckdns.org" .settings.vps }}
```

### ✅ Good: Guard Clauses at Template Start

```go
{{- if not .settings.vps }}
{{-   /* Entire template only for non-VPS */ }}
... window manager configs ...
{{- end }}
```

### ✅ Good: Feature Flag Checks

```go
{{- if and $.features.ai.coding_assistants (not .block_on_workplace) }}
  {{- /* Only install if feature enabled AND not blocked on workplace */ }}
{{- end }}
```

### ⚠️ Complex: Nested Ternary (Hard to Read)

```go
# IN .chezmoi.yaml.tmpl — AVOID WHEN POSSIBLE
$guiAvailable := or
  (and (eq .chezmoi.os "linux") (not $headless) (not $wsl) (not $inContainer))
  (eq .chezmoi.os "darwin")
  (and (eq .chezmoi.os "windows") (not $wsl))

# BETTER: Extract to named template
{{ define "guiAvailable" }}
  {{- if eq .chezmoi.os "darwin" }}true
  {{- else if and (eq .chezmoi.os "linux") (not .settings.headless) (not .settings.wsl) (not .settings.inContainer) }}true
  {{- else if and (eq .chezmoi.os "windows") (not .settings.wsl) }}true
  {{- else }}false{{ end }}
{{ end }}
```

### ❌ Anti-Pattern: Logic in Templates That Should Be in Data

```go
# BAD: Complex logic in template
{{- if and (eq .chezmoi.os "linux") (eq .chezmoi.osid "ubuntu") (not .settings.vps) }}
  apt install -y {{ .packages.ubuntu | join " " }}
{{- end }}

# GOOD: Data-driven
# .chezmoidata/linux/packages.yaml:
#   ubuntu: [pkg1, pkg2]
#   arch: [pkg1, pkg2]
# In template:
{{- if not .settings.vps }}
  {{- range index .packages .chezmoi.osid }}
  apt install -y {{ . }}
  {{- end }}
{{- end }}
```

---

## 5. Template Composition — DRY Patterns

### 1. Named Templates (Define/Template)

```go
# In .chezmoitemplates/common/script_helper
{{ define "script_helper" }}
info() { echo -e "\033[1;34m[INFO]\033[0m $*"; }
warn() { echo -e "\033[1;33m[WARN]\033[0m $*"; }
success() { echo -e "\033[1;32m[SUCCESS]\033[0m $*"; }
error() { echo -e "\033[1;31m[ERROR]\033[0m $*"; }
{{ end }}

# In any script template:
{{ template "common/script_helper" . }}
```

### 2. Guard Templates (Early Exit)

```go
# .chezmoitemplates/common/script_is_not_ephemeral
{{ define "script_is_not_ephemeral" }}
{{- if .settings.ephemeral }}
exit 0
{{- end }}
{{ end }}

# Usage (MUST be at top of script, before shebang processing):
{{ template "common/script_is_not_ephemeral" . }}
#!/usr/bin/env bash
...
```

### 3. Helper with Parameters (via dict)

```go
# Define
{{ define "install_binary" }}
{{- $name := .name }}
{{- $url := .url }}
{{- $bin := .bin | default $name }}
info "Installing {{ $name }}"
curl -fsSL "{{ $url }}" -o "/tmp/{{ $bin }}"
chmod +x "/tmp/{{ $bin }}"
mv "/tmp/{{ $bin }}" "{{ $.dirs.bin }}/{{ $bin }}"
{{ end }}

# Call
{{ template "common/install_binary" (dict "name" "lazygit" "url" "https://github.com/jesseduffield/lazygit/releases/download/v0.40/lazygit_0.40_Linux_x86_64.tar.gz") }}
```

### 4. Completion Generation Template

```go
# .chezmoitemplates/common/script_validate_completions_path
{{ define "script_validate_completions_path" }}
mkdir -p "{{ $.chezmoi.homeDir }}/.local/share/zsh/site-functions"
{{ end }}

# Usage in script (pass root context $):
{{ template "common/script_validate_completions_path" $ }}
{{ .completions_cmd }} > "{{ $.chezmoi.homeDir }}/.local/share/zsh/site-functions/_{{ .name }}"
```

---

## 6. Loops & Iteration Patterns

### 1. Simple Range (List)

```go
{{- range .packages.linux }}
  apt install -y {{ . }}
{{- end }}
```

### 2. Range with Index

```go
{{- range $i, $pkg := .packages.linux }}
  {{ $i }}: {{ $pkg }}
{{- end }}
```

### 3. Range Map (Keys + Values)

```go
{{- range $workspace, $repos := .repos.work.workplaces }}
  # {{ $workspace }}
  {{- range $repos }}
  git clone {{ .repo }} {{ .path }}
  {{- end }}
{{- end }}
```

### 4. Filter in Range

```go
{{- range .ai_tools.npm }}
  {{- if and $.features.ai.coding_assistants (not .block_on_workplace) }}
    npm install -g {{ .package }}
  {{- end }}
{{- end }}
```

### 5. Sort Before Range

```go
{{- range sortAlpha (keys .features.ai) }}
  {{ . }}: {{ index $.features.ai . }}
{{- end }}
```

---

## 7. Variable Scoping Rules

### Variable Assignment

```go
{{ $var := "value" }}        // New variable (:=)
{{ $var = "new" }}           // Reassign existing (=)
{{ $var := "shadow" }}       // SHADOWS outer $var in this scope!
```

### Scope Boundaries

| Construct | Creates New Scope? |
|-----------|-------------------|
| `{{ if }}...{{ end }}` | No |
| `{{ range }}...{{ end }}` | **Yes** (`.`, `$` change) |
| `{{ with }}...{{ end }}` | **Yes** (`.` changes) |
| `{{ template "name" . }}` | No (but `.` becomes passed context) |
| `{{ define }}...{{ end }}` | No (define time ≠ execute time) |

### Common Bug: Variable Shadowing in Range

```go
# BUG: $enabled shadows outer $enabled
{{ $enabled := $.features.ai.coding_assistants }}
{{- range .ai_tools.npm }}
  {{ $enabled := .enabled }}  // Shadows! Now $enabled is item.enabled
  {{ if $enabled }}...{{ end }}
{{- end }}

# FIX: Use different name or access via $
{{ $rootEnabled := $.features.ai.coding_assistants }}
{{- range .ai_tools.npm }}
  {{ $itemEnabled := .enabled }}
  {{ if and $rootEnabled $itemEnabled }}...{{ end }}
{{- end }}
```

---

## 8. Advanced Patterns from `fabiosouzadev/dotfiles`

### 1. Environment Detection Pipeline (`.chezmoi.yaml.tmpl`)

```go
# 1. Raw detection
$ci := or (eq (env "CI") "true") (env "GITHUB_ACTIONS" | not | not)
$codespaces := eq (env "CODESPACES") "true"
$devContainer := eq (env "DEVCONTAINER") "true"
$gitpod := eq (env "GITPOD_WORKSPACE_ID" | not | not) "true"
$replit := eq (env "REPL_SLUG" | not | not) "true"

# 2. Derived
$ephemeral := or $ci $codespaces $devContainer $gitpod $replit
$interactiveTTY := eq (env "TERM" | not | not) "true"
$sshSession := or (env "SSH_CONNECTION" | not | not) (env "SSH_CLIENT" | not | not)
$wsl := hasPrefix "WSL" (env "WSL_DISTRO_NAME" | default "")
$inContainer := or (exists "/.dockerenv") (env "CONTAINER" | not | not)
$termux := hasPrefix "com.termux" (env "PREFIX" | default "")

# 3. GUI detection (complex → should be template)
$guiAvailable := or
  (and (eq .chezmoi.os "linux") (not $headless) (not $wsl) (not $inContainer))
  (eq .chezmoi.os "darwin")
  (and (eq .chezmoi.os "windows") (not $wsl))

# 4. VPS detection (heuristic)
$isVps := or
  (env "CHEZMOI_VPS" | not | not)
  ($hostLower | contains "vps")
  ($hostLower | contains "vnic")
  (hasPrefix "instance-" $hostLower)
  (and (eq .chezmoi.os "linux") (eq .chezmoi.username "ubuntu") $sshSession (not $guiAvailable))

# 5. Profile resolution
$ismanaged := ($hostLower | contains "zwpe0f96cn")
$profile := env "CHEZMOI_PROFILE" | default ($ismanaged | ternary "work" "personal")
if $isVps { $profile = "vps" }
```

### 2. Feature Flag Hierarchy with Overrides

```go
features:
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
    coding_orchestrator:
      enabled: true
      schedule: "0 2 * * *"
      budget_per_night: 5
      budget_per_task: 2

# Overridden per-profile in .chezmoidata/vps/features.yaml:
# ai:
#   coding_assistants: true
#   hermes:
#     dashboard:
#       enabled: true
#   omniroute:
#     enabled: true
#   coding_orchestrator:
#     enabled: true
#   ollama:
#     enabled: false
```

### 3. Conditional Ignore Patterns (`.chezmoiignore.tmpl`)

```go
# OS-specific exclusions
{{- if not (.settings.osid | lower | contains "linux" ) }}
.chezmoiscripts/linux/**
.chezmoidata/linux/**
.mozilla/**
.config/systemd/**
{{- end }}

{{- if not (.settings.osid | lower | contains "darwin" ) }}
.chezmoiscripts/darwin/**
.chezmoidata/darwin/**
{{- end }}

# VPS-specific (exclude desktop, GUI, heavy tools)
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

# Non-VPS excludes VPS scripts
{{- if (not .settings.vps) }}
.chezmoiscripts/vps/**
{{- end }}
```

### 4. AI Tools Install Script (Template)

```bash
#!/usr/bin/env bash

{{ template "common/script_is_not_ephemeral" . }}
{{ template "common/script_eval_mise" . }}
{{ template "common/script_helper" . }}

info ">>>>>> 🤖 Installing AI Tools 🤖 <<<<<<<"

# NPM tools
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

# Curl-install tools
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

---

## 9. Debugging Templates

### 1. Execute Template Directly

```bash
# Render a template with current data
chezmoi execute-template home/.chezmoi.yaml.tmpl

# Render with custom data
chezmoi execute-template --data='{"settings":{"vps":true}}' home/dot_zshrc.tmpl
```

### 2. Debug Print in Template

```go
{{- /* Debug: print all settings */ }}
{{- warn "SETTINGS: " (toJson .settings) }}

{{- /* Debug: print current context in range */ }}
{{- range .items }}
  {{- warn "ITEM: " (toJson .) }}
{{- end }}
```

### 3. Dry Run Apply

```bash
chezmoi apply --dry-run --verbose
```

### 4. Trace Template Execution

```bash
chezmoi apply --trace 2>&1 | grep -E "(template|executing|rendering)"
```

---

## 10. Performance Best Practices

| Practice | Why |
|----------|-----|
| Use `{{- -}}` to trim whitespace | Reduces output size, cleaner scripts |
| Avoid complex logic in templates | Move to data files (`.chezmoidata/`) |
| Cache repeated computations in `$vars` | Don't recompute `$.features.ai.hermes.dashboard.enabled` in loops |
| Use `define` for reusable blocks | DRY, single source of truth |
| Keep `.chezmoiignore.tmpl` simple | Evaluated on every file operation |
| Prefer `ternary` over `if/else` for values | Single expression, easier to read |
| Don't `range` large lists in config templates | Use scripts for heavy iteration |

---

## 11. Common Errors & Fixes

| Error | Cause | Fix |
|-------|-------|-----|
| `nil pointer evaluating .settings.vps` | Variable not in `data.output` | Add to `data.settings` in `.chezmoi.yaml.tmpl` |
| `template "common/foo" not defined` | Template file not in `.chezmoitemplates/` | Create file or fix path |
| `unexpected EOF` | Unclosed `{{ if }}` or `{{ range }}` | Match every `{{ if }}` with `{{ end }}` |
| `cannot assign to $var` | Using `:=` in nested scope | Use `=` for reassignment, or different name |
| `executing template: range can't iterate over X` | Iterating non-list/non-map | Check data type with `toJson` debug |
| `function "foo" not defined` | Typo or function doesn't exist | Check [ChezMoi functions](https://www.chezmoi.io/reference/templates/functions/) |

---

## 12. Testing Templates

### Unit Test Pattern (Bash)

```bash
#!/usr/bin/env bash
# test_templates.sh

test_template() {
  local template=$1
  local data=$2
  local expected=$3
  
  result=$(chezmoi execute-template --data="$data" "$template")
  if [[ "$result" == "$expected" ]]; then
    echo "✅ PASS: $template"
  else
    echo "❌ FAIL: $template"
    echo "  Expected: $expected"
    echo "  Got: $result"
  fi
}

# Test VPS detection
test_template "home/.chezmoi.yaml.tmpl" '{"chezmoi":{"os":"linux","hostname":"instance-123","username":"ubuntu"},"settings":{"sshSession":true,"guiAvailable":false}}' "vps"
```

---

## 13. Related Skills

| Skill | Relationship |
|-------|--------------|
| `chezmoi-architecture` | Prerequisite: understands data flow |
| `chezmoi-environment-detection` | Uses template functions for detection |
| `chezmoi-script-lifecycle` | Scripts use template patterns |
| `chezmoi-ignore-patterns` | Advanced conditional exclusion |

---

## 14. References

- **Go text/template docs**: https://pkg.go.dev/text/template
- **ChezMoi template functions**: https://www.chezmoi.io/reference/templates/functions/
- **ChezMoi template variables**: https://www.chezmoi.io/reference/templates/variables/
- **Repo patterns**: `fabiosouzadev/dotfiles` — `.chezmoi.yaml.tmpl`, `.chezmoiignore.tmpl`, `.chezmoitemplates/common/`, `.chezmoiscripts/unix/run_once_after_590-install-ai-tools.sh.tmpl`

---

*Generated via Loop Engineering Mode — Phase 4: Skill Creation. Validated against live repo analysis.*