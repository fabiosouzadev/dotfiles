#!/bin/sh

set -eu

PROJECT_DIR="/data"
REPOSITORY="git@codeberg.org:fabiosouzadev/my-knowledge.git"

SSH_DIR="/root/.ssh"
SSH_KEY="/run/secrets/codeberg_deploy_key"
SSH_KNOWN_HOSTS="/run/secrets/codeberg_known_hosts"

export HOME="/root"

echo "[entrypoint] Configuring SSH..."

# Ensure secrets exist
if [ ! -f "$SSH_KEY" ] || [ ! -f "$SSH_KNOWN_HOSTS" ]; then
    echo "[ERROR] SSH secrets are missing."
    exit 1
fi

# Create SSH directory with secure permissions
install -d -m 700 "$SSH_DIR"

# Copy secrets to local SSH configuration
install -m 600 "$SSH_KEY" "$SSH_DIR/id_ed25519"
install -m 644 "$SSH_KNOWN_HOSTS" "$SSH_DIR/known_hosts"

# Configure Codeberg SSH
cat > "$SSH_DIR/config" <<'EOF'
Host codeberg.org
    HostName codeberg.org
    User git
    IdentityFile /root/.ssh/id_ed25519
    IdentitiesOnly yes
    StrictHostKeyChecking yes
    UserKnownHostsFile /root/.ssh/known_hosts
EOF

chmod 600 "$SSH_DIR/config"

echo "[entrypoint] SSH configured."

# First boot: clone repository
if [ ! -d "$PROJECT_DIR/.git" ]; then

    echo "[entrypoint] Repository not found."

    if [ -n "$(find "$PROJECT_DIR" -mindepth 1 -maxdepth 1 -print -quit)" ]; then
        echo "[ERROR] /data is not empty and is not a Git repository."
        exit 1
    fi

    echo "[entrypoint] Cloning repository..."

    git clone "$REPOSITORY" "$PROJECT_DIR"

fi

cd "$PROJECT_DIR"

# Ensure the expected repository is configured
ORIGIN="$(git remote get-url origin 2>/dev/null || true)"

if [ "$ORIGIN" = "https://codeberg.org/fabiosouzadev/my-knowledge.git" ]; then
    echo "[entrypoint] Migrating remote from HTTPS to SSH..."
    git remote set-url origin "$REPOSITORY"
elif [ "$ORIGIN" != "$REPOSITORY" ]; then
    echo "[ERROR] Unexpected Git remote: ${ORIGIN:-none}"
    exit 1
fi

# Configure SSH specifically for this repository.
# This is independent of the shell environment inherited by Git.
git config --local core.sshCommand "ssh -F /root/.ssh/config"

# Configure Git identity
: "${GIT_USER_NAME:?GIT_USER_NAME is required}"
: "${GIT_USER_EMAIL:?GIT_USER_EMAIL is required}"

git config --local user.name "$GIT_USER_NAME"
git config --local user.email "$GIT_USER_EMAIL"


# Validate Git authentication before starting OpenKnowledge
echo "[entrypoint] Testing Codeberg authentication..."

if ! GIT_TERMINAL_PROMPT=0 git ls-remote origin HEAD >/dev/null; then
    echo "[ERROR] Cannot authenticate with Codeberg."
    echo "[ERROR] Check Deploy Key and known_hosts."
    exit 1
fi

echo "[entrypoint] Git authentication successful."
echo "[entrypoint] Commit: $(git rev-parse --short HEAD)"

# Initialize OpenKnowledge only once
if [ ! -d ".ok" ]; then
    echo "[entrypoint] Initializing OpenKnowledge..."
    ok init --no-mcp --no-skills < /dev/null
else
    echo "[entrypoint] OpenKnowledge already initialized."
fi

echo "[entrypoint] Starting OpenKnowledge..."

exec ok start
