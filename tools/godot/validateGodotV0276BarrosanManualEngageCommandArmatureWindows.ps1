param()
$ErrorActionPreference = "Stop"
Set-Location (Resolve-Path (Join-Path $PSScriptRoot "..\.."))
node tools/godot/saltoV0276BarrosanManualEngageCommandArmatureTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0276"
if ($LASTEXITCODE -ne 0) { throw "FAIL_V0276_BARROSAN_MANUAL_ENGAGE_COMMAND_ARMATURE_VALIDATION" }
Write-Output "PASS_V0276_BARROSAN_MANUAL_ENGAGE_COMMAND_ARMATURE_VALIDATION"
