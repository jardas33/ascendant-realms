param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0235"
Set-Location $RepoRoot
node tools/godot/saltoArchitectureCorrectionTool.mjs validation "--artifact-root=$($ArtifactRoot.Replace('\','/'))"
if ($LASTEXITCODE -ne 0) { throw "v0.235 architecture validation failed." }
Write-Output "PASS_V0235_ARCHITECTURE_VALIDATION_READY"
