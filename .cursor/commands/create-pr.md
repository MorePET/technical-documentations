# Create Pull Request Command

This command helps you create pull requests following the project's standards and guidelines.

For complete documentation on pull request guidelines, templates, and review process, see:

**Related Documentation:**

- **[Pull Request Guidelines](./../pr-template.md)**
- **[Git Workflow](./../git-workflow.md)**
- **[Version Management](./../../docs/VERSION_MANAGEMENT.md)**

## Workflow

**Style Guidelines:**
- Use standard markdown lists: `-` for bullets, `- [ ]` for unchecked, `- [x]` for checked
- Never use emojis for lists or checkboxes
- Keep PR descriptions clean and professional

When creating a pull request, follow these steps:

### 0. Intelligent Version Bump Analysis (Automatic)

**The command automatically analyzes changes and suggests version bumps:**

```bash
# 1. Get current version
CURRENT_VERSION=$(make version | grep -oP '\d+\.\d+\.\d+')

# 2. Get latest tag
LATEST_TAG=$(git tag -l | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -1)

# 3. Analyze commits in branch
BASE_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')
COMMITS=$(git log --oneline origin/$BASE_BRANCH..HEAD)

# 4. Determine bump type based on Semantic Versioning
HAS_BREAKING=false
HAS_FEAT=false
HAS_FIX=false

# Check for breaking changes
if echo "$COMMITS" | grep -qE "BREAKING CHANGE|!:"; then
  HAS_BREAKING=true
fi

# Check for features
if echo "$COMMITS" | grep -qE "^[a-f0-9]+ feat"; then
  HAS_FEAT=true
fi

# Check for fixes
if echo "$COMMITS" | grep -qE "^[a-f0-9]+ fix"; then
  HAS_FIX=true
fi

# Suggest bump type (Semantic Versioning)
if [ "$HAS_BREAKING" = "true" ]; then
  SUGGESTED_BUMP="major"
  EXPLANATION="Breaking changes detected (MAJOR bump required)"
elif [ "$HAS_FEAT" = "true" ]; then
  SUGGESTED_BUMP="minor"
  EXPLANATION="New features detected (MINOR bump recommended)"
elif [ "$HAS_FIX" = "true" ]; then
  SUGGESTED_BUMP="patch"
  EXPLANATION="Bug fixes only (PATCH bump recommended)"
else
  SUGGESTED_BUMP="patch"
  EXPLANATION="Other changes (PATCH bump default)"
fi

# Calculate suggested version
IFS='.' read -r -a PARTS <<< "$CURRENT_VERSION"
case "$SUGGESTED_BUMP" in
  major)
    SUGGESTED_VERSION="$((PARTS[0] + 1)).0.0"
    ;;
  minor)
    SUGGESTED_VERSION="${PARTS[0]}.$((PARTS[1] + 1)).0"
    ;;
  patch)
    SUGGESTED_VERSION="${PARTS[0]}.${PARTS[1]}.$((PARTS[2] + 1))"
    ;;
esac

# Present to user
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Version Bump Analysis"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Current version: $CURRENT_VERSION"
echo "Latest tag: $LATEST_TAG"
echo ""
echo "Analysis:"
BREAKING_STATUS=$([ "$HAS_BREAKING" = "true" ] && echo "✓ Found" || echo "✗ None")
echo "  Breaking changes: $BREAKING_STATUS"
echo "  New features: $([ "$HAS_FEAT" = "true" ] && echo "✓ Found" || echo "✗ None")"
echo "  Bug fixes: $([ "$HAS_FIX" = "true" ] && echo "✓ Found" || echo "✗ None")"
echo ""
echo "📈 Suggested: $SUGGESTED_BUMP bump"
echo "   $CURRENT_VERSION → $SUGGESTED_VERSION"
echo ""
echo "Explanation: $EXPLANATION"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Apply version bump?"
echo "  1) patch - $CURRENT_VERSION → ${PARTS[0]}.${PARTS[1]}.$((PARTS[2] + 1))"
echo "  2) minor - $CURRENT_VERSION → ${PARTS[0]}.$((PARTS[1] + 1)).0"
echo "  3) major - $CURRENT_VERSION → $((PARTS[0] + 1)).0.0"
echo "  4) skip - No version bump"
echo ""
read -p "Choice [1-4, default=$SUGGESTED_BUMP]: " CHOICE

case "$CHOICE" in
  1|patch)
    echo "Bumping patch version..."
    make bump-patch
    ;;
  2|minor)
    echo "Bumping minor version..."
    make bump-minor
    ;;
  3|major)
    echo "Bumping major version..."
    make bump-major
    ;;
  4|skip|"")
    echo "Skipping version bump"
    ;;
  *)
    echo "Applying suggested: $SUGGESTED_BUMP"
    make bump-$SUGGESTED_BUMP
    ;;
esac

# Prompt to update CHANGELOG
if [ "$CHOICE" != "skip" ] && [ "$CHOICE" != "4" ]; then
  NEW_VERSION=$(make version | grep -oP '\d+\.\d+\.\d+')
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📝 CHANGELOG Update Required"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Version bumped to: $NEW_VERSION"
  echo ""
  echo "Please update CHANGELOG.md with actual changes:"
  echo "  1. Open CHANGELOG.md"
  echo "  2. Find: ## [$NEW_VERSION] - $(date +%Y-%m-%d)"
  echo "  3. Replace placeholder with actual changes"
  echo "  4. Use categories: Added, Changed, Fixed, etc."
  echo ""
  read -p "Press Enter when CHANGELOG is updated..."

  # Commit version bump
  echo ""
  echo "Committing version bump..."
  git add pyproject.toml CHANGELOG.md
  git commit -m "chore(release): bump version to $NEW_VERSION

Updated version and CHANGELOG for upcoming release."
fi
```

