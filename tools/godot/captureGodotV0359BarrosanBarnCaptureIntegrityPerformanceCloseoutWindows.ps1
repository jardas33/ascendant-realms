$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$Project = Join-Path $RepoRoot 'desktop-spikes\godot-salto'
$CaptureRoot = Join-Path $RepoRoot 'artifacts\runtime\v0359'
$PerformanceRoot = Join-Path $RepoRoot 'artifacts\performance\v0359-barrosan-barn'
$Godot = if ($env:GODOT_BIN -and (Test-Path -LiteralPath $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64_console.exe' }
$GodotConsole = Join-Path (Split-Path $Godot) 'Godot_v4.6.3-stable_win64_console.exe'
$Scene = 'res://scenes/review/V0359BarrosanBarnCaptureIntegrityPerformanceCloseout.tscn'
if (-not (Test-Path -LiteralPath $Godot)) { throw 'v0.359 Godot executable not found' }
if (-not (Test-Path -LiteralPath $GodotConsole)) { throw 'v0.359 Godot console executable not found' }
$null = & $GodotConsole --headless --editor --path $Project --quit-after 2
if ($LASTEXITCODE -ne 0) { throw 'v0.359 Godot import scan failed' }
if (Test-Path -LiteralPath $CaptureRoot) { Remove-Item -LiteralPath $CaptureRoot -Recurse -Force }
if (Test-Path -LiteralPath $PerformanceRoot) { Remove-Item -LiteralPath $PerformanceRoot -Recurse -Force }
New-Item -ItemType Directory -Force -Path $CaptureRoot | Out-Null
New-Item -ItemType Directory -Force -Path $PerformanceRoot | Out-Null

$scenarios = @(
  @{ id='baseline'; args=@('--v0359-scenario=baseline','--v0359-view=rts','--v0359-capture=baseline.png','--v0359-purpose=shared House02 comparison baseline; not true default runtime') ; expected='BASELINE_HOUSE02_NO_BARN' },
  @{ id='opt-in'; args=@('--v0359-scenario=opt-in','--v0357-barrosan-barn-opt-in','--v0359-view=rts','--v0359-capture=opt_in.png','--v0359-purpose=exact single-slot differential; Barn only') ; expected='LOADED_ONCE' },
  @{ id='authority'; args=@('--v0359-scenario=authority','--v0357-barrosan-barn-opt-in','--v0357-debug-review','--v0359-view=rts','--v0359-capture=authority.png','--v0359-purpose=authority and one-slot DEBUG_REVIEW') ; expected='LOADED_ONCE' },
  @{ id='wide'; args=@('--v0359-scenario=wide','--v0357-barrosan-barn-opt-in','--v0359-view=wide','--v0359-capture=wide.png','--v0359-purpose=ordinary wide three-quarter context') ; expected='LOADED_ONCE' },
  @{ id='close-scale'; args=@('--v0359-scenario=close-scale','--v0357-barrosan-barn-opt-in','--v0359-view=close-scale','--v0359-capture=close_scale.png','--v0359-purpose=closer House02 Barn worker scale context') ; expected='LOADED_ONCE' },
  @{ id='rts-distance'; args=@('--v0359-scenario=rts-distance','--v0357-barrosan-barn-opt-in','--v0359-view=rts','--v0359-capture=rts_distance.png','--v0359-purpose=ordinary RTS gameplay-distance framing') ; expected='LOADED_ONCE' },
  @{ id='terrain-contact'; args=@('--v0359-scenario=terrain-contact','--v0357-barrosan-barn-opt-in','--v0359-view=terrain-contact','--v0359-capture=terrain_contact.png','--v0359-purpose=closer Barn foundation and engine contact shadow framing') ; expected='LOADED_ONCE' },
  @{ id='front'; args=@('--v0359-scenario=front','--v0357-barrosan-barn-opt-in','--v0359-view=front','--v0359-capture=front.png','--v0359-purpose=front three-quarter agricultural door and shutter view') ; expected='LOADED_ONCE' },
  @{ id='rear'; args=@('--v0359-scenario=rear','--v0357-barrosan-barn-opt-in','--v0359-view=rear','--v0359-capture=rear.png','--v0359-purpose=rear wall and roof closure view') ; expected='LOADED_ONCE' },
  @{ id='roof'; args=@('--v0359-scenario=roof','--v0357-barrosan-barn-opt-in','--v0359-view=roof','--v0359-capture=roof.png','--v0359-purpose=elevated exterior roof slopes and ridge view') ; expected='LOADED_ONCE' },
  @{ id='rollback'; args=@('--v0359-scenario=rollback','--v0359-rollback') ; expected='ROLLED_BACK_CLEAN' },
  @{ id='missing-scene-fail-closed'; args=@('--v0359-scenario=missing-scene-fail-closed','--v0357-barrosan-barn-opt-in','--v0357-debug-review','--v0357-barrosan-barn-fallback=missing-scene','--v0359-view=rts','--v0359-capture=missing_scene.png','--v0359-purpose=F1 missing canonical scene fail closed') ; expected='FAIL_CLOSED_MISSING_SCENE' },
  @{ id='hash-mismatch-fail-closed'; args=@('--v0359-scenario=hash-mismatch-fail-closed','--v0357-barrosan-barn-opt-in','--v0357-debug-review','--v0357-barrosan-barn-fallback=hash-mismatch','--v0359-view=rts','--v0359-capture=hash_mismatch.png','--v0359-purpose=F2 source hash mismatch fail closed') ; expected='FAIL_CLOSED_HASH_MISMATCH' },
  @{ id='invalid-authority-fail-closed'; args=@('--v0359-scenario=invalid-authority-fail-closed','--v0357-barrosan-barn-opt-in','--v0357-debug-review','--v0357-barrosan-barn-fallback=invalid-authority','--v0359-view=rts','--v0359-capture=invalid_authority.png','--v0359-purpose=F3 invalid authority fail closed') ; expected='FAIL_CLOSED_INVALID_AUTHORITY' },
  @{ id='unknown-slot-rejected'; args=@('--v0359-scenario=unknown-slot-rejected','--v0357-barrosan-barn-opt-in','--v0357-debug-review','--v0357-barrosan-barn-slot=unregistered_slot','--v0359-view=rts','--v0359-capture=unknown_slot.png','--v0359-purpose=F4 unknown slot fail closed') ; expected='FAIL_CLOSED_UNKNOWN_SLOT_REJECTED' }
)
$results = @()
foreach ($scenario in $scenarios) {
  $scenarioRoot = Join-Path $CaptureRoot $scenario.id
  New-Item -ItemType Directory -Force -Path $scenarioRoot | Out-Null
  $env:V0359_ARTIFACT_ROOT = $scenarioRoot.Replace('\','/')
  $env:V0359_REPO_ROOT = $RepoRoot.Replace('\','/')
  $argList = @('--path', $Project, '--rendering-method', 'gl_compatibility', '--rendering-driver', 'opengl3', '--scene', $Scene) + $scenario.args
  Push-Location $Project
  & $Godot @argList
  $exitCode = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE }
  Pop-Location
  $runtimePath = Join-Path $scenarioRoot 'v0359-barrosan-barn-runtime.json'
  $runtime = if (Test-Path -LiteralPath $runtimePath) { Get-Content -LiteralPath $runtimePath -Raw | ConvertFrom-Json } else { $null }
  $status = if ($runtime) { [string]$runtime.statusDetail } else { 'MISSING' }
  if ($exitCode -ne 0 -or $status -ne $scenario.expected) { throw "v0.359 scenario $($scenario.id) failed: exit $exitCode, status $status" }
  $results += [ordered]@{ id=$scenario.id; expected=$scenario.expected; status=$status; exitCode=$exitCode; runtimeManifest=($runtimePath.Substring($RepoRoot.Length+1).Replace('\','/')) }
}
Remove-Item Env:V0359_ARTIFACT_ROOT -ErrorAction SilentlyContinue
Remove-Item Env:V0359_REPO_ROOT -ErrorAction SilentlyContinue

$env:V0359_ARTIFACT_ROOT = $PerformanceRoot.Replace('\','/')
$env:V0359_REPO_ROOT = $RepoRoot.Replace('\','/')
Push-Location $Project
& $Godot @('--path',$Project,'--rendering-method','gl_compatibility','--rendering-driver','opengl3','--scene',$Scene,'--v0359-scenario=performance','--v0359-performance')
$performanceExit = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE }
Pop-Location
Remove-Item Env:V0359_ARTIFACT_ROOT -ErrorAction SilentlyContinue
Remove-Item Env:V0359_REPO_ROOT -ErrorAction SilentlyContinue
if ($performanceExit -ne 0) { throw "v0.359 uncapped benchmark failed with exit $performanceExit" }

$panels = @()
$panelScenarios = @('authority','baseline','opt-in','wide','close-scale','rts-distance','terrain-contact','front','rear','roof','missing-scene-fail-closed','hash-mismatch-fail-closed','invalid-authority-fail-closed','unknown-slot-rejected')
foreach ($id in $panelScenarios) {
  $runtimePath = Join-Path $CaptureRoot "$id\v0359-barrosan-barn-runtime.json"
  $runtime = Get-Content -LiteralPath $runtimePath -Raw | ConvertFrom-Json
  foreach ($capture in @($runtime.captures)) {
    $rawPath = $capture.rawCapturePath.Replace('/','\')
    $relative = $rawPath.Substring($RepoRoot.Length+1).Replace('\','/')
    $panels += [ordered]@{ boardPanelId=$capture.panelId; scenario=$id; semanticPurpose=$capture.semanticPurpose; rawCapturePath=$relative; rawCaptureSha256=$capture.rawCaptureSha256; cameraPosition=$capture.cameraPosition; cameraTarget=$capture.cameraTarget; cameraRotation=$capture.cameraRotation; projectionType=$capture.projectionType; orthographicSize=$capture.orthographicSize; viewportWidth=$capture.viewportWidth; viewportHeight=$capture.viewportHeight; sceneStateSignature=$capture.sceneStateSignature; barnRootCount=$capture.barnRootCount; house02Count=$capture.house02Count; frameNumberAfterCameraTransition=$capture.frameNumberAfterCameraTransition; settleFrames=$capture.settleFrames; timestampSequence=$capture.timestampSequence }
  }
}
$rollbackRuntime = Get-Content -LiteralPath (Join-Path $CaptureRoot 'rollback\v0359-barrosan-barn-runtime.json') -Raw | ConvertFrom-Json
foreach ($capture in @($rollbackRuntime.captures) | Where-Object { $_.rawCapturePath }) {
  $rawPath = $capture.rawCapturePath.Replace('/','\')
  $relative = $rawPath.Substring($RepoRoot.Length+1).Replace('\','/')
  $panels += [ordered]@{ boardPanelId=$capture.panelId; scenario='rollback'; semanticPurpose=$capture.semanticPurpose; rawCapturePath=$relative; rawCaptureSha256=$capture.rawCaptureSha256; cameraPosition=$capture.cameraPosition; cameraTarget=$capture.cameraTarget; cameraRotation=$capture.cameraRotation; projectionType=$capture.projectionType; orthographicSize=$capture.orthographicSize; viewportWidth=$capture.viewportWidth; viewportHeight=$capture.viewportHeight; sceneStateSignature=$capture.sceneStateSignature; barnRootCount=$capture.barnRootCount; house02Count=$capture.house02Count; frameNumberAfterCameraTransition=$capture.frameNumberAfterCameraTransition; settleFrames=$capture.settleFrames; timestampSequence=$capture.timestampSequence }
}
$manifest = [ordered]@{ schemaVersion=1; checkpoint='v0.359'; captureDuplicationRootCause='v0.358 passed v0358-view arguments while the inherited parser read only v0357-view, so requested view changes were ignored before render; board composition then selected those duplicate raw files'; duplicationWasInRawCaptures=$true; duplicationWasInBoardComposition=$true; correctedCaptureSequencing='v0359 parses v0359-view, applies camera transform, waits 8 rendered frames, then reads the viewport'; panels=$panels; scenarios=$results; performanceManifest='artifacts/performance/v0359-barrosan-barn/v0359-performance.json' }
$manifest | ConvertTo-Json -Depth 30 | Set-Content (Join-Path $CaptureRoot 'capture-manifest.json') -Encoding UTF8
Write-Output 'PASS_V0359_BARROSAN_BARN_CAPTURE_INTEGRITY_PERFORMANCE_CAPTURE'
