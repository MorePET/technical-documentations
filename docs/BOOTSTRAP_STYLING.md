# Bootstrap Styling for Typst HTML Output

This document describes how to use Bootstrap 5 styling for Typst-generated HTML documents.

## Overview

The Bootstrap styling workflow provides a modern, responsive, and accessible design for Typst HTML exports. It includes:

- **Bootstrap 5.3.2**: Industry-standard CSS framework with responsive grid and components
- **Dark Mode Support**: Automatic system preference detection plus manual toggle
- **Responsive Tables**: Mobile-friendly table layouts that stack on small screens
- **Table of Contents**: Collapsible sidebar navigation using Bootstrap Offcanvas
- **Custom Enhancements**: Additional styling on top of Bootstrap for Typst-specific elements

## Quick Start

### Build HTML with Bootstrap

```bash
# Basic build
python3 scripts/build-html-bootstrap.py input.typ output.html

# Without theme toggle
python3 scripts/build-html-bootstrap.py input.typ output.html --no-theme-toggle

# Without TOC sidebar
python3 scripts/build-html-bootstrap.py input.typ output.html --no-toc

# Minimal (no theme toggle, no TOC)
python3 scripts/build-html-bootstrap.py input.typ output.html --no-theme-toggle --no-toc
```

### Using Makefile

```bash
# Build example with Bootstrap
make html-bootstrap

# Clean up generated files
make clean
```

## Files and Scripts

### Core Files

- **`lib/styles-bootstrap.css`**: Custom CSS that enhances Bootstrap for Typst output
- **`scripts/build-html-bootstrap.py`**: Main build script that orchestrates the entire workflow
- **`scripts/add-bootstrap-classes.py`**: Post-processor that adds Bootstrap classes to HTML elements
- **`scripts/add-styling-bootstrap.py`**: Injects Bootstrap CDN links, theme toggle, and TOC sidebar

### Build Workflow

The `build-html-bootstrap.py` script performs these steps:

1. **Compile**: Typst → HTML (requires `typst` command)
2. **Post-process**: Inject SVG diagrams inline
3. **Add Classes**: Apply Bootstrap classes to HTML elements
4. **Add Styling**: Include Bootstrap CDN, custom CSS, theme toggle, and TOC
5. **Fix Formatting**: Clean up trailing whitespace

## Bootstrap Classes Used

### Tables

All tables automatically receive:
- `table` - Base Bootstrap table styling
- `table-hover` - Row hover effects
- `table-bordered` - Bordered cells
- `table-primary` - Blue header background for first row

### Typography

- Headings get `mt-4 mb-3` for consistent spacing
- Links get `link-primary` for Bootstrap-styled links

### Layout

- Content is wrapped in `container py-4` for responsive centering
- Mobile breakpoints automatically adjust layout

## Dark Mode

### How It Works

Bootstrap 5.3+ includes built-in dark mode support using the `data-bs-theme` attribute:

- **Auto Mode** (default): Follows system preference via `prefers-color-scheme`
- **Light Mode**: `<html data-bs-theme="light">`
- **Dark Mode**: `<html data-bs-theme="dark">`

### Theme Toggle

The theme toggle button cycles through: Auto → Dark → Light → Auto

```javascript
// Theme preference is saved to localStorage
localStorage.getItem('theme') // 'light', 'dark', or null (auto)
```

### Custom Colors

Diagram colors (SVG elements) use custom CSS variables that adapt to the current theme:

```css
:root {
  --color-text: #000000;
  --color-stroke: #000000;
  /* ... more colors ... */
}

@media (prefers-color-scheme: dark) {
  :root {
    --color-text: #ffffff;
    --color-stroke: #ffffff;
    /* ... dark mode colors ... */
  }
}

[data-bs-theme='dark'] {
  /* Manual dark mode overrides */
}
```

## Table of Contents Sidebar

### Desktop (≥992px)

- Always visible on the left side
- Body content shifts right to accommodate sidebar
- Smooth scrolling to sections
- Active section highlighting

### Mobile (<992px)

