param()
$ErrorActionPreference = "Stop"
Set-Location (Resolve-Path (Join-Path $PSScriptRoot "..\.."))
node tools/godot/saltoV0263BarrosanWatchpostIntelMemoryTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0263"
if ($LASTEXITCODE -ne 0) { throw "v0.263 Barrosan Watchpost intel memory validation failed." }
Write-Output "PASS_V0263_BARROSAN_WATCHPOST_INTEL_MEMORY_VALIDATION"
