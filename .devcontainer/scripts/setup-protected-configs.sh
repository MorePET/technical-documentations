#!/bin/bash
set -euo pipefail

echo "🔒 Protecting linting configuration files..."

# Define protected files
PROTECTED_FILES=(
    ".pre-commit-config.yaml"
    "pyproject.toml"
    ".hadolint.yaml"
    ".checkmake.ini"
    ".yamllint"
)

# Set read-only permissions
cd /workspace
for file in "${PROTECTED_FILES[@]}"; do
    if [ -f "$file" ]; then
        chmod 444 "$file"
        echo "  ✓ Protected: $file (444 read-only)"
    else
        echo "  ⚠ Skipped: $file (not found)"
    fi
done

# Create helper script for editing protected files
cat > /usr/local/bin/edit-protected << 'EOF'
#!/bin/bash
# Helper script to edit protected config files
# Usage: edit-protected <file>

if [ $# -eq 0 ]; then
    echo "Usage: edit-protected <file>"
    echo ""
    echo "Protected configuration files:"
    echo "  .pre-commit-config.yaml  - Pre-commit hooks"
    echo "  pyproject.toml           - Python project config"
    echo "  .hadolint.yaml           - Containerfile linting"
    echo "  .checkmake.ini           - Makefile linting"
    echo "  .yamllint                - YAML linting"
    exit 1
fi

FILE="$1"
EDITOR="${EDITOR:-vim}"

if [ ! -f "$FILE" ]; then
    echo "Error: File not found: $FILE"
    exit 1
fi

# Temporarily unlock
chmod 644 "$FILE"
echo "🔓 Unlocked: $FILE"

# Edit
$EDITOR "$FILE"

# Re-lock
chmod 444 "$FILE"
echo "🔒 Re-protected: $FILE"
EOF

chmod +x /usr/local/bin/edit-protected

echo ""
echo "✅ Configuration protection complete!"
echo ""
echo "📋 Security Model:"
echo "   • Warning comments in each protected file"
echo "   • 444 permissions (read-only for ALL users)"
echo "   • Auto-fixing linters FAIL → manual intervention required"
echo "   • Both AI and humans need explicit chmod to modify"
echo ""
echo "🔧 To edit protected files:"
echo "   edit-protected <filename>"
echo ""
echo "   Or manually:"
echo "   chmod 644 <file> && vim <file> && chmod 444 <file>"
echo ""

