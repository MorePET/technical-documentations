# YOLO Issue Command

**AUTONOMOUS EXECUTION MODE - NO USER CONFIRMATION**

Execute `/yolo-issue <issue-number>` to autonomously solve GitHub issues with production-ready code, comprehensive tests, and complete documentation.

## EXECUTION PROTOCOL

### STEP 1: PREFLIGHT

```bash
gh repo view --json nameWithOwner --jq .nameWithOwner
gh issue view <issue-number> --json number,title,body,labels,state,assignees
git status
```

**DECISION POINT: Clean working directory?**
- **NO** → ABORT. Display: "🛑 YOLO MODE ABORTED: Uncommitted changes detected. Commit, stash, or discard changes then retry."
- **YES** → PROCEED to STEP 2

### STEP 2: BRANCH SETUP

```bash
git checkout main
git pull origin main
git checkout -b issue<issue-number>
gh auth setup-git  # Prevents push auth failures
```

Display: "🚀 YOLO MODE ACTIVATED for Issue #<number> - Working autonomously..."

### STEP 3: ANALYSIS & PLANNING

Create `.cursor/plans/issue-<number>.md`:
- Issue type (bug/feature/docs/refactor)
- Affected files/components
- Implementation approach with rationale
- Commit strategy (3-5 atomic commits)
- Acceptance criteria checklist

DO NOT show plan to user. Execute immediately.

### STEP 4: IMPLEMENTATION

**For each logical unit of work:**

1. Implement changes following project patterns
2. Run `read_lints` on modified files
3. Fix any linting errors automatically
4. Commit:
   ```bash
   git add <files>
   git commit -m "<type>(<scope>): <description>

   <detailed explanation>

   Related to #<n>"
   ```

**IF commit fails with "files were modified by this hook":**
- Re-run identical commit command (pre-commit auto-fixed files)
- If fails again, check linter output and fix issues
- MUST NOT skip hooks with --no-verify

**COMMIT CATEGORIES (3-5 commits):**
1. Core implementation: `feat/fix(scope): implement X for #N`
2. Tests (if code changes): `test(scope): add tests for #N`
3. Refactoring (if needed): `refactor(scope): improve Y for #N`
4. Documentation: `docs(scope): document X for #N`
5. Changelog: `docs(changelog): add entry for #N`

### STEP 5: QUALITY GATES

Before pushing, verify:
- `read_lints` returns no errors
- All pre-commit hooks pass
- No TODO/FIXME comments remain
- No hardcoded values (use config/env/constants)
- CHANGELOG.md updated with [Unreleased] section
- Git status clean

### STEP 6: PUSH & PR CREATION

```bash
git push -u origin issue<issue-number>
```

**IF push fails with "could not read Username":**
```bash
gh auth setup-git
git push -u origin issue<issue-number>
```

**Create PR using temporary file (avoids shell escaping issues):**

```bash
cat > /tmp/pr-body.md << 'EOF'
## 🚀 YOLO Mode Implementation

Autonomously resolves issue #<issue-number>.

## Implementation

<detailed description of changes>

**Approach:** <rationale for chosen solution>
**Files changed:** <count>
**Commits:** <count> atomic commits

### Changes

**Core Implementation:**
- <file>: <what changed>

**Tests:** (if applicable)
- <test-file>: <coverage>

**Documentation:**
- <doc-file>: <what documented>
- CHANGELOG.md: [Unreleased] entry added

## Quality

- ✅ All linters passing
- ✅ Pre-commit hooks passed
- ✅ Documentation complete
- ✅ CHANGELOG updated
- ✅ No hardcoded values
- ✅ Follows project conventions

## Commits

<list commits with descriptions>

Closes #<issue-number>

## Review Notes

Implemented autonomously in YOLO mode. Please verify:
- Alignment with project vision
- Edge cases covered
- Documentation clarity

Implementation plan: `.cursor/plans/issue-<issue-number>.md`
EOF

gh pr create \
  --title "<type>: <description> (closes #<issue-number>)" \
  --body-file /tmp/pr-body.md

rm /tmp/pr-body.md
```

