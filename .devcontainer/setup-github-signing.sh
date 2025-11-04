#!/usr/bin/env bash
set -euo pipefail

# Script to add SSH signing key to GitHub account
# This needs to be run inside the dev container

echo "=========================================="
echo "GitHub SSH Signing Key Setup"
echo "=========================================="
echo ""

# Check if gh is installed
if ! command -v gh >/dev/null 2>&1; then
    echo "❌ GitHub CLI (gh) is not installed"
    exit 1
fi

# Check if gh is authenticated
if ! gh auth status >/dev/null 2>&1; then
    echo "GitHub CLI is not authenticated. Let's log in..."
    echo ""
    gh auth login
    echo ""
fi

# Find the SSH signing key
SIGNING_KEY="/root/.ssh/signing-key.pub"

if [ ! -f "$SIGNING_KEY" ]; then
    echo "❌ No SSH signing key found at: $SIGNING_KEY"
    echo ""
    echo "The signing key should have been set up during container creation."
    echo "Try rebuilding the container."
    exit 1
fi

echo "Found SSH signing key:"
echo "----------------------------------------"
cat "$SIGNING_KEY"
echo "----------------------------------------"
echo ""

# Get the key title
KEY_EMAIL=$(git config --global user.email || echo "unknown")
KEY_TITLE="SSH Signing Key - ${KEY_EMAIL} - $(date +%Y-%m-%d)"

echo "Adding this key to GitHub as a signing key..."
echo "Title: $KEY_TITLE"
echo ""

# Add the key to GitHub
# Note: GitHub CLI will automatically set it as a signing key if we use the right flag
if gh ssh-key add "$SIGNING_KEY" --title "$KEY_TITLE" --type signing; then
    echo ""
    echo "✅ SSH signing key successfully added to GitHub!"
    echo ""
    echo "Your commits will now show as 'Verified' on GitHub."
    echo ""
    echo "Test it:"
    echo "  git commit --allow-empty -m 'test signed commit'"
    echo "  git push"
    echo ""
else
    echo ""
    echo "❌ Failed to add SSH key to GitHub"
    echo ""
    echo "You can add it manually:"
    echo "1. Go to: https://github.com/settings/keys"
    echo "2. Click 'New SSH key'"
    echo "3. Select 'Signing Key' as the key type"
    echo "4. Paste this key:"
    echo ""
    cat "$SIGNING_KEY"
    echo ""
    exit 1
fi


