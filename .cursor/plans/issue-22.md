# Issue #22: Fix build system project directory mismatch

## Problem Statement

The build system has a structural inconsistency where the project name (`technical-documentation`) doesn't match the actual source directory (`docs/`), causing build failures when compiling diagrams.

## Analysis

### Current State

- **Makefile line 8**: `PROJECT ?= technical-documentation`
- **Makefile line 15**: `TECH_DOC_SRC = docs/main.typ` (source is in `docs/`)
- **build-diagrams.py lines 211-212**: Expects project directory at `/workspace/{PROJECT}/`
- **Actual structure**:
  - ✅ `/workspace/docs/` - Real documentation source
  - ✅ `/workspace/docs/diagrams/` - Real diagrams
  - ❌ `/workspace/technical-documentation/` - Expected but doesn't exist
  - ❌ `/workspace/technical-documentation/build/` - Orphaned directory

### Error Manifestation

When running `make`, the build fails at:

```text
📊 Compiling diagrams for technical-documentation...
Building diagrams for project: technical-documentation
Error: project directory not found at /workspace/technical-documentation
```

### Required Changes

The `build-diagrams.py` script expects:

```python
project_dir = project_root / args.project  # /workspace/technical-documentation
diagrams_dir = project_dir / "diagrams"    # /workspace/technical-documentation/diagrams
```

But the actual structure is:
- Source: `/workspace/docs/main.typ`
- Diagrams: `/workspace/docs/diagrams/`

## Implementation Options

### Option 1: Change Project Name to Match Directory (Recommended)

**Description:** Update the Makefile to use "docs" as the project name instead of "technical-documentation"

**Pros:**
- Minimal changes (only 2 lines in Makefile)
- Aligns project name with actual directory structure
- No impact on output file names or locations
- Low risk of breaking existing workflows

**Cons:**
- Project name becomes less descriptive ("docs" vs "technical-documentation")

**Estimated Complexity:** Low

**Files to modify:**
- `Makefile` (lines 8, 46)

### Option 2: Rename docs/ to technical-documentation/

**Description:** Rename the `docs/` directory to `technical-documentation/` to match the project name

**Pros:**
- More descriptive directory name
- Project name remains descriptive

**Cons:**
- Requires updating multiple file paths (TECH_DOC_SRC, README references, etc.)
- May break existing documentation or user expectations
- Higher risk of missing references
- More disruptive change

**Estimated Complexity:** Medium

**Files to modify:**
- `Makefile` (line 15)
- Any documentation referencing `docs/`
- Git history shows `docs/` as established directory

### Option 3: Add Project Name Mapping to build-diagrams.py

**Description:** Modify `build-diagrams.py` to support a mapping between project names and actual directories

**Pros:**
- Keeps project name descriptive
- Keeps directory name conventional (`docs/`)
- Allows for flexible mappings

**Cons:**
- Adds complexity to the build system
- Non-obvious mapping for future maintainers
- Other scripts might have same issue
- Requires more code changes

**Estimated Complexity:** Medium

**Files to modify:**
- `scripts/build-diagrams.py`
- Potentially other build scripts

## Recommended Approach

**Choice:** Option 1 - Change Project Name to Match Directory

**Rationale:**
- Simplest solution (2-line change)
- Lowest risk
- Aligns with principle: "Make the code match reality, not reality match the code"
- The project name is primarily an internal build variable, not user-facing
- Output files still use descriptive name: `build/technical-documentation.pdf`
- The `docs/` directory is a standard convention in many projects

## Implementation Steps

1. ✅ **Update Makefile line 8** - Change default project name

   ```makefile
   # From:
   PROJECT ?= technical-documentation
   # To:
   PROJECT ?= docs
   ```

2. ✅ **Update Makefile line 46** - Update technical-documentation target

   ```makefile
   # From:
   @$(MAKE) build-project SRC=$(TECH_DOC_SRC) OUT=$(TECH_DOC_OUT) PROJECT=technical-documentation
   # To:
   @$(MAKE) build-project SRC=$(TECH_DOC_SRC) OUT=$(TECH_DOC_OUT) PROJECT=docs
   ```

3. **Test the build** - Verify diagrams compile correctly

   ```bash
   make clean
   make
   ```

4. **Verify outputs** - Check that all outputs are created correctly
   - `build/technical-documentation.pdf`
   - `build/technical-documentation.html`
   - `build/diagrams/*.svg` (compiled from `docs/diagrams/`)

5. **Update CHANGELOG.md** - Document the fix

6. **Commit changes** - Following conventional commit format

## Testing Strategy

### Pre-test Verification

- [ ] Check that `docs/diagrams/` directory exists
- [ ] Verify `.typ` diagram files are in `docs/diagrams/`

### Build Tests

- [ ] `make clean` - Clean all artifacts
- [ ] `make colors` - Generate color files
- [ ] `make diagrams PROJECT=docs` - Compile diagrams explicitly
- [ ] `make` - Full build (should now succeed)

### Output Verification

- [ ] `build/technical-documentation.pdf` exists
- [ ] `build/technical-documentation.html` exists
- [ ] `docs/build/diagrams/` contains compiled SVGs
- [ ] Both light and dark theme SVGs are generated

### Manual Verification

- [ ] Open PDF - diagrams are displayed correctly
- [ ] Open HTML in browser - diagrams render with theme switching

## Acceptance Criteria

- [x] Makefile updated with correct project name
- [ ] Build completes without "project directory not found" error
- [ ] Diagrams compile from `docs/diagrams/` directory
- [ ] Output files are created in correct locations
- [ ] Both light and dark theme diagram SVGs are generated
- [ ] PDF and HTML outputs display diagrams correctly
- [ ] CHANGELOG.md updated with fix
- [ ] Changes committed with proper conventional commit message

## Related Issues/PRs

- Fixes #22

## Follow-up Actions (Not in this PR)

- Consider removing orphaned `/workspace/technical-documentation/` directory
- Update documentation if PROJECT variable is referenced elsewhere
- Consider adding validation to prevent similar mismatches
