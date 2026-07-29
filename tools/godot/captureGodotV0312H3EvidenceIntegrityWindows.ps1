param()
$ErrorActionPreference = 'Stop'
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..')
Set-Location $RepoRoot
$Godot = Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64.exe'
$Project = Join-Path $RepoRoot 'desktop-spikes\godot-salto'
$Base = Join-Path $RepoRoot 'artifacts\desktop-spikes\godot-salto\v0312'
if (Test-Path -LiteralPath $Base) { Remove-Item -LiteralPath $Base -Recurse -Force }
New-Item -ItemType Directory -Force -Path $Base | Out-Null

function Invoke-SemanticCapture([string]$Id, [string]$PresentationFlag) {
  $relative = "../../artifacts/desktop-spikes/godot-salto/v0312/$Id"
  & $Godot '--path' $Project '--' '--h3-semantic-evidence' '--salto-barrosan-playable-runtime-skin' '--salto-barrosan-h3-runtime-pilot' $PresentationFlag "--artifact-root=$relative"
  $manifest = Join-Path $Base "$Id\semantic-capture-manifest.json"
  $until = (Get-Date).AddSeconds(600)
  while (!(Test-Path -LiteralPath $manifest) -and (Get-Date) -lt $until) { Start-Sleep -Milliseconds 250 }
  if (!(Test-Path -LiteralPath $manifest)) { throw "v0.312 missing semantic manifest for $Id" }
  $parsed = Get-Content -LiteralPath $manifest -Raw | ConvertFrom-Json
  if ([int]$parsed.captureCount -lt 60) { throw "v0.312 $Id expected genuine sequence captures, got $($parsed.captureCount)" }
}

Invoke-SemanticCapture 'player' '--salto-barrosan-player-presentation'
Invoke-SemanticCapture 'debug-review' '--salto-barrosan-debug-review-overlay'
$Python = 'C:\Users\barro\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
if (!(Test-Path -LiteralPath $Python)) { $Python = (Get-Command python -ErrorAction Stop).Source }
& $Python tools/godot/buildV0312H3EvidencePack.py
if ($LASTEXITCODE -ne 0) { throw 'v0.312 evidence pack build failed' }
node tools/godot/saltoV0312H3RuntimeEvidenceIntegrityTool.mjs validate
if ($LASTEXITCODE -ne 0) { throw 'v0.312 semantic validator failed after capture' }
Write-Output 'PASS_V0312_H3_RUNTIME_EVIDENCE_INTEGRITY_CAPTURE_PACK_READY'
