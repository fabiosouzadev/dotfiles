---
last_mapped_commit: c2840b6cdfa7b1cdccbfa7c030396b2c931328a2
last_mapped_at: 2026-11-23
---
# Testing Patterns

**Analysis Date:** 2026-11-23

## Test Framework

**Runner:**
- Not detected in this codebase

**Assertion Library:**
- Not detected in this codebase

**Run Commands:**
- No test runner scripts found in package.json or project root

## Test File Organization

**Location:**
- Not applicable — no test files detected in codebase

**Naming:**
- Not applicable — no test files detected

**Structure:**
- Not applicable — no test files detected

## Testing Approach

**Current State:**
This dotfiles repository (`~/.local/share/chezmoi`) is a configuration management system built on:
- Shell scripts (.sh files)
- JavaScript hook modules (.js files)
- Configuration templates (.tmpl files)
- Chezmoi-managed dotfiles

**Testing Strategy:**
- Tests are run in GSD core repository (not in this dotfiles repository)
- Hooks and utilities defined here (`/.claude/hooks/`) are tested in upstream GSD codebase
- Generated files (`exit-code-registry.js`, `cli-exit.js`) are byte-compared for parity: `npm run lint:generated-sync`
- Module mirrors verified to stay in sync via test assertions

## Code Validation Patterns

**Manual Testing Approach:**
- Hooks validated by running in actual Claude/Windsurf session
- Shell scripts tested by execution in target shells (bash, sh, zsh)
- JavaScript modules required and called to verify they load on unbuilt clones
- Configuration validation through YAML/JSON parsing attempts

**Verification by Testing Infrastructure:**
- **Generated file sync:** Byte-compared by `npm run lint:generated-sync` (#3911, ADR-3889 Phase 7)
  - Verifies `gsd-core/bin/lib/exit-code-registry.cjs` = `hooks/lib/exit-code-registry.js` = `scripts/lib/exit-code-registry.cjs`
  - Verifies `gsd-core/bin/lib/cli-exit.cjs` = `hooks/lib/cli-exit.js` = `scripts/lib/cli-exit.js`

- **Mirror tests:** Specialized tests pin that duplicate code stays in sync
  - `tests/dispatch-identity.test.cjs`: Verifies `hooks/lib/dispatch-identity.js` mirrors `src/phase-id.cts`
  - Cold-tree load test: Monkeypatches `Module._load` to assert hooks load without requiring gsd-core/bin/lib

- **Parity testing:** For cold-load modules that must work on unbuilt clones
  - `hooks/lib/config-read.js` → mirrors `gsd-core/bin/lib/config-file-read.cjs`
  - Test ensures both have identical capability for reading bounded config files

## Module Load Testing

**Cold Load Constraint:**
Hooks must load on a raw, unbuilt clone where build artifacts (`gsd-core/bin/lib/*.cjs`) don't exist.

**Validation:**
- Modules marked with `// COLD-LOAD CONSTRAINT` explicitly state they cannot require certain paths
- `hooks/lib/dispatch-identity.js` requires NOTHING (no fs, no path, no gsd-core)
- Load test verifies modules load by monkeypatching Module._load to block forbidden paths

## Error Path Testing

**Patterns Observed:**
- Functions tested for error conditions: null returns, throws, structured errors
- Exit code tests verify correct code emitted for each outcome
- File system error codes tested: ENOENT, EISDIR, ENXIO, EFBIG

**Error Handling Test Pattern:**
```javascript
// Example: testing optional file absence
if (err && err.code === 'ENOENT' && !(options && options.required)) return null;
// Throw for non-optional
throw err;
```

**Structured Error Objects:**
- Error.code property checked: `if (!st.isFile()) throw coded(..., 'EISDIR');`
- Errors created with explicit code: `function coded(message, code) { return Object.assign(new Error(message), { code }); }`

## Git Integration Testing

**Patterns:**
- Git command classification tested in `git-cmd.js`
- Test cases cover four git invocation forms:
  1. bare: `git commit -m "..."`
  2. -C path: `git -C /some/path commit -m "..."`
  3. env-prefix: `GIT_AUTHOR_NAME=x git commit "..."`
  4. full-path: `/usr/bin/git commit -m "..."`

- Token walker skips git options correctly (ARGUMENT_TAKING_FLAGS and BOOLEAN_FLAGS)
- Glued flag form tested: `-cfoo=value` correctly parsed

## Hook Protocol Testing

**Contract Verification:**
- Exit codes match registered names: code 2 = HOOK_DENY, code 0 = PASS
- JSON payload structure verified for structured output
- Fail-safe behavior: hooks exit 0 on advisory errors (don't block tool)
- Fail-closed behavior: security hooks exit 2 to block dangerous operations

**Test Patterns:**
- Hook exit code contracts defined in `exit-codes.json` (source of truth)
- Generated registries byte-compared to verify no divergence
- Exit code lookup tested: `exitCodeFor()` returns correct number for name, throws for unregistered

## Coverage Gaps

**Untested Areas:**
- `~/.local/share/chezmoi/home/` dotfiles not tested in this repository
- Chezmoi template execution not validated in codebase
- Shell initialization (.zshrc, .bashrc equivalents) not tested
- Configuration file modifications not verified programmatically
- Actual hook execution in Claude/Windsurf session not automated in this repo

**Risk:**
- Hooks could have silent failures that only manifest when tool is invoked
- Chezmoi template rendering errors only discovered during apply
- Configuration changes could break shell initialization

## Common Patterns

**Defensive Programming:**
```javascript
// Defensive type checking
if (typeof name !== 'string' || name.length === 0) {
  throw new Error(...);
}

// Optional chaining with defaults
const envDir = process.env.CLAUDE_CONFIG_DIR;
if (envDir && fs.existsSync(path.join(envDir, 'gsd-core', 'VERSION'))) {
  return envDir;
}
```

**Shell Script Patterns:**
```bash
# Pre-initialize status variables to prevent inherited env pollution
CONFIG_STATUS=0
CMD_STATUS=0
CLASSIFY_STATUS=0

# Idempotent cleanup
cleanup_temp_files() {
  rm -f "${ENABLED_ERR:-}" "${CMD_ERR:-}" "${CLASSIFY_ERR:-}" 2>/dev/null || true
}
trap cleanup_temp_files EXIT
```

**Async/Background Patterns:**
- Not applicable for hooks (synchronous execution required)
- Background workers spawn for non-blocking operations (gsd-graphify-rebuild.sh)
- Worker tracks status via lockfile and status file

## Documentation Testing

**Patterns:**
- Generated files include instruction comments for regeneration
- Source of truth documented in generated file header
- Comments explain WHY generated file exists (not just WHAT it is)
- Test assertions verify that documentation in comments stays accurate

---

*Testing analysis: 2026-11-23*
