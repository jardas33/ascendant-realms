param()
$ErrorActionPreference = "Stop"
Set-Location (Resolve-Path (Join-Path $PSScriptRoot "..\.."))
node tools/godot/saltoV0285BarrosanHoldLineNonLethalContactStepTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0285" "--true-default-root=artifacts/desktop-spikes/godot-salto/true-default-runtime-baseline-lock-0285"
if ($LASTEXITCODE -ne 0) { throw "v0.285 Hold Line non-lethal contact step validation failed." }
Write-Output "PASS_V0285_BARROSAN_HOLD_LINE_NON_LETHAL_CONTACT_STEP_VALIDATION"
