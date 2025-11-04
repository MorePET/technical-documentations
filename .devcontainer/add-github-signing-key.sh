#!/usr/bin/env bash
set -euo pipefail

# Add SSH signing key to GitHub using GitHub CLI
# This script extracts your configured signing key and adds it to GitHub

echo "🔐 GitHub SSH Signing Key Setup"
echo ""

# Check if gh CLI is available
if ! command -v gh >/dev/null 2>&1; then
    echo "❌ GitHub CLI (gh) is not installed"
    echo ""
    echo "To install:"
    echo "  macOS:   brew install gh"
    echo "  Linux:   https://github.com/cli/cli/blob/trunk/docs/install_linux.md"
    echo "  Windows: winget install --id GitHub.cli"
    echo ""
    echo "Manual alternative: Copy your key and add it at:"
    echo "  https://github.com/settings/keys"
    exit 1
fi

# Check if authenticated
if ! gh auth status >/dev/null 2>&1; then
    echo "❌ Not authenticated with GitHub"
    echo "   Run: gh auth login"
    exit 1
fi

# Get the configured signing key
SIGNING_KEY=$(git config --global user.signingkey 2>/dev/null || echo "")

if [ -z "$SIGNING_KEY" ]; then
    echo "❌ No signing key configured in git"
    echo "   Run: /workspace/.devcontainer/select-signing-key.sh"
    exit 1
fi

# Extract the actual key (remove "key::" prefix if present)
if [[ "$SIGNING_KEY" == key::* ]]; then
    PUBLIC_KEY="${SIGNING_KEY#key::}"
else
    # It's a file path, read the file
    if [ -f "$SIGNING_KEY" ]; then
        PUBLIC_KEY=$(cat "$SIGNING_KEY")
    else
        echo "❌ Signing key file not found: $SIGNING_KEY"
        exit 1
    fi
fi

# Extract key type and fingerprint for display
KEY_TYPE=$(echo "$PUBLIC_KEY" | awk '{print $1}')
KEY_FINGERPRINT=$(echo "$PUBLIC_KEY" | ssh-keygen -lf - 2>/dev/null | awk '{print $2}' || echo "unknown")

echo "Current signing key:"
echo "  Type: $KEY_TYPE"
echo "  Fingerprint: $KEY_FINGERPRINT"
echo ""

# Check if this key is already added
echo "Checking if key is already on GitHub..."
EXISTING_KEYS=$(gh ssh-key list --format json 2>/dev/null || echo "[]")

# Extract just the key part (without comment) for comparison
PUBLIC_KEY_PART=$(echo "$PUBLIC_KEY" | awk '{print $1" "$2}')

if echo "$EXISTING_KEYS" | grep -q "$(echo "$PUBLIC_KEY_PART" | awk '{print $2}')"; then
    echo "⚠️  This key appears to already exist on GitHub"
    read -p "Continue anyway? [y/N]: " CONTINUE
    if [[ ! "$CONTINUE" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
fi

# Create a temporary file for the key
TEMP_KEY=$(mktemp)
echo "$PUBLIC_KEY" > "$TEMP_KEY"

# Add the key to GitHub
echo ""
echo "Adding key to GitHub..."

# Use git user email as title
KEY_TITLE="SSH Signing Key - $(git config user.email 2>/dev/null || hostname)"

if gh ssh-key add "$TEMP_KEY" --type signing --title "$KEY_TITLE" 2>&1; then
    echo ""
    echo "✅ SSH signing key successfully added to GitHub!"
    echo ""
    echo "🎉 Your commits will now show as 'Verified' on GitHub"
    echo ""
    echo "View your keys at: https://github.com/settings/keys"
else
    ERROR=$?
    echo ""
    echo "❌ Failed to add key to GitHub"
    echo ""
    echo "Manual steps:"
    echo "1. Copy your public key:"
    echo ""
    echo "$PUBLIC_KEY"
    echo ""
    echo "2. Go to: https://github.com/settings/keys"
    echo "3. Click 'New SSH key'"
    echo "4. Select 'Signing Key' as the key type"
    echo "5. Paste the key above"
    rm -f "$TEMP_KEY"
    exit $ERROR
fi

# Clean up
rm -f "$TEMP_KEY"

# Offer to test
echo ""
read -p "Test signing with a commit? [y/N]: " TEST
if [[ "$TEST" =~ ^[Yy]$ ]]; then
    echo ""
    git commit --allow-empty -m "Test signed commit" && \
    git log --show-signature -1 && \
    echo "" && \
    echo "✅ Commit created and signed! Push to GitHub to see the 'Verified' badge."
fi





