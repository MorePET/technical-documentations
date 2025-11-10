# Solve Issue Command

This command provides a comprehensive workflow for solving GitHub issues with proper planning, implementation, and pull request submission.

**Usage:** `/solve-issue <issue-number>`

For complete documentation on related workflows, see:

**Related Documentation:**

- **[Git Commit Guidelines](./git-commit.md)**
- **[Pull Request Guidelines](./create-pr.md)**
- **[Git Workflow](./../git-workflow.md)**
- **[PR Template](./../pr-template.md)**

## ⚠️ CRITICAL: Methodical Approach Required

This command emphasizes **careful planning, user feedback, and clean commits**. For an automated approach, see [yolo-issue.md](./yolo-issue.md).

## Workflow

### 1. Fetch and Analyze the Issue

**Get issue details:**

```bash
# Get current repo
REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner)

# Fetch issue details
gh issue view <issue-number> --json number,title,body,labels,state,assignees
```

**Analyze:**
- Read the issue description carefully
- Identify the problem or feature request
- Note any acceptance criteria
- Check for related issues or dependencies
- Review any labels or assignees

**Output to user:**
- Issue title and number
- Description summary
- Current state
- Your initial understanding of the task

### 2. Check Repository State

**⚠️ CRITICAL: Verify clean working directory**

```bash
git status
```

**If NOT clean (uncommitted changes exist):**

❌ **STOP IMMEDIATELY** and inform the user:

```text
⚠️ Cannot proceed with issue resolution!

Your working directory has uncommitted changes:
[list the modified/untracked files]

You must commit or stash these changes before starting work on an issue.

Options:
1. Commit changes: See git-commit.md for guidelines
2. Stash changes: git stash save "description"
3. Discard changes: git restore . (⚠️ destructive)

After cleaning up, run this command again.
```

**If clean (working tree clean):**

✅ Proceed to next step

### 3. Create and Checkout Issue Branch

**Check if branch exists:**

```bash
# Check local branches
git branch --list "issue<issue-number>"

# Check remote branches
git branch -r --list "origin/issue<issue-number>"
```

**Branch naming:** `issue<number>` (e.g., `issue42`)

**If branch doesn't exist:**

```bash
# Ensure main is up to date
git checkout main
git pull origin main

# Create new branch
git checkout -b issue<issue-number>
```

**If branch already exists locally:**

```bash
# Checkout existing branch
git checkout issue<issue-number>

# Update from remote if it exists
git pull origin issue<issue-number> 2>/dev/null || echo "No remote branch yet"

# Rebase on latest main
git rebase main
```

**Confirm to user:**
- ✓ Branch: `issue<number>`
- ✓ Based on latest `main`
- ✓ Ready for development

### 4. Create Implementation Plan

**Create `.cursor/plans/` directory if it doesn't exist:**

```bash
mkdir -p .cursor/plans
```

**Generate comprehensive plan and save to:** `.cursor/plans/issue-<number>.md`

**Plan structure:**

```markdown
# Issue #<number>: <title>

## Problem Statement

[Clear description of the issue/feature]

## Analysis

### Current State
- [What exists now]
- [Relevant code locations]
- [Dependencies/constraints]

### Required Changes
- [What needs to change]
- [Files to modify]
- [New files to create]

## Implementation Options

### Option 1: [Approach Name]

**Description:** [How this approach works]

**Pros:**
- [Advantage 1]
- [Advantage 2]

**Cons:**
- [Disadvantage 1]
- [Disadvantage 2]

**Estimated Complexity:** Low/Medium/High

**Files to modify:**
- `path/to/file1.py`
- `path/to/file2.py`

### Option 2: [Alternative Approach]

[Same structure as Option 1]

### Option 3: [Another Alternative]

[Same structure as Option 1]

## Recommended Approach

**Choice:** Option [X]

**Rationale:** [Why this is the best approach]

## Implementation Steps

1. [Step 1 with file references]
2. [Step 2 with file references]
3. [Step 3 - Add tests]
4. [Step 4 - Update documentation]
5. [Step 5 - Update CHANGELOG.md]

## Testing Strategy

- [Unit tests to add]
- [Integration tests needed]
- [Manual testing steps]

## Acceptance Criteria

- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] [All tests pass]
- [ ] [Documentation updated]
- [ ] [CHANGELOG.md updated]

## Related Issues/PRs

- Related to #[X]
- Depends on #[Y]
```

**After creating the plan:**

1. **Display the plan to the user**
2. **If multiple viable options exist, ASK FOR FEEDBACK:**

```text
I've created an implementation plan with 3 approaches:

Option 1 (Recommended): [Brief description]
  Pros: [Key advantages]
  Cons: [Key disadvantages]

Option 2: [Brief description]
  Pros: [Key advantages]
  Cons: [Key disadvantages]

Option 3: [Brief description]
  Pros: [Key advantages]
  Cons: [Key disadvantages]

My recommendation is Option 1 because [rationale].

Would you like me to:
1. Proceed with Option 1 (recommended)
2. Use Option 2
3. Use Option 3
4. Modify the plan

Please confirm or provide feedback.
```

