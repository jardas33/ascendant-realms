param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $RepoRoot
node tools/godot/saltoV0250BarrosanExplicitAttackOrderBridgeTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0250"
if ($LASTEXITCODE -ne 0) { throw "v0.250 validation failed." }
Write-Output "PASS_V0250_BARROSAN_EXPLICIT_ATTACK_ORDER_BRIDGE_VALIDATION"
