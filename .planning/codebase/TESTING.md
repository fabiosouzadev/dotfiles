# Testing

> Last mapped: 2026-05-13

## Overview

This is a **dotfiles repository**, not a traditional software project. There is no automated test suite, CI pipeline, or formal testing framework. Validation is performed through manual application and operational verification.

## Validation Approach

### Primary Validation: `chezmoi apply`
The main validation mechanism is running `chezmoi apply` and verifying:
- Template rendering succeeds without errors
- Files are placed in the correct locations
- Scripts execute without failures
- Encrypted files are properly decrypted

### Pre-apply Checks
chezmoi provides built-in validation tools:
- `chezmoi diff` — Preview changes before applying
- `chezmoi verify` — Check target state matches source
- `chezmoi doctor` — Diagnose chezmoi configuration issues

### Template Validation
- Go templates are validated at render time by chezmoi
- Template syntax errors cause the apply to fail immediately
- The `.chezmoiignore.tmpl` file ensures OS-irrelevant files are excluded

## Manual Testing Matrix

### Operating Systems
| OS | Tested? | Notes |
|----|---------|-------|
| macOS (Darwin) | ✅ Active | Primary development machine |
| Arch Linux | ✅ Active | Desktop with Dell 3530/3520 |
| Ubuntu Linux | ✅ Historical | Package lists maintained |
| Windows | ✅ Active | winget/scoop scripts functional, cross-platform bash |
| WSL | ⚠️ Indirect | Detection logic in `.chezmoi.yaml.tmpl` |

### Environment Types
| Environment | Tested? | Notes |
|-------------|---------|-------|
| Interactive desktop | ✅ | Full GUI with window managers |
| Headless server | ⚠️ | Guards exist but less frequently tested |
| CI/Codespaces | ✅ Active | Detection logic present, ephemeral guards active across all scripts |
| Container/Docker | ⚠️ | Container detection present |


## Smoke Tests (Manual)

After `chezmoi apply`, the following can be verified:

1. **Shell starts correctly**: `zsh` launches without errors
2. **Zinit plugins load**: `zinit list` shows plugins
3. **Tools available**: `mise`, `starship`, `zoxide`, `eza` respond to `--version`
4. **Git configured**: `git config user.name` returns correct value
5. **tmux works**: `tmux` starts with Catppuccin theme
6. **Neovim works**: `nvim` starts and Navigator.nvim integration functions
7. **AI tools accessible**: `claude`, `aider`, `opencode` commands available

## Missing Testing

- **No CI/CD pipeline** for automated validation
- **No template rendering tests** (no `chezmoi execute-template` checks)
- **No cross-OS testing** (no matrix builds)
- **No linting** for shell scripts (no shellcheck integration)
- **No idempotency tests** (scripts should be re-runnable but this isn't verified)

## Recommendations for Future Testing

1. **GitHub Actions CI**: Run `chezmoi apply --dry-run` on multiple OS containers
2. **ShellCheck**: Lint all `.sh.tmpl` files for shell script best practices
3. **Template tests**: Use `chezmoi execute-template` to validate template rendering
4. **Docker-based tests**: Test `chezmoi init --apply` in clean containers for each OS
