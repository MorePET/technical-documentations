# YOLO Issue Command 🚀

**⚠️ WARNING: AUTONOMOUS MODE - MINIMAL USER INTERVENTION**

This command provides a **fully autonomous, aggressive approach** to solving GitHub issues.
The AI will make independent decisions, implement solutions following best practices,
and create a pull request without seeking approval at each step.

**Usage:** `/yolo-issue <issue-number>`

**When to use:**

- ✅ You trust the AI's judgment completely
- ✅ Issue is well-defined with clear requirements
- ✅ You want a production-ready, fully-tested solution
- ✅ You're comfortable with the AI making architectural decisions

**When NOT to use:**
- ❌ Issue has ambiguous requirements
- ❌ Major architectural decisions needed
- ❌ Breaking changes required
- ❌ You want to review the plan first

**For a methodical approach with user input, see [solve-issue.md](./solve-issue.md).**

## 🎯 Autonomous Workflow

### Mode Characteristics

**YOLO Mode means:**

1. **Zero confirmation requests** - AI decides and acts
2. **Production quality** - SOLID, DRY, well-tested code
3. **Best practices enforced** - No shortcuts, no hardcoding
4. **Comprehensive testing** - Unit, integration, edge cases
5. **Complete documentation** - Code comments, docstrings, README updates
6. **Proactive commits** - Regular atomic commits throughout
7. **No half measures** - Solution is complete or nothing

**AI will autonomously:**
- Choose the best implementation approach
- Refactor existing code if needed
- Add extensive tests
- Update all relevant documentation
- Make architectural improvements
- Ensure code quality and maintainability
- Create production-ready PR

### 1. Issue Analysis & Repository State

**Fetch issue without asking:**

```bash
# Get repository
REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner)

# Fetch issue
gh issue view <issue-number> --json number,title,body,labels,state,assignees
```

**Analyze deeply:**
- Parse requirements and acceptance criteria
- Identify all affected components
- Review related code and patterns
- Identify potential edge cases
- Determine optimal architecture

**Check repository state:**

```bash
git status
```

**⚠️ CRITICAL: Working Directory Check**

**If NOT clean:**

❌ **STOP IMMEDIATELY** - Cannot proceed in YOLO mode with uncommitted changes.

```text
🛑 YOLO MODE ABORTED

Cannot proceed: working directory has uncommitted changes.

Modified files:
[list files]

YOLO mode requires a clean working directory to ensure
no work is lost during autonomous operations.

Action required:
1. Commit your changes (see git-commit.md)
2. Stash your changes: git stash save "wip"
3. Discard changes: git restore . (destructive)

Then run yolo-issue again.
```

**If clean:**

✅ **Proceed with full autonomy**

### 2. Branch Creation & Setup

**Execute without confirmation:**

```bash
# Update main
git checkout main
git pull origin main

# Create issue branch
git checkout -b issue<issue-number>
```

**Inform user (info only, no wait):**

```text
🚀 YOLO MODE ACTIVATED for Issue #<number>

Branch: issue<number>
Mode: Fully autonomous
Target: Production-ready solution

Working... (this may take a while)
```

### 3. Implementation Plan (Internal)

**Create plan automatically:**

Create `.cursor/plans/issue-<number>.md` with comprehensive analysis:

