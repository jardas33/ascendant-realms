$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$Runtime = Join-Path $RepoRoot 'artifacts\runtime\v0347\screenshots'
$Pack = Join-Path $RepoRoot 'artifacts\manual-review\v0347-barn-rendered-geometry-truth\UPLOAD_TO_CHAT'
if (Test-Path -LiteralPath $Pack) { Get-ChildItem -LiteralPath $Pack -Force | Remove-Item -Force }
New-Item -ItemType Directory -Force -Path $Pack | Out-Null

function New-Board([string]$path, [array]$items, [string]$title) {
  $canvas = New-Object System.Drawing.Bitmap(1600, 900)
  $graphics = [System.Drawing.Graphics]::FromImage($canvas)
  $graphics.Clear([System.Drawing.Color]::FromArgb(55, 64, 58))
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

New-Board (Join-Path $Pack '01_FINAL_FRONT_AND_HORIZONTAL_MASS.png') @(
  @{file='01_front_three_quarter.png';x=25;y=90;w=1000;h=700;caption='Actual front three-quarter: broad agricultural mass, lower door, upper opening, slate roof'};
  @{file='02_direct_front_orthographic.png';x=1050;y=90;w=525;h=700;caption='Actual direct front: horizontal wall/eave proportion and intact openings'}
) 'V0.347 FINAL FRONT AND HORIZONTAL MASS'
New-Board (Join-Path $Pack '02_COMPLETE_GRANITE_GABLES.png') @(
  @{file='03_direct_side_gable.png';x=25;y=90;w=1000;h=700;caption='Actual direct side: complete solid granite end gable from eave to ridge'};
  @{file='01_front_three_quarter.png';x=1050;y=90;w=525;h=700;caption='Actual three-quarter: granite wall continuity and roof edge'}
) 'V0.347 COMPLETE GRANITE GABLE AND WALL TRUTH'
New-Board (Join-Path $Pack '03_HOUSE02_SLATE_AND_ROOF_PITCH.png') @(
  @{file='04_roof_close_up.png';x=25;y=90;w=1000;h=700;caption='Actual roof close-up: House02 slate tile texture, two slopes, straight ridge'};
  @{file='03_direct_side_gable.png';x=1050;y=90;w=525;h=700;caption='Actual side/gable: measured restrained 20 degree roof profile'}
) 'V0.347 HOUSE02 SLATE AND ROOF PITCH'
New-Board (Join-Path $Pack '04_TRUE_MATCHED_FRONT_512X256.png') @(
  @{file='05_true_matched_front_512x256.png';x=40;y=120;w=1520;h=760;caption='Actual direct render: frozen House02 left / v0.347 barn right; each source panel is 256x256'}
) 'V0.347 TRUE MATCHED HOUSE02 FRONT COMPARISON'

$manifest = Get-Content (Join-Path $RepoRoot 'artifacts\runtime\v0347\v0347-barn-rendered-geometry-truth-runtime.json') -Raw | ConvertFrom-Json
$metrics = Get-Content (Join-Path $RepoRoot 'art-source\blender\v0347\v0347-barn-rendered-geometry-metrics.json') -Raw | ConvertFrom-Json
$diagnosis = Get-Content (Join-Path $RepoRoot 'art-source\blender\v0347\v0347-transform-and-geometry-diagnosis.json') -Raw | ConvertFrom-Json
$files = Get-ChildItem -LiteralPath $Pack -File | Sort-Object Name
$summary = [ordered]@{
  checkpoint='v0.347'; outcome=$manifest.outcome; automatedVisualApproval=$false; humanReviewRequired=$true
  sourceCaptureCount=$manifest.rawCaptureCount; sourceCaptures=@($manifest.captures | ForEach-Object {$_.fileName})
  exactSourceCountBeforePackaging=5; finalRawSourceSet='artifacts/runtime/v0347/screenshots/'
  finalRawSourceSetFiles=@('01_front_three_quarter.png','02_direct_front_orthographic.png','03_direct_side_gable.png','04_roof_close_up.png','05_true_matched_front_512x256.png')
  worldSpaceSlopes=$metrics.v0347WorldSpaceSlopes; v0346ActualSourceGeometry=$metrics.v0346ActualSourceGeometry
  frontWidth=$metrics.frontWidth; wallEaveHeight=$metrics.wallEaveHeight; totalRidgeHeight=$metrics.totalRidgeHeight
  roofPercentOfTotalHeight=$metrics.roofPercentOfTotalHeight; roof=$metrics.roof; openings=$metrics.openings
  trueMatchedComparison=[ordered]@{file='05_true_matched_front_512x256.png';width=512;height=256;leftPanel='frozen House02 rendered directly';rightPanel='v0.347 barn rendered directly';eachPanel='256x256'}
  transformDiagnosis=$diagnosis.v0347; reviewPackFiles=@('00_READ_ME_FIRST.md','01_FINAL_FRONT_AND_HORIZONTAL_MASS.png','02_COMPLETE_GRANITE_GABLES.png','03_HOUSE02_SLATE_AND_ROOF_PITCH.png','04_TRUE_MATCHED_FRONT_512X256.png','compact-evidence-summary.json')
  exactlySixReviewFiles=$true; exactlyFourPng=$true; noVideo=$true; noTitleCardOnlyEvidence=$true; noDefaultRuntimeIntegration=$true; noGameplay=$true
  sourceHashes=$metrics.sourceHashes; finalHashes=$metrics.finalHashes
}
$summary | ConvertTo-Json -Depth 24 | Set-Content (Join-Path $Pack 'compact-evidence-summary.json') -Encoding UTF8
@"
# v0.347 rendered-geometry truth repair

Outcome: **$($manifest.outcome)**

Automated visual approval is false and human review remains required. v0.346 remains the rejected human-review candidate and is not marked gold, accepted, or production-ready. This upload pack contains only the isolated v0.347 derivative and its rendered evidence.

Exactly six upload files are present: four actual rendered boards, this readme, and compact-evidence-summary.json. The five unlabelled source renders remain under artifacts/runtime/v0347/screenshots/ and are not extra upload files.

Capture command: npm run godot:capture:salto-v0347-barn-rendered-geometry-truth
Pack command: npm run godot:pack:salto-v0347-barn-rendered-geometry-truth
Validator command: npm run godot:validate:salto-v0347-barn-rendered-geometry-truth

The source set was exactly five real Godot renders before packaging: front three-quarter, direct front, direct side/gable, roof close-up, and the true 512x256 matched House02-left/barn-right comparison. No video, title card, embedded reference image, or fallback frame is used.

Geometry truth: final world-space roof pitch is 20 degrees on both measured slopes, with one straight ridge; final roof rise is approximately 34 percent of total building height. The gables are solid granite geometry and the roof uses the frozen House02 slate tile lineage with an explicit active UV contract.

No default runtime, gameplay, save, stable-ID, movement, pathfinding, combat, economy, or resource change is included. The scene is an opt-in review-only fixture.
"@ | Set-Content (Join-Path $Pack '00_READ_ME_FIRST.md') -Encoding UTF8
if ((Get-ChildItem -LiteralPath $Pack -File).Count -ne 6) { throw 'v0.347 upload pack must contain exactly six files' }
Write-Output 'PASS_V0347_BARN_RENDERED_GEOMETRY_TRUTH_PACK_BUILT'
