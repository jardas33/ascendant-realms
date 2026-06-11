param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0213"
$BenchmarkRoot = Join-Path $ArtifactRoot "benchmark"
$ArtifactRootArg = $ArtifactRoot.Replace("\", "/")

Set-Location $RepoRoot

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
  $deadline = (Get-Date).AddSeconds(120)
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
    throw "Missing expected artifact '$fileName' for v0.213 benchmark scenario '$ScenarioRoot'."
  }
}

& (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
& (Join-Path $PSScriptRoot "packageGodotWindows.ps1")

Reset-SafeDirectory -Path $BenchmarkRoot -Parent $ArtifactRoot

$UiFlags = @(
  "--salto-ui-shell-experiment",
  "--salto-selection-command-panel",
  "--salto-production-objectives-log",
  "--salto-minimap-tooltip-accessibility"
)

& (Join-Path $PSScriptRoot "launchGodotSaltoShellV2GroundingLightingWindows.ps1") -Wait "--worker-art-opt-in-benchmark" "--artifact-root=$((Join-Path $BenchmarkRoot 'pre-v0203-shell-v2-comparator').Replace('\', '/'))"
Assert-ExpectedFiles -ScenarioRoot (Join-Path $BenchmarkRoot "pre-v0203-shell-v2-comparator") -ExpectedFiles @("worker-art-opt-in-benchmark-runtime.json")

$FullUiBenchmarkArgs = @("--worker-art-opt-in-benchmark", "--artifact-root=$((Join-Path $BenchmarkRoot 'full-ui-opt-in').Replace('\', '/'))") + $UiFlags
& (Join-Path $PSScriptRoot "launchGodotSaltoShellV2GroundingPropsWindows.ps1") -Wait @FullUiBenchmarkArgs
Assert-ExpectedFiles -ScenarioRoot (Join-Path $BenchmarkRoot "full-ui-opt-in") -ExpectedFiles @("worker-art-opt-in-benchmark-runtime.json")

$ProceduralFallbackBenchmarkArgs = @("--worker-art-opt-in-benchmark", "--salto-ui-shell-force-fallback", "--artifact-root=$((Join-Path $BenchmarkRoot 'procedural-fallback').Replace('\', '/'))") + $UiFlags
& (Join-Path $PSScriptRoot "launchGodotSaltoShellV2GroundingPropsWindows.ps1") -Wait @ProceduralFallbackBenchmarkArgs
Assert-ExpectedFiles -ScenarioRoot (Join-Path $BenchmarkRoot "procedural-fallback") -ExpectedFiles @("worker-art-opt-in-benchmark-runtime.json")

node "tools/godot/saltoFullUiQaTool.mjs" benchmark "--artifact-root=$ArtifactRootArg"
if ($LASTEXITCODE -ne 0) {
  throw "v0.213 full UI QA benchmark failed with exit code $LASTEXITCODE."
}

Write-Output "PASS_V0213_FULL_UI_QA_BENCHMARK_READY"
