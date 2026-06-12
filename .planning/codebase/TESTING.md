# Testing Patterns

**Analysis Date:** Fri Jun 12 2026

## Test Framework

**Runner:**
- Not detected. Repository has no `package.json`, `jest.config.*`, `vitest.config.*`, `pytest` config, Bats config, or dedicated automated test directory.
- Validation runner is chezmoi itself through manual commands documented in `docs/TESTING.md` and `docs/DEVELOPMENT.md`.
- Config: `home/.chezmoi.yaml.tmpl` is primary render/apply config; `.chezmoiroot` points chezmoi at `home/` source root.

**Assertion Library:**
- Not detected. No automated assertion library present.
- Manual assertions check command success, rendered diff, shell startup, and tool availability.

**Run Commands:**
```bash
chezmoi apply --dry-run --verbose     # Render templates and preview apply without modifying target files
chezmoi diff                          # Preview target changes from source state
chezmoi apply                         # Apply dotfiles after dry-run review
chezmoi verify                        # Verify target state matches source where supported
chezmoi doctor                        # Diagnose chezmoi/runtime environment issues
```

## Test File Organization

**Location:**
- No test files detected by `**/*test*` or `**/*spec*` source patterns.
- Testing guidance lives in `docs/TESTING.md`.
- Development validation guidance lives in `docs/DEVELOPMENT.md`.
- Runtime scripts requiring validation live under `home/.chezmoiscripts/` by platform and lifecycle.
- Templates requiring render validation live across `home/**/*.tmpl`, especially `home/.chezmoi.yaml.tmpl`, `home/dot_zshrc.d/*.tmpl`, and `home/.chezmoiscripts/**/*.tmpl`.

**Naming:**
- No automated test naming convention detected.
- Manual validation should name evidence by feature/path in phase artifacts under `.planning/milestones/...` when using GSD workflow.

**Structure:**
```text
home/
├── .chezmoi.yaml.tmpl                 # Core template data and environment detection to render-test
├── .chezmoiscripts/<platform>/        # Lifecycle scripts to dry-run/apply-test
├── .chezmoitemplates/<group>/         # Shared guards/helpers to include-test through scripts
├── dot_zshrc.d/*.tmpl                 # Shell fragments to render and source-test
└── private_dot_config/**              # App configs to render and smoke-test

docs/TESTING.md                        # Manual validation checklist
```

## Test Structure

**Suite Organization:**
```bash
# Current manual validation pattern from docs/DEVELOPMENT.md
chezmoi apply --dry-run --verbose
chezmoi apply
```

**Patterns:**
- Setup pattern: work from chezmoi source directory `/home/fabio.souza/.local/share/chezmoi`, make changes under `home/`, then run chezmoi preview commands.
- Render validation pattern: run `chezmoi apply --dry-run --verbose` after changing `.tmpl` files such as `home/.chezmoi.yaml.tmpl`, `home/dot_zshrc.d/200-aliases.zsh.tmpl`, or `home/.chezmoiscripts/linux/run_once_before_216-install-wm.sh.tmpl`.
- Diff assertion pattern: inspect `chezmoi diff` before applying changes that modify target dotfiles.
- Apply assertion pattern: run `chezmoi apply` only after dry-run output looks correct.
- Smoke assertion pattern: verify shell starts, zinit plugins load, and expected tools respond after apply; checklist is documented in `docs/TESTING.md`.
- Cross-platform pattern: manually reason against guard templates in `home/.chezmoitemplates/linux/`, `home/.chezmoitemplates/darwin/`, `home/.chezmoitemplates/windows/`, `home/.chezmoitemplates/common/`, and `home/.chezmoitemplates/workplace/`.

## Mocking

**Framework:** Not detected.

**Patterns:**
```bash
# No mocking framework exists. Use dry-run and environment override variables for safe validation.
CHEZMOI_FORCE_HEADLESS=true chezmoi apply --dry-run --verbose
CHEZMOI_FORCE_GUI=true chezmoi apply --dry-run --verbose
CHEZMOI_SKIP_SHELL_PROBES=true chezmoi apply --dry-run --verbose
```

