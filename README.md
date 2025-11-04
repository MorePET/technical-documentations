# Stakeholder Analysis - Typst with HTML Styling

Beautiful, modern HTML exports from Typst documents with professional CSS styling - **now with native Typst integration!**

> **⚠️ Note:** HTML export requires Typst compiled with `--features html` (experimental). PDF export works perfectly. See `HTML-EXPORT-SETUP.md` for details.

## 📋 Overview

This project demonstrates how to create stunning HTML exports from Typst documents with **automatic CSS styling built right into your Typst template**. No post-processing needed!

### What's Included

- **📄 Typst Source**: `stakeholder-example.typ` - Source document
- **🎨 CSS Stylesheet**: `styles.css` - Modern, responsive styling
- **🤖 Automation Script**: `add-styling.py` - Auto-apply CSS to HTML exports
- **🔧 Build Tools**: `build.sh` and `Makefile` - Streamlined workflow
- **📖 Documentation**: `STYLING-GUIDE.md` - Complete styling guide

### Examples

- `stakeholder-example.html` - Plain Typst HTML export
- `stakeholder-example-styled.html` - Styled version with CSS

## 🚀 Quick Start

### Method 1: Native Typst Integration (Recommended ⭐)

The CSS styling is now **built into the template**! Just export:

```typst
// In your .typ file:
#import "technical-documentation-package.typ": *
#show: tech-doc  // Automatically includes CSS!

= Your Document
```

Then export:
```bash
typst compile --format html stakeholder-example.typ
```

**That's it!** The HTML will automatically include the CSS link.

**Dark Mode?** Already included! The CSS automatically switches between light and dark modes based on the viewer's browser/system preference using `prefers-color-scheme`. No special configuration needed!

**Want an Interactive Toggle?** Add one line for presentations/demos:
```typst
#show: tech-doc.with(html-theme-toggle: true)
```
This adds a floating button to switch themes instantly! See `THEME-TOGGLE-GUIDE.md` for details.

**Use Inline CSS (single file):**
```typst
#show: tech-doc.with(html-inline-css: read("styles.css"))
```

See `AUTO-DARK-MODE.md` to learn about the automatic theme switching, `THEME-TOGGLE-GUIDE.md` for the interactive toggle, or `TYPST-HTML-STYLING.md` for complete documentation.

### Method 2: Using Build Scripts (Alternative)

If you prefer post-processing:

**Option A: Build Script**
```bash
./build.sh stakeholder-example
```

**Option B: Make**
```bash
make
# or
make FILE=stakeholder-example
```

**Option C: Manual**
```bash
# 1. Export from Typst
typst compile --format html stakeholder-example.typ

# 2. Apply styling
python add-styling.py stakeholder-example.html --force

# 3. Open in browser
xdg-open stakeholder-example.html  # Linux
# or just open the file manually
```

## 🎨 Styling Features

The CSS provides:

- ✨ **Modern Design**: Clean, professional look with subtle gradients and shadows
- 🌓 **Automatic Dark Mode**: Switches based on browser/system preference using `prefers-color-scheme`
- 📊 **Enhanced Tables**: 
  - Color-coded header row (blue gradient)
  - Hover effects on rows
  - Smooth transitions
  - Proper spacing and borders
- 📱 **Responsive Layout**: Automatically adapts to mobile, tablet, and desktop
- 🖨️ **Print-Optimized**: Looks great when printing to PDF
- ♿ **Accessible**: High contrast ratios and readable fonts
- 🎯 **Professional Typography**: Modern font stack with proper hierarchy
- 🔧 **DRY & SOLID**: Single CSS file with variables, no duplicate code

### Before and After

| Plain HTML Export | With CSS Styling |
|-------------------|------------------|
| No colors | Blue gradient headers |
| Basic borders | Subtle shadows and spacing |
| Cramped layout | Breathing room with proper padding |
| Plain bullets | Styled with brand colors |
| Not mobile-friendly | Fully responsive |

## 🔧 Customization

### Quick Color Change

Edit `styles.css`:

