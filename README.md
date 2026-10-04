# yikesgaming.com

Website for the Big Yikes guild, served by GitHub Pages.

| Path | What |
|---|---|
| `index.html` | Placeholder home page. It redirects to `/valheim/` until the real Big Yikes home page is built. |
| `valheim/index.html` | Valheim server join guide (address, three steps; the password is kept in the guild Discord). |
| `assets/css/brand.css` | Shared design system: colors, type, components. Rules in `DESIGN.md`. |
| `assets/js/site.js` | Copy buttons. |
| `assets/icons/` | Tabler icon set (SVG) used across the site. |
| `assets/img/` | Favicon, home-screen icon, link-preview images. |
| `tools/` | Sources for the preview images. Re-render with `pwsh tools/render.ps1`. |
| `.claude/skills/big-yikes-design/` | Claude Code skill that keeps new pages in the design system. |
| `install`, `uninstall` | Short-URL copies of `valheim/install.ps1` and `valheim/uninstall.ps1` (so the command is `irm https://yikesgaming.com/install \| iex`). Copy them again whenever you edit the .ps1 files. |
| `CNAME` | Tells GitHub Pages to serve this site at `yikesgaming.com`. |
| `robots.txt` | Asks search engines not to list the site (it's for guild members). |
| `.nojekyll` | Serves files as-is, without GitHub's Jekyll processing. |

Plain HTML with no build step: edit a file, commit, push, and the site updates in about a minute.

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
