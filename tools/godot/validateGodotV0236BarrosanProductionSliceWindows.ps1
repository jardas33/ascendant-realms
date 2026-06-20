param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0236"
Set-Location $RepoRoot
node tools/godot/saltoV0236BarrosanProductionSliceTool.mjs validation "--artifact-root=$($ArtifactRoot.Replace('\','/'))"
if ($LASTEXITCODE -ne 0) { throw "v0.236 Barrosan production-slice validation failed." }
Write-Output "PASS_V0236_BARROSAN_PRODUCTION_SLICE_VALIDATION_READY"
