#!/usr/bin/env bash
set -euo pipefail

# Check if we're running inside the dev container
if [ "${IN_CONTAINER:-}" = "true" ]; then
	echo "This script must be run outside the container"
	exit 1
fi

CONF_DIR="$(dirname "$0")/.conf"
mkdir -p "$CONF_DIR"

echo "========================================"
echo "Devcontainer Prerequisites Validation"
echo "========================================"
echo ""

# Track overall success/failure
SETUP_FAILED=false
SETUP_WARNINGS=false

# Array to collect error messages
declare -a ERROR_MESSAGES
declare -a WARNING_MESSAGES
declare -a SETUP_INSTRUCTIONS

# 1. Check GHCR Authentication
echo "🔍 [1/5] Checking GitHub Container Registry (GHCR) authentication..."
echo "in the following explanation docker or podman are interchangeable"
if command -v docker >/dev/null 2>&1; then
	if docker info >/dev/null 2>&1; then
		# Try to check docker auth for ghcr.io
		if grep -q "ghcr.io" "$HOME/.docker/config.json" 2>/dev/null; then
			echo "   ✅ Docker authenticated to ghcr.io"
		else
			echo "   ⚠️  Docker not authenticated to ghcr.io"
			WARNING_MESSAGES+=("Docker not authenticated to ghcr.io")
			SETUP_INSTRUCTIONS+=("$(cat <<-'EOF'
				GHCR Authentication (Docker):
				  1. Create GitHub Personal Access Token:
				     https://github.com/settings/tokens/new
				     - Name: "GHCR Dev Container Access"
				     - Scope: read:packages ✅
				  2. Login to GHCR:
				     echo "YOUR_TOKEN" | docker login ghcr.io -u YOUR_GITHUB_USERNAME --password-stdin
				  3. Verify:
				     docker pull ghcr.io/morepet/containers/dev/typst:1.3-dev
			EOF
			)")
			SETUP_WARNINGS=true
		fi
	fi
elif command -v podman >/dev/null 2>&1; then
	AUTH_FILE="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/containers/auth.json"
	if [ -f "$AUTH_FILE" ] && grep -q "ghcr.io" "$AUTH_FILE" 2>/dev/null; then
		echo "   ✅ Podman authenticated to ghcr.io"
	else
		echo "   ⚠️  Podman not authenticated to ghcr.io"
		WARNING_MESSAGES+=("Podman not authenticated to ghcr.io")
		SETUP_INSTRUCTIONS+=("$(cat <<-'EOF'
			GHCR Authentication (Podman):
			  1. Create GitHub Personal Access Token:
			     https://github.com/settings/tokens/new
			     - Name: "GHCR Dev Container Access"
			     - Scope: read:packages ✅
			  2. Login to GHCR:
			     echo "YOUR_TOKEN" | podman login ghcr.io -u YOUR_GITHUB_USERNAME --password-stdin
			  3. Verify:
			     podman pull ghcr.io/morepet/containers/dev/typst:1.3-dev
		EOF
		)")
		SETUP_WARNINGS=true
	fi
else
	echo "   ❌ Neither Docker nor Podman found"
	ERROR_MESSAGES+=("Container runtime not found")
	SETUP_INSTRUCTIONS+=("Install Docker Desktop or Podman")
	SETUP_FAILED=true
fi
echo ""

# 2. Check SSH public key
echo "🔍 [2/5] Checking SSH public key..."
HOST_SSH_PUBKEY="$HOME/.ssh/id_ed25519_github.pub"
if [ -f "$HOST_SSH_PUBKEY" ]; then
	cp "$HOST_SSH_PUBKEY" "$CONF_DIR/id_ed25519_github.pub"
	echo "   ✅ SSH public key found and copied"
	echo "      From: $HOST_SSH_PUBKEY"
