#!/usr/bin/env python3
"""Extract version from pyproject.toml."""

import sys
from pathlib import Path

try:
    import tomllib  # Python 3.11+
except ImportError:
    import tomli as tomllib  # Fallback for Python 3.10


def get_version(pyproject_path: Path = Path("pyproject.toml")) -> str:
    """Extract version from pyproject.toml."""
    with pyproject_path.open("rb") as f:
        data = tomllib.load(f)
    return data["project"]["version"]


if __name__ == "__main__":
    try:
        version = get_version()
        print(version)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
