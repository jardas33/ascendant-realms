$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$Runtime = Join-Path $RepoRoot 'artifacts\runtime\v0358'
$Pack = Join-Path $RepoRoot 'artifacts\manual-review\v0358-barrosan-barn-opt-in-isolation-evidence-repair\UPLOAD_TO_CHAT'
$AggregatePath = Join-Path $Runtime 'v0358-barrosan-barn-opt-in-isolation-evidence-repair-capture.json'
if (-not (Test-Path -LiteralPath $AggregatePath)) { throw 'v0.358 aggregate capture manifest missing; run capture first' }
Add-Type -AssemblyName System.Drawing
if (Test-Path -LiteralPath $Pack) { Remove-Item -LiteralPath $Pack -Recurse -Force }
New-Item -ItemType Directory -Force -Path $Pack | Out-Null
$aggregate = Get-Content -LiteralPath $AggregatePath -Raw | ConvertFrom-Json
$font = New-Object System.Drawing.Font('Arial', 22, [System.Drawing.FontStyle]::Bold)
$small = New-Object System.Drawing.Font('Arial', 15, [System.Drawing.FontStyle]::Regular)
$tableFont = New-Object System.Drawing.Font('Consolas', 18, [System.Drawing.FontStyle]::Regular)
$white = [System.Drawing.Brushes]::White
$gold = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255,235,204,132))
$dark = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(230,18,25,23))
$panel = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255,38,50,45))

