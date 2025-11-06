# Python Development Guidelines

## Package Management with uv

### On Host Machine

Always use `uv` with virtual environments:

```bash
# Create virtual environment
uv venv

# Activate virtual environment
source .venv/bin/activate  # Linux/macOS
.venv\Scripts\activate     # Windows

# Install dependencies
uv pip install -r requirements.txt

# Add new package
uv pip install package-name
uv pip freeze > requirements.txt
```

### Inside Dev Containers

Use `uv` directly without virtual environments:

```bash
# Install dependencies
uv pip install --system -r requirements.txt

# Run Python with uv
uv run python script.py

# Run tools with uv
uv run ruff check .
uv run ruff format .
uv run pytest
```

**Why different approaches?**
- **Host**: Virtual environments isolate project dependencies from system Python
- **Container**: Already isolated, so `--system` install is safe and simpler

### Project Dependencies

Always maintain `requirements.txt`:

```txt
# requirements.txt
package-name>=1.0.0,<2.0.0
another-package==2.3.4
```

For development dependencies, use `requirements-dev.txt`:

```txt
# requirements-dev.txt
-r requirements.txt
pytest>=8.0.0
ruff>=0.1.0
pre-commit>=3.0.0
```

## Code Style: Ruff

**ALWAYS comply with ALL Ruff rules.** Ruff is our single source of truth for Python code quality.

### Running Ruff

```bash
# Check for issues
uv run ruff check .

# Auto-fix issues
uv run ruff check --fix .

# Format code
uv run ruff format .
```

### Pre-commit Integration

Ruff runs automatically on `git commit` via pre-commit hooks:

```yaml
- repo: local
  hooks:
    - id: ruff
      name: ruff
      entry: uv run ruff check --fix
      language: system
      types: [python]
      require_serial: true
    - id: ruff-format
      name: ruff-format
      entry: uv run ruff format
      language: system
      types: [python]
      require_serial: true
```

### Ruff Configuration

See `pyproject.toml` or `ruff.toml` for project-specific rules.

**Key principles:**
- ✅ Follow all Ruff defaults
- ✅ Fix all Ruff errors before committing
- ✅ Use `# noqa: RULE` ONLY when absolutely necessary with explanation
- ✅ Never disable Ruff rules globally without team discussion

### Common Ruff Rules

**Import ordering (I):**
```python
# Standard library
import os
import sys

# Third-party
import requests
from django.conf import settings

# Local
from myapp.models import User
```

**Line length (E501):**
- Max 88 characters (Ruff default)
- Let Ruff format handle it

**Unused imports/variables (F401, F841):**
```python
# ❌ Bad
import os  # unused
x = 5  # unused variable

# ✅ Good
import os
x = 5
print(x)
```

**Type annotations:**
```python
# ✅ Prefer annotated code
def process_data(items: list[str], count: int) -> dict[str, int]:
    return {"total": count}
```

## Docstrings: Google Style

**ALWAYS use Google-style docstrings** for all modules, classes, and functions.

### Module Docstring

```python
"""Brief description of module purpose.

Extended description providing more details about the module's
functionality and usage.

Example:
    Basic usage example::

        from mymodule import MyClass
        obj = MyClass()
        result = obj.process()
"""
```

### Function Docstring

```python
def fetch_user_data(user_id: int, include_posts: bool = False) -> dict[str, any]:
    """Fetch user data from the database.

    Retrieves comprehensive user information including profile details
    and optionally their recent posts.

    Args:
        user_id: The unique identifier for the user.
        include_posts: Whether to include the user's posts in the response.
            Defaults to False.

    Returns:
        A dictionary containing user data with keys:
            - id: User's unique identifier
            - name: User's full name
            - email: User's email address
            - posts: List of post objects (if include_posts is True)

    Raises:
        UserNotFoundError: If the user_id does not exist in the database.
        DatabaseError: If there's a connection issue with the database.

    Example:
        >>> user = fetch_user_data(123, include_posts=True)
        >>> print(user['name'])
        'John Doe'

    Note:
        This function requires an active database connection. Use within
        a database context manager for proper resource cleanup.
    """
```

### Class Docstring

