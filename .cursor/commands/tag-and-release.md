# Tag and Release Command

**CREATES GIT TAG AND GITHUB RELEASE - FULLY AUTOMATED**

Execute `/tag-and-release` after PR merge to create git tag and GitHub release from CHANGELOG.

## PREREQUISITES

- On `main` branch
- Clean working directory
- Version already bumped in `pyproject.toml` (from `/create-pr`)
- CHANGELOG.md updated with version entry
- All changes committed and merged

## EXECUTION PROTOCOL

### STEP 1: VALIDATE PREREQUISITES

```bash
BRANCH=$(git branch --show-current)
```

**DECISION POINT: On main branch?**

**IF NOT main:**
```text
❌ Error: Must be on main branch
Current: $BRANCH

Run: git checkout main
```
→ ABORT

**IF main:**
→ PROCEED to working directory check

```bash
git diff-index --quiet HEAD --
```

**DECISION POINT: Working directory clean?**

**IF NOT clean:**
```text
❌ Error: Uncommitted changes detected

Modified files:
[list files]

Action: Commit or stash changes
```
→ ABORT

**IF clean:**
→ PROCEED to STEP 2

### STEP 2: GET AND VALIDATE VERSION

```bash
VERSION=$(make version | grep -oP '\d+\.\d+\.\d+')
```

**Validate format (X.Y.Z):**
```bash
if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "❌ Invalid version format: $VERSION"
  exit 1
fi
```

**Get latest tag:**
```bash
LATEST_TAG=$(git tag -l | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -1)
```

**DECISION POINT: Latest tag exists?**

**IF NO tags:**
→ Display: "ℹ️ No previous tags - first release"
→ PROCEED to STEP 3

**IF tags exist:**
→ Validate version is consecutive

**Parse versions:**
```bash
IFS='.' read -r -a LATEST_PARTS <<< "$LATEST_TAG"
IFS='.' read -r -a NEW_PARTS <<< "$VERSION"

LATEST_MAJOR=${LATEST_PARTS[0]}
LATEST_MINOR=${LATEST_PARTS[1]}
LATEST_PATCH=${LATEST_PARTS[2]}

NEW_MAJOR=${NEW_PARTS[0]}
NEW_MINOR=${NEW_PARTS[1]}
NEW_PATCH=${NEW_PARTS[2]}
```

**Validate consecutive:**
```bash
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
```

**IF NOT consecutive:**
```text
❌ Error: Version $VERSION not consecutive to $LATEST_TAG

Valid next versions:
- Patch: $LATEST_MAJOR.$LATEST_MINOR.$((LATEST_PATCH + 1))
- Minor: $LATEST_MAJOR.$((LATEST_MINOR + 1)).0
- Major: $((LATEST_MAJOR + 1)).0.0

Current: $LATEST_TAG
Attempted: $VERSION
```
→ ABORT

**IF consecutive:**
→ PROCEED to STEP 3

### STEP 3: VALIDATE CHANGELOG

```bash
grep -q "^## \[$VERSION\]" CHANGELOG.md
```

**DECISION POINT: Version entry exists?**

**IF NOT exists:**
```text
❌ Error: CHANGELOG.md missing entry for $VERSION

Expected format:
## [$VERSION] - YYYY-MM-DD

### Added
- Features

### Changed
- Modifications

### Fixed
- Bug fixes
```
→ ABORT

**IF exists:**
→ Validate format

```bash
ENTRY=$(sed -n "/^## \[$VERSION\]/,/^## \[/p" CHANGELOG.md | head -n -1)
DATE_PATTERN="^## \[$VERSION\] - [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}"

if ! echo "$ENTRY" | grep -q "$DATE_PATTERN"; then
  echo "❌ Error: Version entry missing date"
  exit 1
fi

CATEGORIES="Added|Changed|Deprecated|Removed|Fixed|Security"
if ! echo "$ENTRY" | grep -qE "^### ($CATEGORIES)"; then
  echo "❌ Error: CHANGELOG must have at least one category"
  exit 1
fi
```

**IF validation fails:**
→ Display specific error
→ ABORT

**IF validation succeeds:**
→ Display: "✅ CHANGELOG.md format valid"
→ PROCEED to STEP 4

### STEP 4: EXTRACT RELEASE NOTES

```bash
RELEASE_NOTES=$(sed -n "/^## \[$VERSION\]/,/^## \[/p" CHANGELOG.md | head -n -1)

# Determine release title from first major feature
FEATURE_NAME=$(echo "$RELEASE_NOTES" | grep -A1 "^### Added" | \
  tail -1 | sed 's/^- \*\*//' | sed 's/\*\*.*//' | head -c 40)

if [ -n "$FEATURE_NAME" ]; then
  RELEASE_TITLE="Release $VERSION - $FEATURE_NAME"
else
  RELEASE_TITLE="Release $VERSION"
fi
```

### STEP 5: CREATE GIT TAG

