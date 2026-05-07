# Research Summary: Dotfiles Documentation & Maintainability

**Project:** fabiosouzadev/dotfiles
**Research Date:** 2026-05-07
**Domain:** Dotfiles README documentation, keybinding cheatsheets, fork-friendly guides, maintainability patterns

## Key Findings

### README Structure (Best Practices from Top Repos)

The best dotfiles READMEs (holman/dotfiles, alrra/dotfiles, awesome-dotfiles) share a common pattern:

1. **Hero section** — Project title, 1-line description, optional screenshot/badge
2. **Quick Start** — One-liner install command per OS (the most important section)
3. **Features** — What makes this setup special (bullet list)
4. **Prerequisites** — Dependencies needed before install
5. **Detailed Installation** — Step-by-step for new machine bootstrap
6. **Structure** — Directory layout with brief explanation of each folder
7. **Customization / Fork Guide** — How to adapt for your own use
8. **Keybindings** — Cheatsheets for terminal tools
9. **Acknowledgments** — Credits and inspiration

### Keymap Documentation Format

Research shows tables are the most effective format for keybinding docs:

```markdown
> **Prefix:** `Ctrl + a`

| Key | Action |
| :--- | :--- |
| `Prefix` + `c` | New window |
| `Prefix` + `|` | Vertical split |
```

**Best practices:**
- Group by context (Sessions, Windows, Panes, Navigation)
- Standardize notation (`Prefix` for tmux, `Leader` for nvim)
- Use backticks for key combos
- Include the configured prefix/leader at the top
- Note plugin dependencies (e.g., "requires Navigator.nvim")

### Fork & Customization Guide

Key elements for a fork-friendly repo:
- Explain `.chezmoi.yaml.tmpl` variables that need changing (username, email, GPG key)
- List files that contain personal data vs generic config
- Warn about encrypted files (they won't work without the user's age key)
- Provide a "first fork" checklist
- Explain how `.chezmoidata/` drives package selection per OS

### Maintainability Patterns from Research

**Common anti-patterns found in our codebase:**
- Duplicated scripts across OS directories → consolidate to `unix/`
- Monolithic config files → modular includes (already done for zsh, niri)
- No CI validation → add `chezmoi apply --dry-run` in containers
- Heavy shell startup → lazy-load with zinit `wait` or `atinit`

**Recommended improvements:**
1. README as living documentation (auto-generate keymap tables from config files)
2. Feature flags for optional tools (AI tools opt-in)
3. ShellCheck linting in CI
4. Template rendering tests via `chezmoi execute-template`

## Recommendations for This Project

### Phase 1: README (Priority)
- Use the 9-section structure above
- Extract keymaps from actual config files (tmux.conf.tmpl, nvim config)
- Include OS-specific quick-start commands
- Add fork/customization guide with checklist

### Phase 2: Tech Debt Cleanup
- Fix duplications (bashrc, clone-my-repos)
- Simplify aider config
- Fix typo in starship eval script

### Phase 3: Feature Flags
- Make AI tools opt-in via `.chezmoi.yaml.tmpl` feature detection
- Group tools by category (coding assistants, spec tools, etc.)

### Phase 4: Shell Optimization
- Lazy-load heavy evals (mise, direnv, starship, zoxide)
- Measure startup time before/after

### Phase 5: CI Pipeline
- GitHub Actions with `chezmoi apply --dry-run` on Ubuntu + macOS
- ShellCheck for all `.sh.tmpl` files
- Template rendering validation

## Anti-Features (What NOT to Do)

- Don't auto-generate the entire README — it loses personality
- Don't create separate docs/ folder yet — one README is sufficient for this scale
- Don't add badges/shields just for decoration — only meaningful ones
- Don't document internal chezmoi mechanics — focus on user-facing info
