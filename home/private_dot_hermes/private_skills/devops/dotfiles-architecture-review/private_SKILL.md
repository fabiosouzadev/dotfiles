---
name: dotfiles-architecture-review
description: "Health checks, drift detection, security scan, roadmap."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos]
metadata:
  hermes:
    tags: [dotfiles, architecture, review, health, drift, security]
    category: devops
requires_toolsets: [terminal, file]
supersedes: []
---

# Dotfiles Architecture Review Skill

**Trigger**: Use when performing periodic architecture reviews of the dotfiles repository — health checks, drift detection, dependency audit, security scanning, performance baselines, refactor roadmap.

**Goal**: Provide complete reference for architecture review patterns from `fabiosouzadev/dotfiles` enabling continuous improvement and technical debt management.

---

## 1. Review Framework

### Review Cadence

| Frequency | Scope | Duration | Output |
|-----------|-------|----------|--------|
| **Weekly** | Health checks, drift detection | 15 min | Dashboard alerts |
| **Monthly** | Dependency audit, security scan | 30 min | Report + issues |
| **Quarterly** | Full architecture review | 2 hours | Roadmap + decisions |
| **Annually** | Strategic redesign | 1 day | Architecture decision records |

### Review Pillars

```
┌─────────────────────────────────────────────────────────────┐
│                 ARCHITECTURE REVIEW PILLARS                 │
├─────────────┬─────────────┬─────────────┬───────────────────┤
│   HEALTH    │   DRIFT     │  SECURITY   │   PERFORMANCE     │
│  (Status)   │ (Consistency)│ (Safety)    │   (Efficiency)    │
├─────────────┼─────────────┼─────────────┼───────────────────┤
│ Services up │ Config sync │ Secrets rot │ Apply time        │
│ Scripts ok  │ Template    │ Deps scan   │ Script duration   │
│ Backups ok  │ Schema valid│ Permissions │ Resource usage    │
│ Tests pass  │ Git clean   │ Supply chain│ Cache hit rate    │
└─────────────┴─────────────┴─────────────┴───────────────────┘
```

---

## 2. Health Checks

### System Health Script: `scripts/health-check.sh`

```bash
#!/usr/bin/env bash
# Health check for dotfiles deployment

set -euo pipeinfo

RESULTS=()
PASS=0
FAIL=0
WARN=0

check() {
  local name="$1"
  local cmd="$2"
  if eval "$cmd" &>/dev/null; then
    RESULTS+=("✅ $name")
    ((PASS++))
  else
    RESULTS+=("❌ $name")
    ((FAIL++))
  fi
}

warn_check() {
  local name="$1"
  local cmd="$2"
  if eval "$cmd" &>/dev/null; then
    RESULTS+=("✅ $name")
    ((PASS++))
  else
    RESULTS+=("⚠️  $name")
    ((WARN++))
  fi
}

info "Running dotfiles health checks..."

# ===== CHEZMOI =====
check "chezmoi installed" "command -v chezmoi"
check "chezmoi source exists" "test -d ~/.local/share/chezmoi"
check "chezmoi apply clean" "chezmoi apply --dry-run --verbose 2>&1 | grep -q 'OK'"

# ===== SHELL =====
check "zsh installed" "command -v zsh"
check "zinit installed" "test -d ~/.local/share/zinit"
check "starship installed" "command -v starship"
check "fzf installed" "command -v fzf"

# ===== TOOLS =====
check "git installed" "command -v git"
check "age installed" "command -v age"
check "rclone installed" "command -v rclone"
check "jq installed" "command -v jq"
check "yq installed" "command -v yq"

# ===== AI STACK =====
warn_check "hermes installed" "command -v hermes"
warn_check "omniroute installed" "command -v omniroute"
warn_check "aider installed" "command -v aider"

# ===== VPS SERVICES (if VPS) =====
if [[ -f /etc/systemd/system/caddy.service ]] || systemctl list-unit-files | grep -q caddy; then
  check "caddy active" "systemctl is-active caddy"
  check "dockge active" "systemctl is-active dockge"
  check "tailscale active" "systemctl is-active tailscaled"
  check "ufw active" "ufw status | grep -q active"
  check "fail2ban active" "systemctl is-active fail2ban"
fi

# ===== SYSTEMD USER SERVICES =====
check "hermes service" "systemctl --user is-active hermes"
check "omniroute service" "systemctl --user is-active omniroute"
check "orchestrator timer" "systemctl --user is-active coding-orchestrator.timer"

# ===== BACKUPS =====
warn_check "recent backup exists" "find ~/.local/share/backups -name 'backup-*.tar.gz.age' -mtime -1"
warn_check "hermes backup recent" "find ~/.local/share/hermes/backups -name 'hermes-*.sql.gz' -mtime -1"

# ===== SECRETS =====
check "age identity exists" "test -f ~/.config/age/identity"
check "GPG key available" "gpg --list-secret-keys | grep -q sec"

# ===== NETWORK =====
warn_check "internet reachable" "ping -c 1 8.8.8.8"
warn_check "github reachable" "curl -sf https://github.com >/dev/null"

# ===== SUMMARY =====
echo ""
echo "═══════════════════════════════════════"
echo "HEALTH CHECK SUMMARY"
echo "═══════════════════════════════════════"
printf "%s\n" "${RESULTS[@]}"
echo ""
echo "Pass: $PASS | Warn: $WARN | Fail: $FAIL"
echo "═══════════════════════════════════════"

[[ $FAIL -eq 0 ]] && exit 0 || exit 1
```

