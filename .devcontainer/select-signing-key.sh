#!/usr/bin/env bash
set -euo pipefail

# Interactive SSH signing key selection
# This script lets you choose which SSH key to use for git signing

echo "🔑 SSH Signing Key Selection"
echo ""

# Check if SSH agent is available
if ! command -v ssh-add >/dev/null 2>&1 || ! ssh-add -l >/dev/null 2>&1; then
    echo "❌ SSH agent is not available or has no keys loaded"
    echo "   Run 'ssh-add ~/.ssh/your_key' on your host machine first"
    exit 1
fi

# Get all keys from the agent
mapfile -t KEYS < <(ssh-add -L)
KEY_COUNT=${#KEYS[@]}

if [ "$KEY_COUNT" -eq 0 ]; then
    echo "❌ No SSH keys found in agent"
    exit 1
fi

echo "Available SSH keys in your agent:"
echo ""

# Display keys with numbers
for i in "${!KEYS[@]}"; do
    KEY="${KEYS[$i]}"
    # Extract key type and fingerprint
    KEY_TYPE=$(echo "$KEY" | awk '{print $1}')
    KEY_COMMENT=$(echo "$KEY" | cut -d' ' -f3-)
    
    # Get fingerprint
    FINGERPRINT=$(ssh-add -l | sed -n "$((i+1))p" | awk '{print $1" "$2}')
    
    echo "[$((i+1))] $KEY_TYPE - $FINGERPRINT"
    if [ -n "$KEY_COMMENT" ]; then
        echo "    Comment: $KEY_COMMENT"
    fi
    echo ""
done

# Prompt for selection
if [ "$KEY_COUNT" -eq 1 ]; then
    echo "Only one key available, using it automatically."
    SELECTION=0
else
    read -p "Select a key [1-$KEY_COUNT]: " CHOICE
    
    # Validate input
    if ! [[ "$CHOICE" =~ ^[0-9]+$ ]] || [ "$CHOICE" -lt 1 ] || [ "$CHOICE" -gt "$KEY_COUNT" ]; then
        echo "❌ Invalid selection"
        exit 1
    fi
    
    SELECTION=$((CHOICE - 1))
fi

SELECTED_KEY="${KEYS[$SELECTION]}"
echo ""
echo "✅ Selected key: $(echo "$SELECTED_KEY" | awk '{print $1}') $(ssh-add -l | sed -n "$((SELECTION+1))p" | awk '{print $2}')"
echo ""

# Configure git
echo "Configuring git..."
git config --global gpg.format ssh
git config --global user.signingkey "key::$SELECTED_KEY"
git config --global commit.gpgsign true
git config --global tag.gpgsign true

# Create allowed_signers file for verification
CONF_DIR="/workspace/.devcontainer/.conf"
USER_EMAIL=$(git config user.email 2>/dev/null || echo "")

if [ -n "$USER_EMAIL" ]; then
    echo "$USER_EMAIL namespaces=\"git\" $SELECTED_KEY" > "$CONF_DIR/allowed_signers"
    git config --global gpg.ssh.allowedSignersFile "$CONF_DIR/allowed_signers"
    echo "✅ Git configured for SSH signing"
else
    echo "⚠️  Warning: git user.email not set, signature verification may not work"
    echo "   Run: git config --global user.email 'your.email@example.com'"
fi

echo ""
echo "🎉 Done! Your commits will now be signed with this SSH key."
echo ""
echo "📝 Next steps:"
echo "   1. Test signing: git commit --allow-empty -m 'test'"
echo "   2. Add key to GitHub: /workspace/.devcontainer/add-github-signing-key.sh"
echo ""





