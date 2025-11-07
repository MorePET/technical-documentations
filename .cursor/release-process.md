# Release Process

## Creating a New Release (PR-based)

**IMPORTANT**: Always release through a Pull Request for review.

### 1. Create Release Branch

```bash
git checkout main
git pull origin main
git checkout -b release/vX.Y.Z
```

### 2. Update CHANGELOG.md

- Use [Keep a Changelog](https://keepachangelog.com/) format
- **First release (0.x.0)**: Use only "Added" section
- **Subsequent releases**: Use appropriate sections:
  - Added: New features
  - Changed: Changes in existing functionality
  - Deprecated: Soon-to-be removed features
  - Removed: Removed features
  - Fixed: Bug fixes
  - Security: Security improvements

Example for first release:

```markdown
## [0.1.0] - 2025-01-06

### Added

- Feature 1
- Feature 2

[0.1.0]: https://github.com/ORG/REPO/releases/tag/v0.1.0
```

### 3. Commit and Push Release Branch

```bash
git add CHANGELOG.md
git commit -m "Release vX.Y.Z

- Brief summary of major changes
- One line per major feature/fix"

git push origin release/vX.Y.Z
```

### 4. Create Pull Request

```bash
gh pr create \
  --title "Release vX.Y.Z" \
  --body "## Release vX.Y.Z

$(sed -n '/## \[X.Y.Z\]/,/## \[/p' CHANGELOG.md | head -n -1)

## Pre-release Checklist

- [ ] CHANGELOG.md updated
- [ ] Version numbers updated (if applicable)
- [ ] All tests passing
- [ ] Documentation updated
- [ ] No breaking changes without major version bump"
```

### 5. Review and Merge

1. **Wait for PR review and approval**
2. **Ensure all CI checks pass**
3. **Merge using "Create a merge commit"** (not squash or rebase)
   - This creates a clean merge commit on main
   - Tag will point to this merge commit

### 6. Tag the Merge Commit

```bash
# Pull the merged changes
git checkout main
git pull origin main

# Create signed annotated tag
git tag -a vX.Y.Z -m "Release vX.Y.Z - Brief Description

Features:
- Major feature 1
- Major feature 2"

# Push tag
git push origin vX.Y.Z
```

Note: Tag is automatically signed with SSH key (configured in git)

### 7. Create GitHub Release

```bash
gh release create vX.Y.Z \
  --title "vX.Y.Z - Brief Description" \
  --notes "## Release Notes

$(sed -n '/## \[X.Y.Z\]/,/## \[/p' CHANGELOG.md | head -n -1)"
```

Or manually create release with notes matching the CHANGELOG content.

### 8. Clean Up

```bash
# Delete release branch
git branch -d release/vX.Y.Z
git push origin --delete release/vX.Y.Z
```

## Why PR-based Releases?

- ✅ Code review catches mistakes before tagging
- ✅ CI/CD runs on release changes
- ✅ Team visibility and discussion
- ✅ Prevents accidental releases
- ✅ Clean audit trail
- ✅ Ability to fix issues before going live

## Important Notes

- **Always** use merge commit (not squash/rebase) for release PRs
- **Never** commit after creating the tag (tag points to specific commit)
- **Never** include "Fixed" or "Changed" in first release (everything is "Added")
- **Always** wait for PR approval before merging
- **Always** keep CHANGELOG.md in the commit that the tag points to

## Emergency: Fix a Bad Release

If you need to fix a release that's already tagged:

```bash
# Delete tag locally and remotely
git tag -d vX.Y.Z
git push --delete origin vX.Y.Z

# Delete GitHub release
gh release delete vX.Y.Z --yes

# Create new PR with fixes
git checkout -b release/vX.Y.Z-fix
# Make fixes
git commit -m "Fix release vX.Y.Z"
gh pr create --title "Fix release vX.Y.Z"
# Merge PR

# Recreate tag on fixed merge commit
git checkout main
git pull
git tag -a vX.Y.Z -m "Release message"
git push origin vX.Y.Z

# Recreate GitHub release
gh release create vX.Y.Z ...
```

## Semantic Versioning

- **MAJOR** (X.0.0): Breaking changes
- **MINOR** (0.X.0): New features, backwards compatible
- **PATCH** (0.0.X): Bug fixes, backwards compatible

## Branch Protection

Recommended branch protection rules for `main`:

- Require pull request reviews before merging
- Require status checks to pass
- Require branches to be up to date before merging
- Do not allow bypassing the above settings
