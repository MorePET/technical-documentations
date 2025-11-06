# Dark Mode Color Standards

## The Problem with Bright Dark Mode Colors

When dark mode colors are too bright or saturated, they cause:

- **Eye strain** - bright colors on dark backgrounds create excessive contrast
- **Visual fatigue** - high saturation is tiring to look at for extended periods
- **Poor readability** - bright backgrounds compete with white text
- **Unprofessional appearance** - looks amateurish compared to standard design systems

## Industry Standard Approach

Professional design systems (Material Design, GitHub, VS Code, Tailwind) follow these principles:

### 1. Lower Saturation

Dark mode colors should be **desaturated** compared to light mode:

- Light mode: Vibrant, saturated pastels
- Dark mode: Muted, lower saturation tones

### 2. Controlled Lightness

Dark mode backgrounds should stay in the **20-35% lightness range** (HSL):

- Too dark (<15%): Poor contrast with page background
- Too bright (>40%): Eye strain, competes with text
- Sweet spot (20-35%): Visible but comfortable

### 3. Sufficient Contrast

Must maintain readability:

- **Text on node**: At least 4.5:1 contrast ratio (WCAG AA)
- **Node vs background**: Distinguishable but not harsh
- **White text**: Works on all node colors

## Our Color Palette

### Light Mode (Unchanged)

Soft, vibrant pastels that work well on white backgrounds:

```text
Blue:    #cce3f7  (80% lightness, high saturation)
Green:   #ccf2cc  (soft mint)
Orange:  #f2dcc4  (warm beige)
Purple:  #e5ccf2  (light lavender)
Red:     #f2cccc  (soft pink)
Neutral: #f0f0f0  (very light gray)
```

### Dark Mode (Updated - Industry Standard)

Muted, darker tones inspired by Material Design & GitHub Dark:

```text
Blue:    #1e3a5f  (24% lightness, low saturation - deep slate)
Green:   #1e3d1e  (24% lightness - forest green)
Orange:  #4a3420  (24% lightness - warm brown)
Purple:  #3a2651  (24% lightness - deep purple)
Red:     #4a2020  (20% lightness - burgundy)
Neutral: #2d3748  (26% lightness - cool gray, from Tailwind)
```

## Color Selection Methodology

### Dark Mode Colors Were Chosen Based On

1. **Reference Systems**
   - **GitHub Dark**: Uses `#21262d` (15% L), `#30363d` (24% L) for surfaces
   - **Material Design**: Elevation 1 = `#1e1e1e`, Elevation 2 = `#272727`
   - **VS Code Dark+**: Background `#1e1e1e`, panels `#252526`
   - **Tailwind Gray**: `slate-700` = `#334155`, `slate-800` = `#1e293b`

2. **Lightness Target: 20-30%**
   - Stays visible against typical dark backgrounds (#0f1419 to #1e1e1e)
   - Doesn't compete with white text
   - Professional, easy on the eyes

3. **Saturation: Low to Medium**
   - Blue: ~50% saturation (was ~60%, too bright)
   - Colors are recognizable but not neon
   - Avoids the "RGB gamer aesthetic"

4. **Hue Adjustments**
   - Blue: Shifted slightly toward slate/navy for sophistication
   - Green: Deep forest green, not bright lime
   - Orange: Warm brown, professional
   - Purple: Deep amethyst, not bright magenta
   - Red: Burgundy/maroon, not fire engine red

## Testing Your Colors

To verify dark mode colors are appropriate:

### Visual Tests

1. **Squint test**: Blur your eyes - colors should be distinguishable but not glowing
2. **15-minute test**: Use dark mode for 15 minutes - should feel comfortable, not tiring
3. **Text contrast**: White text should be clearly readable on all node colors

### Technical Tests

```bash
# Check contrast ratios (example with online tools)
# White (#ffffff) on dark blue (#1e3a5f) = ~8:1 (Excellent)
# White (#ffffff) on dark green (#1e3d1e) = ~10:1 (Excellent)
```

### Comparison Test

Open these professional tools in dark mode for reference:

- GitHub: [github.com](https://github.com) (observe sidebar, cards)
- VS Code: Dark+ theme (observe sidebar, editor panels)
- Material Design: [m3.material.io](https://m3.material.io) (dark theme examples)

## When to Adjust Colors

### Signs colors are TOO BRIGHT

- ❌ Colors appear to "glow" or "pop out"
- ❌ Eyes feel strained after 5-10 minutes
- ❌ Colors look neon or "RGB gaming setup"
- ❌ Text is hard to read on the node backgrounds

### Signs colors are TOO DARK

- ❌ Can't distinguish between different node types
- ❌ Nodes blend into the page background
- ❌ Need to squint to see the diagram
- ❌ All colors look like shades of gray

### Signs colors are JUST RIGHT

- ✅ Comfortable to view for extended periods
- ✅ Each color is clearly identifiable
- ✅ Professional, polished appearance
- ✅ Similar feel to GitHub/VS Code/Material dark themes
- ✅ Text is highly readable
- ✅ Nodes stand out from background without being harsh

## Quick Reference: HSL Values

Our dark mode colors in HSL (Hue, Saturation, Lightness):

```text
Blue:    H:210° S:50% L:24%  (Cool, professional slate)
Green:   H:120° S:33% L:24%  (Forest green, not lime)
Orange:  H:30°  S:38% L:24%  (Warm brown, earthy)
Purple:  H:270° S:36% L:24%  (Deep amethyst)
Red:     H:0°   S:40% L:21%  (Burgundy, not bright red)
Neutral: H:210° S:20% L:26%  (Cool gray, from Tailwind)
```

Note: All stay in the 20-26% lightness range with moderate saturation (33-50%).

## Customization Tips

If you want to adjust colors:

1. **Keep lightness in 20-30% range** for dark mode backgrounds
2. **Reduce saturation** compared to light mode (aim for 30-50%)
3. **Test with white text** to ensure readability
4. **Reference professional tools** - if it looks like GitHub/VS Code, you're on track
5. **Use HSL color picker** - easier to control lightness than RGB/HEX

## Tools for Color Selection

- **Coolors.co**: Generate palettes, adjust HSL values
- **Contrast Checker**: WebAIM contrast checker for accessibility
- **Adobe Color**: Extract colors from professional interfaces
- **Browser DevTools**: Inspect GitHub/VS Code colors directly
- **Tailwind Color Palette**: Reference their carefully designed grays and colors
