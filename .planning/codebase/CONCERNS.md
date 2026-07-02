# Codebase Concerns

**Analysis Date:** 2026-06-12

## Tech Debt

**Environment detection template is high-complexity control plane:**
- Issue: `home/.chezmoi.yaml.tmpl` combines CI, container, WSL, GUI, SSH, hostname, workplace, VPS, feature, and directory detection in one 313-line template. Several decisions depend on shell probes (`output "sh" "-c" ...`) and nested `ternary` expressions.
- Files: `home/.chezmoi.yaml.tmpl`
- Impact: A false positive in `$inContainer`, `$headless`, `$guiAvailable`, or `$profile` changes what configs and services are rendered across every machine. Debugging requires re-rendering the full chezmoi data model.
- Fix approach: Split detection into documented sections with minimal shell probes, add explicit override variables (`CHEZMOI_PROFILE`, `CHEZMOI_FORCE_GUI`, `CHEZMOI_FORCE_HEADLESS` already exist), and add render tests for representative hosts.

**OmniRoute configuration is duplicated across shell, service, Caddy, and tool configs:**
- Issue: OmniRoute host, port, API key decryption, and model gateway assumptions appear in several files instead of one generated data source.
- Files: `home/dot_zshrc.d/605-omniroute.zsh.tmpl`, `home/dot_claude/settings.json.tmpl`, `home/private_dot_config/opencode/opencode.json.tmpl`, `home/private_dot_openclaude.json.tmpl`, `home/private_dot_config/systemd/user/omniroute.service.tmpl`, `home/private_dot_config/caddy/Caddyfile.tmpl`
- Impact: Changing OmniRoute host, mode, or token handling requires editing multiple templates. Mixed `localhost`, `vps-omniroute`, and `157.151.13.223` values can drift.
- Fix approach: Put host/port/protocol/model defaults under `home/.chezmoi.yaml.tmpl` `features.ai.omniroute`, then render all consumers from those values.

**Tool versions prefer moving targets:**
- Issue: Several managed tools use `latest`, `lts`, `autoupdate`, or GitHub release downloads instead of pinned versions.
- Files: `home/private_dot_config/mise/config.toml.tmpl`, `home/private_dot_config/opencode/opencode.json.tmpl`, `home/dot_zshrc.d/101-zinit-plugins.zsh.tmpl`
- Impact: New machines can install different versions from existing machines. A breaking release can change shell behavior, AI tool behavior, or generated lockfiles.
- Fix approach: Pin critical CLI versions in `home/private_dot_config/mise/config.toml.tmpl`; keep `latest` only for low-risk tools; document intentional auto-update behavior per tool.

**Generated application state is committed as config:**
- Issue: `home/private_dot_config/glab-cli/private_config.yml.tmpl` contains fields that look like runtime state (`last_update_check_timestamp`, Duo/Orbit binary metadata placeholders, telemetry settings) mixed with desired configuration.
- Files: `home/private_dot_config/glab-cli/private_config.yml.tmpl`
- Impact: Applying dotfiles can overwrite locally managed CLI state or preserve stale state across machines.
- Fix approach: Keep only desired settings and auth host entries in the template; let `glab` maintain runtime update metadata locally.

**Hard-coded personal paths reduce portability:**
- Issue: `home/private_dot_config/greenclip.toml` hard-codes `/home/fabiosouzadev/.cache/greenclip.history` instead of using chezmoi home data or XDG variables.
- Files: `home/private_dot_config/greenclip.toml`
- Impact: Applying under a different username writes clipboard history to a nonexistent path or the wrong path.
- Fix approach: Convert to `home/private_dot_config/greenclip.toml.tmpl` and render `history_file` from `.chezmoi.homeDir` or `${XDG_CACHE_HOME}`.

## Known Bugs

**Commented template still decrypts and renders Freemodel key:**
- Symptoms: `home/dot_zshrc.d/604-openclaude.zsh.tmpl` contains a shell-commented `OPENAI_API_KEY` line with a live Go template expression. Go templates evaluate before shell comments matter, so rendered `.zshrc.d/604-openclaude.zsh` can contain a commented plaintext API key.
- Files: `home/dot_zshrc.d/604-openclaude.zsh.tmpl`
- Trigger: Run `chezmoi apply` with access to `home/dot_keys/encrypted_freemodels-key.txt.asc`.
- Workaround: Remove the `include ... decrypt` expression from commented examples; use placeholder text in comments.