else
	echo "   ⚠️  SSH public key not found at $HOST_SSH_PUBKEY"
	WARNING_MESSAGES+=("SSH key id_ed25519_github.pub not found")
	SETUP_INSTRUCTIONS+=("$(cat <<-EOF
		SSH Key Setup:
		  1. Generate SSH key:
		     ssh-keygen -t ed25519 -C "your.email@example.com" -f ~/.ssh/id_ed25519_github
		  2. Add to GitHub:
		     cat ~/.ssh/id_ed25519_github.pub
		     Then add at: https://github.com/settings/keys
		     Choose "Signing key" for commit signing
		  3. Or create symlink if you have a different key:
		     ln -s ~/.ssh/your_key.pub ~/.ssh/id_ed25519_github.pub
	EOF
	)")
	SETUP_WARNINGS=true
fi
echo ""

# 3. Check allowed-signers file
echo "🔍 [3/5] Checking allowed-signers file..."
HOST_ALLOWED_SIGNERS_FILE="$HOME/.config/git/allowed-signers"
if [ -f "$HOST_ALLOWED_SIGNERS_FILE" ]; then
	cp "$HOST_ALLOWED_SIGNERS_FILE" "$CONF_DIR/allowed-signers"
	echo "   ✅ Allowed-signers file found and copied"
	echo "      From: $HOST_ALLOWED_SIGNERS_FILE"
else
	echo "   ⚠️  Allowed-signers file not found"
	WARNING_MESSAGES+=("allowed-signers file not found")
	SETUP_INSTRUCTIONS+=("$(cat <<-EOF
		Allowed-Signers Setup:
		  1. Create directory:
		     mkdir -p ~/.config/git
		  2. Add your SSH key to allowed-signers:
		     echo "your.email@example.com \$(cat ~/.ssh/id_ed25519_github.pub)" > ~/.config/git/allowed-signers
		  3. Configure git:
		     git config --global gpg.ssh.allowedSignersFile ~/.config/git/allowed-signers
	EOF
	)")
	SETUP_WARNINGS=true
fi
echo ""

# 4. Check Git configuration
echo "🔍 [4/5] Checking Git configuration..."
GIT_USER_NAME=""
GIT_USER_EMAIL=""

# Try to get git config from host, or fall back to environment variables
if git config --global user.name >/dev/null 2>&1; then
	GIT_USER_NAME=$(git config --global user.name)
	echo "   ✅ Git user.name: $GIT_USER_NAME"
elif [ -n "${GIT_USER_NAME:-}" ]; then
	echo "   ✅ Git user.name from environment: $GIT_USER_NAME"
else
	echo "   ❌ Git user.name not configured"
	ERROR_MESSAGES+=("Git user.name not configured")
	SETUP_INSTRUCTIONS+=("$(cat <<-EOF
		Git Configuration:
		  Option 1 - Configure git globally:
		    git config --global user.name "Your Name"
		    git config --global user.email "your.email@example.com"

		  Option 2 - Use environment variables (SSH/remote):
		    export GIT_USER_NAME="Your Name"
		    export GIT_USER_EMAIL="your.email@example.com"
	EOF
	)")
	SETUP_FAILED=true
fi

if git config --global user.email >/dev/null 2>&1; then
	GIT_USER_EMAIL=$(git config --global user.email)
	echo "   ✅ Git user.email: $GIT_USER_EMAIL"
elif [ -n "${GIT_USER_EMAIL:-}" ]; then
	echo "   ✅ Git user.email from environment: $GIT_USER_EMAIL"
else
	echo "   ❌ Git user.email not configured"
	ERROR_MESSAGES+=("Git user.email not configured")
	SETUP_FAILED=true
fi
echo ""

# 5. Check GitHub CLI
echo "🔍 [5/5] Checking GitHub CLI authentication..."
if command -v gh >/dev/null 2>&1; then
	if gh auth status >/dev/null 2>&1; then
		echo "   ✅ GitHub CLI authenticated"
		GH_USER=$(gh api user -q .login 2>/dev/null || echo "unknown")
		echo "      Logged in as: $GH_USER"
	else
		echo "   ⚠️  GitHub CLI not authenticated"
		WARNING_MESSAGES+=("GitHub CLI not authenticated")
		SETUP_INSTRUCTIONS+=("$(cat <<-EOF
			GitHub CLI Authentication:
			  1. Authenticate with GitHub:
			     gh auth login --web
			  2. Verify:
			     gh auth status

			  This enables automatic token extraction for the devcontainer.
		EOF
		)")
		SETUP_WARNINGS=true
	fi
