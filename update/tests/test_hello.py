"""Tests for the hello module."""

import logging
from pathlib import Path

import pytest

from src.hello import greet, process_file


@pytest.fixture
def sample_file(tmp_path: Path) -> Path:
    """Create a sample file for testing.

    Args:
        tmp_path: Pytest fixture providing temporary directory

    Returns:
        Path to the created test file
    """
    file_path = tmp_path / "test.txt"
    file_path.write_text("Hello, World!")
    return file_path


class TestGreet:
    """Tests for the greet function."""

    def test_greet_simple(self) -> None:
        """Test basic greeting."""
        result = greet("Alice")
        assert result == "Hello, Alice!"

    def test_greet_excited(self) -> None:
        """Test excited greeting."""
        result = greet("Bob", excited=True)
        assert result == "Hello, Bob! 🎉"

    def test_greet_empty_name(self) -> None:
        """Test that empty name raises ValueError."""
        with pytest.raises(ValueError, match="Name cannot be empty"):
            greet("")

    def test_greet_whitespace_name(self) -> None:
        """Test that whitespace-only name raises ValueError."""
        with pytest.raises(ValueError, match="Name cannot be empty"):
            greet("   ")


class TestProcessFile:
    """Tests for the process_file function."""

    def test_process_existing_file(self, sample_file: Path) -> None:
        """Test processing an existing file."""
        result = process_file(sample_file)
        assert result == "Hello, World!"

    def test_process_nonexistent_file(self, tmp_path: Path) -> None:
        """Test processing a nonexistent file."""
        nonexistent = tmp_path / "does_not_exist.txt"
        result = process_file(nonexistent)
        assert result is None

    def test_process_file_logging(
        self,
        sample_file: Path,
        caplog: pytest.LogCaptureFixture,
    ) -> None:
        """Test that file processing logs appropriately."""
        with caplog.at_level(logging.INFO):
            process_file(sample_file)

        assert "Successfully read" in caplog.text
        assert str(sample_file) in caplog.text
