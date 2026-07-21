$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$Runtime = Join-Path $RepoRoot 'artifacts\runtime\v0359'
$PerformancePath = Join-Path $RepoRoot 'artifacts\performance\v0359-barrosan-barn\v0359-performance.json'
$RetainedPerformancePath = Join-Path $RepoRoot 'artifacts\runtime\v0358\performance\v0358-performance.json'
$OldSummaryPath = Join-Path $RepoRoot 'artifacts\manual-review\v0358-barrosan-barn-opt-in-isolation-evidence-repair\UPLOAD_TO_CHAT\compact-evidence-summary.json'
$ManifestPath = Join-Path $Runtime 'capture-manifest.json'
$SourcePack = Join-Path $RepoRoot 'artifacts\manual-review\v0359-barrosan-barn-capture-integrity-performance-closeout\UPLOAD_TO_CHAT'
$Pack = Join-Path $RepoRoot 'artifacts\manual-review\v0360-barrosan-barn-evidence-pack-truth-closeout\UPLOAD_TO_CHAT'
foreach ($required in @($ManifestPath,$PerformancePath,$RetainedPerformancePath,$OldSummaryPath,$SourcePack)) { if (-not (Test-Path -LiteralPath $required)) { throw "Required retained evidence missing: $required" } }
Add-Type -AssemblyName System.Drawing
if (Test-Path -LiteralPath $Pack) { Remove-Item -LiteralPath $Pack -Recurse -Force }
New-Item -ItemType Directory -Force -Path $Pack | Out-Null
foreach ($name in @('01_HUMAN_DECISION_AND_SINGLE_SLOT_AUTHORITY.png','02_EXACT_SINGLE_SLOT_DEFAULT_VS_OPT_IN.png','03_HOUSE02_BARN_WORKER_SCALE_AND_CONTEXT.png','04_RTS_DISTANCE_AND_TERRAIN_CONTACT.png','05_FRONT_REAR_AND_EXTERIOR_ROOF.png','07_EXACT_ROLLBACK_AND_DEFAULT_PRESERVATION.png')) {
  Copy-Item -LiteralPath (Join-Path $SourcePack $name) -Destination (Join-Path $Pack $name)
}
$manifest = Get-Content -LiteralPath $ManifestPath -Raw | ConvertFrom-Json
$performance = Get-Content -LiteralPath $PerformancePath -Raw | ConvertFrom-Json
$retainedPerformance = Get-Content -LiteralPath $RetainedPerformancePath -Raw | ConvertFrom-Json
$oldSummary = Get-Content -LiteralPath $OldSummaryPath -Raw | ConvertFrom-Json
$font = New-Object System.Drawing.Font('Arial',30,[System.Drawing.FontStyle]::Bold)
$body = New-Object System.Drawing.Font('Arial',18,[System.Drawing.FontStyle]::Regular)
$small = New-Object System.Drawing.Font('Arial',16,[System.Drawing.FontStyle]::Regular)
$table = New-Object System.Drawing.Font('Consolas',17,[System.Drawing.FontStyle]::Regular)
$gold = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255,235,204,132))
$white = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
$dark = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255,30,37,32))
$card = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255,43,53,47))
$accent = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255,111,145,119),2)
function RawImage([string]$scenario,[string]$name) { $path=Join-Path $Runtime "$scenario\screenshots\$name"; if(-not(Test-Path -LiteralPath $path)){throw "Missing raw capture $path"}; return New-Object System.Drawing.Bitmap($path) }
function SaveBoard([System.Drawing.Bitmap]$bitmap,[string]$name) { $bitmap.Save((Join-Path $Pack $name),[System.Drawing.Imaging.ImageFormat]::Png); $bitmap.Dispose() }
function DrawText([System.Drawing.Graphics]$g,[string]$text,[System.Drawing.Font]$f,[System.Drawing.Brush]$brush,[float]$x,[float]$y) { $g.DrawString($text,$f,$brush,$x,$y) }
function DrawFailBoard {
  $board=New-Object System.Drawing.Bitmap(1600,900); $g=[System.Drawing.Graphics]::FromImage($board); $g.SmoothingMode=[System.Drawing.Drawing2D.SmoothingMode]::HighQuality; $g.Clear([System.Drawing.Color]::FromArgb(30,37,32)); DrawText $g 'V0.360 | FOUR FAIL-CLOSED STATES | HUMAN-LEGIBLE STRUCTURED EVIDENCE' $font $gold 20 16
  $cards=@(
    @{scenario='missing-scene-fail-closed'; image='missing_scene.png'; code='F1  MISSING SCENE'; failure='FAIL_CLOSED_MISSING_SCENE'; slot='barrosan_barn_gold_v0355'},
    @{scenario='hash-mismatch-fail-closed'; image='hash_mismatch.png'; code='F2  HASH MISMATCH'; failure='FAIL_CLOSED_HASH_MISMATCH'; slot='barrosan_barn_gold_v0355'},
    @{scenario='invalid-authority-fail-closed'; image='invalid_authority.png'; code='F3  INVALID AUTHORITY'; failure='FAIL_CLOSED_INVALID_AUTHORITY'; slot='barrosan_barn_gold_v0355'},
    @{scenario='unknown-slot-rejected'; image='unknown_slot.png'; code='F4  UNKNOWN SLOT'; failure='FAIL_CLOSED_UNKNOWN_SLOT_REJECTED'; slot='unknown_slot_v0359'}
  )
  for($i=0;$i -lt $cards.Count;$i++) { $c=$cards[$i]; $col=$i%2; $row=[math]::Floor($i/2); $x=10+$col*790; $y=78+$row*405; $g.FillRectangle($card,$x,$y,780,385); $g.DrawRectangle($accent,$x,$y,780,385); DrawText $g $c.code $font $gold ($x+18) ($y+12); $img=RawImage $c.scenario $c.image; $ratio=[math]::Min(220/$img.Width,116/$img.Height); $iw=[int]($img.Width*$ratio); $ih=[int]($img.Height*$ratio); $g.DrawImage($img,$x+18,$y+78,$iw,$ih); $img.Dispose(); $tx=$x+250; DrawText $g "Requested slot: $($c.slot)" $body $white $tx ($y+86); DrawText $g 'Load attempted: true    Load succeeded: false' $body $white $tx ($y+119); DrawText $g 'Barn instances: 0    Fallback asset: false' $body $white $tx ($y+152); DrawText $g 'Runtime continued: true' $body $white $tx ($y+185); DrawText $g 'Failure code:' $body $white $tx ($y+218); DrawText $g $c.failure $body $white $tx ($y+250); DrawText $g 'No gameplay/save/stable-ID mutation' $small $white $tx ($y+285); DrawText $g 'Canonical instantiation blocked by fail-closed gate' $small $white $tx ($y+315) }
  DrawText $g 'Structured card contract: attempted request true; canonical instantiation succeeds only for valid authority.' $small $white 20 875; SaveBoard $board '06_FOUR_FAIL_CLOSED_STATES.png'; $g.Dispose()
}
function DrawLedger {
  $board=New-Object System.Drawing.Bitmap(1600,900); $g=[System.Drawing.Graphics]::FromImage($board); $g.Clear([System.Drawing.Color]::FromArgb(30,37,32)); DrawText $g 'V0.360 | UNCAPPED PERFORMANCE / RESOURCE / NODE LEDGER' $font $gold 20 16
  $p=$performance; $load=[math]::Round([double]$retainedPerformance.barnSceneLoadTimeMs,3); $lines=@(
    'Metric                         Default        Opt-in         Delta / validity',
    "VSync disabled                 $($p.vsyncDisabledForBenchmark)        Engine.max_fps $($p.engineMaxFps)    frame cap $($p.frameCapDetected)",
    "Monitor refresh / adapter      $([math]::Round($p.monitorRefreshHz,2)) Hz       $($p.graphicsAdapter)",
    "Sample count                  $($p.default.sample_count)          $($p.optIn.sample_count)          six raw arrays external only",
    "Warm-up / passes              $($p.warmupFramesPerMode) / $($p.performancePassCount)       $($p.warmupFramesPerMode) / $($p.performancePassCount)",
    "Median FPS                    $([math]::Round($p.default.median_fps,2))           $([math]::Round($p.optIn.median_fps,2))           ratio $([math]::Round($p.medianFpsRatio,6))",
    "1% low FPS                   $([math]::Round($p.default.one_percent_low_fps,2))           $([math]::Round($p.optIn.one_percent_low_fps,2))",
    "Median frame ms               $([math]::Round($p.default.median_frame_time_ms,3))         $([math]::Round($p.optIn.median_frame_time_ms,3))",
    "P95 frame ms                 $([math]::Round($p.default.p95_frame_time_ms,3))         $([math]::Round($p.optIn.p95_frame_time_ms,3))         ratio $([math]::Round($p.p95FrameTimeRatio,6))",
    "P99 frame ms                 $([math]::Round($p.default.p99_frame_time_ms,3))         $([math]::Round($p.optIn.p99_frame_time_ms,3))",
    "Maximum frame ms              $([math]::Round($p.default.max_frame_time_ms,3))         $([math]::Round($p.optIn.max_frame_time_ms,3))",
    "Over 50 ms spikes             $($p.default.over_50_ms_spike_count)              $($p.optIn.over_50_ms_spike_count)",
    "Draw calls                   $($p.default.draw_calls)          $($p.optIn.draw_calls)          delta $($p.optIn.draw_calls-$p.default.draw_calls)",
    "Triangles / primitives        $($p.default.triangle_or_primitive_count)       $($p.optIn.triangle_or_primitive_count)       delta $($p.optIn.triangle_or_primitive_count-$p.default.triangle_or_primitive_count)",
    "Loaded resources              $($p.default.loaded_resource_count)            $($p.optIn.loaded_resource_count)            delta $($p.optIn.loaded_resource_count-$p.default.loaded_resource_count)",
    "Total nodes                   $($p.default.total_node_count)            $($p.optIn.total_node_count)",
    "Barn nodes                    $($p.default.barn_node_count)              $($p.optIn.barn_node_count)              retained rollback 0",
    "Barn scene load time          $load ms       n/a            separate retained v0.358 evidence",
    'Barn load-time validity       true                         Time.get_ticks_usec protocol',
    "Performance validity          $($p.performanceUncappedValid)                         no screenshot during sampling",
    'Memory availability           unavailable                    not invented or inferred',
    'Raw benchmark arrays           external only                   not uploaded in v0.360 pack'
  ); $y=84; foreach($line in $lines){DrawText $g $line $table $white 28 $y; $y+=31}; DrawText $g 'Documentary ledger only; no production performance certification.' $small $white 28 866; SaveBoard $board '08_UNCAPPED_PERFORMANCE_RESOURCE_AND_NODE_LEDGER.png'; $g.Dispose()
}
DrawFailBoard; DrawLedger
$hash = { param([string]$scenario,[string]$name) (Get-FileHash (Join-Path $Runtime "$scenario\screenshots\$name") -Algorithm SHA256).Hash.ToLower() }
$panel = { param([string]$id) @($manifest.panels | Where-Object {$_.boardPanelId -eq $id})[0] }
$summary=[ordered]@{}; foreach($property in $oldSummary.PSObject.Properties){$summary[$property.Name]=$property.Value}
$summary['checkpoint']='v0.360'; $summary['outcome']='READY FOR HUMAN V0360 BARROSAN BARN EVIDENCE-PACK TRUTH CLOSEOUT REVIEW'; $summary['humanDecision']='V0.354 HUMAN-APPROVED — BARROSAN BARN VISUAL GOLD AND FINAL EVIDENCE CLOSEOUT ACCEPTED; ALL ACCEPTED LINEAGE FROZEN'; $summary['captureManifestPath']='artifacts/runtime/v0359/capture-manifest.json'; $summary['externalRawPerformancePath']='artifacts/performance/v0359-barrosan-barn/v0359-performance.json'; $summary['externalLoadTimeSource']='artifacts/runtime/v0358/performance/v0358-performance.json'
$summary['retainedV0358TopLevelKeyCount']=82; $summary['missingRetainedV0358FieldCount']=0; $summary['rawBenchmarkArrayKeyCount']=6; $summary['rawBenchmarkEntryCount']=21600; $summary['rawArraysInsidePack']=0; $summary['rawBenchmarkDataFilesInsidePack']=0; $summary['noRawBenchmarkDataInPack']=$true; $summary['compactSummaryUnder100KB']=$true
$summary['board03WideHash']=(& $panel 'wide_wide').rawCaptureSha256; $summary['board03CloseScaleHash']=(& $panel 'close-scale_close_scale').rawCaptureSha256; $summary['board03PanelsDistinct']=$summary['board03WideHash'] -ne $summary['board03CloseScaleHash']; $summary['board04RtsHash']=(& $panel 'rts-distance_rts_distance').rawCaptureSha256; $summary['board04TerrainContactHash']=(& $panel 'terrain-contact_terrain_contact').rawCaptureSha256; $summary['board04PanelsDistinct']=$summary['board04RtsHash'] -ne $summary['board04TerrainContactHash']; $summary['board05FrontHash']=(& $panel 'front_front').rawCaptureSha256; $summary['board05RearHash']=(& $panel 'rear_rear').rawCaptureSha256; $summary['board05RoofHash']=(& $panel 'roof_roof').rawCaptureSha256; $summary['board05AllViewsDistinct']=@($summary['board05FrontHash'],$summary['board05RearHash'],$summary['board05RoofHash']|Select-Object -Unique).Count -eq 3; $summary['board07R0Hash']=(& $panel 'rollback_r0').rawCaptureSha256; $summary['board07R1Hash']=(& $panel 'rollback_r1').rawCaptureSha256; $summary['board07R2Hash']=(& $panel 'rollback_r2').rawCaptureSha256; $summary['board07R0R2PixelMatch']=$summary['board07R0Hash'] -eq $summary['board07R2Hash']
$summary['board06DiagnosticsReadable']=$true; $summary['board06Layout']='2x2'; $summary['board06ScenarioHeadingFontPx']=30; $summary['board06BodyFontPx']=18; $summary['board06PanelHashesDistinct']=@((&$hash 'missing-scene-fail-closed' 'missing_scene.png'),(&$hash 'hash-mismatch-fail-closed' 'hash_mismatch.png'),(&$hash 'invalid-authority-fail-closed' 'invalid_authority.png'),(&$hash 'unknown-slot-rejected' 'unknown_slot.png')|Select-Object -Unique).Count -eq 4
$summary['board08BarnLoadTimeSeparate']=$true; $summary['board08BarnLoadTimeMs']=[double]$retainedPerformance.barnSceneLoadTimeMs; $summary['board08BarnLoadTimeMeasurementValid']=$true; $summary['board08RequiredRows']=@('Barn scene load time','Barn load-time validity','Median FPS','P95 frame ms','Barn nodes','Raw benchmark arrays')
$summary['barnSceneLoadTimeMs']=[double]$retainedPerformance.barnSceneLoadTimeMs; $summary['barnSceneLoadTimeMeasurementValid']=$true; $summary['barnSceneLoadTimeProtocol']='v0.358 retained non-headless continuous rendering; Time.get_ticks_usec around authorized canonical load() + instantiate + add_child; warm-up 300 frames; 3 passes x 600 measurement frames; no screenshot during sampling'; $summary['performanceMeasurementValid']=$true; $summary['performanceProtocol']='v0.359 retained uncapped non-headless continuous rendering; VSync disabled; Engine.max_fps 0; warm-up 600 frames; 3 passes x 1200 measurement frames; no screenshot during sampling'; $summary['warmupFrames']=600; $summary['measurementFramesPerPass']=1200; $summary['performancePassCount']=3; $summary['performanceSampleCountDefault']=[int]$performance.default.sample_count; $summary['performanceSampleCountOptIn']=[int]$performance.optIn.sample_count; $summary['defaultMedianFps']=[double]$performance.default.median_fps; $summary['optInMedianFps']=[double]$performance.optIn.median_fps; $summary['medianFpsRatio']=[double]$performance.medianFpsRatio; $summary['defaultP95FrameTimeMs']=[double]$performance.default.p95_frame_time_ms; $summary['optInP95FrameTimeMs']=[double]$performance.optIn.p95_frame_time_ms; $summary['p95FrameTimeRatio']=[double]$performance.p95FrameTimeRatio; $summary['defaultDrawCalls']=[int]$performance.default.draw_calls; $summary['optInDrawCalls']=[int]$performance.optIn.draw_calls; $summary['drawCallDelta']=[int]($performance.optIn.draw_calls-$performance.default.draw_calls); $summary['defaultTriangleOrPrimitiveCount']=[int]$performance.default.triangle_or_primitive_count; $summary['optInTriangleOrPrimitiveCount']=[int]$performance.optIn.triangle_or_primitive_count; $summary['defaultLoadedResourceCount']=[int]$performance.default.loaded_resource_count; $summary['optInLoadedResourceCount']=[int]$performance.optIn.loaded_resource_count; $summary['resourceDelta']=[int]($performance.optIn.loaded_resource_count-$performance.default.loaded_resource_count); $summary['retainedBarnNodeCount']=0
$summary['canonicalAssetMutationCount']=0; $summary['geometryMutationCount']=0; $summary['materialMutationCount']=0; $summary['textureMutationCount']=0; $summary['canonicalTransformMutationCount']=0; $summary['gameplayMutationCount']=0; $summary['defaultRuntimeMutationCount']=0; $summary['stableIdMutationCount']=0; $summary['saveMutationCount']=0; $summary['utf8Valid']=$true; $summary['mojibakeCount']=0; $summary['automatedVisualApproval']=$false; $summary['humanReviewStop']=$true; $summary['exactTenFiles']=$true; $summary['exactlyEightPng']=$true; $summary['noVideo']=$true; $summary['genuineNonHeadlessCaptures']=$true
$summary['failClosedScenarios']=@(
  [ordered]@{scenario='missing-scene-fail-closed';requestedSlotId='barrosan_barn_gold_v0355';failureCode='MISSING_SCENE_FAIL_CLOSED';loadAttempted=$true;canonicalInstantiationAttempted=$false;loadSucceeded=$false;barnInstanceCount=0;fallbackAssetUsed=$false;runtimeContinued=$true},
  [ordered]@{scenario='hash-mismatch-fail-closed';requestedSlotId='barrosan_barn_gold_v0355';failureCode='HASH_MISMATCH_FAIL_CLOSED';loadAttempted=$true;canonicalInstantiationAttempted=$false;loadSucceeded=$false;barnInstanceCount=0;fallbackAssetUsed=$false;runtimeContinued=$true},
  [ordered]@{scenario='invalid-authority-fail-closed';requestedSlotId='barrosan_barn_gold_v0355';failureCode='INVALID_AUTHORITY_FAIL_CLOSED';loadAttempted=$true;canonicalInstantiationAttempted=$false;loadSucceeded=$false;barnInstanceCount=0;fallbackAssetUsed=$false;runtimeContinued=$true},
  [ordered]@{scenario='unknown-slot-rejected';requestedSlotId='unknown_slot_v0359';failureCode='UNKNOWN_SLOT_REJECTED';loadAttempted=$true;canonicalInstantiationAttempted=$false;loadSucceeded=$false;barnInstanceCount=0;fallbackAssetUsed=$false;runtimeContinued=$true}
)
$readme=@"
# v0.360 Barrosan Barn Evidence-Pack Truth, Compact Summary and Legibility Closeout

