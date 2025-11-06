#!/bin/bash

# Post-attach script - runs when container is attached
# This script is called from postAttachCommand

# Set error handling, fail on any error during script execution
set -euo pipefail

echo "Running post-attach setup..."

# Note: Git configuration and pre-commit setup are now handled in post-create.sh
# This script can be used for per-attach operations if needed in the future

echo "Post-attach setup complete"