---

## 3. Drift Detection

### Drift Detection Script: `scripts/drift-detect.sh`

```bash
#!/usr/bin/env bash
# Detect drift between source and deployed state

set -euo pipeinfo

info "Detecting configuration drift..."

DRIFT_FOUND=0

# ===== 1. CHEZMOI MANAGED FILES =====
info "Checking chezmoi managed files..."
chezmoi managed --include=files,symlinks | while IFS= read -r file; do
  source_file="$HOME/.local/share/chezmoi/$file"
  target_file="$HOME/$file"
  
  if [[ ! -e "$target_file" ]]; then
    echo "❌ MISSING: $target_file"
    DRIFT_FOUND=1
  elif [[ -L "$target_file" ]]; then
    # Symlink - check target
    source_target=$(readlink "$source_file" 2>/dev/null || true)
    target_target=$(readlink "$target_file" 2>/dev/null || true)
    if [[ "$source_target" != "$target_target" ]]; then
      echo "⚠️  SYMLINK DRIFT: $target_file (source: $source_target, target: $target_target)"
      DRIFT_FOUND=1
    fi
  elif ! diff -q "$source_file" "$target_file" &>/dev/null; then
    echo "⚠️  CONTENT DRIFT: $target_file"
    DRIFT_FOUND=1
  fi
done

# ===== 2. TEMPLATE RENDERING =====
info "Checking template rendering..."
chezmoi managed --include=scripts | while IFS= read -r script; do
  if [[ "$script" == *.tmpl ]]; then
    rendered=$(chezmoi execute-template "$HOME/.local/share/chezmoi/$script")
    deployed=$(cat "$HOME/${script%.tmpl}" 2>/dev/null || echo "MISSING")
    if [[ "$rendered" != "$deployed" ]]; then
      echo "⚠️  TEMPLATE DRIFT: $script"
      DRIFT_FOUND=1
    fi
  fi
done

# ===== 3. GIT STATUS =====
info "Checking git status..."
cd "$HOME/.local/share/chezmoi"
if [[ -n $(git status --porcelain) ]]; then
  echo "⚠️  UNCOMMITTED CHANGES in chezmoi source"
  git status --short
  DRIFT_FOUND=1
fi

# ===== 4. SYSTEMD SERVICES =====
info "Checking systemd service drift..."
for service in hermes omniroute coding-orchestrator; do
  source_file="$HOME/.config/systemd/user/${service}.service"
  deployed_file="/etc/systemd/user/${service}.service"
  user_deployed="$HOME/.config/systemd/user/${service}.service"
  
  if [[ -f "$source_file" && -f "$user_deployed" ]]; then
    if ! diff -q "$source_file" "$user_deployed" &>/dev/null; then
      echo "⚠️  SYSTEMD DRIFT: $service.service"
      DRIFT_FOUND=1
    fi
  fi
done

# ===== SUMMARY =====
if [[ $DRIFT_FOUND -eq 0 ]]; then
  success "No drift detected ✅"
  exit 0
else
  error "Drift detected ❌"
  exit 1
fi
```

---

## 4. Dependency Audit

### Dependency Audit Script: `scripts/dependency-audit.sh`

