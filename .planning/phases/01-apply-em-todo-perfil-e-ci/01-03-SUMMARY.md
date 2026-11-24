---
phase: 01-apply-em-todo-perfil-e-ci
plan: 03
subsystem: templates
tags: [chezmoi, templates, termux, ai-tools, shellcheck, render-fixes]

# Dependency graph
requires:
  - phase: 01-apply-em-todo-perfil-e-ci
    provides: CI render harness and fixtures (plan 01-01)
provides:
  - Termux template using correct .termux.ssh data keys
  - AI tools installer with proper flag reassignment (Composio and herdr)
  - Window manager script rendering on EndeavourOS/CachyOS
  - Hardware driver scripts rendering on rtl8821ce and linuxonmac
  - Shellcheck-clean templates (SC2157 and SC2046 fixed)
affects: [01-04, 01-05]

# Actuals
actuals:
  tokens: 15000
  tasks: 3
  commits: 3

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Template-time conditionals for shellcheck warnings ({{- if .url }})"
    - "Flag reassignment with = inside {{ if }} blocks (not :=)"
    - "Current element access with 'index .' inside range loops"

key-files:
  created: []
  modified:
    - home/dot_zshrc.d/termux.zsh.tmpl
    - home/.chezmoiscripts/unix/run_once_after_590-install-ai-tools.sh.tmpl
    - home/.chezmoiscripts/linux/run_once_before_216-install-wm.sh.tmpl
    - home/.chezmoiscripts/linux/run_once_before_103-install-rtl8821ce-driver.sh.tmpl
    - home/.chezmoiscripts/linux/run_once_before_104-install-cirrus-driver-for-macbook.tmpl
    - home/.chezmoiscripts/linux/run_onchange_before_202-install-ubuntu-packages.sh.tmpl
    - home/.chezmoiscripts/linux/run_once_before_215-install-virtualisation.sh.tmpl

key-decisions:
  - "Used .termux.ssh.vps_host/vps_user from data.yaml instead of features.ai path"
  - "Changed := to = for flag reassignment in template if blocks (M2 fix)"
  - "Moved URL test from shell runtime to template time for shellcheck compliance"

patterns-established:
  - "Flag reassignment pattern: use = inside {{ if }}, keep := for initial declarations"
  - "Template-time conditionals to avoid shellcheck warnings on rendered literals"

requirements-completed: [APPLY-02, APPLY-03, REL-05]

coverage:
  - id: D1
    description: "Termux template renders with vps_host and vps_user from data"
    requirement: APPLY-02
    verification:
      - kind: automated_ui
        ref: "bash ci/render.sh one termux home/dot_zshrc.d/termux.zsh.tmpl | grep 'local vps_ip=\"fabiosouzadev.duckdns.org\"'"
        status: pass
    human_judgment: false
  - id: D2
    description: "AI tools installer renders Composio when enabled, omits when disabled"
    requirement: APPLY-03
    verification:
      - kind: automated_ui
        ref: "bash ci/render.sh one linux-arch home/.chezmoiscripts/unix/run_once_after_590-install-ai-tools.sh.tmpl | grep -c 'Installing composio'"
        status: pass
    human_judgment: false
  - id: D3
    description: "Window manager script renders AUR packages on Arch profiles"
    requirement: REL-05
    verification:
      - kind: automated_ui
        ref: "bash ci/render.sh one linux-arch home/.chezmoiscripts/linux/run_once_before_216-install-wm.sh.tmpl | grep -c 'rofi-greenclip'"
        status: pass
    human_judgment: false
  - id: D4
    description: "Hardware driver scripts render with their flags enabled"
    requirement: REL-05
    verification:
      - kind: automated_ui
        ref: "bash ci/render.sh with hardware flags | grep rtl8821ce-dkms-git"
        status: pass
    human_judgment: false
  - id: D5
    description: "Shellcheck warnings SC2157 and SC2046 fixed without suppressions"
    requirement: REL-05
    verification:
      - kind: automated_ui
        ref: "bash ci/render.sh gate shows shellcheck_failures=0 for all profiles"
        status: pass
    human_judgment: false

# Metrics
duration: 13 min
completed: 2026-11-24
plan_head_before: 979e8b110942334c29c96c359e9babc4817ca8c6
plan_head_after: d9d2bf36fa9f458bcc71f11432d97fdd8b29d314
status: complete
---

# Phase 01 Plan 03: Template defects and shellcheck warnings Summary

**Seven template render defects fixed (A5, M2, three Arch/hardware breaks, SC2157 ×8, SC2046) — all files now render cleanly with shellcheck passing**

## Performance

- **Duration:** 13 min
- **Started:** 2026-11-24T17:46:25Z
- **Completed:** 2026-11-24T18:00:00Z
- **Tasks:** 3 completed
- **Files modified:** 7

## Accomplishments
- Fixed termux.zsh.tmpl to use .termux.ssh.vps_host/vps_user from data (A5)
- Fixed ai-tools installer flag reassignment with = instead of := (M2)
- Fixed window-manager script AUR block rendering on Arch profiles
- Fixed rtl8821ce and Cirrus driver scripts to use .settings.osid
- Fixed SC2157 warnings by moving URL test to template time
- Fixed SC2046 warning by quoting $(whoami) command substitution

## Task Commits

Each task was committed atomically:

1. **Task 1: Fix A5 and M2 defects** - `1994a47` (feat)
2. **Task 2: Fix render breaks on Arch and hardware** - `8e9b01d` (fix)
3. **Task 3: Fix shellcheck warnings** - `d9d2bf3` (fix)

## Files Created/Modified
- `home/dot_zshrc.d/termux.zsh.tmpl` - qr-ssh using .termux.ssh data keys
- `home/.chezmoiscripts/unix/run_once_after_590-install-ai-tools.sh.tmpl` - flag reassignment with =
- `home/.chezmoiscripts/linux/run_once_before_216-install-wm.sh.tmpl` - AUR packages via index .
- `home/.chezmoiscripts/linux/run_once_before_103-install-rtl8821ce-driver.sh.tmpl` - .settings.osid
- `home/.chezmoiscripts/linux/run_once_before_104-install-cirrus-driver-for-macbook.tmpl` - .settings.osid
- `home/.chezmoiscripts/linux/run_onchange_before_202-install-ubuntu-packages.sh.tmpl` - template-time URL test
- `home/.chezmoiscripts/linux/run_once_before_215-install-virtualisation.sh.tmpl` - quoted whoami

## Decisions Made
- Used .termux.ssh data keys instead of features.ai path (HYG-01 will centralize in Phase 2)
- Moved URL emptiness test from shell runtime to template time (SC2157 fix)
- Added Portuguese comment explaining := vs = in template if blocks
- Noted Composio PATH mismatch: 590 installs on non-VPS, 312-source-composio.zsh adds PATH only on VPS (out of scope, left unchanged)

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None - all render and shellcheck issues resolved as planned.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Ready for plan 01-04 (Ollama template fixes) and 01-05 (gate verification across all profiles). Together with plan 01-02 (Ollama installers), the full `bash ci/render.sh gate` should turn green on all five profiles.

## Open Observations

**Composio PATH mismatch (noted for user awareness):** The ai-tools installer (590) now installs Composio on non-VPS machines when `features.hermes.composio.enabled: true`. However, `312-source-composio.zsh.tmpl` adds `~/.composio` to PATH only on the VPS profile. This means Composio is installed but not on PATH for non-VPS profiles with the flag enabled. No requirement covers this mismatch, so it was left unchanged as planned.

---
*Phase: 01-apply-em-todo-perfil-e-ci*
*Completed: 2026-11-24*
