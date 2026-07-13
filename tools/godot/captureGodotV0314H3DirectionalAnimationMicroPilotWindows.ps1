param()
$ErrorActionPreference = 'Stop'
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..')
Set-Location $RepoRoot
$Godot = Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64.exe'
$Project = Join-Path $RepoRoot 'desktop-spikes\godot-salto'
$Base = Join-Path $RepoRoot 'artifacts\desktop-spikes\godot-salto\v0314'
if (Test-Path -LiteralPath $Base) { Remove-Item -LiteralPath $Base -Recurse -Force }
New-Item -ItemType Directory -Force -Path $Base | Out-Null

function Invoke-MicroPilotCapture([string]$Id, [string]$PresentationFlag) {
  $relative = "../../artifacts/desktop-spikes/godot-salto/v0314/$Id"
  & $Godot '--path' $Project '--' '--h3-directional-animation-micro-pilot' '--salto-barrosan-playable-runtime-skin' '--salto-barrosan-h3-runtime-pilot' '--salto-selection-command-panel' $PresentationFlag "--artifact-root=$relative"
  $manifest = Join-Path $Base "$Id\capture-manifest.json"
  $until = (Get-Date).AddSeconds(600)
  while (!(Test-Path -LiteralPath $manifest) -and (Get-Date) -lt $until) { Start-Sleep -Milliseconds 250 }
  if (!(Test-Path -LiteralPath $manifest)) { throw "v0.314 missing capture manifest for $Id" }
  $parsed = Get-Content -LiteralPath $manifest -Raw | ConvertFrom-Json
  if ([int]$parsed.captureCount -lt 16) { throw "v0.314 $Id expected at least 16 captures, got $($parsed.captureCount)" }
}

Invoke-MicroPilotCapture 'player' '--salto-barrosan-player-presentation'
Invoke-MicroPilotCapture 'debug-review' '--salto-barrosan-debug-review-overlay'
& 'C:\Users\barro\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' tools/godot/buildV0314H3DirectionalAnimationMicroPilotPack.py
if ($LASTEXITCODE -ne 0) { throw 'v0.314 review pack build failed' }
node tools/godot/saltoV0314H3DirectionalAnimationMicroPilotTool.mjs validate
if ($LASTEXITCODE -ne 0) { throw 'v0.314 dedicated validator failed after capture' }
Write-Output 'PASS_V0314_H3_DIRECTIONAL_ANIMATION_CAPTURE_PACK_READY'
