#!/bin/bash

# Post-start script - runs after container starts
# This script is called from postStartCommand

# Set error handling, fail on any error during script execution
set -euo pipefail

echo "Running post-start setup..."

echo "Post-start setup complete"