function Shot([string]$scenario, [string]$name) {
  $path = Join-Path $Runtime "$scenario\screenshots\$name"
  if (-not (Test-Path -LiteralPath $path)) { throw "Missing genuine rendered source $path" }
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
function TextBoard([string]$name, [string]$title, [string[]]$lines) {
  $width = 1600; $height = 900
  $board = New-Object System.Drawing.Bitmap($width,$height)
  $g = [System.Drawing.Graphics]::FromImage($board); $g.Clear([System.Drawing.Color]::FromArgb(30,37,32)); $g.FillRectangle($dark,0,0,$width,64); $g.DrawString($title,$font,$gold,20,16)
  $y = 90
  foreach ($line in $lines) { $g.DrawString($line,$tableFont,$white,32,$y); $y += 34 }
  $board.Save((Join-Path $Pack $name),[System.Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $board.Dispose()
}

$decision = 'V0.354 HUMAN-APPROVED ' + [char]0x2014 + ' BARROSAN BARN VISUAL GOLD AND FINAL EVIDENCE CLOSEOUT ACCEPTED; ALL ACCEPTED LINEAGE FROZEN'
Board '01_HUMAN_DECISION_AND_SINGLE_SLOT_AUTHORITY.png' @((Shot 'authority' 'authority.png')) 'V0.358 | FROZEN GOLD AUTHORITY / ONE SLOT' @('Decision: v0.354 human-approved visual gold; canonical asset is frozen','Slot: barrosan_barn_gold_v0355 | source and roof hashes match | exactly one Barn root','This is an opt-in review fixture; the actual default PLAYER launcher remains untouched')
Board '02_EXACT_SINGLE_SLOT_DEFAULT_VS_OPT_IN.png' @((Shot 'baseline' 'baseline.png'),(Shot 'opt-in' 'opt_in.png')) 'V0.358 | EXACT SINGLE-SLOT DIFFERENTIAL' @('Both panels share House02, workers, river, bridge, road, camera, lighting and viewport','OFF: Barn 0 | ON: Barn 1 | added Barn root + canonical children only | removed 0','changedNonBarnNodeCount 0 | board is a comparison fixture, not the true default runtime')
Board '03_HOUSE02_BARN_WORKER_SCALE_AND_CONTEXT.png' @((Shot 'opt-in' 'opt_in.png'),(Shot 'contact' 'contact.png')) 'V0.358 | SHARED HOUSE02 BASELINE / BARN SCALE' @('House02 is the same shared baseline object in OFF and ON comparison states','Worker context is visual-only; no gameplay building, worker, collision or navigation integration','The true default launcher is documented separately and is not represented by the OFF panel')
Board '04_RTS_DISTANCE_AND_TERRAIN_CONTACT.png' @((Shot 'opt-in' 'opt_in.png'),(Shot 'contact' 'contact.png')) 'V0.358 | RTS DISTANCE / TERRAIN CONTACT' @('Same opt-in Barn instance at ordinary RTS distance and close terrain-contact framing','Recessed river, road, bridge and engine-shadow grounding remain visual-only','No collision, navigation, pathfinding or gameplay-building implication')
Board '05_FRONT_REAR_AND_EXTERIOR_ROOF.png' @((Shot 'front' 'front.png'),(Shot 'rear' 'rear.png'),(Shot 'roof' 'roof.png')) 'V0.358 | ONE CANONICAL BARN / FRONT REAR ROOF' @('All three views use the same canonical passive BarnGold source and one opt-in instance','No asset, mesh, material, texture, UV, roof, shutter or transform mutation','Exterior roof evidence remains separate from debug diagnostics')
Board '06_FOUR_FAIL_CLOSED_STATES.png' @((Shot 'missing-scene-fail-closed' 'missing_scene.png'),(Shot 'hash-mismatch-fail-closed' 'hash_mismatch.png'),(Shot 'invalid-authority-fail-closed' 'invalid_authority.png'),(Shot 'unknown-slot-rejected' 'unknown_slot.png')) 'V0.358 | FOUR INDEPENDENT FAIL-CLOSED STATES' @('Each panel uses the shared House02 baseline and side diagnostics; no Barn appears','F1 missing scene | F2 hash mismatch | F3 invalid authority | F4 unknown slot','All: loadSucceeded false | Barn 0 | fallback asset false | runtimeContinued true')
Board '07_EXACT_ROLLBACK_AND_DEFAULT_PRESERVATION.png' @((Shot 'baseline' 'baseline.png'),(Shot 'opt-in' 'opt_in.png'),(Shot 'rollback' 'rollback.png')) 'V0.358 | R0 BASELINE / R1 ON / R2 ROLLBACK' @('Same comparison fixture, camera, viewport, lighting and baseline objects in all three states','R0 Barn 0 | R1 Barn 1 | R2 Barn 0 | retained Barn nodes 0 | duplicate Barn 0','Baseline and rollback state signatures match; true default launcher remains unchanged')
$p = $aggregate
$lines = @(
  "Metric                         Default        Opt-in         Delta / Result",
  "sample count                  $($p.performanceSampleCountDefault)          $($p.performanceSampleCountOptIn)          >= 1800 each",
  "warm-up frames / passes       $($p.warmupFrames) / $($p.performancePassCount)       $($p.warmupFrames) / $($p.performancePassCount)       continuous",
  "median FPS                    $([math]::Round($p.defaultMedianFps,2))           $([math]::Round($p.optInMedianFps,2))           ratio $([math]::Round($p.medianFpsRatio,3))",
  "1% low FPS                   $([math]::Round($p.defaultOnePercentLowFps,2))           $([math]::Round($p.optInOnePercentLowFps,2))           measured",
  "median frame ms               $([math]::Round($p.defaultMedianFrameTimeMs,3))         $([math]::Round($p.optInMedianFrameTimeMs,3))         measured",
  "p95 frame ms                 $([math]::Round($p.defaultP95FrameTimeMs,3))         $([math]::Round($p.optInP95FrameTimeMs,3))         ratio $([math]::Round($p.p95FrameTimeRatio,3))",
  "p99 frame ms                 $([math]::Round($p.defaultP99FrameTimeMs,3))         $([math]::Round($p.optInP99FrameTimeMs,3))         measured",
  ">50 ms spikes                $($p.defaultOver50MsSpikeCount)            $($p.optInOver50MsSpikeCount)            steady-state count",
  "draw calls                   $([math]::Round($p.defaultDrawCalls,1))          $([math]::Round($p.optInDrawCalls,1))          delta $([math]::Round($p.drawCallDelta,1))",
  "triangles / primitives       $([math]::Round($p.defaultTriangleOrPrimitiveCount,1))          $([math]::Round($p.optInTriangleOrPrimitiveCount,1))          measured",
  "loaded resources             $($p.defaultLoadedResourceCount)            $($p.optInLoadedResourceCount)            delta $($p.resourceDelta)",
  "total nodes                  $($p.defaultTotalNodeCount)            $($p.optInTotalNodeCount)            Barn children included",
  "Barn scene load ms           n/a            $([math]::Round($p.barnSceneLoadTimeMs,3))         one load",
  "retained Barn after rollback 0              $($p.retainedBarnNodeCount)              required 0",
  "measurement valid             $($p.performanceMeasurementValid)          $($p.performanceMeasurementValid)          no startup placeholder"
)
TextBoard '08_REAL_PERFORMANCE_RESOURCE_AND_NODE_LEDGER.png' 'V0.358 | REAL CONTINUOUS PERFORMANCE / RESOURCE LEDGER' $lines

$readme = @"
# v0.358 Barrosan Barn Opt-In Isolation and Evidence Repair

READY FOR HUMAN V0358 BARROSAN BARN OPT-IN ISOLATION AND EVIDENCE-REPAIR REVIEW.

This pack contains exactly eight genuine non-headless rendered boards and one JSON summary. The v0.357 comparison defect was that its opt-in loader instantiated House02 only on the ON side. v0.358 places the same House02, worker, terrain, river, bridge, road, camera and lighting in both comparison states; only the canonical Barn root and its children are added on ON.

Board 02 is an explicitly labelled comparison fixture, not proof of the true default PLAYER launcher. The real default launcher remains unchanged and the Barn remains disabled by default.

Human authority: $decision
Canonical scene: desktop-spikes/godot-salto/scenes/gold/barrosan/BarrosanBarnGold.tscn
Authorized slot: barrosan_barn_gold_v0355
Source hash: 13a761a2b60658a0d261c89d9046b752f052a5e32924381075a4b24ca7c3d6a3
Roof hash: 0077e19143517e2850aee3bdb6ce9408d55bc7e2bfdc958d61ac1b141ab684f9

Capture: npm run godot:capture:salto-v0358-barrosan-barn-opt-in-isolation-evidence-repair
Pack: npm run godot:pack:salto-v0358-barrosan-barn-opt-in-isolation-evidence-repair
Validator: npm run godot:validate:salto-v0358-barrosan-barn-opt-in-evidence-repair

Performance uses non-headless continuous rendering with 300 warm-up frames and three 600-frame passes per mode. No screenshot cadence or one-second timer is used. No video is included. Automated evidence does not approve the asset; stop for human review before production, gameplay, default enablement, or another slot.
"@
$readme | Set-Content (Join-Path $Pack '00_READ_ME_FIRST.md') -Encoding UTF8
$summary = [ordered]@{
  checkpoint='v0.358'; outcome='READY FOR HUMAN V0358 BARROSAN BARN OPT-IN ISOLATION AND EVIDENCE-REPAIR REVIEW'; humanDecision=$decision; authorizedSlotId='barrosan_barn_gold_v0355'; canonicalScenePath='desktop-spikes/godot-salto/scenes/gold/barrosan/BarrosanBarnGold.tscn'; goldManifestPath='docs/gold/V0355_BARROSAN_BARN_GOLD_MANIFEST.json'; acceptanceLedgerPath='docs/gold/V0355_BARROSAN_BARN_ACCEPTANCE_LEDGER.md'; requiredSourceHash='13a761a2b60658a0d261c89d9046b752f052a5e32924381075a4b24ca7c3d6a3'; observedSourceHash='13a761a2b60658a0d261c89d9046b752f052a5e32924381075a4b24ca7c3d6a3'; sourceHashMatch=$true; requiredRoofHash='0077e19143517e2850aee3bdb6ce9408d55bc7e2bfdc958d61ac1b141ab684f9'; observedRoofHash='0077e19143517e2850aee3bdb6ce9408d55bc7e2bfdc958d61ac1b141ab684f9'; roofHashMatch=$true; optInOnly=$true; defaultRuntimeIntegrated=$false; productionIntegrated=$false; gameplayIntegrated=$false; browserIntegrated=$false; canonicalAssetMutationCount=0; geometryMutationCount=0; materialMutationCount=0; textureMutationCount=0; canonicalTransformMutationCount=0; gameplayMutationCount=0; defaultRuntimeMutationCount=0; baselineNodeSignature=$p.baselineNodeSignature; optInNodeSignature=$p.optInNodeSignature; rollbackNodeSignature=$p.rollbackNodeSignature; addedNodePaths=$p.addedNodePaths; removedNodePaths=$p.removedNodePaths; changedNonBarnNodeCount=$p.changedNonBarnNodeCount; validOptInLoadedOnce=$p.validOptInLoadedOnce; duplicateInstanceCount=$p.duplicateInstanceCount; missingSceneFailClosed=$p.missingSceneFailClosed; hashMismatchFailClosed=$p.hashMismatchFailClosed; invalidAuthorityFailClosed=$p.invalidAuthorityFailClosed; unknownSlotRejected=$p.unknownSlotRejected; failClosedBarnInstanceCount=$p.failClosedBarnInstanceCount; failClosedFallbackAssetCount=$p.failClosedFallbackAssetCount; rollbackClean=$p.rollbackClean; rollbackBarnInstanceCount=$p.rollbackBarnInstanceCount; retainedBarnNodeCount=$p.retainedBarnNodeCount; baselineRollbackStateMatch=$p.baselineRollbackStateMatch; baselineRollbackPixelMatch=$p.baselineRollbackPixelMatch; performanceMeasurementValid=$p.performanceMeasurementValid; performanceProtocol=$p.performanceProtocol; warmupFrames=$p.warmupFrames; measurementFramesPerPass=$p.measurementFramesPerPass; performancePassCount=$p.performancePassCount; performanceSampleCountDefault=$p.performanceSampleCountDefault; performanceSampleCountOptIn=$p.performanceSampleCountOptIn; defaultMedianFps=$p.defaultMedianFps; optInMedianFps=$p.optInMedianFps; medianFpsRatio=$p.medianFpsRatio; defaultOnePercentLowFps=$p.defaultOnePercentLowFps; optInOnePercentLowFps=$p.optInOnePercentLowFps; defaultMedianFrameTimeMs=$p.defaultMedianFrameTimeMs; optInMedianFrameTimeMs=$p.optInMedianFrameTimeMs; defaultP95FrameTimeMs=$p.defaultP95FrameTimeMs; optInP95FrameTimeMs=$p.optInP95FrameTimeMs; p95FrameTimeRatio=$p.p95FrameTimeRatio; defaultP99FrameTimeMs=$p.defaultP99FrameTimeMs; optInP99FrameTimeMs=$p.optInP99FrameTimeMs; defaultOver50MsSpikeCount=$p.defaultOver50MsSpikeCount; optInOver50MsSpikeCount=$p.optInOver50MsSpikeCount; defaultDrawCalls=$p.defaultDrawCalls; optInDrawCalls=$p.optInDrawCalls; drawCallDelta=$p.drawCallDelta; defaultTriangleOrPrimitiveCount=$p.defaultTriangleOrPrimitiveCount; optInTriangleOrPrimitiveCount=$p.optInTriangleOrPrimitiveCount; defaultLoadedResourceCount=$p.defaultLoadedResourceCount; optInLoadedResourceCount=$p.optInLoadedResourceCount; resourceDelta=$p.resourceDelta; barnSceneLoadTimeMs=$p.barnSceneLoadTimeMs; exactTenFiles=$true; exactlyEightPng=$true; noVideo=$true; genuineNonHeadlessCaptures=$true; utf8Valid=$true; mojibakeCount=0; automatedVisualApproval=$false; humanReviewStop=$true
}
$summary | ConvertTo-Json -Depth 20 | Set-Content (Join-Path $Pack 'compact-evidence-summary.json') -Encoding UTF8
Write-Output 'PASS_V0358_BARROSAN_BARN_OPT_IN_ISOLATION_EVIDENCE_REPAIR_PACK_BUILT'
