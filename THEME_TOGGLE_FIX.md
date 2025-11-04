# Theme Toggle Fix - Making Diagrams Respond to Manual Theme Switching

## Problem

The diagrams were not changing colors when users clicked the theme toggle button (🌓). They only responded to the system's color scheme preference (`prefers-color-scheme`), not to the manual `data-theme` attribute.

## Root Cause

The CSS embedded in the SVGs only had `@media (prefers-color-scheme: dark)` rules, which respond to the OS/browser theme setting. The theme toggle button sets `data-theme="dark"` on the `<body>` element, but this wasn't being respected.

Additionally, when the CSS was embedded inside each SVG's `<style>` tag, the attribute selectors like `[data-theme='dark']` couldn't see the parent document's `<body>` element where the attribute was set.

## Solution

### 1. Updated CSS Generation (`build-colors.py`)

Added three layers of dark mode support:
```css
/* Layer 1: Default light mode */
:root {
  --color-stroke: #000000;
  --color-text: #000000;
  /* ... */
}

/* Layer 2: System dark mode preference */
@media (prefers-color-scheme: dark) {
  :root {
    --color-stroke: #ffffff;
    --color-text: #ffffff;
    /* ... */
  }
}

/* Layer 3: Manual dark toggle */
[data-theme='dark'] {
  --color-stroke: #ffffff;
  --color-text: #ffffff;
  /* ... */
}

/* Layer 4: Manual light toggle (overrides system dark) */
[data-theme='light'] {
  --color-stroke: #000000;
  --color-text: #000000;
  /* ... */
}
```

### 2. Moved CSS from SVGs to HTML Head (`post-process-html.py`)

Instead of embedding CSS in each SVG:
- Inline the complete `colors.css` into the HTML `<head>` section
- This makes the CSS variables available at the document level
- Embedded SVGs inherit these variables from the parent document
- The `[data-theme]` selectors can now see the `<body>` attribute

### 3. Simplified SVG Processing (`build-diagrams.py`)

Removed CSS embedding from SVGs:
- SVGs now only use `var(--color-*)` references
- No embedded `<style>` tags in SVGs
- Variables inherit from parent HTML document

### 4. Protected Colors CSS in Styling Script (`add-styling.py`)

Modified to preserve the inlined diagram colors CSS:
- Extracts diagram colors CSS before removing old styles
- Restores it after cleaning
- Ensures colors.css isn't accidentally removed

## How It Works Now

1. **Page Loads**: Default `:root` CSS variables are active (light mode)
2. **System Dark Mode**: `@media (prefers-color-scheme: dark)` activates automatically
3. **User Clicks Toggle**: JavaScript sets `data-theme="dark"` on `<body>`
4. **CSS Responds**: `[data-theme='dark']` selector activates, overriding defaults
5. **SVGs Update**: Inline SVG elements using `var(--color-*)` instantly reflect new values
6. **Text & Arrows**: Switch from black to white
7. **Node Fills**: Switch to darker, muted tones

## Theme Priorities (Cascade Order)

1. `:root` (base - light mode)
2. `@media (prefers-color-scheme: dark)` (system preference)
3. `[data-theme='dark']` (manual dark - highest priority)
4. `[data-theme='light']` (manual light - overrides system dark)

## Files Modified

1. `/workspace/build-colors.py` - Generate CSS with `[data-theme]` selectors
2. `/workspace/post-process-html.py` - Inline colors.css in HTML head
3. `/workspace/build-diagrams.py` - Remove CSS embedding from SVGs
4. `/workspace/add-styling.py` - Preserve diagram colors when adding page styles

## Testing

To verify:
```bash
# Rebuild everything
python3 build-colors.py
python3 build-diagrams.py
python3 build-html.py technical-doc-example.typ technical-doc-example.html
```

In a browser:
1. Open `technical-doc-example.html`
2. Click the theme toggle button (🌓)
3. **Expected**: Diagrams instantly change colors
   - Light mode: Black arrows/text, soft pastel fills
   - Dark mode: White arrows/text, muted darker fills

## Key Insight

CSS variables DO inherit into inline SVGs from the parent document, but attribute selectors like `[data-theme='dark']` only match elements in the same DOM scope. By moving the CSS to the HTML `<head>` (parent document level) and having SVGs reference the variables, the theme toggle can control both page styling AND embedded diagram colors.