- Hidden by default
- Floating button (📋) in bottom-left corner to open
- Slides in as Bootstrap Offcanvas
- Automatically closes after clicking a link

### Features

- **Auto-generated**: Extracts all `<h2>` and `<h3>` headings
- **Smooth Scroll**: Animated scrolling to sections
- **Active Highlighting**: Current section highlighted in blue
- **Collapsible**: Can be hidden on desktop to maximize content space

## Customization

### Modify Colors

Edit `lib/styles-bootstrap.css`:

```css
:root {
  --bs-primary: #2563eb;        /* Change primary color */
  --bs-primary-rgb: 37, 99, 235; /* RGB version for opacity */
  --custom-border-radius: 8px;   /* Adjust border radius */
}
```

### Disable Features

```bash
# No theme toggle
python3 scripts/build-html-bootstrap.py input.typ output.html --no-theme-toggle

# No TOC sidebar
python3 scripts/build-html-bootstrap.py input.typ output.html --no-toc

# Both disabled
python3 scripts/build-html-bootstrap.py input.typ output.html --no-theme-toggle --no-toc
```

### Use Local Bootstrap

By default, Bootstrap is loaded from CDN. To use a local copy:

1. Download Bootstrap from https://getbootstrap.com
2. Save to `lib/bootstrap/`
3. Edit `scripts/add-styling-bootstrap.py` to reference local files

## Responsive Design

### Breakpoints

Bootstrap uses these breakpoints:

- **XS** (<576px): Extra small devices (phones)
- **SM** (≥576px): Small devices (phones, landscape)
- **MD** (≥768px): Medium devices (tablets)
- **LG** (≥992px): Large devices (desktops)
- **XL** (≥1200px): Extra large devices (large desktops)

### Mobile Optimizations

- Tables stack vertically on small screens
- TOC sidebar becomes an offcanvas drawer
- Theme toggle button scales down
- Reduced padding and margins

## Comparison with Custom Styling

| Feature | Custom CSS | Bootstrap |
|---------|------------|-----------|
| **File Size** | Smaller (custom only) | Larger (full framework) |
| **Features** | Minimal, specific | Comprehensive |
| **Customization** | Easy (full control) | Moderate (via variables) |
| **Browser Support** | Modern only | Excellent |
| **Responsive Grid** | Manual | Built-in |
| **Components** | Limited | Extensive |
| **Community** | None | Large |
| **Updates** | Manual | Regular releases |

## Best Practices

1. **Load Order**: Bootstrap CSS → Custom CSS → Bootstrap JS
2. **CDN vs Local**: Use CDN for faster initial load, local for offline access
3. **Customization**: Override Bootstrap via custom CSS, don't modify Bootstrap files
4. **Accessibility**: Bootstrap includes ARIA attributes and keyboard navigation
5. **Mobile First**: Design for mobile, enhance for desktop

## Troubleshooting

### Tables Not Styled

- Check that `table` class was added: `<table class="table table-hover table-bordered">`
- Verify Bootstrap CSS is loaded before custom CSS
- Check browser console for CSS errors

### Dark Mode Not Working

- Verify `data-bs-theme` attribute is on `<html>` element
- Check that theme toggle JavaScript loaded correctly
- Clear localStorage: `localStorage.clear()`

### TOC Sidebar Not Visible

- Check that headings have IDs: `<h2 id="heading-1">`
- Verify Bootstrap JS is loaded (required for Offcanvas)
- Check browser console for JavaScript errors

### Bootstrap Not Loading from CDN

- Check internet connection
- Verify CDN URLs are correct in HTML
- Try using local Bootstrap files instead

## Further Reading

- [Bootstrap Documentation](https://getbootstrap.com/docs/5.3/)
- [Bootstrap Dark Mode](https://getbootstrap.com/docs/5.3/customize/color-modes/)
- [Bootstrap Tables](https://getbootstrap.com/docs/5.3/content/tables/)
- [Bootstrap Offcanvas](https://getbootstrap.com/docs/5.3/components/offcanvas/)
