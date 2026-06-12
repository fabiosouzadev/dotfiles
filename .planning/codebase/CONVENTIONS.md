# Coding Conventions

**Analysis Date:** Fri Jun 12 2026

## Naming Patterns

**Files:**
- Use chezmoi source-state names under `home/`: `dot_` for dotfiles, `private_` for private-permission targets, `executable_` for executable targets, and `encrypted_*.asc` for age-encrypted material. Examples: `home/dot_zprofile.tmpl`, `home/private_dot_config/i3/config`, `home/dot_zshrc.d/encrypted_300-ai-api-keys.zsh.asc`.
- Use `.tmpl` suffix for files rendered through chezmoi Go templates. Examples: `home/.chezmoi.yaml.tmpl`, `home/dot_aider.conf.yaml.tmpl`, `home/.chezmoiscripts/linux/run_onchange_before_202-install-ubuntu-packages.sh.tmpl`.
- Use numeric prefixes to enforce load/order semantics in shell fragments and chezmoi scripts. Examples: `home/dot_zshrc.d/099-zshenv.zsh.tmpl`, `home/dot_zshrc.d/999-autoload-compinit.zsh.tmpl`, `home/.chezmoiscripts/unix/run_once_after_530-install-atuin.sh.tmpl`.
- Use lifecycle-prefixed chezmoi script names: `run_once_before_*`, `run_once_after_*`, `run_onchange_before_*`, `run_onchange_after_*`. Examples: `home/.chezmoiscripts/linux/run_once_before_199-install-paru.sh.tmpl`, `home/.chezmoiscripts/windows/run_onchange_before_201-install-winget-packages.ps1.tmpl`.
- Use lowercase kebab names for docs and script purposes after numeric/lifecycle prefix. Examples: `home/.chezmoiscripts/linux/run_once_before_216-install-wm.sh.tmpl`, `home/.chezmoiscripts/unix/run_once_after_510-install-ai-tools.sh.tmpl`.

**Functions:**
- Shell helper functions use lowercase names and short action labels. Shared helpers live in `home/.chezmoitemplates/common/script_helper`: `info()`, `warn()`, `error()`, `success()`.
- Prefer command-existence checks with `command -v name >/dev/null 2>&1` before aliases, optional integrations, or installers. Examples: `home/dot_zshrc.d/200-aliases.zsh.tmpl`, `home/dot_zshrc.d/101-zinit-plugins.zsh.tmpl`, `home/.chezmoiscripts/darwin/run_onchange_after_501-install-darwin-packages-macports.sh.tmpl`.

**Variables:**
- Shell variables use `UPPER_SNAKE_CASE` for runtime values. Examples: `MAIN_DISPLAY` and `LAPTOP_DISPLAY` in `home/dot_screenlayout/executable_i3_detect_displays.sh`; `VERSION` in `home/.chezmoiscripts/darwin/run_onchange_after_501-install-darwin-packages-macports.sh.tmpl`; `SOURCE_FILE` in `home/.chezmoiscripts/linux/run_onchange_before_202-install-ubuntu-packages.sh.tmpl`.
- Go template local variables use lower camelCase or short lowercase with `$` prefix. Examples: `$root`, `$features`, `$wmName`, `$wmFlavors` in `home/.chezmoiscripts/linux/run_once_before_216-install-wm.sh.tmpl`; `$vps`, `$gui_packages`, `$not_in_repos` in `home/.chezmoiscripts/linux/run_onchange_before_202-install-ubuntu-packages.sh.tmpl`.
- Chezmoi data paths use dotted lowercase object paths. Examples: `.settings.vps`, `.features.i3.enabled`, `.packages.linux.ubuntu.apt` in `home/.chezmoiscripts/linux/run_onchange_before_202-install-ubuntu-packages.sh.tmpl`.

**Types:**
- Not applicable. Repository uses shell scripts, Go templates, TOML/YAML/JSON config, markdown docs, and no application type system.

## Code Style

