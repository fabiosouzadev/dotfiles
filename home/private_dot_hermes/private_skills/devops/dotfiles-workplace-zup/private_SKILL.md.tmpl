---
name: dotfiles-workplace-zup
description: "Zup workplace config: VPN, SSH, git, Bob, AWS, kubectl."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos]
metadata:
  hermes:
    tags: [dotfiles, workplace, zup, vpn, ssh, git, aws, kubernetes]
    category: devops
requires_toolsets: [terminal, file]
supersedes: []
---

# Dotfiles Workplace Zup Skill

**Trigger**: Use when configuring Zup-specific workplace settings — SSH keys, Instivo VPN, Bob CLI, git config, AWS profiles, kubectl contexts, internal tools.

**Goal**: Provide complete reference for Zup workplace patterns from `fabiosouzadev/dotfiles` enabling seamless onboarding and configuration for Zup-issued laptops.

---

## 1. Workplace Detection

### In `.chezmoi.yaml.tmpl`

```go
{{- $hostLower := lower .chezmoi.hostname }}
{{- $ismanaged := ($hostLower | contains "zwpe0f96cn") }}

{{- if $ismanaged }}
data:
  features:
    workplace:
      zup: true
{{- end }}
```

### Hostname Pattern

| Pattern | Matches |
|---------|---------|
| `*zwpe0f96cn*` | Zup-issued laptops (corporate asset tag) |

---

## 2. Zsh Module: `200-workplace.zsh`

```zsh
# Zup Workplace Configuration
# Only loaded when .features.workplace.zup = true

# ===== GIT CONFIG =====
export GIT_AUTHOR_EMAIL="fabio.vanderlei@zup.com.br"
export GIT_COMMITTER_EMAIL="fabio.vanderlei@zup.com.br"
git config --global user.email "fabio.vanderlei@zup.com.br"
git config --global user.name "Fábio Vanderlei"
git config --global commit.gpgsign true
git config --global gpg.program "gpg"

# ===== SSH KEY FOR WORK GITHUB =====
# Uses dedicated work key
export GIT_SSH_COMMAND='ssh -i ~/.ssh/id_ed25519_work -o IdentitiesOnly=yes'

# SSH config for work GitHub
cat >> ~/.ssh/config <<'EOF' 2>/dev/null || true
Host github.com-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_work
    IdentitiesOnly yes
EOF

# ===== INSTIVO VPN =====
zup-vpn() {
  local config="${HOME}/.config/instivo/config.ovpn"
  if [[ -f "$config" ]]; then
    echo "Connecting to Instivo VPN..."
    sudo openvpn --config "$config"
  else
    echo "Instivo config not found at $config"
    echo "Download from: https://vpn.instivo.com/config.ovpn"
  fi
}

# VPN status
zup-vpn-status() {
  if pgrep -x openvpn >/dev/null; then
    echo "VPN: Connected"
  else
    echo "VPN: Disconnected"
  fi
}

# ===== BOB (Zup Internal Tool) =====
if command -v bob &>/dev/null; then
  alias zup-deploy="bob deploy"
  alias zup-logs="bob logs --tail=100"
  alias zup-shell="bob shell"
  alias zup-status="bob status"
  
  # Bob completions
  if [[ -f ~/.local/share/zsh/site-functions/_bob ]]; then
    source ~/.local/share/zsh/site-functions/_bob
  fi
fi

# ===== AWS PROFILE =====
export AWS_PROFILE="${AWS_PROFILE:-zup-prod}"
export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-us-east-1}"

# AWS helpers
zup-aws-login() {
  aws sso login --profile zup-prod
}

zup-aws-console() {
  aws configure get sso_start_url --profile zup-prod | xargs -I {} open {}
}

# ===== KUBERNETES =====
alias kctx-zup="kubectl config use-context zup-cluster"
alias kns-zup="kubectl config set-context --current --namespace=zup"

# Kubeconfig helper
zup-kubeconfig() {
  if command -v bob &>/dev/null; then
    bob kubeconfig --profile zup-prod > ~/.kube/config
    echo "Kubeconfig updated"
  fi
}

# ===== INTERNAL TOOLS =====
# Zup CLI (if available)
if command -v zup &>/dev/null; then
  alias zup-apps="zup apps list"
  alias zup-services="zup services list"
fi

# ===== PROXY (if corporate) =====
# export HTTP_PROXY="http://proxy.zup.com.br:8080"
# export HTTPS_PROXY="http://proxy.zup.com.br:8080"
# export NO_PROXY="localhost,127.0.0.1,.zup.com.br"

# ===== ALIASES =====
alias zup-vpn-up="zup-vpn"
alias zup-vpn-down="sudo pkill openvpn"
alias zup-status="zup-vpn-status && bob status 2>/dev/null || true"
```

---

## 3. Data File: `.chezmoidata/work/workplace.yaml`

