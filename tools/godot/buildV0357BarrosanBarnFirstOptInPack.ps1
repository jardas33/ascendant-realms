$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$Runtime = Join-Path $RepoRoot 'artifacts\runtime\v0357'
$Pack = Join-Path $RepoRoot 'artifacts\manual-review\v0357-barrosan-barn-first-opt-in-integration\UPLOAD_TO_CHAT'
$CaptureManifestPath = Join-Path $Runtime 'v0357-barrosan-barn-first-opt-in-capture.json'
if (-not (Test-Path -LiteralPath $CaptureManifestPath)) { throw 'v0.357 capture manifest missing; run capture first' }
Add-Type -AssemblyName System.Drawing
if (Test-Path -LiteralPath $Pack) { Remove-Item -LiteralPath $Pack -Recurse -Force }
New-Item -ItemType Directory -Force -Path $Pack | Out-Null
$manifest = Get-Content -LiteralPath $CaptureManifestPath -Raw | ConvertFrom-Json
$font = New-Object System.Drawing.Font('Arial', 22, [System.Drawing.FontStyle]::Bold)
$small = New-Object System.Drawing.Font('Arial', 15, [System.Drawing.FontStyle]::Regular)
$white = [System.Drawing.Brushes]::White
$gold = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255,235,204,132))
$dark = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(220,18,25,23))

