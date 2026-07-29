param()
$ErrorActionPreference = "Stop"
Set-Location (Resolve-Path (Join-Path $PSScriptRoot "..\.."))
node tools/godot/saltoV0287BarrosanReserveAssignedToBridgeStepTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0287" "--true-default-root=artifacts/desktop-spikes/godot-salto/true-default-runtime-baseline-lock-0287"
if ($LASTEXITCODE -ne 0) { throw "v0.287 Reserve Assigned To Bridge Step validation failed." }
Write-Output "PASS_V0287_BARROSAN_RESERVE_ASSIGNED_TO_BRIDGE_STEP_VALIDATION"
