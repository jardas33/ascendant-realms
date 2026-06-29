param()
$ErrorActionPreference = "Stop"
Set-Location (Resolve-Path (Join-Path $PSScriptRoot "..\.."))
node tools/godot/saltoV0266BarrosanWatchpostDefenderReadinessBridgeTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/V0266"
if ($LASTEXITCODE -ne 0) { throw "v0.266 Barrosan Watchpost Defender Readiness Bridge validation failed." }
Write-Output "PASS_V0266_BARROSAN_WATCHPOST_DEFENDER_READINESS_BRIDGE_VALIDATION"

