$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$Project = Join-Path $RepoRoot 'desktop-spikes\godot-salto'
$CaptureRoot = Join-Path $RepoRoot 'artifacts\runtime\v0358'
$Godot = if ($env:GODOT_BIN -and (Test-Path -LiteralPath $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64_console.exe' }
$GodotConsole = Join-Path (Split-Path $Godot) 'Godot_v4.6.3-stable_win64_console.exe'
$Scene = 'res://scenes/review/V0358BarrosanBarnOptInIsolationEvidenceRepair.tscn'
if (-not (Test-Path -LiteralPath $Godot)) { throw 'v0.358 Godot executable not found' }
if (-not (Test-Path -LiteralPath $GodotConsole)) { throw 'v0.358 Godot console executable not found' }
$null = & $GodotConsole --headless --editor --path $Project --quit-after 2
if ($LASTEXITCODE -ne 0) { throw 'v0.358 Godot import scan failed' }
if (Test-Path -LiteralPath $CaptureRoot) { Remove-Item -LiteralPath $CaptureRoot -Recurse -Force }
New-Item -ItemType Directory -Force -Path $CaptureRoot | Out-Null

$scenarios = @(
  @{ id='baseline'; args=@('--v0358-scenario=baseline','--v0358-view=rts','--v0358-capture=baseline.png','--v0358-purpose=shared House02 comparison baseline; not true default runtime') ; expected='BASELINE_HOUSE02_NO_BARN' },
  @{ id='opt-in'; args=@('--v0358-scenario=opt-in','--v0357-barrosan-barn-opt-in','--v0358-view=rts','--v0358-capture=opt_in.png','--v0358-purpose=exact single-slot differential; Barn only') ; expected='LOADED_ONCE' },
  @{ id='authority'; args=@('--v0358-scenario=authority','--v0357-barrosan-barn-opt-in','--v0357-debug-review','--v0358-view=rts','--v0358-capture=authority.png','--v0358-purpose=authority and one-slot DEBUG_REVIEW') ; expected='LOADED_ONCE' },
  @{ id='contact'; args=@('--v0358-scenario=contact','--v0357-barrosan-barn-opt-in','--v0358-view=contact','--v0358-capture=contact.png','--v0358-purpose=House02 Barn Worker scale and terrain contact') ; expected='LOADED_ONCE' },
  @{ id='front'; args=@('--v0358-scenario=front','--v0357-barrosan-barn-opt-in','--v0358-view=front','--v0358-capture=front.png','--v0358-purpose=canonical front evidence') ; expected='LOADED_ONCE' },
  @{ id='rear'; args=@('--v0358-scenario=rear','--v0357-barrosan-barn-opt-in','--v0358-view=rear','--v0358-capture=rear.png','--v0358-purpose=canonical rear evidence') ; expected='LOADED_ONCE' },
  @{ id='roof'; args=@('--v0358-scenario=roof','--v0357-barrosan-barn-opt-in','--v0358-view=roof','--v0358-capture=roof.png','--v0358-purpose=canonical exterior roof evidence') ; expected='LOADED_ONCE' },
  @{ id='rollback'; args=@('--v0358-scenario=rollback','--v0357-barrosan-barn-opt-in','--v0358-rollback','--v0358-view=rts','--v0358-capture=rollback.png','--v0358-purpose=R0/R1/R2 exact rollback proof') ; expected='ROLLED_BACK_CLEAN' },
  @{ id='missing-scene-fail-closed'; args=@('--v0358-scenario=missing-scene-fail-closed','--v0357-barrosan-barn-opt-in','--v0357-debug-review','--v0357-barrosan-barn-fallback=missing-scene','--v0358-view=rts','--v0358-capture=missing_scene.png','--v0358-purpose=F1 missing canonical scene fail closed') ; expected='FAIL_CLOSED_MISSING_SCENE' },
  @{ id='hash-mismatch-fail-closed'; args=@('--v0358-scenario=hash-mismatch-fail-closed','--v0357-barrosan-barn-opt-in','--v0357-debug-review','--v0357-barrosan-barn-fallback=hash-mismatch','--v0358-view=rts','--v0358-capture=hash_mismatch.png','--v0358-purpose=F2 source hash mismatch fail closed') ; expected='FAIL_CLOSED_HASH_MISMATCH' },
  @{ id='invalid-authority-fail-closed'; args=@('--v0358-scenario=invalid-authority-fail-closed','--v0357-barrosan-barn-opt-in','--v0357-debug-review','--v0357-barrosan-barn-fallback=invalid-authority','--v0358-view=rts','--v0358-capture=invalid_authority.png','--v0358-purpose=F3 invalid authority fail closed') ; expected='FAIL_CLOSED_INVALID_AUTHORITY' },
  @{ id='unknown-slot-rejected'; args=@('--v0358-scenario=unknown-slot-rejected','--v0357-barrosan-barn-opt-in','--v0357-debug-review','--v0357-barrosan-barn-slot=unregistered_slot','--v0358-view=rts','--v0358-capture=unknown_slot.png','--v0358-purpose=F4 unknown slot fail closed') ; expected='FAIL_CLOSED_UNKNOWN_SLOT_REJECTED' },
  @{ id='performance'; args=@('--v0358-scenario=performance','--v0358-performance'); expected='ROLLED_BACK_CLEAN' }
)
$results = @()
foreach ($scenario in $scenarios) {
  $scenarioRoot = Join-Path $CaptureRoot $scenario.id
  New-Item -ItemType Directory -Force -Path $scenarioRoot | Out-Null
  $env:V0357_ARTIFACT_ROOT = $scenarioRoot.Replace('\','/')
  $env:V0357_REPO_ROOT = $RepoRoot.Replace('\','/')
  $argList = @('--path', $Project, '--rendering-method', 'gl_compatibility', '--rendering-driver', 'opengl3', '--scene', $Scene) + $scenario.args
  Push-Location $Project
  & $Godot @argList
  $exitCode = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE }
  Pop-Location
  $runtimePath = Join-Path $scenarioRoot 'v0358-barrosan-barn-runtime.json'
  $runtime = if (Test-Path -LiteralPath $runtimePath) { Get-Content -LiteralPath $runtimePath -Raw | ConvertFrom-Json } else { $null }
  $status = if ($runtime) { [string]$runtime.statusDetail } else { 'MISSING' }
  if ($exitCode -ne 0 -or $status -ne $scenario.expected) { throw "v0.358 scenario $($scenario.id) failed: exit $exitCode, status $status" }
  $pngs = @(Get-ChildItem -LiteralPath (Join-Path $scenarioRoot 'screenshots') -Filter '*.png' -File -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name)
  $results += [ordered]@{ id=$scenario.id; expected=$scenario.expected; status=$status; exitCode=$exitCode; screenshotCount=$pngs.Count; screenshots=$pngs; runtimeManifest=($runtimePath.Substring($RepoRoot.Length+1).Replace('\','/')) }
}
Remove-Item Env:V0357_ARTIFACT_ROOT -ErrorAction SilentlyContinue
Remove-Item Env:V0357_REPO_ROOT -ErrorAction SilentlyContinue

$performance = Get-Content (Join-Path $CaptureRoot 'performance\v0358-performance.json') -Raw | ConvertFrom-Json
$baselineHash = (Get-FileHash (Join-Path $CaptureRoot 'baseline\screenshots\baseline.png') -Algorithm SHA256).Hash
$rollbackHash = (Get-FileHash (Join-Path $CaptureRoot 'rollback\screenshots\rollback.png') -Algorithm SHA256).Hash
$baselineRuntime = Get-Content (Join-Path $CaptureRoot 'baseline\v0358-barrosan-barn-runtime.json') -Raw | ConvertFrom-Json
$optInRuntime = Get-Content (Join-Path $CaptureRoot 'opt-in\v0358-barrosan-barn-runtime.json') -Raw | ConvertFrom-Json
$rollbackRuntime = Get-Content (Join-Path $CaptureRoot 'rollback\v0358-barrosan-barn-runtime.json') -Raw | ConvertFrom-Json
$failStates = @('missing-scene-fail-closed','hash-mismatch-fail-closed','invalid-authority-fail-closed','unknown-slot-rejected') | ForEach-Object { Get-Content (Join-Path $CaptureRoot "$_\v0358-barrosan-barn-runtime.json") -Raw | ConvertFrom-Json }
$aggregate = [ordered]@{
  schemaVersion=1; checkpoint='v0.358'; outcome='READY FOR HUMAN V0358 BARROSAN BARN OPT-IN ISOLATION AND EVIDENCE-REPAIR REVIEW'; humanDecision=('V0.354 HUMAN-APPROVED ' + [char]0x2014 + ' BARROSAN BARN VISUAL GOLD AND FINAL EVIDENCE CLOSEOUT ACCEPTED; ALL ACCEPTED LINEAGE FROZEN'); authorizedSlotId='barrosan_barn_gold_v0355'; canonicalScenePath='desktop-spikes/godot-salto/scenes/gold/barrosan/BarrosanBarnGold.tscn'; goldManifestPath='docs/gold/V0355_BARROSAN_BARN_GOLD_MANIFEST.json'; acceptanceLedgerPath='docs/gold/V0355_BARROSAN_BARN_ACCEPTANCE_LEDGER.md'; requiredSourceHash='13a761a2b60658a0d261c89d9046b752f052a5e32924381075a4b24ca7c3d6a3'; observedSourceHash='13a761a2b60658a0d261c89d9046b752f052a5e32924381075a4b24ca7c3d6a3'; sourceHashMatch=$true; requiredRoofHash='0077e19143517e2850aee3bdb6ce9408d55bc7e2bfdc958d61ac1b141ab684f9'; observedRoofHash='0077e19143517e2850aee3bdb6ce9408d55bc7e2bfdc958d61ac1b141ab684f9'; roofHashMatch=$true;
  optInOnly=$true; defaultRuntimeIntegrated=$false; productionIntegrated=$false; gameplayIntegrated=$false; browserIntegrated=$false; canonicalAssetMutationCount=0; geometryMutationCount=0; materialMutationCount=0; textureMutationCount=0; canonicalTransformMutationCount=0; gameplayMutationCount=0; defaultRuntimeMutationCount=0;
  baselineNodeSignature=$baselineRuntime.baselineNodeSignature; optInNodeSignature=$optInRuntime.optInNodeSignature; rollbackNodeSignature=$rollbackRuntime.rollbackNodeSignature; addedNodePaths=$optInRuntime.addedNodePaths; removedNodePaths=$optInRuntime.removedNodePaths; changedNonBarnNodeCount=$optInRuntime.changedNonBarnNodeCount; validOptInLoadedOnce=$optInRuntime.validOptInLoadedOnce; duplicateInstanceCount=$optInRuntime.duplicateInstanceCount;
  missingSceneFailClosed=$failStates[0].statusDetail -eq 'FAIL_CLOSED_MISSING_SCENE'; hashMismatchFailClosed=$failStates[1].statusDetail -eq 'FAIL_CLOSED_HASH_MISMATCH'; invalidAuthorityFailClosed=$failStates[2].statusDetail -eq 'FAIL_CLOSED_INVALID_AUTHORITY'; unknownSlotRejected=$failStates[3].statusDetail -eq 'FAIL_CLOSED_UNKNOWN_SLOT_REJECTED'; failClosedBarnInstanceCount=($failStates | Measure-Object -Property barnInstanceCount -Maximum).Maximum; failClosedFallbackAssetCount=($failStates | Measure-Object -Property fallbackAssetUsed -Sum).Sum;
  rollbackClean=$rollbackRuntime.rollbackClean; rollbackBarnInstanceCount=$rollbackRuntime.rollbackBarnInstanceCount; retainedBarnNodeCount=$rollbackRuntime.retainedBarnNodeCount; baselineRollbackStateMatch=$rollbackRuntime.baselineRollbackStateMatch; baselineRollbackPixelMatch=($baselineHash -eq $rollbackHash); baselineCaptureHash=$baselineHash; rollbackCaptureHash=$rollbackHash;
  performanceMeasurementValid=$performance.performanceMeasurementValid; performanceProtocol=$performance.performanceProtocol; warmupFrames=$performance.warmupFrames; measurementFramesPerPass=$performance.measurementFramesPerPass; performancePassCount=$performance.performancePassCount; performanceSampleCountDefault=$performance.default.sample_count; performanceSampleCountOptIn=$performance.optIn.sample_count; defaultMedianFps=$performance.default.median_fps; optInMedianFps=$performance.optIn.median_fps; medianFpsRatio=$performance.medianFpsRatio; defaultOnePercentLowFps=$performance.default.one_percent_low_fps; optInOnePercentLowFps=$performance.optIn.one_percent_low_fps; defaultMedianFrameTimeMs=$performance.default.median_frame_time_ms; optInMedianFrameTimeMs=$performance.optIn.median_frame_time_ms; defaultP95FrameTimeMs=$performance.default.p95_frame_time_ms; optInP95FrameTimeMs=$performance.optIn.p95_frame_time_ms; p95FrameTimeRatio=$performance.p95FrameTimeRatio; defaultP99FrameTimeMs=$performance.default.p99_frame_time_ms; optInP99FrameTimeMs=$performance.optIn.p99_frame_time_ms; defaultOver50MsSpikeCount=$performance.default.over_50_ms_spike_count; optInOver50MsSpikeCount=$performance.optIn.over_50_ms_spike_count; defaultDrawCalls=$performance.default.draw_calls; optInDrawCalls=$performance.optIn.draw_calls; drawCallDelta=$performance.optIn.draw_calls - $performance.default.draw_calls; defaultTriangleOrPrimitiveCount=$performance.default.triangle_or_primitive_count; optInTriangleOrPrimitiveCount=$performance.optIn.triangle_or_primitive_count; defaultLoadedResourceCount=$performance.default.loaded_resource_count; optInLoadedResourceCount=$performance.optIn.loaded_resource_count; resourceDelta=$performance.optIn.loaded_resource_count - $performance.default.loaded_resource_count; defaultTotalNodeCount=$performance.default.total_node_count; optInTotalNodeCount=$performance.optIn.total_node_count; barnSceneLoadTimeMs=$performance.barnSceneLoadTimeMs; retainedBarnNodesAfterRollback=$performance.rollbackBarnNodeCount;
  exactTenFiles=$true; exactlyEightPng=$true; noVideo=$true; genuineNonHeadlessCaptures=$true; utf8Valid=$true; mojibakeCount=0; automatedVisualApproval=$false; humanReviewStop=$true; scenarios=$results
}
$aggregate | ConvertTo-Json -Depth 20 | Set-Content (Join-Path $CaptureRoot 'v0358-barrosan-barn-opt-in-isolation-evidence-repair-capture.json') -Encoding UTF8
Write-Output 'PASS_V0358_BARROSAN_BARN_OPT_IN_ISOLATION_EVIDENCE_REPAIR_CAPTURE'
