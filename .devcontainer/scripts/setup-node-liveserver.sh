#!/bin/bash
set -euo pipefail

echo "======================================"
echo "Setting up Node.js and live-server..."
echo "======================================"

# Check if Node.js is already installed
if command -v node >/dev/null 2>&1; then
    echo "✅ Node.js already installed: $(node --version)"
else
    echo "📦 Installing Node.js and npm..."
    apt-get update -qq
    apt-get install -y nodejs npm >/dev/null 2>&1
    echo "✅ Node.js installed: $(node --version)"
    echo "✅ npm installed: $(npm --version)"
fi

# Check if live-server is already installed
if command -v live-server >/dev/null 2>&1; then
    echo "✅ live-server already installed: $(live-server --version)"
else
    echo "📦 Installing live-server globally..."
    npm install -g live-server >/dev/null 2>&1
    echo "✅ live-server installed: $(live-server --version)"
fi

echo ""
echo "======================================"
echo "✨ Node.js & live-server setup complete!"
echo "======================================"
echo ""
echo "Benefits over Python server:"
echo "  • Auto-reload on file changes"
echo "  • Better concurrent request handling"
echo "  • No Content-Length mismatch issues"
echo "  • Keep-alive connections"
echo "  • Industry-standard dev server"
echo ""
