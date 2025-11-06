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
make THEME_TOGGLE=no          # Build without theme toggle (auto mode only)
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

- 🌓 **Dark mode toggle** (top-right) - 3 states: 🌙 Dark / ☀️ Light / 🌓 Auto (system)
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
- **VS Code** with "Dev Containers" extension (recommended)
  - Or use any editor + run containers manually

**Container setup by platform:**
- **Linux**: `docker` or `podman` native
- **macOS**: Docker Desktop or Podman Machine
- **Windows**: Docker Desktop (auto-installs WSL2)

**Without VS Code:**

```bash
# Build and run container manually:
docker build -f .devcontainer/Containerfile -t typst-dev .
docker run -it -v $(pwd):/workspace typst-dev
# Then: make example
```

## 📚 More Info

- `technical-documentation/README.md` - Detailed usage
- `docs/BUILD_SYSTEM.md` - Build system docs
- `example/` - Working examples with diagrams
- `make help` - All available commands

---

**Tip:** Run `make example` first to see what's possible, then edit `technical-documentation/` for your own docs!
