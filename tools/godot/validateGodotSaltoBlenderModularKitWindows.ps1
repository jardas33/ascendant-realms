param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0233"
$Manifest = Join-Path $ArtifactRoot "runtime\v0233-blender-modular-kit-runtime.json"
Set-Location $RepoRoot
if (-not (Test-Path -LiteralPath $Manifest)) {
  & (Join-Path $PSScriptRoot "captureGodotSaltoBlenderModularKitWindows.ps1")
}
node tools/godot/saltoBlenderModularKitTool.mjs validation "--artifact-root=$($ArtifactRoot.Replace('\','/'))"
if ($LASTEXITCODE -ne 0) { throw "v0.233R real-GLB validation failed." }
node scripts/cleanupSaltoExperimentalArtifacts.mjs "--output-root=$((Join-Path $ArtifactRoot 'cleanup-dry-run').Replace('\','/'))"
if ($LASTEXITCODE -ne 0) { throw "v0.233 cleanup dry run failed." }
Write-Output "PASS_V0233R_REAL_GLTF_VALIDATION_READY"
