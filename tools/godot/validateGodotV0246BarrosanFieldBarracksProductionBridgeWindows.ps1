param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $RepoRoot
node tools/godot/saltoV0246BarrosanFieldBarracksProductionBridgeTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0246"
if ($LASTEXITCODE -ne 0) { throw "v0.246 validation failed." }
Write-Output "PASS_V0246_BARROSAN_FIELD_BARRACKS_PRODUCTION_BRIDGE_VALIDATION"
