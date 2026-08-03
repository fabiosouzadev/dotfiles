---
name: chezmoi-secret-management
description: "Manage age/GPG secrets in chezmoi: encrypt, decrypt, rotate."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [chezmoi, secrets, age, gpg, encryption, security]
    category: devops
requires_toolsets: [terminal, file]
supersedes: []
---

# ChezMoi Secret Management Skill

**Trigger**: Use when managing encrypted secrets in chezmoi — age for native chezmoi encryption, GPG for legacy files, recipient configuration, key rotation, and fork safety procedures.

**Goal**: Provide complete reference for secret management patterns from `fabiosouzadev/dotfiles` enabling secure, version-controlled secrets with safe distribution via forks.

---

## 1. Two-Layer Encryption Strategy

### Why Two Systems?

| Layer | Tool | Use Case | Key Management |
|-------|------|----------|----------------|
| **Native chezmoi** | `age` | `.chezmoi.yaml.tmpl` data, templates, scripts | Single recipient (age public key) |
| **Legacy/External** | `gpg` | Encrypted Zsh snippets (`encrypted_*.zsh.asc`), external files | Multiple recipients, web of trust |

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    CHEZMOI REPO (PUBLIC)                    │
│  ┌─────────────────────┐  ┌─────────────────────────────┐  │
│  │  age-encrypted      │  │  gpg-encrypted              │  │
│  │  - private_*.toml   │  │  - private_dot_config/      │  │
│  │  - *.age            │  │  - encrypted_*.zsh.asc      │  │
│  │  (auto-decrypt on   │  │  (manual decrypt via        │  │
│  │   chezmoi apply)    │  │   gpg --decrypt)            │  │
│  └─────────────────────┘  └─────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                    DESTINATION ($HOME)                      │
│  ~/.config/chezmoi/chezmoi.yaml        → decrypted config   │
│  ~/.config/app/secrets.toml            → decrypted secrets  │
│  ~/.zshrc.d/encrypted_*.zsh            → sourced directly   │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. Age Encryption (Native ChezMoi)

### Setup

```bash
# 1. Generate age key pair (once per user)
age-keygen -o ~/.config/chezmoi/age.key

# 2. Extract public key (add to .chezmoi.yaml.tmpl)
age-keygen -y ~/.config/chezmoi/age.key
# Output: age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# 3. Configure recipient in .chezmoi.yaml.tmpl
age:
  recipient: "age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  identity: "~/.config/chezmoi/age.key"  # optional, for decrypt
```

### Encrypting Files

```bash
# Encrypt a file for chezmoi (output: file.age)
chezmoi age encrypt --recipient age1xxxx... --output secrets.toml.age secrets.toml

# Or use the shorthand (requires recipient in config)
chezmoi age encrypt secrets.toml
```

### Decrypting Files

```bash
# Decrypt (requires identity/private key)
chezmoi age decrypt --identity ~/.config/chezmoi/age.key --output secrets.toml secrets.toml.age

# Auto-decrypt on apply (configured in .chezmoi.yaml.tmpl)
chezmoi apply
```

### In `fabiosouzadev/dotfiles`

```yaml
# home/.chezmoi.yaml.tmpl
age:
  recipient: "age1qv0q0q0q0q0q0q0q0q0q0q0q0q0q0q0q0q0q0q0q0q0q0q0q0q0q0q"
  identity: "{{ .chezmoi.homeDir }}/.config/chezmoi/age.key"

# Data files use age encryption
# home/private_dot_config/chezmoi/age/recipient.txt → contains recipient
# home/private_dot_config/chezmoi/age/identity.age → encrypted identity
```

---

## 3. GPG Encryption (Legacy/External)

### Setup

```bash
# 1. Generate or import GPG key
gpg --full-generate-key
# Choose: RSA 4096, no expiry, your email

# 2. Export public key (for sharing)
gpg --armor --export your@email.com > public.key

# 3. Configure recipient in repo (FORK-GUIDE.md)
# Recipient: E691C031009FB1DAA3A25125212D516F623C5747 (from repo)
```

