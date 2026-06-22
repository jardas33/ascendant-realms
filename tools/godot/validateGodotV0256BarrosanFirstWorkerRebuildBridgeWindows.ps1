param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $RepoRoot
node tools/godot/saltoV0256BarrosanFirstWorkerRebuildBridgeTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0256"
if ($LASTEXITCODE -ne 0) { throw "v0.256 first Worker rebuild validation failed." }
Write-Output "PASS_V0256_BARROSAN_FIRST_WORKER_REBUILD_BRIDGE_VALIDATION"