```bash
TAG_MESSAGE="Release $VERSION

$RELEASE_NOTES"

git tag -a "$VERSION" -m "$TAG_MESSAGE"
```

**Display:** "✅ Created tag: $VERSION"

### STEP 6: PUSH TAG

```bash
git push --tags
```

**IF push fails (authentication):**
```bash
gh auth setup-git
git push --tags
```

**IF push fails (tag exists remotely):**
```text
❌ Error: Tag $VERSION already exists on remote

To delete and recreate (DANGEROUS):
git push origin :refs/tags/$VERSION
git tag -d $VERSION
[Then run /tag-and-release again]
```
→ ABORT

**IF push succeeds:**
→ Display: "✅ Pushed tag: $VERSION"
→ PROCEED to STEP 7

### STEP 7: CREATE GITHUB RELEASE

```bash
# Get previous tag for comparison link
PREV_TAG=$(git tag -l | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | \
  sort -V | tail -2 | head -1)

# Build comparison link
if [ -n "$PREV_TAG" ]; then
  REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
  COMPARISON_URL="https://github.com/$REPO/compare/$PREV_TAG...$VERSION"
  COMPARISON_LINK="\n\n---\n\n**Full Changelog**: $COMPARISON_URL"
else
  COMPARISON_LINK=""
fi

# Create release
gh release create "$VERSION" \
  --title "$RELEASE_TITLE" \
  --notes "$RELEASE_NOTES$COMPARISON_LINK"
```

**IF release creation fails:**
→ Check if release already exists: `gh release list | grep $VERSION`
→ If exists: Delete with `gh release delete $VERSION --yes`
→ Retry release creation

**IF release succeeds:**
→ Display: "✅ Created GitHub release: $VERSION"
→ PROCEED to STEP 8

### STEP 8: COMPLETION REPORT

```text
✅ Tag and Release Complete

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📦 Release Details

Version: $VERSION
Previous: $PREV_TAG
Type: [patch/minor/major]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Actions Completed

- Git tag created: $VERSION
- Tag pushed to remote
- GitHub release created
- Release notes from CHANGELOG

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔗 URLs

Tag: https://github.com/$REPO/releases/tag/$VERSION
Changelog: https://github.com/$REPO/compare/$PREV_TAG...$VERSION

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## ERROR RECOVERY

**Tag already exists locally:**
```bash
# Delete local tag
git tag -d $VERSION

# Re-run /tag-and-release
```

**Tag exists remotely:**
```bash
# Delete remote tag (CAREFUL - check with team first)
git push origin :refs/tags/$VERSION

# Delete local tag
git tag -d $VERSION

# Re-run /tag-and-release
```

**Release creation fails (422 Validation):**
```bash
# List releases
gh release list | grep $VERSION

# If exists, delete
gh release delete $VERSION --yes

# Re-run /tag-and-release
```

**CHANGELOG format invalid:**
→ Edit CHANGELOG.md to match format:
```markdown
## [X.Y.Z] - YYYY-MM-DD

### Added/Changed/Fixed
- Description
```
→ Commit changes
→ Re-run `/tag-and-release`

**Version not consecutive:**
→ Bump version correctly: `make bump-patch/minor/major`
→ Update CHANGELOG.md
→ Commit changes
→ Re-run `/tag-and-release`

## VALIDATION CHECKLIST

**Automatically checked:**
- [ ] On main branch
- [ ] Working directory clean
- [ ] Version format valid (X.Y.Z)
- [ ] Version consecutive to latest tag
- [ ] CHANGELOG entry exists
- [ ] CHANGELOG has date
- [ ] CHANGELOG has categories
- [ ] Git tag created
- [ ] Tag pushed to remote
- [ ] GitHub release created

## KEEP A CHANGELOG FORMAT

**Required structure:**
```markdown
## [X.Y.Z] - YYYY-MM-DD

### Added
- New features

### Changed
- Modifications

### Deprecated
- Soon-to-be removed

### Removed
- Removed features

### Fixed
- Bug fixes

### Security
- Security fixes
```

**Must have:**
- Version header with date
- At least one category
- Bullet points under categories

## SEMANTIC VERSIONING

**MAJOR.MINOR.PATCH**

**MAJOR (X.0.0):** Breaking changes
**MINOR (0.X.0):** New features (compatible)
**PATCH (0.0.X):** Bug fixes (compatible)

**Rules:**
- Never reuse versions
- Must be consecutive
- No gaps allowed

## EXECUTION CHECKLIST

- [ ] PR merged to main
- [ ] On main branch
- [ ] Pulled latest: `git pull origin main`
- [ ] Working directory clean
- [ ] Version bumped in pyproject.toml
- [ ] CHANGELOG.md has version entry with date
- [ ] Ready to create tag and release

---

**WORKFLOW:** `/create-pr` (bumps version) → merge PR → `/tag-and-release` (creates tag and release)
