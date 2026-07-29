param()
$ErrorActionPreference = 'Stop'
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..')
Set-Location $RepoRoot
$Godot = Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64.exe'
$Project = Join-Path $RepoRoot 'desktop-spikes\godot-salto'
$Base = Join-Path $RepoRoot 'artifacts\desktop-spikes\godot-salto\v0318'
if (Test-Path -LiteralPath $Base) { Remove-Item -LiteralPath $Base -Recurse -Force }
New-Item -ItemType Directory -Force -Path $Base | Out-Null

function Invoke-CellCapture([string]$Id, [string]$PresentationFlag) {
  $relative = "../../artifacts/desktop-spikes/godot-salto/v0318/$Id"
  & $Godot '--path' $Project '--' '--h3-single-sprite-atlas-rendering-repair' '--salto-barrosan-playable-runtime-skin' '--salto-barrosan-h3-runtime-pilot' '--salto-selection-command-panel' $PresentationFlag "--artifact-root=$relative"
  if ($LASTEXITCODE -ne 0) { throw "v0.318 Godot capture failed for $Id with exit code $LASTEXITCODE" }
  $manifest = Join-Path $Base "$Id\capture-manifest.json"
  $until = (Get-Date).AddSeconds(1200)
  while (!(Test-Path -LiteralPath $manifest) -and (Get-Date) -lt $until) { Start-Sleep -Milliseconds 250 }
  if (!(Test-Path -LiteralPath $manifest)) { throw "v0.318 missing capture manifest for $Id" }
  $parsed = Get-Content -LiteralPath $manifest -Raw | ConvertFrom-Json
  if ([int]$parsed.captureCount -lt 70) { throw "v0.318 $Id expected at least 70 rendered captures, got $($parsed.captureCount)" }
  if ([string]$parsed.status -notlike 'PASS_*') { throw "v0.318 $Id capture failed: $($parsed.status)" }
}

Invoke-CellCapture 'player' '--salto-barrosan-player-presentation'
Invoke-CellCapture 'debug-review' '--salto-barrosan-debug-review-overlay'
Write-Output 'PASS_V0318_H3_SINGLE_SPRITE_ATLAS_RENDERING_CAPTURE_READY'
