param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $RepoRoot
node tools/godot/saltoV0244BarrosanLimitedTechnicalPlaytestTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0244"
if ($LASTEXITCODE -ne 0) { throw "v0.244 validation failed." }
Write-Output "PASS_V0244_BARROSAN_LIMITED_TECHNICAL_PLAYTEST_VALIDATION"
