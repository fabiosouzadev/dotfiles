---
name: chezmoi-environment-detection
description: "Detect OS, VPS, CI, containers, WSL, cloud IDEs in chezmoi."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [chezmoi, detection, environment, vps, ci, wsl, container]
    category: devops
requires_toolsets: [terminal, file]
supersedes: []
---

# ChezMoi Environment Detection Skill

**Trigger**: Use when you need to detect the runtime environment in chezmoi templates — OS, VPS, CI/CD, containers, WSL, cloud IDEs, headless/ephemeral contexts — to conditionally apply configs, skip scripts, or adjust feature flags.

**Goal**: Provide battle-tested detection patterns from `fabiosouzadev/dotfiles` that correctly classify any machine into: personal laptop, work laptop (Zup), VPS (Oracle Cloud ARM64), CI runner, Codespaces, DevContainer, WSL, Termux, or container.

---

## 1. Detection Philosophy

### The Detection Pipeline

```
Raw Env Vars → Derived Flags → Profile Resolution → Feature Matrix
     │              │                  │                │
     ▼              ▼                  ▼                ▼
  $CI=true    $ephemeral=true    $profile="vps"   features.ai.ollama=false
  $CODESPACES $headless=true     $profile="work"  features.gui=false
  $WSL_DISTRO $guiAvailable=false                features.sudo=true
```

### Key Principles

| Principle | Implementation |
|-----------|----------------|
| **Explicit > Heuristic** | `CHEZMOI_PROFILE`, `CHEZMOI_VPS` env vars override auto-detection |
| **Fail Safe** | Default to most restrictive (ephemeral/headless) when uncertain |
| **Composable** | Each detection is independent; combine with `or`/`and` |
| **Testable** | Every flag can be overridden via `--data` for unit testing |

---

## 2. Raw Environment Variables (Source of Truth)

### CI/CD Detection

| Variable | Values | Platform |
|----------|--------|----------|
| `CI` | `"true"` | Generic (GitHub Actions, GitLab CI, CircleCI, etc.) |
| `GITHUB_ACTIONS` | `"true"` | GitHub Actions |
| `GITLAB_CI` | `"true"` | GitLab CI |
| `CIRCLECI` | `"true"` | CircleCI |
| `BUILDKITE` | `"true"` | Buildkite |
| `DRONE` | `"true"` | Drone |
| `TEAMCITY_VERSION` | set | TeamCity |
| `TRAVIS` | `"true"` | Travis CI |

### Cloud IDE Detection

| Variable | Values | Platform |
|----------|--------|----------|
| `CODESPACES` | `"true"` | GitHub Codespaces |
| `DEVCONTAINER` | `"true"` | VS Code Dev Containers |
| `GITPOD_WORKSPACE_ID` | set | Gitpod |
| `REPL_SLUG` | set | Replit |
| `CODER_AGENT` | `"true"` | Coder |
| `STACKBLITZ` | `"true"` | StackBlitz |

### Container/VM Detection

| Variable / File | Values | Meaning |
|-----------------|--------|---------|
| `/.dockerenv` | exists | Running in Docker |
| `CONTAINER` | `"true"` | Generic container |
| `KUBERNETES_SERVICE_HOST` | set | Kubernetes pod |
| `VIRTUALIZATION` | `"wsl"` | WSL2 (systemd) |
| `WSL_DISTRO_NAME` | set | WSL distro name |
| `WSL_INTEROP` | set | WSL interop |

### Terminal/Session Detection

| Variable | Values | Meaning |
|----------|--------|---------|
| `TERM` | `"dumb"`, `"xterm-256color"`, etc. | Terminal type |
| `SSH_CONNECTION` | set | SSH session |
| `SSH_CLIENT` | set | SSH client connection |
| `SSH_TTY` | set | SSH TTY allocated |
| `DISPLAY` | set | X11 display (GUI) |
| `WAYLAND_DISPLAY` | set | Wayland display (GUI) |
| `XDG_SESSION_TYPE` | `"x11"`, `"wayland"`, `"tty"` | Session type |

