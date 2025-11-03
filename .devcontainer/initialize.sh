#!/usr/bin/env bash
set -euo pipefail

# Initialize script - runs on host before container starts
# This script is called from initializeCommand

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONF_DIR="$SCRIPT_DIR/.conf"

echo "Initializing devcontainer setup..."

# Create configuration directory
mkdir -p "$CONF_DIR"

# Export git configuration
echo "Exporting git configuration..."
GITCONFIG_OUT="$CONF_DIR/.gitconfig"
GITCONFIG_GLOBAL="$CONF_DIR/.gitconfig.global"

if command -v git >/dev/null 2>&1; then
    git config --list --global --include >"$GITCONFIG_GLOBAL" 2>/dev/null || true
    
    # Parse key-value pairs and reconstruct .gitconfig with correct section/subsection syntax
    awk -F= '
      function print_section(section, subsection) {
        if (section != "") {
          if (subsection != "") {
            print "[" section " \"" subsection "\"]"
          } else {
            print "[" section "]"
          }
        }
      }
      {
        key = $1
        val = $2
        if (key ~ /^includeif\./) next
        split(key, arr, ".")
        section = arr[1]
        # Handle subsection (e.g., filter.lfs.clean)
        if (length(arr) > 2) {
          subsection = arr[2]
          subkey = arr[3]
          # Special case for diff.lfs.textconv
          if (section == "diff" && subsection == "lfs" && subkey == "textconv") {
            if (section != last_section || subsection != last_subsection) {
              if (last_section != "") print ""
              print_section(section, subsection)
              last_section = section
              last_subsection = subsection
            }
            print "    textconv = " val
            next
          }
          # General case for filter.lfs.*
          if (section == "filter" && subsection == "lfs") {
            if (section != last_section || subsection != last_subsection) {
              if (last_section != "") print ""
              print_section(section, subsection)
              last_section = section
              last_subsection = subsection
            }
            print "    " subkey " = " val
            next
          }
        }
        # Handle normal section.key
        subsection = ""
        if (section != last_section || subsection != last_subsection) {
          if (last_section != "") print ""
          print_section(section, subsection)
          last_section = section
          last_subsection = subsection
        }
        # Remove section. from key
        subkey = substr(key, length(section) + 2)
        print "    " subkey " = " val
      }
    ' "$GITCONFIG_GLOBAL" >"$GITCONFIG_OUT" 2>/dev/null || true
    
    echo "Exported git configuration to $GITCONFIG_OUT"
fi

# Export GPG public keys
echo "Exporting GPG keys..."
if command -v gpg >/dev/null 2>&1 && gpg --list-keys >/dev/null 2>&1; then
    gpg --export --armor >"$CONF_DIR/gpg-public-keys.asc" 2>/dev/null || true
    gpg --export-ownertrust >"$CONF_DIR/gpg-ownertrust.txt" 2>/dev/null || true
    
    # Export GPG key IDs for signing (exclude expired keys)
    # Use machine-readable format to reliably filter out expired keys
    gpg --list-secret-keys --keyid-format LONG --with-colons 2>/dev/null | \
        awk -F: '/^sec:/ && $2 != "e" && $2 != "r" {print $5}' >"$CONF_DIR/gpg-signing-key.txt" 2>/dev/null || true
    
    echo "Exported GPG keys to $CONF_DIR/"
else
    echo "No GPG keys found or GPG not available. Skipping GPG export."
fi

# Detect OS and export SSH_AUTH_SOCK path for documentation
if [[ -n "${SSH_AUTH_SOCK:-}" ]]; then
    echo "SSH_AUTH_SOCK is set to: $SSH_AUTH_SOCK"
    echo "$SSH_AUTH_SOCK" >"$CONF_DIR/ssh-auth-sock.txt"
else
    echo "Warning: SSH_AUTH_SOCK not set. SSH agent forwarding may not work."
fi

echo "Initialization complete"
