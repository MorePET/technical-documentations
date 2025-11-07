#!/bin/bash

# Post-attach script - runs when container is attached
# This script is called from postAttachCommand

# Set error handling, fail on any error during script execution
set -euo pipefail

echo "Running post-attach setup..."

# Set up git configuration
/workspace/.devcontainer/scripts/setup-git-conf.sh

# Verify GitHub CLI authentication status
echo "Verifying GitHub CLI authentication..."
if gh auth status >/dev/null 2>&1; then
    echo "✅ GitHub CLI authenticated"
else
    echo "⚠️  GitHub CLI is not authenticated"
    echo "   Run this command to authenticate:"
    echo "   gh auth login --web"
    echo ""
fi

echo "Post-attach setup complete"
