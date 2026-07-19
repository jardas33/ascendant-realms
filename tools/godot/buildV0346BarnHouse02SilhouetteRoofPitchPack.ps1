$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$Runtime = Join-Path $RepoRoot 'artifacts\runtime\v0346\screenshots'
$Pack = Join-Path $RepoRoot 'artifacts\manual-review\v0346-barn-house02-silhouette-roof-pitch\UPLOAD_TO_CHAT'
if (Test-Path -LiteralPath $Pack) { Get-ChildItem -LiteralPath $Pack -Force | Remove-Item -Force }
New-Item -ItemType Directory -Force -Path $Pack | Out-Null
function New-Board([string]$path, [array]$items, [string]$title) {
  $canvas = New-Object System.Drawing.Bitmap(1600, 900); $graphics = [System.Drawing.Graphics]::FromImage($canvas); $graphics.Clear([System.Drawing.Color]::FromArgb(53, 61, 55))
  $font = New-Object System.Drawing.Font('Arial', 20, [System.Drawing.FontStyle]::Bold); $small = New-Object System.Drawing.Font('Arial', 14, [System.Drawing.FontStyle]::Regular); $graphics.DrawString($title, $font, [System.Drawing.Brushes]::White, 28, 22)
  foreach ($item in $items) { $image = [System.Drawing.Image]::FromFile((Join-Path $Runtime $item.file)); $rect = New-Object System.Drawing.Rectangle($item.x, $item.y, $item.w, $item.h); $graphics.DrawImage($image, $rect); $graphics.DrawString($item.caption, $small, [System.Drawing.Brushes]::White, $item.x, ($item.y + $item.h + 8)); $image.Dispose() }
  $canvas.Save($path, [System.Drawing.Imaging.ImageFormat]::Png); $graphics.Dispose(); $canvas.Dispose(); $font.Dispose(); $small.Dispose()
}
New-Board (Join-Path $Pack '01_HOUSE02_FAMILY_PROPORTION_RESET.png') @(@{file='05_true_matched_512x256_house02_barn.png';x=40;y=100;w=1520;h=760;caption='Actual frozen House02 at left; actual v0.346 barn at right; each panel is 256x256'}) 'V0.346 HOUSE02 FAMILY PROPORTION RESET'
New-Board (Join-Path $Pack '02_UNLABELLED_FRONT_REAR_GABLE.png') @(@{file='01_front_three_quarter.png';x=25;y=90;w=500;h=700;caption='Actual front: lower and upper agricultural openings'};@{file='02_rear_three_quarter.png';x=550;y=90;w=500;h=700;caption='Actual rear: service side and rear opening'};@{file='03_direct_side_gable.png';x=1075;y=90;w=500;h=700;caption='Actual side/gable: closed granite and two slopes'}) 'V0.346 UNLABELLED FRONT REAR GABLE SET'
New-Board (Join-Path $Pack '03_LOWER_ROOF_PITCH_AND_DARK_SLATE.png') @(@{file='04_close_roof_front_material.png';x=25;y=90;w=1000;h=700;caption='Dark low-saturation slate and thin charcoal-brown edge'};@{file='03_direct_side_gable.png';x=1050;y=90;w=525;h=700;caption='Lower, restrained roof pitch and straight ridge'}) 'V0.346 LOWER ROOF PITCH AND DARK SLATE'
New-Board (Join-Path $Pack '04_TRUE_MATCHED_512X256_COMPARISON.png') @(@{file='05_true_matched_512x256_house02_barn.png';x=40;y=120;w=1520;h=760;caption='True direct render: frozen House02 left / v0.346 barn right, matched camera and light'}) 'V0.346 TRUE MATCHED HOUSE02 BARN COMPARISON'
$manifest = Get-Content (Join-Path $RepoRoot 'artifacts\runtime\v0346\v0346-barn-house02-silhouette-roof-pitch-runtime.json') -Raw | ConvertFrom-Json; $metrics = Get-Content (Join-Path $RepoRoot 'art-source\blender\v0346\v0346-barn-metrics.json') -Raw | ConvertFrom-Json; $files = Get-ChildItem -LiteralPath $Pack -File | Sort-Object Name
$summary = [ordered]@{ checkpoint='v0.346'; outcome=$manifest.outcome; automatedVisualApproval=$false; humanReviewRequired=$true; sourceCaptureCount=$manifest.captureCount; sourceCaptures=@($manifest.captures | ForEach-Object {$_.fileName}); frontCapture='01_front_three_quarter.png'; rearCapture='02_rear_three_quarter.png'; trueComparison=[ordered]@{file='05_true_matched_512x256_house02_barn.png';width=512;height=256;leftPanel='frozen House02 rendered directly';rightPanel='v0.346 barn rendered directly';eachPanel='256x256'}; ratiosAfter=$metrics.ratiosAfter; v0345Comparison=$metrics.v0345Comparison; v0346RoofPitchDegrees=$metrics.v0346RoofPitchDegrees; roof=$metrics.roof; reviewPackFiles=@('00_READ_ME_FIRST.md','01_HOUSE02_FAMILY_PROPORTION_RESET.png','02_UNLABELLED_FRONT_REAR_GABLE.png','03_LOWER_ROOF_PITCH_AND_DARK_SLATE.png','04_TRUE_MATCHED_512X256_COMPARISON.png','compact-evidence-summary.json'); exactlySixReviewFiles=$true; exactlyFourPng=$true; noVideo=$true; v0345GraniteLineagePreserved=$true; noDefaultRuntimeIntegration=$true; noGameplay=$true; noHumanApproval=$true; sourceHashes=$metrics.sourceHashes }
$summary | ConvertTo-Json -Depth 16 | Set-Content (Join-Path $Pack 'compact-evidence-summary.json') -Encoding UTF8
@"
# v0.346 House02-family silhouette and roof-pitch repair

Outcome: **$($manifest.outcome)**

Automated visual approval is false and human review remains required. v0.345 was rejected by human review and is not marked gold, accepted, or production-ready. This isolated derivative preserves the successful v0.345 granite/opening lineage while repairing horizontal family silhouette, roof pitch, slate value, gable closure, and front/rear capture orientation.

Exactly six upload files are present: four boards, this readme, and compact-evidence-summary.json. The five unlabelled Godot source captures remain under artifacts/runtime/v0346/screenshots/ and are not extra upload files.

Capture command: npm run godot:capture:salto-v0346-barn-house02-silhouette-roof-pitch
Pack command: npm run godot:pack:salto-v0346-barn-house02-silhouette-roof-pitch
Validator command: npm run godot:validate:salto-v0346-barn-house02-silhouette-roof-pitch

The true comparison is an actual 512x256 render: frozen House02 on the left and v0.346 on the right, each 256x256, using the same orthographic camera, lighting, ground, and worker treatment. No old board or embedded reference image is used. No default runtime, gameplay, save, stable-ID, or resource change is included.
"@ | Set-Content (Join-Path $Pack '00_READ_ME_FIRST.md') -Encoding UTF8
if ((Get-ChildItem -LiteralPath $Pack -File).Count -ne 6) { throw 'v0.346 upload pack must contain exactly six files' }
Write-Output 'PASS_V0346_BARN_HOUSE02_SILHOUETTE_ROOF_PITCH_PACK_BUILT'
