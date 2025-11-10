#!/usr/bin/env python3
"""
Script to add Bootstrap styling to Typst HTML exports with optional dark mode toggle and TOC sidebar.
Usage: python add-styling-bootstrap.py input.html [output.html] [--inline] [--theme-toggle] [--toc-sidebar]
"""

import re
import sys
import time
from pathlib import Path


def get_cache_buster(file_path=None):
    """
    Generate a cache-busting query parameter.
    Uses file modification time if file exists, otherwise uses current timestamp.

    Args:
        file_path: Optional path to file to check modification time

    Returns:
        String like "?v=1699632000" for cache-busting
    """
    if file_path and Path(file_path).exists():
        # Use file modification time
        mtime = int(Path(file_path).stat().st_mtime)
        return f"?v={mtime}"
    else:
        # Use current timestamp
        return f"?v={int(time.time())}"


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
    if "bootstrap" in html_content and not force:
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
        viewport_tag = (
            '\n    <meta name="viewport" content="width=device-width, initial-scale=1">'
        )
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

    # Add colors.css first (needed for theme-aware diagram colors)
    # Find colors.css file for cache-busting
    colors_css_path = output_path.parent / "colors.css"
    colors_cache_buster = get_cache_buster(colors_css_path)
    colors_link = (
        f'\n    <link rel="stylesheet" href="colors.css{colors_cache_buster}">'
    )
    if "</head>" in html_content:
        html_content = html_content.replace("</head>", f"{colors_link}\n  </head>", 1)
    else:
        html_content = html_content.replace("<head>", f"<head>{colors_link}", 1)
    print(f"✅ Added link to colors.css{colors_cache_buster}")

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
        # External link to custom CSS with cache-busting
        css_relative = css_path.name
        # Find the CSS file in the output directory for cache-busting
        output_css_path = output_path.parent / css_relative
        cache_buster = get_cache_buster(output_css_path)
        link_tag = f'\n    <link rel="stylesheet" href="{css_relative}{cache_buster}">'

        if "</head>" in html_content:
            html_content = html_content.replace("</head>", f"{link_tag}\n  </head>", 1)
        else:
            html_content = html_content.replace("<head>", f"<head>{link_tag}", 1)

        print(f"✅ Added link to {css_relative}{cache_buster}")

    # Add Bootstrap JS bundle (includes Popper)
    bootstrap_js = '    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-C6RzsynM9kWDrMNeT87bh95OGNyZPhcTNXj1NW7RuBCsyN/o0jlpcV8Qyq46cDfL" crossorigin="anonymous"></script>'

    # Add diagram theme switcher JS
    diagram_js = '    <script src="diagram-theme-switcher.js"></script>'

    if "</body>" in html_content:
        html_content = html_content.replace(
            "</body>", f"\n{bootstrap_js}\n{diagram_js}\n  </body>", 1
        )
    else:
        html_content = html_content.replace("</html>", f"{bootstrap_js}\n</html>", 1)

    print("✅ Added Bootstrap 5.3.2 JS from CDN")

    # Wrap main content in Bootstrap container if not already wrapped
    if '<div class="container">' not in html_content and "<body>" in html_content:
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
                    if "theme-toggle" in marker:
                        end_idx = body_content.find("</button>", idx) + len("</button>")
                    else:
                        end_idx = body_content.find("</div>", idx) + len("</div>")
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

    # Add theme toggle if requested (but NOT if sidebar is enabled - it goes in navbar)
    if theme_toggle and not toc_sidebar:
        # Standalone Bootstrap-compatible theme toggle (only when no navbar)
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
            html_content = html_content.replace(
                "</head>", f"{toggle_css}\n  </head>", 1
            )

        # Insert JavaScript before </body>
        if "</body>" in html_content:
            # Insert before Bootstrap JS
            html_content = html_content.replace(
                bootstrap_js, f"{toggle_js}\n{bootstrap_js}"
            )

        print("✅ Added Bootstrap-compatible dark mode toggle button")

    # Add TOC sidebar if requested (using Bootstrap offcanvas)
    if toc_sidebar:
        # Bootstrap navbar with burger menu for mobile + theme toggle dropdown
        navbar_html = """
    <!-- Bootstrap Navbar -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary fixed-top">
      <div class="container-fluid">
        <button class="btn btn-outline-light me-2 d-lg-none" type="button" data-bs-toggle="offcanvas" data-bs-target="#tocOffcanvas" aria-label="Toggle sidebar">
          <span class="navbar-toggler-icon d-inline-block" style="width: 1.2em; height: 1.2em; vertical-align: middle;"></span>
        </button>
        <a class="navbar-brand" href="#">Technical Documentation</a>"""

        if theme_toggle:
            navbar_html += """
        <div class="dropdown ms-auto">
          <button class="btn btn-outline-light dropdown-toggle d-flex align-items-center" type="button" id="bd-theme" data-bs-toggle="dropdown" aria-expanded="false">
            <svg class="bi theme-icon-active" width="1em" height="1em"><use href="#circle-half"></use></svg>
          </button>
          <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="bd-theme">
            <li>
              <button class="dropdown-item d-flex align-items-center" type="button" data-bs-theme-value="light">
                <svg class="bi me-2 opacity-50" width="1em" height="1em"><use href="#sun-fill"></use></svg>
                Light
                <svg class="bi ms-auto d-none" width="1em" height="1em"><use href="#check2"></use></svg>
              </button>
            </li>
            <li>
              <button class="dropdown-item d-flex align-items-center" type="button" data-bs-theme-value="dark">
                <svg class="bi me-2 opacity-50" width="1em" height="1em"><use href="#moon-stars-fill"></use></svg>
                Dark
                <svg class="bi ms-auto d-none" width="1em" height="1em"><use href="#check2"></use></svg>
              </button>
            </li>
            <li>
              <button class="dropdown-item d-flex align-items-center active" type="button" data-bs-theme-value="auto">
                <svg class="bi me-2 opacity-50" width="1em" height="1em"><use href="#circle-half"></use></svg>
                Auto
                <svg class="bi ms-auto d-none" width="1em" height="1em"><use href="#check2"></use></svg>
              </button>
            </li>
          </ul>
        </div>"""

        navbar_html += """
      </div>
    </nav>

    <!-- Bootstrap Icons SVG Sprites -->
    <svg xmlns="http://www.w3.org/2000/svg" class="d-none">
      <symbol id="check2" viewBox="0 0 16 16">
        <path d="M13.854 3.646a.5.5 0 0 1 0 .708l-7 7a.5.5 0 0 1-.708 0l-3.5-3.5a.5.5 0 1 1 .708-.708L6.5 10.293l6.646-6.647a.5.5 0 0 1 .708 0z"/>
      </symbol>
      <symbol id="circle-half" viewBox="0 0 16 16">
        <path d="M8 15A7 7 0 1 0 8 1v14zm0 1A8 8 0 1 1 8 0a8 8 0 0 1 0 16z"/>
      </symbol>
      <symbol id="moon-stars-fill" viewBox="0 0 16 16">
        <path d="M6 .278a.768.768 0 0 1 .08.858 7.208 7.208 0 0 0-.878 3.46c0 4.021 3.278 7.277 7.318 7.277.527 0 1.04-.055 1.533-.16a.787.787 0 0 1 .81.316.733.733 0 0 1-.031.893A8.349 8.349 0 0 1 8.344 16C3.734 16 0 12.286 0 7.71 0 4.266 2.114 1.312 5.124.06A.752.752 0 0 1 6 .278z"/>
        <path d="M10.794 3.148a.217.217 0 0 1 .412 0l.387 1.162c.173.518.579.924 1.097 1.097l1.162.387a.217.217 0 0 1 0 .412l-1.162.387a1.734 1.734 0 0 0-1.097 1.097l-.387 1.162a.217.217 0 0 1-.412 0l-.387-1.162A1.734 1.734 0 0 0 9.31 6.593l-1.162-.387a.217.217 0 0 1 0-.412l1.162-.387a1.734 1.734 0 0 0 1.097-1.097l.387-1.162zM13.863.099a.145.145 0 0 1 .274 0l.258.774c.115.346.386.617.732.732l.774.258a.145.145 0 0 1 0 .274l-.774.258a1.156 1.156 0 0 0-.732.732l-.258.774a.145.145 0 0 1-.274 0l-.258-.774a1.156 1.156 0 0 0-.732-.732l-.774-.258a.145.145 0 0 1 0-.274l.774-.258c.346-.115.617-.386.732-.732L13.863.1z"/>
      </symbol>
      <symbol id="sun-fill" viewBox="0 0 16 16">
        <path d="M8 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8zM8 0a.5.5 0 0 1 .5.5v2a.5.5 0 0 1-1 0v-2A.5.5 0 0 1 8 0zm0 13a.5.5 0 0 1 .5.5v2a.5.5 0 0 1-1 0v-2A.5.5 0 0 1 8 13zm8-5a.5.5 0 0 1-.5.5h-2a.5.5 0 0 1 0-1h2a.5.5 0 0 1 .5.5zM3 8a.5.5 0 0 1-.5.5h-2a.5.5 0 0 1 0-1h2A.5.5 0 0 1 3 8zm10.657-5.657a.5.5 0 0 1 0 .707l-1.414 1.415a.5.5 0 1 1-.707-.708l1.414-1.414a.5.5 0 0 1 .707 0zm-9.193 9.193a.5.5 0 0 1 0 .707L3.05 13.657a.5.5 0 0 1-.707-.707l1.414-1.414a.5.5 0 0 1 .707 0zm9.193 2.121a.5.5 0 0 1-.707 0l-1.414-1.414a.5.5 0 0 1 .707-.707l1.414 1.414a.5.5 0 0 1 0 .707zM4.464 4.465a.5.5 0 0 1-.707 0L2.343 3.05a.5.5 0 1 1 .707-.707l1.414 1.414a.5.5 0 0 1 0 .708z"/>
      </symbol>
    </svg>"""
        body_injections.append(navbar_html)

        # Add theme toggle JavaScript if theme toggle is enabled (Bootstrap dropdown style)
        if theme_toggle:
            theme_toggle_js = """
    <script>
      /*!
       * Color mode toggler for Bootstrap's docs (https://getbootstrap.com/)
       * Copyright 2011-2024 The Bootstrap Authors
       * Licensed under Creative Commons Attribution 3.0 Unported License.
       */

      (() => {
        'use strict'

        const getStoredTheme = () => localStorage.getItem('theme')
        const setStoredTheme = theme => localStorage.setItem('theme', theme)

        const getPreferredTheme = () => {
          const storedTheme = getStoredTheme()
          if (storedTheme) {
            return storedTheme
          }

          return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light'
        }

        const setTheme = theme => {
          if (theme === 'auto') {
            document.documentElement.setAttribute('data-bs-theme', (window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light'))
          } else {
            document.documentElement.setAttribute('data-bs-theme', theme)
          }
        }

        setTheme(getPreferredTheme())

        const showActiveTheme = (theme, focus = false) => {
          const themeSwitcher = document.querySelector('#bd-theme')

          if (!themeSwitcher) {
            return
          }

          const activeThemeIcon = document.querySelector('.theme-icon-active use')
          const btnToActive = document.querySelector(`[data-bs-theme-value="${theme}"]`)
          const svgOfActiveBtn = btnToActive.querySelector('svg use').getAttribute('href')

          document.querySelectorAll('[data-bs-theme-value]').forEach(element => {
            element.classList.remove('active')
            element.querySelector('svg.bi.ms-auto').classList.add('d-none')
          })

          btnToActive.classList.add('active')
          btnToActive.querySelector('svg.bi.ms-auto').classList.remove('d-none')
          activeThemeIcon.setAttribute('href', svgOfActiveBtn)
          const themeSwitcherLabel = `Toggle theme (${btnToActive.dataset.bsThemeValue})`
          themeSwitcher.setAttribute('aria-label', themeSwitcherLabel)

          if (focus) {
            themeSwitcher.focus()
          }
        }

        window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', () => {
          const storedTheme = getStoredTheme()
          if (storedTheme !== 'light' && storedTheme !== 'dark') {
            setTheme(getPreferredTheme())
          }
        })

        window.addEventListener('DOMContentLoaded', () => {
          showActiveTheme(getPreferredTheme())

          document.querySelectorAll('[data-bs-theme-value]')
            .forEach(toggle => {
              toggle.addEventListener('click', () => {
                const theme = toggle.getAttribute('data-bs-theme-value')
                setStoredTheme(theme)
                setTheme(theme)
                showActiveTheme(theme, true)
              })
            })
        })
      })()
    </script>"""

        # Bootstrap offcanvas TOC sidebar (visible on large screens, offcanvas on mobile)
        toc_html = """
    <!-- TOC Sidebar (Bootstrap Offcanvas) -->
    <div class="offcanvas-lg offcanvas-start" data-bs-scroll="true" data-bs-backdrop="false" tabindex="-1" id="tocOffcanvas">
      <div class="offcanvas-header border-bottom d-lg-none">
        <h5 class="offcanvas-title fw-bold">Contents</h5>
        <button type="button" class="btn-close" data-bs-dismiss="offcanvas" aria-label="Close"></button>
      </div>
      <div class="offcanvas-body p-0 py-lg-3">
        <nav id="toc-nav" class="nav flex-column px-3 pt-2">
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

              // Close offcanvas after navigation (only on mobile)
              if (window.innerWidth < 992) {
                const offcanvasElement = document.getElementById('tocOffcanvas');
                const offcanvas = bootstrap.Offcanvas.getInstance(offcanvasElement);
                if (offcanvas) {
                  offcanvas.hide();
                }
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

        # TOC CSS (Bootstrap.com inspired)
        toc_css = """
    <style>
      /* Fixed navbar spacing */
      body {
        padding-top: 60px; /* Space for fixed navbar */
      }

      /* Navbar styling */
      .navbar {
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        z-index: 1030;
      }

      [data-bs-theme="dark"] .navbar {
        box-shadow: 0 2px 4px rgba(0,0,0,0.5);
      }

      /* Theme toggle button styling */
      #bd-theme {
        border: none !important;
        box-shadow: none !important;
      }

      #bd-theme:hover,
      #bd-theme:focus,
      #bd-theme:active {
        border: none !important;
        box-shadow: none !important;
        outline: none !important;
      }

      /* Make theme icons always white */
      #bd-theme svg,
      #bd-theme .theme-icon-active {
        fill: white;
        color: white;
      }

      /* Burger menu button styling - remove outline */
      .navbar .btn-outline-light.me-2 {
        border: none !important;
        box-shadow: none !important;
      }

      .navbar .btn-outline-light.me-2:hover,
      .navbar .btn-outline-light.me-2:focus,
      .navbar .btn-outline-light.me-2:active {
        border: none !important;
        box-shadow: none !important;
        outline: none !important;
      }

      /* Make navbar toggler icon visible */
      .navbar-toggler-icon {
        background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 30 30'%3e%3cpath stroke='rgba%28255, 255, 255, 0.85%29' stroke-linecap='round' stroke-miterlimit='10' stroke-width='2' d='M4 7h22M4 15h22M4 23h22'/%3e%3c/svg%3e");
      }

      /* Sidebar layout on large screens */
      @media (min-width: 992px) {
        #tocOffcanvas {
          position: fixed !important;
          top: 60px;
          left: 0;
          width: 280px;
          height: calc(100vh - 60px);
          border-right: 1px solid var(--bs-border-color);
          background: var(--bs-body-bg);
          overflow-y: auto;
          display: block !important;
          visibility: visible !important;
          transform: none !important;
        }

        /* Push main content to the right on large screens */
        body .container {
          margin-left: 280px !important;
          margin-right: 0 !important;
          max-width: calc(100% - 280px) !important;
        }
      }

      /* Mobile offcanvas styling */
      @media (max-width: 991.98px) {
        #tocOffcanvas {
          width: 280px;
        }
      }

      /* TOC link styling using Bootstrap colors */
      #toc-nav .nav-link {
        padding: 0.375rem 0;
        border-left: 2px solid transparent;
        padding-left: 1rem;
        transition: all 0.2s ease;
        margin-bottom: 0.125rem;
        color: var(--bs-body-color);
        font-size: 0.875rem;
      }

      #toc-nav .nav-link:hover {
        color: var(--bs-primary);
        border-left-color: var(--bs-primary);
      }

      #toc-nav .nav-link.active {
        color: var(--bs-primary);
        border-left-color: var(--bs-primary);
        font-weight: 600;
      }

      /* H3 links indented more */
      #toc-nav .nav-link.ms-3 {
        padding-left: 1.5rem;
        font-size: 0.8125rem;
      }

      /* Print: hide interactive elements */
      @media print {
        .navbar,
        #tocOffcanvas {
          display: none !important;
        }

        body {
          padding-top: 0 !important;
        }

        body .container {
          margin-left: 0 !important;
        }
      }
    </style>"""

        # Insert CSS before </head>
        if "</head>" in html_content:
            html_content = html_content.replace("</head>", f"{toc_css}\n  </head>", 1)

        # Insert JavaScript before Bootstrap JS
        scripts_to_insert = toc_js
        if theme_toggle and "theme_toggle_js" in locals():
            scripts_to_insert = theme_toggle_js + "\n" + toc_js

        if bootstrap_js in html_content:
            html_content = html_content.replace(
                bootstrap_js, f"{scripts_to_insert}\n{bootstrap_js}"
            )

        print("✅ Added Bootstrap navbar with burger menu")
        print("✅ Added Bootstrap offcanvas TOC sidebar (collapsible)")

    # Inject all body elements at once (after <body> tag)
    if body_injections:
        combined_injection = "".join(body_injections)
        if "<body>" in html_content:
            html_content = html_content.replace(
                "<body>", f"<body>{combined_injection}", 1
            )

    # Remove old emoji-based theme toggle button (if present from post-processing)
    # Remove the script that creates the toggle button with 🌓 emoji
    html_content = re.sub(
        r'<script>[\s\S]*?toggleBtn\.innerHTML\s*=\s*[\'"]🌓[\'"][\s\S]*?</script>',
        "",
        html_content,
    )
    # Remove the style tag for theme-toggle-btn (more specific pattern)
    html_content = re.sub(
        r"<style>\s*/\*\s*Theme toggle button styling\s*\*/[\s\S]*?\.theme-toggle-btn[\s\S]*?</style>",
        "",
        html_content,
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
        print("  --toc-sidebar:  Add Bootstrap offcanvas table of contents sidebar")
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
