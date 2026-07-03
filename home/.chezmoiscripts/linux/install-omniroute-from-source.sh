#!/usr/bin/env bash
# Chezmoi script to install OmniRoute from source
# This script should be run after chezmoi has applied the configurations

set -euo pipefail

echo "🚀 Installing OmniRoute from source..."

# Configuration
OMNIROUTE_DIR="${HOME}/.local/src/OmniRoute"
OMNIROUTE_REPO="https://github.com/omniroute/omniroute.git"
SERVICE_FILE="/etc/systemd/system/omniroute.service"
ENV_FILE="${HOME}/.omniroute/.env"

# Create directory if it doesn't exist
mkdir -p "$(dirname "$OMNIROUTE_DIR")"

# Clone or update repository
if [ -d "$OMNIROUTE_DIR" ]; then
    echo "📁 Updating existing OmniRoute source..."
    cd "$OMNIROUTE_DIR"
    git fetch origin
    git reset --hard origin/main
else
    echo "📥 Cloning OmniRoute repository..."
    git clone "$OMNIROUTE_REPO" "$OMNIROUTE_DIR"
fi

# Ensure Node.js is installed via mise (should be handled by chezmoi, but double-check)
if ! command -v mise &> /dev/null; then
    echo "❌ mise not found. Please ensure chezmoi has installed mise first."
    exit 1
fi

# Install Node.js LTS if not already installed
if ! mise ls | grep -q "lts"; then
    echo "📦 Installing Node.js LTS via mise..."
    mise install node@lts
fi

mise use node@lts --local

# Install dependencies
echo "📦 Installing Node.js dependencies..."
cd "$OMNIROUTE_DIR"
npm ci

# Build CLI
echo "🔨 Building OmniRoute CLI..."
npm run build:cli

# Ensure environment file exists
if [ ! -f "$ENV_FILE" ]; then
    echo "⚠️  Environment file not found at $ENV_FILE"
    echo "Please create it with required variables (see docs/OMNIROUTE-BACKUP.md)"
    # Create a basic one if missing
    mkdir -p "$(dirname "$ENV_FILE")"
    cat > "$ENV_FILE" <<EOF
# OmniRoute environment variables
# Please add your actual values:
# STORAGE_ENCRYPTION_KEY=
# OMNIROUTE_PUBLIC_BASE_URL=
# PORT=20128
EOF
    echo "Created basic environment file at $ENV_FILE - please edit it with your values"
fi

# Handle systemd service
# Note: The actual systemd file is managed by chezmoi in .chezmoifiles/
# We need to ensure it's deployed and the service is enabled/started

echo "🔧 Setting up systemd service..."
# The systemd service file should be deployed by chezmoi to /etc/systemd/system/
# We'll check if it exists and if not, we'll copy it from chezmoi
if [ ! -f "$SERVICE_FILE" ]; then
    echo "📋 Copying systemd service from chezmoi..."
    sudo cp "${HOME}/.local/share/chezmoi/.chezmoifiles/systemd/omniroute.service" "$SERVICE_FILE"
    sudo systemctl daemon-reload
fi

# Enable and start service
echo "▶️  Enabling and starting OmniRoute service..."
sudo systemctl enable omniroute.service
sudo systemctl restart omniroute.service

# Wait for service to be ready
echo "⏳ Waiting for service to start..."
sleep 5

# Verify service is active
if sudo systemctl is-active --quiet omniroute.service; then
    echo "✅ OmniRoute is running!"
    echo "📊 Dashboard: http://localhost:20128"
    echo "🔌 API Base: http://localhost:20129/v1"
else
    echo "❌ Failed to start OmniRoute service"
    sudo systemctl status omniroute.service --no-pager
    echo "💡 Check journalctl for more details:"
    echo "   journalctl -u omniroute.service -f"
    exit 1
fi

echo "🎉 OmniRoute installation complete!"