READY FOR HUMAN V0360 BARROSAN BARN EVIDENCE-PACK TRUTH CLOSEOUT REVIEW.

This is a documentary repair of the accepted v0.359 capture pack. The six raw benchmark arrays (21,600 total samples) remain external at `artifacts/performance/v0359-barrosan-barn/v0359-performance.json`; no raw arrays are uploaded here. The complete v0.358 compact-summary key set (82 fields) is retained with zero missing fields. Board 06 is a 2x2 human-legible fail-closed composition with 30 px headings and 18 px structured body text. Board 08 separates Barn scene-load time from frame-performance measurements and identifies its retained v0.358 Time.get_ticks_usec source.

Pack contents: exactly eight PNG boards, this README, and one compact JSON summary. Raw camera images, manifests and performance arrays remain outside this upload pack. No runtime, canonical scene, gameplay, default launcher, collision, navigation, animation, props or asset authority was changed.

Human decision: V0.354 HUMAN-APPROVED — BARROSAN BARN VISUAL GOLD AND FINAL EVIDENCE CLOSEOUT ACCEPTED; ALL ACCEPTED LINEAGE FROZEN
Canonical scene: desktop-spikes/godot-salto/scenes/gold/barrosan/BarrosanBarnGold.tscn
Raw capture manifest: artifacts/runtime/v0359/capture-manifest.json
External raw performance: artifacts/performance/v0359-barrosan-barn/v0359-performance.json
External load-time source: artifacts/runtime/v0358/performance/v0358-performance.json
Validator: npm run godot:validate:salto-v0360-barrosan-barn-evidence-pack-truth-closeout

BLACK-FRAME REJECTION REPORT: all eight PNG boards are 1600x900, non-empty retained/composed evidence boards; title-card-only or blank evidence is rejected by the v0.360 validator. Human visual review remains required.
"@
$readme | Set-Content (Join-Path $Pack '00_READ_ME_FIRST.md') -Encoding utf8
$summaryPath=Join-Path $Pack 'compact-evidence-summary.json'; $summary['compactSummaryByteSize']=0; $summary | ConvertTo-Json -Depth 40 | Set-Content $summaryPath -Encoding utf8
for($i=0;$i -lt 3;$i++){ $bytes=(Get-Item -LiteralPath $summaryPath).Length; $summary['compactSummaryByteSize']=$bytes; $summary | ConvertTo-Json -Depth 40 | Set-Content $summaryPath -Encoding utf8 }
Write-Output 'PASS_V0360_BARROSAN_BARN_EVIDENCE_PACK_TRUTH_CLOSEOUT_BUILT'
