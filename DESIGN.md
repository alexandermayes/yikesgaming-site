# <Big Yikes> design system

The rulebook for every page on yikesgaming.com. Tokens and components live in `assets/css/brand.css`.
New pages link that file and follow these rules, so the site stays one design as it grows.

## Identity

- **Subject:** `<Big Yikes>`, a WoW Classic guild that also runs game servers (Valheim first).
- **Audience:** guildmates arriving from a Discord link, often on a phone.
- **Brand mark:** the guild tag in angle brackets, `<Big Yikes>`, the way WoW shows a guild under a player's
  name. Set in Tanker, brand purple. It's the only place the brand purple appears.
- **Favicon:** the brackets alone (`assets/img/favicon.svg`).

## Color

| Token | Light | Dark | Use |
|---|---|---|---|
| `--ground` | `#EEF1EE` | `#0D1112` | page background |
| `--surface` | `#FFFFFF` | `#151B1C` | cards, keycaps |
| `--ink` | `#14191B` | `#E5EBE9` | text |
| `--muted` | `#55616A` | `#97A5A2` | secondary text, labels |
| `--line` | `#D2D9D6` | `#263132` | borders, dividers |
| `--brand` | `#7E2BC4` | `#C68BF6` | the `<Big Yikes>` mark only (WoW "epic" purple) |
| `--accent` | `#1D716D` | `#4CB5AD` | the current game's accent: buttons, step numbers, focus |

Every pair above passes WCAG AA (4.5:1) for text. **Game accents:** each game page sets
`<html data-game="...">` and owns one accent. Valheim is teal (the default in `:root`). To add a game, add a
`[data-game="wow"] { --accent: ...; --accent-ink: ...; --accent-text: ...; --accent-soft: ... }` block in both
themes and check contrast before shipping.

The **in-game tooltip** (`--tip-*`) is always dark, in both themes, because that's how tooltips look in game.

## Type

- **Tanker** (Fontshare, ITF Free Font License): headings and the brand mark. It has capitals only, so it's
  for short display text. Never use it for body copy.
- **Switzer** (Fontshare): everything else. 400 body, 500 small UI, 600 labels and h3, 700 tooltip titles.
- **JetBrains Mono** (Google Fonts): only for things people copy or type, like server addresses.
- Scale: 1.25 ratio from a 17px base (`--fs-sm` to `--fs-hero`). Body lines stay under about 62 characters.
- Sentence case everywhere. No all-caps labels, no eyebrow labels above headings.

## Layout

- One left-aligned column, max 640px, 16px side gutter. Quiet nameplate header (mark left, section right).
- **One bold element per page.** On the Valheim page it's the item tooltip. Keep everything else plain.
- Numbered markers only for real sequences (join steps). Cards only for the one thing that needs separating.

## Components (in brand.css)

`nameplate`, `card` + `status` + `field`, `btn` (copy buttons via `data-copy`), `steps`, `key` (keycap for
menu buttons), `tooltip`, `note`, `details` (FAQ rows), `footer`.

## Rules from the checklist

- Tap targets at least 48px (Apple HIG says 44pt).
- Visible focus ring (`:focus-visible`, accent color). Motion only in response to a click, and off under
  `prefers-reduced-motion`.
- Icons: **Tabler** only (MIT), inlined as SVG with `class="icon"` and `aria-hidden="true"`. Source files are
  in `assets/icons/`. Get more from `https://api.iconify.design/tabler/<name>.svg`. Don't draw custom icons.
- Link previews: every page gets `og:title`, `og:description` and a 1200x630 `og:image`. Build the image as
  HTML in `tools/` and render it with `pwsh tools/render.ps1`.
- Copy: plain words, short sentences, name things the way the game names them ("Join IP", "Connect").
- Never put passwords or keys in this repo. It's public.
