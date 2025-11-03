# Typst Container Setup

This directory contains configuration for writing Typst documents in a reproducible, containerized environment using VS Code Dev Containers and Podman.

## Features
- **Workspace Mounting:** Your project directory is mounted into the container at `/workspace`.
- **GPG Agent Forwarding:** Your host GPG agent socket is forwarded into the container for signing and encryption operations.
- **User Configuration:** Git and GPG configuration are automatically imported for a seamless development experience.
- **Typst Development Environment:** Complete setup for creating and compiling Typst documents with live preview and LSP support.

---

## Requirements

### System Dependencies
- **Podman** (v4.0+) - Container runtime for building and running the development container
- **Podman Compose** - For orchestrating the container services defined in `docker-compose.yml`
- **GPG** - For GPG agent socket forwarding and key management

### VS Code
You will need **VS Code** with the **Dev Containers** extension for containerized development experience. To configure VS Code for Podman (system-wide):

#### **Option A: VS Code Settings UI**
  - Open VS Code Settings (`Ctrl+,`)
  - Search for "dev containers"
  - Set "Dev Containers: Docker Path" to `podman`
  - Set "Dev Containers: Docker Compose Path" to `podman-compose`

#### **Option B: Edit settings.json**
  - Press `Ctrl+Shift+P` → "Preferences: Open Settings (JSON)"
  - Add these lines:
   ```json
   {
       "dev.containers.dockerPath": "podman",
       "dev.containers.dockerComposePath": "podman-compose"
   }
   ```

### Container Features
The development container includes:
- **Python 3.12** - Latest stable Python version for development tools
- **Typst v0.13.1** - Modern typesetting system for creating professional documents
- **Typst LSP v0.13.0** - Language Server Protocol for VS Code integration
- **Development tools**: build-essential, git, curl, wget, nano, shellcheck
- **Code quality tools**: ruff, mypy, yamllint, hadolint, shfmt, pre-commit hooks
- **VS Code Extensions**: Python, YAML support, Typst LSP, TinyMist, Typst Preview, GitHub PR integration, Ruff, MyPy

---

## Getting Started

### 1. **Set Up GPG Agent Socket Environment Variable**
Verify your GPG socket path with `gpgconf --list-dirs agent-socket`. Then add the following to your `~/.bashrc` (or equivalent shell profile) and restart VS Code:

```sh
# Set GPG agent socket for dev containers
export GPG_SOCKET_PATH="$(gpgconf --list-dirs agent-socket)"
```

### 2. **Run User Configuration Script**
Before starting the dev container, run the setup script to export your Git and GPG configuration:

```sh
.devcontainer/setup-user-conf.sh
```

This will:
- Generate a valid `.gitconfig` for use inside the container.
- Export your public GPG keys and ownertrust for import into the container.
- Validate that your `GPG_SOCKET_PATH` is set and matches your actual GPG agent socket.

If necessary, you can edit the generated `.devcontainer/.conf/.gitconfig` to match your needs.

### 3. **Build the Dev Container**
Run:

```sh
podman-compose build dev
```

### 4. **Start the Dev Container**
- Open the project root in VS Code.
- Use the **Dev Containers** extension to "Reopen in Container".
- The container will mount your workspace and forward your GPG agent socket automatically.

---

## Working with Typst Documents

### Available Commands
The container includes convenient aliases for Typst development:
- `typst-compile` - Compile a Typst document to PDF
- `typst-watch` - Watch for changes and automatically recompile
- `precommit` - Run pre-commit hooks for code quality

### VS Code Integration
The container is configured with:
- **Typst LSP** for syntax highlighting, autocompletion, and error checking
- **TinyMist** for enhanced Typst support
- **Typst Preview** for live document preview
- **Auto-formatting** on save with Ruff for Python files

### Example Usage
```bash
# Compile a Typst document
typst compile main.typ output.pdf

# Watch for changes
typst watch main.typ output.pdf

# Run code quality checks
precommit
```

---

## Project Structure
- `.devcontainer/` - Container configuration and setup scripts
- `.githooks/` - Git hooks for automated quality checks
- Configuration files for various development tools (`.hadolint.yaml`, `.yamllint`, etc.)
