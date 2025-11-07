# Git Commit Command

This command helps you create proper conventional commits following the project's standards.

For complete documentation on commit conventions, workflow, and best practices, see:

**[Git Workflow Documentation](./../git-workflow.md)**

## Commit Message Format

**ALWAYS use conventional commits** with this format:

```text
```text
<type>(<scope>): <description>

<body>

<footer>
```

### Required Elements

**Type** (required): What kind of change
**Scope** (required): Module/component affected (must be from allowed list)
**Description** (required): Brief summary (50 chars max)

### Optional Elements

**Body** (optional): Detailed explanation
**Footer** (optional): Breaking changes, issue references

## Commit Types

| Type | When to Use | Example |
|------|-------------|---------|
| `feat` | New feature | `feat(auth): add user login` |
| `fix` | Bug fix | `fix(api): resolve memory leak` |
| `docs` | Documentation | `docs(readme): update install guide` |
| `style` | Code formatting | `style(python): format with ruff` |
| `refactor` | Code restructure | `refactor(auth): extract validation` |
| `perf` | Performance improvement | `perf(api): optimize query` |
| `test` | Test additions/changes | `test(auth): add login tests` |
| `chore` | Maintenance tasks | `chore(deps): update packages` |
| `ci` | CI/CD changes | `ci(workflow): add python matrix` |
| `build` | Build system changes | `build(config): update pyproject.toml` |
| `revert` | Revert previous commit | `revert(api): undo breaking change` |

## Scope Guidelines

**Scopes are REQUIRED** for all commits and must be from the allowed list.

**See [.gitlint](../.gitlint) for the complete list of 20 allowed scopes.**

Scopes are organized by category:

- **Code/Feature Areas:** `auth`, `api`, `ui`, `cli`
- **Documentation:** `readme`, `changelog`
- **Infrastructure:** `workflow`, `github`, `deps`, `devcontainer`, `config`
- **Languages/Tools:** `typst`, `python`, `markdown`, `yaml`
- **Tooling:** `pre-commit`, `gitlint`, `linter`
- **Other:** `security`, `release`

**Scope rules:**
- Always use lowercase
- No spaces allowed
- Use hyphens for multi-word scopes (e.g., `pre-commit`)
- Choose the most specific scope for your change
- Scopes avoid redundancy with types (no `docs`, `ci`, `build`, `test` scopes)
- If the scope you need isn't in the list, discuss adding it to `.gitlint`

**Sensible combinations:**
- `feat(auth):` - New authentication feature
- `fix(api):` - Fix API bug
- `docs(readme):` - Update README (not `docs(docs):`)
- `style(python):` - Format Python code
- `chore(deps):` - Update dependencies
- `ci(workflow):` - Modify CI workflow (not `ci(ci):`)
- `test(auth):` - Add auth tests (not `test(test):`)

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
- ✅ Lowercase first word after colon: `feat(auth): add login`
- ✅ No period at end
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
pick abc1234 feat(auth): add user authentication
s def5678 style(auth): fix typo in auth module
s ghi9012 test(auth): add authentication tests
```

## Pre-commit Hooks

**Hooks run automatically on commit:**
- Gitlint (commit message validation)
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

# Commit rejected for missing/invalid scope?
# Use a scope from the allowed list (see Scope Guidelines)

# Then commit
git add .
git commit -m "fix(linter): resolve linting issues"
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
feat(scope):     New feature
fix(scope):      Bug fix
docs(scope):     Documentation
style(scope):    Formatting
refactor(scope): Code restructure
perf(scope):     Performance
test(scope):     Tests
chore(scope):    Maintenance
ci(scope):       CI/CD
build(scope):    Build system
revert(scope):   Revert commit
```

**Note:** All commits REQUIRE a scope from the allowed list (see Scope Guidelines above).

### Fast Commit Commands

**⚠️ Use with caution - only for 1-4 related files:**

```bash
# Quick fix
git add . && git commit -m "fix(api): quick bug fix"

# Feature commit (related files only)
git add src/component.py && git commit -m "feat(ui): add new component"

# Documentation
git add docs/ && git commit -m "docs(readme): update API guide"
```

---

**See [git-workflow.md](./../git-workflow.md) for complete Git workflow and commit guidelines.**
