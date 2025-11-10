# Git Commit Command

**CREATES CONVENTIONAL COMMITS - PRE-COMMIT HOOKS ENFORCED**

Execute `/git-commit` for proper conventional commits following project standards.

## COMMIT FORMAT (MANDATORY)

```
<type>(<scope>): <description>

<body>

<footer>
```

**REQUIRED:** type, scope, description
**OPTIONAL:** body, footer

## TYPES

| Type | Usage |
|------|-------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation |
| `style` | Formatting (no logic change) |
| `refactor` | Code restructure (no behavior change) |
| `perf` | Performance improvement |
| `test` | Tests |
| `chore` | Maintenance |
| `ci` | CI/CD changes |
| `build` | Build system |
| `revert` | Revert commit |

## SCOPES (REQUIRED - FROM ALLOWED LIST)

See `.gitlint` for complete list of 20 allowed scopes.

**Categories:**
- Code: `auth`, `api`, `ui`, `cli`
- Docs: `readme`, `changelog`
- Infra: `workflow`, `github`, `deps`, `devcontainer`, `config`
- Languages: `typst`, `python`, `markdown`, `yaml`
- Tools: `pre-commit`, `gitlint`, `linter`
- Other: `security`, `release`

**Rules:**
- Lowercase only
- No spaces
- Hyphens for multi-word (`pre-commit`)
- Must be from allowed list

## EXECUTION PROTOCOL

### STEP 1: REVIEW CHANGES

```bash
git status
git diff --staged --name-only | wc -l
```

**DECISION POINT: Number of staged files?**

**IF 0 files:**
→ Display: "No files staged. Use `git add <file>` first."
→ ABORT

**IF 1-4 files, same scope:**
→ PROCEED to STEP 2

**IF 5+ files OR mixed scopes:**
→ Display: "⚠️ Multiple logical changes detected. Split into separate commits:"
→ List files grouped by suggested commits
→ Ask user: "Commit all together or split?"
→ IF split: guide user through staged commits
→ IF together: PROCEED with caution

### STEP 2: DETERMINE COMMIT DETAILS

**Analyze staged files to determine:**
- **Type:** feat/fix/docs/etc. based on changes
- **Scope:** from file paths and affected area
- **Description:** what changed (imperative mood, <50 chars)
- **Body:** why changed (if not obvious)
- **Footer:** issue references (Fixes #N, Related to #N)

**Present to user:**
```text
Proposed commit:

Type: feat
Scope: auth
Description: add password validation
Body: Implement password strength validation with minimum requirements...
Footer: Related to #42

Proceed? (yes/modify/abort)
```

### STEP 3: CREATE COMMIT

```bash
git commit -m "<type>(<scope>): <description>

<body>

<footer>"
```

**IF pre-commit hooks fail:**
→ Read hook output
→ Identify failure type:

**Auto-fixable (end-of-file, whitespace):**
```text
⚠️ Pre-commit auto-fixed files. Re-running commit...
```
→ Re-run identical commit command
→ IF fails again: analyze and fix manually

**Linting errors:**
```bash
# Python
uv run ruff check --fix .
uv run ruff format .

# Shell
shellcheck script.sh

# Markdown
# Fix line length, formatting issues
```
→ Fix issues
→ Re-stage fixed files
→ Retry commit

**Gitlint errors (wrong type/scope):**
→ Fix commit message format
→ Use correct type/scope from allowed lists
→ Retry commit

**NEVER use `--no-verify` without explicit user permission.**

**IF need to skip hooks:**
→ Ask user: "Pre-commit hook failed: <reason>. Skip hooks? (yes/no)"
→ Only if user says "yes":
```bash
git commit --no-verify -m "message"
```

### STEP 4: CONFIRM SUCCESS

```text
✅ Commit created

[abc1234] type(scope): description
Files changed: N
Insertions: +X
Deletions: -Y
```

## COMMIT SPLITTING RULES

**MUST split if:**
- 5+ files
- Different types (feat + fix = 2 commits)
- Different scopes (auth + api = 2 commits)
- Unrelated changes

**Split example:**
```bash
# Commit 1: Core implementation
git add src/auth.py src/models.py
git commit -m "feat(auth): add password validation"

# Commit 2: Tests
git add tests/test_auth.py
git commit -m "test(auth): add validation tests"

# Commit 3: Documentation
git add docs/auth.md README.md
git commit -m "docs(readme): document password requirements"

# Commit 4: Config
git add config/settings.py
git commit -m "chore(config): add auth settings"
```

## MESSAGE QUALITY RULES

**Subject line:**
- Imperative mood: "add" not "added"
- Lowercase after colon: `feat(auth): add login`
- No period at end
- Under 50 characters

**Body:**
- Explain what and why, not how
- Wrap at 72 characters
- Blank line after subject
- Bullet points for multiple items

## PRE-COMMIT HOOKS

**Hooks run automatically:**
- Gitlint (message validation)
- Ruff (Python lint/format)
- Shellcheck (shell scripts)
- Pymarkdown (markdown)
- Trailing whitespace fix
- End-of-file fix

**Hook failure protocol:**
1. Read error output
2. Fix issues
3. Re-stage files
4. Retry commit
5. ONLY skip if user explicitly approves

## COMMON OPERATIONS

**Amend last commit:**
```bash
git commit --amend -m "fixed message"
```

**Add forgotten file:**
```bash
git add forgotten.py
git commit --amend --no-edit
```

**Undo last commit (keep changes):**
```bash
git reset --soft HEAD~1
```

**Revert a commit:**
```bash
git revert <commit-hash>
```

## ERROR RECOVERY

**"files were modified by this hook":**
→ Normal behavior (auto-fix)
→ Re-run identical commit command
→ Will succeed on second attempt

**"invalid type/scope":**
→ Use type from allowed list
→ Use scope from `.gitlint`
→ Fix message format

**"too many files":**
→ Unstage: `git reset`
→ Stage groups: `git add file1 file2`
→ Commit each group separately

**"wrong branch":**
→ Check: `git branch --show-current`
→ Switch: `git checkout correct-branch`
→ Cherry-pick if needed: `git cherry-pick <hash>`

## EXECUTION CHECKLIST

- [ ] Files staged selectively (not `git add .` for 5+ files)
- [ ] Changes reviewed with `git diff --staged`
- [ ] Commit message follows format
- [ ] Type from allowed list
- [ ] Scope from allowed list
- [ ] Description imperative, <50 chars
- [ ] Issue references in footer
- [ ] Pre-commit hooks pass
- [ ] No `--no-verify` unless approved

---

**CRITICAL:** Never commit without reviewing changes. Never skip hooks without permission. Never mix unrelated changes.