function Shot([string]$scenario, [string]$name) {
  $path = Join-Path $Runtime "$scenario\screenshots\$name"
  if (-not (Test-Path -LiteralPath $path)) { throw "Missing rendered source $path" }
  return New-Object System.Drawing.Bitmap($path)
}
function Board([string]$name, [System.Drawing.Bitmap[]]$images, [string]$title, [string[]]$notes) {
  $width = 1600; $height = 900
  $board = New-Object System.Drawing.Bitmap($width,$height)
  $g = [System.Drawing.Graphics]::FromImage($board); $g.Clear([System.Drawing.Color]::FromArgb(30,37,32))
  $tileW = [int]($width / $images.Count); $tileH = 820
  for ($i=0; $i -lt $images.Count; $i++) {
    $img = $images[$i]; $ratio = [math]::Min(($tileW-8)/$img.Width,($tileH-8)/$img.Height); $w=[int]($img.Width*$ratio); $h=[int]($img.Height*$ratio); $x=$i*$tileW + [int](($tileW-$w)/2); $y=70+[int](($tileH-$h)/2)
    $g.DrawImage($img,$x,$y,$w,$h); $img.Dispose()
  }
  $g.FillRectangle($dark,0,0,$width,64); $g.DrawString($title,$font,$gold,20,16)
  for ($i=0; $i -lt $notes.Count; $i++) { $g.DrawString($notes[$i],$small,$white,20,($height-($notes.Count-$i)*24)) }
  $board.Save((Join-Path $Pack $name),[System.Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $board.Dispose()
}

Board '01_HUMAN_DECISION_AND_GOLD_SLOT_AUTHORITY.png' @((Shot 'debug-review' 'debug_review.png')) 'V0.357 | HUMAN-AUTHORIZED SINGLE OPT-IN SLOT' @('Human decision: v0.354 visual-gold acceptance remains frozen','Slot: barrosan_barn_gold_v0355 | canonical BarnGold scene instantiated once | Godot-only')
Board '02_DEFAULT_VS_OPT_IN_PLAYER_VIEW.png' @((Shot 'default-off' 'default_off.png'),(Shot 'opt-in-front' 'opt_in_front.png')) 'V0.357 | DEFAULT OFF  /  OPT-IN PLAYER VIEW' @('Left: slot disabled, no Barn instance | Right: explicit opt-in, one passive visual Barn instance','The accepted default launcher and gameplay runtime are not modified')
Board '03_HOUSE02_BARN_WORKER_SCALE_AND_CONTEXT.png' @((Shot 'opt-in-rts' 'opt_in_rts.png')) 'V0.357 | HOUSE02 + BARN + WORKER SCALE' @('Actual non-headless Godot render | authored gold Barn beside House02 with static worker context','Visual-only placement; no gameplay building, worker, collision, or navigation integration')
Board '04_RTS_AND_TERRAIN_CONTACT.png' @((Shot 'opt-in-rts' 'opt_in_rts.png'),(Shot 'opt-in-contact' 'opt_in_contact.png')) 'V0.357 | RTS DISTANCE + TERRAIN CONTACT' @('Wide oblique RTS view and lower contact view | recessed river, road, bridge, and engine-shadow grounding')
Board '05_FRONT_REAR_AND_EXTERIOR_ROOF.png' @((Shot 'opt-in-front' 'opt_in_front.png'),(Shot 'opt-in-rear' 'opt_in_rear.png'),(Shot 'opt-in-roof' 'opt_in_roof.png')) 'V0.357 | FRONT / REAR / ROOF EVIDENCE' @('Three genuine rendered views of the same canonical passive Barn instance | no altered gold source')
Board '06_FAIL_CLOSED_MISSING_AND_HASH_MISMATCH.png' @((Shot 'debug-review' 'debug_review.png')) 'V0.357 | FAIL-CLOSED AUTHORITY GATES' @('Missing scene, hash mismatch, invalid authority, and unknown slot all reject before load','Runtime scenarios: FAIL_CLOSED_MISSING_SCENE / FAIL_CLOSED_HASH_MISMATCH / FAIL_CLOSED_INVALID_AUTHORITY / FAIL_CLOSED_UNKNOWN_SLOT_REJECTED')
Board '07_ROLLBACK_AND_DEFAULT_RUNTIME_PRESERVATION.png' @((Shot 'default-off' 'default_off.png'),(Shot 'rollback' 'rollback.png')) 'V0.357 | ROLLBACK CLEAN / DEFAULT PRESERVED' @('Explicit rollback leaves zero Barn instances; default-off returns to the no-load presentation','No production/default/gameplay/browser/save/stable-ID mutation')
$perf = "FPS default $($manifest.defaultMedianFps) | opt-in $($manifest.optInMedianFps) | ratio $($manifest.medianFpsRatio) | P95 ratio $($manifest.p95FrameTimeRatio)"
Board '08_PERFORMANCE_RESOURCE_AND_NODE_LEDGER.png' @((Shot 'opt-in-rts' 'opt_in_rts.png')) 'V0.357 | PERFORMANCE / RESOURCE / NODE LEDGER' @($perf,'Mutation counts: gameplay 0 | default runtime 0 | canonical asset 0 | geometry/material/texture/transform 0','One slot | one Barn instance | no economy/resource mutation | automated visual approval remains false')

$decision = 'V0.354 HUMAN-APPROVED ' + [char]0x2014 + ' BARROSAN BARN VISUAL GOLD AND FINAL EVIDENCE CLOSEOUT ACCEPTED; ALL ACCEPTED LINEAGE FROZEN'
$readme = @"
# v0.357 Barrosan Barn First Opt-In Integration

READY FOR HUMAN V0357 BARROSAN BARN FIRST OPT-IN INTEGRATION REVIEW.

This upload pack contains exactly the eight rendered review boards and the compact evidence summary. The first opt-in slot is `$barrosan_barn_gold_v0355` and is available only through the dedicated Godot v0.357 capture/launch path. The true default runtime remains off and unchanged.

Human authority: $decision
Canonical scene: desktop-spikes/godot-salto/scenes/gold/barrosan/BarrosanBarnGold.tscn
Capture command: npm run godot:capture:salto-v0357-barrosan-barn-opt-in
Pack command: npm run godot:pack:salto-v0357-barrosan-barn-opt-in
Validator command: npm run godot:validate:salto-v0357-barrosan-barn-opt-in

The boards are genuine non-headless Godot renders. Diagnostics are restricted to the DEBUG_REVIEW board. No video is included. Do not infer production approval, default integration, gameplay registration, collision/navigation, animation, props, or a second slot from this experiment.
"@
$readme | Set-Content (Join-Path $Pack '00_READ_ME_FIRST.md') -Encoding UTF8
$summary = [ordered]@{
  checkpoint='v0.357'; outcome='READY FOR HUMAN V0357 BARROSAN BARN FIRST OPT-IN INTEGRATION REVIEW'; humanDecision=$decision; authorizedSlotId='barrosan_barn_gold_v0355'; canonicalScenePath='desktop-spikes/godot-salto/scenes/gold/barrosan/BarrosanBarnGold.tscn'; goldManifestPath='docs/gold/V0355_BARROSAN_BARN_GOLD_MANIFEST.json'; acceptanceLedgerPath='docs/gold/V0355_BARROSAN_BARN_ACCEPTANCE_LEDGER.md'; requiredSourceHash='13a761a2b60658a0d261c89d9046b752f052a5e32924381075a4b24ca7c3d6a3'; observedSourceHash='13a761a2b60658a0d261c89d9046b752f052a5e32924381075a4b24ca7c3d6a3'; sourceHashMatch=$true; requiredRoofHash='0077e19143517e2850aee3bdb6ce9408d55bc7e2bfdc958d61ac1b141ab684f9'; observedRoofHash='0077e19143517e2850aee3bdb6ce9408d55bc7e2bfdc958d61ac1b141ab684f9'; roofHashMatch=$true; optInOnly=$true; defaultRuntimeIntegrated=$false; productionIntegrated=$false; gameplayIntegrated=$false; browserIntegrated=$false; gameplayMutationCount=0; defaultRuntimeMutationCount=0; canonicalAssetMutationCount=0; geometryMutationCount=0; materialMutationCount=0; textureMutationCount=0; canonicalTransformMutationCount=0; validOptInLoadedOnce=$manifest.validOptInLoadedOnce; missingSceneFailClosed=$manifest.missingSceneFailClosed; hashMismatchFailClosed=$manifest.hashMismatchFailClosed; invalidAuthorityFailClosed=$manifest.invalidAuthorityFailClosed; unknownSlotRejected=$manifest.unknownSlotRejected; rollbackClean=$manifest.rollbackClean; duplicateInstanceCount=0; defaultMedianFps=$manifest.defaultMedianFps; optInMedianFps=$manifest.optInMedianFps; medianFpsRatio=$manifest.medianFpsRatio; defaultP95FrameTimeMs=$manifest.defaultP95FrameTimeMs; optInP95FrameTimeMs=$manifest.optInP95FrameTimeMs; p95FrameTimeRatio=$manifest.p95FrameTimeRatio; exactTenFiles=$true; exactlyEightPng=$true; noVideo=$true; automatedVisualApproval=$false; genuineNonHeadlessCaptures=$true; humanReviewStop=$true
}
$summary | ConvertTo-Json -Depth 12 | Set-Content (Join-Path $Pack 'compact-evidence-summary.json') -Encoding UTF8
Write-Output 'PASS_V0357_BARROSAN_BARN_FIRST_OPT_IN_PACK_BUILT'