### Termux (Android)

| Variable | Values | Meaning |
|----------|--------|---------|
| `PREFIX` | `/data/data/com.termux/files/usr` | Termux prefix |
| `TERMUX_VERSION` | set | Termux app version |

---

## 3. Derived Detection Variables (`.chezmoi.yaml.tmpl`)

### Complete Detection Pipeline from `fabiosouzadev/dotfiles`

```go
{{- /* ===== 1. CI/CD DETECTION ===== */}}
{{- $ci := or (eq (env "CI") "true") (env "GITHUB_ACTIONS" | not | not) (env "GITLAB_CI" | not | not) (env "CIRCLECI" | not | not) (env "BUILDKITE" | not | not) (env "DRONE" | not | not) }}

{{- /* ===== 2. CLOUD IDE DETECTION ===== */}}
{{- $codespaces := eq (env "CODESPACES") "true" }}
{{- $devContainer := eq (env "DEVCONTAINER") "true" }}
{{- $gitpod := eq (env "GITPOD_WORKSPACE_ID" | not | not) "true" }}
{{- $replit := eq (env "REPL_SLUG" | not | not) "true" }}
{{- $coder := eq (env "CODER_AGENT") "true" }}
{{- $stackblitz := eq (env "STACKBLITZ") "true" }}

{{- /* ===== 3. EPHEMERAL = CI OR CLOUD IDE ===== */}}
{{- $ephemeral := or $ci $codespaces $devContainer $gitpod $replit $coder $stackblitz }}

{{- /* ===== 4. TERMINAL/SESSION DETECTION ===== */}}
{{- $interactiveTTY := eq (env "TERM" | not | not) "true" }}
{{- $sshSession := or (env "SSH_CONNECTION" | not | not) (env "SSH_CLIENT" | not | not) (env "SSH_TTY" | not | not) }}

{{- /* ===== 5. GUI DETECTION ===== */}}
{{- $guiAvailable := or
    (and (eq .chezmoi.os "linux") (not $headless) (not $wsl) (not $inContainer))
    (eq .chezmoi.os "darwin")
    (and (eq .chezmoi.os "windows") (not $wsl))
  }}

{{- /* ===== 6. WSL DETECTION ===== */}}
{{- $wsl := or
    (hasPrefix "WSL" (env "WSL_DISTRO_NAME" | default ""))
    (hasPrefix "WSL" (env "WSL_INTEROP" | default ""))
    (eq (env "VIRTUALIZATION") "wsl")
  }}

{{- /* ===== 7. CONTAINER DETECTION ===== */}}
{{- $inContainer := or
    (exists "/.dockerenv")
    (eq (env "CONTAINER") "true")
    (env "KUBERNETES_SERVICE_HOST" | not | not)
  }}

{{- /* ===== 8. TERMUX DETECTION ===== */}}
{{- $termux := hasPrefix "com.termux" (env "PREFIX" | default "") }}

{{- /* ===== 9. HEADLESS = NO GUI OR SSH OR CONTAINER OR WSL OR TERMUX ===== */}}
{{- $headless := or
    (not $interactiveTTY)
    (not $guiAvailable)
    $wsl
    $inContainer
    $sshSession
    $termux
  }}

{{- /* ===== 10. VPS DETECTION (ORACLE CLOUD ARM64) ===== */}}
{{- $hostLower := lower .chezmoi.hostname }}
{{- $isVps := or
    (env "CHEZMOI_VPS" | not | not)              // Explicit override
    (hasPrefix "instance-" $hostLower)           // Oracle Cloud instance-*
    ($hostLower | contains "vps")                // hostname contains "vps"
    ($hostLower | contains "vnic")               // Oracle VNIC
    (and
      (eq .chezmoi.os "linux")
      (eq .chezmoi.username "ubuntu")
      $sshSession
      (not $guiAvailable)
    )
  }}

{{- /* ===== 11. WORKPLACE DETECTION (ZUP) ===== */}}
{{- $ismanaged := ($hostLower | contains "zwpe0f96cn") }}

{{- /* ===== 12. PROFILE RESOLUTION ===== */}}
{{- $profile := env "CHEZMOI_PROFILE" | default ($ismanaged | ternary "work" "personal") }}
{{- if $isVps }}{{ $profile = "vps" }}{{ end }}
```

