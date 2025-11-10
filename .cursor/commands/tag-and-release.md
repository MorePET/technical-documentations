# Tag and Release Command

This command automates the complete git tag creation and GitHub release workflow.

## Usage

```bash
/tag-and-release
```

**Purpose:** Create a git tag and GitHub release for the current version in pyproject.toml.

## Prerequisites

Before running this command, ensure:

- [ ] On **main** branch
- [ ] **Clean working directory** (no uncommitted changes)
- [ ] **Version bumped** in pyproject.toml (via `make bump-patch/minor/major`)
- [ ] **CHANGELOG.md updated** with release notes for current version
- [ ] All changes **committed** to main

## Workflow

The command performs these steps automatically:

### 1. Check for Version Bump Instruction (Optional)

**Read bump type from recent commits:**

```bash
# Check if recent commits indicate a version bump
# Look for [patch], [minor], or [major] in commit messages
RECENT_COMMIT=$(git log -1 --pretty=%B)
BUMP_TYPE=""

if echo "$RECENT_COMMIT" | grep -q "\[patch\]"; then
  BUMP_TYPE="patch"
elif echo "$RECENT_COMMIT" | grep -q "\[minor\]"; then
  BUMP_TYPE="minor"
elif echo "$RECENT_COMMIT" | grep -q "\[major\]"; then
  BUMP_TYPE="major"
fi

# If bump type found, apply it automatically
if [ -n "$BUMP_TYPE" ]; then
  CURRENT=$(make version | grep -oP '\d+\.\d+\.\d+')
  echo "🔄 Auto-applying $BUMP_TYPE bump from commit instruction"
  echo "   Current: $CURRENT"

  make bump-$BUMP_TYPE

  NEW=$(make version | grep -oP '\d+\.\d+\.\d+')
  echo "   New: $NEW"
  echo ""

  # Commit the bump
  git add pyproject.toml CHANGELOG.md
  git commit -m "chore(release): apply $BUMP_TYPE bump to $NEW

Auto-bumped based on PR merge commit instruction."

  echo "✅ Version auto-bumped: $CURRENT → $NEW"
fi
```

**How it works:**

When `/create-pr` commits a version bump, it includes `[patch]`, `[minor]`,
or `[major]` in the commit message. After PR merge, `/tag-and-release`
reads this and automatically applies the bump before creating the release.

This eliminates manual version bumping after merging PRs!

### 2. Validate Prerequisites

**Branch Check:**

```bash
# Must be on main
BRANCH=$(git branch --show-current)
if [ "$BRANCH" != "main" ]; then
  echo "❌ Error: Must be on main branch (currently on: $BRANCH)"
  exit 1
fi
```

**Working Directory Check:**

```bash
# Must be clean
if ! git diff-index --quiet HEAD --; then
  echo "❌ Error: Working directory has uncommitted changes"
  echo "Commit or stash changes before creating release"
  exit 1
fi
```

### 2. Get and Validate Version

**Extract version from pyproject.toml:**

```bash
# Use make version to get current version
VERSION=$(make version | grep -oP '\d+\.\d+\.\d+')
echo "Current version: $VERSION"
```

**Validate version format:**

```bash
# Must match X.Y.Z format (Semantic Versioning)
if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "❌ Error: Invalid version format: $VERSION"
  echo "Expected: X.Y.Z (e.g., 0.3.3)"
  exit 1
fi
```

**Check version is consecutive to existing tags:**

