# Renders the site's raster images with headless Chrome:
#   tools/og-valheim.html      -> assets/img/og-yikesheim-v4.png       (1200x630 link preview for Discord etc.)
#   assets/img/favicon.svg     -> assets/img/apple-touch-icon.png (180x180)
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

Shot "$root\tools\og-valheim.html" "$root\assets\img\og-yikesheim-v4.png" 1200 630

$icon = Join-Path $profile 'icon.html'
New-Item -ItemType Directory -Force $profile | Out-Null
"<!doctype html><style>html,body{margin:0;width:180px;height:180px;background:#7E2BC4}img{width:180px;height:180px;display:block}</style><img src='file:///$(("$root\assets\img\favicon.svg") -replace '\\','/')'>" | Set-Content $icon -Encoding utf8NoBOM
Shot $icon "$root\assets\img\apple-touch-icon.png" 180 180

Remove-Item $profile -Recurse -Force -ErrorAction SilentlyContinue
