param()
$ErrorActionPreference = "Stop"
Set-Location (Resolve-Path (Join-Path $PSScriptRoot "..\.."))
node tools/godot/saltoV0280BarrosanEngageCommitResolutionBridgeTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0280"
if ($LASTEXITCODE -ne 0) { throw "FAIL_V0280_BARROSAN_ENGAGE_COMMIT_RESOLUTION_BRIDGE_VALIDATION" }
Write-Output "PASS_V0280_BARROSAN_ENGAGE_COMMIT_RESOLUTION_BRIDGE_VALIDATION"
