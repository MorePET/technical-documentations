# Solve Issue Command

**METHODICAL ISSUE SOLVING - USER FEEDBACK REQUIRED**

Execute `/solve-issue <issue-number>` for careful planning, implementation, and PR creation with user checkpoints.

## EXECUTION PROTOCOL

### STEP 1: FETCH ISSUE

```bash
REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
gh issue view <issue-number> --json number,title,body,labels,state,assignees
```

**Display to user:**
```text
📋 Issue #<number>: <title>

<summary of description>

State: <state>
Labels: <labels>
Assignees: <assignees>

Initial understanding:
[Your analysis of what needs to be done]
```

### STEP 2: CHECK REPOSITORY STATE

```bash
git status
```

**DECISION POINT: Working directory clean?**

**IF NOT clean:**
```text
⚠️ Cannot proceed - uncommitted changes detected

Modified files:
[list files]

Action required:
1. Commit: /git-commit
2. Stash: git stash save "wip"
3. Discard: git restore . (DESTRUCTIVE)

Run /solve-issue again after cleanup.
```
→ ABORT

**IF clean:**
→ Display: "✅ Working directory clean"
→ PROCEED to STEP 3

### STEP 3: CREATE BRANCH

```bash
# Check if branch exists
git branch --list "issue<number>"
git branch -r --list "origin/issue<number>"
```

**DECISION POINT: Branch exists?**

**IF NO:**
```bash
git checkout main
git pull origin main
git checkout -b issue<issue-number>
```
→ Display: "✅ Created branch: issue<number>"

**IF YES (locally):**
```bash
git checkout issue<issue-number>
git pull origin issue<issue-number> 2>/dev/null || true
git rebase main
```
→ Display: "✅ Checked out existing branch: issue<number>"
→ If rebase conflicts: guide resolution

**PROCEED to STEP 4**

### STEP 4: CREATE IMPLEMENTATION PLAN

```bash
mkdir -p .cursor/plans
```

**Generate plan:** `.cursor/plans/issue-<number>.md`

**Plan structure:**
```markdown
# Issue #<number>: <title>

## Problem Statement
[Clear description]

## Analysis

### Current State
- Existing code/behavior
- Relevant files
- Dependencies/constraints

### Required Changes
- What needs to change
- Files to modify
- New files to create

## Implementation Options

### Option 1: [Name]
**Description:** [How it works]
**Pros:** [Advantages]
**Cons:** [Disadvantages]
**Complexity:** Low/Medium/High
**Files:** [List]

### Option 2: [Alternative]
[Same structure]

### Option 3: [Another]
[Same structure]

## Recommended Approach
**Choice:** Option [X]
**Rationale:** [Why]

## Implementation Steps
1. [Step with files]
2. [Step with files]
3. Add tests
4. Update docs
5. Update CHANGELOG

## Testing Strategy
- Unit tests
- Integration tests
- Manual testing

## Acceptance Criteria
- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] Tests pass
- [ ] Docs updated
- [ ] CHANGELOG updated
```

**Display plan to user.**

**IF multiple viable options:**
```text
Implementation Plan Created

I've identified 3 approaches:

Option 1 (Recommended): [brief description]
  Pros: [key advantages]
  Cons: [key disadvantages]

Option 2: [brief description]
  Pros: [key advantages]
  Cons: [key disadvantages]

Option 3: [brief description]
  Pros: [key advantages]
  Cons: [key disadvantages]

Recommendation: Option 1 because [rationale]

Choose:
1) Proceed with Option 1 (recommended)
2) Use Option 2
3) Use Option 3
4) Modify plan

Response:
```

**WAIT for user response.**

**After user confirms:**
→ PROCEED to STEP 5

### STEP 5: IMPLEMENT SOLUTION

**Commit strategy: 3-5 atomic commits**

**Phase structure:**

