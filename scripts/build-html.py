#!/usr/bin/env python3
"""
DEPRECATED: This script has been superseded by build-html-bootstrap.py

This script now redirects to build-html-bootstrap.py which uses Bootstrap styling.
The old custom CSS approach has been retired in favor of Bootstrap.

For direct use, call build-html-bootstrap.py instead:
    python3 scripts/build-html-bootstrap.py input.typ output.html

This redirect wrapper is maintained for backward compatibility.
"""

import subprocess
import sys
from pathlib import Path


def main():
    """Main entry point - redirects to build-html-bootstrap.py."""
    print("=" * 70)
    print("⚠️  DEPRECATION NOTICE")
    print("=" * 70)
    print("This script (build-html.py) is deprecated.")
    print("Redirecting to build-html-bootstrap.py (Bootstrap styling)...")
    print("=" * 70)
    print()

    # Find the bootstrap build script
    script_dir = Path(__file__).parent
    bootstrap_script = script_dir / "build-html-bootstrap.py"

    if not bootstrap_script.exists():
        print(f"Error: Bootstrap build script not found: {bootstrap_script}")
        sys.exit(1)

    # Pass all arguments to the Bootstrap builder
    args = ["python3", str(bootstrap_script)] + sys.argv[1:]

    try:
        result = subprocess.run(args, check=True)
        return result.returncode
    except subprocess.CalledProcessError as e:
        return e.returncode
    except KeyboardInterrupt:
        print("\n\nBuild interrupted by user.")
        return 130


if __name__ == "__main__":
    sys.exit(main())
