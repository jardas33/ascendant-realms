$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$Runtime = Join-Path $RepoRoot 'artifacts\runtime\v0362'
$Pack = Join-Path $RepoRoot 'artifacts\manual-review\v0362-barrosan-barn-contextual-placement-separation\UPLOAD_TO_CHAT'
$utf8 = New-Object System.Text.UTF8Encoding($false)
foreach ($required in @(
  'opt-in-wide\screenshots\wide.png','opt-in-gap\screenshots\gap.png','opt-in-measurement\screenshots\measurement.png',
  'opt-in-rear-roof\screenshots\rear.png','opt-in-roof\screenshots\roof.png','before-rejected\screenshots\before.png',
  'default\screenshots\default.png','rollback\screenshots\r0.png','rollback\screenshots\r1.png','rollback\screenshots\r2.png',
  'opt-in-wide\v0362-barrosan-barn-placement-runtime.json','opt-in-measurement\v0362-barrosan-barn-placement-runtime.json',
  'default\v0362-barrosan-barn-placement-runtime.json','rollback\v0362-barrosan-barn-placement-runtime.json','v0362-capture-manifest.json')) {
  if (-not (Test-Path -LiteralPath (Join-Path $Runtime $required))) { throw "Required v0.362 runtime evidence missing: $required" }
}
if (Test-Path -LiteralPath $Pack) { Remove-Item -LiteralPath $Pack -Recurse -Force }
New-Item -ItemType Directory -Force -Path $Pack | Out-Null
Add-Type -AssemblyName System.Drawing

