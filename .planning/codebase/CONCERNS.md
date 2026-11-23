---
last_mapped_commit: c2840b6cdfa7b1cdccbfa7c030396b2c931328a2
last_mapped_at: 2026-11-23
---
# Codebase Concerns

**Analysis Date:** 2026-11-23

## Tech Debt

### 1. Unversioned "latest" Dependency Tags

**Issue:** Multiple Docker images and package installations reference unversioned or dynamic "latest" tags, reducing reproducibility and increasing the risk of breaking changes between deployments.

**Files:**
- `home/dot_local/opt/stacks/ollama/compose.yaml.tmpl` - Line 3: `ollama/ollama:latest`
- `home/dot_local/opt/stacks/openknowledge/compose.yaml.tmpl` - `openknowledge:latest`
- `home/.chezmoidata/ollama.yaml` - Line 3: `version: "latest"`
- `home/.chezmoiscripts/linux/run_once_after_504-install-ollama.sh.tmpl` - Lines 22-26: Dynamic version via GitHub API
- `home/private_dot_config/mise/config.toml.tmpl` - Line 9: `@inkeep/open-knowledge` with `version = "latest"`

**Impact:** 
- Cannot guarantee reproducible environments across machines or time
- Potential for silent breakage when container images update
- Deployment inconsistency between local dev and VPS environments
- Rollback becomes difficult as "latest" may no longer be available

**Fix approach:** 
1. Pin all container images to specific versions (e.g., `ollama/ollama:0.1.26`)
2. Create a version registry in `.chezmoidata/versions.yaml`
3. Use update strategy for intentional upgrades (e.g., weekly vs. on-demand)
4. Document version selection criteria and changelog

---

### 2. Hardcoded Domain Names and IP Addresses

**Issue:** External service endpoints and VPS configuration are hardcoded throughout templates, making the dotfiles difficult to fork or reuse and creating a single point of failure if infrastructure changes.

**Files:**
- `home/dot_local/opt/stacks/omniroute/compose.yaml.tmpl` - Line 24: Hardcoded `193.123.97.209` and `omniroute-fabiosouzadev.duckdns.org`
- `home/dot_local/opt/stacks/caddy/Caddyfile.tmpl` - Lines 17, 27, 32, 37, 63: Multiple hardcoded `fabiosouzadev.duckdns.org` subdomains
- `home/dot_hermes/config.yaml.tmpl` - `matrix-fabiosouzadev.duckdns.org` and `notes-fabiosouzadev.duckdns.org`
- `home/.chezmoidata/termux/data.yaml` - `vps_host: "fabiosouzadev.duckdns.org"`

**Impact:**
- Repository is not reusable by others without manual editing
- VPS migration or infrastructure change requires find-and-replace across many files
- Security consideration: IP address exposed in Git history

**Fix approach:**
1. Extract all domains/IPs to `.chezmoi.yaml.tmpl` as configurable data variables
2. Replace hardcoded values with template functions: `{{ .vps.host }}`, `{{ .vps.ip }}`
3. Create environment variable overrides for CI/CD and fork scenarios
4. Document the expected configuration schema

---

### 3. Complex Multi-Platform Script Conditionals

**Issue:** Setup scripts use nested OS-specific conditionals and templates, increasing complexity and making it difficult to maintain or test across platforms.

**Files:**
- `home/.chezmoiscripts/linux/run_once_after_504-install-ollama.sh.tmpl` - Lines 20-87: Deeply nested conditionals for "user" vs "root" modes
- `home/.chezmoiscripts/darwin/run_once_after_530-install-idea-community.sh.tmpl` - Complex macOS-specific installation with hdiutil mount operations
- `home/.chezmoiscripts/windows/run_once_after_530-install-idea-community.ps1.tmpl` - PowerShell variant with different logic paths
- 56 total script files across `.chezmoiscripts/` with platform-specific branching

**Impact:**
- Bug fixes in one platform variant may not be applied to others
- Testing burden increases with each platform variant
- Maintenance overhead when upgrading tools
- Logic divergence between platforms over time

