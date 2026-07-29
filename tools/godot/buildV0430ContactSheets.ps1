param(
  [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$pack = Join-Path $RepoRoot 'artifacts/manual-review/v0430-tesana-canonical-production-rebase'
$production = Join-Path $RepoRoot 'production/ascendant-realms-godot'
New-Item -ItemType Directory -Force -Path $pack | Out-Null

function Get-ImageFiles([string[]]$Patterns, [int]$Limit = 12) {
  $files = Get-ChildItem -LiteralPath $production -Recurse -File |
    Where-Object { $Patterns -contains $_.Extension.ToLowerInvariant() -and $_.FullName -notlike '*\.godot\*' -and $_.FullName -notlike '*\artifacts\*' } |
    Sort-Object FullName |
    Select-Object -First $Limit
  return @($files)
}

function New-Sheet([string]$OutputName, [object[]]$Items, [string]$Title) {
  $width = 1920
  $cellW = 460
  $cellH = 300
  $cols = 4
  $rows = [Math]::Max(1, [Math]::Ceiling($Items.Count / $cols))
  $height = 92 + ($rows * $cellH)
  $bmp = New-Object System.Drawing.Bitmap($width, $height)
  $gfx = [System.Drawing.Graphics]::FromImage($bmp)
  $gfx.Clear([System.Drawing.Color]::FromArgb(22, 27, 31))
  $fontTitle = New-Object System.Drawing.Font('Segoe UI', 24, [System.Drawing.FontStyle]::Bold)
  $fontLabel = New-Object System.Drawing.Font('Segoe UI', 11, [System.Drawing.FontStyle]::Regular)
  $white = [System.Drawing.Brushes]::White
  $muted = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(190, 205, 210))
  $gfx.DrawString($Title, $fontTitle, $white, 24, 20)
  for ($i = 0; $i -lt $Items.Count; $i++) {
    $item = $Items[$i]
    $x = 20 + (($i % $cols) * $cellW)
    $y = 82 + ([Math]::Floor($i / $cols) * $cellH)
    $rect = [System.Drawing.Rectangle]::new([int]$x, [int]$y, [int]($cellW - 18), [int]($cellH - 42))
    try {
      $img = [System.Drawing.Image]::FromFile($item.FullName)
      $scale = [Math]::Min($rect.Width / $img.Width, $rect.Height / $img.Height)
      $dw = [int]($img.Width * $scale)
      $dh = [int]($img.Height * $scale)
      $dx = $rect.X + [int](($rect.Width - $dw) / 2)
      $dy = $rect.Y + [int](($rect.Height - $dh) / 2)
      $gfx.DrawImage($img, $dx, $dy, $dw, $dh)
      $img.Dispose()
    } catch {
      $gfx.FillRectangle([System.Drawing.Brushes]::DarkRed, $rect)
    }
    $label = [IO.Path]::GetFileName($item.FullName)
    $gfx.DrawString($label, $fontLabel, $muted, $x, $y + $rect.Height + 5)
  }
  $out = Join-Path $pack $OutputName
  $bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
  $gfx.Dispose(); $bmp.Dispose(); $fontTitle.Dispose(); $fontLabel.Dispose(); $muted.Dispose()
  Write-Host "$OutputName ($($Items.Count) source images)"
}

$reviewFrames = @(
  '01_PRODUCTION_TITLE_SCREEN.png', '02_PRODUCTION_SKIRMISH_SETUP.png',
  '05_PRODUCTION_CAMPAIGN_MAP.png', '07_PRODUCTION_GAMEPLAY_LOADED.png',
  '08_PRODUCTION_WORKER_SELECTED.png', '09_PRODUCTION_WORKER_MOVED.png',
  '11_PRODUCTION_BUILD_PLACEMENT.png', '12_PRODUCTION_HERO_SCREEN.png'
) | ForEach-Object { Get-Item (Join-Path $pack $_) -ErrorAction SilentlyContinue } | Where-Object { $_ }
New-Sheet '16_PRODUCTION_RUNTIME_CONTACT_SHEET.png' @($reviewFrames) 'v0.430 real runtime frames'

$allAssets = Get-ImageFiles @('.png', '.jpg', '.jpeg') 16
New-Sheet '17_PRODUCTION_ASSET_CONTACT_SHEET.png' @($allAssets) 'v0.430 exported production image assets'

$unitAssets = $allAssets | Where-Object { $_.Name -match '(unit|worker|militia|hero|soldier|aster|defender)' } | Select-Object -First 12
if ($unitAssets.Count -lt 4) { $unitAssets = $allAssets | Select-Object -First 12 }
New-Sheet '14_PRODUCTION_ASSET_GALLERY_UNITS.png' @($unitAssets) 'v0.430 unit/source-asset gallery'

$buildingAssets = $allAssets | Where-Object { $_.Name -match '(house|barn|building|barrack|hall|keep|workshop|tower)' } | Select-Object -First 12
if ($buildingAssets.Count -lt 4) { $buildingAssets = $allAssets | Select-Object -Skip 12 -First 12 }
New-Sheet '15_PRODUCTION_ASSET_GALLERY_BUILDINGS.png' @($buildingAssets) 'v0.430 building/source-asset gallery'

$comparisonItems = @(
  Get-Item (Join-Path $pack '01_PRODUCTION_TITLE_SCREEN.png') -ErrorAction SilentlyContinue
  Get-Item (Join-Path $pack '07_PRODUCTION_GAMEPLAY_LOADED.png') -ErrorAction SilentlyContinue
  Get-Item (Join-Path $pack '17_PRODUCTION_ASSET_CONTACT_SHEET.png') -ErrorAction SilentlyContinue
)
New-Sheet '18_ORIGINAL_EXPORT_PRODUCTION_COPY_HASH_COMPARISON.png' @($comparisonItems | Where-Object { $_ }) 'v0.430 original export / production-copy evidence'
