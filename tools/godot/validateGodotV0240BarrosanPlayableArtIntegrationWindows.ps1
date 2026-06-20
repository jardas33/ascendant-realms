param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $RepoRoot
node tools/godot/saltoV0240BarrosanPlayableArtIntegrationTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0240"
if ($LASTEXITCODE -ne 0) { throw "v0.240 Barrosan playable-art integration validation failed." }
Write-Output "PASS_V0240_BARROSAN_PLAYABLE_ART_INTEGRATION_VALIDATION_READY"
