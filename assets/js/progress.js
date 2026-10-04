// Big Yikes progress kit: renders world progress (bosses + biomes) the same way everywhere it appears (Hall of Fame,
// home page; Longhouse carries the same functions). Styles live in brand.css under "progress kit".
// Usage: BYProgress.render(container, { bosses: [...defeated], biomes: [...reached], tracked: true, iconBase: '/assets/valheim/' })
(function (root) {
  var BOSSES = ['Eikthyr', 'The Elder', 'Bonemass', 'Moder', 'Yagluth', 'The Queen', 'Fader'];
  // Valheim's progression order: the order a guild actually reaches them (sailing the Ocean comes before the Mistlands).
  var BIOMES = ['Meadows', 'Black Forest', 'Swamp', 'Mountains', 'Plains', 'Ocean', 'Mistlands', 'Ashlands', 'Deep North'];
  function slug(s) { return String(s).toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, ''); }
  function icon(base, name, size) { return '<img class="vi" src="' + base + slug(name) + '.png" alt="" width="' + size + '" height="' + size + '" loading="lazy">'; }
  function meter(label, n, total, tracked) {
    return '<div class="meter"><div class="meter-top">' + label + '<span>' + (tracked ? '<b>' + n + '</b> of ' + total : 'Not tracked yet') + '</span></div>' +
      '<div class="bar" role="img" aria-label="' + label + ': ' + (tracked ? n + ' of ' + total : 'not tracked yet') + '"><span style="transform:scaleX(' + (tracked ? n / total : 0) + ')"></span></div></div>';
  }
  function render(el, o) {
    var base = o.iconBase || '/assets/valheim/', tracked = !!o.tracked;
    var bosses = o.bosses || [], biomes = o.biomes || [];
    var down = BOSSES.filter(function (b) { return bosses.indexOf(b) >= 0; }).length;
    var reached = BIOMES.filter(function (b) { return biomes.indexOf(b) >= 0; }).length;
    var nextBiome = tracked ? BIOMES.filter(function (b) { return biomes.indexOf(b) < 0; })[0] : null;
    var meters = o.meters === false ? '' : '<div class="meters">' + meter('Bosses', down, 7, tracked) + meter('Biomes', reached, BIOMES.length, tracked) + '</div>';
    var journey = '<ol class="journey" aria-label="Biomes, in the order a guild reaches them">' + BIOMES.map(function (b) {
      var st = !tracked ? 'unknown' : biomes.indexOf(b) >= 0 ? 'reached' : b === nextBiome ? 'next' : 'locked';
      var word = { unknown: 'Not tracked', reached: 'Reached', next: 'Next up', locked: 'Locked' }[st];
      return '<li class="node ' + st + '"><span class="coin">' + icon(base, b, 34) + '</span><b>' + b + '</b><small>' + word + '</small></li>';
    }).join('') + '</ol>';
    var trophies = '<div class="trophies" role="list" aria-label="Bosses">' + BOSSES.map(function (b) {
      var st = !tracked ? 'unknown' : bosses.indexOf(b) >= 0 ? 'earned' : 'locked';
      var word = { unknown: 'Not tracked', earned: 'Defeated', locked: 'Standing' }[st];
      return '<div class="trophy ' + st + '" role="listitem">' + icon(base, b, 52) + '<b>' + b + '</b><small>' + word + '</small></div>';
    }).join('') + '</div>';
    if (o.only === 'journey') { el.innerHTML = journey; return; }
    if (o.only === 'trophies') { el.innerHTML = trophies; return; }
    el.innerHTML = meters + (o.order === 'bosses-first' ? trophies + journey : journey + trophies);
  }
  root.BYProgress = { render: render, BOSSES: BOSSES, BIOMES: BIOMES };
})(window);
