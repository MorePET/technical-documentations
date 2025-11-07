# Typst Devcontainer Template

## Protected Linting Configuration Files

This repository protects critical linting configuration files from accidental modifications using a **simple read-only permission model**.

### Protected Files

The following files are set to **444 (read-only)** to prevent casual edits:

- `.pre-commit-config.yaml` - Pre-commit hooks configuration
- `pyproject.toml` - Python project dependencies and tool settings
- `.hadolint.yaml` - Containerfile/Dockerfile linting rules
- `.checkmake.ini` - Makefile linting rules
- `.yamllint` - YAML linting rules

### Why Protected?

These files control the linting and quality checks for the entire project. Accidental modifications can:
- Disable important security checks
- Break CI/CD pipelines
- Introduce inconsistent code formatting
- Allow bad code to slip through

### Security Model

**Layer 1: Warning Comments**
- Each file contains prominent "DO NOT EDIT" warnings
- Visual deterrent for casual modifications

**Layer 2: File Permissions (444)**
- Read-only for ALL users (including root and AI)
- Both manual tools and auto-fixers get "Permission denied"
- Forces conscious, deliberate modification

**Layer 3: Manual Intervention Required**
- If pre-commit auto-fixers fail on these files, you MUST manually review
- Explicit chmod required → visible in command history
- Changes appear in git commits

### How to Edit Protected Files

When you genuinely need to modify a protected configuration file:

```bash
# Option 1: Use the helper script (recommended)
edit-protected .pre-commit-config.yaml

# Option 2: Manual three-step process
chmod 644 .pre-commit-config.yaml
vim .pre-commit-config.yaml
chmod 444 .pre-commit-config.yaml
```

### Pre-commit Behavior

When pre-commit runs and encounters issues in protected files:

```text
fix end of files.........................................................Failed
- hook id: end-of-file-fixer
- exit code: 1

PermissionError: [Errno 13] Permission denied: '.pre-commit-config.yaml'

→ Manual intervention required! Use: edit-protected .pre-commit-config.yaml
```

This is **by design** - it forces you to consciously review and fix the issue.

### CI/CD Compatibility

✅ **GitHub Actions works fine** - Git doesn't store 444 permissions, so CI gets normal 644 files
✅ **Renovate can update** - PRs can modify files normally
✅ **Auto-merge works** - No permission issues in CI

The protection is **local only**, which is exactly what we want!

### Benefits

✅ **Simple** - Just 444 permissions, no complex user management
✅ **Effective** - Blocks both humans and AI from casual edits
✅ **Visible** - chmod commands appear in history/logs
✅ **CI-friendly** - No impact on automated workflows
✅ **Fail-safe** - Auto-fixers fail loudly instead of silently modifying

### Automated Setup

Protection is automatically applied during devcontainer creation:

```bash
.devcontainer/scripts/setup-protected-configs.sh
```

This runs as part of `.devcontainer/post-create.sh`.

### Verification

```bash
# Check permissions
ls -la .pre-commit-config.yaml
# Expected: -r--r--r-- ... .pre-commit-config.yaml

# Test protection
echo "test" >> .pre-commit-config.yaml
# Expected: Permission denied ✓
```

### Related

- GitHub Issue: [#9 - Protected config file security](https://github.com/MorePET/technical-documentations/issues/9)
- Setup script: `.devcontainer/scripts/setup-protected-configs.sh`
