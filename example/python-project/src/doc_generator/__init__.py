"""Documentation generator package for extracting API docs and test reports."""

__version__ = "1.0.0"

from .extract_api import generate_api_docs
from .test_report import generate_test_report

__all__ = ["generate_api_docs", "generate_test_report"]
