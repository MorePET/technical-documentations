#!/bin/bash
set -euo pipefail

echo "Running post-create setup..."

SCRIPTS_DIR="/workspace/.devcontainer/scripts"

# Initialize git repository if needed
"$SCRIPTS_DIR/setup-git-init.sh"

# Set up git configuration
"$SCRIPTS_DIR/setup-git-conf.sh"

# Set up GitHub CLI authentication (if interactive)
echo "Checking GitHub CLI authentication..."
if ! gh auth status >/dev/null 2>&1; then
    # Check if we're in an automated/test environment
    # CI=true is set by most CI systems, DEVCONTAINER_TEST can be set by our tests
    if [ "${CI:-false}" = "true" ] || [ "${DEVCONTAINER_TEST:-false}" = "true" ]; then
        # Automated environment - skip authentication
        echo "ℹ️  GitHub CLI not authenticated (automated environment)"
        echo "   To authenticate later, run: gh auth login --web"
    elif [ -t 0 ] && [ -n "$TERM" ]; then
        # Interactive session with terminal - prompt for authentication
        echo "⚠️  GitHub CLI is not authenticated"
        echo "Please authenticate with GitHub:"
        echo ""
        gh auth login --web
        echo ""
        if gh auth status >/dev/null 2>&1; then
            echo "✅ GitHub CLI authenticated successfully"
        else
            echo "❌ GitHub CLI authentication failed"
            echo "You can authenticate later by running: gh auth login --web"
        fi
    else
        # Non-interactive (e.g., automated tests) - skip authentication
        echo "ℹ️  GitHub CLI not authenticated (non-interactive session)"
        echo "   To authenticate later, run: gh auth login --web"
    fi
else
    echo "✅ GitHub CLI already authenticated"
fi

# Set up project with dynamic naming
"$SCRIPTS_DIR/setup-project.sh"

# Install pre-commit hooks
"$SCRIPTS_DIR/setup-precommit.sh"

echo "Post-create setup complete"
