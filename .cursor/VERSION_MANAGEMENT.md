# Version Management

This document explains how version numbers are managed in this project using a **single source of truth** approach.

## Single Source of Truth: `pyproject.toml`

The version number is defined **once** in `pyproject.toml`:

```toml
[project]
version = "0.3.2"
```

All other uses of the version number are derived from this file.

## Version Management Tools

### Get Current Version

```bash
# Using Python script
python3 scripts/get_version.py

# Using Make
make version
```

### Bump Version

The `bump_version.py` script automates version bumping following [Semantic Versioning](https://semver.org/):

```bash
# Bump patch version (0.3.2 → 0.3.3)
python3 scripts/bump_version.py patch

# Bump minor version (0.3.2 → 0.4.0)
python3 scripts/bump_version.py minor

# Bump major version (0.3.2 → 1.0.0)
python3 scripts/bump_version.py major

# Dry run (show what would happen)
python3 scripts/bump_version.py patch --dry-run

# Skip CHANGELOG update
python3 scripts/bump_version.py patch --no-changelog
```

**What it does:**

1. ✅ Updates version in `pyproject.toml`
2. ✅ Adds new version entry to `CHANGELOG.md` (with date)
3. ✅ Shows next steps (commit, tag, push)

### Using Make Targets

```bash
# Show current version
make version

# Bump patch version and show next steps
make bump-patch

# Bump minor version
make bump-minor

# Bump major version
make bump-major
```

## Release Workflow

### Automated Workflow with bump_version.py

```bash
# 1. Bump version (creates CHANGELOG entry)
python3 scripts/bump_version.py patch

# 2. Edit CHANGELOG.md to add actual changes
vim CHANGELOG.md

# 3. Commit
git add pyproject.toml CHANGELOG.md
git commit -m "chore(release): bump version to 0.3.3"

# 4. Tag
git tag -a 0.3.3 -m "Release 0.3.3"

# 5. Push
git push && git push --tags

# 6. Create GitHub release
gh release create 0.3.3 --title "Release 0.3.3" --notes-file RELEASE_NOTES.md
```

### Manual Workflow (Current)

If you prefer manual control:

```bash
# 1. Edit version in pyproject.toml
vim pyproject.toml

# 2. Edit CHANGELOG.md
vim CHANGELOG.md

# 3. Commit, tag, and push (same as above)
```

## Where Version is Used

### Automatically Derived

These locations automatically read from `pyproject.toml`:

- **Python scripts:** Can use `importlib.metadata.version("workspace")`
- **Build scripts:** Use `scripts/get_version.py`
- **Git tags:** Match the version in `pyproject.toml`
- **GitHub releases:** Use the git tag

### Manually Maintained

These must be updated manually (or use the bump script):

- **CHANGELOG.md:** Version entries with dates
- **Git tags:** Must match `pyproject.toml` version
- **GitHub releases:** Should match git tags

## Best Practices

### 1. Keep pyproject.toml as Source of Truth

**Always update `pyproject.toml` first**, then derive everywhere else.

### 2. Use Semantic Versioning

- **MAJOR** (X.0.0): Breaking changes
- **MINOR** (0.X.0): New features (backward compatible)
- **PATCH** (0.0.X): Bug fixes

### 3. Update CHANGELOG.md

Always document changes in CHANGELOG.md:

```markdown
## [0.3.3] - 2025-11-10

### Added
- New feature X

### Changed
- Updated component Y

### Fixed
- Bug in Z (#123)
```

### 4. Tag Matches Version

Git tags must **exactly match** the version in `pyproject.toml`:

```bash
# pyproject.toml has version = "0.3.2"
# Tag must be:
git tag 0.3.2  # ✅ Correct

# NOT:
git tag v0.3.2  # ❌ Wrong (extra 'v')
git tag 0.3     # ❌ Wrong (missing patch)
```

### 5. One Version, One Tag, One Release

**Never reuse version numbers:**
- Each commit gets a unique version
- Each version gets a unique tag
- Each tag gets a unique release

## Reading Version in Code

### Python

```python
# Using importlib.metadata (recommended)
from importlib.metadata import version
project_version = version("workspace")

# Using get_version.py
import subprocess
result = subprocess.run(
    ["python3", "scripts/get_version.py"],
    capture_output=True,
    text=True,
)
version = result.stdout.strip()
```

### Shell/Bash

```bash
# Using get_version.py
VERSION=$(python3 scripts/get_version.py)
echo "Version: $VERSION"

# Using grep/sed (fragile, not recommended)
VERSION=$(grep '^version = ' pyproject.toml | sed 's/version = "\(.*\)"/\1/')
```

### Make

```makefile
# Get version
VERSION := $(shell python3 scripts/get_version.py)

# Use in targets
release:
    @echo "Building version $(VERSION)"
    git tag $(VERSION)
```

## Troubleshooting

### Version Mismatch

If versions are out of sync:

```bash
# Check what's in pyproject.toml
python3 scripts/get_version.py

# Check git tags
git tag -l | tail -5

# Check latest release
gh release list --limit 5
```

**Fix:** Update everything to match `pyproject.toml`.

### CHANGELOG Missing Entry

If you forgot to update CHANGELOG:

```bash
# Add entry manually or run:
python3 scripts/bump_version.py patch --dry-run  # Preview
python3 scripts/bump_version.py patch             # Update
```

### Tag Already Exists

If you need to recreate a tag:

```bash
# Delete local tag
git tag -d 0.3.2

# Delete remote tag (CAREFUL!)
git push origin :refs/tags/0.3.2

# Create new tag
git tag -a 0.3.2 -m "Release 0.3.2"
git push --tags
```

## Advanced: setuptools_scm (Alternative)

For Python packages, you can use `setuptools_scm` to derive versions from git tags automatically:

```toml
# pyproject.toml
[build-system]
requires = ["setuptools>=45", "setuptools_scm[toml]>=6.2"]

[tool.setuptools_scm]
write_to = "src/_version.py"
```

Then version is **derived from git tags** instead of being manually set.

**Pros:**
- Version comes from git tags (single source of truth)
- No manual version updates needed

**Cons:**
- Requires clean git state
- More complex setup
- May not fit documentation-focused projects

## Summary

✅ **DO:**
- Keep version in `pyproject.toml` as single source
- Use `bump_version.py` for automated bumps
- Update CHANGELOG with each version
- Match git tags to `pyproject.toml` version
- Follow semantic versioning

❌ **DON'T:**
- Hardcode version in multiple files
- Reuse version numbers
- Forget to update CHANGELOG
- Use inconsistent tag formats
- Skip version bumps for releases