```yaml
# Workplace-specific configuration (loaded only on Zup profile)
git:
  email: "fabio.vanderlei@zup.com.br"
  name: "Fábio Vanderlei"
  signing_key: "work-gpg-key-id"
  gpg_program: "gpg"

ssh:
  keys:
    - name: "work-ed25519"
      path: "~/.ssh/id_ed25519_work"
      host: "github.com"
      user: "git"
      # Public key deployed via chezmoi (encrypted)

vpn:
  instivo:
    config_url: "https://vpn.instivo.com/config.ovpn"
    config_path: "~/.config/instivo/config.ovpn"
    autostart: false

tools:
  bob: true
  zup_cli: true

aws:
  profile: "zup-prod"
  region: "us-east-1"
  sso_start_url: "https://zup.awsapps.com/start"

kubernetes:
  context: "zup-cluster"
  namespace: "zup"

shell:
  aliases:
    zup-deploy: "bob deploy"
    zup-logs: "bob logs --tail=100"
    zup-shell: "bob shell"
    zup-vpn: "zup-vpn"
```

---

## 4. SSH Key Management (Encrypted)

### Private Key (GPG-encrypted)

```
home/private_dot_config/
├── encrypted_id_ed25519_work.asc    # GPG encrypted
└── encrypted_id_ed25519_work.pub.asc
```

### In `.chezmoi.yaml.tmpl` (decrypt on apply)

```go
{{- if .features.workplace.zup }}
{{- $ssh_key := fromYaml (include ".chezmoidata/work/ssh_key.yaml.age") }}
data:
  work_ssh_key: $ssh_key
{{- end }}
```

### Deploy Script: `run_once_after_530-setup-zup-vpn.sh.tmpl`

```bash
#!/usr/bin/env bash

{{ template "common/script_is_not_ephemeral" . }}
{{ template "common/script_is_not_workplace" . }}

info ">>>>>> 🏢 Zup Workplace Setup 🏢 <<<<<<"

# 1. SSH Key
if [[ -n "{{ .work_ssh_key.private_key }}" ]]; then
  mkdir -p ~/.ssh
  chmod 700 ~/.ssh
  echo "{{ .work_ssh_key.private_key }}" > ~/.ssh/id_ed25519_work
  chmod 600 ~/.ssh/id_ed25519_work
  
  echo "{{ .work_ssh_key.public_key }}" > ~/.ssh/id_ed25519_work.pub
  chmod 644 ~/.ssh/id_ed25519_work.pub
  
  success "Work SSH key deployed"
fi

# 2. SSH Config
cat > ~/.ssh/config.d/work <<'EOF'
Host github.com-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_work
    IdentitiesOnly yes
EOF

# 3. Git Config
git config --global user.email "fabio.vanderlei@zup.com.br"
git config --global user.name "Fábio Vanderlei"
git config --global commit.gpgsign true
success "Git configured for Zup"

# 4. Instivo VPN Config
mkdir -p ~/.config/instivo
if [[ ! -f ~/.config/instivo/config.ovpn ]]; then
  warn "Instivo VPN config not found"
  warn "Download from: https://vpn.instivo.com/config.ovpn"
  warn "Place at: ~/.config/instivo/config.ovpn"
fi

# 5. Bob CLI (if not installed)
if ! command -v bob &>/dev/null; then
  info "Installing Bob CLI..."
  curl -fsSL https://bob.zup.com.br/install.sh | bash
  success "Bob CLI installed"
fi

success ">>> 🏢 Zup Workplace Ready 🏢"
```

---

## 5. GPG Key for Work (Signing Commits)

### Setup

```bash
# Generate work GPG key (if not exists)
gpg --full-generate-key
# Type: RSA and RSA
# Key size: 4096
# Expiry: 2y
# Name: Fábio Vanderlei
# Email: fabio.vanderlei@zup.com.br

# Export public key
gpg --armor --export fabio.vanderlei@zup.com.br > ~/work-gpg-pub.asc

# Add to GitHub/GitLab
# Settings → SSH and GPG keys → New GPG key
```

### In Zsh (auto-load)

```zsh
# In 200-workplace.zsh
export GPG_TTY=$(tty)
gpg-connect-agent updatestartuptty /bye >/dev/null

# Get key ID
WORK_GPG_KEY=$(gpg --list-secret-keys --keyid-format=long \
  fabio.vanderlei@zup.com.br | grep sec | awk '{print $2}' | cut -d'/' -f2)

if [[ -n "$WORK_GPG_KEY" ]]; then
  git config --global user.signingkey "$WORK_GPG_KEY"
fi
```

---

## 6. Kubernetes Context Management

### Multi-Cluster Setup

```zsh
# In 200-workplace.zsh

# List available contexts
zup-kube-contexts() {
  kubectl config get-contexts -o name | grep -E "(zup|staging|prod)"
}

# Switch context with fuzzy finder
zup-kube-switch() {
  local ctx=$(kubectl config get-contexts -o name | fzf --prompt="Kube Context> ")
  [[ -n "$ctx" ]] && kubectl config use-context "$ctx"
}

# Get current context in prompt
zup-kube-current() {
  kubectl config current-context 2>/dev/null | sed 's/^/(k8s: /; s/$/)/'
}

# Add to Starship prompt (in starship.toml)
# [custom.zup_kube]
# command = "zup-kube-current"
# when = "test -n \"$ZUP_KUBE\""
# format = "[$output]($style)"
```

