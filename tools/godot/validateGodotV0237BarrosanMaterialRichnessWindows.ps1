param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0237"
Set-Location $RepoRoot
node tools/godot/saltoV0237BarrosanMaterialRichnessTool.mjs validation "--artifact-root=$($ArtifactRoot.Replace('\','/'))"
if ($LASTEXITCODE -ne 0) { throw "v0.237 Barrosan material-richness validation failed." }
Write-Output "PASS_V0237_BARROSAN_MATERIAL_RICHNESS_VALIDATION_READY"
