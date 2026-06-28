param()
$ErrorActionPreference = "Stop"
Set-Location (Resolve-Path (Join-Path $PSScriptRoot "..\.."))
node tools/godot/saltoV0262BarrosanWatchpostAwarenessTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0262"
if ($LASTEXITCODE -ne 0) { throw "v0.262 Barrosan Watchpost awareness validation failed." }
Write-Output "PASS_V0262_BARROSAN_WATCHPOST_AWARENESS_VALIDATION"
