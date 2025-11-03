#!/usr/bin/env bash
set -euo pipefail

# Post-create script - runs once when container is created
# This script is called from postCreateCommand

echo "Running post-create setup..."

CONF_DIR="/workspace/.devcontainer/.conf"

# Configure GPG
if [ -d "/root/.gnupg" ]; then
    chmod 700 /root/.gnupg
fi

# Import GPG public keys if available
if [ -f "$CONF_DIR/gpg-public-keys.asc" ]; then
    echo "Importing GPG public keys..."
    gpg --import "$CONF_DIR/gpg-public-keys.asc" 2>/dev/null || true
fi

# Import GPG ownertrust if available
if [ -f "$CONF_DIR/gpg-ownertrust.txt" ]; then
    echo "Importing GPG ownertrust..."
    gpg --import-ownertrust "$CONF_DIR/gpg-ownertrust.txt" 2>/dev/null || true
fi

# Configure GPG agent to use SSH authentication
echo "Configuring GPG agent..."
mkdir -p /root/.gnupg
cat > /root/.gnupg/gpg-agent.conf <<'EOF'
# GPG agent configuration for SSH forwarding
default-cache-ttl 600
max-cache-ttl 7200
enable-ssh-support
pinentry-program /usr/bin/pinentry-curses
allow-loopback-pinentry
EOF

# Set proper permissions
chmod 600 /root/.gnupg/gpg-agent.conf

# Configure GPG to prefer using SSH keys if available
cat > /root/.gnupg/gpg.conf <<'EOF'
# GPG configuration
use-agent
no-tty
EOF

chmod 600 /root/.gnupg/gpg.conf

# Import git configuration if available
if [ -f "$CONF_DIR/.gitconfig" ]; then
    echo "Importing git configuration..."
    cp "$CONF_DIR/.gitconfig" /root/.gitconfig
    chmod 600 /root/.gitconfig
fi

# Set up signing key if available
if [ -f "$CONF_DIR/gpg-signing-key.txt" ]; then
    SIGNING_KEY=$(head -n 1 "$CONF_DIR/gpg-signing-key.txt" | tr -d '\n' | tr -d '\r')
    if [ -n "$SIGNING_KEY" ]; then
        echo "Configuring git to use GPG signing key: $SIGNING_KEY"
        git config --global user.signingkey "$SIGNING_KEY"
        git config --global commit.gpgsign true
        git config --global tag.gpgsign true
    fi
fi

echo "Post-create setup complete"


