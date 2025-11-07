#!/bin/bash
set -euo pipefail

echo "Setting up project configuration..."

# Get project name from directory name
PROJECT_DIR=$(basename "$(pwd)")
PROJECT_NAME="${PROJECT_DIR// /_}"  # Replace spaces with underscores
PROJECT_NAME="${PROJECT_NAME//-/_}"  # Replace hyphens with underscores
PROJECT_NAME=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]')  # Lowercase

echo "Detected project name: $PROJECT_NAME"

# Update pyproject.toml with actual project name
if [ -f "pyproject.toml" ]; then
    sed -i.bak "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" pyproject.toml
    rm pyproject.toml.bak 2>/dev/null || true
    echo "Updated pyproject.toml with project name"
fi

# Update src/__init__.py
if [ -f "src/__init__.py" ]; then
    sed -i.bak "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" src/__init__.py
    rm src/__init__.py.bak 2>/dev/null || true
    echo "Updated src/__init__.py with project name"
fi

# Initialize uv project
if command -v uv &> /dev/null; then
    echo "Syncing dependencies with uv..."
    uv sync
fi

echo "Project setup complete"