**Wait for user confirmation before implementing**

### 5. Implement the Solution

**Follow these principles throughout implementation:**

#### Commit Strategy (Critical)

**Make regular, atomic commits** following [git-commit.md](./git-commit.md):

**Commit frequency guidelines:**
- After each logical unit of work (every 30-60 mins of work)
- When a specific step in the plan is complete
- Before making risky changes
- When tests pass for a component

**Commit structure examples:**

```bash
# Step 1: Initial implementation
git add src/module.py
git commit -m "feat(module): implement core functionality for issue #42"

# Step 2: Add tests
git add tests/test_module.py
git commit -m "test(module): add unit tests for issue #42"

# Step 3: Documentation
git add docs/module.md
git commit -m "docs(module): document new functionality for issue #42"

# Step 4: Update changelog
git add CHANGELOG.md
git commit -m "docs(changelog): add entry for issue #42"
```

**⚠️ ALWAYS reference issue number in commits:**
- In commit message body: `Fixes #42` or `Related to #42`
- In commit description for context

#### Code Quality Standards

**Follow these principles:**
- ✅ **SOLID principles** - Single responsibility, proper abstraction
- ✅ **DRY** - Don't repeat yourself, extract common logic
- ✅ **Clear naming** - Descriptive variable and function names
- ✅ **Proper error handling** - Handle edge cases gracefully
- ✅ **Type hints** - Use type annotations (Python/TypeScript)
- ✅ **Documentation** - Docstrings for functions/classes
- ✅ **No magic numbers** - Use named constants
- ✅ **Configuration over hardcoding** - Use config files/env vars

#### Testing Requirements

**Add tests for:**
- ✅ Core functionality (unit tests)
- ✅ Edge cases and error conditions
- ✅ Integration points
- ✅ Regression tests if fixing a bug

**Test coverage:**
- Aim for high coverage of new/modified code
- Include both positive and negative test cases

#### Pre-commit Hooks

**All commits must pass pre-commit hooks** (see [git-commit.md](./git-commit.md)):
- If hooks fail, **FIX the issues** before committing
- **NEVER use `--no-verify`** without asking user first
- Common hook failures: linting errors, formatting issues, trailing whitespace

#### Progress Updates

**Keep user informed:**
- Show progress after each major step
- Explain what you're implementing
- Show test results
- Report any blockers or questions

### 6. Final Verification

**Before creating PR, verify:**

```bash
# 1. All tests pass
[run test command based on project]

# 2. Working directory is clean
git status  # Should be clean

# 3. Review all commits
git log --oneline origin/main..HEAD

# 4. Check diff
git diff origin/main...HEAD
```

**Checklist:**
- [ ] All planned steps completed
- [ ] Tests added and passing
- [ ] Documentation updated
- [ ] CHANGELOG.md updated (if user-facing change)
- [ ] No debug code, console.logs, or TODOs left
- [ ] All commits follow conventional format
- [ ] Pre-commit hooks passed on all commits

### 7. Create Pull Request

**Push the branch:**

```bash
git push origin issue<issue-number>
```

**Create PR using GitHub CLI:**

```bash
gh pr create \
  --title "fix/feat: <description> (closes #<issue-number>)" \
  --body "## Description

[Description of changes]

## Changes

- [Change 1]
- [Change 2]

## Testing

- [x] Unit tests added
- [x] All tests passing
- [x] Manual testing completed

## Related Issues

Closes #<issue-number>

## Implementation Plan

See: .cursor/plans/issue-<number>.md" \
  --draft
```

**PR title format:**
- Use conventional commit type: `fix:`, `feat:`, `docs:`, etc.
- Include brief description
- Reference issue: `(closes #42)` or `(fixes #42)`

**Example titles:**
- `feat: add user authentication (closes #42)`
- `fix: resolve database connection timeout (fixes #123)`
- `docs: update API documentation (closes #67)`

**After PR creation:**

1. **Inform user:**
   - ✓ PR created (show URL)
   - ✓ Status: Draft
   - ✓ Linked to issue #X
   - ✓ Implementation plan included

2. **Next steps:**
   - Wait for CI checks
   - Address any automated feedback
   - Mark as "Ready for review" when ready
   - Respond to review comments

### 8. Mark PR Ready for Review

**After CI passes and you're confident:**

```bash
gh pr ready <pr-number>
```

**Inform user:**

```text
✅ Issue #<number> solution complete!

Summary:
- Branch: issue<number>
- Commits: <count> atomic commits
- Tests: All passing
- PR: #<pr-number> (ready for review)
- Plan: .cursor/plans/issue-<number>.md

The PR is now ready for maintainer review.
```

## Best Practices

### Planning Phase

- **Thorough analysis** - Understand the issue completely before coding
- **Multiple options** - Consider different approaches
- **Get feedback** - Ask user for preference when there are trade-offs
- **Document plan** - Save plan for future reference

