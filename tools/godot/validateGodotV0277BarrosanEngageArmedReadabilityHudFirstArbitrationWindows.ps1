param()
$ErrorActionPreference = "Stop"
Set-Location (Resolve-Path (Join-Path $PSScriptRoot "..\.."))
node tools/godot/saltoV0277BarrosanEngageArmedReadabilityHudFirstArbitrationTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0277"
if ($LASTEXITCODE -ne 0) { throw "FAIL_V0277_BARROSAN_ENGAGE_ARMED_READABILITY_HUD_FIRST_ARBITRATION_VALIDATION" }
Write-Output "PASS_V0277_BARROSAN_ENGAGE_ARMED_READABILITY_HUD_FIRST_ARBITRATION_VALIDATION"
