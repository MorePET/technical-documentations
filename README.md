# Technical Documentation System

Create professional technical documentation with diagrams in both PDF and HTML with automatic dark mode.

## 🚀 Quick Start

### 1. Setup

**Option A: Native Installation**

```bash
# Install Typst, Python 3, and Make on your system (see Requirements below)
# Clone this repo and you're ready!
```

**Option B: Dev Container**

```bash
# Open in VS Code with Dev Containers extension
# Or use GitHub Codespaces
# Everything pre-installed!
```

### 2. See the Example

```bash
make example                        # Build the example project
open technical-doc-example.html     # View HTML (has diagrams & dark mode)
open technical-doc-example.pdf      # View PDF
```

The example shows:

- System Architecture diagram
- Data Flow diagram
- State Machine diagram
- Stakeholder tables (CSV/JSON/YAML)
- Dark mode toggle

### 3. Start Your Own Documentation

```bash
# Your workspace is ready in technical-documentation/
cd technical-documentation
vim technical-documentation.typ     # Edit your content

# Add diagrams (see example/diagrams/ for reference)
cd diagrams
# Create .typ files here

# Build your documentation
cd /workspace
make                                # Builds technical-documentation (default)
```

## 📋 Make Commands

| Command | What it does |
|---------|--------------|
| `make` | Build your documentation (technical-documentation/) |
| `make example` | Build the example/demo |
| `make all-projects` | Build everything |
| `make pdf` | Just PDF for default project |
| `make html` | Just HTML for default project |
| `make clean` | Remove build artifacts |
| `make help` | Show all commands |

### ⚙️ Configuration

| Variable | Options | Description |
|----------|---------|-------------|
| `THEME_TOGGLE` | `yes` (default) / `no` | Include theme toggle button or use auto mode only |

**Examples:**

```bash
make THEME_TOGGLE=no          # Build without darkmode toggle (auto mode only)
make THEME_TOGGLE=no example  # Build example without toggle
```

## 📁 Project Structure

```text
workspace/
├── technical-documentation/    ← YOUR WORK (default)
│   ├── technical-documentation.typ
│   └── diagrams/
│
├── example/                   ← REFERENCE/DEMO
│   ├── technical-doc-example.typ
│   └── diagrams/              (3 diagram examples)
│
├── lib/                       ← SHARED (colors, styles, package)
│   ├── technical-documentation-package.typ
│   ├── colors.json
│   └── styles.css
│
├── scripts/                   ← BUILD TOOLS
└── Makefile                   ← BUILD COMMANDS
```

## ✏️ Editing Your Documentation

**Main document:** `technical-documentation/technical-documentation.typ`

```typst
#import "../lib/technical-documentation-package.typ": tech-doc

#show: tech-doc

= My Section
Content here...

// Add diagrams (see example/ for templates)
```

**Change colors:** Edit `lib/colors.json` and rebuild

**Add diagrams:** Create `.typ` files in `technical-documentation/diagrams/` (copy from `example/diagrams/` as template)

## 🎨 HTML Features

- 🌓 **Dark mode toggle** (top-right) - 3 states: 🌑 Dark / 🌕 Light / 🌓 Auto (system)
  - Optional: Can be disabled for auto-only mode (`THEME_TOGGLE=no`)
- 📚 **TOC sidebar** (left) - Collapsible sections with smooth navigation
- 📊 **Diagrams** - SVG diagrams that switch colors with theme
- 📱 **Responsive** - Works on mobile, tablet, and desktop

## 🔧 Requirements

### Minimal (No Containers Needed!)

This project uses **only Python standard library** - no pip packages required!

- **Typst** (>= 0.14.0) - [Download here](https://github.com/typst/typst/releases)
  - Version 0.14.0+ required for HTML export
- **Python 3** (any recent version)
  - **Recommended:** Use `uv` for fast Python management - [Install uv](https://docs.astral.sh/uv/getting-started/installation/)
- **Make** - Usually pre-installed on macOS/Linux (install via `xcode-select --install` on macOS or `sudo apt install make` on Linux/WSL if missing)
  - Optional: Run scripts manually with `python3 scripts/...` if Make unavailable

#### Platform-Specific Installation

**macOS:**

```bash
brew install typst make python3
```

**Linux/WSL:**

```bash
sudo apt install make python3  # Debian/Ubuntu
# Install Typst >= 0.14.0 from https://github.com/typst/typst/releases
```

**Windows:** Use WSL2 (recommended) or install Python/Typst from python.org and typst.app

#### Quick Setup with uv

Use [`uv`](https://docs.astral.sh/uv/) for modern Python environment management (recommended):

```bash
# Install uv and create venv
curl -LsSf https://astral.sh/uv/install.sh | sh
uv venv && source .venv/bin/activate
make example
```

### Dev Container Option

If you prefer containers (optional):

- **Docker** or **Podman** (container runtime)
- **VS Code** with "Dev Containers" extension
- **GitHub Container Registry (GHCR) token** for pulling pre-built images

**Quick start:**

1. Install [Docker Desktop](https://docs.docker.com/desktop/) or [Podman](https://podman.io/)
2. Install [VS Code Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
3. Configure Podman path (if using Podman) - see [Dev Container Setup Guide](docs/DEV_CONTAINER_SETUP.md#option-b-podman-docker-free-alternative)
4. [Authenticate with GHCR](docs/DEV_CONTAINER_SETUP.md#3-github-container-registry-ghcr-authentication)
5. Open project in VS Code and select "Reopen in Container"

**Important setup requirements:**

- GHCR authentication (GitHub Personal Access Token with `read:packages` scope)
- SSH key named `~/.ssh/id_ed25519_github.pub` for git signing (optional)
- Podman users: configure VS Code to use Podman instead of Docker

See **[Dev Container Setup Guide](docs/DEV_CONTAINER_SETUP.md)** for complete instructions.

## 🔍 Code Quality & Linting

This project uses **pre-commit hooks** to automatically check and fix code quality issues:

```bash
# Install hooks (one-time setup)
make install-hook

# Hooks run automatically on git commit
# Or run manually:
pre-commit run --all-files
```

**What's checked:**
- ✅ Trailing whitespace (auto-fixed)
- ✅ Python code style (Ruff)
- ✅ Shell scripts (ShellCheck)
- ✅ YAML/JSON syntax
- ✅ Markdown formatting

See [Linter & Pre-commit Guide](docs/LINTER_AND_PRECOMMIT.md) for details.

## 📚 More Info

- [Detailed Usage Guide](technical-documentation/README.md) - How to write documentation
- [Build System Documentation](docs/BUILD_SYSTEM.md) - Build pipeline and make targets
- [Dev Container Setup Guide](docs/DEV_CONTAINER_SETUP.md) - Container development environment
- [Linter & Pre-commit Guide](docs/LINTER_AND_PRECOMMIT.md) - Code quality and hooks
- [Dark Mode Color Standards](docs/DARK_MODE_COLOR_STANDARDS.md) - Color palette design
- [Example Project](example/) - Working examples with diagrams
- `make help` - All available commands

---

**Tip:** Run `make example` first to see what's possible, then edit `technical-documentation/` for your own docs!