```markdown
# YOLO Implementation Plan - Issue #<number>

## Autonomous Analysis

**Issue:** [Title]
**Type:** Bug/Feature/Enhancement
**Complexity:** Low/Medium/High
**Estimated Changes:** <number> files

## Chosen Approach

**Decision:** [Approach selected]

**Rationale:**
- [Reason 1 - performance/maintainability/scalability]
- [Reason 2 - follows existing patterns]
- [Reason 3 - minimal breaking changes]

## Implementation Breakdown

### Phase 1: Core Implementation
- [ ] [Specific task]
- [ ] [Specific task]

### Phase 2: Testing
- [ ] Unit tests for all new functions
- [ ] Integration tests
- [ ] Edge case coverage
- [ ] Performance tests (if applicable)

### Phase 3: Documentation
- [ ] Docstrings for all public APIs
- [ ] README updates
- [ ] Usage examples
- [ ] CHANGELOG entry

### Phase 4: Code Quality
- [ ] Refactor for SOLID principles
- [ ] Remove code duplication (DRY)
- [ ] Extract magic numbers to constants
- [ ] Add type hints/annotations
- [ ] Ensure proper error handling

## Quality Gates

All must pass:
- ✅ All tests pass
- ✅ 100% of new code has tests
- ✅ No linting errors
- ✅ No hardcoded values
- ✅ All functions documented
- ✅ Follows project patterns
- ✅ No TODOs or debug code

## Commit Strategy

Planned commits:
1. `feat/fix(scope): implement core solution for #<n>`
2. `test(scope): add comprehensive tests for #<n>`
3. `refactor(scope): apply SOLID/DRY principles for #<n>`
4. `docs(scope): add documentation for #<n>`
5. `docs(changelog): update for #<n>`

## Acceptance Criteria Met

[List from issue, all checked off when complete]
```

**DO NOT show plan to user** - Execute immediately.

### 4. Implementation (Full Autonomy)

#### Code Quality Standards (Enforced)

**SOLID Principles - Mandatory:**

- **Single Responsibility** - Each function/class does ONE thing
- **Open/Closed** - Extend behavior without modifying existing code
- **Liskov Substitution** - Subtypes must be substitutable for base types
- **Interface Segregation** - Many specific interfaces > one general
- **Dependency Inversion** - Depend on abstractions, not concretions

**DRY - Don't Repeat Yourself:**
- Extract duplicate code into functions
- Create reusable utilities
- Use inheritance/composition appropriately
- Centralize configuration

**No Hardcoding - Zero Tolerance:**
- Use configuration files
- Use environment variables
- Use named constants
- Use dependency injection

**Clean Code Requirements:**
- Descriptive variable names (no `x`, `temp`, `data`)
- Clear function names (verb + noun)
- Functions under 50 lines (ideally 20)
- Proper error handling with specific exceptions
- Type hints on all functions (Python/TypeScript)
- Comprehensive docstrings

#### Implementation Process

**Phase 1: Core Implementation**

```bash
# Implement the solution
# - Follow existing code patterns
# - Use proper abstractions
# - Handle edge cases
# - Add logging where appropriate

# Commit when logical unit complete
git add <relevant files>
git commit -m "feat/fix(scope): implement core functionality for #<n>

[Detailed description of implementation]
[Explain key decisions]
[Note any trade-offs]

Related to #<n>"
```

**Phase 2: Comprehensive Testing**

```bash
# Add thorough tests
# - Unit tests for each function
# - Integration tests for workflows
# - Edge cases and error conditions
# - Performance tests if applicable

git add tests/
git commit -m "test(scope): add comprehensive test suite for #<n>

Tests include:
- Unit tests for [components]
- Integration tests for [workflows]
- Edge cases: [scenarios]
- Error handling: [conditions]

Coverage: aim for >90% of new code

Related to #<n>"
```

**Phase 3: Refactoring for Quality**

```bash
# Review and refactor
# - Apply SOLID principles
# - Remove duplication
# - Extract constants
# - Improve naming
# - Add type hints

git add <files>
git commit -m "refactor(scope): enhance code quality for #<n>

Applied SOLID principles:
- [Specific refactorings]

Removed duplication:
- [Extracted functions/classes]

Improved maintainability:
- [Type hints, constants, etc.]

Related to #<n>"
```

**Phase 4: Documentation**

```bash
# Add comprehensive documentation
# - Docstrings for all public APIs
# - Update README if needed
# - Add usage examples
# - Document configuration options

git add docs/ README.md <source files>
git commit -m "docs(scope): document solution for #<n>

Added:
- Docstrings for all public functions
- README section on [feature]
- Usage examples
- Configuration documentation

Related to #<n>"
```

**Phase 5: Changelog**

```bash
# Update CHANGELOG.md
git add CHANGELOG.md
git commit -m "docs(changelog): add entry for #<n>

[Brief description of user-facing change]

