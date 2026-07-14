param()
$ErrorActionPreference = 'Stop'
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..')
Set-Location $RepoRoot
$Godot = Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64.exe'
$Project = Join-Path $RepoRoot 'desktop-spikes\godot-salto'
$Base = Join-Path $RepoRoot 'artifacts\desktop-spikes\godot-salto\v0316'
if (Test-Path -LiteralPath $Base) { Remove-Item -LiteralPath $Base -Recurse -Force }
New-Item -ItemType Directory -Force -Path $Base | Out-Null

function Invoke-ClosureCapture([string]$Id, [string]$PresentationFlag) {
  $relative = "../../artifacts/desktop-spikes/godot-salto/v0316/$Id"
  & $Godot '--path' $Project '--' '--h3-visible-animation-directional-closure' '--salto-barrosan-playable-runtime-skin' '--salto-barrosan-h3-runtime-pilot' '--salto-selection-command-panel' $PresentationFlag "--artifact-root=$relative"
  $manifest = Join-Path $Base "$Id\capture-manifest.json"
  $until = (Get-Date).AddSeconds(900)
  while (!(Test-Path -LiteralPath $manifest) -and (Get-Date) -lt $until) { Start-Sleep -Milliseconds 250 }
  if (!(Test-Path -LiteralPath $manifest)) { throw "v0.316 missing capture manifest for $Id" }
  $parsed = Get-Content -LiteralPath $manifest -Raw | ConvertFrom-Json
  if ([int]$parsed.captureCount -lt 45) { throw "v0.316 $Id expected at least 45 rendered captures, got $($parsed.captureCount)" }
  if ([string]$parsed.status -notlike 'PASS_*') { throw "v0.316 $Id capture failed: $($parsed.status)" }
}

Invoke-ClosureCapture 'player' '--salto-barrosan-player-presentation'
Invoke-ClosureCapture 'debug-review' '--salto-barrosan-debug-review-overlay'
Write-Output 'PASS_V0316_H3_VISIBLE_ANIMATION_DIRECTIONAL_CLOSURE_CAPTURE_READY'
