#!/bin/bash
set -euo pipefail

# Script to set up git configuration and hooks within the dev container
# This is used to ensure that the git configuration and hooks are consistent
# between the host and the dev container.
# The script is called from the post-attach.sh script.

# Setup git configuration
echo "Setting up git configuration..."
HOST_GITCONFIG_FILE="/workspace/.devcontainer/.conf/.gitconfig"
CONTAINER_GITCONFIG_FILE=$HOME"/.gitconfig"
if [ -f "$HOST_GITCONFIG_FILE" ]; then
	echo "Applying git configuration from $HOST_GITCONFIG_FILE..."
	cp "$HOST_GITCONFIG_FILE" "$CONTAINER_GITCONFIG_FILE"

	# Fix paths from host to container locations
	echo "Fixing git configuration paths for container environment..."
	# Note: user.signingkey will be set later using SSH agent (key:: prefix)
	git config --global gpg.ssh.allowedsignersfile "$HOME/.config/git/allowed-signers"
	echo "Git configuration paths updated for container"
else
	echo "No git config file found, skipping git setup"
	echo "Run this from host's project root: .devcontainer/setup-user-conf.sh"
fi

# Setup SSH public key for signing using SSH agent
# Check if SSH agent is available and has keys loaded
if [ -n "$SSH_AUTH_SOCK" ] && ssh-add -L >/dev/null 2>&1; then
	echo "SSH agent detected with keys loaded"
	# Get the first ED25519 key from the agent (typically the signing key)
	SSH_AGENT_KEY=$(ssh-add -L | grep "ssh-ed25519" | head -1)
	if [ -n "$SSH_AGENT_KEY" ]; then
		git config --global user.signingkey "key::$SSH_AGENT_KEY"
		echo "Git configured to use SSH agent key for signing: $(echo "$SSH_AGENT_KEY" | awk '{print $2}' | cut -c1-20)..."
	else
		echo "Warning: No ED25519 key found in SSH agent"
	fi
else
	echo "Warning: SSH agent not available or no keys loaded"
	echo "Commit/tag signing will not work without SSH agent forwarding"
fi

# Also copy the public key file for reference (if available)
HOST_SSH_PUBKEY="/workspace/.devcontainer/.conf/id_ed25519_github.pub"
CONTAINER_SSH_DIR="$HOME/.ssh"
if [ -f "$HOST_SSH_PUBKEY" ]; then
	mkdir -p "$CONTAINER_SSH_DIR"
	cp "$HOST_SSH_PUBKEY" "$CONTAINER_SSH_DIR/id_ed25519_github.pub"
	echo "SSH public key file copied to $CONTAINER_SSH_DIR/id_ed25519_github.pub (for reference)"
fi

# Setup allowed-signers file
HOST_ALLOWED_SIGNERS_FILE="/workspace/.devcontainer/.conf/allowed-signers"
CONTAINER_ALLOWED_SIGNERS_DIR="$HOME/.config/git"
if [ -f "$HOST_ALLOWED_SIGNERS_FILE" ]; then
	echo "Applying allowed-signers file from $HOST_ALLOWED_SIGNERS_FILE..."
	mkdir -p "$CONTAINER_ALLOWED_SIGNERS_DIR"
	cp "$HOST_ALLOWED_SIGNERS_FILE" "$CONTAINER_ALLOWED_SIGNERS_DIR/allowed-signers"
	echo "Allowed-signers file installed at $CONTAINER_ALLOWED_SIGNERS_DIR/allowed-signers"
else
	echo "Warning: No allowed-signers file found at $HOST_ALLOWED_SIGNERS_FILE"
	echo "Git signature verification may not work without this file"
	echo "Run this from host's project root: .devcontainer/setup-user-conf.sh"
fi

# Setup git hooks
echo "Setting up git hooks..."
if [ -d .githooks ]; then
	git config core.hooksPath .githooks
	echo "Git hooks configured to use .githooks directory"
else
	echo "No .githooks directory found, using default git hooks"
fi
