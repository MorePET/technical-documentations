# Git Commit Command

This command helps you create proper conventional commits following the project's standards.

For complete documentation on commit conventions, workflow, and best practices, see:

**[Git Workflow Documentation](./../git-workflow.md)**

## Commit Message Format

**ALWAYS use conventional commits** with this format:

```text
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

## ⚠️ Critical: Split Large Commits

**ALWAYS review staged files before committing.**

If you have **5+ files** or **multiple unrelated changes**, split into separate commits:

### Signs You Need Multiple Commits

❌ **Don't commit together:**
- Feature + bug fix
- Code + documentation
- Implementation + tests (sometimes separate is better)
- Multiple unrelated features
- Config changes + code changes
- Different scopes/areas

✅ **Group by:**
- Logical units of work
- Single purpose/scope
- Related files only
- Same commit type

### Example: Splitting a Large Change

**Bad (10 files, mixed purposes):**

```bash
git add .  # ❌ Everything at once
git commit -m "add feature and fix bugs and update docs"
```

**Good (split into logical commits):**

```bash
# Commit 1: Core feature
git add src/auth.py src/models.py
git commit -m "feat(auth): add password validation"

# Commit 2: Tests
git add tests/test_auth.py
git commit -m "test(auth): add validation tests"

# Commit 3: Documentation
git add docs/auth.md README.md
git commit -m "docs(auth): document password requirements"

# Commit 4: Config
git add config/settings.py
git commit -m "chore(config): add auth settings"
```

## Interactive Commit Workflow

### 1. Stage Your Changes

**⚠️ STOP before `git add .`**

Review what changed first:

```bash
# See ALL changes
git status

# Count modified files
git status --short | wc -l
```

**Decision tree:**
- **1-4 files, same purpose** → Stage all together
- **5+ files** → Review if they should be split
- **Different types/scopes** → Definitely split

```bash
# Stage selectively
git add src/auth.py tests/test_auth.py

# Or stage all (only if related)
git add .

# Or interactively stage hunks
git add -p
```

### 2. Review Changes

```bash
# See what will be committed
git diff --staged

# See affected files
git status

# Count staged files
git diff --staged --name-only | wc -l
```

**If you see 5+ files:**
- Ask yourself: "Do these all belong together?"
- If no: Unstage and commit in batches

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

**Each commit should be ONE logical change.**

**Atomic = Single-purpose, focused, reviewable**

✅ **Good (separate commits):**

```bash
git commit -m "feat(auth): add password validation"
git commit -m "feat(auth): add password strength meter"
git commit -m "test(auth): add validation tests"
```

❌ **Bad (mixed purposes):**

```bash
git commit -m "add auth features and tests and fix docs"
```

### When to Split Commits

Split if you have:
- ✂️ **5+ files** → Likely multiple logical changes
- ✂️ **Different types** → feat + fix + docs = 3 commits
- ✂️ **Different scopes** → auth + api + ui = 3 commits
- ✂️ **Unrelated changes** → Even if same file

**Rule of thumb:** If you use "and" in commit message, split it!

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

### Large Commit (Too Many Files)

**If you have 5+ staged files, split them:**

```bash
# See what's staged
git status

# If too many files, unstage all
git reset

# Commit in logical groups
git add src/auth/*.py
git commit -m "feat(auth): implement authentication"

git add tests/test_auth*.py
git commit -m "test(auth): add authentication tests"

git add docs/auth.md
git commit -m "docs(auth): document authentication flow"

git add config/settings.py
git commit -m "chore(config): add auth configuration"
```

**Pro tip:** Use `git add -p` to stage specific hunks within files

## Quick Reference

### Commit Types Cheat Sheet

```text
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

**⚠️ Use with caution - only for 1-4 related files:**

```bash
# Quick fix (single file)
git add src/bug.py && git commit -m "fix: quick bug fix"

# Feature commit (related files only)
git add src/component.py && git commit -m "feat(ui): add new component"

# Documentation (related docs)
git add docs/api.md && git commit -m "docs: update API guide"
```

**Don't:**

```bash
# ❌ Blind commit all
git add . && git commit -m "updates"

# ❌ Large mixed batch
git add . && git commit -m "feat: add feature"  # (if 10+ files)
```

---

**See [git-workflow.md](./../git-workflow.md) for complete Git workflow and commit guidelines.**
