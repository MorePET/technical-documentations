# Linter and Pre-commit System

This project uses a comprehensive linting and formatting system via `pre-commit` hooks to ensure code quality and consistency.

## Quick Start

### Installing Pre-commit Hooks

```bash
# Install pre-commit hooks (one-time setup)
make install-hook

# Or manually
pre-commit install
```

Once installed, the hooks will run automatically on `git commit`.

### Running Manually

```bash
# Run on all files
pre-commit run --all-files

# Run on staged files only
pre-commit run

# Run specific hook
pre-commit run trailing-whitespace --all-files
pre-commit run ruff-check --all-files
```

### Skipping Hooks (Use Sparingly!)

```bash
# Skip hooks for a specific commit (not recommended)
git commit --no-verify -m "message"
```

## Configured Hooks

### General File Checks

These hooks from `pre-commit-hooks` ensure basic file hygiene:

| Hook | What it does | Auto-fixes |
|------|-------------|------------|
| `check-added-large-files` | Prevents accidentally committing large files | No |
| `check-case-conflict` | Checks for files with case conflicts | No |
| `check-json` | Validates JSON syntax | No |
| `check-merge-conflict` | Detects merge conflict markers | No |
| `check-symlinks` | Checks for broken symlinks | No |
| `check-toml` | Validates TOML syntax | No |
| `check-yaml` | Validates YAML syntax | No |
| `debug-statements` | Detects debug statements in Python | No |
| `destroyed-symlinks` | Detects destroyed symlinks | No |
| `detect-private-key` | Prevents committing private keys | No |
| `end-of-file-fixer` | Ensures files end with newline | Yes |
| `mixed-line-ending` | Normalizes line endings | Yes |
| `trailing-whitespace` | Removes trailing whitespace | Yes |

### Python: Ruff

[Ruff](https://docs.astral.sh/ruff/) is an extremely fast Python linter and formatter (written in Rust).

```bash
# Linting with auto-fix
uv run ruff check --fix

# Formatting
uv run ruff format

# Check specific files
uv run ruff check scripts/*.py
```

**Pre-commit hooks:**

- `ruff-check`: Runs linter with auto-fix, ignoring docstring rules (D)
- `ruff-format`: Formats Python code

### YAML: yamllint

Validates YAML files for syntax and style issues.

```bash
# Run manually
yamllint .pre-commit-config.yaml

# Pre-commit runs with: --format parsable --strict
```

### Shell: ShellCheck

[ShellCheck](https://www.shellcheck.net/) is a static analysis tool for shell scripts.

```bash
# Run manually
shellcheck scripts/*.sh

# Check specific file
shellcheck scripts/build-all.sh
```

**Common ShellCheck issues fixed in this project:**
- SC2181: Check exit code directly instead of using `$?`

### Markdown: PyMarkdown

Validates Markdown files for common issues.

```bash
# Run manually
pymarkdown scan README.md

# Scan all markdown files
pymarkdown scan *.md docs/*.md
```

### Docker: Hadolint

Lints Dockerfiles and Containerfiles (runs via Podman).

```bash
# Run manually
podman run --rm -i hadolint/hadolint < .devcontainer/Containerfile
```

## Configuration Files

### `.pre-commit-config.yaml`

Main configuration file for all hooks:

```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v5.0.0
    hooks:
      - id: trailing-whitespace
      # ... more hooks

  - repo: local
    hooks:
      - id: ruff-check
        entry: uv run ruff check --fix --ignore=D
```

### `pyproject.toml`

Ruff configuration (if needed):

```toml
[tool.ruff]
line-length = 88
target-version = "py311"
```

### `.pymarkdown.config.md`

PyMarkdown configuration for Markdown linting rules.

### `.hadolint.yaml`

Hadolint configuration for Dockerfile linting.

## Troubleshooting

### Pre-commit Hook Fails

If a hook fails:

1. **Check the output** - most hooks show exactly what needs to be fixed
2. **Auto-fixes** - some hooks (like `trailing-whitespace`) auto-fix files
3. **Stage the fixes** - run `git add` on auto-fixed files
4. **Try again** - run `git commit` again

Example workflow:

```bash
$ git commit -m "Update docs"
# Hook fails: trailing-whitespace fixes files

$ git add -u  # Stage the auto-fixes
$ git commit -m "Update docs"  # Try again
# Success!
```

### Ruff Errors

```bash
# Show what ruff would fix
uv run ruff check

# Apply fixes automatically
uv run ruff check --fix

# Format code
uv run ruff format

# Then stage and commit
git add -u && git commit
```

### ShellCheck Warnings

Most ShellCheck warnings are style suggestions. Common fixes:

```bash
# Bad: Check $? separately
command
if [ $? -eq 0 ]; then

# Good: Check directly
if command; then
```

### Skip Specific Warnings

For legitimate cases where you need to skip a warning:

```bash
# Disable specific ShellCheck rule
# shellcheck disable=SC2181
if [ $? -eq 0 ]; then
```

### Update Hooks

```bash
# Update all hooks to latest versions
pre-commit autoupdate

# Then commit the updated .pre-commit-config.yaml
git add .pre-commit-config.yaml
git commit -m "Update pre-commit hooks"
```

## HTML File Generation

The HTML generation scripts automatically fix trailing whitespace issues via the
`fix_trailing_whitespace()` function in `scripts/build-html.py`. This ensures
generated HTML files pass linter checks without manual intervention.

## Benefits

- [x] **Consistency** - Enforces coding standards automatically
- [x] **Quality** - Catches common errors before they're committed
- [x] **Time-saving** - Auto-fixes many issues (whitespace, formatting)
- [x] **Learning** - Helpful error messages teach best practices
- [x] **CI-ready** - Same checks can run in CI/CD pipelines

## Best Practices

1. **Run pre-commit early** - Don't wait until commit time

   ```bash
   pre-commit run --all-files  # Before starting work
   ```

2. **Stage incrementally** - Don't commit everything at once

   ```bash
   git add specific-file.py  # Stage one file at a time
   git commit                # Test hooks on small changes
   ```

3. **Read the messages** - Hook failures are educational
   - They tell you exactly what's wrong
   - They often suggest the fix

4. **Keep hooks updated** - Run `pre-commit autoupdate` monthly

5. **Don't skip hooks** - If you need to skip, document why:

   ```bash
   git commit --no-verify -m "Emergency fix (skipping hooks - will fix in next commit)"
   ```

## Resources

- [Pre-commit documentation](https://pre-commit.com/)
- [Ruff documentation](https://docs.astral.sh/ruff/)
- [ShellCheck wiki](https://www.shellcheck.net/wiki/)
- [yamllint documentation](https://yamllint.readthedocs.io/)
- [PyMarkdown](https://github.com/jackdewinter/pymarkdown)
