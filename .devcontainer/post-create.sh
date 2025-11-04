#!/usr/bin/env bash
set -euo pipefail

# Post-create script - runs once when container is created
# This script is called from postCreateCommand

echo "Running post-create setup..."

CONF_DIR="/workspace/.devcontainer/.conf"

# Import git configuration if available
if [ -f "$CONF_DIR/.gitconfig" ]; then
    echo "Importing git configuration..."
    cp "$CONF_DIR/.gitconfig" /root/.gitconfig
    chmod 600 /root/.gitconfig
fi

# Configure SSH for git operations
echo "Configuring SSH..."
mkdir -p /root/.ssh
chmod 700 /root/.ssh

# Create SSH config for git operations
cat > /root/.ssh/config <<'EOF'
# SSH configuration for git operations
Host *
    StrictHostKeyChecking accept-new
    AddKeysToAgent yes
EOF

chmod 600 /root/.ssh/config

echo "✓ SSH configured"
echo ""
echo "ℹ Git SSH signing will be configured automatically when you attach to the container"
echo "  (See post-attach.sh for details)"
echo ""
echo "Post-create setup complete"
