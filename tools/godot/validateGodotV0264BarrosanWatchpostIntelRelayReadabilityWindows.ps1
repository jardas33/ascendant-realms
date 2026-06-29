param()
$ErrorActionPreference = "Stop"
Set-Location (Resolve-Path (Join-Path $PSScriptRoot "..\.."))
node tools/godot/saltoV0264BarrosanWatchpostIntelRelayReadabilityTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0264"
if ($LASTEXITCODE -ne 0) { throw "v0.264 Barrosan Watchpost Intel Relay Readability validation failed." }
Write-Output "PASS_V0264_BARROSAN_WATCHPOST_INTEL_RELAY_READABILITY_VALIDATION"
