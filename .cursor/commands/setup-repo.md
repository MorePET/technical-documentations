# Setup Repository Command

This command guides you through setting up a new MorePET repository with all required configurations, workflows, and standards.

For complete documentation on each setup component, see:

**Related Documentation:**

- **[GitHub Actions](./../github-actions.md)**
- **[Git Workflow](./../git-workflow.md)**
- **[Python Development](./../python.md)**
- **[Pull Request Guidelines](./../pr-template.md)**
- **[Issue Templates](./../issue-template.md)**

## Repository Creation Checklist

### 1. Create Repository

**Option A: Using GitHub CLI (Recommended)**

```bash
# Create private repo (MorePET standard)
gh repo create MorePET/new-repo-name \
  --private \
  --description "Brief description of the project" \
  --add-readme \
  --gitignore Python
```

**Option B: Using Web Interface**

- Go to <https://github.com/MorePET>
- Click "New repository"
- Name: `new-repo-name`
- Description: Brief project description
- Visibility: Private
- Initialize with README
- Add Python .gitignore

### 2. Clone and Initial Setup

```bash
# Clone the repository
git clone https://github.com/MorePET/new-repo-name.git
cd new-repo-name

# Set up Git configuration (if not already done)
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519_github.pub
git config --global commit.gpgsign true
```

### 3. Initialize Python Project

```bash
# Create basic project structure
mkdir -p src tests docs
touch src/__init__.py tests/__init__.py

# Create pyproject.toml
cat > pyproject.toml << 'EOF'
[build-system]
requires = ["setuptools>=61.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "new-repo-name"
version = "0.1.0"
description = "Brief description"
authors = [{name = "MorePET", email = "info@morepet.org"}]
requires-python = ">=3.10"
dependencies = []

[project.optional-dependencies]
dev = [
    "pytest>=8.0.0",
    "ruff>=0.1.0",
    "pre-commit>=3.0.0",
]

[tool.setuptools.packages.find]
where = ["src"]

[tool.ruff]
line-length = 88
target-version = "py310"

[tool.ruff.lint]
select = ["E", "F", "I", "N", "UP", "B", "A", "C4", "T20", "SIM", "PIE", "RET", "RUF"]
ignore = ["E501", "B008"]

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = "test_*.py"
python_classes = "Test*"
python_functions = "test_*"
EOF

# Create requirements files
cat > requirements.txt << 'EOF'
# Production dependencies will go here
# Add dependencies with: uv pip install package && uv pip freeze > requirements.txt
EOF

cat > requirements-dev.txt << 'EOF'
-r requirements.txt
pytest>=8.0.0
ruff>=0.1.0
pre-commit>=3.0.0
EOF
```

### 4. Set Up Pre-commit Hooks

```bash
# Install pre-commit
uv pip install --system pre-commit

# Create .pre-commit-config.yaml
cat > .pre-commit-config.yaml << 'EOF'
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
      - id: check-merge-conflict

  - repo: local
    hooks:
      - id: ruff
        name: ruff
        entry: uv run ruff check --fix
        language: system
        types: [python]
        require_serial: true
      - id: ruff-format
        name: ruff-format
        entry: uv run ruff format
        language: system
        types: [python]
        require_serial: true

  - repo: https://github.com/shellcheck-py/shellcheck-py
    rev: v0.9.0.6
    hooks:
      - id: shellcheck
        args: [--severity=warning]

  - repo: https://github.com/pymarkdown/pymarkdown
    rev: 0.9.15
    hooks:
      - id: pymarkdown
        args: [--config, .pymarkdown.json]

  - repo: local
    hooks:
      - id: typst-check
        name: Typst Syntax Check
        entry: >
          bash -c 'for file in "$@"; do
          typst compile "$file" /dev/null || exit 1; done' --
        language: system
        files: '\.typ$'
        pass_filenames: true
EOF

# Create .pymarkdown.json config
cat > .pymarkdown.json << 'EOF'
{
  "plugins": {
    "pymarkdown.plugins.git-commit-check": {
      "enabled": true
    }
  }
}
EOF

# Install hooks
pre-commit install
```

### 5. Set Up GitHub Actions Workflows

**Create CI workflow:**

```bash
mkdir -p .github/workflows

# Create CI workflow
cat > .github/workflows/ci.yml << 'EOF'
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
EOF
```

**Create Renovate workflows (choose based on needs):**

```bash
# For repositories using external dependencies (PyPI, GitHub Actions)
cat > .github/workflows/renovate-external-dependencies.yml << 'EOF'
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
EOF

# Create Renovate config for external dependencies
cat > .github/renovate-external-dependencies.json << 'EOF'
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
EOF
```

### 6. Configure Branch Protection

**Using GitHub CLI:**

```bash
# Enable branch protection on main
gh api repos/MorePET/new-repo-name/branches/main/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":["test"]}' \
  --field enforce_admins=false \
  --field required_pull_requests='{
    "required_approving_review_count":1,
    "dismiss_stale_reviews":true,
    "require_code_owner_reviews":false,
    "dismissal_restrictions":{}
  }' \
  --field restrictions=null \
  --field allow_force_pushes=false \
  --field allow_deletions=false \
  --field block_creations=false
```

**Or manually:**
- Go to repository Settings → Branches
- Add rule for `main` branch
- Require pull request reviews (1 approval)
- Require status checks (CI tests)
- Include administrators
- Restrict pushes that create matching branches

### 7. Set Up Repository Secrets

**Create a fine-grained PAT for Renovate:**

```bash
# Generate token with these permissions:
# - Contents: Read and write
# - Pull requests: Read and write
# - Workflows: Read and write
```

