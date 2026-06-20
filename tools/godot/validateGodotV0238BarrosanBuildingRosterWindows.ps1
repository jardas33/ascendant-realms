param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0238"
Set-Location $RepoRoot
node tools/godot/saltoV0238BarrosanBuildingRosterTool.mjs validation "--artifact-root=$($ArtifactRoot.Replace('\','/'))"
if ($LASTEXITCODE -ne 0) { throw "v0.238 building-roster validation failed." }
Write-Output "PASS_V0238_BARROSAN_BUILDING_ROSTER_VALIDATION_READY"
