param()
$ErrorActionPreference = "Stop"
Set-Location (Resolve-Path (Join-Path $PSScriptRoot "..\.."))
node tools/godot/saltoV0286BarrosanFieldBarracksReserveReadyStepTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0286" "--true-default-root=artifacts/desktop-spikes/godot-salto/true-default-runtime-baseline-lock-0286"
if ($LASTEXITCODE -ne 0) { throw "v0.286 Field Barracks reserve ready step validation failed." }
Write-Output "PASS_V0286_BARROSAN_FIELD_BARRACKS_RESERVE_READY_STEP_VALIDATION"

