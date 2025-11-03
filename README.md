# Technical Documentations

This repository contains technical documentation generation template using Typst.

## Overview

Repository for managing technical documentation of the EXOPET projects.

## Requirements

- VS Code with Dev Containers extension
- Docker Desktop or compatible container runtime
- (Optional) SSH agent with keys for git operations
- (Optional) GPG keys for commit signing

## Getting Started

### 1. Open in Dev Container

Open this repository in VS Code and select "Reopen in Container" when prompted. The dev container will automatically:

- Set up the Typst development environment
- Import your git configuration
- Import your GPG keys (if available)
- Forward your SSH agent for git operations

### 2. First Time Setup

If you want to use GPG signing for commits, ensure you have:

1. An SSH agent running with your keys: `ssh-add -l`
2. GPG installed on your host: `gpg --version`
3. Git configured with your identity:
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   ```

See [`.devcontainer/README.md`](.devcontainer/README.md) for detailed setup instructions and troubleshooting.

## Cross-Platform Support

This dev container works seamlessly on:
- **macOS** - with native ssh-agent
- **Linux** - with ssh-agent or GNOME Keyring
- **Windows** - via WSL2 and Windows SSH agent

No manual configuration of GPG socket paths required!
