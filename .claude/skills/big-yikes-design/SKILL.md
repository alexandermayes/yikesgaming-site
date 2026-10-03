---
name: big-yikes-design
description: Build or change any page on yikesgaming.com (the <Big Yikes> guild site) in the guild's design system. Use for new pages, new sections, link-preview images, or restyling.
---

# Big Yikes design system

Before writing any HTML or CSS in this repo:

1. Read `DESIGN.md` (rules, tokens, components) and `assets/css/brand.css` (the implementation).
2. Start new pages from `valheim/index.html`: copy its `<head>` (fonts, brand.css, favicon, og tags) and its
   `nameplate` header and `footer`.
3. Reuse brand.css components. Add new CSS to brand.css only when a component will be used on more than one
   page; otherwise add a small `<style>` block in the page.

Hard rules:

- Plain HTML/CSS/JS with no build step. GitHub Pages serves the repo as-is from `main`.
- Tanker for headings only (capitals only), Switzer for text, JetBrains Mono only for things people copy.
- Brand purple only on the `<Big Yikes>` mark. Each game page sets `data-game` and uses that game's accent.
- Icons: Tabler only, inline SVG, from `assets/icons/` or `https://api.iconify.design/tabler/<name>.svg`.
- Motion: GSAP 3.15.0 from jsDelivr with SRI, following DESIGN.md's Motion section (one intro, one reveal,
  click responses, reduced-motion safe). Copy the script tags and the head failsafe from `valheim/index.html`.
- Every page needs og tags plus a 1200x630 image built in `tools/` and rendered with `pwsh tools/render.ps1`.
- Check text contrast (WCAG AA) in light and dark for any new color, tap targets of at least 48px, and a
  layout that works at 390px width.
- The repo is public: never commit passwords, keys or tokens.
