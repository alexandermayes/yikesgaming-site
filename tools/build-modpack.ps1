# Builds valheim/Yikesheim-mods.zip: everything a player extracts into their Valheim folder (no scripts, no apps).
# Pinned versions + SHA-256 match valheim/install.ps1. Re-run after bumping versions there.
# Usage: pwsh tools/build-modpack.ps1
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$work = Join-Path ([IO.Path]::GetTempPath()) "yikes-modpack-$PID"
$stage = Join-Path $work 'stage'
New-Item -ItemType Directory -Force $stage | Out-Null

$mods = @(
  @{ Key = 'bep';  Url = 'https://thunderstore.io/package/download/denikson/BepInExPack_Valheim/5.4.2351/'; Sha256 = 'BCE631497976A93977CEB08E166712E6C31D15244956F89F17DF092A9B62E29F' },
  @{ Key = 'vp';   Url = 'https://thunderstore.io/package/download/Grantapher/ValheimPlus_Grantapher_Temporary/10.2.0/'; Sha256 = '1D53F0636538D2F21273CA8CB0CA75B2A00F0B373BC54B02F5369E1CFBED1539' },
  @{ Key = 'rcv';  Url = 'https://thunderstore.io/package/download/Chazman/RunicCharacterVault/1.0.3/'; Sha256 = 'D1B63EA6BC648C92DB78DA7DB51F550F8539E4786A0979EBAD5EE6F2A3E216B7' }
)
foreach ($m in $mods) {
  $zip = Join-Path $work "$($m.Key).zip"
  Invoke-WebRequest $m.Url -OutFile $zip -UseBasicParsing
  if ((Get-FileHash $zip -Algorithm SHA256).Hash -ne $m.Sha256) { throw "Checksum mismatch for $($m.Key)" }
  Expand-Archive $zip (Join-Path $work $m.Key) -Force
}

# BepInEx: the Windows loader files and the BepInEx folder (skip the Linux/macOS launch scripts)
$bep = Join-Path $work 'bep\BepInExPack_Valheim'
foreach ($f in 'winhttp.dll', 'doorstop_config.ini', '.doorstop_version') { Copy-Item (Join-Path $bep $f) $stage }
Copy-Item (Join-Path $bep 'BepInEx') $stage -Recurse
$plugins = Join-Path $stage 'BepInEx\plugins'
New-Item -ItemType Directory -Force $plugins | Out-Null
Copy-Item (Join-Path $work 'vp\BepInEx\plugins\ValheimPlus.dll') $plugins
Copy-Item (Join-Path $work 'rcv\plugins\RunicCharacterVault') $plugins -Recurse

# Same plain-language join messages as install.ps1
$lang = Join-Path $plugins 'RunicCharacterVault\Translations\RunicCharacterVault\English.json'
$text = Get-Content $lang -Raw -Encoding UTF8 | ConvertFrom-Json
$msgs = @{
  'text_25ddcadc5976' = 'Yikesheim needs a brand-new character. Go back, create a new character, and join with that one. Your existing character is safe and still works everywhere else.'
  'text_cf24dc035c05' = 'You already have a character on Yikesheim: {0}. Join with that character.'
  'text_b99199e4c3cc' = 'You already have characters on Yikesheim: {0}. Join with one of those.'
}
foreach ($k in $msgs.Keys) { $text | Add-Member -NotePropertyName $k -NotePropertyValue $msgs[$k] -Force }
[IO.File]::WriteAllText($lang, ($text | ConvertTo-Json -Depth 3), (New-Object Text.UTF8Encoding $false))

# Licenses and where to get the source, kept inside BepInEx so the Valheim folder stays tidy
$notices = Join-Path $stage 'BepInEx\Yikesheim-mods'
New-Item -ItemType Directory -Force $notices | Out-Null
Copy-Item (Join-Path $work 'rcv\LICENSE') (Join-Path $notices 'RunicCharacterVault-LICENSE.txt')
Copy-Item (Join-Path $work 'rcv\NOTICE.md') (Join-Path $notices 'RunicCharacterVault-NOTICE.md')
@'
Yikesheim mod pack (Big Yikes guild Valheim server)
https://yikesgaming.com/valheim/

Unmodified releases of the following, repackaged for one-step install:

- BepInExPack for Valheim 5.4.2351 (denikson). BepInEx is licensed under LGPL-2.1.
  Source: https://github.com/BepInEx/BepInEx  Package: https://thunderstore.io/c/valheim/p/denikson/BepInExPack_Valheim/
- Valheim Plus 10.2.0 (Grantapher fork). Licensed under AGPL-3.0.
  Source: https://github.com/Grantapher/ValheimPlus  Package: https://thunderstore.io/c/valheim/p/Grantapher/ValheimPlus_Grantapher_Temporary/
- Runic Character Vault 1.0.3 (Chazman). MIT License, see RunicCharacterVault-LICENSE.txt and -NOTICE.md.
  Source: https://github.com/ChazmanMods/ValheimMods  Package: https://thunderstore.io/c/valheim/p/Chazman/RunicCharacterVault/
  The only change: three join messages in Translations/RunicCharacterVault/English.json are reworded for Yikesheim.

To turn the mods off, rename winhttp.dll in your Valheim folder to winhttp.dll.off.
'@ | Set-Content (Join-Path $notices 'README.txt') -Encoding utf8NoBOM

# Shown first when someone opens the zip
@'
<BIG YIKES>  YIKESHEIM
Valheim Plus server for the Big Yikes guild
valheim.yikesgaming.com
====================================================

WHAT'S IN HERE
  BepInEx 5.4.2351        the mod loader everything else runs on
  Valheim Plus 10.2.0     2x drops, half weight, bigger stacks
                          (the server sends its own settings when you join)
  Runic Character Vault   keeps your Yikesheim character safe on the server

INSTALL (about a minute)
  1. Close Valheim.
  2. In Steam, right-click Valheim > Manage > Browse local files.
  3. Extract everything in this zip into that folder, so winhttp.dll
     sits next to valheim.exe. Say yes if Windows asks to replace files.
  4. Launch Valheim from Steam and CREATE A NEW CHARACTER.
     Yikesheim only accepts brand-new characters.
  5. Join Game > Join IP > valheim.yikesgaming.com > Connect.
     The password is pinned in #valheim on the Big Yikes Discord.

TURN THE MODS OFF
  Rename winhttp.dll in your Valheim folder to winhttp.dll.off.
  Rename it back to turn them on again.

Full guide and troubleshooting: https://yikesgaming.com/valheim/
Licenses and sources: BepInEx\Yikesheim-mods\README.txt
'@ | Set-Content (Join-Path $stage 'Yikesheim - READ ME FIRST.txt') -Encoding utf8NoBOM

$out = Join-Path $root 'valheim\Yikesheim-mods.zip'
Compress-Archive (Join-Path $stage '*') $out -Force
Remove-Item $work -Recurse -Force
"{0} ({1:N0} KB)" -f $out.Substring($root.Length + 1), ((Get-Item $out).Length / 1KB)
