#!/usr/bin/env bash
set -euo pipefail

# Post-attach script - runs every time you attach to the container
# This script is called from postAttachCommand

echo "Running post-attach setup..."
echo ""

# Setup SSH agent socket forwarding
# VS Code Dev Containers automatically forwards SSH_AUTH_SOCK when available
# This works across macOS, Linux, and Windows

if [ -n "${SSH_AUTH_SOCK:-}" ]; then
    if [ -S "$SSH_AUTH_SOCK" ]; then
        echo "✓ SSH agent socket available at: $SSH_AUTH_SOCK"
        
        # Update shell profile to persist SSH_AUTH_SOCK
        if ! grep -q "SSH Agent forwarding" /root/.bashrc 2>/dev/null; then
            cat >> /root/.bashrc <<'BASHRC_EOF'

# SSH Agent forwarding (added by devcontainer)
if [ -n "${SSH_AUTH_SOCK:-}" ]; then
    export SSH_AUTH_SOCK="${SSH_AUTH_SOCK}"
fi
BASHRC_EOF
        fi
        
    else
        echo "⚠ SSH_AUTH_SOCK is set but socket doesn't exist: $SSH_AUTH_SOCK"
    fi
else
    echo "⚠ SSH_AUTH_SOCK not set. SSH agent forwarding may not be available."
    echo "  Make sure ssh-agent is running on your host system."
fi

# Test SSH agent
if [ -n "${SSH_AUTH_SOCK:-}" ] && command -v ssh-add >/dev/null 2>&1; then
    echo ""
    echo "Testing SSH agent..."
    if ssh-add -l >/dev/null 2>&1; then
        KEY_COUNT=$(ssh-add -l | wc -l)
        echo "✓ SSH agent is working with $KEY_COUNT key(s):"
        ssh-add -l | sed 's/^/  /'
    else
        EXIT_CODE=$?
        if [ $EXIT_CODE -eq 1 ]; then
            echo "⚠ SSH agent is reachable but has no identities loaded"
            echo "  Run 'ssh-add' on your host to add keys"
        else
            echo "⚠ SSH agent error (exit code: $EXIT_CODE)"
        fi
    fi
fi

# Configure Git SSH signing
echo ""
echo "Configuring git SSH signing..."

# Set SSH signing format and enable signing
git config --global gpg.format ssh
git config --global commit.gpgsign true
git config --global tag.gpgsign true

# Check if signing key is already configured
EXISTING_KEY=$(git config --global user.signingkey 2>/dev/null || echo "")

if [ -n "$EXISTING_KEY" ]; then
    echo "✓ Git signing key already configured"
    
    # Verify the key is in the agent
    if [ -n "${SSH_AUTH_SOCK:-}" ] && command -v ssh-add >/dev/null 2>&1 && ssh-add -l >/dev/null 2>&1; then
        # Extract the key from config (remove "key::" prefix if present)
        if [[ "$EXISTING_KEY" == key::* ]]; then
            CONFIGURED_KEY_DATA="${EXISTING_KEY#key::}"
            # Check if this key is in the agent
            if ssh-add -L | grep -qF "$(echo "$CONFIGURED_KEY_DATA" | awk '{print $2}')"; then
                echo "✓ Configured key is available in SSH agent"
            else
                echo "⚠️  Warning: Configured key not found in SSH agent"
                echo "   Run: /workspace/.devcontainer/select-signing-key.sh"
            fi
        fi
    fi
else
    # No key configured, set one up
    if [ -n "${SSH_AUTH_SOCK:-}" ] && command -v ssh-add >/dev/null 2>&1 && ssh-add -l >/dev/null 2>&1; then
        KEY_COUNT=$(ssh-add -l | wc -l)
        
        if [ "$KEY_COUNT" -eq 1 ]; then
            # Only one key, use it automatically
            FIRST_KEY=$(ssh-add -L | head -1)
            
            git config --global user.signingkey "key::$FIRST_KEY"
            
            # Create allowed_signers file for verification
            CONF_DIR="/workspace/.devcontainer/.conf"
            USER_EMAIL=$(git config user.email 2>/dev/null || echo "")
            
            if [ -n "$USER_EMAIL" ]; then
                echo "$USER_EMAIL namespaces=\"git\" $FIRST_KEY" > "$CONF_DIR/allowed_signers"
                git config --global gpg.ssh.allowedSignersFile "$CONF_DIR/allowed_signers"
                
                echo "✓ Git configured with your SSH key"
                echo "  Fingerprint: $(ssh-add -l | head -1 | awk '{print $1" "$2}')"
            fi
        else
            # Multiple keys available
            echo "ℹ️  You have $KEY_COUNT SSH keys available"
            echo ""
            echo "   To choose which key to use for signing, run:"
            echo "   /workspace/.devcontainer/select-signing-key.sh"
            echo ""
            echo "   (Using first key for now)"
            
            # Use first key as default
            FIRST_KEY=$(ssh-add -L | head -1)
            git config --global user.signingkey "key::$FIRST_KEY"
            
            CONF_DIR="/workspace/.devcontainer/.conf"
            USER_EMAIL=$(git config user.email 2>/dev/null || echo "")
            if [ -n "$USER_EMAIL" ]; then
                echo "$USER_EMAIL namespaces=\"git\" $FIRST_KEY" > "$CONF_DIR/allowed_signers"
                git config --global gpg.ssh.allowedSignersFile "$CONF_DIR/allowed_signers"
            fi
        fi
    else
        echo "⚠️  SSH agent not available or no keys loaded"
        echo "   Add keys on your host: ssh-add ~/.ssh/your_key"
    fi
fi

echo ""
echo "Post-attach setup complete"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📝 Useful commands:"
echo ""
echo "   Choose signing key (if you have multiple):"
echo "   /workspace/.devcontainer/select-signing-key.sh"
echo ""
echo "   Add signing key to GitHub (requires gh CLI):"
echo "   /workspace/.devcontainer/add-github-signing-key.sh"
echo ""
echo "   Test SSH signing:"
echo "   git commit --allow-empty -m 'test' && git log --show-signature -1"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"


