param()
$ErrorActionPreference = 'Stop'
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$ArtifactRoot = Join-Path $RepoRoot 'artifacts\desktop-spikes\godot-salto\v0295\static-deployment-route-preview-gate-runtime'
$DefaultRoot = Join-Path $RepoRoot 'artifacts\desktop-spikes\godot-salto\true-default-runtime-baseline-lock-0295'
Set-Location $RepoRoot
New-Item -ItemType Directory -Force -Path $ArtifactRoot, $DefaultRoot | Out-Null
$GodotPath = Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64.exe'
if (-not (Test-Path $GodotPath)) { throw "Missing Godot binary: $GodotPath" }
function Invoke-v0295Capture {
  param([string[]]$Arguments, [string]$Manifest, [string]$Label)
  & $GodotPath @Arguments
  $exitCode = $LASTEXITCODE
  $deadline = (Get-Date).AddSeconds(120)
  while (-not (Test-Path -LiteralPath $Manifest) -and (Get-Date) -lt $deadline) { Start-Sleep -Milliseconds 250 }
  if (-not (Test-Path -LiteralPath $Manifest)) { throw "v0.295 $Label capture did not write a manifest" }
  if ((Get-Content -Raw -LiteralPath $Manifest) -notmatch '"status"\s*:\s*"PASS_PLAYER_SLICE_CAPTURE"') { throw "v0.295 $Label capture manifest did not pass" }
  if ($exitCode -ne 0) { Write-Warning "Godot returned $exitCode after v0.295 $Label wrote a passing manifest." }
}
Invoke-v0295Capture -Arguments @('--path','.\desktop-spikes\godot-salto','--','--player-slice-capture','--artifact-root=../../artifacts/desktop-spikes/godot-salto/true-default-runtime-baseline-lock-0295') -Manifest (Join-Path $DefaultRoot 'screenshot-runtime-manifest.json') -Label 'default runtime'
Invoke-v0295Capture -Arguments @('--path','.\desktop-spikes\godot-salto','--','--player-slice-capture','--salto-barrosan-playable-runtime-skin','--artifact-root=../../artifacts/desktop-spikes/godot-salto/v0295/static-deployment-route-preview-gate-runtime') -Manifest (Join-Path $ArtifactRoot 'screenshot-runtime-manifest.json') -Label 'opt-in runtime'
$Python = 'C:\Users\barro\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
& $Python tools/godot/buildV0295BarrosanStaticDeploymentRoutePreviewGatePack.py
if ($LASTEXITCODE -ne 0) { throw 'v0.295 review pack assembly failed' }
node tools/godot/saltoV0295BarrosanStaticDeploymentRoutePreviewGateTool.mjs
if ($LASTEXITCODE -ne 0) { throw 'v0.295 validator failed' }
Write-Output 'PASS_v0295_BARROSAN_STATIC_DEPLOYMENT_ROUTE_PREVIEW_GATE_PACK_READY'
