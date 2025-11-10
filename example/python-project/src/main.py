"""Main entry point for the application."""

import argparse
import logging
import sys
from pathlib import Path

from . import __version__
from .hello import greet, process_file


def setup_logging(verbose: bool = False) -> None:
    """Configure logging for the application.

    Args:
        verbose: Enable debug-level logging
    """
    level = logging.DEBUG if verbose else logging.INFO
    logging.basicConfig(
        level=level,
        format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )


def parse_args() -> argparse.Namespace:
    """Parse command line arguments.

    Returns:
        Parsed arguments
    """
    parser = argparse.ArgumentParser(
        description="Example application demonstrating best practices",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    parser.add_argument(
        "--version",
        action="version",
        version=f"%(prog)s {__version__}",
    )

    parser.add_argument(
        "-v",
        "--verbose",
        action="store_true",
        help="Enable verbose logging",
    )

    subparsers = parser.add_subparsers(dest="command", help="Available commands")

    # Greet command
    greet_parser = subparsers.add_parser("greet", help="Generate a greeting")
    greet_parser.add_argument("name", help="Name to greet")
    greet_parser.add_argument(
        "-e",
        "--excited",
        action="store_true",
        help="Add excitement to the greeting",
    )

    # Process command
    process_parser = subparsers.add_parser("process", help="Process a file")
    process_parser.add_argument(
        "file",
        type=Path,
        help="File to process",
    )

    return parser.parse_args()


def main() -> int:
    """Main application entry point.

    Returns:
        Exit code (0 for success, non-zero for failure)
    """
    args = parse_args()
    setup_logging(args.verbose)

    logger = logging.getLogger(__name__)
    logger.info("Application starting")

    try:
        if args.command == "greet":
            result = greet(args.name, args.excited)
            print(result)
            return 0

        elif args.command == "process":
            result = process_file(args.file)
            if result is not None:
                print(f"File contents:\n{result}")
                return 0
            else:
                print("Failed to process file", file=sys.stderr)
                return 1

        else:
            print("No command specified. Use --help for usage information.")
            return 1

    except Exception as e:
        logger.exception(f"Unexpected error: {e}")
        return 1
    finally:
        logger.info("Application finished")


if __name__ == "__main__":
    sys.exit(main())
