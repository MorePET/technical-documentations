#!/bin/bash
set -euo pipefail

echo "Setting up pre-commit hooks..."

if [ -f "/workspace/.pre-commit-config.yaml" ]; then
    echo "Installing pre-commit hooks (this may take a few minutes)..."
    cd /workspace
    pre-commit install-hooks || {
        echo "⚠️  Pre-commit install failed"
        echo "    You can manually run 'pre-commit install-hooks' later"
        exit 1
    }
    echo "Pre-commit hooks installed successfully"
else
    echo "No .pre-commit-config.yaml found, skipping"
fi
