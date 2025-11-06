#!/usr/bin/env python3
"""
Script to add CSS styling to Typst HTML exports with optional dark mode toggle and TOC sidebar.
Usage: python add-styling.py input.html [output.html] [--inline] [--theme-toggle] [--toc-sidebar]
"""

import re
import sys
from pathlib import Path


def add_css_to_html(
    input_file,
    output_file=None,
    css_file="styles.css",
    inline=False,
    force=False,
    theme_toggle=False,
    toc_sidebar=False,
):
    """
    Add CSS link or inline styles to an HTML file with optional theme toggle and TOC sidebar.

    Args:
        input_file: Path to input HTML file
        output_file: Path to output HTML file (default: replace input)
        css_file: Path to CSS file to link or embed
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

    # Check if styling already exists
    if '<link rel="stylesheet"' in html_content or "<style>" in html_content:
        if not force:
            print("⚠️  Styling already exists in the HTML file.")
            try:
                response = input("Do you want to replace it? (y/n): ")
                if response.lower() != "y":
                    print("Aborted.")
                    return
            except EOFError:
                # Non-interactive mode, skip
                pass
        # Remove existing style/link tags from the head section only (not from SVGs!)
        # But preserve diagram colors CSS which is needed for theme switching
        # Split at </head> to only process the head section
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

            # Remove style/link tags only from head
            head_section = re.sub(r'<link[^>]*rel="stylesheet"[^>]*>', "", head_section)
            head_section = re.sub(
                r"<style>.*?</style>", "", head_section, flags=re.DOTALL
            )

            # Restore diagram colors CSS
            if diagram_colors_css:
                head_section += f"\n    {diagram_colors_css}\n"

            html_content = head_section + body_section
        else:
            # Fallback: remove all (shouldn't happen with valid HTML)
            html_content = re.sub(r'<link[^>]*rel="stylesheet"[^>]*>', "", html_content)
            html_content = re.sub(
                r"<style>.*?</style>", "", html_content, flags=re.DOTALL
            )

    if inline:
        # Inline CSS
        if not css_path.exists():
            print(f"❌ CSS file not found: {css_path}")
            sys.exit(1)

        css_content = css_path.read_text(encoding="utf-8")
        style_tag = f"\n    <style>\n{css_content}\n    </style>"

        # Insert before </head> or after <head>
        if "</head>" in html_content:
            html_content = html_content.replace("</head>", f"{style_tag}\n  </head>")
        elif "<head>" in html_content:
            html_content = html_content.replace("<head>", f"<head>{style_tag}")
        else:
            # Add head section if it doesn't exist
            html_content = html_content.replace(
                "<html>", f"<html>\n  <head>{style_tag}\n  </head>"
            )

        print("✅ Embedded CSS inline")
    else:
        # External link
        # Use relative path
        css_relative = css_path.name
        link_tag = f'\n    <link rel="stylesheet" href="{css_relative}">'

        # Insert before </head> or after <head>
        if "</head>" in html_content:
            html_content = html_content.replace("</head>", f"{link_tag}\n  </head>")
        elif "<head>" in html_content:
            html_content = html_content.replace("<head>", f"<head>{link_tag}")
        else:
            # Add head section if it doesn't exist
            html_content = html_content.replace(
                "<html>", f"<html>\n  <head>{link_tag}\n  </head>"
            )

        print(f"✅ Added link to {css_relative}")

    # Collect elements to inject after <body>
    body_injections = []

    # Add theme toggle if requested
    if theme_toggle:
        # Theme toggle button HTML
        toggle_html = """
    <button class="theme-toggle" onclick="toggleTheme()" aria-label="Toggle theme">
      <span id="theme-icon">🌓</span> Theme
    </button>"""
        body_injections.append(toggle_html)

        # Theme toggle JavaScript
        toggle_js = """
    <script>
      // Theme toggle functionality
      const body = document.body;
      const icon = document.getElementById('theme-icon');

      // Load saved theme on page load
      const savedTheme = localStorage.getItem('theme');
      if (savedTheme) {
        body.setAttribute('data-theme', savedTheme);
        updateIcon(savedTheme);
      }

      function toggleTheme() {
        const current = body.getAttribute('data-theme');

        // Simple cycle: Auto → Dark → Light → Auto
        if (!current) {
          // Auto → Dark
          body.setAttribute('data-theme', 'dark');
          localStorage.setItem('theme', 'dark');
          updateIcon('dark');
        } else if (current === 'dark') {
          // Dark → Light
          body.setAttribute('data-theme', 'light');
          localStorage.setItem('theme', 'light');
          updateIcon('light');
        } else {
          // Light → Auto
          body.removeAttribute('data-theme');
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

        # Theme toggle CSS
        toggle_css = """
    <style>
      /* Theme Toggle Button */
      .theme-toggle {
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 0.4rem 0.8rem;
        background: var(--primary-color, #3b82f6);
        color: white;
        border: none;
        border-radius: 4px;
        font-size: 1rem;
        font-weight: bold;
        cursor: pointer;
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        transition: all 0.2s ease;
        z-index: 1000;
        display: flex;
        align-items: center;
        gap: 0.5rem;
        font-family: system-ui, -apple-system, sans-serif;
      }

      .theme-toggle:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 8px rgba(0, 0, 0, 0.15);
        background: var(--primary-hover, #2563eb);
      }

      .theme-toggle:active {
        transform: translateY(0);
      }

      #theme-icon {
        font-size: 1.1rem;
        line-height: 1;
      }

      /* Auto dark mode (system preference) */
      @media (prefers-color-scheme: dark) {
        body:not([data-theme]) {
          background: #0f172a;
          color: #e2e8f0;
          color-scheme: dark;
        }

        body:not([data-theme]) main {
          background: #1e293b;
          color: #e2e8f0;
        }
      }

      /* Dark mode forced styles */
      body[data-theme="dark"] {
        background: #0f172a;
        color: #e2e8f0;
        color-scheme: dark;
      }

      body[data-theme="dark"] main {
        background: #1e293b;
        color: #e2e8f0;
      }

      /* Light mode forced styles */
      body[data-theme="light"] {
        background: #ffffff;
        color: #1e293b;
        color-scheme: light;
      }

      body[data-theme="light"] main {
        background: #ffffff;
        color: #1e293b;
      }

      /* Responsive design */
      @media (max-width: 768px) {
        .theme-toggle {
          top: 10px;
          right: 10px;
          padding: 0.4rem 0.8rem;
          font-size: 0.9rem;
        }
      }
    </style>"""

        # Insert CSS before </head> or at the beginning
        if "</head>" in html_content:
            html_content = html_content.replace("</head>", f"{toggle_css}\n  </head>")
        elif "<head>" in html_content:
            html_content = html_content.replace("<head>", f"<head>{toggle_css}")
        else:
            # Add head if it doesn't exist
            html_content = html_content.replace(
                "<html>", f"<html>\n  <head>{toggle_css}\n  </head>"
            )

        # Insert JavaScript before </body> or at the end
        if "</body>" in html_content:
            html_content = html_content.replace("</body>", f"{toggle_js}\n  </body>")
        else:
            # Fallback: add before </html>
            html_content = html_content.replace("</html>", f"{toggle_js}\n</html>")

        print("✅ Added dark mode toggle button")

    # Add TOC sidebar if requested
    if toc_sidebar:
        # TOC sidebar HTML
        toc_html = """
    <!-- TOC Sidebar -->
    <div id="toc-sidebar" class="toc-sidebar">
      <div class="toc-header">
        <h3>Contents</h3>
        <button id="toc-toggle" class="toc-collapse-btn" aria-label="Collapse sidebar">←</button>
      </div>
      <nav id="toc-nav" class="toc-nav">
        <!-- TOC will be generated by JavaScript -->
      </nav>
    </div>
    <button id="toc-expand-btn" class="toc-expand-btn" aria-label="Expand sidebar">→</button>
    <button id="toc-mobile-toggle" class="toc-mobile-toggle" aria-label="Toggle table of contents">

    </button>"""
        body_injections.append(toc_html)

        # TOC JavaScript
        toc_js = """
    <script>
      // TOC Sidebar functionality
      (function() {
        const sidebar = document.getElementById('toc-sidebar');
        const tocNav = document.getElementById('toc-nav');
        const tocToggle = document.getElementById('toc-toggle');
        const tocExpandBtn = document.getElementById('toc-expand-btn');
        const mobileToggle = document.getElementById('toc-mobile-toggle');

        // Extract headings and build TOC
        function buildTOC() {
          const headings = document.querySelectorAll('h2, h3');
          if (headings.length === 0) return;

          const tocList = document.createElement('ul');
          tocList.className = 'toc-list';
          let currentH2Item = null;
          let currentSublist = null;

          headings.forEach((heading, index) => {
            // Add ID if heading doesn't have one
            if (!heading.id) {
              heading.id = 'heading-' + index;
            }

            const li = document.createElement('li');
            li.className = 'toc-item';

            const link = document.createElement('a');
            link.href = '#' + heading.id;
            link.textContent = heading.textContent;
            link.className = 'toc-link';

            // Smooth scroll on click
            link.addEventListener('click', (e) => {
              e.preventDefault();

              const wasActive = link.classList.contains('active');

              // If losing focus (clicking a different link), collapse ALL subsections
              // EXCEPT if clicking an H3 (subsection) - keep its parent's subsections open
              if (!wasActive && heading.tagName !== 'H3') {
                document.querySelectorAll('.toc-sublist').forEach(sl => {
                  sl.classList.add('collapsed');
                });
              }

              // Highlight active link
              document.querySelectorAll('.toc-link').forEach(l => l.classList.remove('active'));
              link.classList.add('active');

              // Scroll to heading (unless toggling subsections)
              if (!wasActive || heading.tagName !== 'H2') {
                heading.scrollIntoView({ behavior: 'smooth', block: 'start' });
                history.pushState(null, null, '#' + heading.id);
              }
            });

            if (heading.tagName === 'H2') {
              // Main section
              li.appendChild(link);
              tocList.appendChild(li);

              currentH2Item = li;
              currentSublist = null;
            } else if (heading.tagName === 'H3' && currentH2Item) {
              // Subsection
              if (!currentSublist) {
                currentSublist = document.createElement('ul');
                currentSublist.className = 'toc-sublist collapsed'; // Start collapsed
                currentH2Item.appendChild(currentSublist);

                // Make the parent H2 link toggleable
                const parentLink = currentH2Item.querySelector('.toc-link');
                if (parentLink) {
                  parentLink.classList.add('has-subsections');

                  // Capture the sublist in closure properly
                  const thisSublist = currentSublist;

                  // Add click handler for subsection behavior
                  parentLink.addEventListener('click', (e) => {
                    const wasActive = parentLink.classList.contains('active');

                    if (wasActive) {
                      // Already active: toggle subsections (show/hide)
                      e.preventDefault();
                      thisSublist.classList.toggle('collapsed');
                    } else {
                      // Not active: expand this one (others already collapsed by general handler)
                      thisSublist.classList.remove('collapsed');
                    }
                  });
                }
              }

              li.appendChild(link);
              currentSublist.appendChild(li);
            }
          });

          tocNav.appendChild(tocList);
        }

        // Toggle sidebar collapsed state
        function toggleSidebar() {
          sidebar.classList.toggle('collapsed');
          const isCollapsed = sidebar.classList.contains('collapsed');
          tocToggle.innerHTML = isCollapsed ? '→' : '←';
          tocToggle.setAttribute('aria-label', isCollapsed ? 'Expand sidebar' : 'Collapse sidebar');
          localStorage.setItem('tocSidebarCollapsed', isCollapsed);
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
            document.querySelectorAll('.toc-link').forEach(link => {
              link.classList.remove('active');
              if (link.getAttribute('href') === '#' + activeHeading.id) {
                link.classList.add('active');
              }
            });
          }
        }

        // Event listeners
        tocToggle.addEventListener('click', toggleSidebar);
        tocExpandBtn.addEventListener('click', toggleSidebar);
        mobileToggle.addEventListener('click', () => {
          sidebar.classList.toggle('mobile-open');
        });

        // Restore collapsed state from localStorage
        const savedState = localStorage.getItem('tocSidebarCollapsed');
        if (savedState === 'true') {
          sidebar.classList.add('collapsed');
          tocToggle.innerHTML = '→';
        }

        // Build TOC on page load
        buildTOC();

        // Highlight on scroll (debounced)
        let scrollTimeout;
        window.addEventListener('scroll', () => {
          clearTimeout(scrollTimeout);
          scrollTimeout = setTimeout(highlightActiveSection, 50);
        });

        // Initial highlight
        highlightActiveSection();
      })();
    </script>"""

        # TOC CSS
        toc_css = """
    <style>
      /* TOC Sidebar */
      .toc-sidebar {
        position: fixed;
        left: 0;
        top: 0;
        width: 280px;
        height: 100vh;
        background: var(--bg-secondary, #f9fafb);
        border-right: 2px solid var(--border-color, #e5e7eb);
        overflow-y: auto;
        transition: transform 0.3s ease;
        z-index: 999;
        box-shadow: 2px 0 10px var(--shadow-color, rgba(0, 0, 0, 0.1));
      }

      .toc-sidebar.collapsed {
        transform: translateX(-100%);
      }

      .toc-header {
        position: sticky;
        top: 0;
        background: var(--bg-secondary, #f9fafb);
        padding: 1.5rem 1rem 1rem 1rem;
        border-bottom: 2px solid var(--primary-color, #2563eb);
        display: flex;
        justify-content: space-between;
        align-items: center;
        z-index: 10;
      }

      .toc-header h3 {
        margin: 0;
        font-size: 1.1rem;
        color: var(--text-color, #1f2937);
      }

      .toc-collapse-btn {
        background: var(--primary-color, #2563eb);
        color: white;
        border: none;
        border-radius: 4px;
        padding: 0.4rem 0.8rem;
        cursor: pointer;
        font-size: 1rem;
        font-weight: bold;
        transition: all 0.2s ease;
      }

      .toc-collapse-btn:hover {
        background: var(--primary-hover, #1d4ed8);
        transform: scale(1.1);
      }

      .toc-nav {
        padding: 1rem;
      }

      .toc-list {
        list-style: none;
        padding: 0;
        margin: 0;
      }

      .toc-item {
        margin: 0.25rem 0;
        position: relative;
      }

      .toc-link {
        display: block;
        padding: 0.5rem 0.75rem;
        color: var(--text-secondary, #4b5563);
        text-decoration: none;
        border-radius: 4px;
        transition: all 0.2s ease;
        font-size: 0.9rem;
        line-height: 1.4;
      }

      .toc-link:hover {
        background: var(--table-row-hover, rgba(37, 99, 235, 0.1));
        color: var(--primary-color, #2563eb);
        padding-left: 1rem;
      }

      .toc-link.active {
        background: var(--primary-color, #2563eb);
        color: white;
        font-weight: 600;
        border-left: 3px solid var(--primary-hover, #1d4ed8);
      }

      .toc-link.has-subsections {
        font-weight: 600;
      }

      .toc-sublist {
        list-style: none;
        padding-left: 1.5rem;
        margin: 0.25rem 0;
        border-left: 2px solid var(--border-light, #e5e7eb);
        max-height: 1000px;
        overflow: hidden;
        transition: max-height 0.3s ease, opacity 0.3s ease;
        opacity: 1;
      }

      .toc-sublist.collapsed {
        max-height: 0;
        opacity: 0;
      }

      .toc-sublist .toc-link {
        font-size: 0.85rem;
        padding: 0.4rem 0.5rem;
      }

      /* Mobile toggle button */
      .toc-mobile-toggle {
        display: none;
        position: fixed;
        bottom: 20px;
        left: 20px;
        width: 50px;
        height: 50px;
        background: var(--primary-color, #2563eb);
        color: white;
        border: none;
        border-radius: 50%;
        font-size: 1.5rem;
        cursor: pointer;
        box-shadow: 0 4px 12px var(--shadow-color, rgba(0, 0, 0, 0.2));
        z-index: 998;
        transition: all 0.2s ease;
      }

      .toc-mobile-toggle:hover {
        transform: scale(1.1);
        box-shadow: 0 6px 16px var(--shadow-color, rgba(0, 0, 0, 0.3));
      }

      /* Adjust main content to make room for sidebar */
      body {
        margin-left: 280px;
        transition: margin-left 0.3s ease;
      }

      body:has(.toc-sidebar.collapsed) {
        margin-left: 0;
      }

      /* Expand button - appears when sidebar is collapsed */
      .toc-expand-btn {
        position: fixed;
        top: 20px;
        left: 0;
        padding: 0.4rem 0.8rem;
        background: var(--primary-color, #2563eb);
        color: white;
        border: none;
        border-radius: 0 4px 4px 0;
        cursor: pointer;
        font-size: 1rem;
        font-weight: bold;
        z-index: 998;
        opacity: 0;
        pointer-events: none;
        transition: all 0.2s ease;
        display: flex;
        align-items: center;
        justify-content: center;
        box-shadow: 2px 0 10px var(--shadow-color, rgba(0, 0, 0, 0.2));
      }

      .toc-sidebar.collapsed ~ .toc-expand-btn {
        opacity: 1;
        pointer-events: all;
      }

      .toc-expand-btn:hover {
        background: var(--primary-hover, #1d4ed8);
        transform: scale(1.1);
      }

      /* Adjust theme toggle button position when sidebar is open */
      .theme-toggle {
        right: 20px;
      }

      /* Custom scrollbar for TOC */
      .toc-sidebar::-webkit-scrollbar {
        width: 8px;
      }

      .toc-sidebar::-webkit-scrollbar-track {
        background: var(--bg-primary, #ffffff);
      }

      .toc-sidebar::-webkit-scrollbar-thumb {
        background: var(--bg-tertiary, #f3f4f6);
        border-radius: 4px;
      }

      .toc-sidebar::-webkit-scrollbar-thumb:hover {
        background: var(--border-light, #e5e7eb);
      }

      /* Responsive design */
      @media (max-width: 1024px) {
        .toc-sidebar {
          width: 240px;
        }

        body {
          margin-left: 240px;
        }

        body:has(.toc-sidebar.collapsed) {
          margin-left: 0;
        }
      }

      @media (max-width: 768px) {
        .toc-sidebar {
          transform: translateX(-100%);
          width: 280px;
        }

        .toc-sidebar.mobile-open {
          transform: translateX(0);
        }

        .toc-sidebar.collapsed {
          transform: translateX(-100%);
        }

        body {
          margin-left: 0 !important;
        }

        .toc-mobile-toggle {
          display: block;
        }

        .toc-collapse-btn {
          display: none !important;
        }

        .toc-expand-btn {
          display: none !important;
        }
      }

      /* Print: hide TOC */
      @media print {
        .toc-sidebar,
        .toc-mobile-toggle,
        .toc-expand-btn {
          display: none !important;
        }

        body {
          margin-left: 0 !important;
        }
      }
    </style>"""

        # Insert CSS before </head>
        if "</head>" in html_content:
            html_content = html_content.replace("</head>", f"{toc_css}\n  </head>")
        elif "<head>" in html_content:
            html_content = html_content.replace("<head>", f"<head>{toc_css}")
        else:
            html_content = html_content.replace(
                "<html>", f"<html>\n  <head>{toc_css}\n  </head>"
            )

        # Insert JavaScript before </body>
        if "</body>" in html_content:
            html_content = html_content.replace("</body>", f"{toc_js}\n  </body>")
        else:
            html_content = html_content.replace("</html>", f"{toc_js}\n</html>")

        print(
            "✅ Added collapsible TOC sidebar (click active section to toggle subsections)"
        )

    # Inject all body elements at once (after <body> tag)
    if body_injections:
        combined_injection = "".join(body_injections)
        if "<body>" in html_content:
            html_content = html_content.replace(
                "<body>", f"<body>{combined_injection}", 1
            )
        else:
            # Fallback: add after html tag
            html_content = html_content.replace(
                "<html>", f"<html><body>{combined_injection}", 1
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
        print(
            "TOC sidebar on the left shows all headings - click active section to toggle subsections!"
        )


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(
            "Usage: python add-styling.py input.html [output.html] [--inline] [--force] [--theme-toggle] [--toc-sidebar]"
        )
        print(
            "Example: python add-styling.py stakeholder-example.html --theme-toggle --toc-sidebar"
        )
        print("  --inline:       Embed CSS directly (default: external link)")
        print("  --force:        Skip confirmation prompts")
        print("  --theme-toggle: Add dark mode toggle button in top-right corner")
        print(
            "  --toc-sidebar:  Add sticky table of contents sidebar with collapsible sections"
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

    add_css_to_html(
        input_file,
        output_file,
        inline=inline,
        force=force,
        theme_toggle=theme_toggle,
        toc_sidebar=toc_sidebar,
    )