```bash
# Get latest tag
LATEST_TAG=$(git tag -l | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -1)

if [ -z "$LATEST_TAG" ]; then
  echo "ℹ️  No previous tags found - this will be the first release"
else
  echo "Latest tag: $LATEST_TAG"
  echo "New version: $VERSION"

  # Version must be greater than latest tag
  LATEST_SEMVER=$(echo "$LATEST_TAG" | sed 's/v//')
  if [ "$VERSION" == "$LATEST_SEMVER" ]; then
    echo "❌ Error: Version $VERSION already exists as a tag"
    echo "Bump version using: make bump-patch/minor/major"
    exit 1
  fi

  # Check if version is consecutive (no gaps)
  # Parse versions
  IFS='.' read -r -a LATEST_PARTS <<< "$LATEST_SEMVER"
  IFS='.' read -r -a NEW_PARTS <<< "$VERSION"

  LATEST_MAJOR=${LATEST_PARTS[0]}
  LATEST_MINOR=${LATEST_PARTS[1]}
  LATEST_PATCH=${LATEST_PARTS[2]}

  NEW_MAJOR=${NEW_PARTS[0]}
  NEW_MINOR=${NEW_PARTS[1]}
  NEW_PATCH=${NEW_PARTS[2]}

  # Validate consecutive bump
  VALID=false
  # Major bump: X.0.0
  if [ "$NEW_MAJOR" -eq $((LATEST_MAJOR + 1)) ] && \
     [ "$NEW_MINOR" -eq 0 ] && [ "$NEW_PATCH" -eq 0 ]; then
    VALID=true
  # Minor bump: 0.X.0
  elif [ "$NEW_MAJOR" -eq "$LATEST_MAJOR" ] && \
       [ "$NEW_MINOR" -eq $((LATEST_MINOR + 1)) ] && \
       [ "$NEW_PATCH" -eq 0 ]; then
    VALID=true
  # Patch bump: 0.0.X
  elif [ "$NEW_MAJOR" -eq "$LATEST_MAJOR" ] && \
       [ "$NEW_MINOR" -eq "$LATEST_MINOR" ] && \
       [ "$NEW_PATCH" -eq $((LATEST_PATCH + 1)) ]; then
    VALID=true
  fi

  if [ "$VALID" = "false" ]; then
    echo "❌ Error: Version $VERSION is not consecutive to $LATEST_SEMVER"
    echo ""
    echo "Valid next versions:"
    echo "  - Patch: $LATEST_MAJOR.$LATEST_MINOR.$((LATEST_PATCH + 1))"
    echo "  - Minor: $LATEST_MAJOR.$((LATEST_MINOR + 1)).0"
    echo "  - Major: $((LATEST_MAJOR + 1)).0.0"
    exit 1
  fi
fi
```

### 3. Validate CHANGELOG.md Format

**Check version entry exists:**

```bash
# CHANGELOG must have entry for current version
if ! grep -q "^## \[$VERSION\]" CHANGELOG.md; then
  echo "❌ Error: CHANGELOG.md missing entry for version $VERSION"
  echo ""
  echo "Expected format:"
  echo "## [$VERSION] - YYYY-MM-DD"
  echo ""
  echo "Update CHANGELOG.md before creating release"
  exit 1
fi
```

**Validate Keep a Changelog format:**

```bash
# Extract the version entry
ENTRY=$(sed -n "/^## \[$VERSION\]/,/^## \[/p" CHANGELOG.md | head -n -1)

# Check for date
DATE_PATTERN="^## \[$VERSION\] - [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}"
if ! echo "$ENTRY" | grep -q "$DATE_PATTERN"; then
  echo "❌ Error: Version entry missing or incorrectly formatted date"
  echo "Expected: ## [$VERSION] - YYYY-MM-DD"
  exit 1
fi

# Check for at least one category (Added, Changed, Fixed, etc.)
CATEGORIES="Added|Changed|Deprecated|Removed|Fixed|Security"
if ! echo "$ENTRY" | grep -qE "^### ($CATEGORIES)"; then
  echo "❌ Error: CHANGELOG entry must have at least one category"
  echo "Categories: Added, Changed, Deprecated, Removed, Fixed, Security"
  exit 1
fi

echo "✅ CHANGELOG.md format valid"
```

### 4. Extract Release Notes

**Parse CHANGELOG for current version:**