**Formatting:**
- No formatter config detected. No `.prettierrc*`, `eslint.config.*`, `biome.json`, `.shellcheckrc`, `shfmt`, or `stylua.toml` found at repository root.
- Shell scripts use 4-space indentation in several files such as `home/dot_screenlayout/executable_i3_detect_displays.sh` and `home/dot_zshrc.d/200-aliases.zsh.tmpl`.
- Some installer scripts use 2-space indentation inside branches, such as `home/.chezmoiscripts/linux/run_onchange_before_201-install-arch-packages.sh.tmpl` and `home/.chezmoiscripts/darwin/run_onchange_after_501-install-darwin-packages-macports.sh.tmpl`. For new code, prefer matching the file-local indentation style rather than reformatting surrounding code.
- Use `#!/usr/bin/env bash` plus `set -euo pipefail` for bash lifecycle scripts. Examples: `home/.chezmoiscripts/linux/run_onchange_before_202-install-ubuntu-packages.sh.tmpl`, `home/.chezmoiscripts/linux/run_once_before_216-install-wm.sh.tmpl`, `home/.chezmoiscripts/darwin/run_onchange_after_501-install-darwin-packages-macports.sh.tmpl`.
- Use `#!/bin/sh` only for POSIX-only standalone scripts. Example: `home/dot_screenlayout/executable_i3_detect_displays.sh`.
- Use vim modelines for generated shell/template files where present. Examples: `home/dot_zshrc.d/101-zinit-plugins.zsh.tmpl`, `home/dot_zshrc.d/302-aider.zsh.tmpl`, `home/.chezmoiscripts/darwin/run_onchange_after_501-install-darwin-packages-macports.sh.tmpl`.

**Linting:**
- No automated linting config detected.
- For new shell code, write shellcheck-friendly bash: quote variables used as paths or command args, use `command -v`, avoid unguarded `cd`, and keep `set -euo pipefail` in executable bash scripts.
- For template-heavy shell, validate rendered output with chezmoi commands instead of relying on static shell parsing, because files like `home/.chezmoiscripts/linux/run_once_before_216-install-wm.sh.tmpl` contain Go template control flow interleaved with shell.

## Import Organization

**Order:**
1. Shebang, when executable script requires it. Example: `home/.chezmoiscripts/linux/run_onchange_before_201-install-arch-packages.sh.tmpl` line 1.
2. Strict mode for bash scripts: `set -euo pipefail`. Example: `home/.chezmoiscripts/linux/run_onchange_before_202-install-ubuntu-packages.sh.tmpl`.
3. Chezmoi guard templates before work begins. Examples: `{{ template "workplace/script_is_not_zup" . }}`, `{{ template "common/script_is_not_ephemeral" . }}`, `{{ template "linux/script_ubuntu_only" . }}` in `home/.chezmoiscripts/linux/run_onchange_before_202-install-ubuntu-packages.sh.tmpl`.
4. Shared helper template after guards. Example: `{{ template "common/script_helper" . }}` in `home/.chezmoiscripts/linux/run_onchange_before_201-install-arch-packages.sh.tmpl`.
5. Runtime setup (`export PATH=...`) before package/tool operations. Example: `home/.chezmoiscripts/linux/run_onchange_before_202-install-ubuntu-packages.sh.tmpl`.
6. Operational logic with `info`/`success` status output. Example: `home/.chezmoiscripts/linux/run_onchange_before_201-install-arch-packages.sh.tmpl`.

**Path Aliases:**
- No language-level path aliases detected.
- Chezmoi reusable snippets are referenced by template name matching `home/.chezmoitemplates/<group>/<name>`. Examples: `common/script_helper`, `linux/script_ubuntu_only`, `workplace/script_is_not_zup`.

## Error Handling

**Patterns:**
- Use `set -euo pipefail` in bash lifecycle scripts to fail fast on command errors, unset variables, and pipeline failures. Examples: `home/.chezmoiscripts/linux/run_onchange_before_202-install-ubuntu-packages.sh.tmpl`, `home/.chezmoiscripts/linux/run_once_before_216-install-wm.sh.tmpl`.
- Use guard templates to exit early for unsupported environments before side effects. Examples: `home/.chezmoiscripts/linux/run_onchange_before_202-install-ubuntu-packages.sh.tmpl`, `home/.chezmoiscripts/linux/run_onchange_before_201-install-arch-packages.sh.tmpl`.
- Use idempotency checks before installing or modifying resources. Examples: `if ! command -v port` in `home/.chezmoiscripts/darwin/run_onchange_after_501-install-darwin-packages-macports.sh.tmpl`; `if ! grep -R ...` and `[ ! -f "$SOURCE_FILE" ]` in `home/.chezmoiscripts/linux/run_onchange_before_202-install-ubuntu-packages.sh.tmpl`.
- Prefer explicit skip messages for environment-based exits. Example: VPS check in `home/.chezmoiscripts/linux/run_once_before_216-install-wm.sh.tmpl`.

