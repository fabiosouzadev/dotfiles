---
last_mapped_commit: d1d1c1c967319d6aa2852d6caaee2123acced521
last_mapped_at: 2026-11-23
---
# Coding Conventions

**Analysis Date:** 2026-11-23

## Naming Patterns

**Files:**
- JavaScript hooks: lowercase with hyphens in hooks directory, e.g., `gsd-check-update.js`, `gsd-validate-commit.sh`
- Library files: lowercase with hyphens in `hooks/lib/`, e.g., `config-read.js`, `git-cmd.js`
- Shell scripts: snake_case with shebang for executables, e.g., `gsd-graphify-rebuild.sh`
- Generated files: marked with `// GENERATED FILE — DO NOT EDIT BY HAND.` comment at top
- Generated files indicate source of truth: `Source of truth: [path]`

**Functions:**
- camelCase for JavaScript functions: `exitCodeFor()`, `readConfigFileBounded()`, `renderDispatchIdentityMarker()`
- arrow functions and regular function declarations used throughout
- Helper functions prefixed with underscore where private scoping is needed
- Exported functions clearly marked: `module.exports = { functionName, ... }`

**Variables:**
- camelCase for local variables and parameters: `cacheDir`, `globalConfigDir`, `cacheFile`
- UPPERCASE_WITH_UNDERSCORES for constants: `CONFIG_MAX_BYTES`, `HOOK_ON_CRASH`, `EXIT_CODES`
- UPPERCASE_WITH_UNDERSCORES for exported environment variables: `EXIT_HOOK_DENY`, `EXIT_USAGE`
- Module-level `const` for frozen objects and Maps

**Types:**
- JSDoc annotations for function parameters and return types
- Type annotations in comments: `@param {string} name`, `@returns {number}`
- Frozen objects created with `Object.freeze()` for immutability: constants like `HOOK_ON_CRASH`
- Maps used for lookup tables: `NAME_TO_CODE = new Map(...)`

## Code Style

**Formatting:**
- 2-space indentation throughout JavaScript
- Single quotes for strings in JS where shell escaping not involved
- Double quotes in shell scripts for variable expansion
- Files end with newline character
- No trailing whitespace

**Linting:**
- ESLint suppressions with `// eslint-disable-next-line` when needed
- Specific rule suppressions: `@typescript-eslint/no-require-imports`, `@typescript-eslint/unbound-method`
- Explicit `'use strict';` at top of module scope in CommonJS files

**Comments Style:**
- `'use strict';` as first line in CommonJS modules
- Module-level comments explaining purpose and constraints above function definitions
- Inline comments explain non-obvious logic or reference tickets/ADRs
- Comments marked with issue/ADR references: `#3582`, `ADR-3889 §4`, `epic #4630`
- LOAD-BEARING and WHY comments highlight critical design decisions

## Import Organization

**Order:**
1. Built-in Node.js modules: `const fs = require('fs');`, `const path = require('path');`
2. Standard library: `const os = require('os');`
3. Third-party packages: none typically used in hooks
4. Relative imports: other modules in lib directory or parent

**Path Aliases:**
- Relative path imports: `require(path.join(__dirname, 'lib', 'config-read.js'))`
- Relative path imports for parent directory: `require(path.join(__dirname, '..', '..', 'gsd-core', '...'))`
- Computed require paths to handle module discovery: `require.main === module`

**Module Declaration:**
```javascript
'use strict';

const fs = require('fs');
const path = require('path');

// ... rest of code

module.exports = { exportedName1, exportedName2 };
```

## Error Handling

**Patterns:**
- Try/catch blocks with explicit error handling for file operations
- Errors transformed into structured objects with `.code` property: `Object.assign(new Error(msg), { code })`
- Null returns for optional failures: `if (err && err.code === 'ENOENT' && !options?.required) return null;`
- Throws for critical failures with detailed error message
- Module-level trap handlers for cleanup: `trap 'rm -f "${FILE:-}"' EXIT`
- Exit codes standardized via `exit-code-registry.js`: `exit "$EXIT_UNAVAILABLE"`

