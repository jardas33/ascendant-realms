param()
$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $RepoRoot

node tools/godot/saltoV0274BarrosanMilitiaEngagementStanceReadabilityTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0274"
if ($LASTEXITCODE -ne 0) { throw "v0.274 Militia Engagement Stance Readability validation failed." }

Write-Output "PASS_V0274_BARROSAN_MILITIA_ENGAGEMENT_STANCE_READABILITY_VALIDATION"
