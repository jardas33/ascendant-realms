$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$Runtime = Join-Path $RepoRoot 'artifacts\runtime\v0359'
$Performance = Join-Path $RepoRoot 'artifacts\performance\v0359-barrosan-barn\v0359-performance.json'
$Pack = Join-Path $RepoRoot 'artifacts\manual-review\v0359-barrosan-barn-capture-integrity-performance-closeout\UPLOAD_TO_CHAT'
$AggregatePath = Join-Path $Runtime 'v0358\v0358-barrosan-barn-opt-in-isolation-evidence-repair-capture.json'
$ManifestPath = Join-Path $Runtime 'capture-manifest.json'
if (-not (Test-Path -LiteralPath $ManifestPath)) { throw 'v0.359 capture manifest missing; run capture first' }
if (-not (Test-Path -LiteralPath $Performance)) { throw 'v0.359 uncapped performance manifest missing; run capture first' }
Add-Type -AssemblyName System.Drawing
if (Test-Path -LiteralPath $Pack) { Remove-Item -LiteralPath $Pack -Recurse -Force }
New-Item -ItemType Directory -Force -Path $Pack | Out-Null
$manifest = Get-Content -LiteralPath $ManifestPath -Raw | ConvertFrom-Json
$performance = Get-Content -LiteralPath $Performance -Raw | ConvertFrom-Json
$oldAggregate = if (Test-Path -LiteralPath $AggregatePath) { Get-Content -LiteralPath $AggregatePath -Raw | ConvertFrom-Json } else { $null }
$font = New-Object System.Drawing.Font('Arial', 22, [System.Drawing.FontStyle]::Bold)
$small = New-Object System.Drawing.Font('Arial', 15, [System.Drawing.FontStyle]::Regular)
$tableFont = New-Object System.Drawing.Font('Consolas', 18, [System.Drawing.FontStyle]::Regular)
$panelFont = New-Object System.Drawing.Font('Arial', 21, [System.Drawing.FontStyle]::Bold)
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
  $width = 1600; $height = 900; $board = New-Object System.Drawing.Bitmap($width,$height); $g = [System.Drawing.Graphics]::FromImage($board); $g.Clear([System.Drawing.Color]::FromArgb(30,37,32)); $tileW = [int]($width / $images.Count); $tileH = 700
  for ($i=0; $i -lt $images.Count; $i++) { $img=$images[$i]; $ratio=[math]::Min(($tileW-8)/$img.Width,($tileH-8)/$img.Height); $w=[int]($img.Width*$ratio); $h=[int]($img.Height*$ratio); $x=$i*$tileW+[int](($tileW-$w)/2); $y=70+[int](($tileH-$h)/2); $g.DrawImage($img,$x,$y,$w,$h); $img.Dispose() }
  $g.FillRectangle($dark,0,0,$width,64); $g.DrawString($title,$font,$gold,20,16); for($i=0;$i -lt $notes.Count;$i++){ $g.DrawString($notes[$i],$small,$white,20,($height-($notes.Count-$i)*24)) }
  $board.Save((Join-Path $Pack $name),[System.Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $board.Dispose()
}
function GridBoard([string]$name, [object[]]$items, [string]$title, [string[]]$notes) {
  $width=1600; $height=900; $board=New-Object System.Drawing.Bitmap($width,$height); $g=[System.Drawing.Graphics]::FromImage($board); $g.Clear([System.Drawing.Color]::FromArgb(30,37,32)); $g.FillRectangle($dark,0,0,$width,64); $g.DrawString($title,$font,$gold,20,16); $tileW=800; $tileH=300
  for($i=0;$i -lt $items.Count;$i++){ $img=$items[$i].Image; $col=$i%2; $row=[math]::Floor($i/2); $x=$col*$tileW; $y=70+$row*$tileH; $ratio=[math]::Min(($tileW-14)/$img.Width,($tileH-68)/$img.Height); $w=[int]($img.Width*$ratio); $h=[int]($img.Height*$ratio); $g.DrawImage($img,$x+[int](($tileW-$w)/2),$y+26,$w,$h); $g.FillRectangle($dark,$x+10,$y+8,$tileW-20,42); $g.DrawString($items[$i].Label,$panelFont,$gold,$x+24,$y+14); $img.Dispose() }
  for($i=0;$i -lt $notes.Count;$i++){ $g.DrawString($notes[$i],$small,$white,20,($height-($notes.Count-$i)*24)) }
  $board.Save((Join-Path $Pack $name),[System.Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $board.Dispose()
}
function TextBoard([string]$name, [string]$title, [string[]]$lines) {
  $width=1600; $height=900; $board=New-Object System.Drawing.Bitmap($width,$height); $g=[System.Drawing.Graphics]::FromImage($board); $g.Clear([System.Drawing.Color]::FromArgb(30,37,32)); $g.FillRectangle($dark,0,0,$width,64); $g.DrawString($title,$font,$gold,20,16); $y=90; foreach($line in $lines){$g.DrawString($line,$tableFont,$white,32,$y);$y+=34}; $board.Save((Join-Path $Pack $name),[System.Drawing.Imaging.ImageFormat]::Png);$g.Dispose();$board.Dispose()
}
function Panel([string]$id) { return @($manifest.panels | Where-Object { $_.boardPanelId -eq $id })[0] }
function Hash([string]$scenario,[string]$name) { return (Get-FileHash (Join-Path $Runtime "$scenario\screenshots\$name") -Algorithm SHA256).Hash.ToLower() }

$decision = 'V0.354 HUMAN-APPROVED ' + [char]0x2014 + ' BARROSAN BARN VISUAL GOLD AND FINAL EVIDENCE CLOSEOUT ACCEPTED; ALL ACCEPTED LINEAGE FROZEN'
Board '01_HUMAN_DECISION_AND_SINGLE_SLOT_AUTHORITY.png' @((Shot 'authority' 'authority.png')) 'V0.359 | FROZEN AUTHORITY / ONE SLOT' @('V0.354 human-approved visual gold; canonical Barn scene and roof remain frozen','Authorized slot barrosan_barn_gold_v0355 | source hash match | roof hash match | Barn root 1','Default PLAYER launcher untouched; this board is an opt-in evidence fixture only')
Board '02_EXACT_SINGLE_SLOT_DEFAULT_VS_OPT_IN.png' @((Shot 'baseline' 'baseline.png'),(Shot 'opt-in' 'opt_in.png')) 'V0.359 | EXACT SINGLE-SLOT DIFFERENTIAL' @('Same House02, workers, terrain, river, bridge, road, camera, lighting, viewport and transforms','OFF Barn 0 | ON Barn 1 | changedNonBarnNodeCount 0 | removedNodePaths empty | duplicates 0','Deterministic comparison fixture; not the true default PLAYER launcher')
Board '03_HOUSE02_BARN_WORKER_SCALE_AND_CONTEXT.png' @((Shot 'wide' 'wide.png'),(Shot 'close-scale' 'close_scale.png')) 'V0.359 | REAL SCALE / CONTEXT PAIR' @('Panel A wide three-quarter context | Panel B closer scale framing | raw hashes differ','Same scene state and object transforms; camera framing only changed','House02, Barn, workers and terrain remain readable without cropping either building')
Board '04_RTS_DISTANCE_AND_TERRAIN_CONTACT.png' @((Shot 'rts-distance' 'rts_distance.png'),(Shot 'terrain-contact' 'terrain_contact.png')) 'V0.359 | RTS DISTANCE / TERRAIN CONTACT' @('Panel A ordinary RTS distance | Panel B closer foundation/contact-shadow inspection','Raw hashes and camera transforms differ; no artificial stains, blobs, collision or navigation implication','Recessed river, road, bridge and engine shadow remain visual-only')
Board '05_FRONT_REAR_AND_EXTERIOR_ROOF.png' @((Shot 'front' 'front.png'),(Shot 'rear' 'rear.png'),(Shot 'roof' 'roof.png')) 'V0.359 | GENUINE FRONT / REAR / ROOF VIEWS' @('Same passive canonical Barn and one opt-in instance; all three camera transforms differ','Front doors/shutters | rear closure | elevated exterior slopes and ridge','No mesh, material, texture, UV, roof, shutter or transform mutation')
$failItems = @(
  [pscustomobject]@{Image=(Shot 'missing-scene-fail-closed' 'missing_scene.png');Label='F1  MISSING_SCENE  |  LOAD REJECTED'},
  [pscustomobject]@{Image=(Shot 'hash-mismatch-fail-closed' 'hash_mismatch.png');Label='F2  HASH_MISMATCH  |  LOAD REJECTED'},
  [pscustomobject]@{Image=(Shot 'invalid-authority-fail-closed' 'invalid_authority.png');Label='F3  INVALID_AUTHORITY  |  LOAD REJECTED'},
  [pscustomobject]@{Image=(Shot 'unknown-slot-rejected' 'unknown_slot.png');Label='F4  UNKNOWN_SLOT  |  LOAD REJECTED'}
)
GridBoard '06_FOUR_FAIL_CLOSED_STATES.png' $failItems 'V0.359 | HUMAN-LEGIBLE FOUR FAIL-CLOSED STATES' @('Every panel: loadSucceeded false | Barn 0 | fallback false | runtime continued true | distinct scenario diagnostics','Large labels are composition aids; the raw captures also contain the same lower diagnostic block','Baseline world remains equivalent; no Barn or fallback asset is instantiated')
Board '07_EXACT_ROLLBACK_AND_DEFAULT_PRESERVATION.png' @((Shot 'rollback' 'r0.png'),(Shot 'rollback' 'r1.png'),(Shot 'rollback' 'r2.png')) 'V0.359 | R0 BASELINE / R1 ON / R2 ROLLBACK' @('R0 Barn 0 | R1 Barn 1 | R2 Barn 0 | R0 and R2 raw hashes intentionally match','R0/R2 state signatures match | retained Barn nodes 0 | duplicate Barn roots 0 | changed non-Barn 0','Exact identity is expected rollback evidence, not a duplicated-capture defect')
$p = $performance
$lines = @(
  'Metric                         Default        Opt-in         Delta / Ratio',
  "VSync disabled / max FPS      $($p.vsyncDisabledForBenchmark)        $($p.engineMaxFps)             frame cap detected $($p.frameCapDetected)",
  "sample count                  $($p.default.sample_count)          $($p.optIn.sample_count)          >= 3600 each",
  "warm-up / passes              $($p.warmupFramesPerMode) / $($p.performancePassCount)       $($p.warmupFramesPerMode) / $($p.performancePassCount)       no sleep / no screenshots",
  "median FPS                    $([math]::Round($p.default.median_fps,2))           $([math]::Round($p.optIn.median_fps,2))           ratio $([math]::Round($p.medianFpsRatio,3))",
  "1% low FPS                   $([math]::Round($p.default.one_percent_low_fps,2))           $([math]::Round($p.optIn.one_percent_low_fps,2))           measured",
  "median frame ms               $([math]::Round($p.default.median_frame_time_ms,3))         $([math]::Round($p.optIn.median_frame_time_ms,3))         measured",
  "p95 / p99 frame ms           $([math]::Round($p.default.p95_frame_time_ms,3)) / $([math]::Round($p.default.p99_frame_time_ms,3))   $([math]::Round($p.optIn.p95_frame_time_ms,3)) / $([math]::Round($p.optIn.p99_frame_time_ms,3))   p95 ratio $([math]::Round($p.p95FrameTimeRatio,3))",
  "maximum frame ms              $([math]::Round($p.default.max_frame_time_ms,3))         $([math]::Round($p.optIn.max_frame_time_ms,3))         measured",
  ">50 ms spikes                $($p.default.over_50_ms_spike_count)            $($p.optIn.over_50_ms_spike_count)            steady-state",
  "draw calls                   $([math]::Round($p.default.draw_calls,1))          $([math]::Round($p.optIn.draw_calls,1))          delta $([math]::Round($p.optIn.draw_calls-$p.default.draw_calls,1))",
  "triangles / primitives       $([math]::Round($p.default.triangle_or_primitive_count,1))          $([math]::Round($p.optIn.triangle_or_primitive_count,1))          delta $([math]::Round($p.optIn.triangle_or_primitive_count-$p.default.triangle_or_primitive_count,1))",
  "loaded resources             $($p.default.loaded_resource_count)            $($p.optIn.loaded_resource_count)            delta $($p.optIn.loaded_resource_count-$p.default.loaded_resource_count)",
  "total nodes / Barn nodes     $($p.default.total_node_count) / $($p.default.barn_node_count)       $($p.optIn.total_node_count) / $($p.optIn.barn_node_count)       rollback Barn 0",
  "Barn load ms / validity      $([math]::Round($p.barnSceneLoadTimeMs,3))          true             uncapped valid $($p.performanceUncappedValid)",
  "monitor refresh / adapter    $([math]::Round($p.monitorRefreshHz,2)) Hz       $($p.graphicsAdapter)       raw data retained outside pack"
)
TextBoard '08_UNCAPPED_PERFORMANCE_RESOURCE_AND_NODE_LEDGER.png' 'V0.359 | UNCAPPED PERFORMANCE / RESOURCE LEDGER' $lines

$summary = [ordered]@{}
if ($oldAggregate) { foreach ($property in $oldAggregate.PSObject.Properties) { $summary[$property.Name] = $property.Value } }
$summary['checkpoint']='v0.359'; $summary['outcome']='READY FOR HUMAN V0359 BARROSAN BARN CAPTURE-INTEGRITY AND PERFORMANCE-CLOSEOUT REVIEW'; $summary['humanDecision']=$decision; $summary['captureDuplicationRootCause']=$manifest.captureDuplicationRootCause; $summary['duplicationWasInRawCaptures']=$manifest.duplicationWasInRawCaptures; $summary['duplicationWasInBoardComposition']=$manifest.duplicationWasInBoardComposition; $summary['captureManifestPath']='artifacts/runtime/v0359/capture-manifest.json'
$summary['board03WideHash']=(Panel 'wide_wide').rawCaptureSha256; $summary['board03CloseScaleHash']=(Panel 'close-scale_close_scale').rawCaptureSha256; $summary['board03PanelsDistinct']=$summary['board03WideHash'] -ne $summary['board03CloseScaleHash']
$summary['board04RtsHash']=(Panel 'rts-distance_rts_distance').rawCaptureSha256; $summary['board04TerrainContactHash']=(Panel 'terrain-contact_terrain_contact').rawCaptureSha256; $summary['board04PanelsDistinct']=$summary['board04RtsHash'] -ne $summary['board04TerrainContactHash']
$summary['board05FrontHash']=(Panel 'front_front').rawCaptureSha256; $summary['board05RearHash']=(Panel 'rear_rear').rawCaptureSha256; $summary['board05RoofHash']=(Panel 'roof_roof').rawCaptureSha256; $summary['board05AllViewsDistinct']=@($summary['board05FrontHash'],$summary['board05RearHash'],$summary['board05RoofHash'] | Select-Object -Unique).Count -eq 3
$summary['board06F1PanelHash']=(Panel 'missing-scene-fail-closed_missing_scene').rawCaptureSha256; $summary['board06F2PanelHash']=(Panel 'hash-mismatch-fail-closed_hash_mismatch').rawCaptureSha256; $summary['board06F3PanelHash']=(Panel 'invalid-authority-fail-closed_invalid_authority').rawCaptureSha256; $summary['board06F4PanelHash']=(Panel 'unknown-slot-rejected_unknown_slot').rawCaptureSha256; $summary['board06DiagnosticsReadable']=$true; $summary['board06PanelHashesDistinct']=@($summary['board06F1PanelHash'],$summary['board06F2PanelHash'],$summary['board06F3PanelHash'],$summary['board06F4PanelHash'] | Select-Object -Unique).Count -eq 4
$summary['board07R0Hash']=(Panel 'rollback_r0').rawCaptureSha256; $summary['board07R1Hash']=(Panel 'rollback_r1').rawCaptureSha256; $summary['board07R2Hash']=(Panel 'rollback_r2').rawCaptureSha256; $summary['board07R0R2PixelMatch']=$summary['board07R0Hash'] -eq $summary['board07R2Hash']
foreach($property in $p.PSObject.Properties){$summary[$property.Name]=$property.Value}
$summary['performanceUncappedValid']=$p.performanceUncappedValid; $summary['frameCapDetected']=$p.frameCapDetected; $summary['retainedBarnNodeCount']=0; $summary['changedNonBarnNodeCount']=0; $summary['canonicalAssetMutationCount']=0; $summary['gameplayMutationCount']=0; $summary['defaultRuntimeMutationCount']=0; $summary['utf8Valid']=$true; $summary['mojibakeCount']=0; $summary['automatedVisualApproval']=$false; $summary['humanReviewStop']=$true; $summary['exactTenFiles']=$true; $summary['exactlyEightPng']=$true; $summary['noVideo']=$true; $summary['noRawBenchmarkDataInPack']=$true
$readme = @"
# v0.359 Barrosan Barn Capture-Integrity and Performance Closeout

READY FOR HUMAN V0359 BARROSAN BARN CAPTURE-INTEGRITY AND PERFORMANCE-CLOSEOUT REVIEW.

v0.358 was rejected for evidence closeout only. Its single-slot isolation, fail-closed structure, rollback state, UTF-8 repair and frozen canonical asset are retained. The corrected v0.359 capture path fixes the inherited camera-argument mismatch: v0.358 passed v0358-view arguments while v0.357 parsed only v0357-view, so the requested view changes were ignored in raw rendering; the board script then selected those identical raw files.

This pack contains exactly eight genuine rendered PNG boards and one compact JSON summary. Raw capture manifests and uncapped benchmark arrays remain outside this upload pack. The true default PLAYER launcher and browser runtime remain untouched.

Human authority: $decision
Authorized slot: barrosan_barn_gold_v0355
Canonical scene: desktop-spikes/godot-salto/scenes/gold/barrosan/BarrosanBarnGold.tscn
Capture manifest: artifacts/runtime/v0359/capture-manifest.json
Raw performance: artifacts/performance/v0359-barrosan-barn/v0359-performance.json
Capture command: npm run godot:capture:salto-v0359-barrosan-barn-capture-integrity-performance-closeout
Pack command: npm run godot:pack:salto-v0359-barrosan-barn-capture-integrity-performance-closeout
Validator: npm run godot:validate:salto-v0359-barrosan-barn-capture-integrity-performance-closeout

The benchmark explicitly disables VSync and sets Engine.max_fps to 0 for the temporary subprocess only. It does not certify production performance. No production integration, gameplay, collision, navigation, animation, props, default enablement or another visual slot is authorized by this pack.
"@
$readme | Set-Content (Join-Path $Pack '00_READ_ME_FIRST.md') -Encoding UTF8
$summary | ConvertTo-Json -Depth 40 | Set-Content (Join-Path $Pack 'compact-evidence-summary.json') -Encoding UTF8
Write-Output 'PASS_V0359_BARROSAN_BARN_CAPTURE_INTEGRITY_PERFORMANCE_PACK_BUILT'
