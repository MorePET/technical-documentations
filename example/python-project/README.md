# Hello World CLI - Implementation Package

A production-ready Python CLI application demonstrating **V-Model software development lifecycle** with automated documentation generation.

## 🎯 Overview

This package implements a simple yet complete CLI application that demonstrates best practices in Python development, including TDD, comprehensive testing, and automated API documentation.

## 📁 Structure

```text
python-project/
├── src/                          # Source code
│   ├── hello.py                  # Core business logic
│   ├── main.py                   # CLI entry point
│   └── doc_generator/            # Documentation generation tools
│       ├── extract_api.py        # API extraction using griffe
│       └── test_report.py        # Test coverage reports
├── tests/                        # Test suite (27 tests)
│   ├── test_hello.py             # Unit tests
│   └── test_main.py              # Unit + integration tests
├── docs/                         # Documentation sources
│   ├── main.typ                  # V-Model documentation
│   └── diagrams/
│       └── v-model.typ           # V-Model diagram source
├── build/                        # All build outputs
│   ├── generated/                # Auto-generated documentation
│   │   ├── api-reference.typ    # API docs from source code
│   │   ├── test-coverage.typ    # Coverage metrics
│   │   └── test-results.typ     # Test results summary
│   └── diagrams/                 # Compiled diagrams
│       └── v-model.svg
└── build_docs.sh                 # Documentation build script
```

## 🚀 Usage

### Run the CLI

```bash
# Greet someone
python -m src.main greet Alice
python -m src.main greet Bob --excited

# Process a file
python -m src.main process file.txt

# Get help
python -m src.main --help
```

### Run Tests

```bash
pytest -v --cov=src
```

### Generate Documentation Artifacts

```bash
# Extract API documentation
python -m src.doc_generator.extract_api

# Generate test reports
python -m src.doc_generator.test_report
```

## 📖 Documentation

This package's documentation is included in the main example documentation at `example/docs/main.typ`.

The V-Model documentation in `docs/main.typ` provides detailed coverage of:

- Requirements Analysis (Phase 1)
- System Design (Phase 2)
- Detailed Design (Phase 3)
- Implementation Details (Phase 4) - with auto-generated API reference
- Unit Testing (Phase 5) - with coverage metrics
- Integration Testing (Phase 6)
- Acceptance Testing (Phase 7)

To view the complete product documentation, build from the workspace root:

```bash
make example
```

## 🧪 Test Coverage

**Core application: 92% average** (hello.py: 87%, main.py: 98%)

The package includes 27 tests covering:
- ✅ Unit tests for greeting logic
- ✅ Unit tests for file processing
- ✅ CLI argument parsing
- ✅ Logging configuration
- ✅ Integration tests for full workflows
- ✅ Error handling paths

## 🔧 Documentation Generator

The `doc_generator` package provides reusable tools for extracting API documentation and test reports:

### Extract API Documentation

```python
from src.doc_generator.extract_api import generate_api_docs
from pathlib import Path

generate_api_docs(
    modules=["src.hello", "src.main"],
    output_file=Path("build/generated/api-reference.typ"),
    project_root=Path(".")
)
```

### Generate Test Reports

```python
from src.doc_generator.test_report import generate_test_report
from pathlib import Path

generate_test_report(
    output_dir=Path("build/generated"),
    project_root=Path(".")
)
```

## 🛠️ Technologies

**Runtime (No Dependencies):**
- Python 3.12+ (stdlib only)

**Development:**
- pytest, pytest-cov - Testing and coverage
- griffe - AST-based API extraction
- docstring-parser - Docstring parsing

**Documentation:**
- Typst - Document compilation
- Fletcher - Diagram creation

## 📈 Implementation Highlights

- **Type Hints:** 100% of functions have complete type annotations
- **Docstrings:** Google-style docstrings throughout
- **PEP 8:** Enforced with Ruff
- **No Runtime Dependencies:** Uses Python stdlib only
- **Logging:** Comprehensive logging at all levels
- **Error Handling:** Graceful failure with clear messages

## 🎓 V-Model Implementation

This package demonstrates complete V-Model methodology:

**Left Side (Descending - Design):**
1. Requirements Analysis → Functional & non-functional requirements
2. System Design → Architecture and component design
3. Detailed Design → Module specifications and algorithms

**Bottom (Implementation):**
4. Implementation → Source code with API documentation

**Right Side (Ascending - Verification):**
5. Unit Testing → Test strategy and coverage
6. Integration Testing → Workflow and error path tests
7. Acceptance Testing → UAC validation and performance testing

Each design phase on the left has a corresponding testing phase on the right, ensuring complete traceability from requirements to validation.

## 📚 Learn More

- For complete product documentation, see `example/docs/main.typ`
- For build system details, see `/workspace/docs/BUILD_SYSTEM.md`
- For API examples, review the generated `build/generated/api-reference.typ`

---

**Part of the example documentation suite demonstrating professional Python development practices**