```python
class UserManager:
    """Manages user-related operations and database interactions.

    This class provides methods for creating, updating, and deleting users,
    as well as querying user data with various filters.

    Attributes:
        db_connection: Active database connection instance.
        cache_enabled: Whether to use caching for queries.
        default_timeout: Default timeout in seconds for database operations.

    Example:
        >>> manager = UserManager(db_connection=conn)
        >>> user = manager.create_user(name="John", email="john@example.com")
        >>> manager.delete_user(user.id)

    Note:
        Always call close() or use as context manager to ensure proper
        cleanup of database resources.
    """

    def __init__(self, db_connection: Database, cache_enabled: bool = True) -> None:
        """Initialize the UserManager.

        Args:
            db_connection: Active database connection instance.
            cache_enabled: Enable query result caching. Defaults to True.

        Raises:
            ConnectionError: If the database connection is invalid.
        """
```

### Property Docstring

```python
@property
def full_name(self) -> str:
    """Get the user's full name.

    Returns:
        The concatenated first and last name.

    Example:
        >>> user.full_name
        'John Doe'
    """
    return f"{self.first_name} {self.last_name}"
```

### Docstring Requirements

**Required sections:**
- Brief summary (one line)
- Extended description (if needed)
- `Args:` for all parameters
- `Returns:` for return values
- `Raises:` for exceptions
- `Example:` for complex functions

**Optional sections:**
- `Note:` for important information
- `Warning:` for potential issues
- `See Also:` for related functions
- `Todo:` for planned improvements

## Logging

**ALWAYS add proper logging** to Python code. Use Python's `logging` module.

### Logging Setup

```python
import logging

# Module-level logger
logger = logging.getLogger(__name__)

# In main/entry point, configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('app.log'),
        logging.StreamHandler()
    ]
)
```

### Logging Levels

Use appropriate log levels:

**DEBUG** - Detailed diagnostic information:
```python
logger.debug("Processing item %d of %d", current, total)
logger.debug("Cache hit for key: %s", cache_key)
logger.debug("Query parameters: %s", params)
```

**INFO** - General informational messages:
```python
logger.info("Starting data processing")
logger.info("User %s logged in successfully", username)
logger.info("Processed %d records in %.2f seconds", count, duration)
```

**WARNING** - Something unexpected but not critical:
```python
logger.warning("API rate limit approaching: %d/%d", current, limit)
logger.warning("Configuration file not found, using defaults")
logger.warning("Deprecated function called: %s", func_name)
```

**ERROR** - Error occurred but application continues:
```python
logger.error("Failed to process record %d: %s", record_id, error)
logger.error("Database connection lost, retrying...")
logger.error("Invalid input data: %s", validation_error)
```

**CRITICAL** - Critical error, application may fail:
```python
logger.critical("Database connection failed, cannot continue")
logger.critical("Out of memory, shutting down")
logger.critical("Critical configuration missing: %s", config_key)
```

### Logging Best Practices

**DO:**
```python
# ✅ Use proper log levels
logger.info("Operation completed successfully")

# ✅ Include context and variables
logger.error("Failed to process user %s: %s", user_id, error)

# ✅ Log exceptions with traceback
try:
    risky_operation()
except Exception as e:
    logger.exception("Unexpected error in risky_operation")

# ✅ Use lazy formatting (efficient)
logger.debug("Processing %s with %s", item, config)

# ✅ Log entry/exit of important functions
logger.info("Starting batch processing of %d items", len(items))
# ... processing ...
logger.info("Batch processing completed in %.2fs", elapsed)
```

**DON'T:**
```python
# ❌ Don't use print()
print("User logged in")  # Use logger.info() instead

# ❌ Don't use string concatenation
logger.info("User " + username + " logged in")  # Use formatting

# ❌ Don't log sensitive data
logger.info("User password: %s", password)  # NEVER

# ❌ Don't log in loops without throttling
for item in huge_list:
    logger.debug("Processing %s", item)  # Too verbose

# ❌ Don't ignore exceptions silently
try:
    operation()
except Exception:
    pass  # Add logging here!
```

### Exception Logging

**Always log exceptions** with context:

```python
try:
    result = process_data(data)
except ValueError as e:
    logger.error("Invalid data format: %s", e)
    raise
except DatabaseError as e:
    logger.exception("Database error while processing data")
    # exception() automatically includes traceback
    raise
except Exception as e:
    logger.critical("Unexpected error in process_data: %s", e, exc_info=True)
    raise
```

