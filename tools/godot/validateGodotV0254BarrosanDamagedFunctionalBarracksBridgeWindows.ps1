param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $RepoRoot
node tools/godot/saltoV0254BarrosanDamagedFunctionalBarracksBridgeTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0254"
if ($LASTEXITCODE -ne 0) { throw "v0.254 damaged functional Barracks validation failed." }
Write-Output "PASS_V0254_BARROSAN_DAMAGED_FUNCTIONAL_BARRACKS_BRIDGE_VALIDATION"