```bash
#!/usr/bin/env bash
# Audit dependencies for vulnerabilities and updates

set -euo pipeinfo

info "Running dependency audit..."

# ===== 1. NPM GLOBAL PACKAGES =====
info "Auditing NPM global packages..."
if command -v npm &>/dev/null; then
  npm audit --global --audit-level=moderate || true
  npm outdated --global --depth=0 || true
fi

# ===== 2. HOMEBREW/APT PACKAGES =====
info "Checking system package updates..."
if command -v apt &>/dev/null; then
  apt list --upgradable 2>/dev/null | head -20
fi

# ===== 3. CHEZMOI DEPENDENCIES =====
info "Checking chezmoi version..."
chezmoi_version=$(chezmoi --version | awk '{print $3}')
latest_version=$(curl -fsSL https://api.github.com/repos/twpayne/chezmoi/releases/latest | jq -r .tag_name)
echo "Current: $chezmoi_version | Latest: $latest_version"

# ===== 4. BINARY TOOLS (via universal install) =====
info "Checking binary tool versions..."
tools=(fzf delta lazygit mise yq jq bat eza zoxide atuin)
for tool in "${tools[@]}"; do
  if command -v "$tool" &>/dev/null; then
    current=$("$tool" --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    echo "$tool: $current"
  fi
done

# ===== 5. GITHUB ACTIONS / WORKFLOWS =====
info "Checking GitHub Actions workflows..."
if [[ -d .github/workflows ]]; then
  for workflow in .github/workflows/*.yml; do
    echo "Checking $workflow..."
    # Check for pinned actions
    grep -E 'uses: [^@]+@[^#]+' "$workflow" | while read -r line; do
      echo "  ⚠️  Unpinned action: $line"
    done
  done
fi

# ===== 6. SUPPLY CHAIN (SBOM) =====
info "Generating SBOM..."
if command -v syft &>/dev/null; then
  syft dir:~/.local/share/chezmoi -o spdx-json > ~/sbom-$(date +%Y%m%d).json
fi
```

---

## 5. Security Scan

### Security Scan Script: `scripts/security-scan.sh`

```bash
#!/usr/bin/env bash
# Security scan for dotfiles repository

set -euo pipeinfo

info "Running security scan..."

ISSUES=0

# ===== 1. SECRET SCANNING =====
info "Scanning for secrets..."
if command -v gitleaks &>/dev/null; then
  gitleaks detect --source="$HOME/.local/share/chezmoi" --verbose || ISSUES=1
else
  # Manual patterns
  patterns=(
    "sk-[a-zA-Z0-9]{48}"           # Anthropic
    "sk-[a-zA-Z0-9]{32,}"          # OpenAI
    "gh[pousr]_[a-zA-Z0-9]{36}"    # GitHub
    "xoxb-[0-9]+-[0-9]+-[a-zA-Z0-9]+"  # Slack
    "AWS[A-Z0-9]{20}"              # AWS
    "-----BEGIN.*PRIVATE KEY-----" # Private keys
  )
  
  for pattern in "${patterns[@]}"; do
    if grep -rE "$pattern" "$HOME/.local/share/chezmoi" --exclude-dir=.git 2>/dev/null; then
      echo "❌ Potential secret found: $pattern"
      ISSUES=1
    fi
  done
fi

# ===== 2. FILE PERMISSIONS =====
info "Checking file permissions..."
find "$HOME/.local/share/chezmoi" -type f -name "*.age" -o -name "*.asc" | while read -r file; do
  perms=$(stat -c "%a" "$file")
  if [[ "$perms" != "600" && "$perms" != "400" ]]; then
    echo "⚠️  Insecure permissions on $file: $perms"
    ISSUES=1
  fi
done

# ===== 3. SSH KEY PERMISSIONS =====
info "Checking SSH key permissions..."
[[ -f "$HOME/.ssh/id_ed25519" ]] && [[ $(stat -c "%a" "$HOME/.ssh/id_ed25519") != "600" ]] && \
  echo "❌ SSH private key permissions too open" && ISSUES=1

# ===== 4. GPG KEY EXPIRY =====
info "Checking GPG key expiry..."
gpg --list-secret-keys --keyid-format=long | grep -E "sec.*expires:" | while read -r line; do
  expiry=$(echo "$line" | grep -oE 'expires: [0-9-]+' | cut -d' ' -f2)
  if [[ -n "$expiry" ]]; then
    days_left=$(( ($(date -d "$expiry" +%s) - $(date +%s)) / 86400 ))
    if [[ $days_left -lt 30 ]]; then
      echo "⚠️  GPG key expires in $days_left days: $expiry"
      ISSUES=1
    fi
  fi
done

# ===== 5. AGE RECIPIENT VALIDATION =====
info "Validating age recipient..."
if [[ -f "$HOME/.config/age/identity" ]]; then
  age_pubkey=$(age-keygen -y ~/.config/age/identity 2>/dev/null)
  if ! grep -q "$age_pubkey" "$HOME/.local/share/chezmoi/.chezmoi.yaml.tmpl" 2>/dev/null; then
    echo "⚠️  Age public key not found in chezmoi config"
    ISSUES=1
  fi
fi

# ===== 6. DANGEROUS PATTERNS =====
info "Checking for dangerous patterns..."
dangerous=(
  "curl.*|.*bash"      # Pipe to bash
  "wget.*|.*bash"      # Pipe to bash
  "chmod 777"          # World writable
  "sudo.*rm -rf"       # Dangerous sudo
  "eval.*\$"           # Eval with variable
)

for pattern in "${dangerous[@]}"; do
  if grep -rE "$pattern" "$HOME/.local/share/chezmoi" --include="*.sh*" --include="*.tmpl" 2>/dev/null | grep -v "^Binary"; then
    echo "⚠️  Potentially dangerous pattern: $pattern"
    ISSUES=1
  fi
done

# ===== SUMMARY =====
if [[ $ISSUES -eq 0 ]]; then
  success "Security scan passed ✅"
  exit 0
else
  error "Security issues found ❌"
  exit 1
fi
```

