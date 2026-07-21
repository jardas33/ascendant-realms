$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$Project = Join-Path $RepoRoot 'desktop-spikes\godot-salto'
$CaptureRoot = Join-Path $RepoRoot 'artifacts\runtime\v0362'
$Godot = if ($env:GODOT_BIN -and (Test-Path -LiteralPath $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64_console.exe' }
$Scene = 'res://scenes/review/V0362BarrosanBarnContextualPlacementSeparation.tscn'
if (-not (Test-Path -LiteralPath $Godot)) { throw 'v0.362 Godot executable not found' }
$null = & $Godot --headless --editor --path $Project --quit-after 2
if ($LASTEXITCODE -ne 0) { throw 'v0.362 Godot import scan failed' }
if (Test-Path -LiteralPath $CaptureRoot) { Remove-Item -LiteralPath $CaptureRoot -Recurse -Force }
New-Item -ItemType Directory -Force -Path $CaptureRoot | Out-Null

function Invoke-V0362Scenario([string]$id,[string[]]$scenarioArgs,[string]$expectedStatus) {
  $root = Join-Path $CaptureRoot $id
  New-Item -ItemType Directory -Force -Path $root | Out-Null
  $env:V0359_ARTIFACT_ROOT = $root.Replace('\','/')
  $env:V0359_REPO_ROOT = $RepoRoot.Replace('\','/')
  $args = @('--path',$Project,'--rendering-method','gl_compatibility','--rendering-driver','opengl3','--scene',$Scene) + $scenarioArgs
  Push-Location $Project
  & $Godot @args
  $exitCode = $LASTEXITCODE
  Pop-Location
  $runtime = Join-Path $root 'v0362-barrosan-barn-placement-runtime.json'
  for($wait=0;$wait -lt 30 -and -not(Test-Path -LiteralPath $runtime);$wait++){Start-Sleep -Milliseconds 250}
  if(-not(Test-Path -LiteralPath $runtime)){throw "v0.362 scenario $id did not write placement manifest"}
  $report = Get-Content -LiteralPath $runtime -Raw | ConvertFrom-Json
  $baseRuntime = Join-Path $root 'v0359-barrosan-barn-runtime.json'
  $base = if(Test-Path -LiteralPath $baseRuntime){Get-Content -LiteralPath $baseRuntime -Raw | ConvertFrom-Json}else{$null}
  $status = if($base){[string]$base.statusDetail}else{'MISSING'}
  if($expectedStatus -ne '' -and $status -ne $expectedStatus){throw "v0.362 scenario $id expected $expectedStatus but got $status (exit $exitCode)"}
  return [ordered]@{id=$id;expected=$expectedStatus;status=$status;exitCode=$exitCode;placementManifest=$runtime.Substring($RepoRoot.Length+1).Replace('\','/');screenshots=@(Get-ChildItem (Join-Path $root 'screenshots') -Filter '*.png' -File -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name);report=$report}
}

$results = @()
$results += Invoke-V0362Scenario 'before-rejected' @('--v0359-scenario=before-rejected','--v0357-barrosan-barn-opt-in','--v0362-before-rejected','--v0359-view=wide','--v0359-capture=before.png','--v0359-purpose=old rejected intersecting contextual placement; identical camera reference') 'LOADED_ONCE'
$results += Invoke-V0362Scenario 'default' @('--v0359-scenario=default','--v0359-view=wide','--v0359-capture=default.png','--v0359-purpose=default opt-in slot disabled; zero Barn instances') 'BASELINE_HOUSE02_NO_BARN'
$results += Invoke-V0362Scenario 'opt-in-wide' @('--v0359-scenario=opt-in-wide','--v0357-barrosan-barn-opt-in','--v0359-view=wide','--v0359-capture=wide.png','--v0359-purpose=repaired wide three-quarter PLAYER composition') 'LOADED_ONCE'
$results += Invoke-V0362Scenario 'opt-in-gap' @('--v0359-scenario=opt-in-gap','--v0357-barrosan-barn-opt-in','--v0362-gap-worker','--v0359-view=gap','--v0359-capture=gap.png','--v0359-purpose=complete evidence worker in open clearance gap') 'LOADED_ONCE'
$results += Invoke-V0362Scenario 'opt-in-rear-roof' @('--v0359-scenario=opt-in-rear-roof','--v0357-barrosan-barn-opt-in','--v0359-view=rear','--v0359-capture=rear.png','--v0359-purpose=opposite rear and roof/eave separation') 'LOADED_ONCE'
$results += Invoke-V0362Scenario 'opt-in-roof' @('--v0359-scenario=opt-in-roof','--v0357-barrosan-barn-opt-in','--v0359-view=roof','--v0359-capture=roof.png','--v0359-purpose=elevated roof and eave separation') 'LOADED_ONCE'
$results += Invoke-V0362Scenario 'opt-in-measurement' @('--v0359-scenario=opt-in-measurement','--v0357-barrosan-barn-opt-in','--v0357-debug-review','--v0359-view=measurement','--v0359-capture=measurement.png','--v0359-purpose=DEBUG_REVIEW world-space bounds and clearance overlay') 'LOADED_ONCE'
$results += Invoke-V0362Scenario 'rollback' @('--v0359-scenario=rollback','--v0357-barrosan-barn-opt-in','--v0359-rollback','--v0359-view=wide','--v0359-capture=rollback.png','--v0359-purpose=R0/R1/R2 exact rollback evidence') 'ROLLED_BACK_CLEAN'
$results += Invoke-V0362Scenario 'missing-scene-fail-closed' @('--v0359-scenario=missing-scene-fail-closed','--v0357-barrosan-barn-opt-in','--v0357-barrosan-barn-fallback=missing-scene') 'FAIL_CLOSED_MISSING_SCENE'
$results += Invoke-V0362Scenario 'hash-mismatch-fail-closed' @('--v0359-scenario=hash-mismatch-fail-closed','--v0357-barrosan-barn-opt-in','--v0357-barrosan-barn-fallback=hash-mismatch') 'FAIL_CLOSED_HASH_MISMATCH'
$results += Invoke-V0362Scenario 'invalid-authority-fail-closed' @('--v0359-scenario=invalid-authority-fail-closed','--v0357-barrosan-barn-opt-in','--v0357-barrosan-barn-fallback=invalid-authority') 'FAIL_CLOSED_INVALID_AUTHORITY'
$results += Invoke-V0362Scenario 'unknown-slot-rejected' @('--v0359-scenario=unknown-slot-rejected','--v0357-barrosan-barn-opt-in','--v0357-barrosan-barn-slot=unknown_slot_v0362') 'FAIL_CLOSED_UNKNOWN_SLOT_REJECTED'
Remove-Item Env:V0359_ARTIFACT_ROOT -ErrorAction SilentlyContinue
Remove-Item Env:V0359_REPO_ROOT -ErrorAction SilentlyContinue
$final = @($results | Where-Object {$_.id -eq 'opt-in-wide'})[0]
$summary = [ordered]@{schemaVersion=1;checkpoint='v0.362';status='PASS_V0362_BARROSAN_BARN_CONTEXTUAL_PLACEMENT_SEPARATION_CAPTURE';scenePath='res://scenes/review/V0362BarrosanBarnContextualPlacementSeparation.tscn';genuineNonHeadlessCaptures=$true;beforeRejectedPlacementCaptured=$true;results=$results;finalMeasurement=$final.report.measurement;rollbackR0R2PixelMatch=(@($results|Where-Object id -eq 'rollback')[0].report.rollbackR0R2PixelMatch);failClosedCount=4;noVideo=$true}
$rollbackBase = Get-Content (Join-Path $CaptureRoot 'rollback\v0359-barrosan-barn-runtime.json') -Raw | ConvertFrom-Json
$summary.rollbackR0R2PixelMatch = [bool]$rollbackBase.captures[-1].rollbackR0R2PixelMatch
$summary | ConvertTo-Json -Depth 30 | Set-Content (Join-Path $CaptureRoot 'v0362-capture-manifest.json') -Encoding utf8
Write-Output 'PASS_V0362_BARROSAN_BARN_CONTEXTUAL_PLACEMENT_SEPARATION_CAPTURE'
