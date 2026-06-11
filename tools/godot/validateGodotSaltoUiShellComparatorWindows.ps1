param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0208"
$ArtifactRootArg = $ArtifactRoot.Replace("\", "/")

Set-Location $RepoRoot

if (-not (Test-Path -LiteralPath (Join-Path $ArtifactRoot "capture\ui-shell-comparator-runtime.json"))) {
  & (Join-Path $PSScriptRoot "captureGodotSaltoUiShellComparatorWindows.ps1")
}

node "tools/godot/saltoUiShellComparatorTool.mjs" validation "--artifact-root=$ArtifactRootArg"
if ($LASTEXITCODE -ne 0) {
  throw "v0.208 UI shell comparator validation failed with exit code $LASTEXITCODE."
}

node "tools/godot/saltoUiShellComparatorTool.mjs" boundary "--artifact-root=$ArtifactRootArg"
if ($LASTEXITCODE -ne 0) {
  throw "v0.208 UI shell comparator boundary scan failed with exit code $LASTEXITCODE."
}

node "scripts/validateSaltoExperimentalArtifactRetention.mjs" "--output-root=$((Join-Path $ArtifactRoot 'artifact-retention').Replace('\', '/'))"
if ($LASTEXITCODE -ne 0) {
  throw "v0.208 artifact retention validation failed with exit code $LASTEXITCODE."
}

Write-Output "PASS_V0208_UI_SHELL_COMPARATOR_VALIDATION_READY"
