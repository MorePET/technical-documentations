# YOLO Implementation Plan - Issue #20

## Autonomous Analysis

**Issue:** Add Cursor commands for automated tag-and-release and PR version bumping
**Type:** Feature
**Complexity:** Medium
**Estimated Changes:** 2 files (1 new, 1 update)

## Chosen Approach

**Decision:** Create standalone `/tag-and-release` command and enhance existing `/create-pr` command

**Rationale:**

- Follows existing command pattern and structure
- Single responsibility: tag-and-release handles releases, create-pr handles PRs
- Integrates seamlessly with version management system
- Reuses existing tools (make version, bump scripts)
- Validates against standards (Keep a Changelog, Semantic Versioning)

## Implementation Breakdown

### Phase 1: Create `/tag-and-release` Command

- [ ] Create `.cursor/commands/tag-and-release.md`
- [ ] Implement validation workflow
- [ ] Add CHANGELOG.md parser
- [ ] Add version continuity checker
- [ ] Add git tag creation logic
- [ ] Add GitHub release creation logic

### Phase 2: Enhance `/create-pr` Command

- [ ] Read existing create-pr.md
- [ ] Add version analysis section
- [ ] Add commit analysis for semver suggestion
- [ ] Add version bump workflow
- [ ] Integrate with make targets

### Phase 3: Documentation

- [ ] Complete command documentation with examples
- [ ] Add troubleshooting sections
- [ ] Update relevant docs if needed

### Phase 4: Validation

- [ ] Test version extraction
- [ ] Test CHANGELOG validation
- [ ] Test tag continuity checking
- [ ] Verify commands follow existing patterns

## Quality Gates

All must pass:
- ✅ Commands follow existing .cursor/commands pattern
- ✅ Clear error messages for validation failures
- ✅ Comprehensive examples
- ✅ Integration with version management system
- ✅ No hardcoded values
- ✅ Follows Keep a Changelog and Semantic Versioning standards

## Commit Strategy

Planned commits:
1. `feat(workflow): add tag-and-release command for #20`
2. `feat(workflow): enhance create-pr with version bumping for #20`
3. `docs(changelog): update for #20`

## Acceptance Criteria

All from issue:
- [x] /tag-and-release validates main branch & clean state
- [x] Uses make version for current version
- [x] Confirms version consecutive to existing tags
- [x] Validates CHANGELOG.md format
- [x] Creates tag and GitHub release
- [x] /create-pr analyzes git history
- [x] Suggests semver-compliant version bump
- [x] Executes make bump-* commands
- [x] Includes version bump in PR workflow