Fixes #<n>"
```

#### Quality Enforcement (Automated)

**Before each commit, automatically:**

**1. Run linters and fix issues:**

```bash
# Python
uv run ruff check --fix .
uv run ruff format .

# Shellcheck for scripts
shellcheck *.sh

# Other project-specific linters
```

**2. Run tests:**

```bash
# Project-specific test command
[run tests]
```

**3. Verify no hardcoding:**

- Scan for magic numbers
- Check for hardcoded paths/URLs
- Verify config usage

**4. Check documentation:**

- Verify docstrings exist
- Check for TODO/FIXME comments
- Validate examples if present

**If quality checks fail:**
- **FIX AUTOMATICALLY** - Don't ask user
- Commit fixes separately
- Continue implementation

### 5. Testing Strategy (Rigorous)

**Test Coverage Requirements:**

**Unit Tests - Mandatory:**
- Test each function independently
- Mock external dependencies
- Test happy path
- Test error cases
- Test edge cases (empty, null, boundary values)

**Integration Tests - Required:**
- Test component interactions
- Test database operations (if applicable)
- Test API endpoints (if applicable)
- Test user workflows

**Edge Cases - Comprehensive:**
- Empty inputs
- Null/None values
- Boundary values (0, -1, max int)
- Invalid types
- Concurrent access (if applicable)
- Large datasets (performance)

**Example Test Structure:**

```python
def test_new_feature_happy_path():
    """Test normal operation."""
    assert function(valid_input) == expected_output

def test_new_feature_empty_input():
    """Test with empty input."""
    with pytest.raises(ValueError):
        function("")

def test_new_feature_null_input():
    """Test with None."""
    assert function(None) == default_value

def test_new_feature_boundary_values():
    """Test edge cases."""
    assert function(0) == expected_for_zero
    assert function(-1) == expected_for_negative
    assert function(sys.maxsize) == expected_for_large

def test_new_feature_integration():
    """Test integration with other components."""
    result = full_workflow(input)
    assert result.status == "success"
```

### 6. Pre-PR Verification (Automated)

**Run full verification suite:**

```bash
# 1. All tests pass
[run all tests]

# 2. Linting clean
[run all linters]

# 3. Type checking (if applicable)
[mypy, typescript, etc.]

# 4. Working directory clean
git status

# 5. Review commits
git log --oneline origin/main..HEAD
```

**Verification Checklist (All automated):**
- [x] All tests passing (100%)
- [x] No linting errors (0)
- [x] No type errors (if applicable)
- [x] All new code has tests
- [x] Documentation complete
- [x] No TODOs, FIXMEs, or debug code
- [x] No console.logs or print statements
- [x] No commented-out code
- [x] CHANGELOG updated
- [x] All commits follow conventional format
- [x] Working directory clean

### 7. Pull Request Creation (Autonomous)

**Push branch:**

```bash
git push origin issue<issue-number>
```

**Create comprehensive PR:**

```bash
gh pr create \
  --title "<type>: <description> (closes #<issue-number>)" \
  --body "## 🚀 YOLO Mode Implementation

This PR was autonomously generated to resolve issue #<issue-number>.

## Description

[Comprehensive description of changes]

## Implementation Approach

[Explanation of chosen approach and rationale]

See detailed plan: `.cursor/plans/issue-<issue-number>.md`

## Changes

### Core Implementation
- [Change 1 with file references]
- [Change 2 with file references]
- [Change 3 with file references]

### Tests Added
- [Test suite 1 - coverage info]
- [Test suite 2 - coverage info]
- [Edge cases covered]

### Documentation
- [Doc update 1]
- [Doc update 2]
- [CHANGELOG entry]

## Code Quality

This implementation follows:
- ✅ **SOLID Principles** - [specific examples]
- ✅ **DRY** - No code duplication
- ✅ **Clean Code** - Descriptive names, proper abstractions
- ✅ **Type Safety** - Full type hints/annotations
- ✅ **Error Handling** - Comprehensive error cases
- ✅ **No Hardcoding** - Configuration-driven

## Testing