**Error Codes:**
- File system errors checked: `ENOENT`, `EISDIR`, `ENXIO`, `EFBIG`
- Validation errors with descriptive messages: throw on invalid input types
- Exit codes from registry: `HOOK_DENY` (2), `USAGE` (64), `NO_INPUT` (66), `UNAVAILABLE` (69), `INTERNAL` (70), `DEGRADED` (80)

**Fail-Safe Patterns:**
- Background operations wrapped in try/catch that never crash main process
- Hooks exit 0 on advisory failures, only exit 2 for security denials
- Degraded mode: when a module is optional (build artifacts), code degrades gracefully
- Pre-initialization of exit status variables: `CONFIG_STATUS=0` to prevent inherited environment values

## Logging

**Framework:** console methods in Node.js, stderr for diagnostics

**Patterns:**
- Structured JSON logging for hook outcomes: `process.stdout.write(JSON.stringify(...))`
- Diagnostic messages to stderr: `console.error()` or `>&2` in shell
- Node.js Date.now() for timestamps: `new Date().toISOString()`
- JSON output for hook protocol compliance

## Comments

**When to Comment:**
- Explain WHY non-obvious code exists, especially security/performance considerations
- Reference issue numbers and ADR sections: `#3582`, `ADR-3889 §3`
- Add comments when code handles platform-specific quirks (Windows vs POSIX)
- Document constraints and load-bearing design decisions

**JSDoc/TSDoc:**
```javascript
/**
 * Resolve the registered exit code for a symbolic name. Pure, total: throws
 * for anything not an exact, registered, exact-case key.
 *
 * @param {string} name
 * @returns {number}
 */
function exitCodeFor(name) {
  // ...
}
```

**Generated Code:**
- Generated files marked with header comment
- Source of truth documented: `Source of truth: [path]`
- Regeneration instructions provided: `Regenerate with: [command]`
- Byte-comparison tests pin generated sync: `npm run lint:generated-sync`

## Function Design

**Size:**
- Functions generally 20-80 lines
- Single responsibility: one function = one concern
- Private helpers extracted to separate functions

**Parameters:**
- Positional parameters for required arguments
- Options objects for optional configuration
- Required vs optional checked explicitly: `const file = "${1:?FILE_PATH required}"`
- Type checking in function body: `if (typeof name !== 'string')`

**Return Values:**
- Explicit return values, no implicit undefined
- Null for optional-absence: `return null` when file not found and not required
- Frozen objects returned for immutability: `Object.freeze([...])`
- Maps and Sets for efficient lookups

## Module Design

**Exports:**
```javascript
module.exports = { functionName1, functionName2, CONSTANT_NAME };
```

**Barrel Files:**
- Not used; each module exports its own public API
- Relative require paths maintain explicit dependency tracking

**Module Constraints:**
- hooks/lib/ modules have COLD-LOAD constraint: cannot require gsd-core/bin/lib artifacts
- Some modules deliberately NOT require certain dependencies to work on unbuilt clones
- Load-bearing documentation explains why certain patterns are used

## Shell Script Conventions

**Shebang:**
- `#!/usr/bin/env bash` for Bash scripts (not `/bin/bash`)
- `#!/bin/sh` for POSIX shell scripts

**Style:**
- `set -euo pipefail` for strict error handling
- Variable assignment with `=` without spaces
- Variable substitution with `${VAR}` (safe with `set -u`)
- Quoted variables: `"${FILE}"` to handle spaces/special characters
- Conditional test with `[` and `]` or `[[` for Bash

**Error Handling in Shell:**
- `mktemp` for temp file creation
- EXIT trap with cleanup function for guaranteed cleanup
- Idempotent cleanup: `rm -f "${FILE:-}" 2>/dev/null || true`
- Exit codes checked: `${VAR:-0}` defaults when unset

---

*Convention analysis: 2026-11-23*
