
#!/bin/sh

set -eu

PROJECT_DIR="/data"
REPOSITORY="git@codeberg.org:fabiosouzadev/my-knowledge.git"

SSH_KEY="/run/secrets/codeberg_deploy_key"
SSH_KNOWN_HOSTS="/run/secrets/codeberg_known_hosts"

echo "[entrypoint] Checking OpenKnowledge repository..."

# Configure SSH for Git
export GIT_SSH_COMMAND="ssh \
  -i ${SSH_KEY} \
  -o IdentitiesOnly=yes \
  -o StrictHostKeyChecking=yes \
  -o UserKnownHostsFile=${SSH_KNOWN_HOSTS}"

# First boot: clone repository
if [ ! -d "${PROJECT_DIR}/.git" ]; then

    echo "[entrypoint] Repository not found."

    # Do not overwrite existing data
    if [ -n "$(find "$PROJECT_DIR" -mindepth 1 -maxdepth 1 -print -quit)" ]; then
        echo "[ERROR] /data is not empty and is not a Git repository."
        exit 1
    fi

    echo "[entrypoint] Cloning repository from Codeberg..."

    git clone "$REPOSITORY" "$PROJECT_DIR"

else
    echo "[entrypoint] Existing Git repository detected."
fi

cd "$PROJECT_DIR"

# Validate repository
git rev-parse --verify HEAD >/dev/null

echo "[entrypoint] Repository ready."
echo "[entrypoint] Commit: $(git rev-parse --short HEAD)"

# Initialize OpenKnowledge only once
if [ ! -d ".ok" ]; then
    echo "[entrypoint] Initializing OpenKnowledge..."

    ok init --no-mcp --no-skills < /dev/null
else
    echo "[entrypoint] OpenKnowledge already initialized."
fi

# Start server
echo "[entrypoint] Starting OpenKnowledge..."

exec ok start
