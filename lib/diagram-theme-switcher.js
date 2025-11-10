/**
 * Diagram Theme Switcher
 * 
 * Dynamically recolors inline SVG diagrams based on Bootstrap theme changes.
 * Works with diagrams generated via html.frame that use colors from colors.json.
 * 
 * How it works:
 * 1. Diagrams are rendered with light theme colors by default
 * 2. This script creates a mapping from light colors to CSS variable names
 * 3. On theme change, it finds all SVG elements and updates their colors
 * 4. Colors are read from CSS variables that change based on data-bs-theme
 */

(function() {
  'use strict';

  // Light theme color mapping (from colors.json light values to CSS variables)
  const LIGHT_COLOR_MAP = {
    '#000000': '--color-text',        // text
    '#ffffff': '--color-gradient-start', // white backgrounds
    '#cfe2ff': '--color-node-bg-blue',
    '#e7f1ff': '--color-node-bg-blue-light',
    '#d1e7dd': '--color-node-bg-green',
    '#ffe5d0': '--color-node-bg-orange',
    '#e2d9f3': '--color-node-bg-purple',
    '#f8d7da': '--color-node-bg-red',
    '#e9ecef': '--color-node-bg-neutral',
    '#9ec5fe': '--color-gradient-end-blue',
  };

  // Normalize color strings to lowercase hex for consistent comparison
  function normalizeColor(color) {
    if (!color) return null;
    color = color.trim().toLowerCase();
    
    // Convert rgb(r, g, b) to hex
    const rgbMatch = color.match(/^rgb\s*\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)$/i);
    if (rgbMatch) {
      const r = parseInt(rgbMatch[1]).toString(16).padStart(2, '0');
      const g = parseInt(rgbMatch[2]).toString(16).padStart(2, '0');
      const b = parseInt(rgbMatch[3]).toString(16).padStart(2, '0');
      return `#${r}${g}${b}`;
    }
    
    return color;
  }

  // Get CSS variable value from computed styles
  function getCSSVariableValue(varName) {
    const value = getComputedStyle(document.documentElement)
      .getPropertyValue(varName)
      .trim();
    return value || null;
  }

  // Recolor a single SVG element
  function recolorSVG(svg) {
    // Find all elements with fill or stroke attributes
    const elements = svg.querySelectorAll('[fill], [stroke]');
    
    elements.forEach(element => {
      // Process fill attribute
      const fill = element.getAttribute('fill');
      if (fill && fill !== 'none') {
        const normalizedFill = normalizeColor(fill);
        const cssVar = LIGHT_COLOR_MAP[normalizedFill];
        
        if (cssVar) {
          const newColor = getCSSVariableValue(cssVar);
          if (newColor) {
            element.setAttribute('fill', newColor);
          }
        }
      }
      
      // Process stroke attribute
      const stroke = element.getAttribute('stroke');
      if (stroke && stroke !== 'none') {
        const normalizedStroke = normalizeColor(stroke);
        const cssVar = LIGHT_COLOR_MAP[normalizedStroke];
        
        if (cssVar) {
          const newColor = getCSSVariableValue(cssVar);
          if (newColor) {
            element.setAttribute('stroke', newColor);
          }
        }
      }
    });
  }

  // Recolor all SVG diagrams in the document
  function recolorAllDiagrams() {
    // Find all SVG elements (typically within figures)
    const svgs = document.querySelectorAll('figure svg, svg');
    
    svgs.forEach(svg => {
      recolorSVG(svg);
    });
    
    console.log(`Diagram theme switcher: Recolored ${svgs.length} SVG diagram(s)`);
  }

  // Initialize on page load
  function init() {
    // Wait for DOM to be ready
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', init);
      return;
    }
    
    // Apply initial coloring
    recolorAllDiagrams();
    
    // Watch for theme changes on the document element
    const observer = new MutationObserver(mutations => {
      mutations.forEach(mutation => {
        if (mutation.type === 'attributes' && 
            (mutation.attributeName === 'data-bs-theme' || 
             mutation.attributeName === 'data-theme')) {
          // Theme changed, recolor diagrams
          setTimeout(recolorAllDiagrams, 10); // Small delay to ensure CSS vars are updated
        }
      });
    });
    
    observer.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ['data-bs-theme', 'data-theme']
    });
    
    // Also listen for system theme changes
    if (window.matchMedia) {
      window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', () => {
        // Only recolor if no explicit theme is set (using system preference)
        const hasExplicitTheme = document.documentElement.hasAttribute('data-bs-theme') ||
                                 document.documentElement.hasAttribute('data-theme');
        if (!hasExplicitTheme) {
          setTimeout(recolorAllDiagrams, 10);
        }
      });
    }
    
    console.log('Diagram theme switcher initialized');
  }

  // Start initialization
  init();
})();
