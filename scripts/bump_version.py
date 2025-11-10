#!/usr/bin/env python3
"""Bump version in pyproject.toml and optionally update CHANGELOG.md."""

import argparse
import re
import sys
from datetime import date
from pathlib import Path

try:
    import tomllib  # Python 3.11+
except ImportError:
    import tomli as tomllib  # Fallback for Python 3.10


def get_version(pyproject_path: Path) -> str:
    """Extract current version from pyproject.toml."""
    with pyproject_path.open("rb") as f:
        data = tomllib.load(f)
    return data["project"]["version"]


def parse_version(version: str) -> tuple[int, int, int]:
    """Parse semantic version string."""
    match = re.match(r"^(\d+)\.(\d+)\.(\d+)$", version)
    if not match:
        raise ValueError(f"Invalid version format: {version}")
    return tuple(map(int, match.groups()))


def bump_version(version: str, bump_type: str) -> str:
    """Bump version by type (major, minor, patch)."""
    major, minor, patch = parse_version(version)

    if bump_type == "major":
        return f"{major + 1}.0.0"
    elif bump_type == "minor":
        return f"{major}.{minor + 1}.0"
    elif bump_type == "patch":
        return f"{major}.{minor}.{patch + 1}"
    else:
        raise ValueError(f"Invalid bump type: {bump_type}")


def update_pyproject(pyproject_path: Path, new_version: str) -> None:
    """Update version in pyproject.toml."""
    content = pyproject_path.read_text()

    # Replace version line
    updated = re.sub(
        r'^version = "[^"]+"',
        f'version = "{new_version}"',
        content,
        flags=re.MULTILINE,
    )

    pyproject_path.write_text(updated)
    print(f'✅ Updated {pyproject_path}: version = "{new_version}"')


def update_changelog(
    changelog_path: Path, new_version: str, current_version: str
) -> None:
    """Add new version entry to CHANGELOG.md."""
    if not changelog_path.exists():
        print(f"⚠️  {changelog_path} not found, skipping")
        return

    content = changelog_path.read_text()
    today = date.today().isoformat()

    # Find the insertion point (after the header, before first version)
    header_end = content.find("\n## [")
    if header_end == -1:
        print(f"⚠️  Could not find version entries in {changelog_path}")
        return

    new_entry = f"\n## [{new_version}] - {today}\n\n### Changed\n\n- Version bump from {current_version}\n"

    updated = content[:header_end] + new_entry + content[header_end:]
    changelog_path.write_text(updated)
    print(f"✅ Updated {changelog_path}: Added [{new_version}] entry")


def main() -> int:
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="Bump version in pyproject.toml and optionally update CHANGELOG.md"
    )
    parser.add_argument(
        "bump_type",
        choices=["major", "minor", "patch"],
        help="Type of version bump",
    )
    parser.add_argument(
        "--pyproject",
        type=Path,
        default=Path("pyproject.toml"),
        help="Path to pyproject.toml (default: pyproject.toml)",
    )
    parser.add_argument(
        "--changelog",
        type=Path,
        default=Path("CHANGELOG.md"),
        help="Path to CHANGELOG.md (default: CHANGELOG.md)",
    )
    parser.add_argument(
        "--no-changelog",
        action="store_true",
        help="Don't update CHANGELOG.md",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be done without making changes",
    )

    args = parser.parse_args()

    try:
        # Get current version
        current = get_version(args.pyproject)
        new = bump_version(current, args.bump_type)

        print(f"Current version: {current}")
        print(f"New version:     {new}")
        print()

        if args.dry_run:
            print("🔍 DRY RUN - No changes made")
            return 0

        # Update pyproject.toml
        update_pyproject(args.pyproject, new)

        # Update CHANGELOG.md
        if not args.no_changelog:
            update_changelog(args.changelog, new, current)

        print()
        print(f"✅ Version bumped: {current} → {new}")
        print()
        print("Next steps:")
        print("  1. Review changes: git diff")
        print("  2. Update CHANGELOG.md with actual changes")
        print(f"  3. Commit: git commit -am 'chore(release): bump version to {new}'")
        print(f"  4. Tag: git tag -a {new} -m 'Release {new}'")
        print("  5. Push: git push && git push --tags")

        return 0

    except Exception as e:
        print(f"❌ Error: {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