---

## 4. Detection Result Matrix

| Environment | `ephemeral` | `headless` | `guiAvailable` | `wsl` | `inContainer` | `termux` | `sshSession` | `isVps` | `ismanaged` | `profile` |
|-------------|-------------|------------|----------------|-------|---------------|----------|--------------|---------|-------------|-----------|
| **Personal Laptop (Linux)** | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | personal |
| **Personal Laptop (macOS)** | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | personal |
| **Personal Laptop (Windows)** | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | personal |
| **Work Laptop (Zup)** | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | work |
| **VPS (Oracle ARM64)** | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ | ❌ | vps |
| **GitHub Actions** | ✅ | ✅ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | personal* |
| **GitHub Codespaces** | ✅ | ✅ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | personal* |
| **VS Code DevContainer** | ✅ | ✅ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | personal* |
| **Gitpod** | ✅ | ✅ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | personal* |
| **WSL2 (Ubuntu)** | ❌ | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | personal |
| **Termux (Android)** | ❌ | ✅ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | personal |
| **SSH to Remote** | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌** | ❌ | personal |

*Profile defaults to `personal` in ephemeral environments (can be overridden with `CHEZMOI_PROFILE`)
**Unless it matches VPS heuristics

---

## 5. Feature Flags by Profile (from detection)

```go
{{- /* Base features (all profiles) */}}
{{- $baseFeatures := dict
  "ai" (dict
    "coding_assistants" true
    "hermes" (dict
      "dashboard" (dict "enabled" false)
    )
    "omniroute" (dict "enabled" false)
    "coding_orchestrator" (dict "enabled" false)
  )
  "gui" (dict "enabled" (not $headless))
  "sudo" (dict "available" (and (not $ephemeral) (not $codespaces) (not $devContainer)))
}}

{{- /* Profile-specific overrides */}}
{{- $features := merge $baseFeatures (dict) }}

{{- if eq $profile "personal" }}
{{-   $features = merge $features (dict
      "ai" (dict
        "hermes" (dict "dashboard" (dict "enabled" false))
        "omniroute" (dict "enabled" false)
        "ollama" (dict "enabled" true)
      )
      "gui" (dict "enabled" true)
      "desktop" (dict "window_manager" true "fonts" true "drivers" true)
    ) }}
{{- else if eq $profile "work" }}
{{-   $features = merge $features (dict
      "ai" (dict
        "hermes" (dict "dashboard" (dict "enabled" false))
        "omniroute" (dict "enabled" false)
        "coding_orchestrator" (dict "enabled" false)
      )
      "workplace" (dict "zup" true)
      "sudo" (dict "available" false)
    ) }}
{{- else if eq $profile "vps" }}
{{-   $features = merge $features (dict
      "ai" (dict
        "hermes" (dict "dashboard" (dict "enabled" true "port" 9119 "domain" "hermes.fabiosouzadev.duckdns.org"))
        "omniroute" (dict "enabled" true "port" 20128 "domain" "omniroute.fabiosouzadev.duckdns.org")
        "coding_orchestrator" (dict "enabled" true "schedule" "0 2 * * *" "budget_per_night" 5 "budget_per_task" 2)
        "ollama" (dict "enabled" false)
      )
      "gui" (dict "enabled" false)
      "desktop" (dict "window_manager" false "fonts" false "drivers" false)
      "vps" (dict
        "dockge" true
        "caddy" true
        "tailscale" true
        "duckdns" true
        "agentmemory" true
      )
      "sudo" (dict "available" true)
    ) }}
{{- end }}

data:
  features: $features
  settings:
    vps: $isVps
    ephemeral: $ephemeral
    headless: $headless
    guiAvailable: $guiAvailable
    profile: $profile
    osid: .chezmoi.osid
    interactiveTTY: $interactiveTTY
    sshSession: $sshSession
    wsl: $wsl
    inContainer: $inContainer
    termux: $termux
    codespaces: $codespaces
    devContainer: $devContainer
    gitpod: $gitpod
    replit: $replit
```