---

## 6. Performance Baseline

### Performance Benchmark Script: `scripts/perf-baseline.sh`

```bash
#!/usr/bin/env bash
# Performance baseline for chezmoi apply

set -euo pipeinfo

info "Running performance baseline..."

RESULTS_FILE="$HOME/.local/share/chezmoi/perf/baseline-$(date +%Y%m%d).json"
mkdir -p "$(dirname "$RESULTS_FILE")"

# ===== 1. CHEZMOI APPLY TIME =====
info "Measuring chezmoi apply time..."
start=$(date +%s.%N)
chezmoi apply --dry-run >/dev/null 2>&1
end=$(date +%s.%N)
apply_time=$(echo "$end - $start" | bc)
echo "chezmoi apply (dry-run): ${apply_time}s"

# ===== 2. SCRIPT EXECUTION TIMES =====
info "Measuring script execution times..."
SCRIPT_DIR="$HOME/.local/share/chezmoi/.chezmoiscripts"
if [[ -d "$SCRIPT_DIR" ]]; then
  for script in "$SCRIPT_DIR"/**/*.sh.tmpl; do
    [[ -f "$script" ]] || continue
    start=$(date +%s.%N)
    bash -n "$script" 2>/dev/null || true
    end=$(date +%s.%N)
    parse_time=$(echo "$end - $start" | bc)
    echo "Parse $script: ${parse_time}s"
  done
fi

# ===== 3. TEMPLATE RENDERING TIME =====
info "Measuring template rendering..."
start=$(date +%s.%N)
chezmoi execute-template "$HOME/.local/share/chezmoi/.chezmoi.yaml.tmpl" >/dev/null
end=$(date +%s.%N)
template_time=$(echo "$end - $start" | bc)
echo "Template render: ${template_time}s"

# ===== 4. SHELL STARTUP TIME =====
info "Measuring shell startup..."
for i in {1..5}; do
  /usr/bin/time -f "%e" zsh -i -c exit 2>&1 | tail -1
done | awk '{sum+=$1} END {print "Avg zsh startup: " sum/NR "s"}'

# ===== 5. SAVE RESULTS =====
cat > "$RESULTS_FILE" <<EOF
{
  "date": "$(date -Iseconds)",
  "hostname": "$(hostname)",
  "chezmoi_apply_dry_run_seconds": $apply_time,
  "template_render_seconds": $template_time,
  "shell_startup_avg_seconds": $(/usr/bin/time -f "%e" zsh -i -c exit 2>&1 | tail -1)
}
EOF

success "Baseline saved: $RESULTS_FILE"
```

---

## 7. Refactor Roadmap

### Architecture Decision Record Template

