#!/bin/sh
set -eu

PROJECT_DIR="/data"
EXPECTED_REMOTE="https://codeberg.org/fabiosouzadev/my-knowledge.git"

echo "[entrypoint] Validating Git repository..."

# 1. Ensure repository exists
if ! git -C "$PROJECT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "[ERROR] Git repository not found in $PROJECT_DIR"
    echo "[ERROR] Download the repository before starting OpenKnowledge."
    exit 1
fi

# 2. Ensure repository has a valid commit
if ! git -C "$PROJECT_DIR" rev-parse --verify HEAD >/dev/null 2>&1; then
    echo "[ERROR] Git repository has no valid commit."
    exit 1
fi

# 3. Validate origin
ORIGIN="$(git -C "$PROJECT_DIR" remote get-url origin 2>/dev/null || true)"

if [ "$ORIGIN" != "$EXPECTED_REMOTE" ]; then
    echo "[ERROR] Unexpected Git remote."
    echo "Expected: $EXPECTED_REMOTE"
    echo "Received: ${ORIGIN:-none}"
    exit 1
fi

echo "[entrypoint] Git repository validated."
echo "[entrypoint] Commit: $(git -C "$PROJECT_DIR" rev-parse --short HEAD)"

cd "$PROJECT_DIR"

# 4. Initialize OpenKnowledge only once
if [ ! -d ".ok" ]; then
    echo "[entrypoint] Initializing OpenKnowledge..."

    ok init --no-mcp --no-skills < /dev/null
else
    echo "[entrypoint] OpenKnowledge already initialized."
fi

# 5. Start server
echo "[entrypoint] Starting OpenKnowledge..."

exec ok start
