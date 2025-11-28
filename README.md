# Typst Technical Documentation Template

A complete development environment and build system for creating professional
technical documentation with Typst, featuring automated diagram compilation,
dual PDF/HTML output with dark mode support, and comprehensive Python API
documentation generation.

## Requirements

> **💡 Quick Start:** After installing requirements, run `.devcontainer/setup-user-conf.sh` to test all logins and validate your setup before opening the devcontainer!

### Container Runtime

You need **one** of the following:

- **Podman**
  - [Podman Desktop](https://podman-desktop.io/) GUI application, or
  - [Podman CLI](https://podman.io/docs/installation) command-line only
  - Ensure podman machine is initialized and running (macOS/Windows):

    ```bash
    podman machine init
    podman machine start
    ```

  - On Linux, podman runs natively without a machine

- **Docker Desktop** (alternative)
  - [Download Docker Desktop](https://www.docker.com/products/docker-desktop/)
  - Ensure Docker Desktop is running before opening the devcontainer
  - 
### Development Environment

- **VS Code** with **Dev Containers extension**
  - Install VS Code: <https://code.visualstudio.com/>
  - Install extension: [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

### Host Machine Prerequisites

Before opening the devcontainer, your **host machine** (or remote server) must have:

#### 1. GHCR Authentication ⚠️ CRITICAL

The devcontainer image is pulled from GitHub Container Registry and **requires authentication**.

**Create GitHub Personal Access Token:**

1. Go to [GitHub Settings → Developer settings → Tokens (classic)](https://github.com/settings/tokens)
2. Click **"Generate new token (classic)"**
3. Name: `GHCR Dev Container Access`
4. Select scope: **`read:packages`** ✅ (required)
5. Generate and **copy the token immediately**

**Login to GHCR:**

```bash
# Docker
echo "YOUR_TOKEN" | docker login ghcr.io -u YOUR_GITHUB_USERNAME --password-stdin

# Podman
echo "YOUR_TOKEN" | podman login ghcr.io -u YOUR_GITHUB_USERNAME --password-stdin
```

**Verify:**

```bash
# Docker
docker pull ghcr.io/morepet/containers/dev/typst:1.3-dev

# Podman
podman pull ghcr.io/morepet/containers/dev/typst:1.3-dev
```

#### 2. Git Configuration ⚠️ REQUIRED

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

**For SSH/remote scenarios** (if git not configured on remote server):

```bash
export GIT_USER_NAME="Your Name"
export GIT_USER_EMAIL="your.email@example.com"
```

#### 3. SSH Key (Specific Name Required)

The setup expects: `~/.ssh/id_ed25519_github.pub`

**If you don't have this key:**

```bash
# Generate new key
ssh-keygen -t ed25519 -C "your.email@example.com" -f ~/.ssh/id_ed25519_github

# Add to GitHub as "Signing key"
cat ~/.ssh/id_ed25519_github.pub
# Add at: https://github.com/settings/keys
```

**If you have a different key name:**

```bash
# Create symlink
ln -s ~/.ssh/your_key.pub ~/.ssh/id_ed25519_github.pub
```

#### 4. Allowed-Signers File

For commit signature verification:

```bash
mkdir -p ~/.config/git
echo "your.email@example.com $(cat ~/.ssh/id_ed25519_github.pub)" > ~/.config/git/allowed-signers
git config --global gpg.ssh.allowedSignersFile ~/.config/git/allowed-signers
```

#### 5. GitHub CLI (Optional but Recommended)

For seamless GitHub integration:

```bash
# Install (see https://cli.github.com/)
# Then authenticate
gh auth login

# Verify
gh auth status
```

#### Quick Validation - Test All Logins

**Before attempting to open the devcontainer, run this script to test all logins and prerequisites:**

```bash
.devcontainer/setup-user-conf.sh
```

**This script validates:**
- ✅ GHCR authentication (Docker/Podman login to ghcr.io)
- ✅ Git configuration (user.name and user.email)
- ✅ SSH key setup (id_ed25519_github.pub)
- ✅ Allowed-signers file
- ✅ GitHub CLI authentication

**The script will:**
- Show exactly what's configured ✅ and what's missing ❌
- Provide step-by-step instructions to fix any issues
- Tell you if you're ready to open the devcontainer

**Note:** Docker and Podman commands are interchangeable in this guide.

## Quick Start

### 1. Start Your Container Runtime

**Docker Desktop users:**

- Launch Docker Desktop application
- Wait for it to fully start (Docker icon in system tray)

**Podman users (macOS/Windows):**

```bash
# Initialize podman machine (first time only)
podman machine init

# Start podman machine
podman machine start

# Verify it's running
podman machine list
```

**Podman on Linux:**

No setup needed - podman runs natively without a machine.

### 2. Test All Logins and Prerequisites

**⚠️ IMPORTANT: Run this script to test all your logins before opening the devcontainer:**

```bash
.devcontainer/setup-user-conf.sh
```

This validates:
- GHCR authentication (Docker/Podman → ghcr.io)
- GitHub CLI authentication
- Git configuration
- SSH keys and allowed-signers

**You'll get a full report showing:**
- ✅ What's correctly configured
- ❌ What's missing (with instructions to fix)
- ⚠️ Optional items that can be configured later

**Only proceed to step 3 if the script shows all required items are configured!**

### 3. Open in Devcontainer

**Important:** Complete [Host Machine Prerequisites](#host-machine-prerequisites) first!

1. Clone this repository
2. Open the folder in VS Code
3. When prompted, click **"Reopen in Container"**
   - Or use Command Palette: "Dev Containers: Reopen in Container"
4. Container will pull and initialize (first time: 2-3 minutes)
5. Watch initialization output for:
   - ✅ Container image pulled successfully
   - ✅ Git configuration valid
   - ✅ SSH key copied
   - ✅ GitHub CLI authenticated

**If container fails to pull:** You're not authenticated to `ghcr.io` (see prerequisites step 1)

### 4. Build Documentation

Once inside the devcontainer:

```bash
# Build the default project (docs/)
make

# Or build the example project
make example
```

### 5. View Your Documentation

Open your browser to <http://localhost:8000> to see:

- PDF version: `build/technical-documentation.pdf`
- HTML version: `build/technical-documentation.html`

That's it! The build system handles everything automatically.

## Using Podman Without VS Code Devcontainer

If you prefer to use Podman directly instead of VS Code's built-in devcontainer support, you have three options.
All options assume you've completed the [Host Machine Prerequisites](#host-machine-prerequisites) (especially GHCR authentication).

### Option 1: Direct Podman CLI Usage

Use Podman command-line directly for maximum control and minimal dependencies.

**Start the container:**

```bash
# Linux (with SELinux context)
podman run -it --rm \
  -v "${PWD}:/workspace:Z" \
  -w /workspace \
  ghcr.io/morepet/containers/dev/typst:1.3-dev \
  /bin/bash

# macOS/Windows (no SELinux)
podman run -it --rm \
  -v "${PWD}:/workspace" \
  -w /workspace \
  ghcr.io/morepet/containers/dev/typst:1.3-dev \
  /bin/bash
```

**Important: SELinux Context (Linux only)**

The `:Z` flag is required on Linux systems with SELinux to allow the container to access the mounted volume. Without it, you'll get permission denied errors.

- `:Z` - Private unshared label (recommended for single container access)
- `:z` - Shared label (use if multiple containers need access)

**Inside the container, run initialization scripts in order:**

```bash
# 1. Post-create (one-time setup)
/workspace/.devcontainer/post-create.sh

# 2. Post-attach (session setup)
/workspace/.devcontainer/post-attach.sh

# 3. Build documentation
make
```

**Script execution order matters:**
1. `post-create.sh` - Sets up git, GitHub CLI, pre-commit hooks, Node.js
2. `post-attach.sh` - Configures git and verifies GitHub CLI for current session

**Pros:**
- No additional tools required beyond Podman
- Full control over container lifecycle
- Easy to customize and script

**Cons:**
- Manual script execution required
- Need to remember the correct command and flags
- No automatic devcontainer.json integration

### Option 2: Podman Compose (not tested)

Use `podman compose` for a more declarative approach with persistent configuration.

**Install docker compose:**

```bash
# Using pip
pip install docker-compose

# Or using system package manager (Fedora/RHEL)
sudo dnf install docker-compose

# Or using system package manager (Debian/Ubuntu)
sudo apt install docker-compose
```

**Start the container:**

```bash
# Start in detached mode
podman compose up -d

# Attach to the running container
podman compose exec dev /bin/bash
```

**Inside the container, run initialization scripts:**

```bash
# Run setup scripts in order
/workspace/.devcontainer/post-create.sh
/workspace/.devcontainer/post-attach.sh

# Build documentation
make
```

**Stop the container:**

```bash
podman compose down
```

**Configuration file:** The repository includes `podman-compose.yml` with proper settings:
- Volume mount with cached consistency
- Working directory set to `/workspace`
- Interactive terminal support
- Matches devcontainer.json configuration

**Pros:**
- Declarative configuration in `podman-compose.yml`
- Easy to start/stop with simple commands
- Persistent container state (optional)
- Familiar Docker Compose syntax

**Cons:**
- Requires installing podman-compose
- Still need to manually run initialization scripts
- Limited devcontainer.json feature support

### Option 3: Dev Container CLI

Use the official Dev Container CLI for full `devcontainer.json` compatibility with Podman.

**Install Dev Container CLI:**

```bash
npm install -g @devcontainers/cli
```

**Start the devcontainer with Podman:**

```bash
# Build and start the devcontainer
devcontainer up --workspace-folder . --docker-path podman

# Execute commands inside
devcontainer exec --workspace-folder . make

# Open a shell
devcontainer exec --workspace-folder . /bin/bash
```

**Full integration:**

The Dev Container CLI automatically:
- ✅ Reads and applies `.devcontainer/devcontainer.json` settings
- ✅ Runs `initializeCommand` on the host
- ✅ Executes `postCreateCommand` and `postAttachCommand` in container
- ✅ Mounts volumes correctly
- ✅ Installs VS Code extensions (when used with VS Code)

### Documentation Generation

- **Dual Output Format**: Generate both PDF and HTML from the same Typst source
- **Bootstrap HTML**: Modern, responsive HTML with Bootstrap 5.3 styling
- **Dark Mode**: Automatic dark mode support with manual toggle and system preference detection
- **Live Development Server**: Auto-reloading development server (live-server with Python fallback)
- **Cache-Busting**: Automatic CSS cache invalidation for reliable updates

### Diagram Support

- **Fletcher Diagrams**: Architecture, data flow, and state machine diagrams
- **Theme-Aware**: Diagrams automatically switch colors for light/dark modes
- **Automatic Compilation**: Diagrams compile automatically as part of the build process
- **SVG Embedding**: Diagrams embedded as SVG in HTML for crisp rendering

### Python Documentation

- **API Documentation**: Generate API reference from Python source using griffe
- **Google-Style Docstrings**: Full support for structured docstring parsing
- **Test Integration**: Automatically include test coverage and results
- **Self-Contained**: All documentation generated within the build system

### Development Environment

- **VS Code Devcontainer**: Pre-configured development environment with all tools
- **SSH Agent Integration**: Git commit/tag signing works seamlessly in container
- **Pre-commit Hooks**: Automatic linting and formatting (Ruff, shellcheck, pymarkdown, yamllint)
- **Protected Configs**: Linting configuration files protected from accidental modification

## Build System

The build automatically handles:

- Generating color palettes from `lib/colors.json`
- Compiling all diagrams in `diagrams/` folder
- Building PDF output
- Building HTML with Bootstrap styling
- Starting development server on <http://localhost:8000>

### Main Targets

```bash
make                    # Build technical-documentation (default)
make example            # Build the example project
make test               # Build and validate all projects
make clean              # Remove all build artifacts
make rebuild            # Clean and rebuild everything
```

## Project Structure

```text
workspace/
├── docs/                          # Default project
│   ├── main.typ                       # Main document
│   └── diagrams/                      # Diagram source files
│
├── build/                         # Build outputs (default project)
│   ├── diagrams/                      # Compiled diagram SVGs
│   ├── technical-documentation.pdf
│   └── technical-documentation.html
│
├── example/                       # Example project
│   ├── docs/
│   │   ├── main.typ
│   │   └── diagrams/
│   └── build/                         # Example build outputs
│       ├── diagrams/
│       ├── technical-documentation.pdf
│       └── technical-documentation.html
│
├── lib/                          # Shared library
│   ├── technical-documentation-package.typ  # Typst functions
│   ├── colors.json                         # Color palette
│   ├── styles-bootstrap.css                # HTML styling
│   └── generated/                          # Auto-generated files
│
├── scripts/                      # Build scripts
│   ├── build-html-bootstrap.py   # HTML processing
│   └── generate-colors.py        # Color palette generator
│
└── Makefile                      # Build system
```

