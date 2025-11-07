# Git Commit Command

This command helps you create proper conventional commits following the project's standards.

For complete documentation on commit conventions, workflow, and best practices, see:

**[Git Workflow Documentation](./../git-workflow.md)**

## Commit Message Format

**ALWAYS use conventional commits** with this format:

```
<type>(<scope>): <description>

<body>

<footer>
```

### Required Elements

**Type** (required): What kind of change
**Description** (required): Brief summary (50 chars max)

### Optional Elements

**Scope** (optional): Module/component affected
**Body** (optional): Detailed explanation
**Footer** (optional): Breaking changes, issue references

## Commit Types

| Type | When to Use | Example |
|------|-------------|---------|
| `feat` | New feature | `feat(auth): add user login` |
| `fix` | Bug fix | `fix(api): resolve memory leak` |
| `docs` | Documentation | `docs(readme): update install guide` |
| `style` | Code formatting | `style: format with ruff` |
| `refactor` | Code restructure | `refactor(auth): extract validation` |
| `perf` | Performance improvement | `perf(db): optimize query` |
| `test` | Test additions/changes | `test(auth): add login tests` |
| `chore` | Maintenance tasks | `chore(deps): update packages` |
| `ci` | CI/CD changes | `ci: add python matrix` |
| `build` | Build system changes | `build: update pyproject.toml` |
| `revert` | Revert previous commit | `revert: fix login bug` |

## Scope Guidelines

**Use scope for:**
- Component/module names: `feat(auth):`, `fix(db):`
- File types: `docs(readme):`, `test(unit):`
- Areas: `refactor(api):`, `style(imports):`

**Don't use scope for:**
- Generic changes: `chore: update deps`
- Multiple areas: Choose most relevant or omit
- File paths: `fix(src/auth.py):` → `fix(auth):`

## Commit Message Examples

### Simple Commit

```bash
git commit -m "fix(auth): resolve login timeout issue"
```

### Commit with Body

```bash
git commit -m "feat(dashboard): add user profile widget

Add a new profile widget to the dashboard showing user information
and recent activity. The widget is responsive and integrates with
the existing theme system.

Includes unit tests for the new component and updates to the
dashboard layout."
```

### Commit with Breaking Change

```bash
git commit -m "feat(api): redesign user endpoints

BREAKING CHANGE: User API endpoints now require authentication
headers. Update your client code to include Bearer tokens.

- Removed anonymous access to /api/users
- Added JWT validation middleware
- Updated API documentation"
```

### Commit Referencing Issues

```bash
git commit -m "fix(db): handle connection pool exhaustion

Fix database connection pool exhaustion under high load by
implementing proper connection cleanup and retry logic.

Closes #123
Related to #456"
```

## Interactive Commit Workflow

### 1. Stage Your Changes

```bash
# Stage all changes
git add .

# Or stage specific files
git add src/auth.py tests/test_auth.py

# Or interactively stage hunks
git add -p
```

### 2. Review Changes

```bash
# See what will be committed
git diff --staged

# See affected files
git status
```

### 3. Create Commit

```bash
# For simple commits
git commit -m "fix(auth): resolve timeout bug"

# For complex commits (opens editor)
git commit
```

### 4. Push (if ready)

```bash
git push origin your-branch
```

## Best Practices

### Atomic Commits

**Each commit should be one logical change:**

✅ **Good:**
```bash
git commit -m "feat(auth): add password validation"
git commit -m "feat(auth): add password strength meter"
git commit -m "test(auth): add validation tests"
```

❌ **Bad:**
```bash
git commit -m "add auth features and tests and fix docs"
```

### Commit Frequency

**Commit early and often:**
- After completing a logical unit of work
- Before switching tasks
- At natural stopping points
- Before risky operations (rebases, merges)

**Don't commit:**
- Incomplete work: `git commit -m "wip"`
- Multiple unrelated changes
- Formatting only (use `style:` type)
- Debug code (remove before commit)

### Commit Message Quality

**Subject line:**
- ✅ Imperative mood: "add", "fix", "update" (not "added", "fixed")
- ✅ Capitalize first word? No
- ✅ Period at end? No
- ✅ Under 50 characters

**Body:**
- Explain what and why, not how
- Wrap at 72 characters
- Separate from subject with blank line
- Use bullet points for multiple changes

### Squashing Commits

**Before PR, consider squashing trivial commits:**

```bash
# Interactive rebase last 3 commits
git rebase -i HEAD~3

# Mark commits to squash with 's'
pick abc1234 feat: add feature
s def5678 fix typo
s ghi9012 add tests
```

## Pre-commit Hooks

**Hooks run automatically on commit:**
- Ruff (Python linting/formatting)
- Shellcheck (shell script linting)
- Pymarkdown (markdown linting)
- Trailing whitespace removal
- End-of-file fixes

**Skip hooks only when necessary:**
```bash
git commit --no-verify -m "urgent fix"
```

## Common Scenarios

### Fix Last Commit Message

```bash
git commit --amend -m "fix(auth): correct login validation"
```

### Add Forgotten File to Last Commit

```bash
git add forgotten-file.py
git commit --amend --no-edit
```

### Undo Last Commit (Keep Changes)

```bash
git reset --soft HEAD~1
```

### Undo Last Commit (Discard Changes)

```bash
git reset --hard HEAD~1
```

### Revert a Commit

```bash
git revert abc1234
```

## Troubleshooting

### Commit Rejected by Hooks

```bash
# Fix linting errors
uv run ruff check --fix .

# Check shell scripts
shellcheck script.sh

# Then commit
git add .
git commit -m "fix: resolve linting issues"
```

### Wrong Branch

```bash
# Check current branch
git branch --show-current

# Switch branch
git checkout correct-branch

# Cherry-pick if needed
git cherry-pick commit-hash
```

### Large Commit

**Split into smaller commits:**
```bash
# Unstage everything
git reset HEAD~

# Stage in parts
git add file1.py
git commit -m "feat: add user validation"

git add file2.py file3.py
git commit -m "feat: add user model"
```

## Quick Reference

### Commit Types Cheat Sheet

```
feat:     New feature
fix:      Bug fix
docs:     Documentation
style:    Formatting
refactor: Code restructure
perf:     Performance
test:     Tests
chore:    Maintenance
ci:       CI/CD
build:    Build system
revert:   Revert commit
```

### Fast Commit Commands

```bash
# Quick fix
git add . && git commit -m "fix: quick bug fix"

# Feature commit
git add src/ && git commit -m "feat(ui): add new component"

# Documentation
git add docs/ && git commit -m "docs: update API guide"
```

---

**See [git-workflow.md](./../git-workflow.md) for complete Git workflow and commit guidelines.**
