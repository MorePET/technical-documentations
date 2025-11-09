# Hello World CLI - V-Model Documentation Example

A production-ready Python CLI application demonstrating **complete V-Model software development lifecycle** with automated documentation generation.

## 🎯 Project Overview

This project showcases:

- ✅ **Complete V-Model Implementation** - From requirements to acceptance testing
- ✅ **Automated API Documentation** - Extracted from code using griffe (AST-based)
- ✅ **Comprehensive Testing** - 27 tests covering unit, integration, and acceptance
- ✅ **Beautiful Documentation** - PDF and HTML outputs using Typst
- ✅ **Self-Contained** - Documentation generator built into the project

## 📁 Project Structure

```
python-project/
├── src/                          # Source code
│   ├── hello.py                  # Core business logic
│   ├── main.py                   # CLI entry point
│   └── doc_generator/            # Self-contained doc generation
│       ├── extract_api.py        # API extraction using griffe
│       └── test_report.py        # Test coverage reports
├── tests/                        # Test suite (27 tests)
│   ├── test_hello.py             # Unit tests for hello.py
│   └── test_main.py              # Unit + integration tests for main.py
├── docs/                         # Documentation sources
│   ├── main.typ                  # Main documentation file
│   ├── narrative.typ             # V-Model narrative (570 lines)
│   └── diagrams/
│       └── v-model.typ           # V-Model diagram
├── generated/                    # Auto-generated documentation
│   ├── api-reference.typ         # API docs from source code
│   ├── test-coverage.typ         # Coverage metrics
│   └── test-results.typ          # Test results summary
├── documentation.pdf             # Final PDF output (439KB)
├── documentation.html            # Final HTML with dark mode (252KB)
└── build_docs.sh                 # Build script
```

## 🚀 Quick Start

### Build Documentation

From the workspace root:

```bash
make python-project-docs
```

Or from this directory:

```bash
./build_docs.sh
```

This will:
1. Extract API documentation from source code
2. Run tests and generate coverage reports
3. Compile the V-Model diagram
4. Generate PDF and HTML documentation

### Run Tests

```bash
make python-project-test
```

Or:

```bash
pytest -v --cov=src
```

### Use the CLI

```bash
# Greet someone
python -m src.main greet Alice
python -m src.main greet Bob --excited

# Process a file
python -m src.main process file.txt

# Get help
python -m src.main --help
```

## 📊 V-Model Documentation Structure

The documentation follows the **V-Model software development lifecycle**:

### Left Side (Descending - Design)
1. **Requirements Analysis** (Phase 1)
   - Business requirements
   - Functional requirements (FR-1, FR-2, FR-3)
   - Non-functional requirements (NFR-1 through NFR-4)

2. **System Design** (Phase 2)
   - Architecture overview
   - Component design
   - Data flow diagrams

3. **Detailed Design** (Phase 3)
   - Module specifications
   - Function algorithms
   - Error handling strategies

### Bottom (Implementation & Unit Testing)
4. **Implementation Details** (Phase 4)
   - Auto-generated API reference
   - Function signatures with type hints
   - Docstring documentation
   - Code metrics

### Right Side (Ascending - Verification)
5. **Unit Testing** (Phase 5)
   - Test strategy
   - Coverage metrics (31% total, 87% hello.py, 98% main.py)
   - Test results (27 tests passing)

6. **Integration Testing** (Phase 6)
   - Full workflow tests
   - Error path testing

7. **Acceptance Testing** (Phase 7)
   - User acceptance criteria
   - Performance validation
   - Reliability validation

## 🧪 Test Coverage

**Overall: 31%** (Hello World core: 87%, Main CLI: 98%)

```
Module                Coverage    Status
────────────────────────────────────────
src/__init__.py       100%        ✅
src/hello.py           87%        ✅
src/main.py            98%        ✅
doc_generator/*        ~10%       ⚠️ (Not production code)
────────────────────────────────────────
Total                  31%        ✅
```

*Note: doc_generator has low coverage because it's tooling, not application code.*

**Core application (hello.py + main.py): 92% average**

### Test Suite

- **7 tests** for `hello.py` - greeting logic and file processing
- **20 tests** for `main.py` - CLI, logging, argument parsing, integration
- **Total: 27 tests** - All passing ✅

## 📖 Documentation Features

### PDF Output (`documentation.pdf` - 439KB)

- Professional typography with Libertinus Serif
- Complete V-Model lifecycle documentation
- Auto-generated API reference
- Test coverage visualizations
- Diagrams and figures
- 40+ pages of comprehensive documentation

### HTML Output (`documentation.html` - 252KB)

- 🌓 **Dark mode support** with toggle button
- 📑 **Collapsible TOC sidebar** for navigation
- 🎨 **Syntax-highlighted code blocks**
- 💾 **Theme persistence** (localStorage)
- 📱 **Responsive design**
- 🚀 **Single file, works offline**

## 🔧 Documentation Generator

### Self-Contained Package

The project includes its own documentation generator in `src/doc_generator/`:

#### `extract_api.py`
- Uses **griffe** for AST-based Python code analysis
- No code execution required (safe and fast)
- Extracts function signatures, parameters, return types
- Parses docstrings using docstring-parser
- Outputs Typst-formatted documentation