### Encrypting Files

```bash
# Encrypt for specific recipient (output: file.asc)
gpg --encrypt --armor --recipient E691C031009FB1DAA3A25125212D516F623C5747 \
    --output encrypted_secrets.zsh.asc secrets.zsh

# Encrypt for multiple recipients
gpg --encrypt --armor --recipient key1 --recipient key2 \
    --output file.asc file
```

### Decrypting Files

```bash
# Decrypt (requires private key)
gpg --decrypt --output secrets.zsh encrypted_secrets.zsh.asc

# In Zsh - source directly (if gpg-agent configured)
source <(gpg --decrypt encrypted_secrets.zsh.asc 2>/dev/null)
```

### In `fabiosouzadev/dotfiles`

```bash
# Encrypted Zsh snippets in home/
private_dot_config/
  encrypted_api_keys.zsh.asc      # API keys, tokens
  encrypted_ssh_config.zsh.asc    # SSH aliases, keys
  encrypted_workplace.zsh.asc     # Work-specific secrets

# In dot_zshrc.tmpl - sourced conditionally
{{- if .features.workplace.zup }}
source "{{ .chezmoi.homeDir }}/.config/encrypted_workplace.zsh"
{{- end }}
```

---

## 4. Secret File Patterns

### Age-Encrypted (`.chezmoidata/` or templates)

```
home/
├── private_dot_config/
│   └── chezmoi/
│       └── age/
│           ├── recipient.txt           # plaintext recipient
│           └── identity.age            # age-encrypted private key
├── private_dot_ssh/
│   └── id_ed25519.age                  # age-encrypted SSH key
└── .chezmoidata/
    └── vps/
        └── secrets.toml.age            # VPS-specific secrets (API keys, tokens)
```

### GPG-Encrypted (sourced by shell)

```
home/
├── private_dot_config/
│   ├── encrypted_api_keys.zsh.asc
│   ├── encrypted_ssh_config.zsh.asc
│   └── encrypted_workplace.zsh.asc
└── .chezmoiignore.tmpl  # ensures .asc files copied as-is
```

---

## 5. Using Secrets in Templates

### Age Secrets (auto-decrypted)

```go
# In .chezmoi.yaml.tmpl - data.output includes decrypted secrets
{{ $vps_secrets := fromYaml (include ".chezmoidata/vps/secrets.toml.age") }}
data:
  vps_secrets: $vps_secrets

# In template - access decrypted values
{{- if .settings.vps }}
api_key: {{ .vps_secrets.api_key }}
db_password: {{ .vps_secrets.db_password }}
{{- end }}
```

### GPG Secrets (manual decrypt at runtime)

```bash
# In script template - decrypt on demand
{{ template "common/script_helper" . }}

decrypt_secret() {
  local file=$1
  gpg --quiet --decrypt "$file" 2>/dev/null || {
    error "Failed to decrypt $file (gpg key not available?)"
    return 1
  }
}

# Usage
API_KEY=$(decrypt_secret "{{ .chezmoi.homeDir }}/.config/encrypted_api_keys.zsh.asc")
```

---

## 6. Fork Safety — Critical for Distribution

### The Problem

When someone forks `fabiosouzadev/dotfiles`:
1. **Age secrets**: Encrypted to *your* recipient → fork owner **cannot decrypt**
2. **GPG secrets**: Encrypted to *your* key → fork owner **cannot decrypt**
3. **Private keys**: If committed unencrypted → **catastrophic leak**

### Solution: Fork Guide Protocol (`docs/FORK-GUIDE.md`)

```markdown
# Forking This Repository

## 1. BEFORE FORKING - Rotate Your Keys

### Age Key Rotation
```bash
# Generate new key pair
age-keygen -o ~/.config/chezmoi/age.key

# Get new public key
age-keygen -y ~/.config/chezmoi/age.key
# → age1newrecipient...

# Update .chezmoi.yaml.tmpl
# age.recipient = "age1newrecipient..."

# Re-encrypt all age secrets
chezmoi age encrypt --recipient age1newrecipient... secrets.toml
```

### GPG Key Rotation
```bash
# Generate new GPG key
gpg --full-generate-key