```css
:root {
  --primary-color: #2563eb;  /* Change to your brand color */
  --text-color: #1f2937;
  /* ... more variables ... */
}
```

### Column Width Adjustment

```css
table td:first-child { width: 15%; }  /* Stakeholder column */
table td:nth-child(2) { width: 28%; } /* Pain column */
table td:nth-child(3) { width: 28%; } /* Promise column */
table td:nth-child(4) { width: 29%; } /* Proof column */
```

See `STYLING-GUIDE.md` for detailed customization options.

## 📦 Build Options

### Build Script (`build.sh`)

Simple bash script for quick builds:

```bash
./build.sh                    # Build default file
./build.sh my-document       # Build specific file
```

### Makefile

More powerful build system:

```bash
make                         # Build default file
make FILE=my-document        # Build specific file
make inline                  # Build with inline CSS
make all-files              # Build all .typ files
make clean                  # Remove generated HTML
make watch                  # Watch and rebuild on changes
make open                   # Build and open in browser
make help                   # Show all commands
```

## 🔄 Workflow Recommendations

### For Development

Use watch mode to see changes in real-time:

```bash
make watch
```

Then edit your `.typ` file and save. The HTML will auto-rebuild.

### For Distribution

**Single File (Inline CSS):**
```bash
make inline
```
This creates one self-contained HTML file.

**Two Files (External CSS):**
```bash
make
```
Distribute both `.html` and `styles.css` together.

### For Version Control

Add to `.gitignore`:
```
*.html
```

Keep in git:
```
*.typ
styles.css
add-styling.py
build.sh
Makefile
```

## 📱 Responsive Design

The CSS automatically adapts:

- **Desktop (>1024px)**: Full 4-column table layout
- **Tablet (768-1024px)**: Smaller fonts, adjusted spacing
- **Mobile (<768px)**: Stacked layout, hidden table headers

Test responsive design:
1. Open HTML in browser
2. Press `F12` (Developer Tools)
3. Click device toolbar icon
4. Select different device sizes

## 🎯 Use Cases

This setup is perfect for:

- 📊 **Stakeholder Analysis** (like this example)
- 📈 **Business Reports** with tables and data
- 📝 **Technical Documentation** 
- 🎓 **Academic Papers** with structured content
- 📋 **Requirements Documents**
- 💼 **Project Proposals**

## 🛠️ Requirements

- **Typst**: For compiling `.typ` to HTML ([install](https://github.com/typst/typst))
- **Python 3**: For the styling script (usually pre-installed on Linux)
- **Make** (optional): For using the Makefile (usually pre-installed on Linux)

Check installation:
```bash
typst --version
python --version
make --version
```

## 💡 Tips & Tricks

### Sharing with Others

**Option A:** Email/Upload
- Use inline CSS: `make inline`
- Share the single HTML file

**Option B:** Web Hosting
- Upload both HTML and CSS to a web server
- Share the URL

**Option C:** Convert to PDF
- Open HTML in browser
- Print to PDF (maintains styling)

### Multiple Documents

Build all documents at once:
```bash
make all-files
```

### Custom Build Commands

Add your own targets to the Makefile:
```makefile
.PHONY: deploy
deploy: all
	rsync -av *.html *.css user@server:/path/
```

## 📚 Documentation

- **`STYLING-GUIDE.md`**: Complete guide to styling options
- **`styles.css`**: Commented CSS with customization notes
- **`Makefile`**: All available build commands

## 🤝 Contributing

Feel free to customize the CSS, scripts, and build tools for your needs!

### Ideas for Enhancement

- 🌙 Add dark mode toggle
- 📊 Add Chart.js for data visualization
- 🔍 Add table filtering/sorting with JavaScript
- 📱 Add mobile-specific interactions
- 🎨 Create multiple theme variants
- 🔗 Add table of contents generation

## 📄 License

Use freely for your projects!

## 🙏 Acknowledgments

- Built with [Typst](https://github.com/typst/typst) - Modern markup-based typesetting
- Styled with modern CSS best practices
- Inspired by clean, professional web design

---

**Questions?** Check `STYLING-GUIDE.md` or customize the files to suit your needs!
