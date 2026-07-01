param()
$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $RepoRoot

node tools/godot/saltoV0272BarrosanMilitiaClearGuardCommandLifecycleTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0272"
if ($LASTEXITCODE -ne 0) { throw "v0.272 Militia Clear Guard Command Lifecycle validation failed." }

Write-Output "PASS_V0272_BARROSAN_MILITIA_CLEAR_GUARD_COMMAND_LIFECYCLE_VALIDATION"
