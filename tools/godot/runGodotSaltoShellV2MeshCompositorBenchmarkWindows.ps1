param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ExePath = Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe"
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0196"
$BenchmarkRoot = Join-Path $ArtifactRoot "benchmark"
$ArtifactRootArg = $ArtifactRoot.Replace("\", "/")

Set-Location $RepoRoot

& (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
& (Join-Path $PSScriptRoot "packageGodotWindows.ps1")

function Reset-SafeDirectory {
  param([Parameter(Mandatory = $true)][string]$Path, [Parameter(Mandatory = $true)][string]$Parent)
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

function Assert-ExpectedFiles {
  param([Parameter(Mandatory = $true)][string]$ScenarioRoot, [Parameter(Mandatory = $true)][string[]]$ExpectedFiles)
  $deadline = (Get-Date).AddSeconds(90)
  do {
    $missing = @()
    foreach ($fileName in $ExpectedFiles) {
      if (-not (Test-Path -LiteralPath (Join-Path $ScenarioRoot $fileName))) {
        $missing += $fileName
      }
    }
    if ($missing.Count -eq 0) {
      return
    }
    Start-Sleep -Milliseconds 250
  } while ((Get-Date) -lt $deadline)

  foreach ($fileName in $missing) {
    throw "Missing expected artifact '$fileName' for v0.196 benchmark scenario '$ScenarioRoot'."
  }
}

Reset-SafeDirectory -Path $BenchmarkRoot -Parent $ArtifactRoot
$env:GODOT_SALTO_EXE_PATH = $ExePath
try {
  & (Join-Path $PSScriptRoot "launchGodotSaltoShellV2ScopedMaterialRecoveryWindows.ps1") -Wait "--worker-art-opt-in-benchmark" "--artifact-root=$((Join-Path $BenchmarkRoot 'p1-shell-v2-scoped-material').Replace('\', '/'))"
  Assert-ExpectedFiles -ScenarioRoot (Join-Path $BenchmarkRoot "p1-shell-v2-scoped-material") -ExpectedFiles @("worker-art-opt-in-benchmark-runtime.json")
  & (Join-Path $PSScriptRoot "launchGodotSaltoShellV2MeshCompositorWindows.ps1") -Wait "--worker-art-opt-in-benchmark" "--artifact-root=$((Join-Path $BenchmarkRoot 'm1-shell-v2-mesh-compositor').Replace('\', '/'))"
  Assert-ExpectedFiles -ScenarioRoot (Join-Path $BenchmarkRoot "m1-shell-v2-mesh-compositor") -ExpectedFiles @("worker-art-opt-in-benchmark-runtime.json")
} finally {
  Remove-Item Env:\GODOT_SALTO_EXE_PATH -ErrorAction SilentlyContinue
}

node "tools/godot/saltoShellV2MeshCompositorTool.mjs" benchmark "--artifact-root=$ArtifactRootArg"
if ($LASTEXITCODE -ne 0) {
  throw "v0.196 shell v2 mesh compositor benchmark failed with exit code $LASTEXITCODE."
}
