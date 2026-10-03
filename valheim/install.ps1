# Big Yikes Valheim mods installer (Yikesheim)
# Installs BepInEx 5.4.2351 + Valheim Plus 10.2.0 (Grantapher) + Runic Character Vault 1.0.3 into your Steam copy of Valheim.
# Runic Character Vault keeps your Yikesheim character on the server; the server only accepts brand-new characters.
# Run it from PowerShell:   irm https://yikesgaming.com/valheim/install.ps1 | iex
# Turn the mods off again:  irm https://yikesgaming.com/valheim/uninstall.ps1 | iex
#
# What it does: finds Valheim through Steam, downloads the two mods from Thunderstore, checks each download
# against a fixed SHA-256 hash, and copies them into the game folder. It changes nothing else on your PC.
# Read it first if you like: https://github.com/alexandermayes/yikesgaming-site/blob/main/valheim/install.ps1

& {
  $ErrorActionPreference = 'Stop'
  [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

  $mods = @(
    @{ Name = 'BepInEx 5.4.2351'; Url = 'https://thunderstore.io/package/download/denikson/BepInExPack_Valheim/5.4.2351/'; Sha256 = 'BCE631497976A93977CEB08E166712E6C31D15244956F89F17DF092A9B62E29F' },
    @{ Name = 'Valheim Plus 10.2.0'; Url = 'https://thunderstore.io/package/download/Grantapher/ValheimPlus_Grantapher_Temporary/10.2.0/'; Sha256 = '1D53F0636538D2F21273CA8CB0CA75B2A00F0B373BC54B02F5369E1CFBED1539' },
    @{ Name = 'Runic Character Vault 1.0.3'; Url = 'https://thunderstore.io/package/download/Chazman/RunicCharacterVault/1.0.3/'; Sha256 = 'D1B63EA6BC648C92DB78DA7DB51F550F8539E4786A0979EBAD5EE6F2A3E216B7' }
  )

  # Plain-language replacements for Runic Character Vault's join messages (keys from its English.json)
  $vaultMessages = @{
    'text_25ddcadc5976' = 'Yikesheim needs a brand-new character. Go back, create a new character, and join with that one. Your existing character is safe and still works everywhere else.'
    'text_cf24dc035c05' = 'You already have a character on Yikesheim: {0}. Join with that character.'
    'text_b99199e4c3cc' = 'You already have characters on Yikesheim: {0}. Join with one of those.'
  }

  function Say($msg, $color = 'Gray') { Write-Host $msg -ForegroundColor $color }
  function Fail($msg) { Write-Host ''; Write-Host $msg -ForegroundColor Red; Write-Host 'Nothing was changed. Ask in the guild Discord if you get stuck.' -ForegroundColor Red; throw 'stop' }

  try {
    Write-Host ''
    Write-Host '  +------------------------------------------------------------+' -ForegroundColor DarkMagenta
    Write-Host '  |  ' -NoNewline -ForegroundColor DarkMagenta; Write-Host '<BIG YIKES>' -NoNewline -ForegroundColor Magenta; Write-Host '                                               |' -ForegroundColor DarkMagenta
    Write-Host '  |  ' -NoNewline -ForegroundColor DarkMagenta; Write-Host 'YIKESHEIM' -NoNewline -ForegroundColor White; Write-Host '  Valheim server mod installer' -NoNewline -ForegroundColor Gray; Write-Host '                   |' -ForegroundColor DarkMagenta
    Write-Host '  |  ' -NoNewline -ForegroundColor DarkMagenta; Write-Host 'valheim.yikesgaming.com' -NoNewline -ForegroundColor Cyan; Write-Host '                                   |' -ForegroundColor DarkMagenta
    Write-Host '  +------------------------------------------------------------+' -ForegroundColor DarkMagenta
    Write-Host ''
    Say "  What you're getting:" 'White'
    Say '    BepInEx 5.4.2351         the mod loader everything else runs on'
    Say '    Valheim Plus 10.2.0      2x drops, half weight, bigger stacks (the server sends its settings)'
    Say '    Runic Character Vault    keeps your Yikesheim character safe on the server'
    Say '  Nothing else on your PC changes. Your other characters and worlds are untouched.'
    Say ''
    Say '  [1/4] Finding Valheim...' 'White'

    # 1. Find Valheim through Steam's library list
    $steam = $null
    foreach ($key in 'HKCU:\Software\Valve\Steam', 'HKLM:\SOFTWARE\WOW6432Node\Valve\Steam', 'HKLM:\SOFTWARE\Valve\Steam') {
      $p = Get-ItemProperty $key -ErrorAction SilentlyContinue
      if ($p) { foreach ($n in 'SteamPath', 'InstallPath') { if ($p.$n -and (Test-Path $p.$n)) { $steam = $p.$n; break } } }
      if ($steam) { break }
    }
    if (-not $steam) { Fail 'Could not find Steam. Is Steam installed on this PC?' }
    $libs = @($steam)
    $vdf = Join-Path $steam 'steamapps\libraryfolders.vdf'
    if (Test-Path $vdf) {
      foreach ($m in [regex]::Matches((Get-Content $vdf -Raw), '"path"\s+"([^"]+)"')) { $libs += ($m.Groups[1].Value -replace '\\\\', '\') }
    }
    $game = $null
    foreach ($lib in ($libs | Select-Object -Unique)) {
      $c = Join-Path $lib 'steamapps\common\Valheim'
      if (Test-Path (Join-Path $c 'valheim.exe')) { $game = $c; break }
    }
    if (-not $game) { Fail 'Found Steam, but not Valheim. Install Valheim from your Steam Library first.' }
    Say "        $game"

    # 2. Valheim must be closed so its files can be replaced
    if (Get-Process valheim -ErrorAction SilentlyContinue) { Fail 'Valheim is running. Close the game, then run this again.' }

    Say '  [2/4] Downloading and checking the mods...' 'White'
    # 3. Download and verify
    $work = Join-Path $env:TEMP ('bigyikes-mods-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
    New-Item -ItemType Directory -Force $work | Out-Null
    $ProgressPreference = 'SilentlyContinue'
    $i = 0
    foreach ($mod in $mods) {
      $i++
      $zip = Join-Path $work "mod$i.zip"
      Say "        $($mod.Name)"
      Invoke-WebRequest $mod.Url -OutFile $zip -UseBasicParsing
      $hash = (Get-FileHash $zip -Algorithm SHA256).Hash
      if ($hash -ne $mod.Sha256) { Fail "The $($mod.Name) download didn't match its expected checksum, so it wasn't installed." }
      Expand-Archive $zip -DestinationPath (Join-Path $work "mod$i") -Force
    }

    Say '  [3/4] Installing...' 'White'
    # 4. Install: BepInEx pack contents go next to valheim.exe, the V+ plugin goes into BepInEx\plugins
    $off = Join-Path $game 'winhttp.dll.off'
    try {
      Copy-Item (Join-Path $work 'mod1\BepInExPack_Valheim\*') $game -Recurse -Force
      $plugins = Join-Path $game 'BepInEx\plugins'
      New-Item -ItemType Directory -Force $plugins | Out-Null
      Copy-Item (Join-Path $work 'mod2\BepInEx\plugins\ValheimPlus.dll') $plugins -Force
      Copy-Item (Join-Path $work 'mod3\plugins\RunicCharacterVault') $plugins -Recurse -Force
      $lang = Join-Path $plugins 'RunicCharacterVault\Translations\RunicCharacterVault\English.json'
      if (Test-Path $lang) {
        $text = Get-Content $lang -Raw -Encoding UTF8 | ConvertFrom-Json
        foreach ($k in $vaultMessages.Keys) { $text | Add-Member -NotePropertyName $k -NotePropertyValue $vaultMessages[$k] -Force }
        [IO.File]::WriteAllText($lang, ($text | ConvertTo-Json -Depth 3), (New-Object Text.UTF8Encoding $false))
      }
      if (Test-Path $off) { Remove-Item $off -Force }
    } catch [UnauthorizedAccessException] {
      Fail 'Windows blocked writing to the Valheim folder. Open PowerShell with "Run as administrator" and run the command again.'
    }
    Remove-Item $work -Recurse -Force -ErrorAction SilentlyContinue

    Say '  [4/4] Done.' 'White'
    Say ''
    Say '  You are ready for Yikesheim.' 'Green'
    Say '    1. Launch Valheim from Steam and CREATE A NEW CHARACTER (existing ones are refused).' 'Yellow'
    Say '    2. Join Game > Join IP > valheim.yikesgaming.com > Connect'
    Say '    3. Password: pinned in #other-games on the Big Yikes Discord'
    Say ''
    Say '  Guide: https://yikesgaming.com/valheim/'
    Say '  Play unmodded later: irm https://yikesgaming.com/valheim/uninstall.ps1 | iex'
    Say ''
  } catch {
    if ($_.Exception.Message -ne 'stop') { Write-Host "Install failed: $($_.Exception.Message)" -ForegroundColor Red }
  }
}
