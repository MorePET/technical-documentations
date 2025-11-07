# GitHub Actions Workflows

## Centralized Workflows

MorePET uses centralized reusable workflows from [MorePET/github-actions](https://github.com/MorePET/github-actions).

All MorePET repositories should call these workflows instead of maintaining local copies.

## Renovate (Dependency Updates)

MorePET uses **three specialized Renovate workflows** for different dependency types:

### 1. External Dependencies (Scheduled)

**File:** `.github/workflows/renovate-external-dependencies.yml`

**Purpose:** Updates from PyPI, pre-commit, GitHub Actions

**Template:**

```yaml
---
name: Renovate (External Dependencies)

on:
  schedule:
    - cron: '0 2 * * 1'  # Weekly on Monday at 2 AM UTC
  workflow_dispatch:

jobs:
  renovate:
    uses: MorePET/github-actions/.github/workflows/renovate-reusable.yml@main
    with:
      config_file: '.github/renovate-external-dependencies.json'
    secrets:
      token: ${{ secrets.RENOVATE_TOKEN }}
```

**Config:** `.github/renovate-external-dependencies.json`

### 2. Internal Dependencies (Triggered)

**File:** `.github/workflows/renovate-internal-dependencies.yml`

**Purpose:** Updates from MorePET internal packages/tools (triggered by package releases)

**Template:**

```yaml
---
name: Renovate (Internal Dependencies)

on:
  workflow_dispatch:  # Triggered by internal MorePET package releases

jobs:
  renovate:
    uses: MorePET/github-actions/.github/workflows/renovate-reusable.yml@main
    with:
      config_file: '.github/renovate-internal-dependencies.json'
    secrets:
      token: ${{ secrets.RENOVATE_TOKEN }}
```

**Config:** `.github/renovate-internal-dependencies.json`

**Self-Triggering Pattern:**

- Producer repos (with internal packages) trigger all repos with this workflow
- Consumer repos (using internal packages) receive updates
- Repos can be BOTH producer and consumer (loose coupling)

### 3. Internal Containers (Triggered)

**File:** `.github/workflows/renovate-internal-containers.yml`

**Purpose:** Updates from MorePET container images (triggered by MorePET/containers releases)

**Template:**

```yaml
---
name: Renovate (Internal Containers)

on:
  workflow_dispatch:  # Triggered by MorePET/containers releases

jobs:
  renovate:
    uses: MorePET/github-actions/.github/workflows/renovate-reusable.yml@main
    with:
      config_file: '.github/renovate-internal-containers.json'
    secrets:
      token: ${{ secrets.RENOVATE_TOKEN }}
```

**Config:** `.github/renovate-internal-containers.json`

**Monitored Container Types:**

- Devcontainers (`.devcontainer/devcontainer.json`)
- Docker/Podman (`Dockerfile`, `Containerfile`)
- Compose (`docker-compose.yml`, `podman-compose.yml`)

## Auto-Discovery Pattern

Internal dependencies and containers use **auto-discovery** to trigger consuming repos:

### How It Works

1. **Producer repo releases** (e.g., MorePET/containers tags new image)
2. **Search for consumers** via GitHub Code Search API
3. **Find all repos** with the corresponding workflow file
4. **Trigger workflows** automatically in those repos
5. **Create PRs** within minutes of release

### Implementation in Producer Repos

Add to your release workflow (in MorePET/containers or internal package repos):

```yaml
name: Release

on:
  pull_request:
    types: [closed]
    branches: [main]

jobs:
  release:
    if: github.event.pull_request.merged == true
    runs-on: ubuntu-latest
    steps:
      # Your build/release steps here

      - name: Trigger Renovate in consuming repos
        run: |
          # For containers: search for renovate-internal-containers.yml
          # For packages: search for renovate-internal-dependencies.yml
          WORKFLOW_FILE="renovate-internal-containers.yml"  # or renovate-internal-dependencies.yml

          echo "Finding repos with $WORKFLOW_FILE..."

          SEARCH="path:.github/workflows/${WORKFLOW_FILE}+org:MorePET"
          gh api "/search/code?q=${SEARCH}" \
            --jq '.items[].repository.name' | \
          while read -r repo; do
            echo "Triggering $WORKFLOW_FILE in MorePET/$repo..."
            gh workflow run "$WORKFLOW_FILE" \
              --repo "MorePET/$repo" \
              --ref main || echo "Failed to trigger $repo"
          done
        env:
          GH_TOKEN: ${{ secrets.ORG_PAT }}
```

### Required in Producer Repos

- **Organization-wide PAT** with `actions:write` permission
- Add as secret: `ORG_PAT`

### Benefits

- **Zero maintenance** - No list of consuming repos to update
- **Self-service** - Repos opt-in by adding the workflow
- **Automatic discovery** - New consumers automatically included
- **Loose coupling** - Repos discover each other via workflow presence

## Renovate Configuration Files

### External Dependencies Config

**File:** `.github/renovate-external-dependencies.json`

```json
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "extends": ["config:recommended"],
  "packageRules": [
    {
      "description": "Security patches - immediate",
      "matchUpdateTypes": ["patch"],
      "matchManagers": ["pep621"],
      "vulnerabilityAlerts": { "enabled": true },
      "automerge": true,
      "automergeType": "pr",
      "minimumReleaseAge": null,
      "schedule": ["at any time"],
      "labels": ["dependencies", "security", "patch", "automerge"]
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
    }
  ],
  "prConcurrentLimit": 5,
  "prHourlyLimit": 2
}
```

### Internal Dependencies Config

**File:** `.github/renovate-internal-dependencies.json`

```json
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "extends": ["config:recommended"],
  "packageRules": [
    {
      "description": "Internal MorePET packages",
      "matchManagers": ["pep621"],
      "matchPackagePatterns": ["^morepet-", "^MorePET/"],
      "automerge": true,
      "automergeType": "pr",
      "minimumReleaseAge": "3 days",
      "labels": ["dependencies", "internal", "automerge"]
    }
  ],
  "hostRules": [
    {
      "matchHost": "https://github.com",
      "hostType": "github-packages"
    }
  ]
}
```

### Internal Containers Config

**File:** `.github/renovate-internal-containers.json`

```json
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "extends": ["config:recommended"],
  "packageRules": [
    {
      "description": "MorePET containers - all types",
      "matchManagers": ["devcontainer", "docker", "docker-compose"],
      "matchPackagePatterns": ["ghcr.io/morepet/containers/"],
      "automerge": false,
      "schedule": ["at any time"],
      "labels": ["dependencies", "internal", "container"]
    }
  ]
}
```

## CI/CD (Testing)

**File:** `.github/workflows/ci.yml`

**Purpose:** Run tests and linting on all PRs and pushes.

**Template:**

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

## Setup Checklist for New Repo

When adding workflows to a new repository:

**For all repos:**
- [ ] Copy `.github/workflows/ci.yml`
- [ ] Create fine-grained PAT with permissions:
  - Contents: Read and write
  - Pull requests: Read and write
  - Workflows: Read and write
- [ ] Add PAT as repository secret: `RENOVATE_TOKEN`
- [ ] Enable auto-merge in repository settings
- [ ] Push to main branch
- [ ] Verify CI runs on test PR

**If consuming external dependencies:**
- [ ] Copy `.github/workflows/renovate-external-dependencies.yml`
- [ ] Copy `.github/renovate-external-dependencies.json`
- [ ] Manually trigger workflow to test

**If consuming MorePET internal packages:**
- [ ] Copy `.github/workflows/renovate-internal-dependencies.yml`
- [ ] Copy `.github/renovate-internal-dependencies.json`
- [ ] Ensure producer repos have trigger logic

**If consuming MorePET containers:**
- [ ] Copy `.github/workflows/renovate-internal-containers.yml`
- [ ] Copy `.github/renovate-internal-containers.json`
- [ ] Ensure MorePET/containers has trigger logic

**If producing internal packages:**
- [ ] Add all above for internal dependencies
- [ ] Add release workflow with auto-discovery trigger
- [ ] Create organization PAT: `ORG_PAT`
- [ ] Use semantic versioning for releases

## GitHub Hygiene for Internal Dependencies

For auto-discovery to work with internal packages:

- ✅ Use semantic versioning (`v1.2.3`)
- ✅ Create GitHub releases or tags
- ✅ Follow semver conventions (MAJOR.MINOR.PATCH)
- ✅ Add trigger logic to release workflow

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

**Organization secrets** (for producer repos):
- `ORG_PAT` - Organization-wide PAT with `actions:write`

### Monitoring

Check these regularly:
- Actions tab: Failed workflow runs
- Renovate alerts
- Security advisories

## Troubleshooting

### Workflow not visible in Actions tab

→ Workflow must be on `main` branch to appear

### External Renovate creates no PRs

→ Check workflow logs, may indicate:
- No updates available
- Configuration error
- Token permissions issue

### Internal workflows not triggered

→ Check producer repo has:
- Trigger logic in release workflow
- Organization PAT with correct permissions
- Correct workflow file name in search

### Container updates not detected

→ Verify:
- Container image is from `ghcr.io/morepet/containers/*`
- Container file is in supported location
- Renovate config includes correct manager

### CI failing on Renovate PRs

→ Check if `uv.lock` is committed and up to date

### Token expired

→ Fine-grained PATs expire after 90 days, create new one

## Reusable Workflows (Already Implemented)

MorePET uses centralized reusable workflows in [MorePET/github-actions](https://github.com/MorePET/github-actions).

**Benefits:**
- One update updates all repos
- Centralized maintenance
- Consistent standards