**What to Mock:**
- Prefer chezmoi/environment overrides for detection behavior in `home/.chezmoi.yaml.tmpl`: `CHEZMOI_PROFILE`, `CHEZMOI_FORCE_GUI`, `CHEZMOI_FORCE_HEADLESS`, `CHEZMOI_SKIP_SHELL_PROBES`, and `CI`, documented in `docs/CONFIGURATION.md`.
- For platform-gated scripts, validate rendered inclusion/exclusion via guard templates rather than running package managers on wrong host. Relevant guards live in `home/.chezmoitemplates/linux/`, `home/.chezmoitemplates/darwin/`, `home/.chezmoitemplates/windows/`, and `home/.chezmoitemplates/workplace/`.

**What NOT to Mock:**
- Do not mock encrypted files by reading or copying secret material. Encrypted secret placeholders such as `home/dot_aws/encrypted_private_credentials.asc`, `home/dot_zshrc.d/encrypted_300-ai-api-keys.zsh.asc`, and `home/dot_omniroute/encrypted_dot_env.asc` should be existence-checked only.
- Do not run package-manager install scripts against production machines as a substitute for dry-run review. Scripts like `home/.chezmoiscripts/linux/run_onchange_before_202-install-ubuntu-packages.sh.tmpl` and `home/.chezmoiscripts/linux/run_onchange_before_201-install-arch-packages.sh.tmpl` include real `sudo apt`, `sudo pacman`, `paru`, and `yay` operations.

## Fixtures and Factories

**Test Data:**
```bash
# Chezmoi data files act as fixtures for rendering package/script templates.
home/.chezmoidata/linux/linux.wm.json
home/.chezmoiexternals/atuin.toml.tmpl
home/.chezmoiexternals/tmux.toml.tmpl
home/.chezmoiexternals/i3.toml.tmpl
```

**Location:**
- Chezmoi data fixtures: `home/.chezmoidata/`.
- External-source fixtures/config templates: `home/.chezmoiexternals/`.
- Environment detection and global fixture composition: `home/.chezmoi.yaml.tmpl`.
- Shared render snippets: `home/.chezmoitemplates/`.

## Coverage

**Requirements:** None enforced.

**View Coverage:**
```bash
# Not applicable: no coverage tooling configured.
```

## Test Types

**Unit Tests:**
- Not used. No function-level shell, template, or config unit tests detected.
- Closest equivalent is rendering a focused template path with chezmoi and inspecting output/diff for files such as `home/dot_zshrc.d/200-aliases.zsh.tmpl`.

**Integration Tests:**
- Manual chezmoi integration validation is primary. Use `chezmoi apply --dry-run --verbose`, `chezmoi diff`, and `chezmoi apply` to validate interaction between `home/.chezmoi.yaml.tmpl`, `home/.chezmoidata/`, `home/.chezmoitemplates/`, and `home/.chezmoiscripts/`.
- Installer scripts require platform-aware integration checks because they perform package installs. Examples: `home/.chezmoiscripts/darwin/run_onchange_after_501-install-darwin-packages-macports.sh.tmpl`, `home/.chezmoiscripts/linux/run_onchange_before_202-install-ubuntu-packages.sh.tmpl`, and `home/.chezmoiscripts/windows/run_onchange_before_201-install-winget-packages.ps1.tmpl`.

**E2E Tests:**
- Not automated.
- Manual E2E is fresh-machine or clean-environment `chezmoi init --apply` followed by smoke checks from `docs/TESTING.md`.
- Expected smoke checks include shell startup (`zsh`), zinit plugin list (`zinit list`), tool availability (`mise`, `starship`, `zoxide`, `eza`), git identity, tmux startup, Neovim startup, and AI CLI availability.

## Common Patterns

**Async Testing:**
```bash
# Not applicable. No async test framework exists.
# For long-running install scripts, prefer dry-run/template review first and run apply only on intended platform.
chezmoi apply --dry-run --verbose
```

**Error Testing:**
```bash
# Current pattern: rely on fail-fast shell and chezmoi render/apply failures.
chezmoi apply --dry-run --verbose
chezmoi doctor
```

**Template Testing:**
```bash
# Validate Go template syntax and rendered target plan.
chezmoi apply --dry-run --verbose
chezmoi diff
```

**Shell Script Testing:**
```bash
# No ShellCheck or shfmt config detected. For new scripts, run external checks manually when available.
shellcheck path/to/rendered-script.sh
shfmt -w path/to/rendered-script.sh
```

**Idempotency Testing:**
```bash
# Manual idempotency pattern for scripts and configs.
chezmoi apply --dry-run --verbose
chezmoi apply
chezmoi apply --dry-run --verbose    # Should show no unexpected changes
```

---

*Testing analysis: Fri Jun 12 2026*
