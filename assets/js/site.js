// Site behaviour: copy buttons everywhere, plus GSAP motion when GSAP loaded and the visitor allows motion.
// Motion rules live in DESIGN.md: one intro sequence per page, small responses to clicks, nothing looping.
(function () {
  var root = document.documentElement;
  var live = document.getElementById('live');
  var gsap = window.gsap;
  var motionOK = !!gsap && window.matchMedia('(prefers-reduced-motion: no-preference)').matches;

  if (motionOK) {
    if (window.SplitText) gsap.registerPlugin(window.SplitText);
    if (window.ScrambleTextPlugin) gsap.registerPlugin(window.ScrambleTextPlugin);
    var fontsReady = document.fonts ? document.fonts.ready : Promise.resolve();
    Promise.race([fontsReady, new Promise(function (r) { setTimeout(r, 1200); })]).then(function () {
      window.__introStarted = true;
      try { intro(); } catch (e) { gsap.set('[data-intro]', { clearProps: 'all' }); } finally { root.classList.remove('js-anim'); }
    });
    try { revealOnView(); } catch (e) {}
  } else {
    root.classList.remove('js-anim');
  }

  // Page-load sequence: headline, lede, card and other [data-intro] parts, then the address decodes.
  function intro() {
    var tl = gsap.timeline({ defaults: { ease: 'power3.out' } });
    var mark = document.querySelector('.mark');
    var h1 = document.querySelector('h1[data-intro]');

    if (mark) {
      tl.from(mark, { autoAlpha: 0, duration: 0.3 }, 0)
        .from(mark.querySelectorAll('.br'), { x: function (i) { return i ? -10 : 10; }, duration: 0.45, ease: 'back.out(2)' }, 0.05);
    }
    if (h1 && window.SplitText) {
      var split = window.SplitText.create(h1, { type: 'lines', mask: 'lines', linesClass: 'line' });
      tl.set(h1, { autoAlpha: 1 }, 0.1)
        .from(split.lines, { yPercent: 105, duration: 0.7, stagger: 0.09, ease: 'power4.out' }, 0.1);
    } else if (h1) {
      tl.from(h1, { autoAlpha: 0, y: 14, duration: 0.5 }, 0.1);
    }
    tl.from('.lede[data-intro]', { autoAlpha: 0, y: 10, duration: 0.5 }, 0.45)
      .from('.card[data-intro]', { autoAlpha: 0, y: 18, duration: 0.55 }, 0.55);
    var others = Array.prototype.filter.call(document.querySelectorAll('[data-intro]'), function (el) {
      return el !== mark && el !== h1 && !el.matches('.lede, .card');
    });
    if (others.length) tl.from(others, { autoAlpha: 0, y: 14, duration: 0.5, stagger: 0.08 }, 0.55);

    var addr = document.querySelector('[data-scramble]');
    if (addr && window.ScrambleTextPlugin) {
      tl.to(addr, { duration: 0.8, scrambleText: { text: addr.textContent, chars: 'abcdefghijklmnopqrstuvwxyz0123456789', revealDelay: 0.15, speed: 0.7 } }, 0.75);
    }
  }

  // Elements marked data-reveal (the item tooltip) pop in the first time they're seen, like hovering an item.
  function revealOnView() {
    var els = document.querySelectorAll('[data-reveal]');
    if (!els.length || !('IntersectionObserver' in window)) return;
    els.forEach(function (el) { gsap.set(el, { autoAlpha: 0 }); });
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (e) {
        if (!e.isIntersecting) return;
        io.unobserve(e.target);
        gsap.fromTo(e.target, { autoAlpha: 0, scale: 0.97, y: 6 }, { autoAlpha: 1, scale: 1, y: 0, duration: 0.22, ease: 'power2.out' });
        gsap.from(e.target.querySelectorAll('li'), { autoAlpha: 0, x: -6, duration: 0.25, stagger: 0.06, delay: 0.12, ease: 'power2.out' });
      });
    }, { threshold: 0.5 });
    els.forEach(function (el) { io.observe(el); });
  }

  // FAQ answers fade in when opened.
  document.querySelectorAll('details').forEach(function (d) {
    d.addEventListener('toggle', function () {
      if (d.open && motionOK) gsap.from(d.querySelector('div'), { autoAlpha: 0, y: -4, duration: 0.2, ease: 'power2.out' });
    });
  });

  // Copy buttons: <button data-copy="text" data-copy-name="Address"> with a <template> holding the "done" content.
  function fallbackCopy(text) {
    var ta = document.createElement('textarea');
    ta.value = text;
    ta.setAttribute('readonly', '');
    ta.style.position = 'fixed';
    ta.style.opacity = '0';
    document.body.appendChild(ta);
    ta.select();
    var ok = false;
    try { ok = document.execCommand('copy'); } catch (e) {}
    document.body.removeChild(ta);
    return ok;
  }

  document.querySelectorAll('[data-copy]').forEach(function (btn) {
    var idle = btn.innerHTML;
    btn.addEventListener('click', function () {
      var text = btn.getAttribute('data-copy');
      var what = btn.getAttribute('data-copy-name') || 'Text';
      var done = btn.querySelector('template');
      function ok() {
        if (done) btn.innerHTML = done.innerHTML;
        btn.classList.add('is-done');
        if (motionOK) gsap.from(btn.querySelector('.icon'), { scale: 0.4, rotation: -25, duration: 0.4, ease: 'back.out(3)' });
        if (live) live.textContent = what + ' copied';
        setTimeout(function () { btn.innerHTML = idle; btn.classList.remove('is-done'); }, 1800);
      }
      function fail() {
        if (fallbackCopy(text)) ok();
        else if (live) live.textContent = 'Copy failed. Select the text and press Ctrl+C.';
      }
      if (navigator.clipboard && navigator.clipboard.writeText) navigator.clipboard.writeText(text).then(ok, fail);
      else fail();
    });
  });
})();