else
	echo "   ⚠️  GitHub CLI (gh) not installed"
	WARNING_MESSAGES+=("GitHub CLI not installed")
	SETUP_INSTRUCTIONS+=("$(cat <<-EOF
		GitHub CLI Installation:
		  Install from: https://cli.github.com/

		  Or use package manager:
		    macOS:   brew install gh
		    Ubuntu:  sudo apt install gh
		    Fedora:  sudo dnf install gh
	EOF
	)")
	SETUP_WARNINGS=true
fi
echo ""

echo "========================================"
echo "Validation Summary"
echo "========================================"
echo ""

# Generate .gitconfig if we have the required info
GITCONFIG_OUT="$CONF_DIR/.gitconfig"
GITCONFIG_GLOBAL="$CONF_DIR/.gitconfig.global"

if [ "$SETUP_FAILED" = "false" ]; then
	echo "✅ All required prerequisites met!"
	echo ""

	# Generate .gitconfig
	if [ -z "$(git config --list --global 2>/dev/null)" ]; then
		echo "Creating .gitconfig from environment variables..."
		echo "[user]" > "$GITCONFIG_GLOBAL"
		echo "    name = $GIT_USER_NAME" >> "$GITCONFIG_GLOBAL"
		echo "    email = $GIT_USER_EMAIL" >> "$GITCONFIG_GLOBAL"
	else
		git config --list --global --include >"$GITCONFIG_GLOBAL"
	fi

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
	    # Handle subsection (e.g., filter.lfs.clean, gpg.ssh.allowedsignersfile, diff.lfs.textconv)
	    # Any 3+ part key (section.subsection.key) becomes [section "subsection"] with key = value
	    if (length(arr) > 2) {
	      subsection = arr[2]
	      subkey = arr[3]
	      # Handle all subsection cases generically
	      if (section != last_section || subsection != last_subsection) {
	        if (last_section != "") print ""
	        print_section(section, subsection)
	        last_section = section
	        last_subsection = subsection
	      }
	      print "    " subkey " = " val
	      next
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
	' "$GITCONFIG_GLOBAL" >"$GITCONFIG_OUT"

	echo "   Generated .gitconfig at $GITCONFIG_OUT"
	echo ""

	if [ "$SETUP_WARNINGS" = "true" ]; then
		echo "⚠️  Warnings (optional items):"
		for warning in "${WARNING_MESSAGES[@]}"; do
			echo "   - $warning"
		done
		echo ""
		echo "The devcontainer will start, but some features may not work."
		echo "See setup instructions below."
		echo ""
	fi
else
	echo "❌ Required prerequisites missing!"
	echo ""
	echo "Errors:"
	for error in "${ERROR_MESSAGES[@]}"; do
		echo "   - $error"
	done
	echo ""
fi

# Print setup instructions if there are any issues
if [ ${#SETUP_INSTRUCTIONS[@]} -gt 0 ]; then
	echo "========================================"
	echo "Setup Instructions"
	echo "========================================"
	echo ""
	for instruction in "${SETUP_INSTRUCTIONS[@]}"; do
		echo "$instruction"
		echo ""
	done
	echo "========================================"
	echo ""
	echo "📖 For detailed documentation, see:"
	echo "   scripts/docs/DEV_CONTAINER_SETUP.md"
	echo ""
fi

# Exit with error if required items are missing
if [ "$SETUP_FAILED" = "true" ]; then
	echo "❌ Cannot proceed with devcontainer initialization."
	echo "   Please fix the errors above and run this script again:"
	echo "   .devcontainer/setup-user-conf.sh"
	echo ""
	exit 1
fi

echo "✅ Initialization validation complete!"
echo "   You can now open the devcontainer in VS Code."
echo ""
