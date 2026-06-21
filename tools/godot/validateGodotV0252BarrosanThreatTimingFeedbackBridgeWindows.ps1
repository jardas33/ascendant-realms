param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $RepoRoot
node tools/godot/saltoV0252BarrosanThreatTimingFeedbackBridgeTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0252"
if ($LASTEXITCODE -ne 0) { throw "v0.252 validation failed." }
Write-Output "PASS_V0252_BARROSAN_THREAT_TIMING_FEEDBACK_BRIDGE_VALIDATION"
