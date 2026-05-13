# Concerns

> Last mapped: 2026-05-07

## Technical Debt

### 1. Duplicated Code in `dot_bashrc.tmpl`
**Severity: Medium** | **File**: `home/dot_bashrc.tmpl`

The bashrc file contains duplicated blocks:
- `cd ~` appears 4 times (lines 118-131)
- `dbus-launch` evaluation block is duplicated 4 times (lines 121-140)
- This appears to be accidental copy-paste rather than intentional

### 2. Duplicated Repo Clone Script
**Severity: Low** | **Files**: Both `darwin/` and `linux/` contain identical `run_onchange_after_605-clone-my-repos.sh.tmpl` (3678 bytes each)

The clone script exists in both OS-specific directories with the same content. This should likely be moved to `unix/` or made into a shared template.

### 3. AI Tool Proliferation
**Severity: Low** | **Directory**: `home/.chezmoiscripts/unix/`

17 separate AI CLI tool install scripts in `unix/`. Many of these tools serve overlapping purposes:
- Claude Code, OpenClaude, Claude Code Router (3 Claude-related tools)
- Aider, OpenCode, Copilot CLI, Cursor CLI, Codex CLI (5 coding assistants)
- Gemini CLI, Qwen Code CLI, Kilo Code CLI, Amp CLI, Kiro Code CLI (5 more CLIs)

This creates significant install time and potential PATH/env conflicts. Consider making AI tools opt-in via feature flags.

### 4. Aider Config is Mostly Comments
**Severity: Low** | **File**: `home/dot_aider.conf.yaml.tmpl`

The 483-line aider config file is almost entirely commented-out template documentation. Only the `editor: nvim` line (line 441) is actually active. The file could be dramatically simplified.

## Security Considerations


### 1. Age Encryption Key Management
**Severity: Medium**

The age identity key lives at `~/.config/chezmoi/key.txt`. If this key is lost:
- All 17 encrypted `.age` files become inaccessible
- SSH keys, GPG keys, API keys, VPN certificates all lost
- No documented backup/recovery procedure in the repo

**Recommendation**: Document key backup procedure. Consider key escrow or multi-recipient encryption.

### 2. API Keys in Shell Environment
**Severity: Medium** | **File**: `dot_zshrc.d/encrypted_300-ai-api-keys.zsh.age`

API keys are decrypted into the shell environment at login. Any process running in the shell can read them via `env` or `/proc/self/environ`. This is standard practice but worth noting.

### 3. Claude Code Router Config Has Env Var References
**Severity: Low** | **File**: `dot_claude-code-router/config.json`

Uses `${OPENROUTER_API_KEY}` and `${GEMINI_API_KEY}` shell variable syntax in a JSON file. This is not standard JSON and relies on the router tool supporting env var expansion.

### 4. Ollama Listens on Localhost
**Severity: Low** | **Config**: `.chezmoidata/ollama.yaml`

Ollama is configured to listen on `127.0.0.1:11434`. This is safe for local use, but scripts don't verify the binding after installation.

## Fragile Areas

### 1. Environment Detection in `.chezmoi.yaml.tmpl`
**Severity: High** | **File**: `home/.chezmoi.yaml.tmpl`

The 244-line config file performs extremely complex environment detection:
- CI detection across 10+ CI providers
- Container detection using cgroup, /.dockerenv, username heuristics
- WSL GUI probe using X11 socket and xdpyinfo
- Nested ternary expressions for GUI availability

This is the most fragile part of the codebase. A false positive in container detection could cause the system to skip GUI configurations on a desktop. The `$guiAvailable` ternary chain (line 97) is particularly hard to reason about.

### 2. Ollama Install Script Complexity
**Severity: Medium** | **File**: `.chezmoiscripts/linux/run_once_after_504-install-ollama.sh.tmpl`

At 6.6KB, this is one of the most complex scripts. It handles multiple installation modes (user, root/systemd, compile) and has significant branching logic.

### 3. Window Manager Package Dependencies
**Severity: Medium** | **File**: `.chezmoidata/linux/linux.wm.json`

WM packages vary between Arch and Ubuntu and between i3 and niri. The install script (`216-install-wm.sh.tmpl`) must correctly parse this nested JSON structure and handle missing packages gracefully.

### 4. Compile-from-source Scripts
**Severity: Medium** | **Files**: `run_once_before_223-compile-nvim.tmpl`, `run_once_before_224-compile-tmux.tmpl`

Compiling Neovim and tmux from source is inherently fragile:
- Dependencies may change between versions
- Build flags may become incompatible
- These are `run_once` — if they fail, chezmoi won't retry automatically

## Performance Concerns

### 1. Zsh Startup Time
**Severity: Medium**

The zsh config sources 20+ files at startup, including:
- Zinit plugin loading (3 plugins)
- Multiple `eval` commands (mise, direnv, zoxide, starship, claude-code-router)
- OpenClaw sourcing

Each `eval $(tool init)` adds ~50-200ms to shell startup. Consider lazy-loading or deferred initialization.

### 2. `run_onchange_` Script Re-execution
**Severity: Low**

Scripts prefixed with `run_onchange_` re-execute whenever their rendered content changes. This means changing a single package in `.chezmoidata/` triggers a full package install run. This is by design but can be slow.

### 3. Large Number of AI Tool Install Scripts
**Severity: Low**

17 AI tool install scripts in `unix/` all run on first apply. Each requires network access (npm install, pip install, etc.). First-time setup on a new machine could take significant time.

## Improvement Opportunities

1. **Add CI pipeline**: Validate templates render correctly on multiple OS containers
2. **Deduplicate bashrc**: Clean up the repeated `cd ~` and `dbus-launch` blocks
3. **Consolidate repo clone scripts**: Move from `darwin/` + `linux/` to `unix/`
4. **Make AI tools opt-in**: Add feature flags for AI tool categories
5. **Simplify aider config**: Remove 480 lines of comments, keep only active config
6. **Document key backup**: Add recovery instructions for age encryption key
7. **Lazy-load shell tools**: Use zinit's `wait` or `atinit` for deferred loading
8. **Add shellcheck**: Lint shell scripts for best practices
9. **Typo fix**: `310-eval-starshipt.zsh.tmpl` has a typo ("starshipt" → "starship")