```bash
# Extract release notes for this version
RELEASE_NOTES=$(sed -n "/^## \[$VERSION\]/,/^## \[/p" CHANGELOG.md | head -n -1)

# Extract title from first line after version header
# Look for main feature/category
RELEASE_TITLE="Release $VERSION"

# Try to determine feature name from CHANGELOG
# Look for the first major feature in Added or Changed sections
FEATURE_NAME=$(echo "$RELEASE_NOTES" | grep -A1 "^### Added" | \
  tail -1 | sed 's/^- \*\*//' | sed 's/\*\*.*//' | head -c 40)
if [ -n "$FEATURE_NAME" ]; then
  RELEASE_TITLE="Release $VERSION - $FEATURE_NAME"
fi
```

### 5. Create Git Tag

**Create annotated tag:**

```bash
# Create tag with message from CHANGELOG
TAG_MESSAGE="Release $VERSION

$RELEASE_NOTES"

git tag -a "$VERSION" -m "$TAG_MESSAGE"
echo "✅ Created tag: $VERSION"
```

### 6. Push Tag

**Push to remote:**

```bash
git push --tags
echo "✅ Pushed tag: $VERSION"
```

### 7. Create GitHub Release

**Format release notes:**

```bash
# Create release with formatted notes
# Add comparison link
PREV_TAG=$(git tag -l | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | \
  sort -V | tail -2 | head -1)
COMPARISON_LINK=""
if [ -n "$PREV_TAG" ]; then
  REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
  COMPARISON_URL="https://github.com/$REPO/compare/$PREV_TAG...$VERSION"
  COMPARISON_LINK="\n\n---\n\n**Full Changelog**: $COMPARISON_URL"
fi

# Create release
gh release create "$VERSION" \
  --title "$RELEASE_TITLE" \
  --notes "$RELEASE_NOTES$COMPARISON_LINK"

echo "✅ Created GitHub release: $VERSION"
```

## Complete Example

Here's what the command does step-by-step:

```bash
# 1. Validate prerequisites
echo "Validating prerequisites..."
# - Check on main branch
# - Check clean working directory

# 2. Get version
echo "Getting version from pyproject.toml..."
VERSION=$(make version | grep -oP '\d+\.\d+\.\d+')
echo "Current version: $VERSION"

# 3. Validate version continuity
echo "Validating version continuity..."
LATEST_TAG=$(git tag -l | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -1)
echo "Latest tag: $LATEST_TAG"
# - Check version is consecutive (no gaps)

# 4. Validate CHANGELOG
echo "Validating CHANGELOG.md..."
# - Check entry exists for $VERSION
# - Validate format: ## [X.Y.Z] - YYYY-MM-DD
# - Check has categories (Added/Changed/Fixed/etc.)

# 5. Extract release notes
echo "Extracting release notes from CHANGELOG..."
RELEASE_NOTES=$(sed -n "/^## \[$VERSION\]/,/^## \[/p" CHANGELOG.md | head -n -1)

# 6. Create tag
echo "Creating git tag..."
git tag -a "$VERSION" -m "Release $VERSION

$RELEASE_NOTES"

# 7. Push tag
echo "Pushing tag to remote..."
git push --tags

# 8. Create GitHub release
echo "Creating GitHub release..."
gh release create "$VERSION" \
  --title "Release $VERSION - Feature Name" \
  --notes "$RELEASE_NOTES

---

**Full Changelog**: https://github.com/ORG/REPO/compare/$PREV_TAG...$VERSION"

echo "✅ Release complete: $VERSION"
```

## Error Handling

### Not on Main Branch

```text
❌ Error: Must be on main branch (currently on: feature/xyz)

Switch to main:
  git checkout main
```

### Uncommitted Changes

```text
❌ Error: Working directory has uncommitted changes

Uncommitted files:
  - file1.py
  - file2.md

Action required:
  1. Commit changes: git add . && git commit -m "..."
  2. Or stash: git stash save "wip"

Then run /tag-and-release again
```

