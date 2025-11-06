# Renovate Setup Instructions

This repository uses centralized reusable workflows from [MorePET/github-actions](https://github.com/MorePET/github-actions) to automatically manage dependency updates.

## Prerequisites

You need to create a **Fine-Grained Personal Access Token (PAT)** to allow Renovate to access this repository.

## Step 1: Enable Auto-merge in Repository Settings

**This is required for Renovate to auto-merge PRs after CI passes.**

1. **Go to:** This repository's **Settings** → **General**

2. **Scroll to** "Pull Requests" section

3. **Check** ✅ **"Allow auto-merge"**

4. **Click** "Save" if prompted

## Step 2: Create Fine-Grained PAT

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

## Step 3: Add Token to Repository Secrets

1. **Go to:** This repository's **Settings** → **Secrets and variables** → **Actions**

2. **Click** "New repository secret"

3. **Configure the secret:**
   - **Name:** `RENOVATE_TOKEN`
   - **Value:** Paste the fine-grained PAT from Step 1

4. **Click** "Add secret"

## Step 4: Test the Workflow

1. **Go to:** Actions tab in this repository

2. **Select** "Renovate" workflow from the left sidebar

3. **Click** "Run workflow" dropdown → "Run workflow"

4. **Wait** for the workflow to complete (~1-2 minutes)

5. **Check** for any PRs created by Renovate

## How It Works

### Schedule

- **Runs:** Every Monday at 2:00 AM UTC
- **Manual trigger:** Available from Actions tab anytime

### Auto-merge Strategy

**Renovate automatically enables auto-merge** on PRs it creates. When CI passes, GitHub will merge the PR automatically.

Renovate will auto-merge certain updates after CI passes:

| Update Type | Soak Time | Auto-merge? | Labels |
|-------------|-----------|-------------|--------|
| **Security** | Immediate | ✅ Yes | `security`, `automerge` |
| **Patch** (x.x.N) | 3 days | ✅ Yes | `patch`, `automerge` |
| **Minor** (x.N.0) | - | ❌ No (manual review) | `minor` |
| **Major** (N.0.0) | - | ❌ No (manual review) | `major` |

### Soak Time

The **3-day soak time** for patch updates means:
- Renovate detects a new patch version (e.g., `ruff 0.14.4`)
- Waits 3 days for community to find issues
- After 3 days, creates PR automatically
- If CI passes, auto-merges

This protects you from being an early adopter of buggy releases.

### What Gets Updated

- Python dependencies in `pyproject.toml` / `uv.lock`
- Pre-commit hooks in `.pre-commit-config.yaml`
- GitHub Actions in `.github/workflows/`

## Security

- ✅ Runs entirely in GitHub Actions (no data to third parties)
- ✅ Uses your GitHub Actions minutes (free for public repos)
- ✅ Token scoped to this repository only
- ✅ Token expires in 90 days (renewal required)

## Token Renewal

When the token expires (90 days):

1. You'll get a workflow failure notification
2. Follow Step 1-2 above to create and add a new token
3. No other changes needed

## Configuration

Configuration files:

- **`.github/workflows/renovate.yml`** - Workflow schedule and settings
- **`.github/renovate.json`** - Renovate behavior and rules

To modify update strategy, edit `.github/renovate.json`.

## Troubleshooting

### Workflow fails with "Bad credentials"

→ Token expired or invalid. Create a new PAT and update the secret.

### No PRs created

→ Check workflow logs in Actions tab. May indicate:
- No updates available
- Configuration error
- Rate limit reached (unlikely for single repo)

### PR created but not auto-merging

→ Check:
- CI tests are passing
- Update type matches auto-merge rules
- For patches: 3-day soak time has elapsed

## Support

For Renovate-specific issues, see:
- [Renovate Docs](https://docs.renovatebot.com/)
- [Renovate GitHub Discussions](https://github.com/renovatebot/renovate/discussions)
