# Renders the site's link-preview images with headless Chrome:
#   tools/og-valheim.html  -> assets/img/og-yikesheim-v8.png  (1200x630, Valheim pages)
#   tools/og-home.html     -> assets/img/og-home-v3.png       (1200x630, home page)
# When an image changes, bump the version in its file name (and the og:image tags) so Discord fetches it again.
# The favicon and home-screen icon come from the real guild icon in assets/brand/ and aren't rendered here.
# Usage: pwsh tools/render.ps1
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$chrome = @("$env:ProgramFiles\Google\Chrome\Application\chrome.exe", "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe", "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe") | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $chrome) { throw 'Chrome not found' }
$profile = Join-Path ([IO.Path]::GetTempPath()) "yikes-render-$PID"

function Shot($src, $out, $w, $h) {
  $url = 'file:///' + ($src -replace '\\', '/')
  & $chrome --headless=new --disable-gpu --hide-scrollbars --force-device-scale-factor=1 --user-data-dir="$profile" `
    --window-size="$w,$h" --virtual-time-budget=8000 --screenshot="$out" $url 2>$null | Out-Null
  if (-not (Test-Path $out)) { throw "render failed: $out" }
  "{0} ({1} KB)" -f $out.Substring($root.Length + 1), [math]::Round((Get-Item $out).Length / 1KB)
}

Shot "$root\tools\og-valheim.html" "$root\assets\img\og-yikesheim-v8.png" 1200 630
Shot "$root\tools\og-home.html" "$root\assets\img\og-home-v3.png" 1200 630
