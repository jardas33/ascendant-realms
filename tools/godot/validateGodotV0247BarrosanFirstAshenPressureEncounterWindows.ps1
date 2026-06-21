param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $RepoRoot
node tools/godot/saltoV0247BarrosanFirstAshenPressureEncounterTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0247"
if ($LASTEXITCODE -ne 0) { throw "v0.247 validation failed." }
Write-Output "PASS_V0247_BARROSAN_FIRST_ASHEN_PRESSURE_ENCOUNTER_VALIDATION"
