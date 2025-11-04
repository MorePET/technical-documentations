#!/usr/bin/env python3
"""
Script to add CSS styling to Typst HTML exports with optional dark mode toggle.
Usage: python add-styling.py input.html [output.html] [--inline] [--theme-toggle]
"""

import sys
import re
from pathlib import Path


def add_css_to_html(input_file, output_file=None, css_file="styles.css", inline=False, force=False, theme_toggle=False):
    """
    Add CSS link or inline styles to an HTML file with optional theme toggle.
    
    Args:
        input_file: Path to input HTML file
        output_file: Path to output HTML file (default: replace input)
        css_file: Path to CSS file to link or embed
        inline: If True, embed CSS inline; if False, add external link
        force: If True, skip confirmation prompts
        theme_toggle: If True, add dark mode toggle button
    """
    input_path = Path(input_file)
    output_path = Path(output_file) if output_file else input_path
    css_path = Path(css_file)
    
    # Read the HTML
    html_content = input_path.read_text(encoding='utf-8')
    
    # Check if styling already exists
    if '<link rel="stylesheet"' in html_content or '<style>' in html_content:
        if not force:
            print("⚠️  Styling already exists in the HTML file.")
            try:
                response = input("Do you want to replace it? (y/n): ")
                if response.lower() != 'y':
                    print("Aborted.")
                    return
            except EOFError:
                # Non-interactive mode, skip
                pass
        # Remove existing style/link tags
        html_content = re.sub(r'<link[^>]*rel="stylesheet"[^>]*>', '', html_content)
        html_content = re.sub(r'<style>.*?</style>', '', html_content, flags=re.DOTALL)
    
    if inline:
        # Inline CSS
        if not css_path.exists():
            print(f"❌ CSS file not found: {css_path}")
            sys.exit(1)
        
        css_content = css_path.read_text(encoding='utf-8')
        style_tag = f"\n    <style>\n{css_content}\n    </style>"
        
        # Insert before </head> or after <head>
        if '</head>' in html_content:
            html_content = html_content.replace('</head>', f'{style_tag}\n  </head>')
        elif '<head>' in html_content:
            html_content = html_content.replace('<head>', f'<head>{style_tag}')
        else:
            # Add head section if it doesn't exist
            html_content = html_content.replace('<html>', f'<html>\n  <head>{style_tag}\n  </head>')
        
        print(f"✅ Embedded CSS inline")
    else:
        # External link
        # Use relative path
        css_relative = css_path.name
        link_tag = f'\n    <link rel="stylesheet" href="{css_relative}">'
        
        # Insert before </head> or after <head>
        if '</head>' in html_content:
            html_content = html_content.replace('</head>', f'{link_tag}\n  </head>')
        elif '<head>' in html_content:
            html_content = html_content.replace('<head>', f'<head>{link_tag}')
        else:
            # Add head section if it doesn't exist
            html_content = html_content.replace('<html>', f'<html>\n  <head>{link_tag}\n  </head>')
        
        print(f"✅ Added link to {css_relative}")
    
    # Add theme toggle if requested
    if theme_toggle:
        # Theme toggle button HTML
        toggle_html = '''
    <button class="theme-toggle" onclick="toggleTheme()" aria-label="Toggle theme">
      <span id="theme-icon">🌓</span> Theme
    </button>'''
        
        # Theme toggle JavaScript
        toggle_js = '''
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
        
        if (current === 'dark') {
          // Dark → Light
          body.setAttribute('data-theme', 'light');
          localStorage.setItem('theme', 'light');
          updateIcon('light');
        } else if (current === 'light') {
          // Light → Auto
          body.removeAttribute('data-theme');
          localStorage.removeItem('theme');
          updateIcon('auto');
        } else {
          // Auto → Opposite of system
          const isDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
          const newTheme = isDark ? 'light' : 'dark';
          body.setAttribute('data-theme', newTheme);
          localStorage.setItem('theme', newTheme);
          updateIcon(newTheme);
        }
      }
      
      function updateIcon(theme) {
        if (theme === 'light') {
          icon.textContent = '☀️';
        } else if (theme === 'dark') {
          icon.textContent = '🌙';
        } else {
          icon.textContent = '🌓';
        }
      }
    </script>'''
        
        # Theme toggle CSS
        toggle_css = '''
    <style>
      /* Theme Toggle Button */
      .theme-toggle {
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 0.7rem 1.2rem;
        background: var(--primary-color, #3b82f6);
        color: white;
        border: none;
        border-radius: 8px;
        font-size: 0.9rem;
        font-weight: 600;
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
          padding: 0.6rem 1rem;
          font-size: 0.85rem;
        }
      }
    </style>'''
        
        # Insert toggle button after <body>
        if '<body>' in html_content:
            html_content = html_content.replace('<body>', f'<body>{toggle_html}')
        else:
            # Fallback: add after html tag
            html_content = html_content.replace('<html>', f'<html><body>{toggle_html}')
        
        # Insert CSS before </head> or at the beginning
        if '</head>' in html_content:
            html_content = html_content.replace('</head>', f'{toggle_css}\n  </head>')
        elif '<head>' in html_content:
            html_content = html_content.replace('<head>', f'<head>{toggle_css}')
        else:
            # Add head if it doesn't exist
            html_content = html_content.replace('<html>', f'<html>\n  <head>{toggle_css}\n  </head>')
        
        # Insert JavaScript before </body> or at the end
        if '</body>' in html_content:
            html_content = html_content.replace('</body>', f'{toggle_js}\n  </body>')
        else:
            # Fallback: add before </html>
            html_content = html_content.replace('</html>', f'{toggle_js}\n</html>')
        
        print(f"✅ Added dark mode toggle button")
    
    # Write the modified HTML
    output_path.write_text(html_content, encoding='utf-8')
    
    print(f"✅ Styled HTML saved to: {output_path}")
    print(f"\n💡 Open {output_path} in your browser to see the result!")
    if theme_toggle:
        print(f"🌓 Click the theme button in the top-right corner to switch between light/dark/auto modes!")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python add-styling.py input.html [output.html] [--inline] [--force] [--theme-toggle]")
        print("Example: python add-styling.py stakeholder-example.html --theme-toggle")
        print("  --inline:       Embed CSS directly (default: external link)")
        print("  --force:        Skip confirmation prompts")
        print("  --theme-toggle: Add dark mode toggle button in top-right corner")
        sys.exit(1)
    
    # Parse arguments
    args = sys.argv[1:]
    inline = '--inline' in args
    force = '--force' in args
    theme_toggle = '--theme-toggle' in args
    
    # Remove flags from args
    file_args = [arg for arg in args if not arg.startswith('--')]
    
    input_file = file_args[0]
    output_file = file_args[1] if len(file_args) > 1 else None
    
    add_css_to_html(input_file, output_file, inline=inline, force=force, theme_toggle=theme_toggle)

