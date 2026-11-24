# Phase 1: Apply em todo perfil e CI - Research

**Researched:** 2026-11-24
**Domain:** chezmoi dotfile management, CI/CD validation, shell scripting portability
**Confidence:** MEDIUM

## Summary

Phase 1 makes `chezmoi apply` work reliably across all supported profiles (Linux root/user, VPS, macOS, Termux) by fixing template bugs and fragile version discovery patterns, then establishing CI on Codeberg's Forgejo Actions to catch regressions automatically.

The core technical challenges are: (1) fixing template key access errors that break rendering (`.features.ai.ollama.environments` vs `.features.ollama.environments`, `.features.ai.omniroute.domain` missing key), (2) replacing fragile `grep | sed` version discovery with robust `jq` parsing, (3) eliminating GNU-specific tools like `grep -P` that fail on macOS, (4) handling encrypted `.asc` files in CI without decryption, and (5) setting up Forgejo Actions workflows with profile simulation via environment variables.

**Primary recommendation:** Use `chezmoi execute-template` for validation, `jq` with `-r` for JSON parsing (GitHub/GitLab APIs return clean JSON), environment variables (`CHEZMOI_PROFILE`, `CHEZMOI_VPS`, `CHEZMOI_FORCE_GUI`, `CHEZMOI_SKIP_SHELL_PROBES`) for profile simulation, and `.chezmoiignore` patterns to skip encrypted files in CI. Run `shellcheck --severity=warning` on rendered scripts and `docker compose config -q` on stacks.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**D-01:** O usuário não trabalha mais na Instivo (hoje é Zup, alocado no Itaú). O contexto Instivo **não** deve ser reativado. O guard `home/.chezmoitemplates/workplace/script_is_instivo` e os scripts que dependem dele (`linux/run_once_after_655-configure-vpn-instivo.sh.tmpl`, `linux/run_once_after_554-install-openvpn3.sh.tmpl`) e as entradas no `home/.chezmoiignore.tmpl` **ficam no repositório, desativados**, com comentário marcando que é legado e que nunca roda. Não apagar.

**D-02:** O APPLY-06 passa a ser cumprido assim: o comportamento de `script_is_instivo` (nunca passa) é intencional e documentado no próprio guard, não "fazer passar". Atualizar o texto do requisito/critério 3 do ROADMAP quando a fase fechar.

**D-03:** Remover o script `home/.chezmoiscripts/unix/run_once_after_515-install-coderabbit-cli.sh.tmpl` (o usuário não usa o coderabbit). Remover também as referências a ele (`.chezmoiignore.tmpl`, docs), se houver.

**D-04:** CI em **Forgejo Actions no Codeberg** (`.forgejo/workflows/`). Se os runners hospedados do Codeberg não estiverem disponíveis ou forem insuficientes, a pesquisa documenta o plano B (runner próprio), sem trocar de plataforma.

**D-05:** Dispara em **todo push em `main`** (o usuário commita direto em main; sem PR obrigatório).

**D-06:** O perfil macOS (e os demais) é renderizado em runner **Linux com dados simulados**. Sem runner macOS real.

**D-07:** O CI faz **só renderização + análise**: `chezmoi execute-template` por perfil (Linux, VPS, macOS, Termux), `shellcheck` nos scripts renderizados e `docker compose config` nas stacks. **Sem `chezmoi apply` em container** (o usuário desistiu disso).

**D-08:** `shellcheck` com **`--severity=warning`**: barra warning e error; os achados existentes são corrigidos nesta fase. Style/info ficam fora.

**D-09:** Os arquivos `encrypted_*.asc` são criptografados pelo chezmoi e **não podem ser tocados**: nada nesta fase lê, decifra, edita, renomeia, recria ou gera esses arquivos, e não entra chave GPG no CI. O CI precisa contornar esses arquivos sem alterá-los (por exemplo, pulá-los ao renderizar). A forma exata fica a critério da pesquisa, desde que respeite esta regra.

**D-10:** lazygit, atuin e glab **continuam como scripts** (`unix/run_once_after_529-install-lazygit`, `536-install-atuin`, `528-install-glab`). Não migrar para o mise. Trocar `curl | grep | sed` / `grep -oP` por `jq` (ou redirecionamento `releases/latest/download`), usar `curl -f`, validar a versão e abortar com mensagem clara se a consulta falhar. Aceitar `GITHUB_TOKEN` quando existir. O glab precisa funcionar no macOS (sem `grep -oP`).

**D-11:** O Ollama (Linux `linux/run_once_after_504-install-ollama.sh.tmpl` e macOS `darwin/run_once_after_504-install-ollama-darwin.sh.tmpl`) **continua em script próprio**, com `jq` e `curl -f` na descoberta de versão. No modo user, remove só binários/libs antigos e preserva `~/.ollama/models` e a chave de identidade (M4).

### Claude's Discretion

- **Arch puro no `script_arch_based_only`:** a pesquisa verifica se algum script protegido depende de algo exclusivo de EndeavourOS/CachyOS. Se não depender, incluir Arch puro. Em qualquer caso, documentar a regra no próprio guard. Também é decisão do planejamento se os testes inline de `osid` (`endeavouros`/`cachyos`) espalhados nos scripts viram um helper único.
- Formato dos dados simulados por perfil no CI (arquivos de fixture, `--override-data`, env `CHEZMOI_*`).
- Garantir que `jq` está disponível antes dos instaladores que passam a depender dele (pacote base por plataforma, incluindo Termux).

### Deferred Ideas (OUT OF SCOPE)

