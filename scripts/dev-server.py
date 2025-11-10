#!/usr/bin/env python3
"""
Development HTTP server with better handling than SimpleHTTPServer.
Uses ThreadingHTTPServer for better concurrent request handling.
"""

import argparse
import http.server
import socketserver
import sys
from pathlib import Path


class BetterHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    """
    Enhanced HTTP request handler with:
    - Proper Content-Length headers
    - Better error handling
    - CORS headers for development
    """

    def end_headers(self):
        """Add CORS headers and ensure proper caching behavior."""
        # Add CORS headers (helpful for development)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")

        # Disable caching for HTML/CSS/JS during development
        if self.path.endswith((".html", ".css", ".js")):
            self.send_header("Cache-Control", "no-cache, no-store, must-revalidate")
            self.send_header("Pragma", "no-cache")
            self.send_header("Expires", "0")

        super().end_headers()

    def log_message(self, format, *args):
        """Customize log messages."""
        # Color code based on status
        status_code = args[1] if len(args) > 1 else "000"
        if status_code.startswith("2"):
            color = "\033[92m"  # Green
        elif status_code.startswith("3"):
            color = "\033[93m"  # Yellow
        elif status_code.startswith("4") or status_code.startswith("5"):
            color = "\033[91m"  # Red
        else:
            color = "\033[0m"  # Default

        reset = "\033[0m"
        sys.stderr.write(
            f"{color}[{self.log_date_time_string()}] {format % args}{reset}\n"
        )


def run_server(port=8000, directory="."):
    """
    Run a development HTTP server.

    Args:
        port: Port number to listen on
        directory: Directory to serve files from
    """
    # Change to the specified directory
    Path(directory).resolve()

    # Use ThreadingHTTPServer for better handling of concurrent requests
    handler = BetterHTTPRequestHandler

    # Set the directory to serve
    handler.directory = directory

    with socketserver.ThreadingTCPServer(("", port), handler) as httpd:
        addr, port = httpd.server_address
        print(f"\n{'=' * 60}")
        print("🌐 Development Server Started")
        print(f"{'=' * 60}")
        print(f"Serving: {Path(directory).resolve()}")
        print(f"Address: http://localhost:{port}")
        print("\nPress Ctrl+C to stop the server")
        print(f"{'=' * 60}\n")

        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print(f"\n\n{'=' * 60}")
            print("🛑 Server stopped")
            print(f"{'=' * 60}\n")
            sys.exit(0)


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="Development HTTP server with better handling"
    )
    parser.add_argument(
        "-p", "--port", type=int, default=8000, help="Port to listen on (default: 8000)"
    )
    parser.add_argument(
        "-d",
        "--directory",
        type=str,
        default=".",
        help="Directory to serve (default: current directory)",
    )

    args = parser.parse_args()

    run_server(port=args.port, directory=args.directory)


if __name__ == "__main__":
    main()