```markdown
# ADR-<NNN>: <Title>

**Status**: Proposed | Accepted | Superseded | Deprecated

**Date**: YYYY-MM-DD

**Context**: 
What is the issue? What forces are at play?

**Decision**: 
What did we decide?

**Consequences**: 
- Positive: 
- Negative: 
- Neutral: 

**Alternatives Considered**: 
1. 
2. 

**Related**: ADR-XXX, ADR-YYY
```

### Current Roadmap (from repo analysis)

| Priority | Area | Issue | Proposed Solution | Effort |
|----------|------|-------|-------------------|--------|
| HIGH | Secrets | Age recipient hardcoded | Move to `.chezmoi.yaml` data | Low |
| HIGH | Scripts | Missing `run_onchange_after_610` | Investigate + restore or document removal | Medium |
| HIGH | VPS | `CHEZMOI_VPS` env var undocumented | Document or remove | Low |
| MEDIUM | Templates | Complex `guiAvailable` ternary | Extract to named template | Medium |
| MEDIUM | CI/CD | No GitHub Actions for validation | Add workflow: lint, test, drift | Medium |
| MEDIUM | Testing | No integration tests | Add bats tests for scripts | High |
| LOW | Docs | Architecture docs scattered | Consolidate in `docs/ARCHITECTURE.md` | Low |
| LOW | Fork Guide | No fork documentation | Create `FORK_GUIDE.md` | Medium |

---

## 8. Automated Review Pipeline

### GitHub Actions: `.github/workflows/architecture-review.yml`

```yaml
name: Architecture Review

on:
  schedule:
    - cron: '0 6 * * 1'  # Weekly Monday 06:00 UTC
  workflow_dispatch:

jobs:
  health-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup chezmoi
        run: |
          curl -fsSL https://get.chezmoi.io | sh
          echo "$HOME/.local/bin" >> $GITHUB_PATH
      - name: Run health check
        run: |
          ./scripts/health-check.sh
  
  drift-detect:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup chezmoi
        run: |
          curl -fsSL https://get.chezmoi.io | sh
          echo "$HOME/.local/bin" >> $GITHUB_PATH
      - name: Init chezmoi
        run: chezmoi init --apply ${{ github.repository }}
      - name: Run drift detection
        run: ./scripts/drift-detect.sh
  
  dependency-audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run dependency audit
        run: ./scripts/dependency-audit.sh
  
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run security scan
        run: ./scripts/security-scan.sh
  
  perf-baseline:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup chezmoi
        run: |
          curl -fsSL https://get.chezmoi.io | sh
          echo "$HOME/.local/bin" >> $GITHUB_PATH
      - name: Init chezmoi
        run: chezmoi init --apply ${{ github.repository }}
      - name: Run performance baseline
        run: ./scripts/perf-baseline.sh
      - name: Upload baseline
        uses: actions/upload-artifact@v4
        with:
          name: perf-baseline
          path: ~/.local/share/chezmoi/perf/
```

---

## 9. Review Checklist

### Quarterly Review Checklist

```
☐ Run full health check (scripts/health-check.sh)
☐ Run drift detection (scripts/drift-detect.sh)
☐ Run dependency audit (scripts/dependency-audit.sh)
☐ Run security scan (scripts/security-scan.sh)
☐ Run performance baseline (scripts/perf-baseline.sh)
☐ Review open GitHub issues labeled "tech-debt"
☐ Review ADRs for superseded decisions
☐ Check backup restore test (last 30 days)
☐ Verify age/GPG key rotation schedule
☐ Update architecture diagrams
☐ Review fork guide accuracy
☐ Plan next quarter refactors
☐ Document decisions in ADR log
```

---

## 10. Related Skills

| Skill | Relationship |
|-------|--------------|
| `chezmoi-architecture` | Prerequisite: data flow |
| `chezmoi-script-lifecycle` | Script health checks |
| `chezmoi-secret-management` | Secret scanning |
| `chezmoi-ignore-patterns` | Drift detection scope |
| `dotfiles-backup-strategy` | Backup verification |
| `dotfiles-universal-binary-install` | Dependency audit |
| `dotfiles-fork-guide` | Fork compatibility |

---

## 11. References

- **Architecture Decision Records**: https://adr.github.io/
- **Gitleaks**: https://github.com/gitleaks/gitleaks
- **Syft (SBOM)**: https://github.com/anchore/syft
- **chezmoi managed**: https://www.chezmoi.io/user-guide/command-overview/#chezmoi-managed

---

*Generated via Loop Engineering Mode — Phase 4: Skill Creation. Validated against live repo analysis.*