**IF PR creation fails:**
- Check for special characters in PR body causing shell errors
- Verify branch is pushed
- Retry with `--head` flag if needed

### STEP 7: COMPLETION REPORT

```text
✅ YOLO MODE COMPLETE - Issue #<number>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Summary
Issue: #<number> - <title>
Branch: issue<number>
Commits: <N>
Files Changed: <count>
Lines: +<added> -<removed>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Implementation Complete
<bullet list of key changes>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔗 Pull Request
PR: #<pr-number>
URL: <pr-url>
Plan: .cursor/plans/issue-<number>.md

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✨ Quality Checks: All Passed
- Linting: ✅
- Documentation: ✅
- CHANGELOG: ✅
- Conventions: ✅
```

## QUALITY STANDARDS (ENFORCE ALWAYS)

**Code Quality:**
- SOLID principles (Single Responsibility, DRY, proper abstractions)
- No hardcoded values (use config files, env vars, named constants)
- Descriptive names (no `x`, `temp`, `data`)
- Functions < 50 lines
- Type hints/annotations (Python/TypeScript)
- Proper error handling

**Testing (if code changes):**
- Unit tests for new functions
- Integration tests for workflows
- Edge cases (empty, null, boundary values)
- Error conditions

**Documentation:**
- Docstrings for public APIs
- README updates if user-facing
- CHANGELOG entry (always)
- Inline comments for complex logic

**Git:**
- Conventional commit format
- Atomic commits (3-5 per issue)
- No `--no-verify` or hook skipping
- Working directory clean before push

## ERROR RECOVERY

**Pre-commit hook failures:**
→ Re-run commit (hooks auto-fix files)
→ If fails twice, read linter output and fix manually

**Markdown line length > 210:**
→ Break lines at logical boundaries (semantic line breaks)

**Git push auth failure:**
→ Run `gh auth setup-git` then retry push

**PR body shell escaping errors (`:Z`, backticks, etc.):**
→ Always use `--body-file` with temp file, never inline `--body`

**Linting errors:**
→ Fix automatically with project linters (ruff, shellcheck, pymarkdown, yamllint)
→ Re-run linters after fixes
→ Commit fixes separately if needed

## ABORT CONDITIONS

**MUST stop and ask user if:**
1. Breaking API changes required
2. Security implications (auth, encryption, data access)
3. Database schema migrations needed
4. New major external dependencies
5. Performance vs complexity trade-offs unclear
6. Issue requirements ambiguous/contradictory
7. Major architectural refactoring beyond issue scope

**Display:**
```text
⚠️ YOLO MODE PAUSED - Issue #<number> requires human decision

Situation: <explain blocker>

Options:
1. <option A with pros/cons>
2. <option B with pros/cons>

Impact: <what's affected>

Recommendation: <your suggestion with reasoning>

Awaiting user confirmation to proceed.
```

## EXECUTION CHECKLIST

Use this to verify each YOLO execution:

**Pre-execution:**
- [ ] Working directory clean
- [ ] GitHub CLI authenticated
- [ ] Issue exists and accessible

**During execution:**
- [ ] Branch created from latest main
- [ ] Git auth configured
- [ ] Implementation plan created (not shown to user)
- [ ] Changes follow project patterns
- [ ] Linting passes on all files
- [ ] 3-5 atomic commits made
- [ ] CHANGELOG updated
- [ ] All pre-commit hooks pass

**Post-execution:**
- [ ] Branch pushed successfully
- [ ] PR created with comprehensive description
- [ ] Completion report displayed
- [ ] Implementation plan available

---

**REMEMBER:**
- Zero user confirmations during execution
- Autonomous decision-making within scope
- Production-ready quality enforced
- Complete or nothing (no partial solutions)