### Implementation Phase

- **Atomic commits** - Small, focused commits (review [git-commit.md](./git-commit.md))
- **Test as you go** - Don't leave testing until the end
- **Follow style** - Match existing code style and patterns
- **Incremental progress** - Complete one step before moving to next

### Quality Checklist

Before committing any code:
- [ ] Follows project coding standards
- [ ] No hardcoded values (use constants/config)
- [ ] Proper error handling
- [ ] Type hints/annotations added
- [ ] Docstrings for new functions/classes
- [ ] No commented-out code
- [ ] No console.logs or debug prints
- [ ] Imports organized properly

### Communication

- **Be transparent** - Share your reasoning
- **Ask when uncertain** - Don't guess on ambiguous requirements
- **Explain trade-offs** - When there are multiple valid approaches
- **Show progress** - Keep user updated on long-running tasks

## Common Scenarios

### Scenario 1: Simple Bug Fix

```bash
# 1. Fetch issue
gh issue view 42

# 2. Check clean
git status

# 3. Create branch
git checkout -b issue42

# 4. Create simple plan
# (Can be brief for obvious bugs)

# 5. Fix + test + commit
git commit -m "fix(api): resolve timeout in /users endpoint

Increased connection timeout from 5s to 30s to handle
slow database queries during peak hours.

Fixes #42"

# 6. Update changelog
git commit -m "docs(changelog): add fix for issue #42"

# 7. PR
gh pr create --title "fix: resolve API timeout (fixes #42)"
```

### Scenario 2: Complex Feature

```bash
# 1. Fetch issue
gh issue view 67

# 2. Extensive analysis
# - Review related code
# - Identify dependencies
# - Consider architecture

# 3. Create detailed plan with options
# - Save to .cursor/plans/issue-67.md
# - Present options to user
# - Wait for feedback

# 4. Implement in phases
# Phase 1: Core logic (commit)
# Phase 2: Tests (commit)
# Phase 3: Integration (commit)
# Phase 4: Documentation (commit)
# Phase 5: Changelog (commit)

# 5. Create PR with comprehensive description
```

### Scenario 3: Issue Requires Clarification

```text
After analyzing issue #89, I have questions:

The issue states "improve performance" but doesn't specify:
1. Which operation is slow?
2. What's the current performance baseline?
3. What's the target performance?

I recommend:
- Commenting on the issue to ask for clarification
- OR making reasonable assumptions and documenting them

How would you like to proceed?
```

## Troubleshooting

### Working Directory Not Clean

```text
⚠️ Cannot start: uncommitted changes detected

Modified files:
  M src/app.py
  M tests/test_app.py

Please commit these first:
  git add src/app.py tests/test_app.py
  git commit -m "feat(app): describe your changes"

Or stash them:
  git stash save "work in progress"

Then run solve-issue again.
```

### Branch Already Exists

```bash
# If local branch exists
git checkout issue42
git rebase main  # Update with latest

# If you want to start fresh
git branch -D issue42
git checkout -b issue42
```

### Pre-commit Hooks Failing

**DO NOT skip hooks!**

```bash
# Fix the reported issues
# For Python linting
uv run ruff check --fix .

# For shell scripts
shellcheck script.sh

# Then commit
git commit -m "your message"
```

See [git-commit.md](./git-commit.md) for detailed pre-commit hook guidelines.

### Issue is Complex or Blocked

**Communicate with user:**

```text
After analyzing issue #X, I've identified some concerns:

Blockers:
- Depends on unmerged PR #Y
- Requires database schema changes
- Needs security review

Recommendations:
1. Wait for PR #Y to merge
2. Create separate issue for schema migration
3. Implement feature flag for gradual rollout

Should we proceed with a partial implementation or wait?
```

## Quick Reference

### Command Sequence

```bash
# 1. Fetch issue
gh issue view <number>

# 2. Verify clean state
git status

# 3. Create branch
git checkout main && git pull
git checkout -b issue<number>

# 4. Create plan
mkdir -p .cursor/plans
# [Create plan file]

# 5. Implement with regular commits
git commit -m "type(scope): description

Related to #<number>"

# 6. Push and PR
git push origin issue<number>
gh pr create --title "type: description (closes #<number>)" --draft
```

### Files to Update

Common files that may need updating:
- **Source code** - Your implementation
- **Tests** - Unit/integration tests
- **Documentation** - README, docs/, docstrings
- **CHANGELOG.md** - User-facing changes
- **Configuration** - If adding new features

### Commit Message Template

```bash
git commit -m "type(scope): brief description

Detailed explanation of what changed and why.
Include context that would help reviewers understand
the changes.

Related to #<issue-number>
Fixes #<issue-number>  # Use this in final commit"
```

---

**For an automated approach without user confirmations, see [yolo-issue.md](./yolo-issue.md).**

**For detailed commit and PR guidelines, see [git-commit.md](./git-commit.md) and [create-pr.md](./create-pr.md).**
