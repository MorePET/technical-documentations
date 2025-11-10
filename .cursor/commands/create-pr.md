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

### 0. Intelligent Version Bump Analysis (AI-Powered)

**The AI analyzes your changes and intelligently suggests version bumps:**

#### Step 1: Gather Information

```bash
# Get current version
CURRENT_VERSION=$(make version | grep -oP '\d+\.\d+\.\d+')

# Get latest tag
LATEST_TAG=$(git tag -l | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -1)

# Get base branch
BASE_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')

# Get commits in this branch
COMMITS=$(git log --oneline origin/$BASE_BRANCH..HEAD)

# Get full diff
DIFF=$(git diff origin/$BASE_BRANCH...HEAD)

# Get files changed
FILES_CHANGED=$(git diff --name-only origin/$BASE_BRANCH...HEAD)
```

#### Step 2: AI Analysis (Intelligent)

**The AI examines:**

1. **Commit Messages** (mechanical check):
   - Breaking changes: `BREAKING CHANGE` or `!:` in commits
   - Features: `feat:` commits
   - Fixes: `fix:` commits

2. **Code Changes** (intelligent analysis):
   - API signature changes (breaking)
   - New public functions/classes (feature)
   - Internal refactoring (patch)
   - Documentation only (no bump needed)
   - Configuration changes
   - Test additions

3. **File Impact** (scope analysis):
   - Core library changes vs. examples
   - Public API vs. internal implementation
   - Documentation vs. code

**AI presents analysis:**

```text
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🤖 AI Version Bump Analysis
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Current version: 0.3.3
Latest tag: 0.3.3

📊 Mechanical Analysis (Commit Messages):
  Breaking changes: ✗ None
  New features (feat:): ✓ Found (2 commits)
  Bug fixes (fix:): ✗ None

🧠 AI Analysis (Code Changes):
  - Added new public commands: /tag-and-release
  - Enhanced existing command: /create-pr
  - New documentation: VERSION_MANAGEMENT.md
  - No API breaking changes
  - All changes backward compatible

📁 Impact:
  - Files changed: 4
  - Core changes: ✓ (new workflow commands)
  - Public API: ✓ (new user-facing features)
  - Breaking changes: ✗

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📈 Recommendation: MINOR bump (0.3.3 → 0.4.0)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Rationale:
- New user-facing features added (workflow commands)
- Backward compatible (no breaking changes)
- More than just bug fixes
- Follows Semantic Versioning: MINOR for new features

Semantic Versioning Rules:
  MAJOR (X.0.0) - Breaking changes (incompatible API)
  MINOR (0.X.0) - New features (backward compatible) ← Suggested
  PATCH (0.0.X) - Bug fixes only

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Apply version bump?
  1) patch  - 0.3.3 → 0.3.4 (bug fixes only)
  2) minor  - 0.3.3 → 0.4.0 (new features) ← AI Recommendation
  3) major  - 0.3.3 → 1.0.0 (breaking changes)
  4) skip   - No version bump

Choice [1-4, default=2]:
```

#### Step 3: Apply Version Bump

```bash
# User selects or accepts AI recommendation
case "$CHOICE" in
  1|patch)
    BUMP_TYPE="patch"
    ;;
  2|minor|"")  # Default to AI suggestion
    BUMP_TYPE="minor"
    ;;
  3|major)
    BUMP_TYPE="major"
    ;;
  4|skip)
    echo "Skipping version bump"
    BUMP_TYPE=""
    ;;
esac

if [ -n "$BUMP_TYPE" ]; then
  echo "Applying $BUMP_TYPE bump..."
  make bump-$BUMP_TYPE
fi
```

#### Step 4: AI-Generated CHANGELOG Update

**AI automatically generates CHANGELOG entry based on analysis:**

```bash
if [ -n "$BUMP_TYPE" ]; then
  NEW_VERSION=$(make version | grep -oP '\d+\.\d+\.\d+')

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📝 Generating CHANGELOG Entry"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "AI is analyzing changes and generating CHANGELOG entry..."
  echo ""

  # AI analyzes the diff and generates appropriate CHANGELOG entry
  # Based on:
  # - Files changed
  # - Code changes (new features, fixes, refactoring)
  # - Commit messages
  # - Scope of changes

  # AI generates entry following Keep a Changelog format
  # Categories used based on actual changes:
  # - Added: New features, new files, new capabilities
  # - Changed: Modifications to existing functionality
  # - Deprecated: Features marked for removal
  # - Removed: Deleted features
  # - Fixed: Bug fixes
  # - Security: Security-related changes

  # Example AI-generated entry:
  # ## [0.4.0] - 2025-11-10
  #
  # ### Added
  #
  # - **Automated Release Workflow**
  #   - New `/tag-and-release` command for complete release automation
  #   - Validates CHANGELOG format and version continuity
  #   - Creates git tags and GitHub releases
  #
  # ### Changed
  #
  # - **PR Creation Workflow**
  #   - Enhanced `/create-pr` with AI-powered version bump analysis
  #   - Automatic CHANGELOG generation

  echo "Generated CHANGELOG entry for version $NEW_VERSION"
  echo ""
  echo "Preview of generated entry:"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  # Show generated entry to user
  sed -n "/^## \[$NEW_VERSION\]/,/^## \[/p" CHANGELOG.md | head -n -1

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "✨ AI has generated the CHANGELOG entry based on your changes"
  echo "📝 You can refine it in the PR if needed"
  echo ""
  read -p "Press Enter to commit version bump and CHANGELOG..."

  # Commit version bump with AI-generated CHANGELOG
  echo ""
  echo "Committing version bump..."
  git add pyproject.toml CHANGELOG.md
  git commit -m "chore(release): bump version to $NEW_VERSION

AI-generated CHANGELOG entry based on branch changes.
Version bump: $CURRENT_VERSION → $NEW_VERSION ($BUMP_TYPE)

Can be refined during PR review."

  echo "✅ Version bumped and CHANGELOG updated"
fi
```

**How AI Analyzes Changes:**

1. **Commit Message Analysis** (baseline):
   - Scans for `BREAKING CHANGE`, `feat:`, `fix:`, etc.
   - Identifies conventional commit types

2. **Code Diff Analysis** (intelligent):
   - Examines actual code changes
   - Identifies new public APIs (functions, classes, commands)
   - Detects signature changes (breaking)
   - Recognizes refactoring vs. new features
   - Distinguishes user-facing vs. internal changes

3. **File Impact Analysis**:
   - New files added (often features)
   - Modified files (fixes or enhancements)
   - Documentation-only changes
   - Test additions

4. **Contextual Understanding**:
   - Relates changes to project structure
   - Understands user-facing impact
   - Considers backward compatibility

**AI CHANGELOG Generation:**

The AI automatically generates appropriate CHANGELOG entries:

- **Categorizes changes** into Added/Changed/Fixed/etc.
- **Summarizes features** from code analysis
- **Groups related changes** logically
- **Uses clear, user-focused language**
- **Follows Keep a Changelog format** exactly

**You can refine in PR** - Everything gets reviewed anyway!

**Semantic Versioning AI Logic:**

```text
IF breaking changes detected (API changes, removed features):
  → MAJOR bump (X.0.0)

ELSE IF new features added (new public APIs, new commands, new capabilities):
  → MINOR bump (0.X.0)

ELSE IF only fixes, refactoring, or docs:
  → PATCH bump (0.0.X)

SPECIAL CASES:
- Documentation only → Skip bump
- Internal refactoring only → PATCH bump
- New internal tools (not user-facing) → PATCH or MINOR
```

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