**Fix approach:**
1. Extract common logic into shared shell functions in `.chezmoidata/`
2. Use cross-platform tools (e.g., `mise` for version management) instead of platform-specific installers
3. Create test harness that validates installation on all platforms
4. Consider unified approach using mise for deterministic tool provisioning

---

### 4. Shell Script Error Handling Gaps

**Issue:** Some shell scripts lack robust error handling, with missing `set -euo pipefail` guards, unquoted variables, and operations that could silently fail.

**Files:**
- `home/dot_local/opt/stacks/openknowledge/entrypoint.sh` - Uses `set -eu` correctly ✓, but lines 49-52 risk non-obvious behavior if `find` output changes
- `home/.chezmoiscripts/linux/run_once_after_504-install-ollama.sh.tmpl` - Line 23: Uses `sed` with unquoted substitution; `curl` with `| grep` chain lacks intermediate error checks
- `home/.chezmoiscripts/unix/run_once_after_528-install-glab.sh.tmpl` - Lines 38-39: Uses `grep` on JSON without `jq`, brittle string parsing

**Impact:**
- Silent failures during installation could leave system in broken state
- Difficult to diagnose failures in CI/remote environments
- Variable expansion bugs if paths contain spaces or special chars

**Fix approach:**
1. Add `set -euo pipefail` to all bash scripts
2. Use `jq` or similar structured parsers instead of `sed | grep` chains
3. Validate all extracted values before use
4. Add debug output via `set -x` in troubleshooting mode

---

## Known Bugs

### 1. ARENA_ELO_SYNC Disabled Due to Version Bug

**Symptoms:** Arena ELO synchronization is explicitly disabled in OmniRoute configuration.

**Files:** `home/dot_local/opt/stacks/omniroute/compose.yaml.tmpl` - Line 56

**Trigger:** Set `ARENA_ELO_SYNC_ENABLED=true` in Omniroute 3.8.52 configuration

**Workaround:** Keep `ARENA_ELO_SYNC_ENABLED=false` or upgrade OmniRoute version

**Root Cause:** Specific bug in OmniRoute v3.8.52 (marked in comment: `#Erro nesta versão`)

---

### 2. Commented Out Browser Service Dependencies

**Symptoms:** ChatGPT Web Codex browser service is fully commented out in OmniRoute compose file, breaking any features that depend on web browsing capability.

**Files:** `home/dot_local/opt/stacks/omniroute/compose.yaml.tmpl` - Lines 89-105

**Trigger:** Try to use browser-based model interaction through OmniRoute

**Workaround:** None currently; feature is disabled

**Root Cause:** Service is non-functional in this OmniRoute version; commented to avoid startup errors

---

## Security Considerations

### 1. API Key Revelation Enabled in Production

**Risk:** OmniRoute is configured to allow API key revelation in its dashboard, potentially exposing sensitive credentials to authorized users.

**Files:** `home/dot_local/opt/stacks/omniroute/compose.yaml.tmpl` - Line 31: `ALLOW_API_KEY_REVEAL=true`

**Current mitigation:** 
- Requires API key authentication (`REQUIRE_API_KEY=true`)
- Reverse proxy (Caddy) adds HTTPS/TLS termination
- WebSocket allowed hosts are explicitly restricted (line 24)

**Recommendations:**
1. Disable API key reveal in production (`ALLOW_API_KEY_REVEAL=false`)
2. Use short-lived tokens instead of persistent API keys
3. Implement audit logging for API key access
4. Restrict dashboard access by IP/user role

---

### 2. Encrypted Files Without Key Material in Repository

**Risk:** Repository contains 41 encrypted `.asc` (GPG) files but no key material. If GPG key is lost, encrypted data becomes inaccessible.

**Files:** 
- `home/dot_aws/encrypted_private_credentials.asc`
- `home/dot_hermes/encrypted_private_*.asc` (multiple)
- `home/dot_keys/encrypted_*.asc` (multiple)
- `home/dot_camofox/cookies/encrypted_linkedin.txt.asc`
- `home/dot_local/opt/stacks/omniroute/restore/encrypted_private_config.sql.asc`

**Current mitigation:**
- GPG key is managed separately (recipient ID: E691C031009FB1DAA3A25125212D516F623C5747)
- `.env*` files are in `.gitignore` (not committed)
- Chezmoi encryption uses local GPG configuration

