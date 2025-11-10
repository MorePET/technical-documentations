# Dev Container Setup Guide

This guide explains how to use the development container for this project.

## Prerequisites

### 1. Container Runtime

Choose **one** of these options:

#### Option A: Docker (Most Common)

**Installation:**

- **macOS**: [Docker Desktop for Mac](https://docs.docker.com/desktop/install/mac-install/)
- **Windows**: [Docker Desktop for Windows](https://docs.docker.com/desktop/install/windows-install/)
- **Linux**: [Docker Engine](https://docs.docker.com/engine/install/)

#### Option B: Podman (Docker-free alternative)

**Why Podman?**

Podman is often preferred over Docker for several reasons:

- **Rootless by default**: Runs containers without requiring root privileges, improving security
- **Daemonless architecture**: No background daemon process required, reducing resource usage
- **Docker-compatible**: Drop-in replacement for Docker CLI commands
- **Better security model**: Each container runs in its own user namespace
- **Open source**: Fully open source without commercial licensing concerns
- **Systemd integration**: Native support for systemd in containers (Linux)

Both Docker and Podman work equally well with this dev container. Choose based on your preference and system requirements.

**Installation Options:**

There are two ways to use Podman:

1. **Podman Desktop** (Recommended for macOS/Windows) - GUI app that includes:
   - Graphical interface for managing containers
   - **Podman CLI** included
   - **Automatic podman machine management** (handles VM setup)
   - Easy status monitoring and troubleshooting

2. **Podman CLI only** - Command-line tool:
   - Lightweight, no GUI
   - Requires manual podman machine setup on macOS/Windows
   - Native on Linux (no VM needed)

**Platform-specific installation:**

- **macOS**:
  - Option 1: [Podman Desktop](https://podman-desktop.io/downloads) (recommended - includes CLI + GUI)
  - Option 2: `brew install podman` (CLI only - requires manual machine setup)

- **Windows**:
  - Option 1: [Podman Desktop](https://podman-desktop.io/downloads) (recommended - includes CLI + GUI)
  - Option 2: [Podman CLI installer](https://github.com/containers/podman/releases) (requires manual machine setup)

- **Linux**:
  - `sudo apt install podman` (Debian/Ubuntu)
  - See [Podman installation](https://podman.io/getting-started/installation) for other distros
  - **No podman machine needed** - runs natively!

**About Podman Machine (macOS/Windows only):**

Since containers are Linux-based, macOS and Windows need a lightweight Linux VM to run them.
This VM is called a "podman machine".

- **Podman Desktop**: Automatically creates and manages the VM for you
- **CLI only**: You must manually create and start the machine:

  ```bash
  # Create the machine (first time only)
  podman machine init

  # Start the machine
  podman machine start

  # Check status
  podman machine list

  # Stop when done (optional)
  podman machine stop
  ```

**Configure VS Code for Podman:**

If using Podman instead of Docker, configure VS Code Dev Containers extension:

1. Open VS Code Settings (Cmd/Ctrl + ,)
2. Search for "dev containers docker path"
3. Set **Dev > Containers: Docker Path** to the path or just `podman` if it is executable everywhere
   - macOS: `/usr/local/bin/podman` (Homebrew) or `/opt/podman/bin/podman` (Podman Desktop)
   - Linux: `/usr/bin/podman` (or run `which podman` to find exact path)
   - Windows: `C:\Program Files\RedHat\Podman\podman.exe`

Or edit `.vscode/settings.json`:

```json
{
  "dev.containers.dockerPath": "/usr/local/bin/podman"
}
```

**Verify Podman is working:**

```bash
# Check version
podman --version

# On macOS/Windows: verify machine is running
podman machine list
# Should show:
# NAME    VM TYPE   CREATED      LAST UP               CPUS  MEMORY  DISK SIZE
# podman  qemu      X mins ago   Currently running     2     2GiB    100GiB

# Test with a simple container
podman run --rm hello-world
```

### 2. VS Code + Dev Containers Extension

**Required:**

1. [Visual Studio Code](https://code.visualstudio.com/)
2. [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

**Install extension:**

- via cli

```bash
code --install-extension ms-vscode-remote.remote-containers
```

- or from the VS code package browser

### 3. GitHub Container Registry (GHCR) Authentication

The dev container uses a pre-built image from GitHub Container Registry (`ghcr.io`).

**Why authentication is needed:**

- Public images from GHCR have rate limits for anonymous pulls
- Authentication increases rate limits and ensures reliable access
- Required for private images (if applicable)

**Setup GitHub Personal Access Token (PAT):**

1. Create a GitHub Personal Access Token:
   - Go to [GitHub Settings > Developer settings > Personal access tokens > Tokens (classic)](https://github.com/settings/tokens)
   - Click "Generate new token (classic)"
   - Give it a descriptive name: `GHCR Dev Container Access`
   - Select scope: **`read:packages`** (required for pulling container images)
   - Click "Generate token"
   - **Copy the token immediately** (you won't see it again!)

2. Login to GHCR on your host machine:

   **Docker:**

   ```bash
   echo "YOUR_TOKEN" | docker login ghcr.io -u YOUR_GITHUB_USERNAME --password-stdin
   ```

   **Podman:**

   ```bash
   echo "YOUR_TOKEN" | podman login ghcr.io -u YOUR_GITHUB_USERNAME --password-stdin
   ```

   Example:

   ```bash
   echo "ghp_abc123..." | docker login ghcr.io -u johndoe --password-stdin
   ```

3. Verify login:

   ```bash
   # Docker
   docker pull ghcr.io/morepet/containers/dev/typst:1.3-dev

   # Podman
   podman pull ghcr.io/morepet/containers/dev/typst:1.3-dev
   ```

**Credentials storage:**

- Docker Desktop: Credentials stored in OS keychain
- Docker CLI: Stored in `~/.docker/config.json`
- Podman: Stored in `${XDG_RUNTIME_DIR}/containers/auth.json`

**Reference:** [Working with the Container registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)

### 4. GitHub CLI Authentication (Automatic)

The dev container automatically handles GitHub CLI (`gh`) authentication by extracting your token from the host machine.

**How it works:**

1. During initialization, if `gh` is authenticated on your host machine, the setup extracts your authentication token
2. The token is passed to the container via an environment variable (never written to disk)
3. Inside the container, `gh auth login` is called to persist the authentication
4. You're automatically authenticated for all GitHub CLI operations

**Setup on Host Machine:**

To enable automatic authentication, ensure GitHub CLI is authenticated on your host:

```bash
# Check if already authenticated
gh auth status

# If not authenticated, login on your host machine
gh auth login --web
```

**Benefits:**

- **Zero configuration** - Works automatically if `gh` is authenticated on host
- **Secure** - Token never written to disk, passed only via environment variable
- **Seamless** - Container is ready to use `gh` commands immediately
- **No git commits** - Token cannot be accidentally committed to repository

**Fallback to Interactive Authentication:**

If `gh` is not authenticated on your host, the container will prompt for interactive authentication:

1. The container will display a device code and URL
2. **Important:** Due to container limitations, pressing Enter to open the browser will fail
3. Instead, manually copy the URL and paste it into your host browser
4. Complete the authentication flow in the browser
5. The container will automatically detect successful authentication

**Security Notes:**

- The authentication token extracted from your host has the same scopes as your host `gh` authentication
- Token is only accessible during container initialization
- Authentication is persisted using standard `gh` CLI methods in `~/.config/gh/hosts.yml`
- The token environment variable is unset after successful authentication

**Manual Token Setup (Alternative):**

If you prefer to use a dedicated token for the container, you can set it manually on your host:

```bash
# On host machine, set environment variable in your shell profile
export DEVCONTAINER_GH_TOKEN="ghp_your_token_here"
```

Then the container will use this token instead of extracting from `gh`.

**Reference:** [GitHub CLI manual](https://cli.github.com/manual/)

### 5. Git Configuration and SSH Keys

The dev container automatically syncs your git configuration and SSH keys from your host machine.

#### Required Git Configuration

Your host machine should have git configured with:

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

**For SSH/Remote Server Scenarios:**

If you're SSH'ing into a remote server and then opening the devcontainer there, you have three options:

**Option 1: Environment Variables (Recommended)**

Set environment variables on the remote server before opening the devcontainer:

```bash
# On the remote server, add to ~/.bashrc or ~/.profile:
export GIT_USER_NAME="Your Name"
export GIT_USER_EMAIL="your.email@example.com"
```

Then reload your shell configuration:

```bash
source ~/.bashrc
```

**Option 2: SSH Environment Forwarding**

Configure your local SSH client to forward git config:

Add to `~/.ssh/config` on your **local machine**:

```ssh
Host your-remote-server
    HostName your-server.com
    User your-username
    SendEnv GIT_USER_NAME GIT_USER_EMAIL
```

Set variables on your **local machine**:

```bash
export GIT_USER_NAME="Your Name"
export GIT_USER_EMAIL="your.email@example.com"
```

**Note:** The remote server must accept these variables. Check that `/etc/ssh/sshd_config` includes:

```text
AcceptEnv GIT_USER_NAME GIT_USER_EMAIL
```

**Option 3: Configure Git on Remote Server**

Simply configure git directly on the remote server (traditional method):

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

#### SSH Key for Git Signing (Optional but Recommended)

The setup script looks for an SSH key specifically named **`id_ed25519_github.pub`** in `~/.ssh/`.

**Why this specific name?**

The script at `.devcontainer/scripts/setup-git-conf.sh` expects:

```bash
HOST_SSH_PUBKEY="$HOME/.ssh/id_ed25519_github.pub"
```

**Setup SSH key for GitHub:**

1. **Generate SSH key** (if you don't have one):

   ```bash
   ssh-keygen -t ed25519 -C "your.email@example.com" -f ~/.ssh/id_ed25519_github
   ```

   This creates:
   - Private key: `~/.ssh/id_ed25519_github`
   - Public key: `~/.ssh/id_ed25519_github.pub`

2. **Add SSH key to GitHub**:
   - Copy your public key:

     ```bash
     cat ~/.ssh/id_ed25519_github.pub
     ```

   - Go to [GitHub Settings > SSH and GPG keys](https://github.com/settings/keys)
   - Click "New SSH key" or "Add SSH key"
   - Select key type:
     - **"Authentication key"** - for git push/pull
     - **"Signing key"** - for commit signing (recommended)
   - Paste your public key
   - Click "Add SSH key"

3. **Configure git to use SSH signing** (optional):

   ```bash
   # Use SSH for commit signing
   git config --global gpg.format ssh
   git config --global user.signingkey ~/.ssh/id_ed25519_github.pub
   git config --global commit.gpgsign true

   # Setup allowed signers file for verification
   mkdir -p ~/.config/git
   echo "your.email@example.com $(cat ~/.ssh/id_ed25519_github.pub)" > ~/.config/git/allowed-signers
   git config --global gpg.ssh.allowedSignersFile ~/.config/git/allowed-signers
   ```

**Using a different SSH key name:**

If your SSH key has a different name, update the script:

Edit `.devcontainer/scripts/setup-git-conf.sh` and change line 22:

```bash
# From:
HOST_SSH_PUBKEY="/workspace/.devcontainer/.conf/id_ed25519_github.pub"

# To:
HOST_SSH_PUBKEY="/workspace/.devcontainer/.conf/YOUR_KEY_NAME.pub"
```

And update `.devcontainer/setup-user-conf.sh` line 14:

```bash
# From:
HOST_SSH_PUBKEY="$HOME/.ssh/id_ed25519_github.pub"

# To:
HOST_SSH_PUBKEY="$HOME/.ssh/YOUR_KEY_NAME.pub"
```

**Reference:** [Managing commit signature verification](https://docs.github.com/en/authentication/managing-commit-signature-verification)

## Quick Start

### Using VS Code

1. **Open project in VS Code**:

   ```bash
   cd /path/to/project
   code .
   ```

2. **Open in container**:
   - VS Code will prompt: "Folder contains a Dev Container configuration"
   - Click **"Reopen in Container"**

   Or manually:
   - Press `F1` or `Cmd/Ctrl + Shift + P`
   - Search for: `Dev Containers: Reopen in Container`

3. **Wait for setup**:
   - First time: downloads image and runs setup (~2-5 minutes)
   - Subsequent times: much faster (~30 seconds)

4. **Verify setup**:

   ```bash
   # Check tools are available
   typst --version
   python3 --version
   make --version

   # Build example
   make example
   ```

### Using GitHub Codespaces

GitHub Codespaces automatically handles authentication and setup:

1. Go to your GitHub repository
2. Click **Code** > **Codespaces** > **Create codespace on main**
3. Wait for environment to build
4. Start coding!

**No additional setup needed** - GHCR authentication, git config, and SSH keys are handled automatically.

## What Happens During Setup

The dev container runs these scripts automatically:

### 1. Initialize (Before Container Starts) - `initialize.sh`

Runs on **host machine** before container creation:

```bash
.devcontainer/setup-user-conf.sh
```

- Copies your git config to `.devcontainer/.conf/.gitconfig`
- Copies SSH public key from `~/.ssh/id_ed25519_github.pub`
- Copies allowed-signers file for commit verification

### 2. Post-Create (After Container Starts) - `post-create.sh`

Runs **inside container** after first creation:

#### a) `setup-git-init.sh`

- Initializes git repository if not present
- Creates main branch

#### b) `setup-git-conf.sh`

- Copies git config from `.devcontainer/.conf/` to container's `~/.gitconfig`
- Installs SSH public key for commit signing
- Configures git hooks

#### c) `setup-project.sh`

- Detects project name from directory
- Updates `pyproject.toml` with project name
- Runs `uv sync` to install dependencies

#### d) `setup-precommit.sh`

- Installs pre-commit hooks from `.pre-commit-config.yaml`
- Downloads and caches all hook dependencies

### 3. Post-Attach (Every Container Attach) - `post-attach.sh`

Currently runs minimal operations. Can be extended for per-attach tasks.

## Troubleshooting

### Issue: Cannot pull container image

**Error:**

```text
Error response from daemon: unauthorized: authentication required
```

**Solution:**

1. Verify you're logged in to GHCR:

   ```bash
   docker login ghcr.io
   # or
   podman login ghcr.io
   ```

2. Check you have the correct token with `read:packages` scope

3. Verify token hasn't expired (GitHub Settings > Developer settings > Tokens)

### Issue: Git commit signing fails

**Error:**

```text
error: gpg failed to sign the data
```

**Solutions:**

1. **Check SSH key is present:**

   ```bash
   # Inside container
   ls -la ~/.ssh/id_ed25519_github.pub
   ```

2. **Verify git configuration:**

   ```bash
   git config --get gpg.format
   # Should show: ssh

   git config --get user.signingkey
   # Should show: /root/.ssh/id_ed25519_github.pub or similar
   ```

3. **Check key on host machine:**

   ```bash
   # On host
   ls -la ~/.ssh/id_ed25519_github.pub
   ```

4. **Re-run setup:**

   ```bash
   # On host, from project root
   .devcontainer/setup-user-conf.sh
   ```

5. **Rebuild container:**
   - VS Code: `F1` > `Dev Containers: Rebuild Container`

### Issue: Podman not working with VS Code

**Solutions:**

1. **Verify Podman is running:**

   ```bash
   podman info
   ```

   If this fails, Podman isn't properly running.

2. **Check Podman machine** (macOS/Windows only):

   ```bash
   # Check machine status
   podman machine list
   ```

   Common machine issues:

   **Machine not running:**

   ```bash
   # Start the machine
   podman machine start

   # If it fails to start, try reinitializing
   podman machine stop
   podman machine rm
   podman machine init
   podman machine start
   ```

   **Machine doesn't exist:**

   ```bash
   # Create a new machine
   podman machine init
   podman machine start
   ```

   **Machine stuck or corrupted:**

   ```bash
   # Remove and recreate
   podman machine stop
   podman machine rm
   podman machine init --cpus 2 --memory 4096 --disk-size 100
   podman machine start
   ```

3. **Verify VS Code setting:**

   ```bash
   # Check current setting
   code --list-extensions | grep remote-containers

   # Verify docker path setting
   cat ~/.vscode/settings.json | grep dockerPath
   ```

4. **Try full path to Podman:**

   ```bash
   # Find Podman location
   which podman

   # Update VS Code setting with full path
   ```

5. **Podman Desktop users:**

   - Open Podman Desktop
   - Check if the machine is running in the GUI
   - Try stopping and starting from the GUI
   - Check logs in Podman Desktop for specific errors

### Issue: Pre-commit hooks fail to install

**Error:**

```text
⚠️  Pre-commit install failed
```

**Solutions:**

1. **Manually install:**

   ```bash
   cd /workspace
   pre-commit install-hooks
   ```

2. **Check internet connectivity:**

   ```bash
   curl -I https://github.com
   ```

3. **Clear cache and retry:**

   ```bash
   rm -rf ~/.pre-commit-cache
   pre-commit install-hooks
   ```

### Issue: "This script must be run outside the container"

**Error when running `setup-user-conf.sh` inside container**

**Solution:**

This script **must** run on your host machine:

```bash
# On your host machine (not in container)
cd /path/to/project
.devcontainer/setup-user-conf.sh
```

### Issue: Docker-compose file not found

The `devcontainer.json` references `docker-compose.yaml`, but it may not exist in your project.

**Solutions:**

1. **Remove docker-compose reference** from `.devcontainer/devcontainer.json`:

   Change:

   ```json
   {
     "image": "ghcr.io/morepet/containers/dev/typst:1.3-dev",
     "dockerComposeFile": "../docker-compose.yaml",
     "service": "dev"
   }
   ```

   To:

   ```json
   {
     "image": "ghcr.io/morepet/containers/dev/typst:1.3-dev"
   }
   ```

2. **Or create a minimal docker-compose.yaml**:

   ```yaml
   version: '3.8'
   services:
     dev:
       image: ghcr.io/morepet/containers/dev/typst:1.3-dev
       volumes:
         - ..:/workspace:cached
       command: sleep infinity
   ```

## Advanced Configuration

### Custom Container Image

To use a different container image, edit `.devcontainer/devcontainer.json`:

```json
{
  "image": "ghcr.io/your-org/your-image:tag"
}
```

### Additional VS Code Extensions

Add extensions to `.devcontainer/devcontainer.json`:

```json
{
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-python.python",
        "charliermarsh.ruff",
        "your.extension-id"
      ]
    }
  }
}
```

### Environment Variables

Add environment variables:

```json
{
  "containerEnv": {
    "MY_VAR": "value",
    "DEBUG": "true"
  }
}
```

### Port Forwarding

Forward ports from container to host:

```json
{
  "forwardPorts": [8000, 3000],
  "portsAttributes": {
    "8000": {
      "label": "Web Server"
    }
  }
}
```

## Resources

- [Dev Containers documentation](https://code.visualstudio.com/docs/devcontainers/containers)
- [Dev Containers specification](https://containers.dev/)
- [GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- [GitHub SSH authentication](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)
- [GitHub commit signing](https://docs.github.com/en/authentication/managing-commit-signature-verification)
- [Podman documentation](https://docs.podman.io/)
- [Docker Desktop documentation](https://docs.docker.com/desktop/)

## See Also

- [Linter & Pre-commit Guide](LINTER_AND_PRECOMMIT.md) - Pre-commit hooks setup
- [Build System Documentation](BUILD_SYSTEM.md) - Build pipeline
- [Main README](../README.md) - Project overview
