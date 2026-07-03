param()
$ErrorActionPreference = "Stop"
Set-Location (Resolve-Path (Join-Path $PSScriptRoot "..\.."))
node tools/godot/saltoV0283BarrosanNonLethalAshenPressureResponseTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0283" "--true-default-root=artifacts/desktop-spikes/godot-salto/true-default-runtime-baseline-lock-0283"
if ($LASTEXITCODE -ne 0) { throw "FAIL_V0283_BARROSAN_NON_LETHAL_ASHEN_PRESSURE_RESPONSE_VALIDATION" }
Write-Output "PASS_V0283_BARROSAN_NON_LETHAL_ASHEN_PRESSURE_RESPONSE_VALIDATION"
