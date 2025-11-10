# Create PR Command

**CREATES PULL REQUESTS WITH VERSION MANAGEMENT**

Execute `/create-pr` to create PRs following project standards with AI-powered version bumping.

## EXECUTION PROTOCOL

### STEP 1: VERSION BUMP & CHANGELOG (MANDATORY FIRST)

**Run BEFORE creating PR. Version bump happens in PR, not after merge.**

```bash
CURRENT_VERSION=$(make version | grep -oP '\d+\.\d+\.\d+')
COMMITS=$(git log --oneline origin/main..HEAD)
FILES=$(git diff --name-only origin/main...HEAD)
```

**AI Analysis:**
- Parse commits for: `BREAKING CHANGE`, `feat:`, `fix:`
- Examine code diffs: new APIs, signature changes, file impact
- Categorize: user-facing vs internal changes

**Present recommendation:**
```text
🤖 AI Analysis

Current: $CURRENT_VERSION
Changes: [summary]

Recommended: MINOR bump → X.Y.0
Rationale: [explanation]

Version bump:
1) patch  - Bug fixes only
2) minor  - New features ← Recommended
3) major  - Breaking changes
4) skip

Choice [2]:
```

**WAIT for user input.**

**Execute bump:**
```bash
case "$CHOICE" in
  1) make bump-patch; BUMP_TYPE="patch" ;;
  2) make bump-minor; BUMP_TYPE="minor" ;;
  3) make bump-major; BUMP_TYPE="major" ;;
  4) BUMP_TYPE="" ;;
esac
```

**IF bump applied:**
```bash
NEW_VERSION=$(make version | grep -oP '\d+\.\d+\.\d+')

# AI generates CHANGELOG entry
# Format: Keep a Changelog
# Creates: ## [X.Y.Z] - YYYY-MM-DD
# Categories: Added/Changed/Fixed
# NO [Unreleased] section
```

**Commit version bump:**
```bash
git add pyproject.toml CHANGELOG.md
git commit -m "chore(release): bump version to $NEW_VERSION

Version bump: $CURRENT_VERSION → $NEW_VERSION
Type: $BUMP_TYPE

AI-generated CHANGELOG entry. Refinable in PR review."
```

**Display:**
```text
✅ Version bumped: $CURRENT_VERSION → $NEW_VERSION
✅ CHANGELOG updated
Ready to create PR
```

### STEP 2: VALIDATE PREREQUISITES

```bash
git status
```

**DECISION POINT: Working directory clean?**

**IF NOT clean:**
→ Display: "❌ Uncommitted changes detected. Commit all changes first."
→ List uncommitted files
→ ABORT

**IF clean:**
→ PROCEED to STEP 3

### STEP 3: VERIFY BRANCH

```bash
BRANCH=$(git branch --show-current)
```

**Check branch naming:**
- Valid prefixes: `feature/`, `fix/`, `docs/`, `refactor/`, `test/`, `chore/`, `release/`, `issue<number>`

**IF invalid branch name:**
→ Display: "⚠️ Branch name doesn't follow conventions"
→ Ask: "Proceed anyway? (yes/no)"
→ IF no: ABORT

**IF valid:**
→ PROCEED to STEP 4

### STEP 4: REBASE ON MAIN

```bash
git checkout main
git pull origin main
git checkout $BRANCH
git rebase main
```

**IF rebase conflicts:**
→ Display: "❌ Rebase conflicts detected"
→ Guide user through resolution
→ After resolution: `git rebase --continue`
→ Verify clean: `git status`

**IF rebase succeeds:**
→ PROCEED to STEP 5

### STEP 5: PUSH BRANCH

```bash
git push -u origin $BRANCH
```

**IF push fails (authentication):**
```bash
gh auth setup-git
git push -u origin $BRANCH
```

**IF push fails (force needed after rebase):**
→ Ask user: "Force push needed after rebase. Proceed? (yes/no)"
→ IF yes:
```bash
git push --force-with-lease origin $BRANCH
```

### STEP 6: CREATE PR

**Determine PR type from commits:**
- feat commits → `feat:`
- fix commits → `fix:`
- docs commits → `docs:`
- Mixed → use primary type

**Generate PR body:**
```markdown
## Description

[Summary of changes]

## Changes

### Core Implementation
- [File]: [What changed]

### Tests
- [Test file]: [Coverage]

### Documentation
- [Doc file]: [Updates]
- CHANGELOG.md: Version bump to X.Y.Z

## Testing

- [x] All tests passing
- [x] Pre-commit hooks passed
- [x] Manual testing completed

## Related Issues

Closes #X
Related to #Y

## Version Bump

- Current → New: $OLD → $NEW
- Type: $BUMP_TYPE
- CHANGELOG: Updated with AI-generated entry
```

**Create PR using temp file:**
```bash
cat > /tmp/pr-body.md << 'EOF'
[PR body content]
EOF

gh pr create \
  --title "<type>: <description> (closes #X)" \
  --body-file /tmp/pr-body.md

rm /tmp/pr-body.md
```

**Use `--body-file` to avoid shell escaping issues with special characters.**

### STEP 7: CONFIRM CREATION

```text
✅ PR Created

PR: #<number>
URL: <url>
Title: <title>
Status: Open (ready for review)

Version: $OLD → $NEW
CHANGELOG: Updated

Next steps:
- Wait for CI checks
- Address review feedback
- After merge: run `/tag-and-release`
```

## PR TITLE FORMAT

```
<type>: <description> (closes #<issue>)
```

**Examples:**
- `feat: add user authentication (closes #42)`
- `fix: resolve database timeout (fixes #123)`
- `docs: update API documentation (closes #67)`

## VERSION BUMPING RULES

**MAJOR (X.0.0):**
- Breaking changes
- API removals
- Incompatible changes

**MINOR (0.X.0):**
- New features (backward compatible)
- New APIs
- Enhancements

**PATCH (0.0.X):**
- Bug fixes
- Documentation
- Internal refactoring
- No new features

## CHANGELOG FORMAT

**AI generates:**
```markdown
## [X.Y.Z] - YYYY-MM-DD

### Added
- New features

### Changed
- Modifications

### Fixed
- Bug fixes
```

**NO [Unreleased] section** - version determined during PR creation.

## ERROR RECOVERY

**Uncommitted changes:**
→ `git status` to see files
→ Commit with `/git-commit`
→ Retry `/create-pr`

**Rebase conflicts:**
→ Resolve conflicts in files
→ `git add` resolved files
→ `git rebase --continue`
→ Retry push

**Push authentication failure:**
→ `gh auth setup-git`
→ `gh auth status` to verify
→ Retry push

**PR creation failure:**
→ Check branch is pushed: `git branch -r | grep $BRANCH`
→ Verify gh CLI auth: `gh auth status`
→ Check for existing PR: `gh pr list`

## EXECUTION CHECKLIST

**Before PR creation:**
- [ ] Version bumped (if applicable)
- [ ] CHANGELOG updated
- [ ] All changes committed
- [ ] Working directory clean
- [ ] Branch rebased on latest main
- [ ] All tests passing
- [ ] Pre-commit hooks passed

**During PR creation:**
- [ ] Branch pushed successfully
- [ ] PR title follows format
- [ ] PR body comprehensive
- [ ] Issue references included
- [ ] Version bump noted

**After PR creation:**
- [ ] CI checks pass
- [ ] Review feedback addressed
- [ ] Mark ready for review
- [ ] After merge: run `/tag-and-release`

---

**WORKFLOW:** version bump → create PR → merge → `/tag-and-release` creates git tag and release