### Test Coverage
- Unit tests: [X files, Y functions covered]
- Integration tests: [Z scenarios]
- Edge cases: [List key edge cases]
- All tests passing: ✅

### Test Results
\`\`\`
[Test output summary]
\`\`\`

## Quality Checks

- [x] All tests passing
- [x] No linting errors
- [x] No type errors
- [x] Documentation complete
- [x] CHANGELOG updated
- [x] No debug code
- [x] Follows project conventions
- [x] Pre-commit hooks passed

## Commits

This PR includes [N] atomic commits:
1. \`feat/fix(scope): core implementation\`
2. \`test(scope): comprehensive test suite\`
3. \`refactor(scope): code quality improvements\`
4. \`docs(scope): documentation\`
5. \`docs(changelog): changelog entry\`

Each commit is independently reviewable and follows conventional commit format.

## Related Issues

Closes #<issue-number>
[Related to #X if applicable]

## Reviewer Notes

This was implemented in YOLO mode with:
- Autonomous decision-making
- Best practice enforcement
- Comprehensive testing
- Production-ready quality

Please review for:
1. Alignment with project vision
2. Any missed edge cases
3. Documentation clarity
4. Architectural fit

## Implementation Plan

Detailed implementation plan available at:
\`.cursor/plans/issue-<issue-number>.md\`" \
  --draft
```

**Mark as ready for review:**

```bash
gh pr ready
```

### 8. Completion Report

**Report to user:**

```text
✅ YOLO MODE COMPLETE - Issue #<number>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Summary

Issue: #<number> - <title>
Branch: issue<number>
Commits: <N> atomic commits
Files Changed: <count>
Tests Added: <count>
Test Coverage: >90%
Lines Changed: +<added> -<removed>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 Implementation Highlights

✅ Core solution implemented following SOLID principles
✅ Comprehensive test suite (unit + integration + edge cases)
✅ Zero hardcoding - all values configurable
✅ Full documentation with examples
✅ CHANGELOG updated
✅ All quality checks passed

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📁 Key Changes

Core Implementation:
- <file1>: <description>
- <file2>: <description>

Tests:
- <test_file1>: <description>
- <test_file2>: <description>

Documentation:
- <doc_file>: <description>
- CHANGELOG.md: Entry added

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔗 Pull Request

PR: #<pr-number>
Status: Ready for Review
URL: <pr-url>

Plan: .cursor/plans/issue-<number>.md

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✨ Code Quality Metrics

- SOLID: ✅ All principles applied
- DRY: ✅ No code duplication
- Type Safety: ✅ Full type hints
- Test Coverage: ✅ >90%
- Documentation: ✅ Complete
- Linting: ✅ 0 errors
- Pre-commit: ✅ All hooks passed

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚀 Ready for Review

The solution is production-ready and awaiting maintainer review.

All autonomous decisions documented in the implementation plan.
```

## YOLO Mode Principles

### Decision-Making Authority

**AI has full authority to:**
- Choose implementation approach
- Select libraries/dependencies
- Make architectural decisions
- Refactor existing code
- Add comprehensive tests
- Update documentation
- Make quality improvements
- Determine commit granularity

**AI will NOT:**
- Make breaking changes without noting in PR
- Delete existing functionality
- Skip tests
- Compromise on code quality
- Use `--no-verify` on commits
- Leave TODOs or incomplete work

### Quality Non-Negotiables

**Every YOLO implementation must have:**

1. **SOLID Architecture**
   - Single Responsibility: Each component does one thing
   - Open/Closed: Extensible without modification
   - Proper abstraction layers

2. **DRY Code**
   - Zero duplication
   - Extracted common logic
   - Reusable utilities

3. **No Hardcoding**
   - Configuration files
   - Environment variables
   - Named constants
   - Dependency injection

4. **Comprehensive Tests**
   - >90% coverage of new code
   - Edge cases covered
   - Error conditions tested
   - Integration tests

5. **Complete Documentation**
   - Docstrings for all public APIs
   - Usage examples
   - README updates
   - CHANGELOG entry

6. **Clean Code**
   - Descriptive naming
   - Type hints/annotations
   - Proper error handling
   - No debug code

