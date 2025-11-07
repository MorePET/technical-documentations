#!/usr/bin/env python3
"""
Script to add Bootstrap styling to Typst HTML exports with optional dark mode toggle and TOC sidebar.
Usage: python add-styling-bootstrap.py input.html [output.html] [--inline] [--theme-toggle] [--toc-sidebar]
"""

import re
import sys
from pathlib import Path


def add_bootstrap_to_html(
    input_file,
    output_file=None,
    css_file="styles-bootstrap.css",
    inline=False,
    force=False,
    theme_toggle=False,
    toc_sidebar=False,
):
    """
    Add Bootstrap and custom CSS to an HTML file with optional theme toggle and TOC sidebar.

    Args:
        input_file: Path to input HTML file
        output_file: Path to output HTML file (default: replace input)
        css_file: Path to custom CSS file to link or embed
        inline: If True, embed CSS inline; if False, add external link
        force: If True, skip confirmation prompts
        theme_toggle: If True, add dark mode toggle button
        toc_sidebar: If True, add sticky table of contents sidebar
    """
    input_path = Path(input_file)
    output_path = Path(output_file) if output_file else input_path
    css_path = Path(css_file)

    # Read the HTML
    html_content = input_path.read_text(encoding="utf-8")

    # Check if Bootstrap already exists
    if 'bootstrap' in html_content:
        if not force:
            print("⚠️  Bootstrap already exists in the HTML file.")
            try:
                response = input("Do you want to replace it? (y/n): ")
                if response.lower() != "y":
                    print("Aborted.")
                    return
            except EOFError:
                # Non-interactive mode, skip
                pass

    # Remove existing style/link tags from the head section (except diagram colors CSS)
    head_end = html_content.find("</head>")
    if head_end != -1:
        head_section = html_content[:head_end]
        body_section = html_content[head_end:]

        # Preserve diagram colors CSS if present
        diagram_colors_match = re.search(
            r"(<style>\s*/\* Diagram colors.*?</style>)",
            head_section,
            flags=re.DOTALL,
        )
        diagram_colors_css = (
            diagram_colors_match.group(1) if diagram_colors_match else ""
        )

        # Remove old style/link tags only from head (but keep viewport meta)
        head_section = re.sub(
            r'<link[^>]*rel="stylesheet"(?![^>]*bootstrap)[^>]*>', "", head_section
        )
        head_section = re.sub(
            r"<style>(?!.*Diagram colors).*?</style>", "", head_section, flags=re.DOTALL
        )

        # Restore diagram colors CSS
        if diagram_colors_css:
            head_section += f"\n    {diagram_colors_css}\n"

        html_content = head_section + body_section

    # Add viewport meta tag if not present
    if 'name="viewport"' not in html_content:
        viewport_tag = '\n    <meta name="viewport" content="width=device-width, initial-scale=1">'
        if "<head>" in html_content:
            html_content = html_content.replace("<head>", f"<head>{viewport_tag}", 1)

    # Add Bootstrap CSS from CDN
    bootstrap_css = '\n    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-T3c6CoIi6uLrA9TneNEoa7RxnatzjcDSCmG1MXxSR1GAsXEV/Dwwykc2MPK8M2HN" crossorigin="anonymous">'

    if "</head>" in html_content:
        html_content = html_content.replace("</head>", f"{bootstrap_css}\n  </head>", 1)
    elif "<head>" in html_content:
        html_content = html_content.replace("<head>", f"<head>{bootstrap_css}", 1)
    else:
        html_content = html_content.replace(
            "<html>", f"<html>\n  <head>{bootstrap_css}\n  </head>", 1
        )

    print("✅ Added Bootstrap 5.3.2 CSS from CDN")

    # Add custom CSS
    if inline:
        # Inline custom CSS
        if not css_path.exists():
            # Try to find it in lib/
            css_path = Path(__file__).parent.parent / "lib" / css_file
            if not css_path.exists():
                print(f"❌ CSS file not found: {css_path}")
                sys.exit(1)

        css_content = css_path.read_text(encoding="utf-8")
        style_tag = f"\n    <style>\n{css_content}\n    </style>"

        if "</head>" in html_content:
            html_content = html_content.replace("</head>", f"{style_tag}\n  </head>", 1)
        else:
            html_content = html_content.replace("<head>", f"<head>{style_tag}", 1)

        print("✅ Embedded custom CSS inline")
    else:
        # External link to custom CSS
        css_relative = css_path.name
        link_tag = f'\n    <link rel="stylesheet" href="{css_relative}">'

        if "</head>" in html_content:
            html_content = html_content.replace("</head>", f"{link_tag}\n  </head>", 1)
        else:
            html_content = html_content.replace("<head>", f"<head>{link_tag}", 1)

        print(f"✅ Added link to {css_relative}")

    # Add Bootstrap JS bundle (includes Popper)
    bootstrap_js = '    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-C6RzsynM9kWDrMNeT87bh95OGNyZPhcTNXj1NW7RuBCsyN/o0jlpcV8Qyq46cDfL" crossorigin="anonymous"></script>'

    if "</body>" in html_content:
        html_content = html_content.replace("</body>", f"\n{bootstrap_js}\n  </body>", 1)
    else:
        html_content = html_content.replace("</html>", f"{bootstrap_js}\n</html>", 1)

    print("✅ Added Bootstrap 5.3.2 JS from CDN")

    # Wrap main content in Bootstrap container if not already wrapped
    if '<div class="container">' not in html_content and '<body>' in html_content:
        # Find body content (after any injected elements like theme toggle)
        body_start = html_content.find("<body>") + len("<body>")
        body_end = html_content.find("</body>")

        if body_end != -1:
            # Extract body content (skip theme toggle/toc if present)
            body_content = html_content[body_start:body_end]

            # Find where actual content starts (after theme toggle, toc, etc.)
            content_start = 0
            for marker in ['<button class="theme-toggle"', '<div id="toc-sidebar"']:
                idx = body_content.find(marker)
                if idx != -1:
                    # Find the end of this element
                    if 'theme-toggle' in marker:
                        end_idx = body_content.find('</button>', idx) + len('</button>')
                    else:
                        end_idx = body_content.find('</div>', idx) + len('</div>')
                    content_start = max(content_start, end_idx)

            prefix = body_content[:content_start]
            main_content = body_content[content_start:]

            # Wrap main content in container with margin for TOC
            container_class = "container py-4"
            if toc_sidebar:
                container_class += " ms-auto"

            wrapped_content = f'{prefix}\n    <div class="{container_class}">\n{main_content}    </div>'

            html_content = (
                html_content[:body_start] + wrapped_content + html_content[body_end:]
            )

            print("✅ Wrapped content in Bootstrap container")

    # Collect elements to inject after <body>
    body_injections = []

    # Add theme toggle if requested
    if theme_toggle:
        # Bootstrap-compatible theme toggle
        toggle_html = """
    <button class="theme-toggle btn btn-primary" onclick="toggleTheme()" aria-label="Toggle theme">
      <span id="theme-icon">🌓</span> <span class="d-none d-sm-inline">Theme</span>
    </button>"""
        body_injections.append(toggle_html)

        # Bootstrap-compatible theme toggle JavaScript
        toggle_js = """
    <script>
      // Bootstrap dark mode toggle functionality
      const htmlElement = document.documentElement;
      const body = document.body;
      const icon = document.getElementById('theme-icon');

      // Load saved theme on page load
      const savedTheme = localStorage.getItem('theme');
      if (savedTheme) {
        htmlElement.setAttribute('data-bs-theme', savedTheme);
        updateIcon(savedTheme);
      }

      function toggleTheme() {
        const current = htmlElement.getAttribute('data-bs-theme');

        // Simple cycle: Auto → Dark → Light → Auto
        if (!current) {
          // Auto → Dark
          htmlElement.setAttribute('data-bs-theme', 'dark');
          localStorage.setItem('theme', 'dark');
          updateIcon('dark');
        } else if (current === 'dark') {
          // Dark → Light
          htmlElement.setAttribute('data-bs-theme', 'light');
          localStorage.setItem('theme', 'light');
          updateIcon('light');
        } else {
          // Light → Auto
          htmlElement.removeAttribute('data-bs-theme');
          localStorage.removeItem('theme');
          updateIcon('auto');
        }
      }

      function updateIcon(theme) {
        if (theme === 'light') {
          icon.textContent = '🌕';
        } else if (theme === 'dark') {
          icon.textContent = '🌑';
        } else {
          icon.textContent = '🌓';
        }
      }
    </script>"""

        # Theme toggle CSS (Bootstrap-compatible)
        toggle_css = """
    <style>
      /* Theme Toggle Button */
      .theme-toggle {
        position: fixed;
        top: 20px;
        right: 20px;
        z-index: 1050;
        display: flex;
        align-items: center;
        gap: 0.5rem;
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
      }

      .theme-toggle:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 8px rgba(0, 0, 0, 0.15);
      }

      #theme-icon {
        font-size: 1.1rem;
        line-height: 1;
      }

      /* Responsive */
      @media (max-width: 576px) {
        .theme-toggle {
          top: 10px;
          right: 10px;
          padding: 0.4rem 0.8rem;
          font-size: 0.9rem;
        }
      }
    </style>"""

        # Insert CSS before </head>
        if "</head>" in html_content:
            html_content = html_content.replace("</head>", f"{toggle_css}\n  </head>", 1)

        # Insert JavaScript before </body>
        if "</body>" in html_content:
            # Insert before Bootstrap JS
            html_content = html_content.replace(
                bootstrap_js, f"{toggle_js}\n{bootstrap_js}"
            )

        print("✅ Added Bootstrap-compatible dark mode toggle button")

    # Add TOC sidebar if requested (using Bootstrap offcanvas)
    if toc_sidebar:
        # Bootstrap offcanvas TOC sidebar
        toc_html = """
    <!-- TOC Sidebar (Bootstrap Offcanvas) -->
    <button class="btn btn-primary toc-mobile-toggle d-lg-none" type="button" data-bs-toggle="offcanvas" data-bs-target="#tocOffcanvas" aria-label="Toggle table of contents">
      📋
    </button>

    <div class="offcanvas offcanvas-start show d-none d-lg-block" data-bs-scroll="true" data-bs-backdrop="false" tabindex="-1" id="tocOffcanvas" style="width: 280px; position: fixed; height: 100vh;">
      <div class="offcanvas-header border-bottom">
        <h5 class="offcanvas-title">Contents</h5>
        <button type="button" class="btn-close d-lg-none" data-bs-dismiss="offcanvas" aria-label="Close"></button>
      </div>
      <div class="offcanvas-body" style="overflow-y: auto;">
        <nav id="toc-nav" class="nav flex-column">
          <!-- TOC will be generated by JavaScript -->
        </nav>
      </div>
    </div>"""
        body_injections.append(toc_html)

        # TOC JavaScript (Bootstrap-compatible)
        toc_js = """
    <script>
      // TOC Sidebar functionality (Bootstrap-compatible)
      (function() {
        const tocNav = document.getElementById('toc-nav');

        // Extract headings and build TOC
        function buildTOC() {
          const headings = document.querySelectorAll('h2, h3');
          if (headings.length === 0) return;

          headings.forEach((heading, index) => {
            // Add ID if heading doesn't have one
            if (!heading.id) {
              heading.id = 'heading-' + index;
            }

            const link = document.createElement('a');
            link.href = '#' + heading.id;
            link.textContent = heading.textContent;
            link.className = 'nav-link';

            if (heading.tagName === 'H2') {
              link.classList.add('fw-semibold');
            } else {
              link.classList.add('ms-3', 'text-muted');
            }

            // Smooth scroll on click
            link.addEventListener('click', (e) => {
              e.preventDefault();

              // Update active state
              document.querySelectorAll('#toc-nav .nav-link').forEach(l => {
                l.classList.remove('active', 'text-primary');
                if (l.classList.contains('text-muted')) {
                  // Keep h3 links muted when not active
                } else {
                  l.classList.add('text-body');
                }
              });

              link.classList.add('active', 'text-primary');
              link.classList.remove('text-muted', 'text-body');

              // Scroll to heading
              heading.scrollIntoView({ behavior: 'smooth', block: 'start' });
              history.pushState(null, null, '#' + heading.id);

              // Close offcanvas on mobile
              const offcanvas = bootstrap.Offcanvas.getInstance(document.getElementById('tocOffcanvas'));
              if (offcanvas && window.innerWidth < 992) {
                offcanvas.hide();
              }
            });

            tocNav.appendChild(link);
          });
        }

        // Highlight active section on scroll
        function highlightActiveSection() {
          const headings = document.querySelectorAll('h2, h3');
          const scrollPos = window.scrollY + 100;

          let activeHeading = null;
          headings.forEach(heading => {
            if (heading.offsetTop <= scrollPos) {
              activeHeading = heading;
            }
          });

          if (activeHeading) {
            document.querySelectorAll('#toc-nav .nav-link').forEach(link => {
              link.classList.remove('active', 'text-primary');
              if (link.classList.contains('ms-3')) {
                link.classList.add('text-muted');
              } else {
                link.classList.add('text-body');
              }

              if (link.getAttribute('href') === '#' + activeHeading.id) {
                link.classList.add('active', 'text-primary');
                link.classList.remove('text-muted', 'text-body');
              }
            });
          }
        }

        // Build TOC on page load
        if (document.readyState === 'loading') {
          document.addEventListener('DOMContentLoaded', buildTOC);
        } else {
          buildTOC();
        }

        // Highlight on scroll (debounced)
        let scrollTimeout;
        window.addEventListener('scroll', () => {
          clearTimeout(scrollTimeout);
          scrollTimeout = setTimeout(highlightActiveSection, 50);
        });

        // Initial highlight
        setTimeout(highlightActiveSection, 100);
      })();
    </script>"""

        # TOC CSS
        toc_css = """
    <style>
      /* TOC Sidebar adjustments */
      body {
        margin-left: 0;
      }

      @media (min-width: 992px) {
        body {
          margin-left: 280px;
        }

        .offcanvas.show {
          visibility: visible;
        }
      }

      .toc-mobile-toggle {
        position: fixed;
        bottom: 20px;
        left: 20px;
        z-index: 1040;
        border-radius: 50%;
        width: 50px;
        height: 50px;
        padding: 0;
        font-size: 1.5rem;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
      }

      #toc-nav .nav-link {
        padding: 0.5rem 0.75rem;
        border-radius: 0.25rem;
        transition: all 0.2s ease;
      }

      #toc-nav .nav-link:hover {
        background-color: rgba(var(--bs-primary-rgb), 0.1);
      }

      #toc-nav .nav-link.active {
        background-color: var(--bs-primary);
        color: white !important;
      }

      /* Print: hide TOC */
      @media print {
        .offcanvas,
        .toc-mobile-toggle {
          display: none !important;
        }

        body {
          margin-left: 0 !important;
        }
      }
    </style>"""

        # Insert CSS before </head>
        if "</head>" in html_content:
            html_content = html_content.replace("</head>", f"{toc_css}\n  </head>", 1)

        # Insert JavaScript before Bootstrap JS
        if bootstrap_js in html_content:
            html_content = html_content.replace(bootstrap_js, f"{toc_js}\n{bootstrap_js}")

        print("✅ Added Bootstrap offcanvas TOC sidebar")

    # Inject all body elements at once (after <body> tag)
    if body_injections:
        combined_injection = "".join(body_injections)
        if "<body>" in html_content:
            html_content = html_content.replace(
                "<body>", f"<body>{combined_injection}", 1
            )

    # Write the modified HTML
    output_path.write_text(html_content, encoding="utf-8")

    print(f"✅ Styled HTML saved to: {output_path}")
    print(f"\n💡 Open {output_path} in your browser to see the result!")
    if theme_toggle:
        print(
            "🌓 Click the theme button in the top-right corner to switch between light (🌕) / dark (🌑) / auto (🌓) modes!"
        )
    if toc_sidebar:
        print("📋 TOC sidebar on the left shows all headings!")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(
            "Usage: python add-styling-bootstrap.py input.html [output.html] [--inline] [--force] [--theme-toggle] [--toc-sidebar]"
        )
        print(
            "Example: python add-styling-bootstrap.py stakeholder-example.html --theme-toggle --toc-sidebar"
        )
        print("  --inline:       Embed CSS directly (default: external link)")
        print("  --force:        Skip confirmation prompts")
        print("  --theme-toggle: Add dark mode toggle button in top-right corner")
        print(
            "  --toc-sidebar:  Add Bootstrap offcanvas table of contents sidebar"
        )
        sys.exit(1)

    # Parse arguments
    args = sys.argv[1:]
    inline = "--inline" in args
    force = "--force" in args
    theme_toggle = "--theme-toggle" in args
    toc_sidebar = "--toc-sidebar" in args

    # Remove flags from args
    file_args = [arg for arg in args if not arg.startswith("--")]

    input_file = file_args[0]
    output_file = file_args[1] if len(file_args) > 1 else None

    add_bootstrap_to_html(
        input_file,
        output_file,
        inline=inline,
        force=force,
        theme_toggle=theme_toggle,
        toc_sidebar=toc_sidebar,
    )
