param()
$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $RepoRoot

node tools/godot/saltoV0273BarrosanMilitiaBraceBridgePostContactHoldTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0273"
if ($LASTEXITCODE -ne 0) { throw "v0.273 Militia Brace Bridge Post-Contact Hold validation failed." }

Write-Output "PASS_V0273_BARROSAN_MILITIA_BRACE_BRIDGE_POST_CONTACT_HOLD_VALIDATION"
