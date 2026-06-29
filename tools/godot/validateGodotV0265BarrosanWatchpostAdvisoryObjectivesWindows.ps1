param()
$ErrorActionPreference = "Stop"
Set-Location (Resolve-Path (Join-Path $PSScriptRoot "..\.."))
node tools/godot/saltoV0265BarrosanWatchpostAdvisoryObjectivesTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0265"
if ($LASTEXITCODE -ne 0) { throw "v0.265 Barrosan Watchpost Advisory Objectives validation failed." }
Write-Output "PASS_V0265_BARROSAN_WATCHPOST_ADVISORY_OBJECTIVES_VALIDATION"

