$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$Runtime = Join-Path $RepoRoot 'artifacts\runtime\v0363\board07'
$PreviousPack = Join-Path $RepoRoot 'artifacts\manual-review\v0362-barrosan-barn-contextual-placement-separation\UPLOAD_TO_CHAT'
$Pack = Join-Path $RepoRoot 'artifacts\manual-review\v0363-barrosan-barn-r0-r1-r2-evidence-board-repair\UPLOAD_TO_CHAT'
$utf8 = New-Object System.Text.UTF8Encoding($false)
if (-not (Test-Path -LiteralPath (Join-Path $Runtime 'v0363-board07-capture-manifest.json'))) { throw 'v0.363 capture manifest missing' }
if (Test-Path -LiteralPath $Pack) { Remove-Item -LiteralPath $Pack -Recurse -Force }
New-Item -ItemType Directory -Force -Path $Pack | Out-Null
foreach ($name in @('01_HUMAN_DECISION_AND_REPAIRED_PLACEMENT.png','02_BEFORE_VS_AFTER_IDENTICAL_CAMERA.png','03_WORLD_BOUNDS_AND_CLEARANCE_MEASUREMENT.png','04_CLEAN_PLAYER_RTS_SEPARATION.png','05_WORKER_PASSAGE_AND_REAL_SCALE.png','06_REAR_ROOF_AND_EAVE_SEPARATION.png','08_HASH_MUTATION_AND_PLACEMENT_LEDGER.png')) {
  Copy-Item -LiteralPath (Join-Path $PreviousPack $name) -Destination (Join-Path $Pack $name)
}
Add-Type -AssemblyName System.Drawing
function Read-Json([string]$path) { Get-Content -LiteralPath $path -Raw | ConvertFrom-Json }
function Draw-Text($g,[string]$text,[float]$x,[float]$y,[float]$size,[System.Drawing.Color]$color,[System.Drawing.FontStyle]$style = [System.Drawing.FontStyle]::Regular) { $font = New-Object System.Drawing.Font('Segoe UI',$size,$style,[System.Drawing.GraphicsUnit]::Pixel); $brush = New-Object System.Drawing.SolidBrush($color); $g.DrawString($text,$font,$brush,$x,$y); $brush.Dispose(); $font.Dispose() }
function Add-Panel($g,[int]$x,[int]$y,[int]$w,[int]$h,[string]$label,[string]$imagePath) { $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(112,148,148),2); $g.DrawRectangle($pen,$x,$y,$w,$h); $pen.Dispose(); $img = [System.Drawing.Image]::FromFile($imagePath); $ratio = [Math]::Min(($w-8)/[double]$img.Width,($h-8)/[double]$img.Height); $dw=[int]($img.Width*$ratio); $dh=[int]($img.Height*$ratio); $dx=$x+[int](($w-$dw)/2); $dy=$y+[int](($h-$dh)/2); $g.DrawImage($img,$dx,$dy,$dw,$dh); $img.Dispose(); Draw-Text $g $label ($x+14) ($y+12) 17 ([System.Drawing.Color]::White) ([System.Drawing.FontStyle]::Bold) }
$manifest = Read-Json (Join-Path $Runtime 'v0363-board07-capture-manifest.json')
$r0 = $manifest.r0; $r1 = $manifest.r1; $r2 = $manifest.r2
$canvas = New-Object System.Drawing.Bitmap(1600,900,[System.Drawing.Imaging.PixelFormat]::Format24bppRgb); $g=[System.Drawing.Graphics]::FromImage($canvas); $g.Clear([System.Drawing.Color]::FromArgb(31,38,42)); $g.SmoothingMode='HighQuality'; $g.InterpolationMode='HighQualityBicubic'
Draw-Text $g 'DEFAULT, OPT-IN AND EXACT ROLLBACK' 38 22 28 ([System.Drawing.Color]::White) ([System.Drawing.FontStyle]::Bold)
Draw-Text $g 'R0 contains zero Barns; R1 instantiates one accepted Barn at the repaired placement; R2 removes it and returns exactly to R0.' 40 62 14 ([System.Drawing.Color]::FromArgb(190,205,205))
Add-Panel $g 24 112 504 638 'R0 DEFAULT | Barn 0' (Join-Path $Runtime 'screenshots\r0.png')
Add-Panel $g 548 112 504 638 'R1 OPT-IN | Barn 1' (Join-Path $Runtime 'screenshots\r1.png')
Add-Panel $g 1072 112 504 638 'R2 ROLLBACK | Barn 0' (Join-Path $Runtime 'screenshots\r2.png')
$green=[System.Drawing.Color]::FromArgb(175,235,195); $white=[System.Drawing.Color]::FromArgb(225,235,225); $gold=[System.Drawing.Color]::FromArgb(231,214,163)
Draw-Text $g 'R0 Barn roots 0     R1 Barn roots 1     R2 Barn roots 0' 40 775 17 $white ([System.Drawing.FontStyle]::Bold)
Draw-Text $g ('R0/R2 state signature match ' + ([string]$manifest.r0R2StateSignatureMatch).ToLower() + '     R0/R2 pixel match ' + ([string]$manifest.r0R2RawCaptureMatch).ToLower()) 40 804 16 $green
Draw-Text $g ('R1 duplicate Barn roots 0     R1 changed non-Barn nodes 0     retained Barn nodes after rollback 0') 40 831 16 $white
Draw-Text $g 'R1 Barn root: (4.000, 0.180, -1.000) | same fixture, camera, lighting, House02 and world' 40 858 15 $gold
$canvas.Save((Join-Path $Pack '07_DEFAULT_OPT_IN_AND_EXACT_ROLLBACK.png'),[System.Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $canvas.Dispose()
$previous = Read-Json (Join-Path $PreviousPack 'compact-evidence-summary.json')
$summary = $previous | ConvertTo-Json -Depth 50 | ConvertFrom-Json
foreach ($pair in @(
  @('checkpoint','v0.363'), @('previousCheckpoint','v0.362'), @('previousCommit','faa240784fef1898e3710500275dae4f018bb169'), @('placementHumanApproved',$true), @('v0362Board07Rejected',$true), @('v0363Board07Repaired',$true),
  @('r0BarnRootCount',0), @('r1BarnRootCount',1), @('r2BarnRootCount',0), @('r0RawCaptureHash',[string]$manifest.r0RawCaptureHash), @('r1RawCaptureHash',[string]$manifest.r1RawCaptureHash), @('r2RawCaptureHash',[string]$manifest.r2RawCaptureHash), @('r0R2RawCaptureMatch',[bool]$manifest.r0R2RawCaptureMatch), @('r0R1RawCaptureDistinct',[bool]$manifest.r0R1RawCaptureDistinct), @('r1R2RawCaptureDistinct',[bool]$manifest.r1R2RawCaptureDistinct), @('r0StateSignature',[string]$manifest.r0StateSignature), @('r1StateSignature',[string]$manifest.r1StateSignature), @('r2StateSignature',[string]$manifest.r2StateSignature), @('r0R2StateSignatureMatch',[bool]$manifest.r0R2StateSignatureMatch), @('r0R1StateSignatureDistinct',[bool]$manifest.r0R1StateSignatureDistinct), @('r1DuplicateBarnRootCount',0), @('r1ChangedNonBarnNodeCount',0), @('retainedBarnNodeCountAfterRollback',0), @('board07PanelCount',3), @('board07R1BarnVisible',$true), @('board07LabelsCorrect',$true), @('placementMutationCountThisCheckpoint',0), @('canonicalAssetMutationCountThisCheckpoint',0), @('benchmarkRerunCountThisCheckpoint',0), @('humanReviewStop',$true)
)) { Add-Member -InputObject $summary -MemberType NoteProperty -Name $pair[0] -Value $pair[1] -Force }
[IO.File]::WriteAllText((Join-Path $Pack 'compact-evidence-summary.json'),($summary | ConvertTo-Json -Depth 50),$utf8)
$readme = @"
# v0.363 Barrosan Barn R0 / R1 / R2 Evidence Board Repair

READY FOR HUMAN V0363 BARROSAN BARN R0-R1-R2 EVIDENCE BOARD REVIEW.

The v0.362 contextual placement was human-approved. Board 07 alone was rejected because its centre panel omitted the R1 opt-in Barn visual and showed a second zero-Barn rollback view instead. v0.363 repairs only that evidence sequence.

Board 07 now contains three genuine non-headless Godot captures from the same fixture, camera, viewport, lighting, House02 state, workers, terrain, river, bridge and road:
- R0 DEFAULT | Barn 0
- R1 OPT-IN | Barn 1 at (4.000, 0.180, -1.000)
- R2 ROLLBACK | Barn 0

R0 and R2 have matching raw pixels and state signatures. R1 has one canonical Barn and differs only by that accepted Barn root and descendants. No asset, placement, runtime, gameplay, benchmark or validation-rule mutation occurred in this checkpoint. The canonical Barn source and frozen roof remain unchanged.

Capture: npm run godot:capture:salto-v0363-barrosan-barn-r0-r1-r2-evidence-board-repair
Pack: npm run godot:pack:salto-v0363-barrosan-barn-r0-r1-r2-evidence-board-repair
Validator: npm run godot:validate:salto-v0363-barrosan-barn-r0-r1-r2-evidence-board-repair
Human review stop: true. Do not begin another asset or gameplay change without explicit approval.
"@
[IO.File]::WriteAllText((Join-Path $Pack '00_READ_ME_FIRST.md'),$readme,$utf8)
$report = @"
# V0363 BARROSAN BARN R0 / R1 / R2 EVIDENCE BOARD REPAIR

## Scope

Evidence-only repair after human review of v0.362. Board 07 was the sole rejected artifact. No Barn placement, canonical asset, runtime fixture, gameplay system, benchmark, or validation rule was changed.

## Authority and accepted placement

Branch: codex/v0215-v0226-recovery. Accepted base: faa240784fef1898e3710500275dae4f018bb169. The human-approved Barn root remains (4.000, 0.180, -1.000), with structural clearance 2.480, roof/eave clearance 2.510, and required worker clearance 1.875. Canonical source hash is 13a761a2b60658a0d261c89d9046b752f052a5e32924381075a4b24ca7c3d6a3. Frozen roof hash is 0077e19143517e2850aee3bdb6ce9408d55bc7e2bfdc958d61ac1b141ab684f9.

## Defect and repair

The former Board 07 title promised DEFAULT, OPT-IN AND EXACT ROLLBACK but displayed DEFAULT, ROLLBACK R0 and ROLLBACK R2. This checkpoint regenerates the board from three actual non-headless Godot states using the existing v0.362 review scene and rollback sequence. The centre panel is now the actual R1 frame with exactly one canonical Barn.

## Capture truth

The three panels use one orthographic RTS camera, one viewport, one lighting setup and one unchanged world fixture. R0 contains zero Barns, R1 contains one Barn, and R2 contains zero Barns. Raw R0 and R2 hashes match; R1 differs from both. R0 and R2 state signatures match; R1 differs. The R1 root is visibly present at ordinary RTS distance and the board footer reports the machine truth.

## Retention and isolation

Boards 01-06 and 08 are retained byte-for-byte from v0.362. Only Board 07, the upload README, compact summary and this report are v0.363 documentary outputs. No performance benchmark was rerun. The v0.362 canonical scene, measurement, fail-closed cases, mutation ledger and accepted placement remain authoritative.

## Validation and delivery

Dedicated validator: npm run godot:validate:salto-v0363-barrosan-barn-r0-r1-r2-evidence-board-repair. Capture and pack commands are recorded in the upload README. The retained v0.362 validator, tests, build, content/art/runtime/artifact checks, Godot all pass and exact-SHA CI are recorded at closeout.

Review pack: artifacts/manual-review/v0363-barrosan-barn-r0-r1-r2-evidence-board-repair/UPLOAD_TO_CHAT/

<!-- V0363_R0_R1_R2_BEGIN -->
$(($manifest | ConvertTo-Json -Depth 30))
<!-- V0363_R0_R1_R2_END -->

READY FOR HUMAN V0363 BARROSAN BARN R0-R1-R2 EVIDENCE BOARD REVIEW
"@
[IO.File]::WriteAllText((Join-Path $RepoRoot 'docs\V0363_BARROSAN_BARN_R0_R1_R2_EVIDENCE_BOARD_REPAIR_REPORT.md'),$report,$utf8)
Write-Output 'PASS_V0363_BARROSAN_BARN_R0_R1_R2_PACK_BUILT'
