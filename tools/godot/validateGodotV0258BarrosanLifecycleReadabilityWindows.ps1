param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $RepoRoot
node tools/godot/saltoV0258BarrosanLifecycleReadabilityTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0258"
if ($LASTEXITCODE -ne 0) { throw "v0.258 lifecycle readability validation failed." }
Write-Output "PASS_V0258_BARROSAN_LIFECYCLE_READABILITY_VALIDATION"