**Recommendations:**
1. Maintain GPG key backup in secure location (hardware key, secure key manager)
2. Document recovery procedure for encrypted files
3. Add `.planning/security/key-recovery.md` with attestation requirements
4. Consider using age encryption alongside GPG for better key management

---

### 3. Broad WebSocket Host Allowlist

**Risk:** OmniRoute WebSocket allows connections from a hardcoded IP address in addition to localhost.

**Files:** `home/dot_local/opt/stacks/omniroute/compose.yaml.tmpl` - Line 24: `193.123.97.209` appears to be a public/shared IP

**Current mitigation:** Explicit allowlist prevents `0.0.0.0` wildcard

**Recommendations:**
1. Extract IP to configuration variable (not hardcoded)
2. Document why this IP is allowed
3. Implement IP-based rate limiting and monitoring
4. Consider using JWT/HMAC instead of IP-based access control

---

### 4. SSH Key Permissions in Container Entry Point

**Risk:** OpenKnowledge container entrypoint creates SSH configuration with potentially loose file permissions or unvalidated key material.

**Files:** `home/dot_local/opt/stacks/openknowledge/entrypoint.sh` - Lines 23-40

**Current mitigation:** 
- Installs with explicit mode `600` for private keys (line 26)
- Validates secret file existence (lines 17-20)
- Uses `chmod 600` for SSH config (line 40)

**Recommendations:**
1. Verify that `SSH_KEY` and `SSH_KNOWN_HOSTS` files are not world-readable when mounted
2. Add permission validation before use
3. Consider using `ssh-keygen` to validate key format before copying
4. Add audit logging when SSH secrets are accessed

---

## Performance Bottlenecks

### 1. Large History Configuration with Unbounded Growth

**Risk:** Zsh history is configured for 1 billion lines (`HISTSIZE=1000000000`), which could consume excessive disk space and slow shell startup.

**Files:** `home/dot_zshrc.d/102-history.zsh.tmpl` - Line 1: `export HISTSIZE=1000000000`

**Problem:** 
- History file could grow to multiple GB
- Shell startup time increases with history size
- Memory usage grows with large in-memory history

**Improvement path:**
1. Implement a reasonable history rotation (e.g., 50 million lines)
2. Use `atuin` for external history management (already installed, see `.chezmoiscripts/unix/run_once_after_536-install-atuin.sh.tmpl`)
3. Add cleanup job to archive old history monthly
4. Monitor history file size with alerting

---

### 2. OmniRoute Memory Allocation May Be Insufficient

**Risk:** OmniRoute is allocated 8GB of Node.js memory (`OMNIROUTE_MEMORY_MB=8192`), which may be insufficient for handling large model contexts and concurrent requests.

**Files:** `home/dot_local/opt/stacks/omniroute/compose.yaml.tmpl` - Lines 58-59

**Problem:**
- Multiple large language models running concurrently could exceed allocation
- Out-of-memory errors would crash the service
- No memory monitoring/alerting in current setup

**Improvement path:**
1. Monitor actual memory usage over time
2. Implement memory-based rate limiting
3. Add Prometheus metrics for heap usage
4. Consider horizontal scaling with multiple OmniRoute instances

---

## Fragile Areas

### 1. Dynamic Version Resolution via GitHub API

**Files:**
- `home/.chezmoiscripts/linux/run_once_after_504-install-ollama.sh.tmpl` - Lines 22-26
- `home/.chezmoiscripts/darwin/run_once_after_504-install-ollama-darwin.sh.tmpl` - Similar pattern
- `home/.chezmoiscripts/unix/run_once_after_528-install-glab.sh.tmpl` - Lines 38-39
- `home/.chezmoiscripts/unix/run_once_after_529-install-lazygit.sh.tmpl` - GitHub API version fetch
- `home/.chezmoiscripts/unix/run_once_after_536-install-atuin.sh.tmpl` - GitHub API version fetch

**Why fragile:**
- Depends on GitHub API being available and unchanged format
- No fallback if API rate limit is hit or service is down
- `sed | grep` parsing is brittle; tag name format changes would break extraction
- No validation that extracted version is a valid semver

