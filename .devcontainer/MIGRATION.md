# Migration Guide: Cross-Platform GPG Setup

## What Changed?

The dev container has been updated to use **SSH agent forwarding** for GPG keys instead of direct GPG socket mounting. This provides better cross-platform support.

### Old Approach (Platform-Specific)
- Required `GPG_SOCKET_PATH` environment variable
- Direct mount of GPG socket from host
- Only worked reliably on specific OS configurations
- Required manual socket path configuration

### New Approach (Cross-Platform)
- Uses VS Code's built-in SSH agent forwarding
- Works automatically on macOS, Linux, and Windows
- No environment variables needed
- Simpler and more maintainable

## Breaking Changes

### Removed
1. **`GPG_SOCKET_PATH` environment variable** - No longer needed
2. **`setup-user-conf.sh` script** - Replaced by `initialize.sh`
3. **Direct GPG socket mounts** - Replaced by SSH agent forwarding
4. **`docker-compose.yaml` service references** - Now uses direct build

### Changed
1. **`devcontainer.json`** - Simplified, no longer uses docker-compose
2. **`initialize.sh`** - New implementation with better error handling
3. **`docker-compose.yaml`** - Simplified, removed GPG socket mounts

### Added
1. **`post-create.sh`** - Handles container creation setup
2. **`post-attach.sh`** - Handles SSH/GPG verification on attach
3. **`.devcontainer/README.md`** - Comprehensive setup documentation
4. **`.devcontainer/MIGRATION.md`** - This file

## Migration Steps

### For Existing Users

1. **Remove environment variable**
   ```bash
   # Remove from your shell profile (~/.zshrc, ~/.bashrc, etc.)
   # Delete or comment out this line:
   export GPG_SOCKET_PATH="..."
   ```

2. **Restart your shell or reload profile**
   ```bash
   source ~/.zshrc  # or ~/.bashrc
   ```

3. **Rebuild the dev container**
   - In VS Code: Press `Cmd+Shift+P` (macOS) or `Ctrl+Shift+P` (Windows/Linux)
   - Select "Dev Containers: Rebuild Container"
   - Wait for the rebuild to complete

4. **Verify the setup**
   After the container rebuilds, check the output for:
   - ✓ SSH agent socket available
   - ✓ GPG has X public key(s) available
   - ✓ Git is configured to use signing key

### For New Users

Just open the repository in VS Code and select "Reopen in Container". Everything will be configured automatically!

## Troubleshooting Migration Issues

### Issue: Container fails to start

**Solution**: Make sure you've removed the `GPG_SOCKET_PATH` variable and restarted your shell.

### Issue: GPG keys not imported

**Solution**: 
1. Ensure GPG is installed on your host: `gpg --version`
2. Verify keys exist: `gpg --list-keys`
3. Rebuild the container to trigger re-import

### Issue: SSH agent not working

**Solution**:
1. Check ssh-agent on host: `ssh-add -l`
2. Add keys if needed: `ssh-add ~/.ssh/id_ed25519`
3. Restart VS Code
4. Rebuild container

### Issue: Commits not signed

**Solution**:
```bash
# Inside the container, verify:
git config --global user.signingkey
gpg --list-secret-keys

# If key is missing, rebuild container
```

## Rollback (If Needed)

If you need to rollback to the old setup:

```bash
git revert <commit-hash>
git checkout <previous-commit>
```

However, the new approach is recommended as it's more reliable and cross-platform.

## Benefits Summary

✅ Works on macOS, Linux, and Windows without changes  
✅ No manual environment variable configuration  
✅ Uses VS Code's built-in SSH forwarding  
✅ Better error messages and diagnostics  
✅ Simpler setup for new users  
✅ More maintainable codebase  

## Questions?

See [`.devcontainer/README.md`](.devcontainer/README.md) for detailed documentation and troubleshooting.




