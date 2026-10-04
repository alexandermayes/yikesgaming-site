---
name: big-yikes-design
description: Build or change any page on yikesgaming.com (the <Big Yikes> guild site) in the guild's design system (Figma "BY Tactile"). Use for new pages, new sections, link-preview images, or restyling.
---

# Big Yikes design system

Before writing any HTML or CSS in this repo:

1. Read `DESIGN.md` (rules, tokens, components) and `assets/css/brand.css` (the implementation). The Figma file
   linked at the top of DESIGN.md is the source of truth.
2. Start new pages from `valheim/index.html` (reading page) or `index.html` (stage page): copy the `<head>`
   (Lilita One + Nunito, season.js, brand.css, favicon, og tags), the `site-head` header with its menu script, and the footer.
3. Reuse brand.css components. Add new CSS to brand.css only when a component will be used on more than one
   page; otherwise add a small `<style>` block in the page.

Hard rules:

- Plain HTML/CSS/JS with no build step. GitHub Pages serves the repo as-is from `main`.
- Single dark theme: canvas `#101110`, text `#F3F3ED` / `#AFB3AA`, outlines `#383D35` (controls `#5A6056`), yellow `#FFCD00` on lip `#B38F00`.
- Lilita One for headlines (never set a weight on it), Nunito for everything else; JetBrains Mono only for
  things people copy. Follow the v4 reference lock and decision ledger in DESIGN.md.
- One yellow `btn` per task area; every other action is `btn ghost` (dark enamel). Buttons sit on a lip and
  sink into it when pressed (transform only). Cards: 2px outline with a heavier bottom edge, never soft shadows.
- Use the real brand art in `assets/brand/` (logo, Bing and Beti, guild emoji). Never redraw or fake it.
- Icons: Tabler only, inline SVG, from `https://api.iconify.design/tabler/<name>.svg`.
- Motion: GSAP 3.15.0 from jsDelivr with SRI, following DESIGN.md's Motion section (one intro, one reveal,
  click responses, reduced-motion safe).
- Every page needs og tags plus a 1200x630 image built in `tools/` and rendered with `pwsh tools/render.ps1`.
- Check contrast (WCAG AA), 44px targets, visible focus, status words next to status colors, and a layout that
  works at 390px (test with a 390px iframe; headless Chrome won't go below 500px).
- The repo is public: never commit passwords, keys or tokens.
