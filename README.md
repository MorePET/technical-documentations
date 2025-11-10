# Typst Technical Documentation Template

A complete development environment and build system for creating professional
technical documentation with Typst, featuring automated diagram compilation,
dual PDF/HTML output with dark mode support, and comprehensive Python API
documentation generation.

## Requirements

> **💡 Quick Start:** After installing requirements, run `.devcontainer/setup-user-conf.sh` to test all logins and validate your setup before opening the devcontainer!

### Container Runtime

You need **one** of the following:

- **Docker Desktop** (recommended for macOS/Windows)
  - [Download Docker Desktop](https://www.docker.com/products/docker-desktop/)
  - Ensure Docker Desktop is running before opening the devcontainer

- **Podman** (alternative, works on Linux/macOS/Windows)
  - [Podman Desktop](https://podman-desktop.io/) GUI application, or
  - [Podman CLI](https://podman.io/docs/installation) command-line only
  - Ensure podman machine is initialized and running (macOS/Windows):

    ```bash
    podman machine init
    podman machine start
    ```

  - On Linux, podman runs natively without a machine

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
   - Or use Command Palette (F1): "Dev Containers: Reopen in Container"
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

## Features

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

### Component Targets

```bash
make colors             # Generate color files from colors.json
make diagrams           # Compile all diagrams for current project
make pdf                # Compile PDF only
make html               # Compile HTML with Bootstrap styling
```

### Server Control

```bash
make server-start       # Start development server on port 8000
make server-stop        # Stop the development server
make server-status      # Check if server is running
```

### Configuration Options

```bash
# Disable theme toggle (use system preference only)
make THEME_TOGGLE=no

# Build specific project
make PROJECT=example

# Compile diagrams for specific project
make diagrams PROJECT=example
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

## Creating Documentation

### 1. Create Your Document

Edit `docs/main.typ`:

```typst
#import "../lib/technical-documentation-package.typ": *

#show: tech-doc.with(
  title: "My Technical Documentation",
  authors: ("Your Name",),
  date: datetime.today(),
)

= Introduction

Your content here...
```

### 2. Add Diagrams

Create diagrams in `docs/diagrams/`:

```typst
// diagrams/architecture.typ
#import "../../lib/generated/colors.typ": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node

#set page(width: auto, height: auto, margin: 1em, fill: none)

#align(center)[
  #diagram(
    node-stroke: 1pt,
    node-fill: node-bg-blue,
    spacing: 5em,

    node((0, 0), [Frontend]),
    node((1, 0), [Backend]),
    edge((0, 0), (1, 0), [API], "->"),
  )
]
```

### 3. Include Diagrams

In your main document:

```typst
#figure(
  image("build/diagrams/architecture.svg"),
  caption: [System Architecture]
)
```

### 4. Build

```bash
make
```

## Available Functions

Import from the package:

```typst
#import "../lib/technical-documentation-package.typ": *
```

### Document Template

- `tech-doc()` - Main document template with proper styling

### Diagram Helpers

- `architecture-diagram()` - System architecture diagrams
- `data-flow-diagram()` - Data flow diagrams
- `state-diagram()` - State machine diagrams

### Typography

- `nuclide()` - Isotope notation (⁴⁴Sc, ⁶⁸Ga, ¹⁸F)
- `beta-plus()` - β⁺ particle
- `beta-minus()` - β⁻ particle

See `lib/NOTATIONS-README.md` for complete notation reference.

## Python API Documentation

Generate API documentation from Python source code:

```bash
# Generate API docs for your Python project
make python-api

# Run tests and generate coverage
make python-tests

# Compile Python-specific diagrams
make python-diagrams
```

The system uses `griffe` to extract API information and generates Typst documentation automatically.

## Customization

### Colors

Edit `lib/colors.json` to customize the color palette:

```json
{
  "light": {
    "primary": "#0066cc",
    "background": "#ffffff",
    ...
  },
  "dark": {
    "primary": "#4dabf7",
    "background": "#1a1a1a",
    ...
  }
}
```

Run `make colors` to regenerate color files.

### HTML Styling

Edit `lib/styles-bootstrap.css` for custom HTML styling. The template uses Bootstrap 5.3 as a base.

### Build Process

The `Makefile` orchestrates the complete build process:

1. **Color Generation**: `lib/colors.json` → `lib/generated/colors.typ`
2. **Diagram Compilation**: `diagrams/*.typ` → `build/diagrams/*.svg`
3. **PDF Build**: Typst compilation with all resources
4. **HTML Build**: Typst HTML export + Bootstrap styling + cache-busting
5. **Server Start**: Live-server or Python HTTP server

## Development Server

The template includes a smart development server:

- **Primary**: `live-server` (Node.js) with auto-reload on file changes
- **Fallback**: Python `ThreadingHTTPServer` if live-server unavailable
- **Port**: 8000 by default
- **Features**: Proper CORS headers, cache control, concurrent requests

Control the server:

```bash
make server-start   # Start server
make server-stop    # Stop server
make server-status  # Check status
```

## Dark Mode

HTML output automatically supports dark mode:

- **System Detection**: Respects `prefers-color-scheme`
- **Manual Toggle**: Button in top-right corner (optional)
- **Persistence**: Choice saved in localStorage
- **Diagrams**: All diagrams switch colors automatically

Disable the toggle button:

```bash
make THEME_TOGGLE=no
```

## Example Project

The `example/` directory contains a complete reference implementation:

- Technical documentation following V-Model structure
- Multiple diagram types (architecture, data flow, state machine)
- Stakeholder analysis with data from multiple sources (CSV, JSON, YAML)
- Python API documentation integration
- Test coverage integration

Build it:

```bash
make example
```

## Tips

1. **Multiple Projects**: Create new folders at workspace root, each with `docs/main.typ` and `docs/diagrams/` subdirectories
2. **Live Reload**: Use `live-server` for best development experience with auto-reload
3. **Diagram Organization**: Group related diagrams in subdirectories under `diagrams/`
4. **Color Consistency**: Use generated color variables from `lib/generated/colors.typ` in diagrams
5. **Version Control**: Build outputs (`build/` directories) are gitignored by default

## Documentation

- **Build System**: See `Makefile` for all targets and options
- **Git Workflow**: See `docs/git-workflow.md` for commit conventions
- **Devcontainer**: See `docs/devcontainer-setup.md` for environment details
- **Linting**: See `docs/linter-precommit-guide.md` for code quality tools

## Protected Configuration Files

This repository protects critical linting configuration files from accidental modifications:

### Protected Files

- `.pre-commit-config.yaml` - Pre-commit hooks
- `pyproject.toml` - Python dependencies and tools
- `.hadolint.yaml` - Container linting
- `.checkmake.ini` - Makefile linting
- `.yamllint` - YAML linting

These files are set to **read-only (444 permissions)** in the devcontainer.

### Editing Protected Files

```bash
# Use the helper script
edit-protected .pre-commit-config.yaml

# Or manually
chmod 644 .pre-commit-config.yaml
vim .pre-commit-config.yaml
chmod 444 .pre-commit-config.yaml
```

The protection is local-only and doesn't affect CI/CD workflows.

## Manual Setup (Without Devcontainer)

If you prefer not to use the devcontainer:

- Typst 0.12+
- Python 3.12+
- Node.js (optional, for live-server)
- Make

## License

See LICENSE file for details.

## Contributing

1. Fork the repository
2. Create a feature branch (`feature/my-feature`)
3. Follow conventional commit format (enforced by gitlint)
4. Ensure all pre-commit hooks pass
5. Submit a pull request

See `docs/git-workflow.md` for detailed guidelines.
