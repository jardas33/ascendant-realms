param()
$ErrorActionPreference = "Stop"
Set-Location (Resolve-Path (Join-Path $PSScriptRoot "..\.."))
node tools/godot/saltoV0281BarrosanRealHudTruthOverlayRemovalTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0281"
if ($LASTEXITCODE -ne 0) { throw "FAIL_V0281_BARROSAN_REAL_HUD_TRUTH_OVERLAY_REMOVAL_VALIDATION" }
Write-Output "PASS_V0281_BARROSAN_REAL_HUD_TRUTH_OVERLAY_REMOVAL_VALIDATION"
