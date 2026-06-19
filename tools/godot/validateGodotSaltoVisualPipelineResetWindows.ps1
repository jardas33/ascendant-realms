param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0232"
$Manifest = Join-Path $ArtifactRoot "production-target-spike\v0232-production-target-spike-runtime.json"
Set-Location $RepoRoot
if (-not (Test-Path -LiteralPath $Manifest)) {
  & (Join-Path $PSScriptRoot "captureGodotSaltoVisualPipelineResetWindows.ps1")
}
node tools/godot/saltoVisualPipelineResetTool.mjs validation "--artifact-root=$($ArtifactRoot.Replace('\','/'))"
if ($LASTEXITCODE -ne 0) { throw "v0.232 visual-pipeline validation failed." }
node scripts/cleanupSaltoExperimentalArtifacts.mjs "--output-root=$((Join-Path $ArtifactRoot 'cleanup-dry-run').Replace('\','/'))"
if ($LASTEXITCODE -ne 0) { throw "v0.232 cleanup dry run failed." }
Write-Output "PASS_V0232_VISUAL_PIPELINE_RESET_VALIDATION_READY"
