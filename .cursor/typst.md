# Typst Documentation Guidelines

## Font Configuration

**ALWAYS use "Libertinus Serif" as the font** for Typst documents.

```typst
#set text(font: "Libertinus Serif", size: 11pt)
#set raw(font: "Libertinus Mono")  // For code blocks
```

## Standard Document Template

```typst
#set document(title: "Document Title", author: "Author Name", date: auto)
#set text(font: "Libertinus Serif", size: 11pt, lang: "en")
#set page(paper: "a4", margin: (x: 2.5cm, y: 2.5cm), numbering: "1")
#set par(justify: true, leading: 0.65em)
#set heading(numbering: "1.1")

// Title block
#align(center)[
  #text(size: 17pt, weight: "bold")[Document Title]
  #v(0.5em)
  #text(size: 12pt)[Author Name]
  #v(0.3em)
  #text(size: 10pt)[#datetime.today().display()]
]

#v(2em)

= Introduction

Your content here.
```

## Essential Syntax

### Headings and Text

```typst
= Level 1
== Level 2
=== Level 3

_italic_, *bold*, *_bold italic_*
#smallcaps[API]  // For acronyms
```

### Lists

```typst
- Unordered list
  - Nested item

+ Ordered list
  + Nested item

/ Term: Definition
```

### Code

```typst
Inline `code` with backticks.
```

Code blocks with language:

````typst
```python
def example():
    return True
```
````

### Mathematics

```typst
Inline: $E = m c^2$

Block:
$ E = m c^2 $ <eq:label>

Reference: See @eq:label
```

### Tables and Figures

**ALWAYS format tables like LaTeX booktabs** (top line, header line, bottom line):

```typst
// Table with booktabs-style formatting
#figure(
  table(
    columns: 3,
    stroke: none,
    table.hline(),
    [*Name*], [*Age*], [*City*],
    table.hline(),
    [Alice], [25], [NYC],
    [Bob], [30], [London],
    table.hline(),
  ),
  caption: [Data table]
) <tab:data>

// Image
#figure(
  image("path/to/image.png", width: 80%),
  caption: [Description]
) <fig:example>

// Reference figures/tables
See @fig:example and @tab:data for details.
```

### Links and References

```typst
#link("https://example.com")[Link text]

// Cross-references with labels
= Introduction <sec:intro>
As discussed in @sec:intro...

// Bibliography
#bibliography("references.bib")
In text: @smith2020 shows...
```

### Page Layout

```typst
// Headers/footers
#set page(
  header: [#smallcaps[Title] #h(1fr) #counter(heading).display()],
  footer: [#h(1fr) #counter(page).display()]
)

// Page breaks
#pagebreak()
#pagebreak(weak: true)  // Conditional

// Columns
#columns(2)[Content in two columns]
```

## Custom Functions

```typst
#let note(body) = rect(
  fill: rgb("#e8f4f8"),
  inset: 8pt,
  radius: 4pt,
  width: 100%
)[*Note:* #body]

#note[Important information]
```

## File Organization

```text
project/
├── main.typ
├── chapters/
│   ├── intro.typ
│   └── conclusion.typ
├── images/
└── references.bib
```

```typst
// Import and include
#import "template.typ": *
#include "chapters/intro.typ"
```

## Writing Style: One Sentence Per Line

For better git diffs and collaboration, write **one sentence per line**:

**Good:**

```typst
The experiment was conducted over three months.
Results showed significant improvement.
We observed a 42% increase in efficiency.
```

**Bad:**

```typst
The experiment was conducted over three months. Results showed significant improvement. We observed a 42% increase in efficiency.
```

**Why?** Git diffs show exactly which sentence changed, making code reviews and collaboration much easier.

**Exceptions - Don't break lines in:**

- Code blocks: ````python ... ````
- Math blocks: `$ ... $`
- Inline functions: `#link(...)[...]`, `#note[...]`
- Definition lists: `/ Term: Definition`
- Abbreviations: Dr., Prof., Fig., e.g., i.e., etc.
- URLs and paths

### Automatic Formatting with SemBr

Pre-commit hooks include **SemBr** (Semantic Line Breaks) with two modes:

**1. Automatic check (runs on commit):**

Warns if semantic line breaks are missing, but doesn't block commits:

```bash
git commit  # Will show warnings for .typ files
```

**2. Manual fix (run when needed):**

Auto-format a file with semantic line breaks:

```bash
# Format specific file
pre-commit run sembr-fix --files document.typ

# Review changes
git diff document.typ

# Accept or manually adjust, then commit
git add document.typ
git commit
```

**Important:** Always review SemBr's changes before accepting. It uses AI but may not handle all edge cases perfectly (especially math, code blocks, or technical abbreviations).

## Best Practices

**DO:**

- ✅ Use Libertinus Serif font
- ✅ Label all figures/tables with meaningful names
- ✅ Use cross-references (@labels), not hardcoded numbers
- ✅ Keep consistent heading hierarchy
- ✅ Add document metadata
- ✅ Write one sentence per line (prose sections)

**DON'T:**

- ❌ Mix different fonts unnecessarily
- ❌ Hardcode "Figure 1", "Table 2", etc.
- ❌ Use manual spacing instead of proper layout
- ❌ Forget to label important elements
- ❌ Put multiple sentences on one line (harder to review)

## Building Documents

```bash
# Compile to PDF
typst compile main.typ

# Watch mode (auto-recompile)
typst watch main.typ

# Specify output
typst compile main.typ output.pdf
```

## Pre-commit Hook

Typst syntax checking is **automatically enforced** via pre-commit hooks. Every `.typ` file is compiled to check for errors before commit.

```yaml
- id: typst-check
  name: Typst Syntax Check
  entry: bash -c 'for file in "$@"; do typst compile "$file" /dev/null || exit 1; done' --
  language: system
  files: '\.typ$'
```

This ensures all Typst documents compile without errors before they enter the repository.

## Checklist

Before committing:

- [ ] Font is "Libertinus Serif"
- [ ] All figures/tables labeled
- [ ] Cross-references use @labels
- [ ] Consistent heading hierarchy
- [ ] Document metadata complete
- [ ] Compiles without errors