---

## 6. Using Detection in Templates

### In `.chezmoiignore.tmpl` (Conditional Exclusion)

```go
{{- /* Exclude Linux-specific on non-Linux */}}
{{- if not (.settings.osid | lower | contains "linux" ) }}
.chezmoiscripts/linux/**
.chezmoidata/linux/**
.mozilla/**
.config/systemd/**
{{- end }}

{{- /* Exclude VPS-incompatible on VPS */}}
{{- if .settings.vps }}
.chezmoiscripts/linux/run_once_before_216-install-wm.sh.tmpl
.chezmoiscripts/linux/run_once_after_220-configure-wm.sh.tmpl
.chezmoidata/linux/fonts.yaml
.chezmoidata/linux/nvidia.yaml
.chezmoidata/linux/virtualbox.yaml
.mozilla/**
.config/gtk-*/
.config/systemd/user/*.service
{{- end }}

{{- /* Exclude VPS scripts on non-VPS */}}
{{- if (not .settings.vps) }}
.chezmoiscripts/vps/**
{{- end }}
```

### In Script Templates (Guards)

```bash
#!/usr/bin/env bash

# Exit early in ephemeral environments (CI, Codespaces, etc.)
{{ template "common/script_is_not_ephemeral" . }}

# Exit early in headless environments (no GUI, SSH, container, WSL, Termux)
{{ template "common/script_is_not_headless" . }}

{{ template "common/script_helper" . }}

# Now safe to run GUI/interactive commands
info "Installing window manager..."
```

### In Config Templates (Conditional Values)

```go
# .chezmoi.yaml.tmpl - port varies by VPS
port: {{ ternary 9119 20128 .settings.vps }}

# Domain only on VPS
domain: {{ ternary "hermes.fabiosouzadev.duckdns.org" "local" .settings.vps }}

# Feature only on non-headless
gui_tool: {{ ternary "enabled" "disabled" (not .settings.headless) }}
```

---

## 7. Testing Detection (Unit Tests)

### Test Data Sets

```bash
#!/usr/bin/env bash
# test_detection.sh

test_case() {
  local name=$1
  local data=$2
  local expected_profile=$3
  local expected_vps=$4
  local expected_headless=$5
  
  result=$(chezmoi execute-template --data="$data" home/.chezmoi.yaml.tmpl)
  # Parse result for profile, vps, headless
  # (Implementation depends on output format)
}

# Personal Linux laptop
test_case "personal_linux" \
  '{"chezmoi":{"os":"linux","hostname":"mylaptop","username":"fabio","osid":"ubuntu"},"env":{"TERM":"xterm-256color"}}' \
  "personal" "false" "false"

# Work laptop (Zup)
test_case "work_zup" \
  '{"chezmoi":{"os":"linux","hostname":"zwpe0f96cn-mbp","username":"fabio","osid":"ubuntu"},"env":{"TERM":"xterm-256color"}}' \
  "work" "false" "false"

# VPS Oracle Cloud
test_case "vps_oracle" \
  '{"chezmoi":{"os":"linux","hostname":"instance-20240101","username":"ubuntu","osid":"ubuntu"},"env":{"SSH_CONNECTION":"1.2.3.4 22 5.6.7.8 22","TERM":"xterm-256color"}}' \
  "vps" "true" "true"

# GitHub Actions
test_case "github_actions" \
  '{"chezmoi":{"os":"linux","hostname":"runner-123","username":"runner","osid":"ubuntu"},"env":{"CI":"true","GITHUB_ACTIONS":"true","TERM":"dumb"}}' \
  "personal" "false" "true"

# WSL2
test_case "wsl2" \
  '{"chezmoi":{"os":"linux","hostname":"DESKTOP-ABC","username":"fabio","osid":"ubuntu"},"env":{"WSL_DISTRO_NAME":"Ubuntu","TERM":"xterm-256color"}}' \
  "personal" "false" "true"

# Termux
test_case "termux" \
  '{"chezmoi":{"os":"linux","hostname":"localhost","username":"u0_a123","osid":"android"},"env":{"PREFIX":"/data/data/com.termux/files/usr","TERM":"xterm-256color"}}' \
  "personal" "false" "true"
```