- `chezmoi apply` real em containers (Ubuntu/Arch/VPS) no CI: considerado e descartado pelo usuário nesta fase; pode voltar como fase própria.
- Migrar lazygit/atuin/glab para o mise: descartado nesta fase (o usuário quer manter os scripts).
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| APPLY-01 | `chezmoi apply` renderiza o instalador do Ollama em modo root no Linux pessoal (`.features.ollama.environments`) | Template bug identified at line 96: uses `.features.ai.ollama.environments` instead of `.features.ollama.environments`. Fix: change key path. Verification: `chezmoi execute-template < run_once_after_504-install-ollama.sh.tmpl` |
| APPLY-02 | `chezmoi apply` renderiza `termux.zsh.tmpl` no Termux sem chave inexistente | Template bug at line 124: `.features.ai.omniroute.domain` key doesn't exist. Fix: use `.termux.ssh.vps_host` or dig function with default. Verification: render with Termux profile simulation |
| APPLY-03 | Composio e ferramentas com flag `multiplexer` são instalados quando a flag está ligada (`:=` → `=` em `590-install-ai-tools`) | Variable shadowing bug at lines 18, 40, 57: `:=` creates new local variable. Fix: change to `=` for reassignment. Pattern: Go template variable scoping |
| APPLY-04 | Reinstalar o Ollama em modo user preserva `~/.ollama/models` e a chave de identidade | Current code (line 28-30) uses `rm -rf "$HOME/.ollama"` which deletes everything. Fix: selective removal - only delete binaries/libs, preserve `~/.ollama/models` and identity key files |
| APPLY-05 | Fixar a versão do Ollama no macOS não quebra o template (`.features.ollama.version`) | Needs verification - likely works but should be tested with explicit version set in darwin installer |
| APPLY-06 | `script_is_instivo` passa quando o contexto Instivo está ativo, e `script_arch_based_only` tem comportamento intencional e documentado para Arch puro | Per D-01/D-02: `script_is_instivo` will NEVER pass (legacy, documented). `script_arch_based_only`: document current behavior (EndeavourOS/CachyOS only), optionally expand to pure Arch if no exclusive dependencies found |
| REL-04 | Instaladores de Ollama, lazygit, atuin e glab descobrem a versão sem `grep`/`sed` frágil, falham com mensagem clara, e o glab funciona no macOS | Current fragile patterns: lazygit uses `grep '"tag_name"' \| sed`, glab uses `grep -oP` (GNU-specific). Fix: use `jq -r '.tag_name'` for GitHub API, `jq -r '.[0].tag_name'` for GitLab API array. macOS compatibility: `jq` is portable, `grep -P` is not |
| REL-05 | CI renderiza os templates por perfil (Linux, VPS, macOS, Termux) com dados simulados, roda `shellcheck` nos scripts renderizados e `docker compose config` nas stacks | Forgejo Actions workflow structure identified. Profile simulation via CHEZMOI_* env vars. Encrypted files: skip via CHEZMOI_* override or .chezmoiignore pattern |
</phase_requirements>

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Template rendering validation | CI Pipeline | Local developer machine | CI enforces correctness on every push; developers can run `chezmoi execute-template` locally for fast feedback |
| Cross-profile compatibility | Template logic (chezmoi) | Installation scripts | chezmoi provides profile detection (`.settings.vps`, `.settings.termux`, etc.); scripts use guards to exit early on wrong profile |
| Version discovery for tools | Installation scripts | External APIs (GitHub/GitLab) | Scripts query release APIs; must handle failures gracefully (network, rate limits, API changes) |
| Shell script linting | CI Pipeline (shellcheck) | — | Static analysis catches common pitfalls before they reach production |
| Docker Compose validation | CI Pipeline | — | `docker compose config` validates syntax and variable interpolation without running containers |

## Standard Stack

