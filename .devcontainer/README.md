# Dev Container Configuration

This dev container is configured to work with GPG signing across **macOS**, **Linux**, and **Windows** using SSH agent forwarding.

## How It Works

### Cross-Platform SSH Agent Forwarding

VS Code Dev Containers automatically forwards your SSH agent into the container when available. This works seamlessly across all platforms:

- **macOS**: Works with native `ssh-agent` or external agents like GPG Suite
- **Linux**: Works with `ssh-agent`, `gpg-agent`, or GNOME Keyring
- **Windows**: Works with Windows OpenSSH agent or Pageant via WSL2

### Setup Process

The container uses three lifecycle scripts:

1. **`initialize.sh`** (runs on host before container starts)
   - Exports your git configuration
   - Exports GPG public keys and ownertrust
   - Captures SSH agent information

2. **`post-create.sh`** (runs once when container is created)
   - Imports git configuration
   - Imports GPG keys
   - Configures GPG agent
   - Sets up git signing configuration

3. **`post-attach.sh`** (runs every time you attach)
   - Verifies SSH agent forwarding
   - Tests GPG availability
   - Displays diagnostic information

## Prerequisites

### 1. SSH Agent with Keys

Ensure you have an SSH agent running on your host with your keys loaded:

```bash
# Check if ssh-agent is running and has keys
ssh-add -l

# If no agent, start one (varies by OS/shell)
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519  # or your key path
```

### 2. GPG Keys

If you want to use GPG signing in the container, make sure GPG is installed on your host and you have keys:

```bash
# Check for GPG keys
gpg --list-secret-keys --keyid-format LONG

# If you need to generate a key
gpg --full-generate-key
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
- Docker Desktop automatically handles SSH socket forwarding
- GPG Suite integrates well if installed

### Linux

- Most distributions include `ssh-agent` by default
- If using GNOME, ssh-agent integration works automatically
- For other desktops, ensure `ssh-agent` is started in your shell profile

### Windows (WSL2)

- Use Windows OpenSSH agent (recommended)
- Start the service: `Get-Service ssh-agent | Set-Service -StartupType Automatic`
- Add keys using PowerShell: `ssh-add`
- WSL2 automatically forwards the Windows agent

## Troubleshooting

### SSH Agent Not Working

If `ssh-add -l` shows an error in the container:

1. Check that ssh-agent is running on your host
2. Ensure keys are added: `ssh-add ~/.ssh/id_ed25519`
3. On Windows, ensure Windows SSH agent service is running
4. Restart the dev container

### GPG Keys Not Available

If GPG keys aren't imported:

1. Check that GPG is installed on your host: `gpg --version`
2. Verify keys exist: `gpg --list-keys`
3. Rebuild the container to re-import keys
4. Check `.devcontainer/.conf/` for exported keys

### Git Signing Not Working

If commits aren't being signed:

1. Check GPG key is configured: `git config --global user.signingkey`
2. Verify GPG can access keys: `gpg --list-secret-keys`
3. Test signing: `echo "test" | gpg --clearsign`
4. Check GPG agent is running: `gpgconf --list-components`

## Files Generated

The initialization process creates these files in `.devcontainer/.conf/` (gitignored):

- `.gitconfig` - Your processed git configuration
- `gpg-public-keys.asc` - Exported public GPG keys
- `gpg-ownertrust.txt` - GPG key trust database
- `gpg-signing-key.txt` - Your GPG signing key ID
- `ssh-auth-sock.txt` - SSH agent socket path (for reference)

## Removed Files

The following files are no longer needed with this approach:

- `setup-user-conf.sh` - Replaced by `initialize.sh`
- Environment variable `GPG_SOCKET_PATH` - No longer required

## Benefits of This Approach

1. **Cross-platform**: Works on macOS, Linux, and Windows without changes
2. **Secure**: Keys never leave your host system
3. **Automatic**: SSH agent forwarding handled by VS Code
4. **Simple**: No manual socket path configuration needed
5. **Maintained**: Uses VS Code's built-in forwarding mechanism
