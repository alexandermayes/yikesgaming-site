# yikesgaming.com

Website for the Big Yikes guild, served by GitHub Pages.

| Path | What |
|---|---|
| `src/pages/` | **The pages' sources.** Edit these, not the root HTML. `src/partials/` holds the shared head, header and nav, footer credit, GSAP and motion-guard blocks; `src/site.json` holds the assets cache version (`?v=`). |
| `content/guild.json` | The facts the pages render: Discord invite, WeakAuras link, member-count fallback, realm, Valheim host. |
| `tools/build.mjs` | `node tools/build.mjs` writes the root pages from `src/`; `--check` fails if a root page drifted from its source (the mod-pin workflow runs it every hour). |
| `tools/check.mjs` | `node tools/check.mjs`: every local link, anchor, asset and og image resolves; every page has lang, viewport and canonical. |
| `index.html` | Home page (generated). Live since 2026-10-04. |
| `valheim/index.html` | Valheim join guide (generated): the install command, the quest log, troubleshooting. Mod versions in it are rewritten by the mod-pin workflow. |
| `valheim/hall/index.html` | Yikesheim Hall of Fame (generated): who is online, Moment of the week, world progress and leaderboards, all from `hq.yikesgaming.com/public/stats.json`. |
| `404.html` | Branded not-found page (generated). |
| `bot/` | Big Yikes Bot's About, Terms and Privacy pages, with their own `public-info.css`. Not generated. |
| `preview/index.html` | Redirect stub to the home page (kept for old links; `noindex`). |
| `assets/css/brand.css` | Shared design system: colors, type, components. Rules in `DESIGN.md`. Longhouse carries a copy. |
| `assets/js/site.js` | Copy buttons, GSAP intro, reveals, the header menu. `season.js` sets the seasonal theme; `progress.js` draws world progress. |
| `assets/icons/` | Tabler icon set (SVG) used across the site. |
| `assets/img/`, `assets/brand/`, `assets/valheim/` | Favicon, home-screen icon, link-preview images; brand art and stickers; Valheim item icons (credits in `CREDITS.txt`). |
| `tools/bump-mods.ps1`, `tools/build-modpack.ps1`, `.github/workflows/mods.yml` | The hourly mod-pin check: newer Thunderstore releases rewrite the installer, the page source and the zip, rebuild the pages, and commit. |
| `tools/render.ps1`, `tools/og-*.html` | Sources for the link-preview images. Re-render with `pwsh tools/render.ps1`. |
| `tools/voice-check.py` | Big Yikes voice check for copy. |
| `.claude/skills/big-yikes-design/`, `big-yikes-voice/` | Claude Code skills that keep new pages in the design system and the guild's voice. |
| `install`, `uninstall` | Short-URL copies of `valheim/install.ps1` and `valheim/uninstall.ps1` (so the command is `irm https://yikesgaming.com/install \| iex`). Copy them again whenever you edit the .ps1 files by hand; the mod-pin workflow re-copies them on every bump and fails its run if they drift. |
| `CNAME` | Tells GitHub Pages to serve this site at `yikesgaming.com`. |
| `robots.txt`, `sitemap.xml` | The site is open to search; `/preview/`, `/tools/` and the short URLs are excluded. |
| `.nojekyll` | Serves files as-is, without GitHub's Jekyll processing. |

Plain HTML, CSS and JS on GitHub Pages, with one step between editing and publishing: edit a source under `src/pages/` (or a fact in `content/guild.json`), run `node tools/build.mjs`, commit the sources and the generated pages together, push, and the site updates in about a minute. Never edit a generated root page by hand: the hourly workflow's `build.mjs --check` fails until it matches its source again. Node 22 is the only tool; there are no dependencies to install.

## First-time setup

1. **Create the GitHub repo.** On github.com, click **New repository**, name it (for example `yikesgaming-site`),
   and leave every "Initialize with" box unchecked.
2. **Push this folder:**
   ```
   git remote add origin https://github.com/<your-username>/yikesgaming-site.git
   git push -u origin main
   ```
3. **Turn on Pages.** In the repo, go to **Settings → Pages** and set **Source** to *Deploy from a branch*,
   with branch `main` and folder `/ (root)`. The custom domain fills in from the `CNAME` file.
4. **Point the domain at GitHub** in Network Solutions (Domains → yikesgaming.com → **Manage DNS** / Advanced DNS).
   First turn off any domain forwarding or "parked page" setting, then:

   | Type | Host | Value |
   |---|---|---|
   | A | @ | 185.199.108.153 |
   | A | @ | 185.199.109.153 |
   | A | @ | 185.199.110.153 |
   | A | @ | 185.199.111.153 |
   | CNAME | www | `<your-username>.github.io` |

   Remove any other `@` A record, plus the `*` (wildcard) record that points to Network Solutions' parking server
   (208.91.197.39).
5. **Enable HTTPS.** Once DNS has updated (minutes to a few hours), go back to **Settings → Pages** and tick
   **Enforce HTTPS** after the certificate is issued.

Optional: add a `play` A record pointing to `149.28.193.152` (the Vultr game server) to give it a name.
Test that Valheim's Join IP accepts `play.yikesgaming.com:2456` before putting it in the guide.

## Keep secrets out of this repo

The repo is public (that's what makes GitHub Pages free), so anything committed here, including old commits,
is readable by anyone. That's why the Valheim server password isn't on the site and lives in the guild Discord.
