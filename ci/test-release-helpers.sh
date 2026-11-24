#!/usr/bin/env bash
# Hermetic tests for release helper functions (require_jq, github_latest_tag, gitlab_latest_tag).
#
# Uses a fake curl on PATH to simulate API responses; validates that the helpers:
# - parse JSON with jq
# - send GITHUB_TOKEN only as a header
# - validate tag format
# - return clear error messages on failures
#
# 9 test cases:
# 1. github-ok: valid response, extracts tag
# 2. token: GITHUB_TOKEN present, token in log as header, not in stdout/stderr
# 3. no-token: GITHUB_TOKEN unset, no Authorization header
# 4. http-error: curl exit 22, stderr mentions GITHUB_TOKEN
# 5. bad-json: invalid JSON
# 6. null-tag: tag_name is null
# 7. bad-tag: tag_name doesn't match version regex
# 8. gitlab-ok: GitLab API, valid tag
# 9. jq-present: require_jq returns 0 when jq is on PATH

set -euo pipefail

CI_TOOLS_DIR="${CI_TOOLS_DIR:-${TMPDIR:-/tmp}/dotfiles-ci-tools}"
export PATH="$CI_TOOLS_DIR:$PATH"

# Check if jq is available
if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq required: run bash ci/bootstrap-tools.sh" >&2
  exit 2
fi

# Setup test environment
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

# Prepare fake curl
FAKE_CURL="$WORK/bin/curl"
FAKE_CURL_LOG="$WORK/curl.log"
FAKE_CURL_MODE_FILE="$WORK/curl.mode"
mkdir -p "$WORK/bin"

cat > "$FAKE_CURL" <<'FAKE_CURL_EOF'
#!/usr/bin/env bash
# Fake curl: logs arguments, returns canned output based on FAKE_CURL_MODE

for arg in "$@"; do
  echo "$arg" >> "${FAKE_CURL_LOG:-/dev/null}"
done

MODE="${FAKE_CURL_MODE:-github-ok}"

case "$MODE" in
  github-ok)
    echo '{"tag_name":"v1.2.3"}'
    exit 0
    ;;
  gitlab-ok)
    echo '{"tag_name":"v1.132.0"}'
    exit 0
    ;;
  http-error)
    exit 22
    ;;
  bad-json)
    echo '<html>'
    exit 0
    ;;
  null-tag)
    echo '{"tag_name":null}'
    exit 0
    ;;
  bad-tag)
    echo '{"tag_name":"latest"}'
    exit 0
    ;;
  *)
    echo "FAKE_CURL: unknown mode $MODE" >&2
    exit 1
    ;;
esac
FAKE_CURL_EOF

chmod +x "$FAKE_CURL"

# Prepend fake curl to PATH
export PATH="$WORK/bin:$PATH"
export FAKE_CURL_LOG
export FAKE_CURL_MODE

# Source the helpers (CR-stripped)
HELPER_SRC="$WORK/helpers.sh"
tr -d '\r' < home/.chezmoitemplates/common/script_helper > "$HELPER_SRC"
if [ -f home/.chezmoitemplates/common/script_release_helpers ]; then
  tr -d '\r' < home/.chezmoitemplates/common/script_release_helpers >> "$HELPER_SRC"
else
  echo "FAIL 0 setup: script_release_helpers missing" >&2
  echo "RELEASE HELPERS FAILED (failed=1)" >&2
  exit 1
fi

# Test runner
PASSED=0
FAILED=0
CASE_NUM=0

run_case() {
  local name="$1"
  local check="$2"

  CASE_NUM=$((CASE_NUM + 1))
  rm -f "$FAKE_CURL_LOG"

  # Run check in subshell with set +e to capture exit status
  set +e
  (
    source "$HELPER_SRC"
    set +e
    eval "$check"
  )
  local result=$?
  set -e

  if [ $result -eq 0 ]; then
    echo "PASS $CASE_NUM $name"
    PASSED=$((PASSED + 1))
  else
    echo "FAIL $CASE_NUM $name: check returned $result"
    FAILED=$((FAILED + 1))
  fi
}

# Case 1: github-ok
run_case "github-ok" '
  export FAKE_CURL_MODE=github-ok
  unset GITHUB_TOKEN
  TAG=$(github_latest_tag acme/tool) && \
  [ "$TAG" = "v1.2.3" ] && \
  grep -q "https://api.github.com/repos/acme/tool/releases/latest" "$FAKE_CURL_LOG" && \
  grep -q -- "-f" "$FAKE_CURL_LOG"
'

# Case 2: token
run_case "token" '
  export FAKE_CURL_MODE=github-ok
  export GITHUB_TOKEN=tok-test-123
  OUT=$(github_latest_tag acme/tool 2>&1) && \
  [ "$OUT" = "v1.2.3" ] && \
  ! echo "$OUT" | grep -q "tok-test-123" && \
  grep -q "Authorization: Bearer tok-test-123" "$FAKE_CURL_LOG"
'

# Case 3: no-token
run_case "no-token" '
  export FAKE_CURL_MODE=github-ok
  unset GITHUB_TOKEN
  OUT=$(github_latest_tag acme/tool 2>&1) && \
  [ "$OUT" = "v1.2.3" ] && \
  ! grep -q "Authorization" "$FAKE_CURL_LOG"
'

# Case 4: http-error
run_case "http-error" '
  export FAKE_CURL_MODE=http-error
  unset GITHUB_TOKEN
  OUT=$(github_latest_tag acme/tool 2>&1 || true) && \
  [ -z "$(echo "$OUT" | grep -v "ERROR")" ] && \
  echo "$OUT" | grep -qi "GITHUB_TOKEN"
'

# Case 5: bad-json
run_case "bad-json" '
  export FAKE_CURL_MODE=bad-json
  unset GITHUB_TOKEN
  OUT=$(github_latest_tag acme/tool 2>&1 || true) && \
  [ -z "$(echo "$OUT" | grep -v "ERROR")" ]
'

# Case 6: null-tag
run_case "null-tag" '
  export FAKE_CURL_MODE=null-tag
  unset GITHUB_TOKEN
  OUT=$(github_latest_tag acme/tool 2>&1 || true) && \
  [ -z "$(echo "$OUT" | grep -v "ERROR")" ] && \
  echo "$OUT" | grep -qi "Unexpected release tag"
'

# Case 7: bad-tag
run_case "bad-tag" '
  export FAKE_CURL_MODE=bad-tag
  unset GITHUB_TOKEN
  OUT=$(github_latest_tag acme/tool 2>&1 || true) && \
  [ -z "$(echo "$OUT" | grep -v "ERROR")" ] && \
  echo "$OUT" | grep -qi "Unexpected release tag"
'

# Case 8: gitlab-ok
run_case "gitlab-ok" '
  export FAKE_CURL_MODE=gitlab-ok
  unset GITHUB_TOKEN
  TAG=$(gitlab_latest_tag 34675721) && \
  [ "$TAG" = "v1.132.0" ] && \
  grep -q "https://gitlab.com/api/v4/projects/34675721/releases/permalink/latest" "$FAKE_CURL_LOG"
'

# Case 9: jq-present
run_case "jq-present" '
  unset FAKE_CURL_MODE
  require_jq && \
  [ $? -eq 0 ] && \
  ! [ -f "$FAKE_CURL_LOG" ] || ! [ -s "$FAKE_CURL_LOG" ]
'

# Final result
if [ $FAILED -eq 0 ]; then
  echo "RELEASE HELPERS OK (cases=$CASE_NUM)"
  exit 0
else
  echo "RELEASE HELPERS FAILED (failed=$FAILED)"
  exit 1
fi
