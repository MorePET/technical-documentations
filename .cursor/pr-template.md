# Pull Request Guidelines

## Creating a Pull Request

### Branch Naming

Follow the format: `<type>/<short-description>`

Types:
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation changes
- `refactor/` - Code refactoring
- `test/` - Test additions or changes
- `chore/` - Maintenance tasks
- `release/` - Release preparation

Examples:
- `feature/add-dark-mode`
- `fix/authentication-bug`
- `docs/update-readme`

### PR Title Format

Use clear, descriptive titles:

```
<type>: Brief description of changes
```

Examples:
- `feature: Add automatic GitHub CLI authentication`
- `fix: Resolve SSH key path mismatch`
- `docs: Update dev container setup guide`

### PR Description Template

```markdown
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

## Screenshots (if applicable)

Add screenshots or GIFs for UI changes.

## Checklist

- [ ] Code follows project conventions
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] CHANGELOG.md updated (if user-facing change)
- [ ] No breaking changes (or documented)
- [ ] Commits are atomic and well-described
```

## PR Review Guidelines

### As Author

Before requesting review:

1. **Self-review your own PR**
   - Read through the diff
   - Check for console.logs, TODOs, or debug code
   - Verify all tests pass
   - Run pre-commit hooks

2. **Keep PRs focused**
   - One feature/fix per PR
   - Avoid mixing unrelated changes
   - If scope grows, split into multiple PRs

3. **Write clear commit messages**
   - Follow conventional commits
   - First line: brief summary (50 chars)
   - Body: explain why, not what

4. **Respond promptly to feedback**
   - Address all review comments
   - Ask questions if unclear
   - Mark conversations as resolved when fixed

### As Reviewer

1. **Review promptly**
   - Aim to review within 24 hours
   - If you can't, let author know

2. **Be constructive**
   - Suggest improvements, don't just criticize
   - Explain the "why" behind suggestions
   - Differentiate between blockers and nits

3. **Check thoroughly**
   - Code logic and correctness
   - Test coverage
   - Documentation completeness
   - Security implications
   - Performance impact

4. **Use GitHub review features**
   - Use "Request Changes" for blockers
   - Use "Approve" when ready to merge
   - Use "Comment" for discussions

### Review Comments Format

```markdown
**Blocker**: Must be fixed before merging
**Suggestion**: Nice to have but not required
**Question**: Seeking clarification
**Nit**: Minor style/formatting suggestion
```

## Merging PRs

### When to Merge

- ✅ At least one approval
- ✅ All CI checks passing
- ✅ All conversations resolved
- ✅ Branch up to date with main
- ✅ No merge conflicts

### Merge Strategies

**Use "Merge Commit" for:**
- Release PRs (always)
- Large feature branches with multiple commits
- PRs where commit history is important

**Use "Squash and Merge" for:**
- Small fixes or features
- PRs with messy commit history
- When you want clean linear history

**Never use "Rebase and Merge" for:**
- Release PRs (breaks tagging)

## PR Size Guidelines

**Ideal PR size:**
- Changed lines: < 400
- Files changed: < 10
- Review time: < 30 minutes

**If your PR is too large:**
- Split into multiple PRs
- Create a tracking issue
- Link PRs together

## Common PR Mistakes to Avoid

❌ Committing directly to main
❌ Pushing without running pre-commit
❌ Including unrelated changes
❌ Not updating documentation
❌ Not updating CHANGELOG.md
❌ Force pushing to shared branches
❌ Merging your own PRs without review
❌ Ignoring CI failures

## CI/CD Integration

All PRs automatically run:
- Pre-commit hooks (ruff, shellcheck, markdown linting)
- Unit tests
- Integration tests
- Linting checks

PRs cannot be merged until all checks pass.

## Draft PRs

Use draft PRs when:
- Work in progress
- Seeking early feedback
- Running CI on incomplete code

Convert to "Ready for Review" when done.
