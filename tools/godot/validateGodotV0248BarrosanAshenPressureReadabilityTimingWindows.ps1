param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $RepoRoot
node tools/godot/saltoV0248BarrosanAshenPressureReadabilityTimingTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0248"
if ($LASTEXITCODE -ne 0) { throw "v0.248 validation failed." }
Write-Output "PASS_V0248_BARROSAN_ASHEN_PRESSURE_READABILITY_TIMING_VALIDATION"
