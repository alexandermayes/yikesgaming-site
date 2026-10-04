// Big Yikes holiday theming. Sets <html data-season="…"> from today's date so seasonal decorations switch themselves
// on and off (see "Seasonal theming" in DESIGN.md). Preview any season with ?season=halloween, or ?season=none.
// Loaded in <head> before the stylesheet paints, so decorations never flash in or out.
(function () {
  // [season, start month, start day, end month, end day], inclusive, visitor's local date. Ranges may wrap the new year.
  var SEASONS = [
    ['halloween', 10, 1, 11, 1],
    ['winter', 12, 1, 1, 6]
  ];
  var forced = /[?&]season=([a-z-]+)/.exec(location.search);
  var season = forced ? forced[1] : '';
  if (!forced) {
    var d = new Date(), today = (d.getMonth() + 1) * 100 + d.getDate();
    for (var i = 0; i < SEASONS.length; i++) {
      var s = SEASONS[i], start = s[1] * 100 + s[2], end = s[3] * 100 + s[4];
      if (start <= end ? today >= start && today <= end : today >= start || today <= end) { season = s[0]; break; }
    }
  }
  if (season && season !== 'none') document.documentElement.setAttribute('data-season', season);
})();