**OmniRoute health aliases ignore VPS-client host selection:**
- Symptoms: `OPENAI_BASE_URL` switches to `http://${OMNIROUTE_HOST:-vps-omniroute}:20128/v1` in VPS-client mode, but health/dashboard/models aliases still call `http://localhost:20128`.
- Files: `home/dot_zshrc.d/605-omniroute.zsh.tmpl`
- Trigger: Render with `.features.ai.omniroute.mode` set to `vps-client`, then run `omniroute-health`, `omniroute-dashboard`, or `omniroute-models` on a client machine.
- Workaround: Override aliases locally or run `curl` against `$OPENAI_BASE_URL` host manually.

**Unquoted Zsh source loop breaks on paths with spaces:**
- Symptoms: `home/dot_zshrc.tmpl` loops over `$ZDOTDIR/.zshrc.d/*.zsh` and runs `source $i` without quoting.
- Files: `home/dot_zshrc.tmpl`
- Trigger: Home directory, dotfile path, or sourced file path contains spaces or glob-sensitive characters.
- Workaround: Keep home path without spaces; quote as `source "$i"` in the template.

**Caddy route mixes configured domain with hard-coded public IP over HTTP:**
- Symptoms: `home/private_dot_config/caddy/Caddyfile.tmpl` emits a server block for `{{ .features.ai.omniroute.domain }}, http://157.151.13.223`. The IP is hard-coded and tied to one deployment.
- Files: `home/private_dot_config/caddy/Caddyfile.tmpl`, `home/private_dot_config/opencode/opencode.json.tmpl`
- Trigger: VPS IP changes, domain points elsewhere, or HTTP access to the public IP bypasses expected TLS hostname flow.
- Workaround: Use the configured domain and remove the public-IP site label, or render IP from `.features.ai.omniroute` data.

## Security Considerations

**AI gateway tokens are decrypted into rendered config and shell environment:**
- Risk: API keys become available to shell child processes, shell history/debug dumps, `/proc` environment readers on permissive systems, and rendered config files.
- Files: `home/dot_zshrc.d/605-omniroute.zsh.tmpl`, `home/dot_claude/settings.json.tmpl`, `home/dot_codex/auth.json.tmpl`, `home/private_dot_config/opencode/opencode.json.tmpl`, `home/private_dot_config/glab-cli/private_config.yml.tmpl`
- Current mitigation: Source secrets are encrypted as `.asc` files under `home/dot_keys/`, `home/dot_zshrc.d/`, `home/private_dot_ssh/`, `home/private_dot_config/glab-cli/`, and related paths.
- Recommendations: Avoid exporting long-lived API keys globally. Prefer tool-specific config files with restrictive permissions, local keyring integration, or short-lived tokens where supported.

**Public OmniRoute server mode binds service to all interfaces:**
- Risk: In VPS server mode, `home/private_dot_config/systemd/user/omniroute.service.tmpl` sets `Environment=HOST=0.0.0.0`. If OmniRoute auth or firewall rules are misconfigured, the AI gateway can be reachable beyond localhost.
- Files: `home/private_dot_config/systemd/user/omniroute.service.tmpl`, `home/private_dot_config/caddy/Caddyfile.tmpl`
- Current mitigation: Caddy reverse-proxies `127.0.0.1:20128` and adds basic hardening headers; OmniRoute API keys are configured separately.
- Recommendations: Bind OmniRoute to `127.0.0.1` when Caddy is the intended ingress, enforce firewall rules, and document direct-port exposure requirements when `HOST=0.0.0.0` is intentional.

**OpenCode uses a public HTTP AI gateway URL:**
- Risk: `home/private_dot_config/opencode/opencode.json.tmpl` sends `apiKey` to `http://157.151.13.223:20129/v1` without TLS in the template.
- Files: `home/private_dot_config/opencode/opencode.json.tmpl`, `home/private_dot_config/caddy/Caddyfile.tmpl`
- Current mitigation: API key is encrypted at rest in source and decrypted during render.
- Recommendations: Use an HTTPS domain from `home/private_dot_config/caddy/Caddyfile.tmpl`, avoid raw public IP HTTP, and keep direct HTTP only for localhost/Tailscale-private addresses.

**Clipboard manager stores unlimited selection size:**
- Risk: `home/private_dot_config/greenclip.toml` sets `max_selection_size_bytes = 0` and no blacklisted applications. Secrets copied from terminals, password managers, browsers, or AI tool configs can persist in clipboard history.
- Files: `home/private_dot_config/greenclip.toml`
- Current mitigation: None detected in config.
- Recommendations: Set a nonzero max selection size, blacklist password/secret tools, and document cleanup of `history_file`.