## Logging

**Framework:** console via shell helper functions.

**Patterns:**
- Use `info "..."` before major operations and `success "..."` after successful completion. Examples: `home/.chezmoiscripts/linux/run_onchange_before_202-install-ubuntu-packages.sh.tmpl`, `home/.chezmoiscripts/linux/run_onchange_before_201-install-arch-packages.sh.tmpl`.
- Use `warn "..."` when idempotency checks find existing resources. Example: PPA and GPG key checks in `home/.chezmoiscripts/linux/run_onchange_before_202-install-ubuntu-packages.sh.tmpl`.
- Shared log helpers are centralized in `home/.chezmoitemplates/common/script_helper`; use them instead of redefining colors in new scripts.

## Comments

**When to Comment:**
- Comment template branches that are difficult to parse after trimming markers. Example: `# if apt packages`, `# if ppas`, and `# range ppas` comments in `home/.chezmoiscripts/linux/run_onchange_before_202-install-ubuntu-packages.sh.tmpl`.
- Comment purpose for tool blocks or shell sections. Examples: `#bat`, `#eza`, `#grep`, `#direnv` in `home/dot_zshrc.d/200-aliases.zsh.tmpl`.
- Comment platform or install purpose at top of scripts. Examples: `# Install Atuin (Magical shell history)` in `home/.chezmoiscripts/unix/run_once_after_530-install-atuin.sh.tmpl`; `# Install Macports` in `home/.chezmoiscripts/darwin/run_onchange_after_501-install-darwin-packages-macports.sh.tmpl`.

**JSDoc/TSDoc:**
- Not applicable. No JavaScript/TypeScript application code detected.

## Function Design

**Size:**
- Keep zsh fragments focused on one concern per numbered file. Examples: aliases in `home/dot_zshrc.d/200-aliases.zsh.tmpl`, plugin setup in `home/dot_zshrc.d/101-zinit-plugins.zsh.tmpl`, external env sourcing in `home/dot_zshrc.d/302-aider.zsh.tmpl`.
- Keep chezmoi lifecycle scripts grouped by platform and installation concern. Examples: Ubuntu packages in `home/.chezmoiscripts/linux/run_onchange_before_202-install-ubuntu-packages.sh.tmpl`, Arch packages in `home/.chezmoiscripts/linux/run_onchange_before_201-install-arch-packages.sh.tmpl`, macOS MacPorts packages in `home/.chezmoiscripts/darwin/run_onchange_after_501-install-darwin-packages-macports.sh.tmpl`.

**Parameters:**
- Scripts take configuration from chezmoi template data instead of CLI parameters. Examples: `.packages.linux.arch.*` in `home/.chezmoiscripts/linux/run_onchange_before_201-install-arch-packages.sh.tmpl`, `.packages.linux.ubuntu.*` in `home/.chezmoiscripts/linux/run_onchange_before_202-install-ubuntu-packages.sh.tmpl`.
- Shell helpers accept message text through `$*`. Example: `info() { ... $*; }` in `home/.chezmoitemplates/common/script_helper`.

**Return Values:**
- Lifecycle scripts signal success/failure through exit status; `set -euo pipefail` makes failed commands fail the script.
- Guard templates should exit early for unsupported platforms/environments, as used in `home/.chezmoiscripts/linux/run_once_before_216-install-wm.sh.tmpl`.

## Module Design

**Exports:**
- No application module exports detected.
- Shared shell behavior is exported into scripts by Go template inclusion from `home/.chezmoitemplates/`, especially `home/.chezmoitemplates/common/script_helper` and platform guards under `home/.chezmoitemplates/linux/`, `home/.chezmoitemplates/darwin/`, `home/.chezmoitemplates/windows/`, and `home/.chezmoitemplates/workplace/`.

**Barrel Files:**
- Not applicable. No TypeScript/JavaScript barrel exports detected.
- Zsh uses ordered source fragments in `home/dot_zshrc.d/` rather than barrel files. Add new shell startup behavior as a numbered file in `home/dot_zshrc.d/` and keep topic scope narrow.

---

*Convention analysis: Fri Jun 12 2026*
