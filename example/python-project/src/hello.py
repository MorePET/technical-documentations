"""Example module demonstrating best practices."""

import logging
from pathlib import Path

logger = logging.getLogger(__name__)


def greet(name: str, excited: bool = False) -> str:
    """Generate a greeting message.

    Args:
        name: Name of the person to greet
        excited: Whether to add excitement to the greeting

    Returns:
        A formatted greeting message

    Raises:
        ValueError: If name is empty
    """
    if not name or not name.strip():
        raise ValueError("Name cannot be empty")

    message = f"Hello, {name}!"
    if excited:
        message += " 🎉"

    logger.debug(f"Generated greeting: {message}")
    return message


def process_file(filepath: Path) -> str | None:
    """Process a file and return its contents.

    Args:
        filepath: Path to the file to process

    Returns:
        File contents if successful, None otherwise
    """
    try:
        if not filepath.exists():
            logger.error(f"File not found: {filepath}")
            return None

        with filepath.open("r") as f:
            content = f.read()
            logger.info(f"Successfully read {len(content)} bytes from {filepath}")
            return content
    except Exception as e:
        logger.exception(f"Error processing file {filepath}: {e}")
        return None