### Version Already Tagged

```text
❌ Error: Version 0.3.3 already exists as a tag

Current version in pyproject.toml: 0.3.3
Existing tags: 0.3.0, 0.3.1, 0.3.2, 0.3.3

Action required:
  Bump version using:
    make bump-patch  # → 0.3.4
    make bump-minor  # → 0.4.0
    make bump-major  # → 1.0.0
```

### Non-Consecutive Version

```text
❌ Error: Version 0.3.5 is not consecutive to 0.3.2

Latest tag: 0.3.2
New version: 0.3.5 (skips 0.3.3 and 0.3.4)

Valid next versions:
  - Patch: 0.3.3
  - Minor: 0.4.0
  - Major: 1.0.0

Action required:
  Update pyproject.toml to a consecutive version
```

### Missing CHANGELOG Entry

```text
❌ Error: CHANGELOG.md missing entry for version 0.3.3

Expected format:
## [0.3.3] - 2025-11-10

### Added
- New features

### Changed
- Changes to functionality

### Fixed
- Bug fixes

Action required:
  1. Add CHANGELOG entry for version 0.3.3
  2. Follow Keep a Changelog format
  3. Run /tag-and-release again

Reference: https://keepachangelog.com/en/1.0.0/
```

### Invalid CHANGELOG Format

```text
❌ Error: CHANGELOG entry for 0.3.3 is incorrectly formatted

Found:
## [0.3.3]

Expected:
## [0.3.3] - YYYY-MM-DD

### Added
- Feature 1

### Changed
- Change 1

Action required:
  1. Add date to version header
  2. Add at least one category section
  3. Add entries under categories

Reference: https://keepachangelog.com/en/1.0.0/
```

## Keep a Changelog Format Summary

CHANGELOG.md must follow this structure:

```markdown
## [X.Y.Z] - YYYY-MM-DD

### Added
- New features for users

### Changed
- Changes to existing functionality

### Deprecated
- Soon-to-be removed features

### Removed
- Removed features

### Fixed
- Bug fixes

### Security
- Security vulnerability fixes
```

**Requirements:**
- Version header: `## [X.Y.Z] - YYYY-MM-DD`
- Most recent version at top
- At least one category section
- Entries are bullet points
- Focus on user-facing changes

**Reference:** [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)

## Semantic Versioning Summary

Versions follow **MAJOR.MINOR.PATCH** format (e.g., 1.4.2):

- **MAJOR (X.0.0)**: Incompatible API changes (breaking changes)
- **MINOR (0.X.0)**: New features (backward compatible)
- **PATCH (0.0.X)**: Bug fixes (backward compatible)

**Rules:**
- Never reuse version numbers
- Must be consecutive (no skipping versions)
- Initial development starts at 0.1.0
- Public API starts at 1.0.0

