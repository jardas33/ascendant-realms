param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ExePath = Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe"
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0184"
$CaptureRoot = Join-Path $ArtifactRoot "capture"
$ArtifactRootArg = $ArtifactRoot.Replace("\", "/")

Set-Location $RepoRoot

& (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
& (Join-Path $PSScriptRoot "packageGodotWindows.ps1")

function Reset-SafeDirectory {
  param([string]$Path, [string]$Parent)
  New-Item -ItemType Directory -Force -Path $Parent | Out-Null
  $resolvedParent = Resolve-Path -LiteralPath $Parent
  if (Test-Path -LiteralPath $Path) {
    $resolvedPath = Resolve-Path -LiteralPath $Path
    if (-not $resolvedPath.Path.StartsWith($resolvedParent.Path, [System.StringComparison]::OrdinalIgnoreCase)) {
      throw "Refusing to remove outside expected artifact root: $($resolvedPath.Path)"
    }
    Remove-Item -LiteralPath $Path -Recurse -Force
  }
  New-Item -ItemType Directory -Force -Path $Path | Out-Null
}

Reset-SafeDirectory -Path $CaptureRoot -Parent $ArtifactRoot
$env:GODOT_SALTO_EXE_PATH = $ExePath
try {
  & (Join-Path $PSScriptRoot "launchGodotSaltoGroundRoadMaterialOptInWindows.ps1") -Wait "--player-slice-capture" "--artifact-root=$((Join-Path $CaptureRoot 'e2-ground-road-material-opt-in-baseline').Replace('\', '/'))"
  & (Join-Path $PSScriptRoot "launchGodotSaltoEnvironmentGeometryConvergenceWindows.ps1") -Wait "--player-slice-capture" "--artifact-root=$((Join-Path $CaptureRoot 'e3-geometry-convergence-opt-in').Replace('\', '/'))"
} finally {
  Remove-Item Env:\GODOT_SALTO_EXE_PATH -ErrorAction SilentlyContinue
}

node "tools/godot/saltoEnvironmentGeometryConvergenceTool.mjs" capture "--artifact-root=$ArtifactRootArg"
if ($LASTEXITCODE -ne 0) {
  throw "v0.184 environment geometry convergence capture report failed with exit code $LASTEXITCODE."
}
