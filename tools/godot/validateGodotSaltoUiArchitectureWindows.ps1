param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0207"
$ArtifactRootArg = $ArtifactRoot.Replace("\", "/")

Set-Location $RepoRoot

if (-not (Test-Path -LiteralPath (Join-Path $ArtifactRoot "capture\ui-architecture-wireframe-runtime.json"))) {
  & (Join-Path $PSScriptRoot "captureGodotSaltoUiArchitectureWindows.ps1")
}

node "tools/godot/saltoUiArchitectureStyleLockTool.mjs" validation "--artifact-root=$ArtifactRootArg"
if ($LASTEXITCODE -ne 0) {
  throw "v0.207 UI architecture validation failed with exit code $LASTEXITCODE."
}

node "tools/godot/saltoUiArchitectureStyleLockTool.mjs" boundary "--artifact-root=$ArtifactRootArg"
if ($LASTEXITCODE -ne 0) {
  throw "v0.207 UI architecture boundary scan failed with exit code $LASTEXITCODE."
}

node "scripts/validateSaltoExperimentalArtifactRetention.mjs" "--output-root=$((Join-Path $ArtifactRoot 'artifact-retention').Replace('\', '/'))"
if ($LASTEXITCODE -ne 0) {
  throw "v0.207 artifact retention validation failed with exit code $LASTEXITCODE."
}

Write-Output "PASS_V0207_UI_ARCHITECTURE_VALIDATION_READY"