**Reference:** [Semantic Versioning](https://semver.org/spec/v2.0.0.html)

## Complete Release Workflow

### Typical Release Process

```bash
# 1. Work on feature branch
git checkout -b feature/new-feature
# ... make changes ...
git commit -m "feat(scope): add new feature"

# 2. Create PR with version bump (see create-pr.md)
/create-pr  # Will suggest version bump

# 3. PR gets reviewed and merged to main
# ... review, approve, merge ...

# 4. Switch to main and pull
git checkout main
git pull origin main

# 5. Create tag and release
/tag-and-release

# Done! Tag and release created automatically
```

### Quick Release (Already on Main)

If you're already on main with version bumped and CHANGELOG updated:

```bash
# Just run the command
/tag-and-release
```

It will:
- ✅ Validate everything
- ✅ Create git tag
- ✅ Push tag to remote
- ✅ Create GitHub release with CHANGELOG notes

## Integration with Version Management

This command integrates with the version management system:

```bash
# 1. Bump version
make bump-patch  # or bump-minor, bump-major

# 2. Update CHANGELOG.md
vim CHANGELOG.md
# Add actual changes for the version

# 3. Commit version bump
git add pyproject.toml CHANGELOG.md
git commit -m "chore(release): bump version to X.Y.Z"

# 4. Push to main
git push origin main

# 5. Create tag and release
/tag-and-release
```

## Success Output

```text
🚀 Creating Tag and Release for v0.3.3

✅ Prerequisites validated
   - On main branch
   - Working directory clean

✅ Version validated: 0.3.3
   - Latest tag: 0.3.2
   - Consecutive bump: ✓ (patch)

✅ CHANGELOG.md validated
   - Entry exists: ## [0.3.3] - 2025-11-10
   - Format correct: ✓
   - Categories present: Added, Changed

✅ Release notes extracted

✅ Git tag created: 0.3.3

✅ Tag pushed to remote

✅ GitHub release created
   - Title: Release 0.3.3 - Version Management System
   - URL: https://github.com/ORG/REPO/releases/tag/0.3.3

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎉 Release 0.3.3 Complete!

View release: https://github.com/ORG/REPO/releases/tag/0.3.3
```

## Troubleshooting

### Issue: Tag Creation Fails

**Error:**

```bash
fatal: tag '0.3.3' already exists
```

**Solution:**

The tag already exists locally or remotely.

```bash
# Check existing tags
git tag -l | grep 0.3.3

# If you need to recreate (CAREFUL):
git tag -d 0.3.3              # Delete local
git push origin :refs/tags/0.3.3  # Delete remote (CAREFUL!)

# Then run /tag-and-release again
```

### Issue: Push Fails

**Error:**

```bash
error: failed to push some refs
```

**Solution:**

Network issue or permissions problem.

```bash
# Verify authentication
gh auth status

# Verify remote
git remote -v

# Try pushing again
git push --tags
```

### Issue: CHANGELOG Format Invalid

**Error:**

```text
❌ Error: CHANGELOG entry must have at least one category
```

**Solution:**

Add at least one category section to your CHANGELOG entry:

```markdown
## [0.3.3] - 2025-11-10

### Added
- New feature X

### Fixed
- Bug in Y
```

### Issue: GitHub Release Creation Fails

**Error:**

```bash
HTTP 422: Validation Failed
```

**Solution:**

Tag might already have a release. Check:

```bash
# List releases
gh release list | grep 0.3.3

# If release exists, delete and recreate
gh release delete 0.3.3 --yes

# Then run /tag-and-release again
```

## Related Commands

- **[git-commit.md](./git-commit.md)**: Commit changes before release
- **[create-pr.md](./create-pr.md)**: Create PR with version bumping
- **[Version Management](./../../docs/VERSION_MANAGEMENT.md)**: Version management system docs

## Quick Reference

### Command Execution

```bash
/tag-and-release
```

### Prerequisites Checklist

Before running, ensure:
- [ ] On main branch: `git branch --show-current`
- [ ] Clean working directory: `git status`
- [ ] Version bumped in pyproject.toml
- [ ] CHANGELOG.md updated with:
  - [ ] Version header: `## [X.Y.Z] - YYYY-MM-DD`
  - [ ] At least one category
  - [ ] Actual release notes
- [ ] Changes committed and pushed to main

### What It Does

1. ✅ Validates prerequisites (branch, working directory, version)
2. ✅ Checks version is consecutive to latest tag
3. ✅ Validates CHANGELOG.md format
4. ✅ Extracts release notes
5. ✅ Creates annotated git tag
6. ✅ Pushes tag to remote
7. ✅ Creates GitHub release with CHANGELOG notes

### Version Management Tools

```bash
# Check current version
make version

# Bump versions
make bump-patch  # 0.3.3 → 0.3.4
make bump-minor  # 0.3.3 → 0.4.0
make bump-major  # 0.3.3 → 1.0.0
```

---

**For version management details, see [docs/VERSION_MANAGEMENT.md](./../../docs/VERSION_MANAGEMENT.md)**
