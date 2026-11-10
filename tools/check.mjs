// Checks the built site: every local link, script, stylesheet, image and anchor target exists; every page has a
// lang, a viewport and (unless noindex) a canonical URL and an og:image that exists. No network. Exit 1 on any miss.
//   node tools/check.mjs
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const skipDirs = new Set(['.git', 'node_modules', 'src', 'tools', '.github', '.claude', '.21st']);
const pages = walk(root).filter((f) => f.endsWith('.html'));
const problems = [];

for (const file of pages) {
  const rel = '/' + path.relative(root, file).replace(/\\/g, '/');
  const html = fs.readFileSync(file, 'utf8');
  const ids = new Set([...html.matchAll(/\sid="([^"]+)"/g)].map((m) => m[1]));
  const noindex = /name="robots" content="[^"]*noindex/.test(html);
  if (!/<html[^>]*\blang="/.test(html)) problems.push(`${rel}: no lang on <html>`);
  if (!/name="viewport"/.test(html)) problems.push(`${rel}: no viewport meta`);
  if (!noindex && !/rel="canonical"/.test(html)) problems.push(`${rel}: no canonical link`);
  for (const m of html.matchAll(/\s(?:href|src)="([^"]+)"/g)) {
    const url = m[1];
    if (/^(https?:|mailto:|data:|javascript:|\/\/)/.test(url) || /['+]/.test(url)) continue;
    if (url.startsWith('#')) { if (url.length > 1 && !ids.has(url.slice(1))) problems.push(`${rel}: anchor ${url} has no target`); continue; }
    const clean = url.replace(/[?#].*$/, '');
    if (!clean) continue;
    const target = clean.startsWith('/') ? path.join(root, clean) : path.resolve(path.dirname(file), clean);
    const candidates = clean.endsWith('/') ? [path.join(target, 'index.html')] : [target, path.join(target, 'index.html')];
    if (!candidates.some((c) => fs.existsSync(c))) problems.push(`${rel}: ${url} does not exist`);
  }
  for (const m of html.matchAll(/property="og:image" content="https:\/\/yikesgaming\.com([^"]+)"/g)) {
    if (!fs.existsSync(path.join(root, m[1]))) problems.push(`${rel}: og:image ${m[1]} does not exist`);
  }
}
const css = fs.readFileSync(path.join(root, 'assets/css/brand.css'), 'utf8');
for (const m of css.matchAll(/url\(["']?([^"')]+)["']?\)/g)) {
  const u = m[1]; if (/^(https?:|data:)/.test(u)) continue;
  if (!fs.existsSync(path.join(root, u.replace(/[?#].*$/, '')))) problems.push(`brand.css: ${u} does not exist`);
}
if (problems.length) { problems.forEach((p) => console.error(p)); process.exit(1); }
console.log(`check: ${pages.length} pages, all links, anchors, assets and og images resolve`);

function walk(dir) {
  return fs.readdirSync(dir, { withFileTypes: true }).flatMap((d) => {
    if (skipDirs.has(d.name)) return [];
    const p = path.join(dir, d.name);
    return d.isDirectory() ? walk(p) : [p];
  });
}
