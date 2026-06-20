param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0234"
Set-Location $RepoRoot
if (-not (Test-Path (Join-Path $ArtifactRoot "runtime\v0234-composed-blender-battlefield-runtime.json"))) {
  & (Join-Path $PSScriptRoot "captureGodotSaltoComposedBlenderBattlefieldWindows.ps1")
}
node tools/godot/saltoComposedBlenderBattlefieldTool.mjs validation "--artifact-root=$($ArtifactRoot.Replace('\','/'))"
if ($LASTEXITCODE -ne 0) { throw "v0.234 composed battlefield validation failed." }
node scripts/cleanupSaltoExperimentalArtifacts.mjs "--output-root=$((Join-Path $ArtifactRoot 'cleanup-dry-run').Replace('\','/'))"
if ($LASTEXITCODE -ne 0) { throw "v0.234 cleanup dry run failed." }
Write-Output "PASS_V0234_COMPOSED_BLENDER_BATTLEFIELD_VALIDATION_READY"