**Add to repository secrets:**
- `RENOVATE_TOKEN`: The fine-grained PAT

### 8. Create Issue and PR Templates

```bash
mkdir -p .github/ISSUE_TEMPLATE

# Bug report template
cat > .github/ISSUE_TEMPLATE/bug_report.md << 'EOF'
---
name: Bug Report
about: Create a report to help us improve
title: 'bug: Brief description'
labels: ['bug']
---

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

- OS: [e.g., Linux, macOS, Windows]
- Python Version: [e.g., 3.10, 3.11]
- Container: [Dev Container/Podman/Docker]

## Additional Context

Any other information about the problem.
EOF

# Feature request template
cat > .github/ISSUE_TEMPLATE/feature_request.md << 'EOF'
---
name: Feature Request
about: Suggest an idea for this project
title: 'feature: Brief description'
labels: ['feature']
---

## Problem Statement

Describe the problem this feature would solve.

## Proposed Solution

Describe your proposed solution.

## Alternatives Considered

What other solutions have you thought about?

## Additional Context

Use cases, examples, mockups.
EOF

# PR template
cat > .github/PULL_REQUEST_TEMPLATE.md << 'EOF'
## Description

Brief summary of what this PR does and why.

## Changes

- Change 1
- Change 2
- Change 3

## Related Issues

Closes #123
Relates to #456

## Testing

- [ ] Tested locally in dev container
- [ ] All pre-commit hooks pass
- [ ] Manual testing completed
- [ ] Documentation updated (if needed)

## Checklist

- [ ] Code follows project conventions
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] CHANGELOG.md updated (if user-facing change)
- [ ] No breaking changes (or documented)
- [ ] Commits are atomic and well-described
EOF
```

### 9. Create Documentation Structure

```bash
# Create basic documentation
cat > README.md << 'EOF'
# New Repo Name

Brief description of what this project does.

## Installation

\`\`\`bash
# Clone the repository
git clone https://github.com/MorePET/new-repo-name.git
cd new-repo-name

# Install dependencies
uv pip install -r requirements-dev.txt

# Install pre-commit hooks
pre-commit install
\`\`\`

## Development

\`\`\`bash
# Run tests
uv run pytest

# Run linting
uv run ruff check .

# Format code
uv run ruff format .
\`\`\`

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development guidelines.

## License

[License information]
EOF
```

### Create CHANGELOG.md File

```bash
cat > CHANGELOG.md << 'EOF'
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Initial project setup
- Basic project structure
- CI/CD workflows
- Pre-commit hooks
EOF
```

### Create CONTRIBUTING.md

```bash
cat > CONTRIBUTING.md << 'EOF'
# Contributing

Thank you for your interest in contributing! Please read this document carefully.

## Development Setup

See [README.md](README.md) for installation instructions.

## Development Workflow

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Make your changes
4. Run tests: `uv run pytest`
5. Run linting: `uv run ruff check .`
6. Format code: `uv run ruff format .`
7. Commit your changes
8. Push to your fork
9. Create a pull request

## Commit Guidelines

We use [Conventional Commits](https://conventionalcommits.org/):

- `feat:` for new features
- `fix:` for bug fixes
- `docs:` for documentation
- `style:` for formatting
- `refactor:` for code restructuring
- `test:` for test additions
- `chore:` for maintenance

## Code Style

- Use `ruff` for linting and formatting
- Follow Google-style docstrings
- Use type hints
- Write tests for new functionality

## Pull Request Process

1. Update the README.md with details of changes if needed
2. Update CHANGELOG.md with your changes
3. Ensure all tests pass
4. Get at least one approval
5. Merge when ready
EOF
```

### 10. Initial Commit and Push

```bash
# Add all files
git add .

# Create initial commit
git commit -m "chore: initial project setup

- Set up Python project structure
- Configure pre-commit hooks
- Add GitHub Actions workflows
- Create documentation templates
- Configure branch protection"

# Push to main
git push origin main
```

### 11. Enable Auto-merge and Additional Settings

**Repository Settings to Configure:**
- Enable auto-merge for Renovate PRs
- Configure discussion categories (if needed)
- Set up code owners (if applicable)
- Configure security advisories

### 12. Test Everything Works

```bash
# Run pre-commit on all files
pre-commit run --all-files

# Run tests (will fail initially, but hooks should work)
uv run pytest

# Check CI by pushing a small change
echo "# Test" >> README.md
git add README.md
git commit -m "test: verify CI setup"
git push origin main
```

## Quick Setup Script (Optional)

For rapid setup of multiple repositories, you can create this script:

```bash
#!/bin/bash
# setup-repo.sh

REPO_NAME=$1

if [ -z "$REPO_NAME" ]; then
    echo "Usage: $0 <repo-name>"
    exit 1
fi

# Create repo
gh repo create MorePET/$REPO_NAME --private --add-readme --gitignore Python

# Clone and setup (continue with manual steps above)
git clone https://github.com/MorePET/$REPO_NAME.git
cd $REPO_NAME

echo "Repository $REPO_NAME created. Continue with manual setup steps."
```

## Verification Checklist

After setup, verify:

- [ ] Repository created and cloned
- [ ] Python project structure in place
- [ ] Pre-commit hooks installed and working
- [ ] GitHub Actions workflows present
- [ ] Branch protection configured
- [ ] Repository secrets added
- [ ] Issue and PR templates created
- [ ] Documentation files present
- [ ] Initial commit pushed
- [ ] CI runs on push to main

---

**See the referenced documentation files for detailed explanations of each component.**
