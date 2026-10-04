# <Big Yikes> design system

The rulebook for every page on yikesgaming.com. Tokens and components live in `assets/css/brand.css`.
New pages link that file and follow these rules, so the site stays one design as it grows.

**Sources:** the Figma file *Big Yikes Design System* (kit "BY Tactile",
https://www.figma.com/design/NPB8kVk568RPWnkJNLd8p1/Big-Yikes-Design-System) for brand rules, and the v4 reference
lock below (Refero research, 2026-10-04) for the component language. Colors, logos and mascots never change; fonts,
buttons and interface follow the reference lock.

## Research and reference lock (v4, 2026-10-04)

Refero's style index returned nothing for any query that day, so the research used ~50 Refero screens: Duolingo
(landing, quests, leaderboard, settings), Discord (home, Discover), Xbox and PlayStation (game and community pages),
Linear and Kraken (settings), plus 404 and leaderboard patterns.

- **Primary: Duolingo's product UI.** A mascot-led brand with tactile controls, which is what the Figma kit's
  "Tactile" name points at. Preserve: buttons on a darker lip that sink when pressed; 2px outlines with a heavier
  bottom edge instead of shadows; bold uppercase tracked button labels; thick rounded progress bars and medal
  ranks; a left navigation rail with icon + label where the active item's icon sits in a raised yellow coin; mascot art as the
  main imagery.
- **Borrow only, from Discord:** headline scale (one heavy display face, big) and real product snippets used as
  imagery (a Yikesheim feed post, a Longhouse panel) instead of abstract graphics.
- **Role rules:** yellow = the primary action, the active nav item, progress fill, reached/defeated states and the
  focus ring. Green = "on" and "online" only, always with the word. Lips are the darker shade of their own fill.
- **Reject:** hairline-border-plus-soft-shadow cards, glassy dark SaaS chrome, pill-shaped everything, decorative
  gradients, light mode (the brand is charcoal), one-word color or italic swaps in headlines.

| Decision | Source | Role kept | Why |
|---|---|---|---|
| Lilita One headlines | Duolingo's chunky rounded display; Discord's heavy hero type | display only, one weight, sentence case | reads like the games the guild plays and matches the brush logo and mascots |
| Nunito for UI and body | Duolingo's rounded DIN | all running text, labels, buttons | rounded and friendly; 800 for labels gives the reference's punch |
| Lip buttons that sink on press | Duolingo buttons | yellow = one primary per area; enamel = everything else | tactile feel promised by "BY Tactile"; transform only, so no layout shift |
| Uppercase tracked button and nav labels | Duolingo buttons and rail | buttons and the Longhouse rail only | the reference's button voice; never on headings or body |
| 2px outline + heavy bottom edge on cards | Duolingo cards | interactive containers only | depth without the AI-style soft shadow |
| Left rail navigation in Longhouse | Duolingo app shell | 8 sections with Valheim icons; phones get scrolling tabs | faster switching and clearer "where am I" than thin top tabs |
| Medal ranks, thick progress bars, trophy badges | Duolingo leaderboard and quests | Hall of Fame and Longhouse overview | world progress and the leaderboard read like a game |
| Chunky rounded-square toggle with a lip | Duolingo settings toggle | green + "On"/"Off" word | state is visible without relying on color |



**Status:** the home page (`index.html`) is an under-construction placeholder. The full home page in progress lives
at `/preview/` (unlinked, noindex); move it back to `index.html` when it's ready. Words follow the
`big-yikes-voice` skill.

**Cache busting:** pages link `brand.css`, `site.js` and `season.js` with `?v=…`. GitHub Pages lets browsers cache them for 10 minutes, so bump the version on every page whenever one of those files changes.

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
  - `web.svg`: spider-web corners from the Halloween banner. Halloween only (see Seasonal theming).
  - `winter-top.svg` / `winter-bottom.svg`: icicles from a snowy eave plus snowflakes, and a snowdrift for the opposite
    corner. Winter only (Dec 1 to Jan 6). Same faint white line art as the webs.
  - `favicon-*.png`, `banner.jpg`: from the guild icon and banner.

## Color (single dark theme)

| Token | Value | Figma | Use |
|---|---|---|---|
| `--ground` | `#090908` | by-tactile-bg-canvas | page background |
| `--ground-2` | `#10100E` | | alternate full-width band |
| `--surface` / `--surface-2` | `#171715` / `#222220` | | dark enamel: secondary buttons, interactive containers; hover |
| `--ink` | `#FBFBF6` | by-tactile-text-primary | text |
| `--muted` | `#B4B4AB` | by-tactile-text-secondary | secondary text, labels |
| `--line` | `#2E2E2A` | | 2px outlines and dividers |
| `--line-strong` | `#66665E` | | control outlines and their lip |
| `--yikes` / `--yikes-lip` | `#FFCD00` / `#B38F00` | brand yellow | primary action, active nav, progress, reached states, focus; the lip under yellow |

v4.5 (2026-10-03): the canvas went from the guild icon's `#101110` charcoal to near-black, and the enamel lost
its olive cast, because the old greys read washed out next to the yellow ("the blacks are very grey"). Neutrals
stay a hair warm so they sit with the yellow; sticker and logo edges use pure `#000` so they still show on the canvas.

v4.7 (2026-10-04): **no tinted fills.** No `color-mix` washes, translucent colour backgrounds or glow halos
("I really dislike the tinted colors across the board"). A colour appears solid at full strength (yellow for
earned, done and the primary action; green and red for status, always with dark text and a word) or not at all
(neutral enamel). Completed things are solid yellow keys; badges are solid; notes are neutral enamel with a yellow
coin icon.

Yellow is a signal, not a decoration: never a background band, never body text. Green (`--online`) and red
(`--danger`) are status colors and always sit next to a written label. The **in-game tooltip** (`--tip-*`)
keeps Valheim's own colors because it imitates the game UI. WoW class colors appear only as role swatches.

## Type

- **Lilita One** (Google Fonts, one weight): `h1`, `h2`, panel titles, step medallions. Display 52/56, Title 26/30,
  poster up to 84px for a hero. Never set a weight on it (the browser would fake-bold it).
- **Nunito** (Google Fonts, 400 to 900): everything else. Body 17/26, lead 20/30, meta 14/20; labels and buttons 800.
  Buttons and the Longhouse rail use uppercase with .06em tracking; nothing else is uppercase.
- **JetBrains Mono**: only for things people copy or type (server address, install command, profile code).
- Sentence case everywhere. No all-caps labels, no eyebrow labels above headings.

## Layout

- Desktop: content up to 1312px at a 1440px viewport with 64px gutters (`.wrap`). Mobile: 24px gutters.
- Reading pages (Valheim guide, Hall of Fame) use a single 720px column (`.page`).
- Home sections are full-width **stages** that alternate `--ground` and `--ground-2`; no card grids.
- Below 960px the header switches to the Menu button; panels stack and, below 600px, actions fill the width.
- Numbered markers only for real sequences (join steps). Cards only for interactive things (the server card).

## Components (in brand.css)

- `site-head` with `wordmark`, `site-nav` (selected page: `aria-current="page"`, a small raised yellow coin before
  the label) and `menu-toggle`.
- **Selected states (v4.6).** Tinted fill + coloured outline read as generic AI UI (user feedback), same as side
  stripes, so neither is used. *Where you are* (navigation): the item's icon sits in a raised yellow coin (Longhouse
  rail), or a small coin precedes a text label (site nav). *Which option is picked* (segmented controls, file tabs,
  day chips): a lit key, solid near-white with dark text on its own lip. Completed/reached keep the progress kit's
  raised gold coin + green check seal.
