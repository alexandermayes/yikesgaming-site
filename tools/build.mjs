// Builds the site's pages from src/ into the repo root, where GitHub Pages serves them as plain files.
//
//   node tools/build.mjs          write every page
//   node tools/build.mjs --check  build in memory and fail if any committed page differs from its source
//
// Sources: src/pages/<path>.html becomes <path>.html at the root. Inside a source:
//   <!--@include name-->   pastes src/partials/name.html (partials may use the same placeholders)
//   {{guild.key}}          a fact from content/guild.json
//   {{site.key}}           a value from src/site.json (for example the assets cache version)
//   {{page.path}}          this page's URL path, such as /valheim/
// The header partial's nav gets aria-current="page" on the link whose href equals the page path.
// Never edit the generated root pages by hand: the mod-pin workflow fails when they drift from their sources.
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const src = path.join(root, 'src');
const guild = JSON.parse(fs.readFileSync(path.join(root, 'content', 'guild.json'), 'utf8'));
const site = JSON.parse(fs.readFileSync(path.join(src, 'site.json'), 'utf8'));
const check = process.argv.includes('--check');

const pages = walk(path.join(src, 'pages')).filter((f) => f.endsWith('.html'));
const partials = new Map();
function partial(name) {
  if (!partials.has(name)) {
    const file = path.join(src, 'partials', name + '.html');
    if (!fs.existsSync(file)) throw new Error(`unknown partial "${name}" (${file})`);
    partials.set(name, fs.readFileSync(file, 'utf8').replace(/\n$/, ''));
  }
  return partials.get(name);
}

function render(text, vars, depth = 0) {
  if (depth > 10) throw new Error('include nesting too deep');
  text = text.replace(/<!--@include ([a-z0-9-]+)-->/g, (_, name) => render(partial(name), vars, depth + 1));
  return text.replace(/\{\{(guild|site|page)\.([A-Za-z0-9_]+)\}\}/g, (m, scope, key) => {
    const v = vars[scope][key];
    if (v === undefined) throw new Error(`no value for ${m}`);
    return String(v);
  });
}

// aria-current on the nav link for this page. The header partial writes the links without it.
function markCurrent(html, pagePath) {
  if (pagePath === '/') return html;
  const needle = `<a href="${pagePath}">`;
  const navStart = html.indexOf('<nav class="site-nav"');
  const navEnd = html.indexOf('</nav>', navStart);
  if (navStart < 0 || navEnd < 0) return html;
  const nav = html.slice(navStart, navEnd);
  if (!nav.includes(needle)) return html;
  return html.slice(0, navStart) + nav.replace(needle, `<a href="${pagePath}" aria-current="page">`) + html.slice(navEnd);
}

let drift = 0;
for (const file of pages) {
  const rel = path.relative(path.join(src, 'pages'), file);
  const out = path.join(root, rel);
  const pagePath = '/' + rel.replace(/\\/g, '/').replace(/index\.html$/, '');
  const vars = { guild, site, page: { path: pagePath } };
  const html = markCurrent(render(fs.readFileSync(file, 'utf8'), vars), pagePath);
  if (check) {
    const current = fs.existsSync(out) ? fs.readFileSync(out, 'utf8') : null;
    if (current !== html) { drift++; console.error(`drift: ${rel} differs from its source (run node tools/build.mjs)`); }
  } else {
    fs.mkdirSync(path.dirname(out), { recursive: true });
    fs.writeFileSync(out, html);
    console.log(`wrote ${rel}`);
  }
}
if (check) {
  if (drift) process.exit(1);
  console.log(`check: ${pages.length} pages match their sources`);
}

function walk(dir) {
  return fs.readdirSync(dir, { withFileTypes: true }).flatMap((d) => {
    const p = path.join(dir, d.name);
    return d.isDirectory() ? walk(p) : [p];
  });
}
