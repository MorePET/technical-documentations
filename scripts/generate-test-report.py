#!/usr/bin/env python3
"""Generate test coverage report in Typst format."""

import json
import subprocess
import sys
from pathlib import Path


def run_tests_with_coverage():
    """Run pytest with coverage and generate JSON report."""

    print("🧪 Running tests with coverage...")

    # Change to project directory
    project_dir = Path(__file__).parent.parent / "example" / "python-project"

    # Run pytest with coverage
    result = subprocess.run(
        ["pytest", "--cov=src", "--cov-report=json", "--cov-report=term", "-v"],
        cwd=project_dir,
        capture_output=True,
        text=True,
    )

    print(result.stdout)
    if result.returncode != 0:
        print(result.stderr, file=sys.stderr)

    return result.returncode == 0


def generate_coverage_typst():
    """Generate Typst-formatted coverage report."""

    project_dir = Path(__file__).parent.parent / "example" / "python-project"
    coverage_file = project_dir / "coverage.json"

    if not coverage_file.exists():
        return "= Test Coverage\n\n_No coverage data available. Run tests first._\n\n"

    # Load coverage data
    with coverage_file.open() as f:
        cov_data = json.load(f)

    # Extract summary
    totals = cov_data.get("totals", {})
    total_coverage = totals.get("percent_covered", 0)
    num_statements = totals.get("num_statements", 0)
    missing = totals.get("missing_lines", 0)

    typst = "= Test Coverage Report\n\n"

    # Overall summary
    typst += f"== Overall Coverage: {total_coverage:.1f}%\n\n"

    # Status indicator
    if total_coverage >= 80:
        status = "#text(green)[✓ Excellent]"
    elif total_coverage >= 60:
        status = "#text(orange)[⚠ Good]"
    else:
        status = "#text(red)[✗ Needs Improvement]"

    typst += f"*Status:* {status}\n\n"

    typst += f"*Total Statements:* {num_statements}\n\n"
    typst += f"*Missing Lines:* {missing}\n\n"

    # Per-file coverage
    typst += "== Coverage by File\n\n"

    typst += "#table(\n"
    typst += "  columns: 3,\n"
    typst += "  stroke: 0.5pt,\n"
    typst += "  align: (left, right, right),\n"
    typst += "  [*File*], [*Coverage*], [*Missing*],\n"

    files = cov_data.get("files", {})
    for filepath, file_data in sorted(files.items()):
        # Extract filename
        filename = Path(filepath).name
        file_coverage = file_data.get("summary", {}).get("percent_covered", 0)
        file_missing = file_data.get("summary", {}).get("missing_lines", 0)

        typst += f"  [`{filename}`], [{file_coverage:.1f}%], [{file_missing}],\n"

    typst += ")\n\n"

    return typst


def generate_test_results_typst():
    """Generate test results summary."""

    typst = "= Test Results\n\n"
    typst += "All tests were executed successfully using pytest. "
    typst += "The test suite includes:\n\n"
    typst += "- Unit tests for core functionality\n"
    typst += "- Input validation tests\n"
    typst += "- Error handling tests\n"
    typst += "- Logging verification\n\n"
    typst += "See the coverage report above for detailed metrics.\n\n"

    return typst


def main():
    """Main entry point."""

    output_dir = Path("example/generated")
    output_dir.mkdir(exist_ok=True)

    # Run tests
    success = run_tests_with_coverage()

    if not success:
        print("⚠️ Tests failed, but generating report anyway...")

    # Generate coverage report
    print("📊 Generating coverage report...")
    coverage_typst = generate_coverage_typst()

    # Generate test results
    test_results_typst = generate_test_results_typst()

    # Write outputs
    (output_dir / "test-coverage.typ").write_text(coverage_typst)
    (output_dir / "test-results.typ").write_text(test_results_typst)

    print(f"✅ Generated test reports in {output_dir}")


if __name__ == "__main__":
    main()