# Export new public key
gpg --armor --export new@email.com

# Re-encrypt all GPG secrets
gpg --encrypt --armor --recipient new@email.com secrets.zsh
```

## 2. AFTER FORKING - Replace All Secrets

1. **Delete all encrypted files** in fork:
   ```bash
   find . -name "*.age" -o -name "*.asc" | xargs rm -f
   ```

2. **Generate your own keys** (see step 1)

3. **Create your own secrets** and encrypt with YOUR keys

4. **Update recipient** in `.chezmoi.yaml.tmpl`

5. **Test**: `chezmoi apply --dry-run` should work without decryption errors

## 3. NEVER COMMIT

- Unencrypted private keys (SSH, age, GPG)
- Plaintext API keys, passwords, tokens
- `.age.key` or `secring.gpg`
- Any file that would compromise your infrastructure
```

### Automated Fork Safety Checks

```bash
#!/usr/bin/env bash
# scripts/fork-safety-check.sh

echo "🔍 Checking for unencrypted secrets..."

# Check for unencrypted private keys
if find . -name "id_*" -not -name "*.pub" -not -name "*.age" -not -name "*.asc" | grep -q .; then
  echo "❌ FAIL: Unencrypted SSH private keys found!"
  exit 1
fi

# Check for plaintext secrets patterns
if grep -r "sk_live_\|ghp_\|gho_\|ghu_\|ghs_\|github_pat_\|api_key\s*=" --include="*.yaml" --include="*.toml" --include="*.json" . | grep -v ".age" | grep -v ".asc" | grep -q .; then
  echo "❌ FAIL: Plaintext API keys detected!"
  exit 1
fi

# Verify all age files can be decrypted (if identity available)
if [[ -f ~/.config/chezmoi/age.key ]]; then
  for f in $(find . -name "*.age"); do
    if ! chezmoi age decrypt --identity ~/.config/chezmoi/age.key "$f" >/dev/null 2>&1; then
      echo "⚠️ WARN: Cannot decrypt $f with current identity"
    fi
  done
fi

echo "✅ Fork safety check passed"
```

---

## 7. Key Rotation Procedures

### Age Key Rotation (Every 90 Days Recommended)

```bash
#!/usr/bin/env bash
# scripts/rotate-age-key.sh

set -euo pipefail

OLD_KEY=~/.config/chezmoi/age.key
BACKUP_DIR=~/.config/chezmoi/age-backups/$(date +%Y%m%d)
mkdir -p "$BACKUP_DIR"

# 1. Backup old key
cp "$OLD_KEY" "$BACKUP_DIR/age.key.bak"

# 2. Generate new key
age-keygen -o "$OLD_KEY"
NEW_RECIPIENT=$(age-keygen -y "$OLD_KEY")

echo "New recipient: $NEW_RECIPIENT"

# 3. Update .chezmoi.yaml.tmpl
sed -i "s/recipient: \"age1.*\"/recipient: \"$NEW_RECIPIENT\"/" home/.chezmoi.yaml.tmpl

# 4. Re-encrypt all age files
find home -name "*.age" | while read f; do
  # Decrypt with old key (from backup)
  plaintext=$(chezmoi age decrypt --identity "$BACKUP_DIR/age.key.bak" "$f")
  # Encrypt with new key
  echo "$plaintext" | chezmoi age encrypt --recipient "$NEW_RECIPIENT" --output "$f" -
done

# 5. Commit changes
git add home/.chezmoi.yaml.tmpl home/**/*.age
git commit -m "security(age): rotate age encryption key"

echo "✅ Age key rotated. Backup at $BACKUP_DIR"
```

### GPG Key Rotation

