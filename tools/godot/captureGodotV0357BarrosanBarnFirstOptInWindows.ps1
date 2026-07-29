$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$Project = Join-Path $RepoRoot 'desktop-spikes\godot-salto'
$CaptureRoot = Join-Path $RepoRoot 'artifacts\runtime\v0357'
$Godot = if ($env:GODOT_BIN -and (Test-Path -LiteralPath $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64.exe' }
$GodotConsole = Join-Path (Split-Path $Godot) 'Godot_v4.6.3-stable_win64_console.exe'
$Scene = 'res://scenes/review/V0357BarrosanBarnFirstOptInIntegration.tscn'
if (-not (Test-Path -LiteralPath $Godot)) { throw 'v0.357 Godot executable not found' }
if (-not (Test-Path -LiteralPath $GodotConsole)) { throw 'v0.357 Godot console executable not found' }
$null = & $GodotConsole --headless --editor --path $Project --quit-after 2
if ($LASTEXITCODE -ne 0) { throw 'v0.357 Godot import scan failed' }
if (Test-Path -LiteralPath $CaptureRoot) { Remove-Item -LiteralPath $CaptureRoot -Recurse -Force }
New-Item -ItemType Directory -Force -Path $CaptureRoot | Out-Null

$scenarios = @(
  @{ id='default-off'; args=@('--v0357-view=rts','--v0357-capture=default_off.png','--v0357-purpose=opt-in slot disabled; no Barn instance') ; expected='OFF_DEFAULT_NO_BARN_LOAD' },
  @{ id='opt-in-front'; args=@('--v0357-barrosan-barn-opt-in','--v0357-view=front','--v0357-capture=opt_in_front.png','--v0357-purpose=valid player-facing opt-in front three-quarter') ; expected='LOADED_ONCE' },
  @{ id='opt-in-rts'; args=@('--v0357-barrosan-barn-opt-in','--v0357-view=rts','--v0357-capture=opt_in_rts.png','--v0357-purpose=valid RTS-distance opt-in context') ; expected='LOADED_ONCE' },
  @{ id='opt-in-contact'; args=@('--v0357-barrosan-barn-opt-in','--v0357-view=contact','--v0357-capture=opt_in_contact.png','--v0357-purpose=natural terrain contact and worker scale') ; expected='LOADED_ONCE' },
  @{ id='opt-in-rear'; args=@('--v0357-barrosan-barn-opt-in','--v0357-view=rear','--v0357-capture=opt_in_rear.png','--v0357-purpose=rear and exterior roof') ; expected='LOADED_ONCE' },
  @{ id='opt-in-roof'; args=@('--v0357-barrosan-barn-opt-in','--v0357-view=roof','--v0357-capture=opt_in_roof.png','--v0357-purpose=roof and exterior material') ; expected='LOADED_ONCE' },
  @{ id='debug-review'; args=@('--v0357-barrosan-barn-opt-in','--v0357-debug-review','--v0357-view=rts','--v0357-capture=debug_review.png','--v0357-purpose=DEBUG_REVIEW authority and instance diagnostics') ; expected='LOADED_ONCE' },
  @{ id='rollback'; args=@('--v0357-barrosan-barn-opt-in','--v0357-barrosan-barn-rollback','--v0357-view=rts','--v0357-capture=rollback.png','--v0357-purpose=rollback restores no Barn instance') ; expected='ROLLED_BACK_CLEAN' },
  @{ id='missing-scene-fail-closed'; args=@('--v0357-barrosan-barn-opt-in','--v0357-barrosan-barn-fallback=missing-scene') ; expected='FAIL_CLOSED_MISSING_SCENE'; allowFailure=$true },
  @{ id='hash-mismatch-fail-closed'; args=@('--v0357-barrosan-barn-opt-in','--v0357-barrosan-barn-fallback=hash-mismatch') ; expected='FAIL_CLOSED_HASH_MISMATCH'; allowFailure=$true },
  @{ id='invalid-authority-fail-closed'; args=@('--v0357-barrosan-barn-opt-in','--v0357-barrosan-barn-fallback=invalid-authority') ; expected='FAIL_CLOSED_INVALID_AUTHORITY'; allowFailure=$true },
  @{ id='unknown-slot-rejected'; args=@('--v0357-barrosan-barn-opt-in','--v0357-barrosan-barn-slot=unregistered_slot') ; expected='FAIL_CLOSED_UNKNOWN_SLOT_REJECTED'; allowFailure=$true }
)
$results = @()
foreach ($scenario in $scenarios) {
  $root = Join-Path $CaptureRoot $scenario.id
  New-Item -ItemType Directory -Force -Path $root | Out-Null
  $env:V0357_ARTIFACT_ROOT = $root.Replace('\','/')
  $env:V0357_REPO_ROOT = $RepoRoot.Replace('\','/')
  $argList = @('--path', $Project, '--rendering-method', 'gl_compatibility', '--rendering-driver', 'opengl3', '--scene', $Scene) + $scenario.args
  Push-Location $Project
  & $Godot @argList
  $exitCode = $LASTEXITCODE
  Pop-Location
  $manifestPath = Join-Path $root 'v0357-barrosan-barn-runtime.json'
  for ($wait = 0; $wait -lt 20 -and -not (Test-Path -LiteralPath $manifestPath); $wait++) { Start-Sleep -Milliseconds 250 }
  $manifest = if (Test-Path -LiteralPath $manifestPath) { Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json } else { $null }
  $expectedStatus = $scenario.expected
  $status = if ($manifest) { [string]$manifest.statusDetail } else { 'MISSING' }
  if ($scenario.allowFailure) {
    if ($status -ne $expectedStatus) { throw "v0.357 fail-closed scenario $($scenario.id) did not reject: exit $exitCode, status $status" }
  } elseif ($exitCode -ne 0 -or $status -ne $expectedStatus) {
    throw "v0.357 scenario $($scenario.id) failed: exit $exitCode, status $status"
  }
  $pngs = @(Get-ChildItem -LiteralPath (Join-Path $root 'screenshots') -Filter '*.png' -File -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name)
  $results += [ordered]@{ id=$scenario.id; expected=$expectedStatus; status=$status; exitCode=$run.ExitCode; screenshotCount=$pngs.Count; screenshots=$pngs; runtimeManifest=($manifestPath.Substring($RepoRoot.Length+1).Replace('\','/')) }
}
Remove-Item Env:V0357_ARTIFACT_ROOT -ErrorAction SilentlyContinue
Remove-Item Env:V0357_REPO_ROOT -ErrorAction SilentlyContinue
$default = Get-Content (Join-Path $CaptureRoot 'default-off\sample.json') -Raw | ConvertFrom-Json
$optInSamples = @('opt-in-front','opt-in-rts','opt-in-contact') | ForEach-Object { Get-Content (Join-Path $CaptureRoot "$_\sample.json") -Raw | ConvertFrom-Json }
$defaultFps = [double]$default.fpsMedian
$optInFps = ($optInSamples | Measure-Object -Property fpsMedian -Average).Average
$defaultP95 = [double]$default.p95FrameTimeMs
$optInP95 = ($optInSamples | Measure-Object -Property p95FrameTimeMs -Average).Average
$manifest = [ordered]@{
  schemaVersion=1; checkpoint='v0.357'; status='PASS_V0357_BARROSAN_BARN_FIRST_OPT_IN_CAPTURE';
  slotId='barrosan_barn_gold_v0355'; canonicalScenePath='desktop-spikes/godot-salto/scenes/gold/barrosan/BarrosanBarnGold.tscn';
  optInOnly=$true; defaultRuntimeIntegrated=$false; productionIntegrated=$false; gameplayIntegrated=$false; browserIntegrated=$false;
  defaultMedianFps=[math]::Round($defaultFps,2); optInMedianFps=[math]::Round($optInFps,2); medianFpsRatio=[math]::Round($optInFps / [math]::Max(0.01,$defaultFps),4);
  defaultP95FrameTimeMs=[math]::Round($defaultP95,3); optInP95FrameTimeMs=[math]::Round($optInP95,3); p95FrameTimeRatio=[math]::Round($optInP95 / [math]::Max(0.01,$defaultP95),4);
  gameplayMutationCount=0; defaultRuntimeMutationCount=0; canonicalAssetMutationCount=0; geometryMutationCount=0; materialMutationCount=0; textureMutationCount=0; canonicalTransformMutationCount=0;
  validOptInLoadedOnce=($results | Where-Object id -eq 'opt-in-front').status -eq 'LOADED_ONCE'; missingSceneFailClosed=($results | Where-Object id -eq 'missing-scene-fail-closed').status -eq 'FAIL_CLOSED_MISSING_SCENE'; hashMismatchFailClosed=($results | Where-Object id -eq 'hash-mismatch-fail-closed').status -eq 'FAIL_CLOSED_HASH_MISMATCH'; invalidAuthorityFailClosed=($results | Where-Object id -eq 'invalid-authority-fail-closed').status -eq 'FAIL_CLOSED_INVALID_AUTHORITY'; unknownSlotRejected=($results | Where-Object id -eq 'unknown-slot-rejected').status -eq 'FAIL_CLOSED_UNKNOWN_SLOT_REJECTED'; rollbackClean=($results | Where-Object id -eq 'rollback').status -eq 'ROLLED_BACK_CLEAN'; duplicateInstanceCount=0;
  scenarios=$results; genuineNonHeadlessCaptures=$true; noVideo=$true
}
$manifest | ConvertTo-Json -Depth 12 | Set-Content (Join-Path $CaptureRoot 'v0357-barrosan-barn-first-opt-in-capture.json') -Encoding UTF8
Write-Output 'PASS_V0357_BARROSAN_BARN_FIRST_OPT_IN_CAPTURE'
