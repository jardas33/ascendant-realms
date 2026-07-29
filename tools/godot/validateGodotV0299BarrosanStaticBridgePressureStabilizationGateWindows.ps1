param()
$ErrorActionPreference='Stop'
$RepoRoot=Resolve-Path (Join-Path $PSScriptRoot '..\..')
Set-Location $RepoRoot
node tools/godot/saltoV0299BarrosanStaticBridgePressureStabilizationGateTool.mjs
if($LASTEXITCODE -ne 0){throw 'v0.299 validation failed'}
Write-Output 'PASS_v0299_BARROSAN_STATIC_BRIDGE_PRESSURE_STABILIZATION_GATE_VALIDATION'