- `btn`: yellow on a darker lip. **One per task area.** `btn ghost` / `btn secondary`: dark enamel with a 2px
  outline and lip for every other action. Pressing sinks the button into its lip (transform only, no layout
  shift); hover lightens the fill in 120ms. `btn small` is 44px tall.
- `card` (2px outline, heavy bottom edge) + `status` + `field` (copy buttons via `data-copy`), `steps` (yellow
  medallions), `key` (keycap with a lip, for game menu buttons),
  `tooltip` (the Valheim item tooltip), `note`, `details` (FAQ rows), `footer`, `live` + `dot`, `season-deco`.

## Seasonal theming

Big Yikes themes for holidays (the guild icon and banner change too), so seasonal art is never part of the base design.
`assets/js/season.js` sets `<html data-season>` from the date (Halloween: Oct 1 to Nov 1; winter: Dec 1 to Jan 6) and
decorations only draw under `html[data-season="…"]` on sections marked `.season-deco`. To add a holiday: add its
date range to `SEASONS`, its art to `assets/brand/`, and an `html[data-season="name"] .season-deco::before/::after` rule.
Preview with `?season=halloween` or `?season=none`. Link previews (og images) stay season-neutral because Discord
caches them.

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

## Ship checks
- `python tools/voice-check.py` (changed pages, or pass files): flags copy that drifts from the voice guide. Rules catch banned words, "clan", exclamation marks and generic buttons; Jev flags hype and vague claims (needs TYPESAFE_API_KEY). Exit 1 means something was flagged.
