param()
$ErrorActionPreference = "Stop"
Set-Location (Resolve-Path (Join-Path $PSScriptRoot "..\.."))
node tools/godot/saltoV0260BarrosanReviewCaptureRecoveryTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0260"
if ($LASTEXITCODE -ne 0) { throw "v0.260 Barrosan review capture recovery validation failed." }
Write-Output "PASS_V0260_BARROSAN_REVIEW_CAPTURE_RECOVERY_VALIDATION"