### Structured Logging

For production applications, consider structured logging:

```python
import logging
import json

class JSONFormatter(logging.Formatter):
    def format(self, record):
        log_data = {
            'timestamp': self.formatTime(record),
            'level': record.levelname,
            'logger': record.name,
            'message': record.getMessage(),
            'module': record.module,
            'function': record.funcName,
        }
        if record.exc_info:
            log_data['exception'] = self.formatException(record.exc_info)
        return json.dumps(log_data)

handler = logging.StreamHandler()
handler.setFormatter(JSONFormatter())
logger.addHandler(handler)
```

### Logging Configuration

**Per-module loggers:**
```python
# myapp/users.py
logger = logging.getLogger(__name__)  # Gets 'myapp.users'

# myapp/api.py
logger = logging.getLogger(__name__)  # Gets 'myapp.api'
```

**Hierarchical control:**
```python
# Set different levels for different modules
logging.getLogger('myapp.users').setLevel(logging.DEBUG)
logging.getLogger('myapp.api').setLevel(logging.INFO)
logging.getLogger('third_party').setLevel(logging.WARNING)
```

## Type Hints

**Always use type hints** for function signatures:

```python
from typing import Optional, Union, List, Dict, Any

def process_items(
    items: list[str],
    max_count: int,
    config: dict[str, any] | None = None
) -> tuple[list[str], int]:
    """Process items with optional configuration.

    Args:
        items: List of items to process.
        max_count: Maximum number of items to process.
        config: Optional configuration dictionary.

    Returns:
        Tuple of processed items and count.
    """
    if config is None:
        config = {}

    processed = items[:max_count]
    return processed, len(processed)
```

**Use modern type hints** (Python 3.10+):
```python
# ✅ Modern (preferred)
def func(items: list[str]) -> dict[str, int]:
    pass

# ❌ Old style (avoid)
from typing import List, Dict
def func(items: List[str]) -> Dict[str, int]:
    pass
```

## Testing

**Write tests** for all non-trivial code:

```python
import pytest
from mymodule import process_data

def test_process_data_success():
    """Test successful data processing."""
    result = process_data([1, 2, 3])
    assert result == [2, 4, 6]

def test_process_data_empty_list():
    """Test handling of empty input."""
    result = process_data([])
    assert result == []

def test_process_data_invalid_type():
    """Test proper error handling for invalid input."""
    with pytest.raises(TypeError):
        process_data("not a list")
```

## Code Organization

**Module structure:**
```python
"""Module docstring."""

# Standard library imports
import logging
import os
from pathlib import Path

# Third-party imports
import requests
from pydantic import BaseModel

# Local imports
from myapp.config import settings
from myapp.utils import helper_function

# Constants
MAX_RETRIES = 3
DEFAULT_TIMEOUT = 30

# Module-level logger
logger = logging.getLogger(__name__)

# Classes and functions
class MyClass:
    """Class docstring."""
    pass

def my_function():
    """Function docstring."""
    pass
```

## Error Handling

**Be explicit** about error handling:

```python
def fetch_data(url: str) -> dict[str, any]:
    """Fetch data from URL.

    Args:
        url: The URL to fetch data from.

    Returns:
        Parsed JSON response.

    Raises:
        RequestError: If the HTTP request fails.
        JSONDecodeError: If the response is not valid JSON.
    """
    try:
        response = requests.get(url, timeout=30)
        response.raise_for_status()
        return response.json()
    except requests.RequestException as e:
        logger.error("Failed to fetch data from %s: %s", url, e)
        raise RequestError(f"HTTP request failed: {e}") from e
    except json.JSONDecodeError as e:
        logger.error("Invalid JSON response from %s", url)
        raise
```

## Summary Checklist

Before committing Python code, ensure:

- [ ] All Ruff checks pass (`uv run ruff check .`)
- [ ] Code is formatted (`uv run ruff format .`)
- [ ] All functions have Google-style docstrings
- [ ] Appropriate logging added (debug/info/warning/error/critical)
- [ ] Type hints on all function signatures
- [ ] Exceptions are logged with context
- [ ] No sensitive data in logs
- [ ] Tests written for new functionality
- [ ] Using `uv` for package management
- [ ] No `print()` statements (use logging)
- [ ] Import order follows Ruff conventions