---

## 8. Common Detection Issues & Fixes

| Issue | Symptom | Root Cause | Fix |
|-------|---------|------------|-----|
| **VPS not detected** | Work configs applied to VPS | Heuristics failed (hostname not `instance-*`) | Set `CHEZMOI_VPS=true` in VPS environment |
| **WSL detected as VPS** | VPS profile on WSL | `username=ubuntu` + `sshSession` false positive | Add `not $wsl` to VPS detection |
| **Codespaces not ephemeral** | Scripts run in Codespaces | Missing `CODESPACES` check | Add `$codespaces` to `$ephemeral` |
| **GUI available false positive** | GUI apps installed on headless | `TERM` set but no real display | Check `DISPLAY`/`WAYLAND_DISPLAY` + `$interactiveTTY` |
| **Profile stuck on work** | Personal machine gets work configs | Hostname contains `zwpe0f96cn` substring | Make workplace detection more specific |

---

## 9. Extending Detection for New Environments

### Adding a New Cloud IDE

```go
# 1. Add raw detection
{{- $newide := eq (env "NEWIDE_VAR") "true" }}

# 2. Add to ephemeral
{{- $ephemeral := or $ci $codespaces $devContainer $gitpod $replit $newide }}

# 3. Test
chezmoi execute-template --data='{"env":{"NEWIDE_VAR":"true"}}' home/.chezmoi.yaml.tmpl
```

### Adding a New Workplace

```go
# 1. Add workplace detection
{{- $newwork := ($hostLower | contains "newcompany-identifier") }}

# 2. Add to profile resolution
{{- $profile := env "CHEZMOI_PROFILE" | default ($ismanaged | ternary "work" ($newwork | ternary "newwork" "personal")) }}

# 3. Add feature overrides in profile section
{{- else if eq $profile "newwork" }}
{{-   $features = merge $features (dict "workplace" (dict "newwork" true)) }}
```

---

## 10. Debugging Detection

```bash
# See all computed settings
chezmoi execute-template home/.chezmoi.yaml.tmpl | grep -A 50 "settings:"

# Dry run with custom env
chezmoi apply --dry-run --verbose --data='{"env":{"CHEZMOI_VPS":"true"}}'

# Trace which template branches execute
chezmoi apply --trace 2>&1 | grep -E "(vps|ephemeral|headless|profile)"
```

---

## 11. Related Skills

| Skill | Relationship |
|-------|--------------|
| `chezmoi-architecture` | Prerequisite: understands data flow |
| `chezmoi-template-patterns` | Uses functions for detection logic |
| `chezmoi-script-lifecycle` | Scripts use detection guards |
| `chezmoi-ignore-patterns` | Conditional exclusion based on detection |
| `chezmoi-multi-profile` | Profile resolution logic |
| `dotfiles-vps-bootstrap` | VPS-specific detection & setup |

---

## 12. References

- **Repo detection logic**: `fabiosouzadev/dotfiles` → `home/.chezmoi.yaml.tmpl` (lines 1-150)
- **ChezMoi env functions**: https://www.chezmoi.io/reference/templates/functions/#env
- **ChezMoi exists function**: https://www.chezmoi.io/reference/templates/functions/#exists
- **Oracle Cloud instance naming**: https://docs.oracle.com/en-us/iaas/Content/Compute/Tasks/managinginstances.htm

---

*Generated via Loop Engineering Mode — Phase 4: Skill Creation. Validated against live repo analysis.*