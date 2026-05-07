# Conventions

> Last mapped: 2026-05-07

## Naming Conventions

### Chezmoi File Prefixes
Files follow chezmoi's strict naming conventions:

| Prefix | Meaning | Example |
|--------|---------|---------|
| `dot_` | Maps to `.` (hidden file) | `dot_zshrc.tmpl` → `.zshrc` |
| `private_` | Restricted file permissions | `private_dot_config/` → `.config/` |
| `encrypted_` | Age-encrypted file | `encrypted_300-ai-api-keys.zsh.age` |
| `readonly_` | Read-only permissions | `readonly_zup_ed25519.pub` |
| `.tmpl` suffix | Go template processing | `config.toml.tmpl` → `config.toml` |

### Script Naming Pattern
Scripts follow a strict ordered naming convention:
```
run_{timing}_{order}-{description}.sh.tmpl
```

| Component | Values | Purpose |
|-----------|--------|---------|
| `timing` | `once_before`, `once_after`, `onchange_before`, `onchange_after` | Execution lifecycle |
| `order` | 3-digit number (100-999) | Execution order |
| `description` | kebab-case | Script purpose |

**Execution groups:**
- **100-199**: System-level (kernels, swap, drivers, package managers)
- **200-299**: Package installation & OS configuration
- **300-499**: (reserved / encrypted keys)
- **500-599**: Tool installation (AI tools, runtime managers, VPN)
- **600-699**: Post-install configuration (repo cloning, VPN config)

### Zsh Config Numbering (`dot_zshrc.d/`)
Same numeric ordering:
- **099**: Environment variables
- **100-104**: Plugin manager, plugins, history, fzf, keybindings
- **200-201**: Aliases
- **300**: API keys (encrypted)
- **301-311**: Tool integrations (evals)
- **403-405**: Work-specific keys (encrypted)
- **504**: Utilities
- **603**: Additional integrations
- **999**: Completion initialization

### Data File Naming
- OS-specific data in subdirectories: `.chezmoidata/{darwin,linux,windows}/`
- Cross-platform data at root: `.chezmoidata/repos.json`, `.chezmoidata/ollama.yaml`
- Data format chosen by content: YAML for lists, JSON for structured data, TOML for config-like data

## Code Style

### Go Templates
- Guard templates are included at the top of scripts using `{{ template "script_name" . }}`
- Comments use Go template comment syntax: `{{- /* comment */ -}}`
- Variables use descriptive camelCase: `$ephemeral`, `$headless`, `$guiAvailable`
- Complex boolean expressions use `ternary` function for readability
- Whitespace control with `-` trimming: `{{-` and `-}}`

### Shell Scripts
- Scripts are written in bash (shebang: `#!/bin/bash`)
- Error handling: scripts generally don't use `set -e` (chezmoi handles errors)
- Package installation uses OS-specific package managers (no abstraction layer)
- Comments in Portuguese (primary language of the developer) and English

### Configuration Files
- **Consistent theme**: Catppuccin Mocha across all tools (tmux, git-delta, bat, opencode)
- **Editor**: nvim is the default editor everywhere (git, chezmoi, aider)
- **Delta**: Used consistently as git diff pager with side-by-side display

## Template Patterns

### Environment Guards
Scripts use template guards to ensure they only run on the correct OS:
```go
{{ template "script_linux_only" . }}
{{ template "script_is_not_ephemeral" . }}
```

### Conditional Blocks
OS-specific logic within config files:
```go
{{ if .settings.osid | lower | contains "windows" -}}
  // Windows-specific config
{{ end -}}
```

### Feature Flags
Feature flags are defined in `.chezmoi.yaml.tmpl` and accessed via `.features`:
```go
{{ if .features.ollama.install }}
  // Ollama config
{{ end }}
```

### Data Access Pattern
Template data from `.chezmoidata/` is accessed via dot notation:
```go
{{ range .packages.linux.arch.extra }}
  {{ . }}
{{ end }}
```

## Error Handling

- **chezmoi lifecycle**: `run_once_` scripts only execute once (tracked by chezmoi)
- **`run_onchange_`**: Re-executes when the script content changes (triggered by data changes via template rendering)
- **Installation scripts**: Generally use `|| true` patterns to avoid blocking on non-critical failures
- **Template guards**: Exit early (exit 0) if OS/environment conditions are not met

## Documentation

- **README.md**: Minimal — contains only the one-liner install command
- **In-file comments**: Portuguese and English mix (developer's native language + technical English)
- **tmux.conf**: Contains detailed installation notes and keybinding reference at the top
- **`.chezmoi.yaml.tmpl`**: Extensive Portuguese documentation explaining ephemeral/headless concepts
- **Script names**: Self-documenting via descriptive kebab-case names

## Git Conventions

- **Commit messages**: Conventional Commits format (`feat:`, `fix:`, `chore:`, `refactor:`)
- **Commit scope**: Tool or area in parentheses (e.g., `feat(wezterm):`, `chore(ollama):`)
- **Branch**: Single `main` branch
- **GPG signing**: All commits signed
- **Auto-setup remote**: Enabled for push
