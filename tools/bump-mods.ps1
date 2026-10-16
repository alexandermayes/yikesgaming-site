# Keeps the Yikesheim mod pins current. Run by .github/workflows/mods.yml every hour (or by hand: pwsh tools/bump-mods.ps1).
#
# Asks Thunderstore for the newest BepInExPack, Valheim Plus (Grantapher) and Runic Character Vault. For any that is
# newer than what valheim/install.ps1 pins, it downloads the package, takes its SHA-256, and rewrites the version, URL
# and checksum in valheim/install.ps1 and tools/build-modpack.ps1, the version names in those scripts' player-facing
# text and valheim/index.html, then rebuilds valheim/Yikesheim-mods.zip. It also refreshes "for Valheim x.y.z" on the
# page from the newest "Patch x.y.z" post in Valheim's Steam news.
#
# The server follows these pins on its own (big-yikes-bot/valheim/deploy/auto-update.sh reads install.ps1 from the live
# site), so a commit here is what rolls a mod update out to everyone. Exit code 0 and "changed" on stdout when it did.
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$installer = Join-Path $root 'valheim\install.ps1'
$builder = Join-Path $root 'tools\build-modpack.ps1'
$page = Join-Path $root 'valheim\index.html'

$packages = @(
  @{ Name = 'BepInEx';               Owner = 'denikson';   Pkg = 'BepInExPack_Valheim' },
  @{ Name = 'Valheim Plus';          Owner = 'Grantapher'; Pkg = 'ValheimPlus_Grantapher_Temporary' },
  @{ Name = 'Runic Character Vault'; Owner = 'Chazman';    Pkg = 'RunicCharacterVault' }
)

$files = @{}
foreach ($f in $installer, $builder, $page) { $files[$f] = Get-Content $f -Raw -Encoding UTF8 }
$changed = @()

foreach ($p in $packages) {
  $m = [regex]::Match($files[$installer], "Name = '$([regex]::Escape($p.Name)) (?<ver>[0-9.]+)'; Url = '(?<url>[^']+)'; Sha256 = '(?<sha>[0-9A-F]+)'")
  if (-not $m.Success) { throw "No pin for $($p.Name) in install.ps1" }
  $cur = $m.Groups['ver'].Value
  $info = Invoke-RestMethod "https://thunderstore.io/api/experimental/package/$($p.Owner)/$($p.Pkg)/" -UseBasicParsing
  $new = $info.latest.version_number
  if ([version]$new -le [version]$cur) { Write-Host "$($p.Name): $cur is current"; continue }

  $url = "https://thunderstore.io/package/download/$($p.Owner)/$($p.Pkg)/$new/"
  $tmp = Join-Path ([IO.Path]::GetTempPath()) "$($p.Pkg)-$new.zip"
  Invoke-WebRequest $url -OutFile $tmp -UseBasicParsing
  $sha = (Get-FileHash $tmp -Algorithm SHA256).Hash
  Write-Host "$($p.Name): $cur -> $new ($sha)"

  $oldUrl = [regex]::Escape($m.Groups['url'].Value); $oldSha = $m.Groups['sha'].Value
  foreach ($f in @($files.Keys)) {
    $t = $files[$f]
    $t = [regex]::Replace($t, $oldUrl, $url)
    $t = $t.Replace($oldSha, $sha)
    $t = [regex]::Replace($t, "$([regex]::Escape($p.Name)) $([regex]::Escape($cur))\b", "$($p.Name) $new")
    $files[$f] = $t
  }
  $changed += "$($p.Name) $new"
}

# "for Valheim 1.0.20" on the page follows the newest "Patch x.y.z" news post
try {
  $news = Invoke-RestMethod 'https://api.steampowered.com/ISteamNews/GetNewsForApp/v2/?appid=892970&count=15&maxlength=1' -UseBasicParsing
  $patch = ($news.appnews.newsitems | Where-Object { $_.title -match '^Patch (\d+\.\d+\.\d+)$' } | Select-Object -First 1)
  if ($patch) {
    $v = [regex]::Match($patch.title, '\d+\.\d+\.\d+').Value
    $pm = [regex]::Match($files[$page], 'for Valheim (\d+\.\d+\.\d+)')
    if ($pm.Success -and $pm.Groups[1].Value -ne $v) {
      $files[$page] = $files[$page].Replace($pm.Value, "for Valheim $v"); $changed += "Valheim $v"
    }
  }
} catch { Write-Host "Steam news unavailable, leaving the Valheim version as is" }

if ($changed.Count -eq 0) { Write-Host 'nothing to do'; exit 0 }
$utf8 = New-Object Text.UTF8Encoding $false
foreach ($f in $files.Keys) { [IO.File]::WriteAllText($f, $files[$f], $utf8) }
& $builder
Write-Output "changed: $($changed -join ', ')"
