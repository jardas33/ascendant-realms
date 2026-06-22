param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $RepoRoot
node tools/godot/saltoV0255BarrosanTrueDestroyedStateBridgeTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0255"
if ($LASTEXITCODE -ne 0) { throw "v0.255 true destroyed-state validation failed." }
Write-Output "PASS_V0255_BARROSAN_TRUE_DESTROYED_STATE_BRIDGE_VALIDATION"
