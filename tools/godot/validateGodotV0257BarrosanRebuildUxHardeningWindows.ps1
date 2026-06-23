param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $RepoRoot
node tools/godot/saltoV0257BarrosanRebuildUxHardeningTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0257"
if ($LASTEXITCODE -ne 0) { throw "v0.257 rebuild UX hardening validation failed." }
Write-Output "PASS_V0257_BARROSAN_REBUILD_UX_HARDENING_VALIDATION"
