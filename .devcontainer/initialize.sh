#!/bin/bash

# Initialize script - runs on host before container starts
# This script is called from initializeCommand

# Set error handling, fail on any error during script execution
set -euo pipefail

echo "Initializing devcontainer setup..."

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Call setup-user-conf.sh from the same directory
"$SCRIPT_DIR/setup-user-conf.sh"

# Extract GitHub token from host gh CLI (if available)
if command -v gh >/dev/null 2>&1; then
	if gh auth status >/dev/null 2>&1; then
		echo "Extracting GitHub token from host gh CLI..."
		DEVCONTAINER_GH_TOKEN=$(gh auth token 2>/dev/null || echo "")
		export DEVCONTAINER_GH_TOKEN
		if [ -n "$DEVCONTAINER_GH_TOKEN" ]; then
			echo "✅ GitHub token extracted (will be passed to container)"
		fi
	else
		echo "ℹ️  GitHub CLI not authenticated on host"
	fi
else
	echo "ℹ️  GitHub CLI not found on host"
fi

echo "Initialization complete"
