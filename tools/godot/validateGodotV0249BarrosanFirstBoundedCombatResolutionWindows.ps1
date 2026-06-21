param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $RepoRoot
node tools/godot/saltoV0249BarrosanFirstBoundedCombatResolutionTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0249"
if ($LASTEXITCODE -ne 0) { throw "v0.249 validation failed." }
Write-Output "PASS_V0249_BARROSAN_FIRST_BOUNDED_COMBAT_RESOLUTION_VALIDATION"
