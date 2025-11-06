# Git Workflow

## Branch Strategy

### Main Branch

- `main` - Production-ready code
  - Protected branch
  - All changes via PR
  - Always deployable
  - Tagged with releases

### Working Branches

Follow naming convention: `<type>/<description>`

**Types:**
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation
- `refactor/` - Code refactoring
- `test/` - Test additions
- `chore/` - Maintenance
- `release/` - Release preparation

**Examples:**
```bash
feature/github-auth
fix/ssh-key-mismatch
docs/update-readme
refactor/split-auth-script
test/add-integration-tests
chore/update-dependencies
release/v0.2.0
```

### Branch Lifecycle

1. **Create branch from latest main**
   ```bash
   git checkout main
   git pull origin main
   git checkout -b feature/my-feature
   ```

2. **Make changes and commit**
   ```bash
   git add .
   git commit -m "feat: add new feature"
   ```

3. **Keep branch updated**
   ```bash
   git checkout main
   git pull origin main
   git checkout feature/my-feature
   git rebase main
   ```

4. **Push and create PR**
   ```bash
   git push origin feature/my-feature
   gh pr create
   ```

5. **After PR merged, delete branch**
   ```bash
   git checkout main
   git pull origin main
   git branch -d feature/my-feature
   git push origin --delete feature/my-feature
   ```

## Commit Conventions

### Conventional Commits

Format: `<type>(<scope>): <description>`

**Types:**
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation only
- `style` - Formatting, missing semicolons, etc.
- `refactor` - Code change that neither fixes a bug nor adds a feature
- `perf` - Performance improvement
- `test` - Adding or updating tests
- `chore` - Maintenance tasks
- `ci` - CI/CD changes
- `build` - Build system changes
- `revert` - Revert previous commit

**Scope (optional):**
- `devcontainer`
- `auth`
- `docs`
- `ci`
- `build`

**Examples:**

```
feat(auth): add automatic GitHub CLI authentication
fix(devcontainer): resolve SSH key path mismatch
docs(readme): update installation instructions
refactor(scripts): extract common auth logic to shared function
test(auth): add unit tests for token extraction
chore(deps): update pre-commit hooks to latest versions
ci: add shellcheck to CI pipeline
```

### Commit Message Structure

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Subject line:**
- Use imperative mood ("add" not "added")
- Don't capitalize first letter
- No period at the end
- Keep under 50 characters

**Body:**
- Wrap at 72 characters
- Explain what and why, not how
- Separate from subject with blank line

**Footer:**
- Reference issues: `Closes #123`
- Breaking changes: `BREAKING CHANGE: description`

**Example:**

```
feat(auth): add automatic token extraction from host

Previously, users had to manually authenticate gh CLI in the
container. This implementation extracts the token from the host's
gh auth and passes it securely to the container via a temporary
file that is immediately deleted after use.

The token is protected by .gitignore patterns and never persists
on disk longer than necessary.

Closes #45
```

## Commit Best Practices

### Atomic Commits

- Each commit should be a single logical change
- Should be able to revert any commit safely
- Makes git bisect more useful

✅ Good:
```bash
git commit -m "feat(auth): add token extraction"
git commit -m "feat(auth): add token file cleanup"
git commit -m "docs(auth): document token security"
```

❌ Bad:
```bash
git commit -m "add auth and fix docs and update deps"
```

### Commit Frequency

**When to commit:**
- After completing a logical unit of work
- Before switching tasks
- At natural stopping points
- Before rebasing or merging

**Too few commits:**
- Large, hard to review changes
- Difficult to identify issues
- Hard to revert specific changes

**Too many commits:**
- "fix typo", "wip", "forgot file"
- These should be squashed before PR

### Squashing Commits

Before opening PR, consider squashing:

```bash
# Interactive rebase last 3 commits
git rebase -i HEAD~3

# Mark commits to squash with 's'
pick abc1234 feat: add feature
s def5678 fix typo
s ghi9012 add tests
```

## Rebase vs. Merge

### When to Rebase

**Rebase your feature branch** onto main:
```bash
git checkout feature/my-feature
git rebase main
```

