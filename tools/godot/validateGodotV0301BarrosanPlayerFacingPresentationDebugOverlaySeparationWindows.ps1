param()
$ErrorActionPreference='Stop'
$RepoRoot=Resolve-Path (Join-Path $PSScriptRoot '..\..')
Set-Location $RepoRoot
node tools/godot/saltoV0301BarrosanPlayerFacingPresentationDebugOverlaySeparationTool.mjs
if($LASTEXITCODE-ne 0){throw 'v0.301 validation failed'}
Write-Output 'PASS_v0301_BARROSAN_PLAYER_FACING_PRESENTATION_DEBUG_OVERLAY_SEPARATION_VALIDATION'
