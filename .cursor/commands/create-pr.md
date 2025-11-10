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

### 0. AI-Powered Version Bump & CHANGELOG (Automatic)

**AI analyzes your changes, suggests version bump, and generates CHANGELOG:**

```bash
# Gather data
CURRENT_VERSION=$(make version | grep -oP '\d+\.\d+\.\d+')
COMMITS=$(git log --oneline origin/main..HEAD)
FILES=$(git diff --name-only origin/main...HEAD)

# AI Analysis: Check commits AND examine actual code changes
# Mechanical: BREAKING CHANGE, feat:, fix: in commits
# Intelligent: New APIs, signature changes, file impact, user-facing changes

# AI presents recommendation
echo "🤖 AI Analysis: Current $CURRENT_VERSION"
echo ""
echo "Changes detected:"
echo "  - [AI summary of actual changes]"
echo ""
echo "📈 Recommended: MINOR bump → 0.4.0"
echo "    Rationale: [AI explanation]"
echo ""
echo "Apply version bump?"
echo "  1) patch  - Bug fixes only"
echo "  2) minor  - New features ← AI suggests"
echo "  3) major  - Breaking changes"
echo "  4) skip"
read -p "Choice [default=2]: " CHOICE

# Apply bump
case "${CHOICE:-2}" in
  1) make bump-patch; BUMP_TYPE="patch" ;;
  2) make bump-minor; BUMP_TYPE="minor" ;;
  3) make bump-major; BUMP_TYPE="major" ;;
  4) BUMP_TYPE="" ;;
esac

# AI generates CHANGELOG entry automatically
if [ -n "$BUMP_TYPE" ]; then
  # AI analyzes diff and generates Keep a Changelog formatted entry
  # Categorizes: Added/Changed/Fixed based on actual changes
  # Uses clear, user-focused language

  NEW_VERSION=$(make version | grep -oP '\d+\.\d+\.\d+')
  echo "✨ AI generated CHANGELOG for $NEW_VERSION"
  echo "📝 Refinable in PR review"

  # Commit with version bump type in message
  git add pyproject.toml CHANGELOG.md
  git commit -m "chore(release): bump version to $NEW_VERSION [$BUMP_TYPE]

AI-generated CHANGELOG. Version: $CURRENT_VERSION → $NEW_VERSION"
fi
```

**AI Analysis Factors:**

- **Commits:** `BREAKING CHANGE`, `feat:`, `fix:` patterns
- **Code:** New APIs, signature changes, refactoring detection
- **Files:** New vs. modified, public vs. internal
- **Impact:** User-facing vs. internal changes

**Semantic Versioning:**

- **MAJOR (X.0.0):** Breaking changes, API removals
- **MINOR (0.X.0):** New features (backward compatible)
- **PATCH (0.0.X):** Bug fixes, docs, internal refactoring

**Bump Type in PR Title:**

The version bump type is included in the commit message with `[patch]`,
`[minor]`, or `[major]` tag. This allows `/tag-and-release` to automatically
determine the correct version bump when creating releases.

**Example:**

```bash
# Commit message includes bump type
chore(release): bump version to 0.4.0 [minor]
```

Tag-and-release reads this to know it's a MINOR bump.

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
