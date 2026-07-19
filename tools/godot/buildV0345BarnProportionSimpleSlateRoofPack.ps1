$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$Runtime = Join-Path $RepoRoot 'artifacts\runtime\v0345\screenshots'
$Pack = Join-Path $RepoRoot 'artifacts\manual-review\v0345-barn-proportion-and-simple-slate-roof\UPLOAD_TO_CHAT'
if (Test-Path -LiteralPath $Pack) { Get-ChildItem -LiteralPath $Pack -Force | Remove-Item -LiteralPath {$_.FullName} -Force }
New-Item -ItemType Directory -Force -Path $Pack | Out-Null

function New-Board([string]$path, [array]$items, [string]$title) {
  $canvas = New-Object System.Drawing.Bitmap(1600, 900)
  $graphics = [System.Drawing.Graphics]::FromImage($canvas)
  $graphics.Clear([System.Drawing.Color]::FromArgb(39, 47, 42))
  $font = New-Object System.Drawing.Font('Arial', 20, [System.Drawing.FontStyle]::Bold)
  $small = New-Object System.Drawing.Font('Arial', 14, [System.Drawing.FontStyle]::Regular)
  $graphics.DrawString($title, $font, [System.Drawing.Brushes]::White, 28, 22)
  foreach ($item in $items) {
    $image = [System.Drawing.Image]::FromFile((Join-Path $Runtime $item.file))
    $rect = New-Object System.Drawing.Rectangle($item.x, $item.y, $item.w, $item.h)
    $graphics.DrawImage($image, $rect)
    $graphics.DrawString($item.caption, $small, [System.Drawing.Brushes]::White, $item.x, ($item.y + $item.h + 8))
    $image.Dispose()
  }
  $canvas.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
  $graphics.Dispose(); $canvas.Dispose(); $font.Dispose(); $small.Dispose()
}

New-Board (Join-Path $Pack '01_PROPORTION_RESET_AND_HOUSE02_SCALE.png') @(
  @{file='05_true_matched_512x256_house02_barn.png';x=40;y=100;w=1520;h=760;caption='Frozen House02 rendered directly at left; v0.345 barn at right; true 512x256 source is preserved in runtime captures'}
) 'V0.345 PROPORTION RESET - HOUSE02 RELATIVE SCALE'
New-Board (Join-Path $Pack '02_UNLABELLED_FRONT_REAR_AND_GABLE.png') @(
  @{file='01_front_three_quarter.png';x=25;y=90;w=500;h=700;caption='Front three-quarter source render'}
  @{file='02_rear_three_quarter.png';x=550;y=90;w=500;h=700;caption='Rear three-quarter source render'}
  @{file='03_direct_side_gable.png';x=1075;y=90;w=500;h=700;caption='Direct side/gable source render'}
) 'V0.345 UNLABELLED SOURCE VIEW SET'
New-Board (Join-Path $Pack '03_SIMPLE_TWO_SLOPE_SLATE_ROOF.png') @(
  @{file='04_close_roof_front_material.png';x=25;y=90;w=1000;h=700;caption='Close roof/front material source render'}
  @{file='03_direct_side_gable.png';x=1050;y=90;w=525;h=700;caption='Complete roof silhouette source render'}
) 'V0.345 SIMPLE SLATE ROOF - TWO SLOPES, STRAIGHT RIDGE, RESTRAINED EDGE'
New-Board (Join-Path $Pack '04_TRUE_MATCHED_512X256_COMPARISON.png') @(
  @{file='05_true_matched_512x256_house02_barn.png';x=40;y=120;w=1520;h=760;caption='Actual 512x256 source: 256x256 frozen House02 panel + 256x256 v0.345 barn panel'}
) 'V0.345 TRUE MATCHED HOUSE02 / BARN COMPARISON'

$runtimeManifest = Get-Content (Join-Path $RepoRoot 'artifacts\runtime\v0345\v0345-barn-proportion-simple-slate-roof-runtime.json') -Raw | ConvertFrom-Json
$metrics = Get-Content (Join-Path $RepoRoot 'art-source\blender\v0345\v0345-barn-metrics.json') -Raw | ConvertFrom-Json
$files = Get-ChildItem -LiteralPath $Pack -File | Sort-Object Name
$summary = [ordered]@{
  checkpoint = 'v0.345'
  outcome = $runtimeManifest.outcome
  automatedVisualApproval = $false
  humanReviewRequired = $true
  sourceCaptureCount = $runtimeManifest.captureCount
  sourceCaptures = @($runtimeManifest.captures | ForEach-Object { $_.fileName })
  trueComparison = [ordered]@{ file = '05_true_matched_512x256_house02_barn.png'; width = 512; height = 256; leftPanel = 'frozen House02 rendered directly'; rightPanel = 'v0.345 barn rendered directly'; eachPanel = '256x256' }
  ratiosBefore = $metrics.ratiosBefore
  ratiosAfter = $metrics.ratiosAfter
  roof = $metrics.roof
  reviewPackFiles = @($files | ForEach-Object { $_.Name })
  exactlySixReviewFiles = ($files.Count -eq 6)
  exactlyFourPng = (($files | Where-Object Extension -eq '.png').Count -eq 4)
  noVideo = (($files | Where-Object Extension -in @('.mp4','.webm','.mov')).Count -eq 0)
  noDefaultRuntimeIntegration = $true
  noGameplay = $true
  sourceHashes = [ordered]@{
    v0344Blend = $metrics.sourceHashes.v0344Blend
    v0344CopiedForV0345 = $metrics.sourceHashes.v0344CopiedForV0345
    house02Blend = $metrics.sourceHashes.house02Blend
    house02GLB = $metrics.sourceHashes.house02GLB
    v0345Blend = (Get-FileHash -Algorithm SHA256 (Join-Path $RepoRoot 'art-source\blender\v0345\barn_proportion_simple_slate_roof_reset.blend')).Hash.ToLower()
    v0345GLB = (Get-FileHash -Algorithm SHA256 (Join-Path $RepoRoot 'desktop-spikes\godot-salto\assets\v0345\barn_proportion_simple_slate_roof_reset.glb')).Hash.ToLower()
  }
}
$summary | ConvertTo-Json -Depth 12 | Set-Content (Join-Path $Pack 'compact-evidence-summary.json') -Encoding UTF8
@"
# v0.345 House02-derived barn proportion and simple slate roof reset

Outcome: **$($runtimeManifest.outcome)**

Automated visual approval is false; human visual review remains required. This pack contains exactly six files: four boards, this readme, and `compact-evidence-summary.json`. The five unlabelled source captures live under `artifacts/runtime/v0345/screenshots/` and are not additional upload-pack files.

The candidate is a new isolated derivative of v0.344. v0.344 remains rejected by human review and is not marked gold, accepted, or production-ready. Frozen House02, v0.343, and v0.344 source assets remain untouched.

Source capture command: `npm run godot:capture:salto-v0345-barn-proportion-and-simple-slate-roof`

The true comparison is an actual 512x256 render: frozen House02 on the left and v0.345 on the right, each 256x256. No old board or embedded reference image is used. No gameplay, runtime integration, save, stable-ID, or default-runtime change is included.
"@ | Set-Content (Join-Path $Pack '00_READ_ME_FIRST.md') -Encoding UTF8
if ((Get-ChildItem -LiteralPath $Pack -File).Count -ne 6) { throw 'v0.345 review pack must contain exactly six files' }
Write-Output 'PASS_V0345_BARN_PROPORTION_SIMPLE_SLATE_ROOF_PACK_BUILT'