**Safe modification:**
1. Use GitHub CLI (`gh api`) with structured JSON output instead of grep/sed
2. Cache version lookups in `.chezmoidata/`
3. Add retry logic with exponential backoff
4. Validate semver format after extraction
5. Add error messages that show what failed

**Test coverage:** 
- None currently; should add shellcheck validation
- Could benefit from pre-flight check of GitHub API access

---

### 2. OmniRoute Container Health Check

**Files:** `home/dot_local/opt/stacks/omniroute/compose.yaml.tmpl` - Lines 72-80

**Why fragile:**
- Health check runs Node.js script (`healthcheck.mjs`) directly in container
- If script has syntax error or Node.js process fails, health check fails catastrophically
- No timeout guard; long-running health check could block orchestration
- No logging of health check results

**Safe modification:**
1. Create separate health check script with error handling
2. Add logging to `healthcheck.mjs`
3. Verify health check script exists and is executable before service starts
4. Add timeout guard (`timeout 4s` to stay under 5s limit)

---

### 3. Synapse Matrix Server Configuration

**Files:** 
- `home/dot_local/opt/stacks/synapse/data/matrix-fabiosouzadev.duckdns.org.log.config.tmpl`
- `home/dot_local/opt/stacks/synapse/data/homeserver.yaml.tmpl`

**Why fragile:**
- Multiple configuration files with no validation
- Matrix server initialization depends on correct PostgreSQL setup
- TLS/HTTPS configuration depends on Caddy reverse proxy being correctly configured
- No automated testing of Matrix federation

**Safe modification:**
1. Create validation script that checks configuration file syntax
2. Add pre-flight checks for PostgreSQL connectivity
3. Test federation with other Matrix servers
4. Document expected Caddy configuration for Matrix

---

## Scaling Limits

### 1. Single-Node Docker Compose Deployment

**Current capacity:** All services run on a single VPS (hostname `fabiosouzadev.duckdns.org`)

**Services affected:**
- OmniRoute (gateway for all LLM access)
- Hindsight (memory/knowledge system)
- PostgreSQL (database for all stateful services)
- Redis (caching and rate limiting)
- Qdrant (vector store for embeddings)
- Caddy (reverse proxy)

**Limit:** Single point of failure; no redundancy or failover

**Scaling path:**
1. Deploy read replicas for PostgreSQL
2. Use Redis cluster instead of single instance
3. Implement load balancing for OmniRoute behind reverse proxy
4. Consider Kubernetes for multi-node orchestration
5. Add monitoring and alerting for service health

---

### 2. Rate Limiting with Single Redis Instance

**Files:** `home/dot_local/opt/stacks/omniroute/compose.yaml.tmpl` - Lines 61-62, 34

**Current setup:**
- Rate limit queues stored in Redis (`QUOTA_STORE_DRIVER=redis`)
- 600-second max wait time for rate-limited requests
- Shared state across all OmniRoute instances (if deployed)

**Limit:** Redis becomes bottleneck if rate limit checks are high-frequency

**Scaling path:**
1. Implement local rate limiting cache with eventual consistency
2. Use Redis Cluster for horizontal scaling
3. Consider dedicated rate limiting service (e.g., Envoy rate limit service)

---

## Dependencies at Risk

### 1. OmniRoute Container Image Stability

**Risk:** OmniRoute is a third-party project (`diegosouzapw/omniroute:3.8.52-web`) with unclear maintenance status.

**Impact:** If maintainer abandons project, security patches and bug fixes become unavailable.

**Migration plan:**
1. Monitor OmniRoute releases and maintenance activity
2. Build image locally if maintenance slows
3. Consider alternatives: LiteLLM, Ollama Proxy, or custom gateway
4. Document decision criteria for switching LLM gateways

---

### 2. Hindsight Vector Database Dependency

**Risk:** Hindsight uses Qdrant for vector storage, which is a critical dependency for memory/knowledge features.

**Files:** `home/dot_local/opt/stacks/hindsight/compose.yaml.tmpl` - Multiple Qdrant configuration lines