Use when:
- ✅ Updating your branch with latest main
- ✅ Cleaning up local commit history
- ✅ Before opening PR

### When to Merge

**Merge main into your branch** if:
- You've already pushed and others are working on same branch
- You want to preserve exact history

**NEVER rebase:**
- ❌ Commits that have been pushed to shared branch
- ❌ Release branches
- ❌ Main branch

## Handling Conflicts

### Resolving Merge Conflicts

1. **Update your branch**
   ```bash
   git checkout main
   git pull
   git checkout feature/my-feature
   git rebase main
   ```

2. **Git will show conflicts**
   ```
   CONFLICT (content): Merge conflict in file.txt
   ```

3. **Open conflicted files**
   ```
   <<<<<<< HEAD
   your changes
   =======
   changes from main
   >>>>>>> main
   ```

4. **Resolve manually**
   - Choose which changes to keep
   - Remove conflict markers
   - Test the result

5. **Continue rebase**
   ```bash
   git add .
   git rebase --continue
   ```

6. **Force push** (if already pushed)
   ```bash
   git push --force-with-lease origin feature/my-feature
   ```

## Git Hooks

### Pre-commit Hook

Automatically runs on `git commit`:
- Ruff (Python linting/formatting)
- Shellcheck (shell script linting)
- Pymarkdown (markdown linting)
- Trailing whitespace fix
- End of file fix

**Skip hooks** (only when absolutely necessary):
```bash
git commit --no-verify -m "message"
```

### Installing Hooks

Hooks are automatically installed in dev container.

Manual installation:
```bash
pre-commit install
```

## Useful Git Commands

### Checking Status

```bash
git status                    # Current state
git log --oneline -10        # Recent commits
git log --graph --all        # Visual history
git diff                     # Unstaged changes
git diff --staged            # Staged changes
```

### Undoing Changes

```bash
git restore file.txt         # Discard unstaged changes
git restore --staged file.txt # Unstage file
git reset HEAD~1             # Undo last commit (keep changes)
git reset --hard HEAD~1      # Undo last commit (discard changes)
git revert abc1234           # Create new commit that undos abc1234
```

### Stashing

```bash
git stash                    # Save changes temporarily
git stash list              # List stashes
git stash pop               # Apply and remove latest stash
git stash apply             # Apply stash without removing
git stash drop              # Delete latest stash
```

### Cleaning Up

```bash
git branch -d feature/done   # Delete merged branch
git branch -D feature/bad    # Force delete branch
git remote prune origin      # Remove stale remote branches
git gc                       # Garbage collection
```

## Branch Protection Rules

### Required for `main` branch:

- ✅ Require pull request before merging
  - Require 1 approval
  - Dismiss stale reviews on new commits
- ✅ Require status checks to pass
  - pre-commit hooks
  - CI tests
- ✅ Require branches to be up to date
- ✅ Require conversation resolution
- ✅ Do not allow bypassing above settings
- ❌ Do not allow force pushes
- ❌ Do not allow deletions

## Emergency Procedures

### Accidentally committed to main

```bash
# Create branch with current changes
git branch emergency-save

# Reset main to origin
git checkout main
git reset --hard origin/main

# Create proper PR from emergency branch
git checkout emergency-save
git checkout -b fix/proper-branch
git push origin fix/proper-branch
gh pr create
```

### Need to force push

**Only acceptable when:**
- Rebasing your own feature branch
- Fixing your own mistakes before PR review

**Always use:**
```bash
git push --force-with-lease origin branch-name
```

**Never use:**
```bash
git push --force  # DON'T USE THIS
```

### Lost commits

```bash
git reflog                   # Find lost commits
git checkout abc1234         # Recover lost commit
git cherry-pick abc1234      # Apply lost commit to current branch
```

## Git Configuration

### Required Settings

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519_github.pub
git config --global commit.gpgsign true
```

### Recommended Settings

```bash
git config --global pull.rebase true
git config --global rebase.autoStash true
git config --global fetch.prune true
git config --global init.defaultBranch main
```

These are automatically configured in the dev container.
