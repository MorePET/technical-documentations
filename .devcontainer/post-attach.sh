#!/usr/bin/env bash
set -euo pipefail

# Post-attach script - runs every time you attach to the container
# This script is called from postAttachCommand

echo "Running post-attach setup..."

# Setup SSH agent socket forwarding
# VS Code Dev Containers automatically forwards SSH_AUTH_SOCK when available
# This works across macOS, Linux, and Windows

if [ -n "${SSH_AUTH_SOCK:-}" ]; then
    if [ -S "$SSH_AUTH_SOCK" ]; then
        echo "✓ SSH agent socket available at: $SSH_AUTH_SOCK"
        
        # Configure GPG to use SSH agent for authentication
        # This allows GPG to use SSH keys for signing when available
        export GPG_TTY=$(tty)
        
        # Update shell profile to persist SSH_AUTH_SOCK and GPG_TTY
        cat >> /root/.bashrc <<'BASHRC_EOF'

# SSH Agent forwarding (added by devcontainer)
if [ -n "${SSH_AUTH_SOCK:-}" ]; then
    export SSH_AUTH_SOCK="${SSH_AUTH_SOCK}"
    export GPG_TTY=$(tty)
fi
BASHRC_EOF
        
    else
        echo "⚠ SSH_AUTH_SOCK is set but socket doesn't exist: $SSH_AUTH_SOCK"
    fi
else
    echo "⚠ SSH_AUTH_SOCK not set. SSH agent forwarding may not be available."
    echo "  Make sure ssh-agent is running on your host system."
fi

# Configure GPG agent forwarding if host socket is available
if [ -S "/root/.gnupg/S.gpg-agent.host" ]; then
    echo "Setting up GPG agent forwarding from host..."
    # Kill any local agent
    gpgconf --kill gpg-agent 2>/dev/null || true
    # Remove local socket if it exists
    rm -f /root/.gnupg/S.gpg-agent
    # Create a script that forwards to the host socket
    cat > /root/.gnupg/start-forwarded-agent.sh <<'AGENT_EOF'
#!/bin/bash
# Forward all requests to the host agent socket
socat UNIX-LISTEN:/root/.gnupg/S.gpg-agent,fork,unlink-early UNIX-CONNECT:/root/.gnupg/S.gpg-agent.host &
AGENT_EOF
    chmod +x /root/.gnupg/start-forwarded-agent.sh
    # Start the forwarding
    if command -v socat >/dev/null 2>&1; then
        pkill -f "socat.*S.gpg-agent" 2>/dev/null || true
        nohup socat UNIX-LISTEN:/root/.gnupg/S.gpg-agent,fork,unlink-early UNIX-CONNECT:/root/.gnupg/S.gpg-agent.host >/dev/null 2>&1 &
        echo "✓ GPG agent forwarding active"
    else
        # Fallback: just symlink (may not work as well but better than nothing)
        ln -sf /root/.gnupg/S.gpg-agent.host /root/.gnupg/S.gpg-agent
        echo "✓ GPG agent socket linked (socat not available for proper forwarding)"
    fi
else
    # No host socket, restart local GPG agent
    if command -v gpgconf >/dev/null 2>&1; then
        echo "Restarting local GPG agent..."
        gpgconf --kill gpg-agent 2>/dev/null || true
        # GPG agent will auto-start on first use
    fi
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

# Test GPG
echo ""
echo "Testing GPG..."
if command -v gpg >/dev/null 2>&1; then
    KEY_COUNT=$(gpg --list-keys 2>/dev/null | grep -c "^pub" || echo "0")
    if [ "$KEY_COUNT" -gt 0 ]; then
        echo "✓ GPG has $KEY_COUNT public key(s) available:"
        gpg --list-keys --keyid-format LONG 2>/dev/null | grep -E "^(pub|uid)" | sed 's/^/  /' || true
        
        # Check if git is configured for GPG signing
        SIGNING_KEY=$(git config --global user.signingkey 2>/dev/null || echo "")
        if [ -n "$SIGNING_KEY" ]; then
            echo "✓ Git is configured to use signing key: $SIGNING_KEY"
        else
            echo "ℹ Git signing key not configured"
        fi
    else
        echo "⚠ No GPG keys found"
        echo "  Keys should be imported during container creation"
    fi
else
    echo "⚠ GPG not available"
fi

echo ""
echo "Post-attach setup complete"
