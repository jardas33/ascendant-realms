param()
$ErrorActionPreference = "Stop"
Set-Location (Resolve-Path (Join-Path $PSScriptRoot "..\.."))
node tools/godot/saltoV0267BarrosanWatchpostDefenderPositioningBridgeTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0267"
if ($LASTEXITCODE -ne 0) { throw "v0.267 Barrosan Watchpost Defender Positioning Bridge validation failed." }
Write-Output "PASS_V0267_BARROSAN_WATCHPOST_DEFENDER_POSITIONING_BRIDGE_VALIDATION"
