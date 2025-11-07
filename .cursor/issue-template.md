# Issue Creation Guidelines

## When to Create an Issue

Create issues for:

- ✅ Bug reports
- ✅ Feature requests
- ✅ Documentation improvements
- ✅ Questions about behavior
- ✅ Security vulnerabilities
- ✅ Performance problems

Don't create issues for:
- ❌ General questions (use discussions)
- ❌ Duplicate issues (search first)
- ❌ Support requests (use discussions)

## Issue Types

### Bug Report

```markdown
## Description

Brief description of the bug.

## Steps to Reproduce

1. Step one
2. Step two
3. Step three

## Expected Behavior

What should happen.

## Actual Behavior

What actually happens.

## Environment

- OS: [e.g., macOS 14.0, Ubuntu 22.04]
- Container Runtime: [Docker/Podman]
- Version: [e.g., 0.1.0]
- Dev Container: [Yes/No]

## Screenshots/Logs

Add relevant screenshots or log output.

## Additional Context

Any other information about the problem.
```

### Feature Request

```markdown
## Problem Statement

Describe the problem this feature would solve.
"I want to... but currently I can't because..."

## Proposed Solution

Describe your proposed solution.

## Alternatives Considered

What other solutions have you thought about?

## Additional Context

- Use cases
- Examples from other projects
- Mockups or diagrams (if applicable)

## Implementation Notes

(Optional) Technical details or suggestions for implementation.
```

### Documentation Issue

```markdown
## Documentation Problem

What documentation is missing, unclear, or incorrect?

## Location

Link to the file or section that needs improvement.

## Suggested Improvement

What should be added or changed?

## Why This Matters

How would this help users?
```

### Security Vulnerability

**DO NOT** create a public issue for security vulnerabilities.

Instead:
1. Email: security@example.com (if configured)
2. Use GitHub Security Advisories
3. Contact maintainers privately

## GitHub Native Issue Types

MorePET repositories use GitHub's native issue types (not labels) for categorization:

**Available Types:**
- `bug` - Something isn't working (crashes, errors, unexpected behavior)
- `feature` - New feature request (enhancements, new functionality)
- `task` - Work item or chore (documentation, refactoring, maintenance)

**Setting types:** Use the REST API (see "Creating Issues via CLI" section below).

**Note:** MorePET does not use labels for categorization. Use issue types instead.

## Issue Title Guidelines

Write clear, searchable titles:

✅ Good titles:
- "GitHub CLI authentication fails in container"
- "Add support for dark mode in documentation"
- "Pre-commit hooks fail on Apple Silicon"

❌ Bad titles:
- "Bug"
- "It doesn't work"
- "Help needed"
- "Question about stuff"

## Writing Good Issues

### Be Specific

❌ "The auth doesn't work"
✅ "GitHub CLI authentication fails with 'token invalid' error in dev container"

### Provide Context

Include:
- What you were trying to do
- What you expected to happen
- What actually happened
- Your environment details

### Include Reproduction Steps

Make it easy for others to see the problem:
1. Exact commands you ran
2. Configuration files used
3. Error messages (full output)

### Search First

Before creating an issue:
1. Search existing issues
2. Check closed issues
3. Check documentation
4. Check discussions

If you find a duplicate:
- Comment on the existing issue
- Add any new information
- Subscribe for updates

## Issue Lifecycle

1. **Created** - New issue submitted
2. **Triaged** - Maintainer reviews and labels
3. **Confirmed** - Issue validated
4. **In Progress** - Someone working on it
5. **PR Created** - Pull request linked
6. **Resolved** - Fixed in main branch
7. **Closed** - Issue completed or declined

## Issue Etiquette

**Do:**
- ✅ Be polite and professional
- ✅ Provide all requested information
- ✅ Update if you find a solution
- ✅ Thank contributors
- ✅ Test suggested fixes

**Don't:**
- ❌ Bump issues unnecessarily
- ❌ Demand immediate fixes
- ❌ Post "+1" comments (use 👍 reaction)
- ❌ Go off-topic in discussions
- ❌ Tag maintainers repeatedly

## Closing Issues

Issues are closed when:
- ✅ Fixed by a merged PR
- ✅ Working as intended (not a bug)
- ✅ Duplicate of existing issue
- ✅ Won't be implemented (with explanation)
- ✅ Stale (no activity for extended period)
- ✅ Invalid (spam, unclear, etc.)

## Issue Templates

The project provides issue templates in `.github/ISSUE_TEMPLATE/`:
- `bug_report.md` - For bug reports
- `feature_request.md` - For feature requests
- `documentation.md` - For documentation issues

Use the appropriate template when creating issues.

## Creating Issues via CLI

### Using GitHub REST API (with issue types)

GitHub now supports **issue types** (bug, feature, task) via the REST API. This is the recommended approach for MorePET repos.

**Bug report:**

```bash
gh api \
  --method POST \
  /repos/ORG/REPO/issues \
  --field title="Brief description of the problem" \
  --field body="## Description

Detailed bug description here.

## Steps to Reproduce

1. Step one
2. Step two

## Expected Behavior

What should happen.

## Actual Behavior

What actually happens." \
  --field type="Bug"
```

**Feature request:**

```bash
gh api \
  --method POST \
  /repos/ORG/REPO/issues \
  --field title="Add support for new feature" \
  --field body="## Problem Statement

Describe the problem this feature would solve.

## Proposed Solution

Describe your proposed solution.

## Alternatives Considered

What other solutions have you thought about." \
  --field type="Feature"
```

**Task:**

```bash
gh api \
  --method POST \
  /repos/ORG/REPO/issues \
  --field title="Task: Brief description" \
  --field body="## Task Description

What needs to be done.

## Checklist

- [ ] Subtask 1
- [ ] Subtask 2" \
  --field type="Task"
```

**From a file:**

```bash
# Create issue body in a file
cat > issue.md << 'EOF'
## Description
Bug details here...
EOF

gh api \
  --method POST \
  /repos/ORG/REPO/issues \
  --field title="Brief description" \
  --field body="$(cat issue.md)" \
  --field type="Bug"
```

### Available Issue Types

GitHub supports three issue types:

| Type | When to Use | Example |
|------|-------------|---------|
| `bug` | Something isn't working | Auth fails, crashes, errors |
| `feature` | New functionality request | Add dark mode, API endpoint |
| `task` | Work item or chore | Update docs, refactor code |

### Common REST API Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `title` | Issue title | `--field title="Fix auth bug"` |
| `body` | Issue description | `--field body="Description..."` |
| `type` | Type (Bug/Feature/Task) | `--field type="Bug"` |
| `assignees` | Assign users (array) | `--field assignees[]=username` |
| `milestone` | Milestone number | `--field milestone=5` |

### Examples for Different Repos

**Current repo:**

```bash
gh api --method POST /repos/{owner}/{repo}/issues \
  --field title="Title" \
  --field body="Body" \
  --field type="Bug"
```

**Different repo:**

```bash
gh api --method POST /repos/MorePET/containers/issues \
  --field title="Add Renovate support" \
  --field body="$(cat issue-body.md)" \
  --field type="Feature"
```

### Assign to Yourself

```bash
gh api --method POST /repos/ORG/REPO/issues \
  --field title="Title" \
  --field body="Body" \
  --field type="Task" \
  --field assignees[]="@me"
```
