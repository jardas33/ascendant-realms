param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $RepoRoot
node tools/godot/saltoV0251BarrosanFirstDefenseConsequenceBridgeTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0251"
if ($LASTEXITCODE -ne 0) { throw "v0.251 validation failed." }
Write-Output "PASS_V0251_BARROSAN_FIRST_DEFENSE_CONSEQUENCE_BRIDGE_VALIDATION"
