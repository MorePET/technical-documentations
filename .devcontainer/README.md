# Dev Container Configuration

This dev container is configured for **SSH signing** of git commits, working cross-platform on **macOS**, **Linux**, and **Windows**.

## How It Works

### Cross-Platform SSH Agent Forwarding

VS Code Dev Containers automatically forwards your SSH agent into the container. This provides:
- ✅ **Git commit signing** using your SSH keys
- ✅ **SSH authentication** for git operations
- ✅ **Cross-platform compatibility** - no OS-specific configuration needed

### Setup Process

The container uses three lifecycle scripts:

1. **`initialize.sh`** (runs on host before container starts)
   - Exports your git configuration
   - Exports your SSH public key for signing
   - Verifies SSH agent is available

2. **`post-create.sh`** (runs once when container is created)
   - Imports git configuration
   - Configures git for SSH signing
   - Sets up SSH for git operations

3. **`post-attach.sh`** (runs every time you attach)
   - Verifies SSH agent forwarding
   - Tests SSH signing configuration
   - Displays diagnostic information

## Prerequisites

### 1. SSH Agent with Keys

Ensure you have an SSH agent running with your keys loaded:

```bash
# Check if ssh-agent is running and has keys
ssh-add -l

# If no agent, start one (varies by OS/shell)
eval "$(ssh-agent -s)"

# Add your SSH key
ssh-add ~/.ssh/id_ed25519  # or id_rsa, id_ecdsa
```

### 2. SSH Key

If you don't have an SSH key, generate one:

```bash
# Generate a new ED25519 key (recommended)
ssh-keygen -t ed25519 -C "your.email@example.com"

# Or RSA if ED25519 isn't supported
ssh-keygen -t rsa -b 4096 -C "your.email@example.com"

# Add it to your SSH agent
ssh-add ~/.ssh/id_ed25519
```

### 3. Git Configuration

Make sure your git user is configured:

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

## Platform-Specific Notes

### macOS

- Works out of the box with macOS Keychain
- SSH agent integration automatic
- No additional setup needed

### Linux

- Most distributions include `ssh-agent` by default
- GNOME: ssh-agent integration works automatically
- Other desktops: ensure `ssh-agent` is started in your shell profile

### Windows (WSL2)

- Use Windows OpenSSH agent (recommended)
- Start the service in PowerShell (as Administrator):
  ```powershell
  Get-Service ssh-agent | Set-Service -StartupType Automatic
  Start-Service ssh-agent
  ```
- Add keys in PowerShell: `ssh-add`
- WSL2 automatically forwards the Windows agent

## SSH Signing vs GPG Signing

### Why SSH Signing?

SSH signing (available since Git 2.34) has several advantages over GPG:

| Feature | SSH Signing | GPG Signing |
|---------|-------------|-------------|
| **Setup** | Use existing SSH keys | Need separate GPG keys |
| **Cross-platform** | Works everywhere | OS-specific socket paths |
| **Agent forwarding** | Built into VS Code | Requires manual setup |
| **Key management** | Same as git SSH | Separate keyring |
| **Expiration** | Keys don't expire | Keys expire |
| **Verification** | GitHub, GitLab support | Wide support |

### How It Works

```bash
# Git is configured to use SSH format
git config --global gpg.format ssh

# Your SSH public key is used for signing
git config --global user.signingkey ~/.ssh/id_ed25519.pub

# Commits are signed automatically
git config --global commit.gpgsign true
```

When you make a commit, git uses your SSH key (via the forwarded SSH agent) to create a signature.

## Troubleshooting

### SSH Agent Not Working

If `ssh-add -l` shows an error in the container:

1. Check ssh-agent on host: `ssh-add -l`
2. Ensure keys are added: `ssh-add ~/.ssh/id_ed25519`
3. On Windows, ensure SSH agent service is running
4. Restart the dev container

### No SSH Keys Found

If initialization can't find SSH keys:

1. Generate a key: `ssh-keygen -t ed25519 -C "your.email@example.com"`
2. Add to agent: `ssh-add ~/.ssh/id_ed25519`
3. Rebuild the container

### Commits Not Being Signed

If commits aren't signed:

1. Check signing is enabled: `git config --global commit.gpgsign`
2. Check signing key: `git config --global user.signingkey`
3. Verify key exists: `ls -la ~/.ssh/signing-key.pub` (in container)
4. Test SSH agent: `ssh-add -l` (in container)

### Signature Verification Failed

If GitHub/GitLab doesn't recognize signatures:

**Easy way** - Use the helper script:
```bash
/workspace/.devcontainer/setup-github-signing.sh
```

**Manual way**:
1. Add your SSH public key to your GitHub/GitLab account
2. Go to Settings → SSH and GPG keys → New SSH key
3. Select "Signing Key" as the key type
4. Paste your public key (`cat ~/.ssh/id_ed25519.pub`)

## Files Generated

The initialization process creates these files in `.devcontainer/.conf/` (gitignored):

- `.gitconfig` - Your processed git configuration
- `ssh-signing-key.pub` - Your SSH public key for signing
- `ssh-key-path.txt` - Path to your SSH key on host
- `ssh-auth-sock.txt` - SSH agent socket path (for reference)

## Testing SSH Signing

After the container starts:

```bash
# Check SSH agent
ssh-add -l

# Check git configuration
git config --global --list | grep -E "(gpg|sign)"

# Create a test signed commit
git commit --allow-empty -m "test signed commit"

# Verify the signature
git log --show-signature -1
```

You should see output like:
```
Good "git" signature for your.email@example.com with ED25519 key SHA256:...
```

## Benefits of This Approach

1. **Cross-platform**: Works on macOS, Linux, and Windows without changes
2. **Secure**: Keys never leave your host system
3. **Automatic**: SSH agent forwarding handled by VS Code
4. **Simple**: No manual socket path configuration needed
5. **Standard**: Uses VS Code's built-in forwarding mechanism
6. **Familiar**: Uses the same SSH keys you already have
7. **Maintained**: Relies on standard git SSH signing feature