**Gemini safety filters disabled for aichat:**
- Risk: `home/private_dot_config/aichat/config.yaml.tmpl` sets Gemini `safetySettings` thresholds to `BLOCK_NONE` for harassment, hate speech, sexual content, and dangerous content.
- Files: `home/private_dot_config/aichat/config.yaml.tmpl`
- Current mitigation: Configuration is local to aichat use.
- Recommendations: Keep `BLOCK_NONE` only if explicitly required; otherwise use provider defaults or document why unrestricted responses are needed.

**Telemetry and auto-update settings are enabled:**
- Risk: Some tools can phone home or update without an explicit per-run prompt.
- Files: `home/private_dot_config/glab-cli/private_config.yml.tmpl`, `home/private_dot_config/opencode/opencode.json.tmpl`
- Current mitigation: Not detected.
- Recommendations: Decide per tool whether telemetry/autoupdate belongs in shared dotfiles. Disable by default for managed/work profiles if policy requires it.

## Performance Bottlenecks

**Zsh startup runs many synchronous sources and init hooks:**
- Problem: `home/dot_zshrc.tmpl` sources every file in `.zshrc.d`; plugin and tool initialization includes zinit, fzf, zoxide, direnv, mise, AI gateway exports, and other aliases.
- Files: `home/dot_zshrc.tmpl`, `home/dot_zshrc.d/100-install-zinit.zsh.tmpl`, `home/dot_zshrc.d/101-zinit-plugins.zsh.tmpl`, `home/dot_zshrc.d/103-fzf.zsh.tmpl`, `home/dot_zshrc.d/999-autoload-compinit.zsh.tmpl`
- Cause: Startup path sources modules eagerly and runs several `eval "$(tool init ...)"` hooks inside zinit load blocks.
- Improvement path: Measure startup with `zprof`, lazy-load heavy tools, and move optional AI/workplace exports behind functions where possible.

**First shell startup can clone zinit:**
- Problem: `home/dot_zshrc.d/100-install-zinit.zsh.tmpl` clones `https://github.com/zdharma-continuum/zinit.git` during shell startup when zinit is missing.
- Files: `home/dot_zshrc.d/100-install-zinit.zsh.tmpl`
- Cause: Installation work is embedded in interactive shell initialization.
- Improvement path: Move zinit installation to a chezmoi script or documented bootstrap step; keep shell startup read-only and fast.

**Completion initialization runs without cache-only mode:**
- Problem: `home/dot_zshrc.d/999-autoload-compinit.zsh.tmpl` runs plain `compinit` on every shell startup.
- Files: `home/dot_zshrc.d/999-autoload-compinit.zsh.tmpl`
- Cause: Plain `compinit` performs security and completion checks at startup.
- Improvement path: Use a cached `.zcompdump` strategy and consider `compinit -C` after trusted setup.

## Fragile Areas

**OmniRoute SQL sync exports sensitive and schema-dependent tables:**
- Files: `home/private_dot_local/bin/executable_omniroute-sync.tmpl`
- Why fragile: The script dumps a fixed table list, including `api_keys` and `upstream_proxy_config`, using SQLite `.mode insert` and transforms statements with `sed`. Schema changes, table absence, or SQL format changes can break sync silently because each `sqlite3` dump redirects errors to `/dev/null`.
- Safe modification: Add explicit table existence checks, fail on missing expected tables, wrap pull in a transaction, back up `storage.sqlite` before import, and avoid syncing raw provider API key rows unless encrypted per destination.
- Test coverage: No automated tests detected for `push`, `pull`, or `status` paths.

**Chezmoi source contains many encrypted operational secrets:**
- Files: `home/dot_aws/encrypted_private_credentials.asc`, `home/dot_zshrc.d/encrypted_300-ai-api-keys.zsh.asc`, `home/dot_zshrc.d/encrypted_404-zup-keys.zsh.asc`, `home/private_dot_ssh/encrypted_private_id_ed25519_personal.asc`, `home/private_dot_ssh/encrypted_private_id_ed25519_zup.asc`, `home/private_dot_local/private_share/vpn/encrypted_fabiosouza.key.asc`, `home/private_dot_coderabbit/encrypted_private_auth.json.asc`
- Why fragile: A single lost encryption identity blocks recovery of SSH keys, API tokens, VPN certs, AWS credentials, and tool auth files. A single compromised identity exposes all encrypted material.
- Safe modification: Maintain documented key backup, rotate exposed keys after recipient changes, and consider multiple recipients for recovery.
- Test coverage: No recovery test or secret inventory validation detected.

