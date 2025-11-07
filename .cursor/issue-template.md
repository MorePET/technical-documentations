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

## Issue Labels

Use appropriate labels:

**Type:**
- `bug` - Something isn't working
- `feature` - New feature request
- `task` - task

**Priority:**
- `critical` - Blocking, needs immediate attention
- `high` - Important, should be addressed soon
- `medium` - Normal priority
- `low` - Nice to have

**Status:**
- `needs-triage` - Needs initial review
- `confirmed` - Bug confirmed or feature approved
- `in-progress` - Someone is working on it
- `blocked` - Waiting on something else
- `help-wanted` - Open for contributions
- `good-first-issue` - Good for newcomers

**Area:**
- `devcontainer` - Dev container related
- `documentation` - Documentation
- `ci-cd` - CI/CD pipeline
- `tooling` - Development tools
- `build` - Build system

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

### Using `gh` CLI

The `gh` CLI allows programmatic issue creation, useful for automation and scripts.

**Bug report:**

```bash
gh issue create \
  --title "bug: Brief description of the problem" \
  --body "## Description

Detailed bug description here.

## Steps to Reproduce

1. Step one
2. Step two

## Expected Behavior

What should happen.

## Actual Behavior

What actually happens." \
  --label "bug,needs-triage"
```

**Feature request:**

```bash
gh issue create \
  --title "feat: Add support for new feature" \
  --body "## Problem Statement

Describe the problem this feature would solve.

## Proposed Solution

Describe your proposed solution.

## Alternatives Considered

What other solutions have you thought about?" \
  --label "feature,needs-triage"
```

**From a file:**

```bash
# Create issue body in a file
cat > issue.md << 'EOF'
## Description
Bug details here...
EOF

gh issue create \
  --title "Bug: Title here" \
  --body-file issue.md \
  --label "bug,high"
```

**Important:** Labels must exist in the repository. Use `gh label list` to see available labels.

### Common `gh` CLI Options

| Flag | Description | Example |
|------|-------------|---------|
| `--title` | Issue title | `--title "Bug: Auth fails"` |
| `--body` | Issue body (inline) | `--body "Description..."` |
| `--body-file` | Issue body (from file) | `--body-file issue.md` |
| `--label` | Comma-separated labels | `--label "bug,critical"` |
| `--assignee` | Assign to user | `--assignee @me` |
| `--milestone` | Set milestone | `--milestone "v1.0"` |
| `--project` | Add to project | `--project "Sprint 1"` |
| `--repo` | Target repo | `--repo ORG/REPO` |
| `--web` | Open in browser | `--web` |

### Check Available Labels

Before creating issues, check what labels exist:

```bash
# List all labels in current repo
gh label list

# List labels in another repo
gh label list --repo ORG/REPO
```

### Create Missing Labels

If needed labels don't exist:

```bash
# Create label
gh label create "dependencies" --color "0366d6" --description "Dependency updates"

# Common labels for MorePET repos
gh label create "bug" --color "d73a4a"
gh label create "feature" --color "0e8a16"
gh label create "documentation" --color "0075ca"
gh label create "dependencies" --color "0366d6"
gh label create "devcontainer" --color "1d76db"
```