```bash
#!/usr/bin/env bash
# scripts/rotate-gpg-key.sh

set -euo pipefail

# 1. Generate new key
gpg --full-generate-key
# Note the new key ID

# 2. Export new public key
NEW_KEY_ID=$(gpg --list-secret-keys --keyid-format=long | grep sec | head -1 | awk '{print $2}' | cut -d'/' -f2)
gpg --armor --export "$NEW_KEY_ID" > ~/.gnupg/new-public.key

# 3. Re-encrypt all GPG files
find home -name "*.asc" | while read f; do
  plaintext=$(gpg --decrypt "$f" 2>/dev/null)
  echo "$plaintext" | gpg --encrypt --armor --recipient "$NEW_KEY_ID" --output "$f" -
done

# 4. Update FORK-GUIDE.md with new recipient
sed -i "s/E691C031009FB1DAA3A25125212D516F623C5747/$NEW_KEY_ID/" docs/FORK-GUIDE.md

# 5. Commit
git add home/**/*.asc docs/FORK-GUIDE.md
git commit -m "security(gpg): rotate GPG encryption key"

echo "✅ GPG key rotated to $NEW_KEY_ID"
```

---

## 8. CI/CD Integration

### GitHub Actions - Secret Scanning

```yaml
# .github/workflows/secret-scan.yml
name: Secret Scan
on: [push, pull_request]

jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Install trufflehog
        run: |
          curl -sSfL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh | sh -s -- -b /usr/local/bin
      
      - name: Scan for secrets
        run: trufflehog filesystem --directory=. --fail
      
      - name: Check fork safety
        run: ./scripts/fork-safety-check.sh
```

### Pre-commit Hook

```yaml
# .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: fork-safety
        name: Fork Safety Check
        entry: ./scripts/fork-safety-check.sh
        language: system
        stages: [commit]
```

---

## 9. Debugging Secrets

```bash
# Verify age recipient in config
chezmoi execute-template home/.chezmoi.yaml.tmpl | grep -A2 "age:"

# Test age decrypt
chezmoi age decrypt --identity ~/.config/chezmoi/age.key home/private_dot_config/chezmoi/age/identity.age

# Test GPG decrypt
gpg --decrypt home/private_dot_config/encrypted_api_keys.zsh.asc

# List all encrypted files
find home -name "*.age" -o -name "*.asc" | sort

# Dry run apply (shows decryption errors)
chezmoi apply --dry-run --verbose 2>&1 | grep -i "decrypt\|age\|gpg"
```

---

## 10. Common Issues & Fixes

| Issue | Symptom | Fix |
|-------|---------|-----|
| `age: recipient not found` | Apply fails | Add `age.recipient` to `.chezmoi.yaml.tmpl` |
| `gpg: decryption failed: No secret key` | GPG decrypt fails | Import private key: `gpg --import private.key` |
| `chezmoi: age identity not found` | Auto-decrypt fails | Set `age.identity` in config or `~/.config/chezmoi/age.key` |
| Fork clone fails apply | Cannot decrypt secrets | Follow FORK-GUIDE.md: rotate keys, re-encrypt |
| `gpg-agent` not running | GPG decrypt hangs | `gpg-connect-agent /bye` or `export GPG_TTY=$(tty)` |

---

## 11. Related Skills

| Skill | Relationship |
|-------|--------------|
| `chezmoi-architecture` | Prerequisite: understands data flow |
| `chezmoi-template-patterns` | Templates access decrypted secrets |
| `chezmoi-environment-detection` | Profile-specific secrets (VPS vs work) |
| `chezmoi-script-lifecycle` | Scripts decrypt secrets at runtime |
| `dotfiles-fork-guide` | Fork safety procedures |
| `dotfiles-backup-strategy` | Backup encrypted state |

---

## 12. References

- **age documentation**: https://github.com/FiloSottile/age
- **ChezMoi age encryption**: https://www.chezmoi.io/user-guide/encryption/age/
- **ChezMoi GPG encryption**: https://www.chezmoi.io/user-guide/encryption/gpg/
- **Repo secrets**: `fabiosouzadev/dotfiles` → `home/private_dot_config/`, `.chezmoi.yaml.tmpl` age config
- **Fork guide**: `docs/FORK-GUIDE.md`

---

*Generated via Loop Engineering Mode — Phase 4: Skill Creation. Validated against live repo analysis.*