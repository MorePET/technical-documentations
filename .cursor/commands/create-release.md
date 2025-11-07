# Create Release Command

This command guides you through the complete release process following the project's standards.

For complete documentation on release process, versioning, and requirements, see:

**[Release Process Documentation](./../release-process.md)**

## Workflow

**IMPORTANT**: Always release through a Pull Request for review and never directly on main branch.

### 1. Prepare Release Branch

```bash
# Start from latest main
git checkout main
git pull origin main

# Create release branch
git checkout -b release/v1.2.3
```

### 2. Update CHANGELOG.md

Follow [Keep a Changelog](https://keepachangelog.com/) format:

**First release (0.x.0)**: Use only "Added" section
**Subsequent releases**: Use appropriate sections:

- Added: New features
- Changed: Changes in existing functionality
- Deprecated: Soon-to-be removed features
- Removed: Removed features
- Fixed: Bug fixes
- Security: Security improvements

```markdown
## [1.2.3] - 2025-01-06

### Added
- New feature description

### Fixed
- Bug fix description

[1.2.3]: https://github.com/ORG/REPO/compare/v1.2.2...v1.2.3
```

### 3. Commit and Push Release Changes

```bash
git add CHANGELOG.md
git commit -m "Release v1.2.3

- Added new authentication feature
- Fixed database connection issue
- Updated documentation"
git push origin release/v1.2.3
```

### 4. Create Release Pull Request

```bash
gh pr create \
  --title "Release v1.2.3" \
  --body "## Release v1.2.3

$(sed -n '/## \[1.2.3\]/,/## \[/p' CHANGELOG.md | head -n -1)

## Pre-release Checklist

- [x] CHANGELOG.md updated
- [x] Version numbers updated (if applicable)
- [x] All tests passing
- [x] Documentation updated
- [x] No breaking changes without major version bump"
```

### 5. Wait for Review and Merge

- Wait for PR review and approval
- Ensure all CI checks pass
- Merge using "Create a merge commit" (not squash or rebase)

### 6. Tag the Release

```bash
# Pull merged changes
git checkout main
git pull origin main

# Create signed annotated tag
git tag -a v1.2.3 -m "Release v1.2.3

Features:
- New authentication system
- Improved error handling

Bug fixes:
- Database connection stability
- UI responsiveness issues"
```

### 7. Push Tag and Create GitHub Release

```bash
# Push tag
git push origin v1.2.3

# Create GitHub release
gh release create v1.2.3 \
  --title "v1.2.3 - New authentication and bug fixes" \
  --notes "## Release Notes

$(sed -n '/## \[1.2.3\]/,/## \[/p' CHANGELOG.md | head -n -1)"
```

### 8. Clean Up

```bash
# Delete release branch
git branch -d release/v1.2.3
git push origin --delete release/v1.2.3
```

## Quick Reference

### Minor Version Release (New Features)

```bash
# Create release branch
git checkout -b release/v1.1.0

# Update CHANGELOG.md with Added section
# Commit and push
git commit -m "Release v1.1.0 - Add user dashboard"
git push origin release/v1.1.0

# Create PR
gh pr create --title "Release v1.1.0"

# After merge, tag and release
git tag -a v1.1.0 -m "Release v1.1.0 - User dashboard and API improvements"
git push origin v1.1.0
gh release create v1.1.0 --title "v1.1.0 - User dashboard" --generate-notes
```

### Patch Release (Bug Fixes)

```bash
# Create release branch
git checkout -b release/v1.0.1

# Update CHANGELOG.md with Fixed section
# Commit and push
git commit -m "Release v1.0.1 - Security and bug fixes"
git push origin release/v1.0.1

# Create PR
gh pr create --title "Release v1.0.1"

# After merge, tag and release
git tag -a v1.0.1 -m "Release v1.0.1 - Critical security fixes"
git push origin v1.0.1
gh release create v1.0.1 --title "v1.0.1 - Security fixes" --generate-notes
```

### Major Version Release (Breaking Changes)

```bash
# Create release branch
git checkout -b release/v2.0.0

# Update CHANGELOG.md with breaking changes
# Consider migration guide in docs
git commit -m "Release v2.0.0 - API redesign"
git push origin release/v2.0.0

# Create PR with migration notes
gh pr create --title "Release v2.0.0"

# After merge, tag and release
git tag -a v2.0.0 -m "Release v2.0.0 - Complete API redesign with breaking changes"
git push origin v2.0.0
gh release create v2.0.0 --title "v2.0.0 - Major API update" --generate-notes
```

## Version Number Guidance

- **MAJOR** (X.0.0): Breaking changes, API changes
- **MINOR** (0.X.0): New features, backwards compatible
- **PATCH** (0.0.X): Bug fixes, backwards compatible

### When to Increment

**Major (X.0.0):**
- Breaking API changes
- Removal of features
- Significant architectural changes

**Minor (0.X.0):**
- New features
- New capabilities
- Enhancements that don't break existing code

**Patch (0.0.X):**
- Bug fixes
- Security patches
- Small improvements
- Documentation updates

## Pre-release Checklist

Before creating release PR:

- [ ] CHANGELOG.md updated with all changes since last release
- [ ] Version follows semantic versioning rules
- [ ] All tests passing
- [ ] CI/CD pipeline green
- [ ] Documentation updated
- [ ] Breaking changes clearly documented
- [ ] Migration guide provided (for major versions)
- [ ] Reviewed by at least one other team member

## Emergency: Fix a Bad Release

If you need to fix a release that's already tagged:

```bash
# Delete tag locally and remotely
git tag -d v1.2.3
git push --delete origin v1.2.3

# Delete GitHub release
gh release delete v1.2.3 --yes

# Create fix branch and make corrections
git checkout -b release/v1.2.3-fix
# Make fixes
git commit -m "Fix release v1.2.3"
git push origin release/v1.2.3-fix

# Create new PR
gh pr create --title "Fix release v1.2.3"

# After merge, recreate tag and release
git checkout main
git pull origin main
git tag -a v1.2.3 -m "Release v1.2.3 (fixed)"
git push origin v1.2.3
gh release create v1.2.3 --title "v1.2.3 - Fixed" --generate-notes
```

## Utility Commands

### Check Current Tags

```bash
git tag --sort=-version:refname | head -5
```

### Compare Tags

```bash
git log --oneline v1.2.2..v1.2.3
```

### Check if Tag Exists

```bash
git ls-remote --tags origin | grep v1.2.3
```

### View Tag Details

```bash
git show v1.2.3
```

---

**See [release-process.md](./../release-process.md) for complete release guidelines and requirements.**
