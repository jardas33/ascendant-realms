param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $RepoRoot
node tools/godot/saltoV0239BarrosanRosterSilhouetteBeautyTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0239"
if ($LASTEXITCODE -ne 0) { throw "v0.239 Barrosan silhouette-beauty validation failed." }
Write-Output "PASS_V0239_BARROSAN_ROSTER_SILHOUETTE_BEAUTY_VALIDATION_READY"
