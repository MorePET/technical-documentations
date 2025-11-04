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

# Export SSH public keys for git signing
echo "Exporting SSH keys..."
SSH_KEY_FOUND=false

# Check common SSH key locations
for KEY_TYPE in id_ed25519 id_rsa id_ecdsa; do
    if [ -f "$HOME/.ssh/${KEY_TYPE}.pub" ]; then
        cp "$HOME/.ssh/${KEY_TYPE}.pub" "$CONF_DIR/ssh-signing-key.pub" 2>/dev/null || true
        echo "$HOME/.ssh/${KEY_TYPE}.pub" > "$CONF_DIR/ssh-key-path.txt"
        echo "Found SSH key: $HOME/.ssh/${KEY_TYPE}.pub"
        SSH_KEY_FOUND=true
        break
    fi
done

if [ "$SSH_KEY_FOUND" = false ]; then
    echo "⚠ No SSH keys found in ~/.ssh/"
    echo "  Common key names: id_ed25519, id_rsa, id_ecdsa"
    echo "  Generate one with: ssh-keygen -t ed25519 -C 'your.email@example.com'"
fi

# Check SSH agent
if [[ -n "${SSH_AUTH_SOCK:-}" ]]; then
    echo "✓ SSH_AUTH_SOCK is set to: $SSH_AUTH_SOCK"
    echo "$SSH_AUTH_SOCK" >"$CONF_DIR/ssh-auth-sock.txt"
    
    # Test if ssh-add works
    if command -v ssh-add >/dev/null 2>&1; then
        if ssh-add -l >/dev/null 2>&1; then
            KEY_COUNT=$(ssh-add -l | wc -l)
            echo "✓ SSH agent has $KEY_COUNT key(s) loaded"
        else
            echo "⚠ SSH agent found but no keys loaded. Run 'ssh-add' to add keys."
        fi
    fi
else
    echo "⚠ SSH_AUTH_SOCK not set. SSH agent forwarding may not work."
    echo "  Make sure ssh-agent is running on your host system."
fi

echo "Initialization complete"
