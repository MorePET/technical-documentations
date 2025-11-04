# Quick Start - Styling Your Typst HTML Exports

## ✅ Setup Complete!

Your stakeholder analysis HTML now has professional styling! Here's what we've created:

## 📁 Files Created

1. **`styles.css`** - Modern light theme with blue accents
2. **`styles-dark.css`** - Dark mode version (optional)
3. **`add-styling.py`** - Automatic styling script
4. **`build.sh`** - Simple build script
5. **`Makefile`** - Advanced build system
6. **`stakeholder-example.html`** - Your HTML (now styled!)

## 🚀 How to Use

### Quick Method - Just Apply Styling

Since your Typst installation needs HTML export enabled, you can:

1. **Export HTML from Typst** (using your method)
2. **Apply styling:**
   ```bash
   python add-styling.py your-file.html --force
   ```
3. **Open in browser** to see the styled result!

### Using the Build Script

The build script will:
- Try to compile Typst → HTML
- If that fails, use existing HTML file
- Apply CSS styling automatically

```bash
./build.sh stakeholder-example
```

### Using Make

```bash
make                    # Style existing HTML
make inline            # Create single-file version
```

## 🎨 Styling Options

### Option 1: Light Theme (Default) ✨

```bash
python add-styling.py stakeholder-example.html --force
```

**Result:** Clean, professional look with blue gradient headers and modern spacing.

### Option 2: Dark Theme 🌙

Edit `stakeholder-example.html` and change the CSS link from:
```html
<link rel="stylesheet" href="styles.css">
```

To:
```html
<link rel="stylesheet" href="styles-dark.css">
```

**Result:** Dark background with glowing effects and blue accents.

### Option 3: Inline CSS (Single File) 📦

```bash
python add-styling.py stakeholder-example.html --inline --force
```

**Result:** Everything embedded in one HTML file (perfect for sharing).

## 🎯 What Changed?

### Before (Plain HTML Export)
- ❌ No colors
- ❌ Basic borders
- ❌ Cramped layout
- ❌ Plain bullets
- ❌ Not mobile-friendly

### After (With CSS)
- ✅ Blue gradient headers
- ✅ Hover effects on table rows
- ✅ Proper spacing and shadows
- ✅ Styled bullet points with brand colors
- ✅ Fully responsive (works on mobile!)
- ✅ Professional typography
- ✅ Print-optimized

## 📱 View Your Styled HTML

Open `stakeholder-example.html` in your browser to see the transformation!

**Compare:**
- `stakeholder-example-styled.html` - External CSS version
- Open both and see the difference!

## 🔄 Your Workflow

When you update your Typst document:

```bash
# 1. Export to HTML (your method)
# ... export from Typst ...

# 2. Apply styling
python add-styling.py stakeholder-example.html --force

# 3. Open in browser
xdg-open stakeholder-example.html  # or just double-click
```

Or use the build script:
```bash
./build.sh stakeholder-example
```

## ✏️ Customization

### Change Colors

Edit `styles.css` line 4:
```css
--primary-color: #2563eb;  /* Change to your brand color */
```

Try:
- `#ef4444` - Red
- `#10b981` - Green  
- `#8b5cf6` - Purple
- `#f59e0b` - Orange

### Change Layout

Edit column widths in `styles.css`:
```css
table td:first-child { width: 15%; }  /* Stakeholder column */
table td:nth-child(2) { width: 28%; } /* Pain column */
/* etc */
```

## 💡 Tips

### For Presentations
- Use the styled HTML
- Press F11 in browser for fullscreen
- Use browser zoom (Ctrl +/-) to adjust size

### For Sharing
```bash
# Single file (easiest):
python add-styling.py stakeholder-example.html --inline --force

# Or share both files:
# - stakeholder-example.html
# - styles.css
```

### For Printing/PDF
- Open styled HTML in browser
- Print to PDF (Ctrl+P)
- Styling is preserved!

### Switch Between Light and Dark Mode

**Manual Method:**
Edit the HTML file's `<link>` tag to point to `styles-dark.css` or `styles.css`

**Script Method (Future Enhancement):**
You could create a toggle button with a bit of JavaScript!

## 📚 More Information

- **Complete guide:** `STYLING-GUIDE.md`
- **Project overview:** `README.md`
- **CSS comments:** Check `styles.css` for inline documentation

## 🎉 You're Done!

Your stakeholder analysis now has professional styling. Just open `stakeholder-example.html` in your browser to see the result!

Need help? Check the other documentation files or customize the CSS to your liking!

