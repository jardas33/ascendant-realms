param()
$ErrorActionPreference = "Stop"
Set-Location (Resolve-Path (Join-Path $PSScriptRoot "..\.."))
node tools/godot/saltoV0261BarrosanWatchpostFoundationTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0261"
if ($LASTEXITCODE -ne 0) { throw "v0.261 Barrosan Watchpost foundation validation failed." }
Write-Output "PASS_V0261_BARROSAN_WATCHPOST_FOUNDATION_VALIDATION"