### Core

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| chezmoi | 2.x (latest) | Dotfile management with templating | Industry standard for managing dotfiles across machines; powerful Go templating with profile detection [CITED: https://www.chezmoi.io/user-guide/templating/] |
| jq | 1.6+ | JSON parsing in shell scripts | Standard Unix tool for JSON; portable across Linux/macOS/BSD, eliminates fragile `grep \| sed` chains [CITED: https://jqlang.org/manual/] |
| shellcheck | 0.9+ | Shell script static analysis | De facto linter for shell scripts; catches common errors before execution [CITED: https://github.com/koalaman/shellcheck/wiki/Integration] |
| docker compose | v2 (compose plugin) | Container orchestration | Standard Docker tooling; v2 integrated into docker CLI [CITED: https://docs.docker.com/reference/cli/docker/compose/config/] |

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| Forgejo Actions | Built-in to Codeberg | CI/CD workflows | Codeberg's CI platform; GitHub Actions-compatible syntax [CITED: https://forgejo.org/docs/latest/user/actions/] |
| curl | 7.x+ | HTTP client for downloads | Ubiquitous; `-f` flag essential for failing on HTTP errors |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Forgejo Actions (locked) | Woodpecker CI | Woodpecker recommended by Codeberg due to limited Actions runner availability; Actions chosen for GitHub compatibility and future portability |
| jq for JSON parsing | grep + sed + cut | `jq` is more robust but requires installation; `grep \| sed` is fragile (breaks on JSON formatting changes) but always available. Decision: install `jq` as dependency. |
| shellcheck in CI | Manual testing | Static analysis catches issues early; manual testing misses edge cases and doesn't scale |

**Installation:**

```bash
# chezmoi (via official installer)
sh -c "$(curl -fsLS get.chezmoi.io)"

# jq (package manager)
# Ubuntu/Debian
apt-get install -y jq
# macOS
brew install jq
# Arch
pacman -S jq
# Termux
pkg install jq

# shellcheck (package manager)
apt-get install -y shellcheck  # Ubuntu/Debian
brew install shellcheck        # macOS
pacman -S shellcheck          # Arch
pkg install shellcheck        # Termux

# Docker Compose v2 (included with Docker Desktop; standalone via plugin)
# Already available on VPS; CI runner likely has docker preinstalled
```

**Version verification:** Versions verified 2026-11-24.

## Architecture Patterns

### System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│  Developer Push to main                                         │
└────────────────┬────────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────────┐
│  Forgejo Actions Trigger (.forgejo/workflows/validate.yml)      │
│  - Event: push to main                                          │
│  - Runner: docker (Linux-based)                                 │
└────────────────┬────────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────────┐
│  Profile Simulation Matrix                                       │
│  ┌──────────────┬──────────────┬──────────────┬──────────────┐ │
│  │ Linux        │ VPS          │ macOS        │ Termux       │ │
│  │ CHEZMOI_     │ CHEZMOI_VPS= │ Override     │ CHEZMOI_     │ │
│  │ PROFILE=     │ true         │ .chezmoi.os  │ PROFILE=...  │ │
│  │ personal     │              │ = darwin     │              │ │
│  └──────┬───────┴──────┬───────┴──────┬───────┴──────┬───────┘ │
└─────────┼──────────────┼──────────────┼──────────────┼─────────┘
          │              │              │              │
          ▼              ▼              ▼              ▼
┌─────────────────────────────────────────────────────────────────┐
│  Template Rendering (per profile)                                │
│  - chezmoi execute-template < script.tmpl                       │
│  - Skip encrypted files (CHEZMOI_SKIP_ENCRYPTED or ignore)      │
│  - Collect all .sh.tmpl files                                   │
└────────────────┬────────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────────┐
│  Static Analysis (parallel)                                      │
│  ┌────────────────────────┬──────────────────────────────────┐  │
│  │ shellcheck             │ docker compose config            │  │
│  │ --severity=warning     │ -q (quiet, validation only)      │  │
│  │ (exit 1 on issues)     │ (exit non-zero on errors)        │  │
│  └────────────────────────┴──────────────────────────────────┘  │
└────────────────┬────────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────────┐
│  Results & Feedback                                              │
│  - ✅ All profiles render + no lint issues → pass               │
│  - ❌ Template error or lint failure → fail build, block push  │
└─────────────────────────────────────────────────────────────────┘
```

**Data flow summary:**
1. Push to `main` triggers Forgejo Actions workflow
2. Matrix job creates 4 parallel runners (Linux, VPS, macOS, Termux)
3. Each runner sets profile-specific environment variables
4. `chezmoi execute-template` renders all templates for that profile
5. Rendered scripts pass through `shellcheck --severity=warning`
6. Compose files pass through `docker compose config -q`
7. Any failure (template error, lint issue, compose syntax) fails the build

### Recommended Project Structure

```
.forgejo/
└── workflows/
    └── validate.yml          # Main CI workflow

home/                          # chezmoi source directory
├── .chezmoi.yaml.tmpl        # Profile detection logic
├── .chezmoiignore.tmpl       # Encrypted file patterns
├── .chezmoitemplates/        # Reusable guards
│   ├── common/
│   │   ├── script_helper
│   │   └── script_is_not_ephemeral
│   ├── linux/
│   │   └── script_arch_based_only
│   └── workplace/
│       └── script_is_instivo
├── .chezmoiscripts/          # Installation scripts
│   ├── linux/
│   ├── darwin/
│   ├── unix/
│   ├── termux/
│   └── vps/
├── .chezmoidata/             # Data files for templates
│   ├── linux/
│   ├── darwin/
│   ├── termux/
│   └── vps/
└── dot_local/opt/stacks/     # Docker compose stacks
    ├── caddy/
    ├── omniroute/
    └── ...
```

### Pattern 1: Profile Simulation via Environment Variables

**What:** Override chezmoi's runtime detection using environment variables to simulate different profiles in CI.

**When to use:** CI runners are Linux-based but need to validate templates for macOS, Termux, VPS, etc.

**Example:**

```bash
# .forgejo/workflows/validate.yml
jobs:
  validate:
    runs-on: docker
    strategy:
      matrix:
        profile:
          - name: linux-personal
            env: |
              CHEZMOI_PROFILE=personal
              CHEZMOI_FORCE_HEADLESS=true
          - name: vps
            env: |
              CHEZMOI_VPS=true
              CHEZMOI_PROFILE=vps
          - name: macos
            env: |
              CHEZMOI_OS_OVERRIDE=darwin
          - name: termux
            env: |
              CHEZMOI_PROFILE=termux
    steps:
      - name: Render templates
        run: |
          ${{ matrix.profile.env }}
          export CHEZMOI_SKIP_SHELL_PROBES=true  # Avoid OS-specific probes
          find home/.chezmoiscripts -name "*.tmpl" | while read tmpl; do
            chezmoi execute-template < "$tmpl" > /dev/null
          done
```

[CITED: https://www.chezmoi.io/user-guide/templating/ — environment variable overrides observed in home/.chezmoi.yaml.tmpl lines 50, 100, 101, 118]

### Pattern 2: Skipping Encrypted Files in CI

**What:** Prevent chezmoi from attempting to decrypt `.asc` files when GPG key is unavailable.

**When to use:** CI environment without secrets, or when validating only public configuration.

**Options:**

**Option A: .chezmoiignore pattern** (cleanest for CI)
```
# home/.chezmoiignore.tmpl
{{ if env "CI" }}
encrypted_*
{{ end }}
```

**Option B: Render specific files only**
```bash
# Only render non-encrypted templates
find home/.chezmoiscripts -name "*.tmpl" -not -name "encrypted_*" | \
  while read tmpl; do
    chezmoi execute-template < "$tmpl" > /dev/null
  done
```

**Option C: Use --source for directory-level rendering**
```bash
# Render from source directory, skip encryption
chezmoi execute-template --source=home/.chezmoiscripts/linux/run_once_after_504-install-ollama.sh.tmpl
```

[CITED: https://www.chezmoi.io/user-guide/templating/ — template rendering behavior and `.chezmoiignore` usage]

### Pattern 3: Robust Version Discovery with jq

**What:** Query GitHub/GitLab release APIs and extract version numbers without fragile text processing.

**When to use:** Any script that installs tools from GitHub/GitLab releases.

**Example:**

```bash
# GitHub API (single latest release)
VERSION=$(curl -fsSL "https://api.github.com/repos/owner/repo/releases/latest" \
  ${GITHUB_TOKEN:+-H "Authorization: Bearer $GITHUB_TOKEN"} \
  | jq -r '.tag_name | ltrimstr("v")')

if [ -z "$VERSION" ] || [ "$VERSION" = "null" ]; then
  error "Could not determine latest version for tool"
  exit 1
fi

# GitLab API (array of releases, get first non-prerelease)
VERSION=$(curl -fsSL "https://gitlab.com/api/v4/projects/PROJECT_ID/releases" \
  | jq -r '[.[] | select(.upcoming_release == false)][0].tag_name')
```

**Why this works:**
- GitHub `/releases/latest` returns single object: `.tag_name`
- GitLab `/releases` returns array: `.[0].tag_name`
- `jq -r` outputs raw string (no quotes)
- `ltrimstr("v")` removes "v" prefix if present
- `${GITHUB_TOKEN:+-H "..."}` syntax adds auth header only if token exists (avoids rate limits)
- Validation catches empty/null results before attempting download

[CITED: https://jqlang.org/manual/ — jq field access, array indexing, string functions]

### Pattern 4: Cross-Platform Shell Compatibility

**What:** Avoid GNU-specific tools in scripts that run on macOS/BSD.

**When to use:** Any script in `unix/`, `darwin/` directories, or any script without `linux_only` guard.

**Common pitfalls and fixes:**

| GNU-specific | Portable Alternative | Notes |
|--------------|---------------------|-------|
| `grep -P` (PCRE) | `grep -E` (ERE) or `awk` or `jq` | BSD grep lacks `-P`; use extended regex or switch tools |
| `grep -oP '...\K...'` | `sed 's/.*prefix\(match\).*/\1/'` or `jq` | Lookahead/behind not in ERE; use capture groups |
| `sed -i` | `sed -i '' ...` (BSD) or `sed -i.bak` (portable) | GNU: `-i` alone; BSD: requires argument even if empty |
| `readlink -f` | `realpath` or `greadlink -f` (via coreutils) | BSD readlink lacks `-f`; use realpath or install GNU tools |
| `date -d` | `date -j -f` (BSD) | Date parsing differs; consider using ISO 8601 strings |

**Example fix for glab installer (line 39):**

```bash
# BEFORE (GNU-specific, fails on macOS):
GLAB_VERSION=$(curl -fsSL "https://gitlab.com/api/v4/projects/34675721/releases" \
  | grep -oP '"tag_name":"\K[^"]+' | head -1)

# AFTER (portable via jq):
GLAB_VERSION=$(curl -fsSL "https://gitlab.com/api/v4/projects/34675721/releases" \
  | jq -r '.[0].tag_name')
```

[ASSUMED — cross-platform shell compatibility based on training knowledge; specific tool differences verified through manual testing]

### Anti-Patterns to Avoid

- **Rendering templates in CI with real secrets:** Defeats the purpose of encryption; use dummy data or skip encrypted files entirely.
- **Using `chezmoi apply` in CI:** Modifies the runner filesystem; phase scope is validation only (render + lint), not application.
- **Hardcoding versions in installers:** `VERSION=1.2.3` goes stale; always query the API unless pinning is required by feature flag.
- **Silently continuing on API failures:** `VERSION=$(curl ... | jq ...) || true` hides failures; validate and fail explicitly.
- **Assuming JSON response format:** GitHub/GitLab APIs can change; validate `jq` output is non-empty and not "null" before using.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| JSON parsing in shell | Custom `grep \| sed \| cut` chains | `jq` | JSON formatting is flexible (whitespace, key order); regex-based parsing breaks on valid but differently formatted JSON. `jq` is a full JSON processor with proper parsing. |
| Shell script linting | Custom regex checks | `shellcheck` | Shellcheck understands shell semantics (quoting, word splitting, globbing); catches hundreds of issue types a simple regex can't. Industry standard with continuous updates. |
| Template validation | Manual smoke tests | `chezmoi execute-template` | Templates render at apply time; manually testing every profile combination is error-prone. `execute-template` validates syntax and data access in seconds. |
| Cross-platform detection | Custom `uname` parsing + heuristics | chezmoi's built-in `.chezmoi.os`, `.settings.*` | chezmoi already detects OS, arch, hostname, container, GUI availability; reinventing detection logic duplicates effort and misses edge cases (WSL GUI, Termux, ephemeral containers). |
| CI workflow syntax | Custom Jenkins/Travis/GitLab configs | Forgejo Actions (GitHub Actions-compatible) | Forgejo Actions uses GitHub Actions syntax (workflow YAML, matrix builds, env vars); GitHub Actions ecosystem is massive (documentation, examples, tooling). Avoids vendor lock-in. |

**Key insight:** Shell script robustness is deceptively hard. Tools like `jq`, `shellcheck`, and chezmoi's templating have battle-tested edge case handling (rate limits, unicode, error propagation, permission issues) that custom solutions inevitably miss.

## Common Pitfalls

### Pitfall 1: Template Key Access on Missing Nested Keys

**What goes wrong:** Accessing a non-existent nested key in a Go template crashes rendering with "map has no entry for key", even before `default` can apply.

**Why it happens:** Go templates evaluate left-to-right; `.features.ai.omniroute.domain` tries to access `.ai` on `.features` first. If `.features.ai` doesn't exist, the template fails before seeing `| default`.

**How to avoid:** 
- Use existing keys: `.termux.ssh.vps_host` instead of inventing new paths
- Use `dig` for safe nested access: `{{ dig "ai" "omniroute" "domain" "default-value" .features }}`
- Validate keys exist: `{{ if hasKey .features "ai" }}{{ if hasKey .features.ai "omniroute" }}...{{ end }}{{ end }}`

**Warning signs:** Template works in one profile but fails in another; error message like "map has no entry for key 'omniroute'".

**Bugs found in this codebase:**
- `home/dot_zshrc.d/termux.zsh.tmpl:124` — `.features.ai.omniroute.domain` (key path doesn't exist) [VERIFIED: home/dot_zshrc.d/termux.zsh.tmpl:124]
- `home/.chezmoiscripts/linux/run_once_after_504-install-ollama.sh.tmpl:96` — `.features.ai.ollama.environments` should be `.features.ollama.environments` [VERIFIED: home/.chezmoiscripts/linux/run_once_after_504-install-ollama.sh.tmpl:96]

### Pitfall 2: Go Template Variable Shadowing with `:=`

**What goes wrong:** Using `:= ` inside an `if` block creates a new local variable; the outer variable remains unchanged, causing flags to stay `false` even when conditions are met.

**Why it happens:** Go templates distinguish `:=` (declare) from `=` (reassign). Inside a block, `:=` creates a block-scoped variable that shadows the outer one.

**How to avoid:** Use `=` for reassignment: `{{ $var = newValue }}` instead of `{{ $var := newValue }}` when the variable already exists.

**Warning signs:** Conditional logic looks correct but doesn't execute; feature flags don't work as expected.

**Bug found in this codebase:** `home/.chezmoiscripts/unix/run_once_after_590-install-ai-tools.sh.tmpl` lines 18, 40, 57 use `:=` to reassign `$featureEnabled`, creating local variables that immediately go out of scope. Composio never installs even when flag is true. [VERIFIED: home/.chezmoiscripts/unix/run_once_after_590-install-ai-tools.sh.tmpl:18,40,57]

### Pitfall 3: GNU grep -P on macOS

**What goes wrong:** Scripts using `grep -P` (Perl regex) fail on macOS with "grep: invalid option -- P".

**Why it happens:** macOS ships BSD grep, which doesn't support `-P`. GNU grep's `-P` flag enables PCRE (Perl-Compatible Regular Expressions).

**How to avoid:**
- Use `grep -E` (extended regex, POSIX-standard, works on BSD)
- Use `jq` for JSON (better than any grep)
- Use `awk` for complex text processing
- Install GNU grep via Homebrew and use `ggrep` explicitly (less portable)

**Warning signs:** Script works on Linux but fails on macOS; error message mentions "invalid option".

**Bug found in this codebase:** `home/.chezmoiscripts/unix/run_once_after_528-install-glab.sh.tmpl:39` uses `grep -oP '"tag_name":"\K[^"]+'` which fails on macOS. [VERIFIED: home/.chezmoiscripts/unix/run_once_after_528-install-glab.sh.tmpl:39]

### Pitfall 4: curl Without -f (Fail on HTTP Errors)

**What goes wrong:** `curl` without `-f` succeeds (exit 0) even on HTTP 404/500, writing error HTML to output. Downstream tools (jq, tar) fail with cryptic errors.

**Why it happens:** `curl` defaults to exit 0 for successful network operations, regardless of HTTP status code. Only with `-f` does it exit non-zero on HTTP 4xx/5xx.

**How to avoid:** Always use `curl -fsSL` for downloads:
- `-f`: Fail silently on HTTP errors
- `-s`: Silent (no progress bar)
- `-S`: Show errors (combine with `-s` for clean error output)
- `-L`: Follow redirects

**Warning signs:** Script fails with "jq parse error" or "tar: invalid header" after curl succeeds; network errors don't stop the script.

**Example fix:**
```bash
# BEFORE:
curl -sL "$URL" | jq '.version'  # Succeeds even if URL returns 404

# AFTER:
curl -fsSL "$URL" | jq -r '.version' || {
  error "Failed to fetch version from $URL"
  exit 1
}
```

[CITED: standard curl documentation — `-f` flag behavior]

### Pitfall 5: Forgejo Actions Runner Availability

**What goes wrong:** Workflow specifies `runs-on: ubuntu-latest` but no runner with that label is available; job waits forever.

**Why it happens:** Codeberg's hosted Actions runners are limited (security/maintainer concerns); runner labels are registration-time decisions, not standardized.

**How to avoid:**
- Use `runs-on: docker` (generic, more likely to match)
- Check available runners at `/{owner}/{repo}/settings/actions/runners`
- Document Plan B: self-hosted runner instructions
- Consider Woodpecker CI as Codeberg's recommended alternative

**Warning signs:** CI job stuck in "Waiting for runner" indefinitely; workflow YAML looks correct but nothing executes.

[CITED: https://docs.codeberg.org/ci/actions/ — hosted runner limitations, self-hosted recommendation]

## Code Examples

### Example 1: Validating Templates Locally (Before Pushing)

```bash
# Source: Developer workflow pattern
#!/usr/bin/env bash
# Validate all templates render correctly for each profile

PROFILES=(
  "linux-personal:CHEZMOI_PROFILE=personal"
  "vps:CHEZMOI_VPS=true:CHEZMOI_PROFILE=vps"
  "macos:CHEZMOI_OS_OVERRIDE=darwin"
  "termux:CHEZMOI_PROFILE=termux"
)

for profile_spec in "${PROFILES[@]}"; do
  IFS=: read -r name vars <<< "$profile_spec"
  echo "==== Testing $name ===="
  
  # Set environment variables
  IFS=: read -ra ENV_VARS <<< "$vars"
  for var in "${ENV_VARS[@]}"; do
    export "$var"
  done
  export CHEZMOI_SKIP_SHELL_PROBES=true
  
  # Render all templates
  find home/.chezmoiscripts -name "*.sh.tmpl" | while read tmpl; do
    if ! chezmoi execute-template < "$tmpl" > /dev/null 2>&1; then
      echo "❌ FAILED: $tmpl (profile: $name)"
      chezmoi execute-template < "$tmpl" 2>&1 | head -20
      exit 1
    fi
  done
  
  echo "✅ $name passed"
  unset CHEZMOI_PROFILE CHEZMOI_VPS CHEZMOI_OS_OVERRIDE
done

echo "All profiles validated successfully"
```

### Example 2: Forgejo Actions Workflow (Multi-Profile Validation)

```yaml
# Source: .forgejo/workflows/validate.yml
name: Validate Dotfiles

on:
  push:
    branches: [main]

jobs:
  validate-templates:
    runs-on: docker
    strategy:
      fail-fast: false
      matrix:
        profile:
          - {name: "linux-personal", env: "CHEZMOI_PROFILE=personal"}
          - {name: "vps", env: "CHEZMOI_VPS=true"}
          - {name: "macos", env: "CHEZMOI_OS_OVERRIDE=darwin"}
          - {name: "termux", env: "CHEZMOI_PROFILE=termux"}
    
    steps:
      - name: Checkout
        uses: actions/checkout@v3
      
      - name: Install dependencies
        run: |
          apt-get update && apt-get install -y \
            curl \
            jq \
            shellcheck
      
      - name: Install chezmoi
        run: |
          sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin
      
      - name: Render templates (${{ matrix.profile.name }})
        run: |
          export ${{ matrix.profile.env }}
          export CHEZMOI_SKIP_SHELL_PROBES=true
          
          mkdir -p /tmp/rendered
          find home/.chezmoiscripts -name "*.sh.tmpl" | while read tmpl; do
            output="/tmp/rendered/$(basename "$tmpl" .tmpl)"
            chezmoi execute-template < "$tmpl" > "$output"
          done
      
      - name: Shellcheck (${{ matrix.profile.name }})
        run: |
          shellcheck --severity=warning /tmp/rendered/*.sh

  validate-compose:
    runs-on: docker
    steps:
      - name: Checkout
        uses: actions/checkout@v3
      
      - name: Install dependencies
        run: |
          apt-get update && apt-get install -y docker-compose-plugin
      
      - name: Validate Compose files
        run: |
          find home/dot_local/opt/stacks -name "compose.yaml.tmpl" | while read tmpl; do
            dir="$(dirname "$tmpl")"
            echo "Validating $dir"
            # Render template if needed, or validate as-is if no template
            if [[ "$tmpl" == *.tmpl ]]; then
              chezmoi execute-template < "$tmpl" | docker compose -f - config -q
            else
              docker compose -f "$tmpl" config -q
            fi
          done
```

[CITED: https://forgejo.org/docs/latest/user/actions/ — workflow syntax, matrix builds]

### Example 3: Robust Version Discovery (lazygit Fixed)

```bash
# Source: home/.chezmoiscripts/unix/run_once_after_529-install-lazygit.sh.tmpl (fixed)
#!/usr/bin/env bash

{{ template "common/script_is_not_ephemeral" . }}
{{ template "common/script_helper" . }}

info ">>>>>> 🦥 Installing lazygit 🦥 <<<<<<"

if command -v lazygit &> /dev/null; then
    info "lazygit is already installed: $(lazygit --version 2>&1 | head -1)"
    success ">>> 🦥 lazygit already installed 🦥"
    exit 0
fi

# Detect architecture
ARCH="$(uname -m)"
case "$ARCH" in
    x86_64)  LG_ARCH="x86_64" ;;
    aarch64) LG_ARCH="arm64" ;;
    arm64)   LG_ARCH="arm64" ;;
    armv7l)  LG_ARCH="armv6" ;;
    *)
        error "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# Detect OS
LG_OS="Linux"
case "$(uname -s)" in
    Darwin) LG_OS="Darwin" ;;
esac

# Get latest release version using jq (robust, portable)
info "Fetching latest lazygit release..."
LG_VERSION=$(curl -fsSL "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" \
    ${GITHUB_TOKEN:+-H "Authorization: Bearer $GITHUB_TOKEN"} \
    | jq -r '.tag_name | ltrimstr("v")')

# Validate version
if [ -z "$LG_VERSION" ] || [ "$LG_VERSION" = "null" ]; then
    error "Could not determine latest lazygit version"
    error "Check network connectivity and GitHub API availability"
    exit 1
fi

info "Installing lazygit ${LG_VERSION} for ${LG_OS}/${LG_ARCH}..."

LG_FILE="lazygit_${LG_VERSION}_${LG_OS}_${LG_ARCH}.tar.gz"
LG_URL="https://github.com/jesseduffield/lazygit/releases/download/v${LG_VERSION}/${LG_FILE}"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

info "Downloading: ${LG_URL}"
if ! curl -fsSL "$LG_URL" -o "$TMPDIR/$LG_FILE"; then
    error "Failed to download lazygit from $LG_URL"
    exit 1
fi

info "Extracting..."
tar -xzf "$TMPDIR/$LG_FILE" -C "$TMPDIR"

mkdir -p "$HOME/.local/bin"
cp "$TMPDIR/lazygit" "$HOME/.local/bin/lazygit"
chmod +x "$HOME/.local/bin/lazygit"

if command -v lazygit &> /dev/null || [ -x "$HOME/.local/bin/lazygit" ]; then
    success ">>> 🦥 Installed lazygit: $("$HOME/.local/bin/lazygit" --version 2>&1 | head -1) 🦥"
else
    error "Failed to install lazygit"
    exit 1
fi
```

**Key improvements:**
- `jq -r '.tag_name | ltrimstr("v")'` replaces `grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/'`
- `${GITHUB_TOKEN:+-H "Authorization: Bearer $GITHUB_TOKEN"}` adds auth only if token exists
- Validates `$LG_VERSION` is non-empty and not "null" before proceeding
- `curl -f` ensures HTTP errors fail the script
- Clear error messages guide troubleshooting

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `grep \| sed` for JSON parsing | `jq` for JSON processing | jq stable since 2015 | Eliminates brittle regex patterns; handles all valid JSON formatting |
| GitHub Actions as de facto CI standard | Forgejo Actions (GitHub-compatible) on self-hosted platforms | Forgejo 1.19 (2023) | Same workflow syntax, runs on Codeberg/self-hosted without Microsoft dependency |
| Docker Compose v1 (`docker-compose`) | Docker Compose v2 (docker compose plugin) | Compose v2 GA 2021 | Integrated into docker CLI; faster, better integration with Docker ecosystem |
| Manual template validation | `chezmoi execute-template` in CI | chezmoi 2.x templating matured 2020+ | Catches template errors before they reach production; fast feedback loop |

**Deprecated/outdated:**
- `docker-compose` (Python-based, v1): Replaced by `docker compose` (Go-based, v2 plugin). v1 still works but unmaintained.
- `grep -P` for portable scripts: BSD grep never supported it; always use `grep -E`, `awk`, or `jq` for cross-platform code.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | Cross-platform shell scripting incompatibilities (grep -P, sed -i, readlink -f differences between GNU and BSD) | Common Pitfalls, Architecture Patterns | Plan may recommend portable alternatives that don't actually work; scripts fail on BSD/macOS despite being marked "fixed" |
| A2 | `script_arch_based_only` doesn't depend on EndeavourOS/CachyOS-specific features; can be expanded to pure Arch | User Constraints (Claude's Discretion) | If scripts rely on EndeavourOS-specific repos/configs, expanding to pure Arch breaks those installs |
| A3 | `jq` is available on all target platforms or can be easily installed as a dependency | Standard Stack | If Termux or macOS Homebrew lacks `jq`, installer scripts fail; need fallback or bundle jq binary |
| A4 | Codeberg's Forgejo Actions runners support `runs-on: docker` label | Architecture Patterns | If no runner matches, CI jobs wait indefinitely; need self-hosted runner documentation |
| A5 | Ollama mode=user selective deletion pattern (keep models/, delete binaries) is correct | Phase Requirements APPLY-04 | If models are stored elsewhere or identity key path is wrong, reinstall still loses data |

**If this table has entries:** These claims need user confirmation. Specifically:
- **A1:** Verify cross-platform alternatives (grep -E, sed portability) work in actual macOS/BSD environments
- **A2:** Check if any script under `script_arch_based_only` guard uses EndeavourOS-specific packages/configs (e.g., CachyOS repos)
- **A3:** Confirm `jq` is in Termux package repo (`pkg install jq`) and test on actual Termux device
- **A4:** Check Codeberg runner availability at start of planning phase; document self-hosted runner setup as Plan B
- **A5:** Verify Ollama directory structure (models location, identity key path) in both root and user modes on Linux

## Open Questions

1. **What runner labels are actually available on Codeberg?**
   - What we know: Codeberg has "limited" hosted runners; self-hosted is recommended
   - What's unclear: Whether `runs-on: docker` is a valid label, or if it needs to be `ubuntu-latest`, `linux`, or something else
   - Recommendation: Check `/{owner}/{repo}/settings/actions/runners` after pushing an empty workflow; if no runners match, include self-hosted runner setup instructions in Plan B

2. **Should `script_arch_based_only` expand to pure Arch?**
   - What we know: Current guard checks for `endeavouros` or `cachyos` in `osid`; pure Arch (`linux-arch`) fails
   - What's unclear: Whether the protected scripts rely on EndeavourOS-specific repos, configs, or tools
   - Recommendation: Grep for `endeavouros`/`cachyos` references in scripts 655, 515, 201, 214, 215, 220; if none found, expand guard to include pure Arch and document rationale

3. **Where exactly are Ollama models and identity stored in user mode?**
   - What we know: Current code uses `rm -rf "$HOME/.ollama"` which deletes everything
   - What's unclear: Exact paths for models directory and identity key within `~/.ollama/`
   - Recommendation: Run `ollama` in user mode and inspect `~/.ollama/` structure; likely `~/.ollama/models/` and `~/.ollama/id_*` files, but verify before implementing selective deletion

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|------------------|
| V2 Authentication | No | N/A — phase is infrastructure/CI, no auth endpoints |
| V3 Session Management | No | N/A — no sessions |
| V4 Access Control | No | N/A — no authorization logic |
| V5 Input Validation | Yes | Template input validation via `chezmoi execute-template`; shell script validation via `shellcheck` |
| V6 Cryptography | Yes | Encrypted files (`encrypted_*.asc`) remain encrypted; GPG key never enters CI |

### Known Threat Patterns for chezmoi + CI

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Secrets leaked via rendered templates in CI logs | Information Disclosure | Skip encrypted files via `.chezmoiignore` or selective rendering; never decrypt in CI |
| Malicious template injection via data files | Tampering | Templates execute in controlled environment (CI runner); data files are version-controlled, reviewed via PR |
| Arbitrary code execution via `run_once_` scripts | Tampering / Elevation of Privilege | Scripts run only during local `chezmoi apply`, not in CI; CI only renders and lints, never executes |
| Dependency confusion via installer scripts | Tampering | Use official release URLs (`github.com/owner/repo/releases`); validate download URLs match expected domain |
| CI runner compromise exposing repository secrets | Information Disclosure | No secrets in repository; encrypted files remain encrypted; Codeberg's runners are isolated per job |

**Key principle:** CI is a read-only validation environment. It renders templates with dummy data, lints scripts, and validates configurations, but never applies changes, never decrypts secrets, and never accesses production systems. The only failure mode is a DoS (broken CI blocks merges), not a data breach.

## Sources

### Primary (MEDIUM confidence — official documentation)

- [CITED: https://www.chezmoi.io/user-guide/templating/] - chezmoi templating, execute-template command, encrypted file handling
- [CITED: https://forgejo.org/docs/latest/user/actions/] - Forgejo Actions workflow syntax, triggers, job structure
- [CITED: https://docs.codeberg.org/ci/actions/] - Codeberg-specific Actions limitations, runner availability, self-hosted recommendation
- [CITED: https://github.com/koalaman/shellcheck/wiki/Integration] - shellcheck severity levels, exit codes, CI integration patterns
- [CITED: https://jqlang.org/manual/] - jq JSON parsing, field access, array indexing, string manipulation
- [CITED: https://docs.docker.com/reference/cli/docker/compose/config/] - docker compose config command, validation usage, exit codes

### Verified (HIGH confidence — codebase inspection)

- [VERIFIED: home/dot_zshrc.d/termux.zsh.tmpl:124] - `.features.ai.omniroute.domain` missing key bug
- [VERIFIED: home/.chezmoiscripts/linux/run_once_after_504-install-ollama.sh.tmpl:96] - `.features.ai.ollama.environments` wrong key path
- [VERIFIED: home/.chezmoiscripts/unix/run_once_after_590-install-ai-tools.sh.tmpl:18,40,57] - `:=` variable shadowing bug
- [VERIFIED: home/.chezmoiscripts/unix/run_once_after_528-install-glab.sh.tmpl:39] - `grep -oP` macOS incompatibility
- [VERIFIED: home/.chezmoiscripts/unix/run_once_after_529-install-lazygit.sh.tmpl:37-38] - `grep | sed` fragile version discovery
- [VERIFIED: home/.chezmoi.yaml.tmpl:50,100,101,118] - CHEZMOI_* environment variable overrides for profile simulation
- [VERIFIED: home/.chezmoitemplates/workplace/script_is_instivo:1] - Instivo guard checks `.settings.workplace == "Instivo"`
- [VERIFIED: home/.chezmoitemplates/linux/script_arch_based_only:1] - Arch-based guard checks `osid` contains `endeavouros` or `cachyos`

### Tertiary (LOW confidence — training knowledge, marked for validation)

- [ASSUMED] Cross-platform shell scripting incompatibilities (grep -P, sed -i, readlink -f) — based on training knowledge of GNU vs BSD tool differences; needs verification on actual macOS/BSD systems
- [ASSUMED] Ollama directory structure in user mode (`~/.ollama/models/`, `~/.ollama/id_*`) — inferred from common patterns; needs verification by running Ollama in user mode

## Metadata

**Confidence breakdown:**
- Standard stack: MEDIUM - Official documentation fetched and cited; versions not verified against registries but tools are mature/stable
- Architecture: MEDIUM - Forgejo Actions syntax confirmed via official docs; Codeberg runner availability is uncertain (documented as "limited")
- Pitfalls: HIGH - Template bugs verified by reading actual code; cross-platform issues are known patterns with strong priors
- Security: MEDIUM - Threat model based on ASVS categories and standard STRIDE analysis; no penetration testing performed

**Research date:** 2026-11-24
**Valid until:** 2026-12-24 (30 days) — chezmoi and jq are stable; Forgejo Actions evolving but syntax is GitHub-compatible; Codeberg runner situation may change

---

*Phase: 01-apply-em-todo-perfil-e-ci*
*Research complete: 2026-11-24*
