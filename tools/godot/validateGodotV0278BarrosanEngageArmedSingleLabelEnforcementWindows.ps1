param()
$ErrorActionPreference = "Stop"
Set-Location (Resolve-Path (Join-Path $PSScriptRoot "..\.."))
node tools/godot/saltoV0278BarrosanEngageArmedSingleLabelEnforcementTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0278"
if ($LASTEXITCODE -ne 0) { throw "FAIL_V0278_BARROSAN_ENGAGE_ARMED_SINGLE_LABEL_ENFORCEMENT_VALIDATION" }
Write-Output "PASS_V0278_BARROSAN_ENGAGE_ARMED_SINGLE_LABEL_ENFORCEMENT_VALIDATION"
