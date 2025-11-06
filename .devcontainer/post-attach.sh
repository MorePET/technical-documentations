#!/bin/bash

# Post-attach script - runs when container is attached
# This script is called from postAttachCommand

# Set error handling, fail on any error during script execution
set -euo pipefail

echo "Running post-attach setup..."

# Set up git configuration
/workspace/.devcontainer/scripts/setup-git-conf.sh

# Verify GitHub CLI authentication status (common script for SOLID principle)
/workspace/.devcontainer/scripts/setup-gh-auth.sh || true  # Don't fail if auth fails

echo "Post-attach setup complete"
