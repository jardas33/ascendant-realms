$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$Project = Join-Path $RepoRoot 'desktop-spikes\godot-salto'
$CaptureRoot = Join-Path $RepoRoot 'artifacts\runtime\v0363\board07'
$Godot = if ($env:GODOT_BIN -and (Test-Path -LiteralPath $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64_console.exe' }
$Scene = 'res://scenes/review/V0362BarrosanBarnContextualPlacementSeparation.tscn'
if (-not (Test-Path -LiteralPath $Godot)) { throw 'v0.363 Godot executable not found' }
$null = & $Godot --headless --editor --path $Project --quit-after 2
if ($LASTEXITCODE -ne 0) { throw 'v0.363 Godot import scan failed' }
if (Test-Path -LiteralPath $CaptureRoot) { Remove-Item -LiteralPath $CaptureRoot -Recurse -Force }
New-Item -ItemType Directory -Force -Path $CaptureRoot | Out-Null
$env:V0359_ARTIFACT_ROOT = $CaptureRoot.Replace('\','/')
$env:V0359_REPO_ROOT = $RepoRoot.Replace('\','/')
Push-Location $Project
& $Godot --path $Project --rendering-method gl_compatibility --rendering-driver opengl3 --scene $Scene --v0359-scenario=v0363-board07 --v0359-rollback
$exitCode = $LASTEXITCODE
Pop-Location
Remove-Item Env:V0359_ARTIFACT_ROOT -ErrorAction SilentlyContinue
Remove-Item Env:V0359_REPO_ROOT -ErrorAction SilentlyContinue
if ($exitCode -ne 0) { throw "v0.363 rollback capture exited with $exitCode" }
$runtimePath = Join-Path $CaptureRoot 'v0359-barrosan-barn-runtime.json'
if (-not (Test-Path -LiteralPath $runtimePath)) { throw 'v0.363 rollback runtime manifest missing' }
$runtime = Get-Content -LiteralPath $runtimePath -Raw | ConvertFrom-Json
$captures = @($runtime.captures | Where-Object { $_.rawCaptureSha256 })
if ($captures.Count -ne 3) { throw "v0.363 expected 3 raw captures but found $($captures.Count)" }
foreach ($capture in $captures) {
  if (-not (Test-Path -LiteralPath ([string]$capture.rawCapturePath))) { throw "v0.363 raw capture missing: $($capture.rawCapturePath)" }
}
$r0 = $captures[0]; $r1 = $captures[1]; $r2 = $captures[2]
$manifest = [ordered]@{
  schemaVersion = 1
  checkpoint = 'v0.363'
  sourceCheckpoint = 'v0.362'
  scenePath = $Scene
  captureMode = 'non-headless Godot runtime rollback sequence'
  genuineNonHeadlessCaptures = $true
  panelCount = 3
  r0 = $r0
  r1 = $r1
  r2 = $r2
  r0BarnRootCount = [int]$r0.barnRootCount
  r1BarnRootCount = [int]$r1.barnRootCount
  r2BarnRootCount = [int]$r2.barnRootCount
  r0RawCaptureHash = [string]$r0.rawCaptureSha256
  r1RawCaptureHash = [string]$r1.rawCaptureSha256
  r2RawCaptureHash = [string]$r2.rawCaptureSha256
  r0R2RawCaptureMatch = ([string]$r0.rawCaptureSha256 -eq [string]$r2.rawCaptureSha256)
  r0R1RawCaptureDistinct = ([string]$r0.rawCaptureSha256 -ne [string]$r1.rawCaptureSha256)
  r1R2RawCaptureDistinct = ([string]$r1.rawCaptureSha256 -ne [string]$r2.rawCaptureSha256)
  r0StateSignature = [string]$r0.sceneStateSignature
  r1StateSignature = [string]$r1.sceneStateSignature
  r2StateSignature = [string]$r2.sceneStateSignature
  r0R2StateSignatureMatch = ([string]$r0.sceneStateSignature -eq [string]$r2.sceneStateSignature)
  r0R1StateSignatureDistinct = ([string]$r0.sceneStateSignature -ne [string]$r1.sceneStateSignature)
  cameraMatch = ((ConvertTo-Json $r0.cameraPosition -Compress) -eq (ConvertTo-Json $r1.cameraPosition -Compress) -and (ConvertTo-Json $r1.cameraPosition -Compress) -eq (ConvertTo-Json $r2.cameraPosition -Compress) -and [double]$r0.orthographicSize -eq [double]$r1.orthographicSize -and [double]$r1.orthographicSize -eq [double]$r2.orthographicSize)
  benchmarkRerunCount = 0
  placementMutationCountThisCheckpoint = 0
  canonicalAssetMutationCountThisCheckpoint = 0
}
$manifest | ConvertTo-Json -Depth 30 | Set-Content -LiteralPath (Join-Path $CaptureRoot 'v0363-board07-capture-manifest.json') -Encoding utf8
Write-Output 'PASS_V0363_BARROSAN_BARN_R0_R1_R2_CAPTURE'
