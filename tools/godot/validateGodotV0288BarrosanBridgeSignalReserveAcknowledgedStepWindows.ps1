param()
$ErrorActionPreference = "Stop"
Set-Location (Resolve-Path (Join-Path $PSScriptRoot "..\.."))
node tools/godot/saltoV0288BarrosanBridgeSignalReserveAcknowledgedStepTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0288" "--true-default-root=artifacts/desktop-spikes/godot-salto/true-default-runtime-baseline-lock-0288"
if ($LASTEXITCODE -ne 0) { throw "v0.288 bridge signal reserve acknowledged step validation failed." }
Write-Output "PASS_v0288_BARROSAN_BRIDGE_SIGNAL_RESERVE_ACKNOWLEDGED_STEP_VALIDATION"
