# Turns the Big Yikes Valheim mods off without deleting them, so Valheim starts unmodded.
# Run it from PowerShell:   irm https://yikesgaming.com/valheim/uninstall.ps1 | iex
# Turn them back on by running the installer again.

& {
  $steam = $null
  foreach ($key in 'HKCU:\Software\Valve\Steam', 'HKLM:\SOFTWARE\WOW6432Node\Valve\Steam', 'HKLM:\SOFTWARE\Valve\Steam') {
    $p = Get-ItemProperty $key -ErrorAction SilentlyContinue
    if ($p) { foreach ($n in 'SteamPath', 'InstallPath') { if ($p.$n -and (Test-Path $p.$n)) { $steam = $p.$n; break } } }
    if ($steam) { break }
  }
  $libs = @($steam)
  $vdf = Join-Path "$steam" 'steamapps\libraryfolders.vdf'
  if ($steam -and (Test-Path $vdf)) { foreach ($m in [regex]::Matches((Get-Content $vdf -Raw), '"path"\s+"([^"]+)"')) { $libs += ($m.Groups[1].Value -replace '\\\\', '\') } }
  $game = $libs | Where-Object { $_ } | ForEach-Object { Join-Path $_ 'steamapps\common\Valheim' } | Where-Object { Test-Path (Join-Path $_ 'valheim.exe') } | Select-Object -First 1
  if (-not $game) { Write-Host 'Could not find Valheim through Steam.' -ForegroundColor Red; return }
  if (Get-Process valheim -ErrorAction SilentlyContinue) { Write-Host 'Close Valheim first, then run this again.' -ForegroundColor Red; return }
  $dll = Join-Path $game 'winhttp.dll'
  if (Test-Path $dll) {
    Move-Item $dll (Join-Path $game 'winhttp.dll.off') -Force
    Write-Host 'Mods turned off. Valheim will start unmodded. Run the installer again to turn them back on.' -ForegroundColor Green
  } else {
    Write-Host 'Mods are already off.' -ForegroundColor Green
  }
}
