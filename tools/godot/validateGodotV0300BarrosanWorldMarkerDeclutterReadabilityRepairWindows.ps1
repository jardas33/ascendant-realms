param()
$ErrorActionPreference='Stop'
$RepoRoot=Resolve-Path (Join-Path $PSScriptRoot '..\..')
Set-Location $RepoRoot
node tools/godot/saltoV0300BarrosanWorldMarkerDeclutterReadabilityRepairTool.mjs
if($LASTEXITCODE -ne 0){throw 'v0.300 validation failed'}
Write-Output 'PASS_v0300_BARROSAN_WORLD_MARKER_DECLUTTER_READABILITY_REPAIR_VALIDATION'