**Impact:** 
- If Qdrant service fails, Hindsight cannot function
- Vector embeddings are not migrable to other systems without re-embedding
- No backup strategy documented

**Migration plan:**
1. Implement Qdrant backup and restore procedures
2. Document migration path to alternative vector databases (Milvus, Weaviate, Pinecone)
3. Add monitoring and alerting for Qdrant disk usage
4. Create automated export of embeddings for disaster recovery

---

### 3. Matrix Synapse Server Maintenance

**Risk:** Matrix Synapse is a large, complex Python project with ongoing maintenance burden.

**Files:** `home/dot_local/opt/stacks/synapse/data/`

**Impact:** Synapse requires regular updates for security fixes and bug patches; updates can be disruptive.

**Migration plan:**
1. Create Synapse upgrade playbook with rollback procedure
2. Test upgrades in staging environment first
3. Set up automated health checks post-upgrade
4. Document known incompatibilities with client applications

---

## Missing Critical Features

### 1. Automated Backup and Disaster Recovery

**Problem:** No documented backup strategy for critical stateful services.

**Missing:**
- Backup of PostgreSQL databases (Hindsight, Synapse, Omniroute config)
- Backup of Qdrant vector database
- Backup of encrypted configuration files
- Restore procedures and RPO/RTO targets

**Blocks:** 
- Cannot recover from data loss without manual recovery
- No way to migrate infrastructure to new VPS

---

### 2. Monitoring and Alerting

**Problem:** No centralized monitoring, logging, or alerting system in place.

**Missing:**
- Health check dashboard for all services
- Log aggregation (logs are scattered across containers)
- Alert thresholds for disk space, memory, CPU, network
- Automated incident response (e.g., restart crashed services)

**Blocks:**
- Cannot proactively detect failures
- Difficult to troubleshoot production issues
- No historical data for performance analysis

---

### 3. Configuration Validation and Testing

**Problem:** No automated validation of rendered templates or configuration files.

**Missing:**
- Schema validation for all YAML files
- Syntax checking for shell scripts (shellcheck)
- Pre-deployment validation of Docker Compose files
- Integration tests for multi-service interactions

**Blocks:**
- Configuration errors discovered at runtime only
- Cannot catch syntax errors before deployment
- No validation that dependent services are properly configured

---

## Test Coverage Gaps

### 1. Shell Script Testing

**What's not tested:**
- Cross-platform installation scripts (`.chezmoiscripts/*/`)
- Error handling paths in install scripts
- Dynamic version resolution from GitHub API
- Variable expansion with special characters

**Files with gaps:**
- `home/.chezmoiscripts/linux/run_once_after_504-install-ollama.sh.tmpl`
- `home/.chezmoiscripts/darwin/run_once_after_504-install-ollama-darwin.sh.tmpl`
- `home/.chezmoiscripts/windows/run_once_after_530-install-idea-community.ps1.tmpl`

**Risk:** Silent failures during system bootstrap; difficult to diagnose in CI/remote environments

**Priority:** High

---

### 2. Docker Compose Configuration Validation

**What's not tested:**
- Compose file syntax validation
- Service startup order and dependencies
- Network connectivity between services
- Volume mount permissions

**Files with gaps:**
- All 13 files in `home/dot_local/opt/stacks/*/compose.yaml.tmpl`

**Risk:** Service startup failures; misconfigured networking; permission errors with mounted volumes

**Priority:** High

---

### 3. Chezmoi Template Rendering

**What's not tested:**
- Template variable resolution
- Conditional blocks based on OS/profile
- File permissions and ownership
- Symlink creation and paths

**Files with gaps:**
- `home/.chezmoi.yaml.tmpl` (complex, 280+ lines)
- All `.tmpl` files in home directory

**Risk:** Broken dotfile installation; incorrect file permissions; missing symlinks

**Priority:** Medium

---

### 4. Integration Tests

**What's not tested:**
- OmniRoute connectivity to Qdrant/PostgreSQL/Redis
- Matrix Synapse federation and federation protocol
- Hindsight memory operations end-to-end
- Caddy reverse proxy routing to all backend services

**Risk:** Service interdependencies broken; no detection until production use

**Priority:** Medium

---

*Concerns audit: 2026-11-23*
