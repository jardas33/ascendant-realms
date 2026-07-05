param()
$ErrorActionPreference = "Stop"
Set-Location (Resolve-Path (Join-Path $PSScriptRoot "..\.."))
node tools/godot/saltoV0291BarrosanReserveLaunchOrderStagedStepTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0291" "--true-default-root=artifacts/desktop-spikes/godot-salto/true-default-runtime-baseline-lock-0291"
if ($LASTEXITCODE -ne 0) { throw "v0.291 reserve launch order staged step validation failed." }
Write-Output "PASS_v0291_BARROSAN_RESERVE_LAUNCH_ORDER_STAGED_STEP_VALIDATION"
