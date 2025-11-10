"""Documentation generator package for extracting API docs and test reports.

Avoid importing submodules at package import time to prevent runpy warnings
when executing modules via `python -m src.doc_generator.<module>`.
"""

__version__ = "1.0.0"

__all__ = ["generate_api_docs", "generate_test_report"]


def generate_api_docs(*args, **kwargs):
    from .extract_api import generate_api_docs as _impl

    return _impl(*args, **kwargs)


def generate_test_report(*args, **kwargs):
    from .test_report import generate_test_report as _impl

    return _impl(*args, **kwargs)