**Phase 1: Core Implementation**
→ Implement core functionality
→ Commit:
```bash
git add <files>
git commit -m "feat/fix(scope): implement core functionality for #<n>

[Detailed description]
[Key decisions]
[Trade-offs]

Related to #<n>"
```

**Phase 2: Tests** (if code changes)
→ Add unit/integration tests
→ Commit:
```bash
git add tests/
git commit -m "test(scope): add comprehensive tests for #<n>

Tests include:
- Unit tests for [components]
- Integration tests for [workflows]
- Edge cases: [scenarios]
- Error handling: [conditions]

Related to #<n>"
```

**Phase 3: Refactoring** (if needed)
→ Apply SOLID principles
→ Remove duplication
→ Commit:
```bash
git add <files>
git commit -m "refactor(scope): enhance code quality for #<n>

Applied SOLID principles:
- [Specific refactorings]

Removed duplication:
- [Extracted functions]

Related to #<n>"
```

**Phase 4: Documentation**
→ Update README, docs, docstrings
→ Commit:
```bash
git add docs/ README.md
git commit -m "docs(scope): document solution for #<n>

Added:
- Docstrings for functions
- README section on [feature]
- Usage examples

Related to #<n>"
```

**Phase 5: CHANGELOG**
→ Update CHANGELOG.md
→ Commit:
```bash
git add CHANGELOG.md
git commit -m "docs(changelog): add entry for #<n>

[User-facing change description]

Fixes #<n>"
```

**During implementation:**
- Keep user informed of progress
- Show test results
- Report blockers/questions
- Ask for feedback on trade-offs

**Code quality standards:**
- SOLID principles
- DRY (no duplication)
- Clear naming
- Type hints/annotations
- Proper error handling
- No magic numbers/hardcoding
- Configuration over hardcoding

**IF pre-commit hooks fail:**
→ Read error output
→ Fix issues automatically
→ Re-stage files
→ Retry commit
→ NEVER use `--no-verify` without asking

**IF blockers encountered:**
```text
⚠️ Blocker Encountered

Issue: [Description]

Impact: [What's blocked]

Options:
1. [Option A - pros/cons]
2. [Option B - pros/cons]

Recommendation: [Your suggestion]

How should we proceed?
```
→ WAIT for user response

### STEP 6: FINAL VERIFICATION

```bash
# Run tests
[project-specific test command]

# Check status
git status

# Review commits
git log --oneline origin/main..HEAD

# Check diff
git diff origin/main...HEAD
```

**Verification checklist:**
- [ ] All planned steps completed
- [ ] Tests added and passing
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] No debug code/TODOs
- [ ] All commits follow format
- [ ] Pre-commit hooks passed
- [ ] Working directory clean

**Display results to user:**
```text
✅ Implementation Complete

Summary:
- Steps completed: [list]
- Tests added: [count]
- Files modified: [count]
- Commits: [count]

Ready to create PR
```

**Ask user:** "Proceed with PR creation? (yes/review/modify)"

**WAIT for confirmation.**

### STEP 7: PUSH BRANCH

```bash
git push -u origin issue<issue-number>
```

**IF auth failure:**
```bash
gh auth setup-git
git push -u origin issue<issue-number>
```

### STEP 8: CREATE PR

**Generate PR title:**
```
<type>: <description> (closes #<issue-number>)
```

**Generate PR body:**
```markdown
## Description
[Summary of changes]

## Implementation
[Approach taken and rationale]

See plan: `.cursor/plans/issue-<number>.md`

## Changes

### Core Implementation
- <file>: <what changed>

### Tests
- <test-file>: <coverage>

### Documentation
- <doc-file>: <updates>
- CHANGELOG.md: Entry added

## Testing
- [x] Unit tests added
- [x] Integration tests added
- [x] All tests passing
- [x] Manual testing completed
- [x] Edge cases covered

## Quality Checks
- [x] Pre-commit hooks passed
- [x] No linting errors
- [x] Documentation complete
- [x] CHANGELOG updated
- [x] Follows project conventions
- [x] No debug code

## Related Issues
Closes #<issue-number>

## Commits
[List commits with brief descriptions]
```

