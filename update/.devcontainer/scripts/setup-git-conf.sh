#!/bin/bash
set -e

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
else
	echo "No git config file found, skipping git setup"
	echo "Run this from host's project root: .devcontainer/setup-user-conf.sh"
fi

# Setup SSH public key for signing
HOST_SSH_PUBKEY="/workspace/.devcontainer/.conf/id_ed25519.pub"
CONTAINER_SSH_DIR="$HOME/.ssh"
if [ -f "$HOST_SSH_PUBKEY" ]; then
	echo "Applying SSH public key from $HOST_SSH_PUBKEY..."
	mkdir -p "$CONTAINER_SSH_DIR"
	cp "$HOST_SSH_PUBKEY" "$CONTAINER_SSH_DIR/id_ed25519.pub"
	echo "SSH public key installed at $CONTAINER_SSH_DIR/id_ed25519.pub"
else
	echo "Warning: No SSH public key found at $HOST_SSH_PUBKEY"
	echo "Git commit signing may not work without this file"
	echo "Run this from host's project root: .devcontainer/setup-user-conf.sh"
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