**Nix/dev environment files mix flakes, devenv, and project-specific assets:**
- Files: `home/private_dot_local/private_share/environments/node.nix`, `home/private_dot_local/private_share/environments/java.nix`, `home/private_dot_local/private_share/environments/php.nix`, `home/private_dot_local/private_share/environments/instivo-ms-auth/devenv.nix`, `home/private_dot_local/private_share/environments/instivo-receiving-conference-ms/devenv.nix`, `home/private_dot_local/private_share/environments/instivo-ms-fornecedor/flake.nix`
- Why fragile: Generic language environments and workplace/project environments live in one tree with different lockfile strategies.
- Safe modification: Separate generic reusable environments from project/workplace-specific environments and document expected update workflow per type.
- Test coverage: No automated render/build checks detected for these Nix environments.

## Scaling Limits

**Single-user dotfiles assume one primary identity and machine profile:**
- Current capacity: One main user identity, one GPG signing key, one personal SSH key path, one work include path, and profile detection based on hostname/workplace data.
- Limit: Additional users, multiple work identities, or shared forks need edits in `home/private_dot_config/git/config.tmpl`, `home/.chezmoi.yaml.tmpl`, and secret paths.
- Scaling path: Move identities into data structures keyed by profile and render Git/SSH/tool configs from selected profile data.

**OmniRoute sync is whole-config import/export:**
- Current capacity: Whole-table SQL export/import for a small local OmniRoute database.
- Limit: Conflicts across machines, partial updates, and provider-specific key rotation are not represented; last import wins.
- Scaling path: Add per-record ownership/version fields or export declarative config without runtime state.

## Dependencies at Risk

**`zdharma-continuum/zinit` bootstrap from GitHub at shell startup:**
- Risk: Network outage, GitHub rate limiting, or upstream compromise affects new shells on machines without zinit.
- Impact: Shell startup can fail or stall before prompt customizations and plugin-provided commands load.
- Migration plan: Install through chezmoi/bootstrap with checksum/pinning, or vendor a known revision.

**AI model/provider names are hard-coded:**
- Risk: Provider model IDs can disappear or change behavior.
- Impact: Claude, OpenCode, OpenClaude, Codex, and aichat workflows can fail despite dotfiles rendering correctly.
- Migration plan: Centralize model IDs in `home/.chezmoi.yaml.tmpl` data and add a health command that verifies configured model availability.

## Missing Critical Features

**Automated render validation:**
- Problem: No CI or local test harness is detected for `chezmoi execute-template`, `chezmoi diff`, or profile matrix rendering.
- Blocks: Safe changes to `home/.chezmoi.yaml.tmpl`, AI configs, and cross-platform templates.

**Secret recovery and rotation runbooks:**
- Problem: Encrypted files are present, but a concrete recovery/rotation workflow is not enforced by code.
- Blocks: Confident key rotation, fork onboarding, and disaster recovery after GPG/age identity loss.

## Test Coverage Gaps

**Template rendering matrix:**
- What's not tested: OS/profile combinations for macOS, Linux, WSL, VPS, work, personal, headless, interactive, and container modes.
- Files: `home/.chezmoi.yaml.tmpl`, `home/private_dot_config/caddy/Caddyfile.tmpl`, `home/private_dot_config/systemd/user/omniroute.service.tmpl`, `home/dot_zshrc.d/*.tmpl`
- Risk: Template changes can break only one target environment and remain undetected until apply time.
- Priority: High

**Shell script linting and behavior tests:**
- What's not tested: Shell quoting, command availability, error handling, `omniroute-sync` SQL import/export behavior, and Zsh startup regressions.
- Files: `home/private_dot_local/bin/executable_omniroute-sync.tmpl`, `home/dot_zshrc.tmpl`, `home/dot_zshrc.d/100-install-zinit.zsh.tmpl`, `home/dot_zshrc.d/605-omniroute.zsh.tmpl`
- Risk: Runtime failures appear during login or manual sync operations rather than during review.
- Priority: High

**Security configuration checks:**
- What's not tested: Plaintext secret rendering, public HTTP endpoints, `HOST=0.0.0.0`, clipboard persistence, and disabled safety filters.
- Files: `home/dot_zshrc.d/604-openclaude.zsh.tmpl`, `home/private_dot_config/opencode/opencode.json.tmpl`, `home/private_dot_config/systemd/user/omniroute.service.tmpl`, `home/private_dot_config/greenclip.toml`, `home/private_dot_config/aichat/config.yaml.tmpl`
- Risk: Sensitive tokens or unsafe network bindings can be introduced by template edits.
- Priority: High

---

*Concerns audit: 2026-06-12*
