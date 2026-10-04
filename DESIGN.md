# <Big Yikes> design system

The rulebook for every page on yikesgaming.com. Tokens and components live in `assets/css/brand.css`.
New pages link that file and follow these rules, so the site stays one design as it grows.

**Source of truth:** the Figma file *Big Yikes Design System* (kit name "BY Tactile"),
https://www.figma.com/design/NPB8kVk568RPWnkJNLd8p1/Big-Yikes-Design-System (Getting started page). When
Figma and this file disagree, Figma wins; update this file and brand.css to match.

**Status:** the home page (`index.html`) is an under-construction placeholder. The full home page in progress lives
at `/preview/` (unlinked, noindex); move it back to `index.html` when it's ready. Words follow the
`big-yikes-voice` skill.

**Checks before shipping:** `npx impeccable detect <url>` (desktop and `--viewport 390x844`) and an axe-core run
(WCAG 2.1 AA) should both come back clean; they did on 2026-10-04 for every page and every Longhouse tab.

## Identity

- **Subject:** `<Big Yikes>`, a gaming community of about 400 people. WoW first (it started on Grobbulus, US),
  plus the Yikesheim Valheim server.
- **Audience:** guildmates and newcomers arriving from a Discord link, often on a phone.
- **Brand art (use the real files, never redraw them):** in `assets/brand/`
  - `logo-wordmark.png`: the brush "BIG YIKES!" logo from Figma, header and footer.
  - `logo-head.png`: the same logo with the "GROBBULUS • US" line (Figma "Big Yikes Head txt"), for large use only.
  - `lockup.png`: Bing (bigfoot) and Beti (yeti) above the logo, the mascot moment on the home page.
  - `stickers/*.png`: real guild emoji, for the sticker wall.
  - `web.svg`: spider-web corners from the Halloween banner (seasonal, decorative, 20% opacity).
  - `favicon-*.png`, `banner.jpg`: from the guild icon and banner.

## Color (single dark theme)

| Token | Value | Figma | Use |
|---|---|---|---|
| `--ground` | `#101110` | by-tactile-bg-canvas | page background |
| `--ground-2` | `#171916` | | alternate full-width band |
| `--surface` | `#1D201C` | | dark enamel: secondary buttons, interactive containers, keycaps |
| `--ink` | `#F3F3ED` | by-tactile-text-primary | text |
| `--muted` | `#AFB3AA` | by-tactile-text-secondary | secondary text, labels |
| `--line` | `#50554D` | by-tactile-border-subtle | borders, dividers |
| `--yikes` | `#FFCD00` | brand yellow | logo, the one primary action per area, focus ring, selected marker |

Yellow is a signal, not a decoration: never a background band, never body text. Green (`--online`) and red
(`--danger`) are status colors and always sit next to a written label. The **in-game tooltip** (`--tip-*`)
keeps Valheim's own colors because it imitates the game UI. WoW class colors appear only as role swatches.

## Type

- **Source Sans 3** (Google Fonts), the kit's UI family. Figma notes it's a proposed stand-in for the brand's
  Lateral/Figura faces, so don't claim those rendered.
  - Display 56/60 bold (`h1`, home section titles), Title 28/32 bold (`h2`, `h3` on the home page),
    Body 18/26 regular, Meta 14/20 (labels, captions).
  - The home hero is the one poster-scale moment: up to 88px, weight 900.
- **JetBrains Mono**: only for things people copy or type (server address, install command, profile code).
- Sentence case everywhere. No all-caps labels, no eyebrow labels above headings.

## Layout

- Desktop: content up to 1312px at a 1440px viewport with 64px gutters (`.wrap`). Mobile: 24px gutters.
- Reading pages (Valheim guide, Hall of Fame) use a single 720px column (`.page`).
- Home sections are full-width **stages** that alternate `--ground` and `--ground-2`; no card grids.
- Below 960px the header switches to the Menu button; panels stack and, below 600px, actions fill the width.
- Numbered markers only for real sequences (join steps). Cards only for interactive things (the server card).

## Components (in brand.css)

- `site-head` with `wordmark`, `site-nav` (selected page: `aria-current="page"`, yellow underline on desktop,
  yellow left bar in the mobile menu) and `menu-toggle`.
- `btn`: yellow enamel primary. **One per task area.** `btn ghost` / `btn secondary`: dark enamel for every
  other action. `btn small` is 44px tall. Feedback is 120ms color and shadow only: nothing moves.
- `card` + `status` + `field` (copy buttons via `data-copy`), `steps`, `key` (keycap for game menu buttons),
  `tooltip` (the Valheim item tooltip), `note`, `details` (FAQ rows), `footer`, `live` + `dot`, `webs`.

## Motion (GSAP 3.15)

GSAP core, SplitText and ScrambleText load from jsDelivr, pinned to `3.15.0` with SRI hashes (copy the tags
from the `<head>` of `valheim/index.html`). Behaviour is in `assets/js/site.js`.

- **One intro per page:** the headline rises from a mask (SplitText), then the other `data-intro` elements
  follow; the server address decodes (`data-scramble`). About 1.2s total.
- **One reveal:** `data-reveal` pops in once when first seen. The home page's sticker wall slaps on once.
- **Responses to actions:** the copy check pops, FAQ answers fade in when opened. UI state changes take 120ms.
- Nothing loops, no scroll-jacking, no smooth-scroll.
- **Reduced motion:** the head script hides `data-intro` only when motion is allowed. With reduced motion (or if
  GSAP fails to load) nothing is hidden and state changes are instant. A 2.5s failsafe and a `try/finally`
  always reveal the page. Windows' "Animation effects" off counts as reduced motion.
- Headless Chrome reports reduced motion and won't render narrower than 500px. Test phone width with 390px
  iframes, and the intro by overriding `matchMedia` and setting `requestAnimationFrame = null` in a copy.

## Rules

- Targets at least 44px (buttons 48px by default). Visible focus ring (`:focus-visible`, yellow).
- Never communicate status by color alone; every badge or dot carries words.
- Icons: **Tabler** only (MIT), inlined as SVG with `class="icon"` and `aria-hidden="true"`. Get more from
  `https://api.iconify.design/tabler/<name>.svg`. No emoji as icons; guild emoji appear only as stickers.
- Link previews: every page gets `og:title`, `og:description` and a 1200x630 `og:image` built as HTML in
  `tools/` and rendered with `pwsh tools/render.ps1`. Bump the file version when an image changes.
  Keep `assets/img/og-yikesheim-v4.png`: the pinned Discord post uses it.
- Copy: plain words, short sentences, name things the way the game names them ("Join IP", "Connect").
- Never put passwords or keys in this repo. It's public.
