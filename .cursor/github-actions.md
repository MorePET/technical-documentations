# GitHub Actions Workflows

## Centralized Workflows

MorePET uses centralized reusable workflows from [MorePET/github-actions](https://github.com/MorePET/github-actions).

All MorePET repositories should call these workflows instead of maintaining local copies.

## Renovate (Dependency Updates)

**File:** `.github/workflows/renovate.yml`

**Purpose:** Automated dependency updates with 3-day soak time for patches.

**Template (calls central workflow):**

```yaml
---
name: Renovate

on:
  schedule:
    - cron: '0 2 * * 1'  # Weekly on Monday at 2 AM UTC
  workflow_dispatch:

jobs:
  renovate:
    uses: MorePET/github-actions/.github/workflows/renovate-reusable.yml@main
    secrets:
      token: ${{ secrets.RENOVATE_TOKEN }}
```

**Required:** 
- Repository secret: `RENOVATE_TOKEN` (fine-grained PAT)
- Config file: `.github/renovate.json` (in your repo)

## CI/CD (Testing)

**File:** `.github/workflows/ci.yml`

**Purpose:** Run tests and linting on all PRs and pushes.

**Template (calls central workflow):**

```yaml
---
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    uses: MorePET/github-actions/.github/workflows/ci-python-reusable.yml@main
```

**With custom Python version:**

```yaml
jobs:
  test:
    uses: MorePET/github-actions/.github/workflows/ci-python-reusable.yml@main
    with:
      python_version: '3.11'
      run_tests: true
```

## Renovate Configuration

**File:** `.github/renovate.json`

**Template:**

```json
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "extends": ["config:recommended"],
  "packageRules": [
    {
      "description": "Security updates - immediate",
      "matchManagers": ["pep621"],
      "vulnerabilityAlerts": {
        "enabled": true
      },
      "automerge": true,
      "automergeType": "pr",
      "minimumReleaseAge": null,
      "schedule": ["at any time"],
      "labels": ["dependencies", "security", "automerge"]
    },
    {
      "description": "Patch updates - 3 day soak time",
      "matchUpdateTypes": ["patch"],
      "matchManagers": ["pep621"],
      "groupName": "Python patch updates",
      "automerge": true,
      "automergeType": "pr",
      "minimumReleaseAge": "3 days",
      "schedule": ["at any time"],
      "labels": ["dependencies", "patch", "automerge"]
    },
    {
      "description": "Minor updates - manual review",
      "matchUpdateTypes": ["minor"],
      "matchManagers": ["pep621"],
      "groupName": "Python minor updates",
      "automerge": false,
      "schedule": ["every weekend"],
      "labels": ["dependencies", "minor"]
    },
    {
      "description": "Major updates - manual review",
      "matchUpdateTypes": ["major"],
      "matchManagers": ["pep621"],
      "groupName": "Python major updates",
      "automerge": false,
      "schedule": ["every 2 weeks on Monday"],
      "labels": ["dependencies", "major"]
    }
  ],
  "prConcurrentLimit": 5,
  "prHourlyLimit": 2
}
```

## Setup Checklist for New Repo

When adding these workflows to a new repository:

- [ ] Copy `.github/workflows/renovate.yml`
- [ ] Copy `.github/workflows/ci.yml`
- [ ] Copy `.github/renovate.json`
- [ ] Create fine-grained PAT with permissions:
  - Contents: Read and write
  - Pull requests: Read and write
  - Workflows: Read and write
- [ ] Add PAT as repository secret: `RENOVATE_TOKEN`
- [ ] Push to main branch
- [ ] Manually trigger Renovate workflow to test
- [ ] Verify CI runs on test PR

## Updating Workflows Across Repos

**Manual approach** (current):
1. Update workflow in one repo
2. Copy to other repos
3. Commit in each repo

**Automated approach** (future, if needed):
1. Create `MorePET/github-actions` repo
2. Convert workflows to reusable workflows
3. Call from each repo with:
   ```yaml
   jobs:
     renovate:
       uses: MorePET/github-actions/.github/workflows/renovate.yml@main
       secrets:
         token: ${{ secrets.RENOVATE_TOKEN }}
   ```

## Best Practices

### Workflow Versioning

Pin action versions but let Renovate update them:

```yaml
- uses: actions/checkout@v4              # Renovate updates this
- uses: renovatebot/github-action@v40.3.12  # Renovate updates this
```

### Branch Protection

Enable branch protection on `main`:
- Require PR reviews
- Require status checks (CI) to pass
- Require branches to be up to date

### Secrets Management

**Repository secrets:**
- `RENOVATE_TOKEN` - Fine-grained PAT for Renovate

**Organization secrets** (if multiple repos):
- Share `RENOVATE_TOKEN` across all repos in MorePET

### Monitoring

Check these regularly:
- Actions tab: Failed workflow runs
- Dependabot/Renovate alerts
- Security advisories

## Troubleshooting

### Workflow not visible in Actions tab

→ Workflow must be on `main` branch to appear

### Renovate creates no PRs

→ Check workflow logs, may indicate:
- No updates available
- Configuration error
- Token permissions issue

### CI failing on Renovate PRs

→ Check if `uv.lock` is committed and up to date

### Token expired

→ Fine-grained PATs expire after 90 days, create new one

## Advanced: Reusable Workflows

If MorePET grows to 5+ repos, consider centralizing:

### Create `MorePET/github-actions` repo

**`.github/workflows/renovate-reusable.yml`:**

```yaml
name: Renovate (Reusable)

on:
  workflow_call:
    secrets:
      token:
        required: true

jobs:
  renovate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: renovatebot/github-action@v40.3.12
        with:
          token: ${{ secrets.token }}
```

### In each repo:

```yaml
jobs:
  renovate:
    uses: MorePET/github-actions/.github/workflows/renovate-reusable.yml@main
    secrets:
      token: ${{ secrets.RENOVATE_TOKEN }}
```

**Benefits:**
- One update updates all repos
- Centralized maintenance
- Consistent standards

**When to do this:**
- 5+ repositories using same workflows
- Organization-wide standards
- Dedicated DevOps/platform team
