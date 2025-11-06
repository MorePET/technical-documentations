#!/bin/bash
set -euo pipefail

echo "Running post-create setup..."

SCRIPTS_DIR="/workspace/.devcontainer/scripts"

# Initialize git repository if needed
"$SCRIPTS_DIR/setup-git-init.sh"

# Set up git configuration
"$SCRIPTS_DIR/setup-git-conf.sh"

# Set up GitHub CLI authentication (common script for SOLID principle)
"$SCRIPTS_DIR/setup-gh-auth.sh" || true  # Don't fail if auth fails

# Set up project with dynamic naming
"$SCRIPTS_DIR/setup-project.sh"

# Install pre-commit hooks
"$SCRIPTS_DIR/setup-precommit.sh"

echo "Post-create setup complete"
