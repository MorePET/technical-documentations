# Create Issue Command

**CREATES GITHUB ISSUES - REQUIRES USER CONFIRMATION**

Execute `/create-issue` to create issues following project standards.

## EXECUTION PROTOCOL

### STEP 1: DETERMINE TARGET REPOSITORY

```bash
# If user specifies repo: use "ORG/REPO"
# Otherwise detect current:
REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
```

### STEP 2: VERIFY REPOSITORY ACCESS

```bash
gh repo view $REPO --json nameWithOwner,description
```

**IF fails:**
→ Display: "❌ Repository not found or not accessible: $REPO"
→ ABORT

**IF succeeds:**
→ Display repo name and description
→ PROCEED to STEP 3

### STEP 3: GATHER ISSUE DETAILS

**Determine from user input:**
- Issue type: Bug / Feature / Task
- Title (clear, descriptive)
- Body (structured with headings)
- Assignees (optional)

**Format body based on type:**

**Bug:**
```markdown
## Description
[What's wrong]

## Steps to Reproduce
1. [Step 1]
2. [Step 2]

## Expected Behavior
[What should happen]

## Actual Behavior
[What actually happens]

## Environment
- OS:
- Version:
```

**Feature:**
```markdown
## Feature Request
[What feature is needed]

## Use Case
[Why it's needed]

## Proposed Solution
[How it could work]

## Alternatives Considered
[Other approaches]
```

**Task:**
```markdown
## Task Description
[What needs to be done]

## Acceptance Criteria
- [ ] [Criterion 1]
- [ ] [Criterion 2]

## Related Issues
- Related to #X
```

### STEP 4: CONFIRM WITH USER (MANDATORY)

**MUST display preview and wait for confirmation:**

```text
📋 Issue Preview

Target: ORG/REPO
Type: Bug/Feature/Task
Title: "Your title here"

Body:
[First 20 lines of body...]

❓ Create this issue? (yes/no)
```

**WAIT for user response.**

**IF user says "no" or anything other than "yes":**
→ Display: "Issue creation cancelled"
→ ABORT

**IF user says "yes":**
→ PROCEED to STEP 5

### STEP 5: CREATE ISSUE

**GitHub auto-assigns issue number - DO NOT specify it yourself:**

```bash
gh api --method POST /repos/$REPO/issues \
  --field title="$TITLE" \
  --field body="$BODY"
```

**IF assignees requested:**
```bash
gh api --method POST /repos/$REPO/issues \
  --field title="$TITLE" \
  --field body="$BODY" \
  --field assignees[]="$USERNAME"
```

**DO NOT add labels unless user explicitly requests them.**

### STEP 6: CONFIRM CREATION

```text
✅ Issue created successfully

Issue: #<number>
Title: <title>
URL: https://github.com/ORG/REPO/issues/<number>
```

## ERROR HANDLING

**Repository not found:**
→ "❌ Repository not accessible: ORG/REPO"
→ Verify repo exists and you have access

**Authentication failure:**
→ Run `gh auth status`
→ Run `gh auth login` if not authenticated

**API error:**
→ Check error message from gh CLI
→ Verify user has write access to repo

## CRITICAL RULES

**NEVER:**
- ❌ Specify issue number (GitHub auto-assigns)
- ❌ Add labels without explicit user request
- ❌ Create without user confirmation
- ❌ Use fields other than: title, body, assignees

**ALWAYS:**
- ✅ Show preview before creating
- ✅ Wait for explicit "yes" confirmation
- ✅ Let GitHub assign issue number
- ✅ Use structured body format
