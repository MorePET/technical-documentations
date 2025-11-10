#!/usr/bin/env python3
"""Watch Python source files and auto-rebuild documentation."""

import subprocess
import time

from watchdog.events import FileSystemEventHandler
from watchdog.observers import Observer


class DocBuilder(FileSystemEventHandler):
    def __init__(self):
        self.last_build = 0
        self.debounce_seconds = 2

    def on_modified(self, event):
        if not event.src_path.endswith(".py"):
            return

        # Debounce
        now = time.time()
        if now - self.last_build < self.debounce_seconds:
            return

        print(f"\n📝 Change detected: {event.src_path}")
        self.rebuild()
        self.last_build = now

    def rebuild(self):
        print("🔨 Rebuilding documentation...")

        # Extract API docs
        print("  → Extracting API docs...")
        result = subprocess.run(
            ["python", "scripts/extract-docs.py"], capture_output=True, text=True
        )
        if result.returncode != 0:
            print(f"  ✗ Error: {result.stderr}")
            return
        print(result.stdout)

        # Generate test reports
        print("  → Generating test reports...")
        result = subprocess.run(
            ["python", "scripts/generate-test-report.py"],
            capture_output=True,
            text=True,
        )
        if result.returncode != 0:
            print(f"  ✗ Error: {result.stderr}")
        print(result.stdout)

        print("✅ Rebuild complete! Typst watch will recompile...")


def main():
    print("👀 Watching example/python-project/src/ for changes...")
    print("💡 Run 'typst watch example/main-api-docs.typ' in another terminal")
    print("💡 Click 'Go Live' in VS Code for auto-refresh\n")

    # Initial build
    handler = DocBuilder()
    handler.rebuild()

    # Watch for changes
    observer = Observer()
    observer.schedule(handler, "example/python-project/src/", recursive=True)
    observer.start()

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
        print("\n👋 Stopping watcher...")
    observer.join()


if __name__ == "__main__":
    main()