---

## 7. AWS SSO Integration

### Login Flow

```zsh
# In 200-workplace.zsh

# AWS SSO login with cached credentials
zup-aws-login() {
  local profile="${1:-zup-prod}"
  if ! aws sts get-caller-identity --profile "$profile" &>/dev/null; then
    aws sso login --profile "$profile"
  fi
}

# Assume role helper
zup-aws-assume() {
  local role_arn="$1"
  local session_name="${2:-zup-session}"
  
  aws sts assume-role \
    --role-arn "$role_arn" \
    --role-session-name "$session_name" \
    --profile zup-prod \
    --output json | jq -r '.Credentials | "export AWS_ACCESS_KEY_ID=\(.AccessKeyId)\nexport AWS_SECRET_ACCESS_KEY=\(.SecretAccessKey)\nexport AWS_SESSION_TOKEN=\(.SessionToken)"'
}

# Quick console access
zup-aws-console() {
  local profile="${1:-zup-prod}"
  local url=$(aws configure get sso_start_url --profile "$profile")
  [[ -n "$url" ]] && xdg-open "$url" || open "$url"
}
```

---

## 8. Bob CLI Workflows

### Common Commands

```bash
# Deploy application
bob deploy --app minha-app --env staging

# View logs
bob logs --app minha-app --env prod --tail=200 --follow

# Shell into container
bob shell --app minha-app --env staging

# List apps
bob apps list --env prod

# Scale
bob scale --app minha-app --env staging --replicas 5

# Rollback
bob rollback --app minha-app --env prod --revision 3
```

### Aliases

```zsh
# In 200-workplace.zsh
alias bd="bob deploy"
alias bl="bob logs --tail=100 --follow"
alias bs="bob shell"
alias ba="bob apps list"
alias bsc="bob scale"
alias brb="bob rollback"
```

---

## 9. Testing Workplace Config

### Dry Run

```bash
# Test with workplace data
chezmoi execute-template --data='{"features":{"workplace":{"zup":true}}}' \
  home/dot_zshrc.d/200-workplace.zsh | head -50
```

### Verify Deployment

```bash
#!/usr/bin/env bash
# verify_zup.sh

checks=(
  "git_email:git config --global user.email | grep -q zup.com.br"
  "ssh_key:test -f ~/.ssh/id_ed25519_work"
  "ssh_config:grep -q github.com-work ~/.ssh/config"
  "bob:command -v bob"
  "aws_profile:aws configure get sso_start_url --profile zup-prod"
  "kube_context:kubectl config get-contexts zup-cluster"
  "gpg_key:gpg --list-secret-keys fabio.vanderlei@zup.com.br"
)

for check in "${checks[@]}"; do
  name="${check%%:*}"
  cmd="${check#*:}"
  if eval "$cmd" &>/dev/null; then
    echo "✅ $name"
  else
    echo "❌ $name"
  fi
done
```

---

## 10. Common Issues & Fixes

| Issue | Cause | Fix |
|-------|-------|-----|
| Work config on personal machine | Hostname contains `zwpe0f96cn` | Override `CHEZMOI_PROFILE=personal` |
| SSH key permission denied | Key not 600 | `chmod 600 ~/.ssh/id_ed25519_work` |
| VPN not connecting | Config expired | Re-download from Instivo portal |
| Bob command not found | Not installed | Run install script or check PATH |
| AWS SSO expired | Token expired | `aws sso login --profile zup-prod` |
| kubectl context missing | Kubeconfig not updated | Run `zup-kubeconfig` or `bob kubeconfig` |
| GPG signing fails | gpg-agent not running | `gpg-connect-agent /bye` |

---

## 11. Related Skills

| Skill | Relationship |
|-------|--------------|
| `chezmoi-multi-profile` | Workplace detection logic |
| `chezmoi-secret-management` | SSH/GPG key encryption |
| `chezmoi-script-lifecycle` | Workplace setup script |
| `chezmoi-ignore-patterns` | Exclude work scripts on personal |
| `dotfiles-zsh-modular` | 200-workplace.zsh module |
| `dotfiles-universal-binary-install` | Bob CLI installation |

---

## 12. References

- **Zup Internal Docs**: https://intranet.zup.com.br/
- **Instivo VPN**: https://vpn.instivo.com/
- **Bob CLI**: https://github.com/ZupIT/bob
- **Repo Workplace**: `fabiosouzadev/dotfiles` → `.chezmoidata/work/`, `dot_zshrc.d/200-workplace.zsh`

---

*Generated via Loop Engineering Mode — Phase 4: Skill Creation. Validated against live repo analysis.*