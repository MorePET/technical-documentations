# Renovate Setup Instructions

This repository uses centralized reusable workflows from [MorePET/github-actions](https://github.com/MorePET/github-actions) to automatically manage dependency updates.

## Architecture Overview

Dependencies are managed through **three specialized Renovate workflows**:

| Workflow | Trigger | Purpose | Config File |
|----------|---------|---------|-------------|
| `renovate-external-dependencies.yml` | Scheduled (weekly) | PyPI, pre-commit, GitHub Actions | `renovate-external-dependencies.json` |
| `renovate-internal-dependencies.yml` | Triggered by package releases | MorePET internal packages/tools | `renovate-internal-dependencies.json` |
| `renovate-internal-containers.yml` | Triggered by container releases | MorePET container images | `renovate-internal-containers.json` |

### External Dependencies (Scheduled)

Runs **every Monday at 2 AM UTC** to check for updates from:

- Python packages on PyPI
- Pre-commit hooks
- GitHub Actions

### Internal Dependencies (Triggered)

Triggered automatically when any MorePET internal package/tool is released:

- **Producer repos** (with internal packages) trigger all repos with this workflow on release
- **Consumer repos** (using internal packages) have this workflow to receive updates
- **Repos can be BOTH** producer and consumer (loose coupling via workflow presence)
- Requires semantic versioned tags/releases (GitHub hygiene)

### Internal Containers (Triggered)

Triggered automatically when MorePET/containers releases new images:

- Monitors **all container types**: Docker, Podman, devcontainer, docker-compose
- Checks `Dockerfile`, `Containerfile`, `docker-compose.yml`, `.devcontainer/devcontainer.json`
- Only updates images from `ghcr.io/morepet/containers/*`

## Prerequisites

### Step 1: Enable Auto-merge in Repository Settings

**This is required for Renovate to auto-merge PRs after CI passes.**

1. **Go to:** This repository's **Settings** → **General**
2. **Scroll to** "Pull Requests" section
3. **Check** ✅ **"Allow auto-merge"**
4. **Click** "Save" if prompted

### Step 2: Create Fine-Grained PAT

1. **Go to:** [github.com/settings/tokens?type=beta](https://github.com/settings/tokens?type=beta)

2. **Click** "Generate new token"

3. **Configure the token:**
   - **Token name:** `Renovate Self-Hosted`
   - **Expiration:** 90 days (recommended for security)
   - **Repository access:** "Only select repositories"
     - Select this repository only

4. **Permissions → Repository permissions:**
   - **Contents:** Read and write ✅
   - **Pull requests:** Read and write ✅
   - **Workflows:** Read and write ✅
   - **Metadata:** Read-only (automatic) ✅

5. **Click** "Generate token"

6. **Copy the token** (you won't see it again!)

### Step 3: Add Token to Repository Secrets

1. **Go to:** This repository's **Settings** → **Secrets and variables** → **Actions**

2. **Click** "New repository secret"

3. **Configure the secret:**
   - **Name:** `RENOVATE_TOKEN`
   - **Value:** Paste the fine-grained PAT from Step 2

4. **Click** "Add secret"

### Step 4: Test the Workflows

1. **Go to:** Actions tab in this repository

2. **Select** "Renovate (External Dependencies)" workflow from the left sidebar

3. **Click** "Run workflow" dropdown → "Run workflow"

4. **Wait** for the workflow to complete (~1-2 minutes)

5. **Check** for any PRs created by Renovate

## Auto-merge Strategy

Renovate automatically enables auto-merge on PRs it creates. When CI passes, GitHub will merge the PR automatically.

### External Dependencies

| Update Type | Soak Time | Auto-merge? | Labels |
|-------------|-----------|-------------|--------|
| **Security Patch** | Immediate | ✅ Yes | `security`, `patch`, `automerge` |
| **Patch** (x.x.N) | 3 days | ✅ Yes | `patch`, `automerge` |
| **Minor** (x.N.0) | - | ❌ No (manual review) | `minor` |
| **Major** (N.0.0) | - | ❌ No (manual review) | `major` |

### Internal Dependencies

Same strategy as external, but applies to MorePET internal packages:

| Update Type | Soak Time | Auto-merge? | Labels |
|-------------|-----------|-------------|--------|
| **Security Patch** | Immediate | ✅ Yes | `internal`, `security`, `patch`, `automerge` |
| **Patch** (x.x.N) | 3 days | ✅ Yes | `internal`, `patch`, `automerge` |
| **Minor** (x.N.0) | - | ❌ No (manual review) | `internal`, `minor` |
| **Major** (N.0.0) | - | ❌ No (manual review) | `internal`, `major` |

### Internal Containers

All container updates require manual review (no auto-merge):

| Update Type | Auto-merge? | Labels |
|-------------|-------------|--------|
| **All updates** | ❌ No (manual review) | `internal`, `container` |

## Soak Time

The **3-day soak time** for patch updates means:
- Renovate detects a new patch version (e.g., `ruff 0.14.4`)
- Waits 3 days for community to find issues
- After 3 days, creates PR automatically
- If CI passes, auto-merges

This protects you from being an early adopter of buggy releases.

## Container Support

The internal containers workflow monitors:
- **Devcontainers:** `.devcontainer/devcontainer.json`
- **Docker/Podman:** `Dockerfile`, `Containerfile`
- **Compose:** `docker-compose.yml`, `docker-compose.yaml`, `podman-compose.yml`

Only MorePET container images (`ghcr.io/morepet/containers/*`) are tracked.

## Trigger Mechanisms

### Auto-Discovery Pattern

**Internal dependencies and containers use auto-discovery:**

1. When a MorePET package/container is released
2. Producer repo searches for all repos with the corresponding workflow file
3. Triggers those workflows automatically
4. Zero maintenance - new consumers are discovered automatically

**Example:**
- MorePET/containers releases new typst image
- Searches for all repos with `renovate-internal-containers.yml`
- Triggers those workflows
- PRs created in consuming repos within minutes

### Self-Triggering for Internal Dependencies

Repos with `renovate-internal-dependencies.yml` can be:
- **Producer:** Releases internal packages, triggers all repos with this workflow
- **Consumer:** Uses internal packages, receives update PRs
- **Both:** Produces package-a, consumes package-b (loose coupling)

## GitHub Hygiene Requirement

For internal dependencies to work, source repos must:
- ✅ Use semantic versioning for releases (e.g., `v1.2.3`)
- ✅ Create GitHub releases or tags
- ✅ Follow semver conventions (MAJOR.MINOR.PATCH)

## Security

- ✅ Runs entirely in GitHub Actions (no data to third parties)
- ✅ Uses your GitHub Actions minutes (free for public repos)
- ✅ Token scoped to this repository only
- ✅ Token expires in 90 days (renewal required)

## Token Renewal

When the token expires (90 days):

1. You'll get a workflow failure notification
2. Follow Step 2-3 above to create and add a new token
3. No other changes needed

## Configuration Files

| File | Purpose |
|------|---------|
| `.github/workflows/renovate-external-dependencies.yml` | External deps workflow schedule |
| `.github/workflows/renovate-internal-dependencies.yml` | Internal deps workflow (triggered) |
| `.github/workflows/renovate-internal-containers.yml` | Container workflow (triggered) |
| `.github/renovate-external-dependencies.json` | External deps behavior rules |
| `.github/renovate-internal-dependencies.json` | Internal deps behavior rules |
| `.github/renovate-internal-containers.json` | Container behavior rules |

## Troubleshooting

### Workflow fails with "Bad credentials"

→ Token expired or invalid. Create a new PAT and update the secret.

### No PRs created (External Dependencies)

→ Check workflow logs in Actions tab. May indicate:
- No updates available
- Configuration error
- Rate limit reached (unlikely for single repo)

### No PRs created (Internal Dependencies/Containers)

→ Workflow must be triggered by producer repo. Check:
- Producer repo has trigger logic implemented
- This repo has the correct workflow file present
- Token has correct permissions

### PR created but not auto-merging

→ Check:
- CI tests are passing
- Update type matches auto-merge rules
- For patches: 3-day soak time has elapsed
- Auto-merge is enabled in repository settings

### Container updates not detected

→ Check:
- Container image is from `ghcr.io/morepet/containers/*`
- Container file is in supported location
- Renovate config includes correct manager type

## Support

For Renovate-specific issues, see:
- [Renovate Docs](https://docs.renovatebot.com/)
- [Renovate GitHub Discussions](https://github.com/renovatebot/renovate/discussions)
