param()
$ErrorActionPreference = 'Stop'
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..')
Set-Location $RepoRoot
$Godot = Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64.exe'
$Project = Join-Path $RepoRoot 'desktop-spikes\godot-salto'
$Base = Join-Path $RepoRoot 'artifacts\desktop-spikes\godot-salto\v0313'
if (Test-Path -LiteralPath $Base) { Remove-Item -LiteralPath $Base -Recurse -Force }
New-Item -ItemType Directory -Force -Path $Base | Out-Null

function Invoke-ContractCapture([string]$Id, [string]$PresentationFlag) {
  $relative = "../../artifacts/desktop-spikes/godot-salto/v0313/$Id"
  & $Godot '--path' $Project '--' '--h3-supported-state-contract' '--salto-barrosan-playable-runtime-skin' '--salto-barrosan-h3-runtime-pilot' $PresentationFlag "--artifact-root=$relative"
  $manifest = Join-Path $Base "$Id\semantic-capture-manifest.json"
  $until = (Get-Date).AddSeconds(600)
  while (!(Test-Path -LiteralPath $manifest) -and (Get-Date) -lt $until) { Start-Sleep -Milliseconds 250 }
  if (!(Test-Path -LiteralPath $manifest)) { throw "v0.313 missing semantic manifest for $Id" }
  $parsed = Get-Content -LiteralPath $manifest -Raw | ConvertFrom-Json
  if ([int]$parsed.captureCount -lt 15) { throw "v0.313 $Id expected focused captures, got $($parsed.captureCount)" }
}

Invoke-ContractCapture 'player' '--salto-barrosan-player-presentation'
Invoke-ContractCapture 'debug-review' '--salto-barrosan-debug-review-overlay'
& 'C:\Users\barro\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' tools/godot/buildV0313H3SupportedStateContractPack.py
if ($LASTEXITCODE -ne 0) { throw 'v0.313 supported-state pack build failed' }
node tools/godot/saltoV0313H3SupportedStateContractTool.mjs validate
if ($LASTEXITCODE -ne 0) { throw 'v0.313 supported-state validator failed after capture' }
Write-Output 'PASS_V0313_H3_SUPPORTED_STATE_CONTRACT_CAPTURE_PACK_READY'
