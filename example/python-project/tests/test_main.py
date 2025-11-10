"""Comprehensive tests for the main module."""

import logging
from unittest.mock import patch

from src.main import main, parse_args, setup_logging


class TestSetupLogging:
    """Tests for logging configuration."""

    def test_setup_logging_default(self):
        """Test default logging level is INFO."""
        # Reset logger to avoid pytest interference
        logging.root.handlers = []
        setup_logging(verbose=False)
        # Check that handler was configured with INFO level
        assert (
            any(h.level == logging.INFO for h in logging.root.handlers)
            or logging.root.level <= logging.INFO
        )

    def test_setup_logging_verbose(self):
        """Test verbose mode sets DEBUG level."""
        # Reset logger to avoid pytest interference
        logging.root.handlers = []
        setup_logging(verbose=True)
        # Check that handler was configured with DEBUG level
        assert (
            any(h.level == logging.DEBUG for h in logging.root.handlers)
            or logging.root.level <= logging.DEBUG
        )


class TestParseArgs:
    """Tests for argument parsing."""

    def test_parse_args_no_command(self):
        """Test parsing with no command."""
        with patch("sys.argv", ["prog"]):
            args = parse_args()
            assert args.command is None
            assert args.verbose is False

    def test_parse_args_greet(self):
        """Test parsing greet command."""
        with patch("sys.argv", ["prog", "greet", "Alice"]):
            args = parse_args()
            assert args.command == "greet"
            assert args.name == "Alice"
            assert args.excited is False

    def test_parse_args_greet_excited(self):
        """Test parsing greet command with excited flag."""
        with patch("sys.argv", ["prog", "greet", "Bob", "--excited"]):
            args = parse_args()
            assert args.command == "greet"
            assert args.name == "Bob"
            assert args.excited is True

    def test_parse_args_greet_short_flag(self):
        """Test parsing greet command with short excited flag."""
        with patch("sys.argv", ["prog", "greet", "Charlie", "-e"]):
            args = parse_args()
            assert args.excited is True

    def test_parse_args_process(self, tmp_path):
        """Test parsing process command."""
        test_file = tmp_path / "test.txt"
        with patch("sys.argv", ["prog", "process", str(test_file)]):
            args = parse_args()
            assert args.command == "process"
            assert args.file == test_file

    def test_parse_args_verbose_flag(self):
        """Test verbose flag."""
        with patch("sys.argv", ["prog", "--verbose", "greet", "Dave"]):
            args = parse_args()
            assert args.verbose is True

    def test_parse_args_verbose_short_flag(self):
        """Test verbose short flag."""
        with patch("sys.argv", ["prog", "-v", "greet", "Eve"]):
            args = parse_args()
            assert args.verbose is True


class TestMain:
    """Tests for main function."""

    def test_main_greet_success(self, capsys):
        """Test successful greet command."""
        with patch("sys.argv", ["prog", "greet", "Alice"]):
            exit_code = main()

        assert exit_code == 0
        captured = capsys.readouterr()
        assert "Hello, Alice!" in captured.out

    def test_main_greet_excited(self, capsys):
        """Test greet command with excitement."""
        with patch("sys.argv", ["prog", "greet", "Bob", "--excited"]):
            exit_code = main()

        assert exit_code == 0
        captured = capsys.readouterr()
        assert "Hello, Bob! 🎉" in captured.out

    def test_main_greet_empty_name(self, capsys):
        """Test greet command with empty name fails."""
        with patch("sys.argv", ["prog", "greet", ""]):
            exit_code = main()

        assert exit_code == 1

    def test_main_process_existing_file(self, tmp_path, capsys):
        """Test process command with existing file."""
        test_file = tmp_path / "test.txt"
        test_file.write_text("Hello, World!")

        with patch("sys.argv", ["prog", "process", str(test_file)]):
            exit_code = main()

        assert exit_code == 0
        captured = capsys.readouterr()
        assert "Hello, World!" in captured.out

    def test_main_process_nonexistent_file(self, tmp_path, capsys):
        """Test process command with nonexistent file."""
        test_file = tmp_path / "nonexistent.txt"

        with patch("sys.argv", ["prog", "process", str(test_file)]):
            exit_code = main()

        assert exit_code == 1
        captured = capsys.readouterr()
        assert "Failed to process file" in captured.err

    def test_main_no_command(self, capsys):
        """Test main with no command."""
        with patch("sys.argv", ["prog"]):
            exit_code = main()

        assert exit_code == 1
        captured = capsys.readouterr()
        assert "No command specified" in captured.out

    def test_main_with_exception(self, capsys):
        """Test main handles unexpected exceptions."""
        with patch("sys.argv", ["prog", "greet", "Alice"]):
            with patch("src.main.greet", side_effect=RuntimeError("Unexpected error")):
                exit_code = main()

        assert exit_code == 1

    def test_main_verbose_logging(self, caplog):
        """Test main with verbose logging."""
        with patch("sys.argv", ["prog", "--verbose", "greet", "Alice"]):
            with caplog.at_level(logging.DEBUG):
                main()

        # Should have debug logs
        assert any(record.levelname == "DEBUG" for record in caplog.records)

    def test_main_application_lifecycle(self, caplog):
        """Test application starting and finishing messages."""
        with patch("sys.argv", ["prog", "greet", "Alice"]):
            with caplog.at_level(logging.INFO):
                main()

        # Check for lifecycle logs
        log_messages = [record.message for record in caplog.records]
        assert any("Application starting" in msg for msg in log_messages)
        assert any("Application finished" in msg for msg in log_messages)


class TestIntegration:
    """Integration tests."""

    def test_full_workflow_greet(self, tmp_path, capsys):
        """Test complete workflow with greet command."""
        with patch("sys.argv", ["prog", "-v", "greet", "Integration", "--excited"]):
            exit_code = main()

        assert exit_code == 0
        captured = capsys.readouterr()
        assert "Hello, Integration! 🎉" in captured.out

    def test_full_workflow_process(self, tmp_path, capsys):
        """Test complete workflow with process command."""
        # Create test file
        test_file = tmp_path / "integration.txt"
        test_content = "Integration test content"
        test_file.write_text(test_content)

        # Run process command
        with patch("sys.argv", ["prog", "process", str(test_file)]):
            exit_code = main()

        assert exit_code == 0
        captured = capsys.readouterr()
        assert test_content in captured.out
