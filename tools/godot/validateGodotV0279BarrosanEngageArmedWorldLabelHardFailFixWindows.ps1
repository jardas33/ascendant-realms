param()
$ErrorActionPreference = "Stop"
Set-Location (Resolve-Path (Join-Path $PSScriptRoot "..\.."))
node tools/godot/saltoV0279BarrosanEngageArmedWorldLabelHardFailFixTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0279"
if ($LASTEXITCODE -ne 0) { throw "FAIL_V0279_BARROSAN_ENGAGE_ARMED_WORLD_LABEL_HARD_FAIL_FIX_VALIDATION" }
Write-Output "PASS_V0279_BARROSAN_ENGAGE_ARMED_WORLD_LABEL_HARD_FAIL_FIX_VALIDATION"
