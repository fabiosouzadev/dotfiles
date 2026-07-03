#!/usr/bin/env bash
# OmniRoute installation script for chezmoi
# Installs OmniRoute from source and configures systemd service

set -euo pipefail

# Configuration
OMNIROUTE_REPO="https://github.com/omniroute/omniroute.git"
OMNIROUTE_DIR="${HOME}/.local/src/OmniRoute"
SERVICE_FILE="/etc/systemd/system/omniroute.service"
ENV_FILE="${HOME}/.omniroute/.env"

echo "🚀 Installing OmniRoute from source..."

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

# Install Node.js via mise if not available
if ! command -v mise &> /dev/null; then
    echo "🔧 Installing mise (version manager)..."
    curl https://mise.run | sh
    # Add to current shell
    export PATH="$HOME/.local/share/mise/bin:$PATH"
    eval "$(mise activate bash)"
fi

# Install Node.js LTS
echo "📦 Installing Node.js LTS via mise..."
mise install node@lts
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
    echo "Continuing anyway..."
fi

# Copy systemd service file (if not already managed by chezmoi)
# Note: chezmoi should handle this via .chezmoifiles/systemd/omniroute.service
if [ ! -f "$SERVICE_FILE" ]; then
    echo "📋 Setting up systemd service..."
    sudo cp "${HOME}/.local/share/chezmoi/.chezmoifiles/systemd/omniroute.service" "$SERVICE_FILE"
    sudo systemctl daemon-reload
fi

# Start and enable service
echo "▶️  Starting OmniRoute service..."
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
    exit 1
fi

echo "🎉 Installation complete!"
