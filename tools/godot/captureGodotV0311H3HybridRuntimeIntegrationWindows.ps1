param()
$ErrorActionPreference = 'Stop'
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..')
Set-Location $RepoRoot
$Godot = Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64.exe'
$Project = Join-Path $RepoRoot 'desktop-spikes\godot-salto'
$Base = Join-Path $RepoRoot 'artifacts\desktop-spikes\godot-salto\v0311'
if (Test-Path -LiteralPath $Base) { Remove-Item -LiteralPath $Base -Recurse -Force }
New-Item -ItemType Directory -Force -Path $Base | Out-Null
function Invoke-H3Capture([string]$Id, [string]$ModeFlag) {
  $relative = "../../artifacts/desktop-spikes/godot-salto/v0311/$Id"
  & $Godot '--path' $Project '--' '--player-slice-capture' '--salto-barrosan-playable-runtime-skin' $ModeFlag '--salto-barrosan-h3-runtime-pilot' "--artifact-root=$relative"
  $manifest = Join-Path $Base "$Id\screenshot-runtime-manifest.json"
  $until = (Get-Date).AddSeconds(300)
  while (!(Test-Path -LiteralPath $manifest) -and (Get-Date) -lt $until) { Start-Sleep -Milliseconds 250 }
  if (!(Test-Path -LiteralPath $manifest)) { throw "v0.311 missing $Id capture manifest" }
  $parsed = Get-Content -LiteralPath $manifest -Raw | ConvertFrom-Json
  if ($parsed.status -ne 'PASS_PLAYER_SLICE_CAPTURE') { throw "v0.311 $Id capture failed: $($parsed.status)" }
  if ([int]$parsed.captureCount -ne 43) { throw "v0.311 $Id expected 43 captures, got $($parsed.captureCount)" }
}
Invoke-H3Capture 'h3-runtime-pilot' '--salto-barrosan-player-presentation'
Invoke-H3Capture 'h3-runtime-pilot-debug' '--salto-barrosan-debug-review-overlay'
$defaultRelative = '../../artifacts/desktop-spikes/godot-salto/v0311/default-runtime-baseline'
& $Godot '--path' $Project '--' '--player-slice-capture' "--artifact-root=$defaultRelative"
$defaultManifest = Join-Path $Base 'default-runtime-baseline\screenshot-runtime-manifest.json'
$until = (Get-Date).AddSeconds(300)
while (!(Test-Path -LiteralPath $defaultManifest) -and (Get-Date) -lt $until) { Start-Sleep -Milliseconds 250 }
if (!(Test-Path -LiteralPath $defaultManifest)) { throw 'v0.311 missing true-default baseline manifest' }
node tools/godot/saltoV0311H3HybridRuntimeIntegrationTool.mjs pack
if ($LASTEXITCODE -ne 0) { throw 'v0.311 review pack build failed' }
$Python = 'C:\Users\barro\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
if (!(Test-Path -LiteralPath $Python)) { $Python = (Get-Command python -ErrorAction Stop).Source }
& $Python tools/godot/buildV0311H3HybridRuntimeIntegrationPack.py
if ($LASTEXITCODE -ne 0) { throw 'v0.311 contact-sheet build failed' }
node tools/godot/saltoV0311H3HybridRuntimeIntegrationTool.mjs validate
if ($LASTEXITCODE -ne 0) { throw 'v0.311 validator failed after capture' }
Write-Output 'PASS_V0311_H3_HYBRID_RUNTIME_INTEGRATION_CAPTURE_PACK_READY'
