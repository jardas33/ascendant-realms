param()
$ErrorActionPreference = "Stop"
Set-Location (Resolve-Path (Join-Path $PSScriptRoot "..\.."))
node tools/godot/saltoV0290BarrosanReserveDeploymentApprovalGateStepTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0290" "--true-default-root=artifacts/desktop-spikes/godot-salto/true-default-runtime-baseline-lock-0290"
if ($LASTEXITCODE -ne 0) { throw "v0.290 reserve deployment approval gate step validation failed." }
Write-Output "PASS_v0290_BARROSAN_RESERVE_DEPLOYMENT_APPROVAL_GATE_STEP_VALIDATION"
