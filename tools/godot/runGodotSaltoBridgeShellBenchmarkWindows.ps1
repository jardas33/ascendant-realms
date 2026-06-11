param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0218"
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
    throw "Missing expected artifact '$fileName' for v0.218 benchmark scenario '$ScenarioRoot'."
  }
}

function Invoke-BenchmarkScenario {
  param(
    [Parameter(Mandatory = $true)][string]$ScenarioId,
    [string[]]$ExtraArgs = @()
  )
  $ScenarioRoot = Join-Path $BenchmarkRoot $ScenarioId
  $ScenarioRootArg = $ScenarioRoot.Replace("\", "/")
  $ScenarioArgs = @("--worker-art-opt-in-benchmark", "--artifact-root=$ScenarioRootArg") + $ExtraArgs
  & (Join-Path $PSScriptRoot "launchGodotSaltoPresentationRebootWindows.ps1") -Wait @ScenarioArgs
  Assert-ExpectedFiles -ScenarioRoot $ScenarioRoot -ExpectedFiles @("worker-art-opt-in-benchmark-runtime.json")
}

& (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
& (Join-Path $PSScriptRoot "packageGodotWindows.ps1")

Reset-SafeDirectory -Path $BenchmarkRoot -Parent $ArtifactRoot

Invoke-BenchmarkScenario -ScenarioId "selected-bridge-shell" -ExtraArgs @()
Invoke-BenchmarkScenario -ScenarioId "legacy-bridge-comparator" -ExtraArgs @(
  "--salto-presentation-reboot-legacy-bridge"
)

node "tools/godot/saltoBridgeShellTool.mjs" benchmark "--artifact-root=$ArtifactRootArg"
if ($LASTEXITCODE -ne 0) {
  throw "v0.218 bridge shell benchmark failed with exit code $LASTEXITCODE."
}

Write-Output "PASS_V0218_BRIDGE_SHELL_BENCHMARK_READY"
