# Create Issue Command

This command helps you create issues in GitHub repositories using the GitHub CLI.

For complete documentation on issue creation guidelines, templates, and examples, see:

**[Issue Template Documentation](./../issue-template.md)**

## Workflow

When creating an issue, follow these steps:

1. **Determine the target repository:**
   - If user specifies a repo (e.g., "ORG/REPO"), use that
   - Otherwise, detect current repo with: `gh repo view --json nameWithOwner --jq .nameWithOwner`

2. **Verify the repository exists:**
   ```bash
   gh repo view ORG/REPO --json nameWithOwner,description
   ```
   - If successful, show repo name and description
   - If failed, inform user the repo doesn't exist or isn't accessible

3. **Confirm with user:**
   - Show the repo name
   - Show the issue type (Bug/Feature/Task)
   - Show the issue title
   - Show a preview of the issue body
   - Ask for confirmation before creating

4. **Create the issue** only after confirmation

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

**See [issue-template.md](./../issue-template.md) for detailed guidelines, templates, and examples.**
