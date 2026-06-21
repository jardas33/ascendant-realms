param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $RepoRoot
node tools/godot/saltoV0245BarrosanAuthoritativeConstructionBridgeTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0245"
if ($LASTEXITCODE -ne 0) { throw "v0.245 validation failed." }
Write-Output "PASS_V0245_BARROSAN_AUTHORITATIVE_CONSTRUCTION_BRIDGE_VALIDATION"