**Semantic Versioning Summary:**
- **MAJOR (X.0.0)**: Breaking changes (incompatible API changes)
- **MINOR (0.X.0)**: New features (backward compatible)
- **PATCH (0.0.X)**: Bug fixes (backward compatible)

**Reference:** [Semantic Versioning](https://semver.org/spec/v2.0.0.html)

1. **Ensure your branch follows naming conventions:**
   - `feature/`, `fix/`, `docs/`, `refactor/`, `test/`, `chore/`, or `release/`
   - Example: `feature/add-user-authentication`

2. **Verify branch is up to date:**

   ```bash
   git checkout main
   git pull origin main
   git checkout your-branch
   git rebase main
   ```

3. **Ensure all changes are committed:**

   ```bash
   git status  # Must show "nothing to commit, working tree clean"
   ```

   - **All work must be committed before creating PR**
   - No uncommitted changes allowed
   - No untracked files that should be included
   - See [git-commit.md](./git-commit.md) for commit guidelines

4. **Run pre-commit hooks and tests:**

   ```bash
   # All pre-commit hooks should have passed during commits
   # Verify tests pass if applicable
   ```

5. **Self-review your changes:**
   - Read through the diff
   - Check for console.logs, TODOs, or debug code
   - Verify all tests pass
   - Confirm pre-commit hooks passed

6. **Push your branch:**

   ```bash
   git push origin your-branch
   ```

7. **Create the pull request:**

   ```bash
   gh pr create
   ```

8. **Fill out the PR template** with:
   - Clear, descriptive title
   - Detailed description of changes
   - Related issues (if applicable)
   - Testing information
   - Screenshots (if UI changes)

## Quick Reference

### Create a Feature PR

```bash
# Ensure you're on feature branch
git checkout feature/add-dark-mode

# Rebase on latest main
git rebase main

# Push and create PR
git push origin feature/add-dark-mode
gh pr create \
  --title "feature: Add dark mode toggle" \
  --body "## Description

Add dark mode support to the application.

## Changes

- Added theme context and provider
- Implemented dark mode CSS variables
- Added toggle component to settings

## Testing

- [x] Tested locally in dev container
- [x] All pre-commit hooks pass
- [x] Manual testing completed"
```

### Create a Bug Fix PR

```bash
# Ensure you're on fix branch
git checkout fix/auth-bug

# Rebase on latest main
git rebase main

# Push and create PR
git push origin fix/auth-bug
gh pr create \
  --title "fix: Resolve authentication timeout issue" \
  --body "## Description

Fixed authentication session timeout bug that was causing users to be
logged out unexpectedly.

## Changes

- Extended session timeout from 30 to 60 minutes
- Added proper session refresh logic
- Updated error handling for expired sessions

## Testing

- [x] Unit tests added for session handling
- [x] Integration tests pass
- [x] Manual testing completed

Closes #123"
```

### Create a Documentation PR

```bash
# Ensure you're on docs branch
git checkout docs/update-readme

# Rebase on latest main
git rebase main

# Push and create PR
git push origin docs/update-readme
gh pr create \
  --title "docs: Update installation instructions" \
  --body "## Description

Updated README.md with clearer installation instructions for new developers.

## Changes

- Added step-by-step installation guide
- Included troubleshooting section
- Added links to dev container setup

## Testing

- [x] Documentation renders correctly
- [x] Links are valid
- [x] Follows documentation style guide"
```

## PR Title Format

Use clear, descriptive titles following conventional commit format:

```text
<type>: Brief description of changes
```

Examples:
- `feature: Add user profile page`
- `fix: Resolve database connection leak`
- `docs: Update API documentation`
- `refactor: Extract common auth logic`

## Common PR Checks

Before creating PR, ensure:

- **All changes are committed** (clean working directory)
- Branch follows naming convention
- Commits follow conventional format
- All pre-commit hooks pass
- Tests are passing
- CHANGELOG.md updated (if user-facing change)
- No breaking changes without major version discussion

## After PR Creation

1. **Wait for CI checks** to complete
2. **Address review feedback** promptly
3. **Mark conversations as resolved** when fixed
4. **Rebase and update** if main branch changes
5. **Merge when approved** (maintainers handle merging)

## Utility Commands

### Check Current Branch

```bash
git branch --show-current
```

### View Recent Commits

```bash
git log --oneline -5
```

### Check if Branch is Behind

```bash
git status
# Look for "Your branch is behind 'origin/main' by X commits"
```

### Interactive Rebase (Clean Up Commits)

```bash
git rebase -i HEAD~3  # Last 3 commits
# Use 'squash' to combine, 'reword' to change messages
```

---

**See [pr-template.md](./../pr-template.md) and [git-workflow.md](./../git-workflow.md) for detailed guidelines and examples.**