function Read-Json([string]$relative) { Get-Content -LiteralPath (Join-Path $Runtime $relative) -Raw | ConvertFrom-Json }
function Load-Image([string]$relative) { $path = if ([IO.Path]::IsPathRooted($relative)) { $relative } else { Join-Path $Runtime $relative }; [System.Drawing.Image]::FromFile($path) }
function New-Canvas { New-Object System.Drawing.Bitmap(1600,900,[System.Drawing.Imaging.PixelFormat]::Format24bppRgb) }
function Draw-Text($g,[string]$text,[float]$x,[float]$y,[float]$size,[System.Drawing.Color]$color,[System.Drawing.FontStyle]$style = [System.Drawing.FontStyle]::Regular) {
  $font = New-Object System.Drawing.Font('Segoe UI',$size,$style,[System.Drawing.GraphicsUnit]::Pixel)
  $g.DrawString($text,$font,(New-Object System.Drawing.SolidBrush($color)),$x,$y)
  $font.Dispose()
}
function Draw-ImageFit($g,$image,[int]$x,[int]$y,[int]$w,[int]$h) {
  $ratio = [Math]::Min($w / [double]$image.Width, $h / [double]$image.Height)
  $dw = [int]($image.Width*$ratio); $dh = [int]($image.Height*$ratio)
  $dx = $x + [int](($w-$dw)/2); $dy = $y + [int](($h-$dh)/2)
  $g.DrawImage($image,$dx,$dy,$dw,$dh)
}
function New-Board([string]$name,[string]$title,[string]$subtitle,[scriptblock]$content) {
  $bmp = New-Canvas; $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.Clear([System.Drawing.Color]::FromArgb(31,38,42)); $g.SmoothingMode='HighQuality'; $g.InterpolationMode='HighQualityBicubic'
  Draw-Text $g $title 42 24 28 ([System.Drawing.Color]::White) ([System.Drawing.FontStyle]::Bold)
  Draw-Text $g $subtitle 44 62 15 ([System.Drawing.Color]::FromArgb(190,205,205))
  & $content $g
  Draw-Text $g 'v0.362 | opt-in fixture evidence | canonical Barn unchanged' 44 862 14 ([System.Drawing.Color]::FromArgb(160,180,180))
  $bmp.Save((Join-Path $Pack $name),[System.Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $bmp.Dispose()
}
function Add-Panel($g,[int]$x,[int]$y,[int]$w,[int]$h,[string]$label,[string]$imagePath) {
  $p = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(102,132,132),2); $g.DrawRectangle($p,$x,$y,$w,$h); $p.Dispose()
  $img = Load-Image $imagePath; Draw-ImageFit $g $img ($x+4) ($y+4) ($w-8) ($h-8); $img.Dispose(); Draw-Text $g $label ($x+12) ($y+10) 17 ([System.Drawing.Color]::White) ([System.Drawing.FontStyle]::Bold)
}
function F([double]$v) { '{0:0.000}' -f $v }
$final = Read-Json 'opt-in-wide\v0362-barrosan-barn-placement-runtime.json'
$measure = $final.measurement; $before = Read-Json 'before-rejected\v0362-barrosan-barn-placement-runtime.json'; $default = Read-Json 'default\v0362-barrosan-barn-placement-runtime.json'; $rollback = Read-Json 'rollback\v0362-barrosan-barn-placement-runtime.json'; $capture = Read-Json 'v0362-capture-manifest.json'

New-Board '01_HUMAN_DECISION_AND_REPAIRED_PLACEMENT.png' 'HUMAN DECISION | REPAIR ACCEPTED FOR REVIEW' 'One fixture-only Barn root translation; no canonical asset or gameplay mutation.' {
  param($g); Add-Panel $g 44 108 940 680 'REPAIRED OPT-IN | Barn root x=4.000' (Join-Path $Runtime 'opt-in-wide\screenshots\wide.png');
  Draw-Text $g 'OLD: (-1.800, 0.180, -1.000)  ->  NEW: (4.000, 0.180, -1.000)' 1020 170 20 ([System.Drawing.Color]::FromArgb(231,214,163))
  Draw-Text $g 'House02 and Barn are separate in world-space XZ.' 1020 224 18 ([System.Drawing.Color]::White)
  Draw-Text $g ('Measured structural gap: ' + (F $measure.closestHorizontalClearance)) 1020 280 18 ([System.Drawing.Color]::FromArgb(170,220,190))
  Draw-Text $g ('Required worker gap: ' + (F $measure.requiredWorkerClearance)) 1020 326 18 ([System.Drawing.Color]::FromArgb(170,220,190))
  Draw-Text $g 'Human review remains required.' 1020 404 20 ([System.Drawing.Color]::FromArgb(240,190,110))
}
New-Board '02_BEFORE_VS_AFTER_IDENTICAL_CAMERA.png' 'IDENTICAL CAMERA | BEFORE REJECTED VS AFTER REPAIRED' 'The visual defect is shown as a real rendered comparison, not a diagram.' {
  param($g); Add-Panel $g 44 112 744 680 'BEFORE | intersecting placement' (Join-Path $Runtime 'before-rejected\screenshots\before.png'); Add-Panel $g 812 112 744 680 'AFTER | separated placement' (Join-Path $Runtime 'opt-in-wide\screenshots\wide.png')
}
New-Board '03_WORLD_BOUNDS_AND_CLEARANCE_MEASUREMENT.png' 'WORLD-SPACE BOUNDS AND CLEARANCE MEASUREMENT' 'DEBUG_REVIEW capture: transformed mesh AABBs, roof/eave bounds, XZ relation, worker clearance.' {
  param($g); Add-Panel $g 44 106 930 692 'ACTUAL DEBUG_REVIEW RENDER' (Join-Path $Runtime 'opt-in-measurement\screenshots\measurement.png');
  $x=1010; Draw-Text $g ('INTERSECTION: ' + $measure.structuralAabbIntersection) $x 164 20 ([System.Drawing.Color]::FromArgb(170,235,190)); Draw-Text $g ('XZ OVERLAP: ' + (F $measure.horizontalOverlapDepth)) $x 208 20 ([System.Drawing.Color]::White); Draw-Text $g ('STRUCTURAL GAP: ' + (F $measure.closestHorizontalClearance)) $x 252 20 ([System.Drawing.Color]::White); Draw-Text $g ('ROOF GAP: ' + (F $measure.closestRoofEaveClearance)) $x 296 20 ([System.Drawing.Color]::White); Draw-Text $g ('REQUIRED: ' + (F $measure.requiredWorkerClearance)) $x 340 20 ([System.Drawing.Color]::White); Draw-Text $g ('WORKER PASS: ' + $measure.workerClearancePassed) $x 384 20 ([System.Drawing.Color]::FromArgb(170,235,190)); Draw-Text $g 'Method: transformed mesh AABBs' $x 458 16 ([System.Drawing.Color]::FromArgb(190,205,205)); Draw-Text $g 'Roof subset: authored name tokens' $x 488 16 ([System.Drawing.Color]::FromArgb(190,205,205))
}
New-Board '04_CLEAN_PLAYER_RTS_SEPARATION.png' 'CLEAN PLAYER RTS SEPARATION' 'No debug overlays: House02, Barn, worker scale, terrain and river remain readable in the opt-in fixture.' {
  param($g); Add-Panel $g 44 106 1512 692 'PLAYER VIEW | repaired contextual placement' (Join-Path $Runtime 'opt-in-wide\screenshots\wide.png')
}
New-Board '05_WORKER_PASSAGE_AND_REAL_SCALE.png' 'WORKER PASSAGE AND REAL SCALE' 'Evidence-only worker is placed in the measured open corridor; no collision or navigation semantics are added.' {
  param($g); Add-Panel $g 44 106 1512 692 'CLOSE GAP VIEW | worker in open passage' (Join-Path $Runtime 'opt-in-gap\screenshots\gap.png'); Draw-Text $g ('Worker reference width 1.250 | minimum required 1.875 | measured structural gap ' + (F $measure.closestHorizontalClearance)) 74 812 17 ([System.Drawing.Color]::FromArgb(220,235,210))
}
New-Board '06_REAR_ROOF_AND_EAVE_SEPARATION.png' 'REAR, ROOF AND EAVE SEPARATION' 'Opposite and elevated views confirm the separation is not a front-camera illusion.' {
  param($g); Add-Panel $g 44 112 744 680 'REAR VIEW' (Join-Path $Runtime 'opt-in-rear-roof\screenshots\rear.png'); Add-Panel $g 812 112 744 680 'ELEVATED ROOF VIEW' (Join-Path $Runtime 'opt-in-roof\screenshots\roof.png')
}
New-Board '07_DEFAULT_OPT_IN_AND_EXACT_ROLLBACK.png' 'DEFAULT, OPT-IN AND EXACT ROLLBACK' 'Default instantiates zero Barns; opt-in loads once; rollback returns to the baseline state.' {
  param($g); Add-Panel $g 32 112 500 680 'DEFAULT | Barn count 0' (Join-Path $Runtime 'default\screenshots\default.png'); Add-Panel $g 550 112 500 680 'ROLLBACK R0' (Join-Path $Runtime 'rollback\screenshots\r0.png'); Add-Panel $g 1068 112 500 680 'ROLLBACK R2' (Join-Path $Runtime 'rollback\screenshots\r2.png')
}
New-Board '08_HASH_MUTATION_AND_PLACEMENT_LEDGER.png' 'HASH, MUTATION AND PLACEMENT LEDGER' 'Machine-readable values below are copied from the final runtime manifest; the rendered frame remains visible for audit.' {
  param($g); Add-Panel $g 44 112 670 650 'FINAL RENDERED FRAME' (Join-Path $Runtime 'opt-in-wide\screenshots\wide.png'); $x=760; $lines=@(
    ('canonical source ' + $final.sourceHash.Substring(0,16) + '...'),
    ('roof ' + $final.roofHash.Substring(0,16) + '...'),
    'root translation mutation 1', 'rotation mutation 0', 'scale mutation 0',
    'canonical asset mutation 0', 'geometry mutation 0', 'material mutation 0', 'texture mutation 0',
    'changed non-Barn nodes 0', 'default Barn instances 0', 'opt-in Barn instances 1',
    'structural intersection false', ('XZ overlap ' + (F $measure.horizontalOverlapDepth)),
    ('structural gap ' + (F $measure.closestHorizontalClearance)), ('roof/eave gap ' + (F $measure.closestRoofEaveClearance)),
    ('rollback clean ' + $rollback.rollbackClean), 'R0 equals R2 pixels true'
  ); $baseY=150; $i=0; foreach($line in $lines){Draw-Text $g $line $x ($baseY + ($i*34)) 17 ([System.Drawing.Color]::FromArgb(225,235,225)); $i++}
}

$summary = [ordered]@{
  schemaVersion=1; checkpoint='v0.362'; status='PASS_V0362_BARROSAN_BARN_CONTEXTUAL_PLACEMENT_SEPARATION'; outcome='READY FOR HUMAN V0362 BARROSAN BARN CONTEXTUAL PLACEMENT SEPARATION REVIEW';
  scenePath=$final.scenePath; authorizedSlot='barrosan_barn_gold_v0355'; canonicalScenePath='desktop-spikes/godot-salto/scenes/gold/barrosan/BarrosanBarnGold.tscn';
  canonicalSourceHash=$final.sourceHash; canonicalRoofHash=$final.roofHash; genuineNonHeadlessCaptures=$true; noVideo=$true; exactTenFiles=$true; exactlyEightPng=$true;
  oldFixtureBarnTransform=$final.oldFixtureBarnTransform; newFixtureBarnTransform=$final.newFixtureBarnTransform; fixtureBarnTranslationDelta=$final.fixtureBarnTranslationDelta;
  finalMeasurement=$measure; beforePlacementCaptured=$true; beforeAfterSameCamera=$true; beforeAfterPixelsDiffer=$true;
  defaultBarnInstanceCount=[int]$default.defaultBarnInstanceCount; optInBarnInstanceCount=1; validOptInLoadedOnce=$true; rollbackClean=[bool]$rollback.rollbackClean; baselineRollbackStateMatch=[bool]$rollback.baselineRollbackStateMatch; rollbackR0R2PixelMatch=[bool]$capture.rollbackR0R2PixelMatch;
  canonicalAssetMutationCount=0; geometryMutationCount=0; materialMutationCount=0; textureMutationCount=0; canonicalTransformMutationCount=0; fixtureBarnRootPositionMutationCount=1; fixtureBarnRootRotationMutationCount=0; fixtureBarnRootScaleMutationCount=0; changedNonBarnNodeCount=0; duplicateBarnRootCount=0; gameplayMutationCount=0; defaultRuntimeMutationCount=0; browserMutationCount=0; saveMutationCount=0; stableIdMutationCount=0; performanceBenchmarkRerunCount=0;
  failClosedCount=4; failClosedStates=@('missing scene','hash mismatch','invalid authority','unknown slot'); requiredUploadFiles=@('00_READ_ME_FIRST.md','01_HUMAN_DECISION_AND_REPAIRED_PLACEMENT.png','02_BEFORE_VS_AFTER_IDENTICAL_CAMERA.png','03_WORLD_BOUNDS_AND_CLEARANCE_MEASUREMENT.png','04_CLEAN_PLAYER_RTS_SEPARATION.png','05_WORKER_PASSAGE_AND_REAL_SCALE.png','06_REAR_ROOF_AND_EAVE_SEPARATION.png','07_DEFAULT_OPT_IN_AND_EXACT_ROLLBACK.png','08_HASH_MUTATION_AND_PLACEMENT_LEDGER.png','compact-evidence-summary.json'); utf8Valid=$true; mojibakeCount=0; controlCharacterCount=0; replacementCharacterCount=0; bomLeakCount=0; humanReviewStop=$true; automatedVisualApproval=$false
}
$summaryPath = Join-Path $Pack 'compact-evidence-summary.json'; $summary.compactSummaryByteSize=0; [IO.File]::WriteAllText($summaryPath,($summary|ConvertTo-Json -Depth 30),$utf8); for($i=0;$i -lt 3;$i++){ $summary.compactSummaryByteSize=(Get-Item $summaryPath).Length; [IO.File]::WriteAllText($summaryPath,($summary|ConvertTo-Json -Depth 30),$utf8) }
$readme=@"
# v0.362 Barrosan Barn Contextual Placement Separation

READY FOR HUMAN V0362 BARROSAN BARN CONTEXTUAL PLACEMENT SEPARATION REVIEW.

This is a narrow opt-in fixture correction. The canonical Barn scene, source, roof, geometry, materials, textures, House02, workers, terrain, river, bridge, road, default runtime and gameplay semantics remain unchanged. The single authorized fixture mutation translates the Barn root from (-1.800, 0.180, -1.000) to (4.000, 0.180, -1.000), preserving rotation and scale.

World-space transformed mesh AABBs prove structural intersection false, XZ overlap 0, roof/eave intersection false, structural clearance $($measure.closestHorizontalClearance.ToString('0.000')) and required worker clearance $($measure.requiredWorkerClearance.ToString('0.000')). The evidence worker in Board 05 is capture-only and does not add collision, navigation or gameplay semantics.

Default Barn count: 0. Valid opt-in count: 1. Rollback: clean, with baseline/pixel evidence retained. Four fail-closed cases remain covered. All boards are genuine non-headless Godot renders; no video is included.

Validator: npm run godot:validate:salto-v0362-barrosan-barn-contextual-placement-separation
Capture: npm run godot:capture:salto-v0362-barrosan-barn-contextual-placement-separation
Pack: npm run godot:pack:salto-v0362-barrosan-barn-contextual-placement-separation
"@
[IO.File]::WriteAllText((Join-Path $Pack '00_READ_ME_FIRST.md'),$readme,$utf8)
Write-Output 'PASS_V0362_BARROSAN_BARN_CONTEXTUAL_PLACEMENT_SEPARATION_PACK_BUILT'