### When YOLO Mode Should Abort

**Stop and ask user if:**

1. **Breaking changes required** - Major API changes need discussion
2. **Security implications** - Auth, encryption, data access changes
3. **Database migrations** - Schema changes need planning
4. **External dependencies** - New major dependencies need approval
5. **Performance trade-offs** - Speed vs memory vs complexity decisions
6. **Issue is ambiguous** - Requirements unclear or contradictory
7. **Architectural overhaul** - Major refactoring beyond issue scope

**In these cases:**

```text
⚠️ YOLO MODE PAUSED

Issue #<number> requires human decision:

Situation:
[Explain the blocker]

Options:
1. [Option A - pros/cons]
2. [Option B - pros/cons]
3. [Option C - pros/cons]

This decision impacts:
- [Impact area 1]
- [Impact area 2]

Recommendation: [Your recommendation with rationale]

Please confirm approach before proceeding.
```

## Comparison: solve-issue vs yolo-issue

| Aspect | solve-issue | yolo-issue |
|--------|-------------|------------|
| **User Input** | Required at key points | Minimal (only if blocked) |
| **Planning** | Show plan, get feedback | Internal plan, execute |
| **Approach Selection** | User chooses | AI decides |
| **Code Quality** | Good practices | Enforced excellence |
| **Testing** | Tests added | Comprehensive suite |
| **Commits** | Regular | Highly organized |
| **Time** | Depends on feedback | Fast (no waiting) |
| **Autonomy** | Guided | Fully autonomous |
| **Best For** | Learning, oversight | Speed, trust |

## Examples

### Example 1: Bug Fix

```text
User: /yolo-issue 42

AI: 🚀 YOLO MODE ACTIVATED for Issue #42

[5 minutes later]

✅ YOLO MODE COMPLETE

Issue: #42 - API timeout on /users endpoint
Solution: Increased timeout + added connection pooling
Commits: 4 atomic commits
Tests: 15 new tests (unit + integration + edge cases)
PR: #156 (ready for review)

Key improvements:
- Fixed immediate timeout issue
- Refactored connection handling (DRY)
- Added retry logic with exponential backoff
- 100% test coverage of new code
- Updated API documentation
```

### Example 2: Feature Implementation

```text
User: /yolo-issue 89

AI: 🚀 YOLO MODE ACTIVATED for Issue #89

[15 minutes later]

✅ YOLO MODE COMPLETE

Issue: #89 - Add user profile export feature
Solution: Complete export system with multiple formats
Commits: 7 atomic commits
Tests: 28 tests (unit + integration + edge cases)
PR: #157 (ready for review)

Implemented:
- Export to JSON, CSV, PDF formats
- Async processing for large datasets
- Progress tracking UI
- Proper error handling
- Rate limiting
- Configurable output options

SOLID principles applied:
- Strategy pattern for export formats
- Factory for format selection
- Dependency injection for services

No hardcoding:
- All limits in config
- File paths from env vars
- Format options configurable
```

## Quick Reference

### Command

```bash
/yolo-issue <number>
```

### Requirements

- Clean working directory (no uncommitted changes)
- GitHub CLI authenticated
- Issue exists and is accessible
- Pre-commit hooks configured

### Workflow Summary

```text
1. Fetch issue → 2. Verify clean state → 3. Create branch
     ↓
4. Analyze & plan (internal) → 5. Implement with quality
     ↓
6. Test comprehensively → 7. Document thoroughly
     ↓
8. Create PR → 9. Report completion
```

### After YOLO Completion

```bash
# Review the commits
git log origin/main..HEAD

# Review the changes
git diff origin/main...HEAD

# Check the plan
cat .cursor/plans/issue-<number>.md

# View PR
gh pr view
```

---

**⚠️ Use YOLO mode responsibly:**
- For well-defined issues
- When you trust AI judgment
- For production-quality solutions
- When speed matters

**For more control, use [solve-issue.md](./solve-issue.md) instead.**

**For commit and PR guidelines, see [git-commit.md](./git-commit.md) and [create-pr.md](./create-pr.md).**
