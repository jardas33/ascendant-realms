param()
$ErrorActionPreference = 'Stop'
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..')
Set-Location $RepoRoot
$Godot = Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64.exe'
$Project = Join-Path $RepoRoot 'desktop-spikes\godot-salto'
$Base = Join-Path $RepoRoot 'artifacts\desktop-spikes\godot-salto\v0315'
if (Test-Path -LiteralPath $Base) { Remove-Item -LiteralPath $Base -Recurse -Force }
New-Item -ItemType Directory -Force -Path $Base | Out-Null

function Invoke-RecoveryCapture([string]$Id, [string]$PresentationFlag) {
  $relative = "../../artifacts/desktop-spikes/godot-salto/v0315/$Id"
  & $Godot '--path' $Project '--' '--h3-directional-animation-runtime-proof-recovery' '--salto-barrosan-playable-runtime-skin' '--salto-barrosan-h3-runtime-pilot' '--salto-selection-command-panel' $PresentationFlag "--artifact-root=$relative"
  $manifest = Join-Path $Base "$Id\capture-manifest.json"
  $until = (Get-Date).AddSeconds(600)
  while (!(Test-Path -LiteralPath $manifest) -and (Get-Date) -lt $until) { Start-Sleep -Milliseconds 250 }
  if (!(Test-Path -LiteralPath $manifest)) { throw "v0.315 missing capture manifest for $Id" }
  $parsed = Get-Content -LiteralPath $manifest -Raw | ConvertFrom-Json
  if ([int]$parsed.captureCount -lt 20) { throw "v0.315 $Id expected at least 20 real runtime captures, got $($parsed.captureCount)" }
  if ([string]$parsed.status -notlike 'PASS_*') { throw "v0.315 $Id capture failed: $($parsed.status)" }
}

Invoke-RecoveryCapture 'player' '--salto-barrosan-player-presentation'
Invoke-RecoveryCapture 'debug-review' '--salto-barrosan-debug-review-overlay'
Write-Output 'PASS_V0315_H3_ANIMATION_RUNTIME_PROOF_CAPTURE_READY'
