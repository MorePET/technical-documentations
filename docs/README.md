# Technical Documentation Project

This is your main workspace for creating technical documentation.

## Getting Started

1. **Edit the main document**: `technical-documentation.typ`
2. **Add diagrams**: Create `.typ` files in the `diagrams/` folder
3. **Build**: Run `make` from the workspace root
4. **View**: Open `technical-documentation.pdf` or `technical-documentation.html`

## Available Functions

Import from the package:

```typst
#import "../lib/technical-documentation-package.typ": (
  tech-doc,
  architecture-diagram,
  data-flow-diagram,
  state-diagram
)
```

### Diagram Functions

- `#architecture-diagram()` - System architecture diagrams
- `#data-flow-diagram()` - Data flow diagrams
- `#state-diagram()` - State machine diagrams

### Creating Custom Diagrams

Create a new file in `diagrams/`, for example `diagrams/my-diagram.typ`:

```typst
#import "../../lib/generated/colors.typ": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node

#set page(width: auto, height: auto, margin: 1em, fill: none)

#align(center)[
  #diagram(
    node-stroke: 1pt,
    node-fill: node-bg-blue,
    spacing: 5em,
    edge-stroke: 1pt,
    node-corner-radius: 5pt,
    label-sep: 5pt,

    node((0, 0), [Component A]),
    node((1, 0), [Component B]),
    edge((0, 0), (1, 0), [Connection], "->", label-pos: 0.5),
  )
]
```

## Building

From the workspace root:

```bash
make                  # Build this project (default)
make pdf              # Just PDF
make html             # Just HTML
make diagrams         # Just compile diagrams
make clean            # Remove build artifacts
```

## Directory Structure

```text
technical-documentation/
├── README.md                           (this file)
├── technical-documentation.typ         (main document)
└── diagrams/                          (diagram source files)
    └── *.typ                          (create diagrams here)
```

## Example Reference

See the `example/` folder for a complete reference with three diagram examples:

- System Architecture
- Data Flow
- State Machine

## Dark Mode

HTML output automatically supports dark mode:

- System preference detection
- Manual toggle button (top-right)
- All diagrams switch colors automatically

## Tips

1. **Colors**: Edit `lib/colors.json` to change the color palette for all projects
2. **Styles**: Edit `lib/styles-bootstrap.css` for HTML styling (Bootstrap-based)
3. **Package**: Edit `lib/technical-documentation-package.typ` to add new functions
4. **Multiple Projects**: Create new folders at the workspace root and use `./scripts/build-all.sh <folder-name>`

## Need Help?

- Run `make help` for all available commands
- Check `example/` for working diagram examples
- See `docs/` for detailed documentation on the build system
