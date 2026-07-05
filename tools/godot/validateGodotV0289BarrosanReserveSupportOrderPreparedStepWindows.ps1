param()
$ErrorActionPreference = "Stop"
Set-Location (Resolve-Path (Join-Path $PSScriptRoot "..\.."))
node tools/godot/saltoV0289BarrosanReserveSupportOrderPreparedStepTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0289" "--true-default-root=artifacts/desktop-spikes/godot-salto/true-default-runtime-baseline-lock-0289"
if ($LASTEXITCODE -ne 0) { throw "v0.289 reserve support order prepared step validation failed." }
Write-Output "PASS_v0289_BARROSAN_RESERVE_SUPPORT_ORDER_PREPARED_STEP_VALIDATION"
