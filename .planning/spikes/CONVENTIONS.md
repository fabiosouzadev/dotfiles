# Spike Conventions

Patterns and stack choices established across spike sessions for Hermes Agent integration.

## Stack

- **Documentation:** Markdown with YAML frontmatter
- **Validation:** Shell scripts (bash/zsh)
- **Templates:** Go templates (chezmoi)
- **Data:** YAML (.chezmoidata/)

## Structure

Standard spike directory layout:
```
NNN-spike-name/
├── README.md          # Main documentation with YAML frontmatter
├── test-*.sh          # Validation scripts
└── *.md               # Supplementary notes
```

YAML frontmatter required:
```yaml
---
spike: NNN
name: spike-name
type: standard|comparison
validates: "Given X, when Y, then Z"
verdict: PENDING|VALIDATED|INVALIDATED|PARTIAL
related: [NNN, NNN]
tags: [tag1, tag2]
---
```

## Patterns

### Feature Flag Integration

Follow existing pattern in `.chezmoi.yaml.tmpl`:
```yaml
"toolname" (dict "install" false)
```

Simple boolean flags for opt-in tools.

### Installation Methods

Priority order:
1. Official installer (if trustworthy and idempotent)
2. Package manager (brew, apt, etc.)
3. Manual build

### Validation Approach

1. Pre-flight checks (baseline)
2. Execute installation
3. Post-flight verification
4. Coexistence tests
5. Investigation trail documentation

## Tools & Libraries

- **curl:** For downloading install scripts
- **chezmoi:** Template execution and validation
- **grep/awk:** Text processing for verification
- **ls/find:** Filesystem inspection

## Naming Conventions

- Spike directories: `NNN-descriptive-name/`
- Test scripts: `test-*.sh` or `validate-*.sh`
- README: Always `README.md` with full frontmatter
