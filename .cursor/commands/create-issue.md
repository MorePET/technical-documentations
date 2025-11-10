# Create Issue Command

This command helps you create issues in GitHub repositories using the GitHub CLI.

## ⚠️ CRITICAL WORKFLOW - MUST FOLLOW

When creating an issue, **ALWAYS** follow these steps in order:

### 1. Determine the target repository

- If user specifies a repo (e.g., "ORG/REPO"), use that
- Otherwise, detect current repo with: `gh repo view --json nameWithOwner --jq .nameWithOwner`

### 2. Verify the repository exists

```bash
gh repo view ORG/REPO --json nameWithOwner,description
```

- If successful, show repo name and description
- If failed, inform user the repo doesn't exist or isn't accessible

### 3. **⚠️ CONFIRM WITH USER FIRST** (MANDATORY)

**DO NOT create the issue yet!** Show the user:
- ✓ Target repository: `ORG/REPO`
- ✓ Issue type: `Bug` / `Feature` / `Task`
- ✓ Issue title: `"Your title here"`
- ✓ Preview of issue body (first 20 lines)
- ❓ **Ask:** "Create this issue? (yes/no)"

### 4. Create the issue ONLY after user confirms "yes"

GitHub will automatically assign the next available issue number. **DO NOT** specify the issue number yourself!

## Quick Reference

### Create a Bug Issue

```bash
gh api \
  --method POST \
  /repos/ORG/REPO/issues \
  --field title="Brief description of the problem" \
  --field body="<your issue body>" \
  --field type="Bug"
```

### Create a Feature Issue

```bash
gh api \
  --method POST \
  /repos/ORG/REPO/issues \
  --field title="Feature title" \
  --field body="<your issue body>" \
  --field type="Feature"
```

### Create a Task Issue

```bash
gh api \
  --method POST \
  /repos/ORG/REPO/issues \
  --field title="Task: Brief description" \
  --field body="<your issue body>" \
  --field type="Task" \
  --field assignees[]="username"
```

**Important Notes:**
- GitHub automatically assigns the next available issue number
- **DO NOT add labels** unless explicitly requested by user
- Only use: `title`, `body`, `type`, and optionally `assignees[]`

## Utility Commands

### Get Current Repo

```bash
gh repo view --json nameWithOwner --jq .nameWithOwner
```

### Verify Repo Exists

```bash
gh repo view ORG/REPO --json nameWithOwner,description
```

Example output:

```json
{
  "description": "Repository description",
  "nameWithOwner": "ORG/REPO"
}
```

### Check Repo Access

```bash
gh repo view ORG/REPO --json nameWithOwner,description,viewerPermission
```

---

## Examples

### Example 1: Bug Report

```bash
# 1. Get repo
REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner)

# 2. Show user what will be created
echo "Creating bug report in $REPO"
echo "Type: Bug"
echo "Title: Login button doesn't work on mobile"
echo ""
echo "Create this issue? (yes/no)"
read -r confirm

# 3. Create only if confirmed
if [ "$confirm" = "yes" ]; then
  gh api --method POST /repos/$REPO/issues \
    --field title="Login button doesn't work on mobile" \
    --field body="## Description
Login button is not responsive on mobile devices..." \
    --field type="Bug"
fi
```

### Example 2: Feature Request

```bash
gh api --method POST /repos/ORG/REPO/issues \
  --field title="Add dark mode support" \
  --field body="## Feature Request\n\nWe should add dark mode..." \
  --field type="Feature"
```

---

## Common Mistakes

❌ **Specifying issue number** - GitHub assigns this automatically
❌ **Adding labels** - DO NOT add `labels[]` unless user explicitly asks
❌ **Creating without confirmation** - Always ask user first
❌ **Wrong type values** - Must be exactly: `Bug`, `Feature`, or `Task`
❌ **Assuming what user wants** - Only add fields user explicitly requests
