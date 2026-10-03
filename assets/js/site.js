// Copy buttons: <button class="btn" data-copy="text">. Swaps icon + label to "Copied" and announces it.
(function () {
  var live = document.getElementById('live');

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
    var done = btn.querySelector('template');
    btn.addEventListener('click', function () {
      var text = btn.getAttribute('data-copy');
      var what = btn.getAttribute('data-copy-name') || 'Text';
      function ok() {
        if (done) btn.innerHTML = done.innerHTML;
        btn.classList.add('is-done');
        if (live) live.textContent = what + ' copied';
        setTimeout(function () { btn.innerHTML = idle; btn.classList.remove('is-done'); done = btn.querySelector('template'); }, 1800);
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
