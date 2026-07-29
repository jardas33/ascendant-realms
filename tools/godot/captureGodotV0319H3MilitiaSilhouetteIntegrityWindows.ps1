param()
$ErrorActionPreference = 'Stop'
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..')
Set-Location $RepoRoot
$Godot = Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64.exe'
$Project = Join-Path $RepoRoot 'desktop-spikes\godot-salto'
$Base = Join-Path $RepoRoot 'artifacts\desktop-spikes\godot-salto\v0319'
if (Test-Path -LiteralPath $Base) { Remove-Item -LiteralPath $Base -Recurse -Force }
New-Item -ItemType Directory -Force -Path $Base | Out-Null

function Invoke-SilhouetteCapture([string]$Id, [string]$PresentationFlag) {
  $relative = "../../artifacts/desktop-spikes/godot-salto/v0319/$Id"
  $arguments = '--path "' + $Project + '" -- --h3-militia-silhouette-integrity --salto-barrosan-playable-runtime-skin --salto-barrosan-h3-runtime-pilot --salto-selection-command-panel ' + $PresentationFlag + ' --artifact-root=' + $relative
  $process = Start-Process -FilePath $Godot -ArgumentList $arguments -WorkingDirectory $Project -Wait -PassThru
  if ($process.ExitCode -ne 0) { throw "v0.319 Godot capture failed for $Id with exit code $($process.ExitCode)" }
  $manifest = Join-Path $Base "$Id\capture-manifest.json"
  $until = (Get-Date).AddSeconds(1200)
  while (!(Test-Path -LiteralPath $manifest) -and (Get-Date) -lt $until) { Start-Sleep -Milliseconds 250 }
  if (!(Test-Path -LiteralPath $manifest)) { throw "v0.319 missing capture manifest for $Id" }
  $parsed = Get-Content -LiteralPath $manifest -Raw | ConvertFrom-Json
  if ([int]$parsed.captureCount -lt 40) { throw "v0.319 $Id expected at least 40 rendered captures, got $($parsed.captureCount)" }
  if ([string]$parsed.status -notlike 'PASS_*') { throw "v0.319 $Id capture failed: $($parsed.status)" }
}

Invoke-SilhouetteCapture 'player' '--salto-barrosan-player-presentation'
Invoke-SilhouetteCapture 'debug-review' '--salto-barrosan-debug-review-overlay'
Write-Output 'PASS_V0319_H3_MILITIA_SILHOUETTE_CAPTURE_READY'