**Create PR:**
```bash
cat > /tmp/pr-body.md << 'EOF'
[PR body]
EOF

gh pr create \
  --title "<type>: <description> (closes #<issue-number>)" \
  --body-file /tmp/pr-body.md \
  --draft

rm /tmp/pr-body.md
```

### STEP 9: COMPLETION REPORT

```text
✅ Issue #<number> Solution Complete

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Summary:
- Branch: issue<number>
- Commits: <count> atomic commits
- Files changed: <count>
- Tests added: <count>
- PR: #<pr-number> (draft)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Implementation:
[Brief summary of approach]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Next Steps:
1. Review PR: <url>
2. Mark ready when confident
3. Respond to review feedback
4. Merge when approved

Plan: .cursor/plans/issue-<number>.md
```

## COMMIT FREQUENCY

**Make commits:**
- After each logical unit (30-60 min work)
- When step in plan complete
- Before risky changes
- When tests pass for component

**Reference issue:**
- Body: `Related to #<n>` or `Fixes #<n>`
- Last commit: `Fixes #<n>` in footer

## COMMUNICATION PRINCIPLES

**Be transparent:**
- Share reasoning
- Explain trade-offs
- Show progress updates
- Ask when uncertain

**Ask for feedback:**
- Multiple valid approaches
- Ambiguous requirements
- Performance vs complexity
- Breaking changes

**Report blockers:**
- Dependencies on other work
- Unclear requirements
- Security/architecture concerns
- Need for user decision

## SCENARIOS

**Simple bug fix:**
- Quick analysis
- Brief plan (can skip options)
- 1-2 commits (fix + changelog)
- Quick PR

**Complex feature:**
- Extensive analysis
- Detailed plan with options
- User feedback required
- 5+ commits
- Comprehensive PR

**Issue requires clarification:**
```text
After analyzing issue #X, questions:

1. [Question about requirement]
2. [Question about scope]
3. [Question about constraints]

Recommend:
- Comment on issue for clarification
- OR make reasonable assumptions (documented)

How to proceed?
```
→ WAIT for user response

## ERROR RECOVERY

**Working directory not clean:**
→ List uncommitted files
→ Guide: commit, stash, or discard
→ ABORT until clean

**Branch exists with conflicts:**
→ Guide rebase
→ Help resolve conflicts
→ Verify clean after resolution

**Pre-commit hooks fail:**
→ Read error output
→ Fix issues (ruff, shellcheck, etc.)
→ Re-stage files
→ Retry commit
→ NEVER skip without permission

**Issue complex/blocked:**
→ Explain blockers
→ Present options
→ Provide recommendation
→ WAIT for user decision

## QUALITY CHECKLIST (EVERY COMMIT)

Before committing:
- [ ] Follows project coding standards
- [ ] No hardcoded values
- [ ] Proper error handling
- [ ] Type hints/annotations
- [ ] Docstrings added
- [ ] No commented code
- [ ] No console.logs/debug prints
- [ ] Imports organized

## EXECUTION CHECKLIST

**Pre-execution:**
- [ ] Issue fetched and analyzed
- [ ] Working directory clean
- [ ] Branch created/checked out

**During execution:**
- [ ] Plan created and approved
- [ ] Implementation follows plan
- [ ] Regular atomic commits
- [ ] Tests added
- [ ] Docs updated
- [ ] CHANGELOG updated
- [ ] User informed of progress

**Post-execution:**
- [ ] All tests passing
- [ ] Pre-commit hooks passed
- [ ] Final verification complete
- [ ] Branch pushed
- [ ] PR created
- [ ] Plan documented

---

**For autonomous approach without user confirmations, see yolo-issue.md**
