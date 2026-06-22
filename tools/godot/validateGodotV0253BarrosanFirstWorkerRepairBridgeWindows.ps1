param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $RepoRoot
node tools/godot/saltoV0253BarrosanFirstWorkerRepairBridgeTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0253"
if ($LASTEXITCODE -ne 0) { throw "v0.253 Worker repair validation failed." }
Write-Output "PASS_V0253_BARROSAN_FIRST_WORKER_REPAIR_BRIDGE_VALIDATION"
