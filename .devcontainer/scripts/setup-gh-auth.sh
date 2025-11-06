#!/bin/bash
set -euo pipefail

# Script to handle GitHub CLI authentication
# This is a common script used by both post-create.sh and post-attach.sh
# to avoid code duplication (SOLID: Single Responsibility Principle)

echo "Checking GitHub CLI authentication..."

# Priority 1: Check for token file from host
TOKEN_FILE="/workspace/.devcontainer/.conf/gh_token"
if [ -f "$TOKEN_FILE" ]; then
	echo "Found GitHub token from host, authenticating..."

	# Read token from file
	DEVCONTAINER_GH_TOKEN=$(cat "$TOKEN_FILE")

	# Immediately remove token file for security
	rm -f "$TOKEN_FILE"

	# Use gh auth login with token to persist authentication
	if echo "$DEVCONTAINER_GH_TOKEN" | gh auth login --with-token --hostname github.com --git-protocol ssh 2>/dev/null; then
		echo "✅ GitHub CLI authenticated via host token"

		# Verify authentication worked
		if gh auth status >/dev/null 2>&1; then
			echo "✅ Authentication persisted to container"
			exit 0
		fi
	else
		echo "⚠️  Token authentication failed, falling back to other methods..."
	fi
fi

# Priority 2: Check if already authenticated
if gh auth status >/dev/null 2>&1; then
	echo "✅ GitHub CLI already authenticated"
	exit 0
fi

# Priority 3: Fall back to interactive authentication
# Check if we're in an automated/test environment
if [ "${CI:-false}" = "true" ] || [ "${DEVCONTAINER_TEST:-false}" = "true" ]; then
	# Automated environment - skip authentication
	echo "ℹ️  GitHub CLI not authenticated (automated environment)"
	echo "   To authenticate later, run: gh auth login --web"
	exit 0
fi

# Check if we're in an interactive session
if [ -t 0 ] && [ -n "$TERM" ]; then
	# Interactive session with terminal - prompt for authentication
	echo "⚠️  GitHub CLI is not authenticated"
	echo ""
	echo "=========================================="
	echo "⚠️  IMPORTANT: Container HTTP Limitation"
	echo "=========================================="
	echo ""
	echo "We are running inside a container. When GitHub provides"
	echo "an authentication URL, pressing Enter to open it in a"
	echo "browser will FAIL because containers don't have direct"
	echo "access to your host's browser."
	echo ""
	echo "Instead:"
	echo "  1. Copy the authentication URL shown below"
	echo "  2. Manually paste it into your host browser"
	echo "  3. Complete the authentication process"
	echo "  4. Enter the verification code when prompted"
	echo ""
	echo "=========================================="

	# Attempt authentication (use default https protocol for interactive)
	gh auth login --web
	echo ""

	# Verify authentication succeeded
	if gh auth status >/dev/null 2>&1; then
		echo "✅ GitHub CLI authenticated successfully"
		exit 0
	else
		echo "❌ GitHub CLI authentication failed"
		echo "You can authenticate later by running: gh auth login --web"
		exit 1
	fi
else
	# Non-interactive (e.g., automated tests) - skip authentication
	echo "ℹ️  GitHub CLI not authenticated (non-interactive session)"
	echo "   To authenticate later, run: gh auth login --web"
	exit 0
fi