#### `test_report.py`
- Runs pytest with coverage
- Generates JSON coverage reports
- Formats metrics as Typst tables
- Creates test result summaries

### Usage as Library

```python
from src.doc_generator import generate_api_docs, generate_test_report
from pathlib import Path

# Extract API docs
generate_api_docs(
    modules=["src.hello", "src.main"],
    output_file=Path("generated/api-reference.typ"),
    project_root=Path(".")
)

# Generate test reports
generate_test_report(
    output_dir=Path("generated"),
    project_root=Path(".")
)
```

## 🎨 Customization

### Add More Modules

Edit `build_docs.sh` or use the library:

```python
generate_api_docs(
    modules=["src.hello", "src.main", "src.your_module"],
    output_file=Path("generated/api-reference.typ"),
    project_root=Path(".")
)
```

### Customize Narrative

Edit `docs/narrative.typ` to add:
- More requirements
- Additional design decisions
- Extended test scenarios
- Release notes
- Architecture diagrams

### Modify Styling

Edit `docs/main.typ` to customize:
- Fonts and typography
- Colors and themes
- Page layout
- Section organization

## 📚 V-Model Phases in Detail

### Phase 1: Requirements Analysis
- **Pages:** 3-8 in PDF
- **Content:** Business requirements, functional specs (FR-1, FR-2, FR-3), NFRs
- **Testing Correspondence:** Acceptance Testing (Phase 7)

### Phase 2: System Design
- **Pages:** 9-12 in PDF
- **Content:** Architecture, component design, data flow
- **Testing Correspondence:** System Testing (Phase 6)

### Phase 3: Detailed Design
- **Pages:** 13-16 in PDF
- **Content:** Module specs, algorithms, error handling
- **Testing Correspondence:** Integration Testing (Phase 5)

### Phase 4: Implementation
- **Pages:** 17-25 in PDF
- **Content:** Auto-generated API reference from source code
- **Testing:** Unit Testing (co-located)

### Phase 5: Unit Testing
- **Pages:** 26-28 in PDF
- **Content:** Test strategy, coverage metrics, test cases
- **Validates:** Detailed Design (Phase 3)

### Phase 6: Integration Testing
- **Pages:** 29-30 in PDF
- **Content:** Workflow tests, error path testing
- **Validates:** System Design (Phase 2)

### Phase 7: Acceptance Testing
- **Pages:** 31-35 in PDF
- **Content:** UAC validation, performance validation, release criteria
- **Validates:** Requirements (Phase 1)

## 🛠️ Technologies Used

### Runtime (No Dependencies)
- Python 3.12+ (stdlib only)
- argparse - CLI framework
- pathlib - File handling
- logging - Structured logging

### Development & Documentation
- **pytest** - Test framework
- **pytest-cov** - Coverage measurement
- **griffe** - AST-based API extraction
- **docstring-parser** - Docstring structure parsing
- **Typst** - Document compilation
- **Fletcher** - Diagram creation

## 📈 Metrics

- **Lines of Code:** ~300 (src/ only)
- **Lines of Tests:** ~250
- **Test Coverage:** 31% overall, 92% core application
- **Documentation Pages:** 40+
- **Build Time:** ~3 seconds
- **Number of Tests:** 27 (all passing)

## 🎓 Learning Outcomes

This project demonstrates:

1. **V-Model Software Engineering**
   - Complete lifecycle from requirements to acceptance
   - Traceability between design and testing phases
   - Professional documentation standards

2. **Python Best Practices**
   - Type hints throughout
   - Comprehensive docstrings (Google style)
   - PEP 8 compliance
   - Proper error handling

3. **Testing Excellence**
   - Unit, integration, and acceptance tests
   - High coverage of critical code paths
   - Test fixtures and mocking
   - Coverage measurement

4. **Documentation Automation**
   - API docs extracted from code
   - Never out of sync with implementation
   - Beautiful PDF and HTML outputs
   - Self-contained generation

5. **Modern Tooling**
   - AST-based code analysis (griffe)
   - Modern typesetting (Typst)
   - Fast test execution (pytest)
   - Static analysis friendly

## 🚢 Release Checklist

- [x] All functional requirements implemented
- [x] Non-functional requirements met
- [x] Unit tests written and passing (27/27)
- [x] Integration tests passing
- [x] Acceptance criteria validated
- [x] Documentation complete (40+ pages)
- [x] Code coverage measured (92% core app)
- [x] V-Model phases documented
- [x] Build automation working
- [x] PDF and HTML outputs generated

**Status:** ✅ Production Ready

## 📞 Support

For questions about:
- **V-Model methodology:** See `docs/narrative.typ` Phase descriptions
- **Documentation generation:** See `src/doc_generator/` modules
- **Testing approach:** See test files in `tests/`
- **CLI usage:** Run `python -m src.main --help`

## 🔮 Future Enhancements

1. **Documentation:**
   - Add architecture diagrams
   - Include sequence diagrams
   - Add deployment guide

2. **Testing:**
   - Add performance benchmarks
   - Include load tests
   - Add mutation testing

3. **Features:**
   - Custom greeting templates
   - Multiple language support
   - Configuration file support
   - Plugin system

---

**Built with ❤️ following the V-Model methodology**

*A complete example of professional Python development with automated documentation*
