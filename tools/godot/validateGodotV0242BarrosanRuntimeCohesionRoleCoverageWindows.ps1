param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $RepoRoot
node tools/godot/saltoV0242BarrosanRuntimeCohesionRoleCoverageTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0242"
if ($LASTEXITCODE -ne 0) { throw "v0.242 validation failed." }
Write-Output "PASS_V0242_BARROSAN_RUNTIME_COHESION_ROLE_COVERAGE_VALIDATION"
