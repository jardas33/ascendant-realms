param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ExePath = Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe"
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0203"
$BenchmarkRoot = Join-Path $ArtifactRoot "benchmark"
$ArtifactRootArg = $ArtifactRoot.Replace("\", "/")

Set-Location $RepoRoot

& (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
& (Join-Path $PSScriptRoot "packageGodotWindows.ps1")

function Wait-ForExecutable {
  param([Parameter(Mandatory = $true)][string]$Path)
  $deadline = (Get-Date).AddSeconds(45)
  do {
    if (Test-Path -LiteralPath $Path) {
      $item = Get-Item -LiteralPath $Path
      if ($item.Length -gt 0) {
        return $item.FullName
      }
    }
    Start-Sleep -Milliseconds 250
  } while ((Get-Date) -lt $deadline)

  throw "Missing exported Godot executable for v0.203 benchmark: $Path"
}

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
    throw "Missing expected artifact '$fileName' for v0.203 benchmark scenario '$ScenarioRoot'."
  }
}

Reset-SafeDirectory -Path $BenchmarkRoot -Parent $ArtifactRoot
$ExePath = Wait-ForExecutable -Path $ExePath
$env:GODOT_SALTO_EXE_PATH = $ExePath
try {
  & (Join-Path $PSScriptRoot "launchGodotSaltoShellV2StructureHierarchyWindows.ps1") -Wait "--worker-art-opt-in-benchmark" "--artifact-root=$((Join-Path $BenchmarkRoot 's1-shell-v2-structure-hierarchy').Replace('\', '/'))"
  Assert-ExpectedFiles -ScenarioRoot (Join-Path $BenchmarkRoot "s1-shell-v2-structure-hierarchy") -ExpectedFiles @("worker-art-opt-in-benchmark-runtime.json")
  & (Join-Path $PSScriptRoot "launchGodotSaltoShellV2EnvironmentalCohesionWindows.ps1") -Wait "--worker-art-opt-in-benchmark" "--artifact-root=$((Join-Path $BenchmarkRoot 'c1-shell-v2-environmental-cohesion').Replace('\', '/'))"
  Assert-ExpectedFiles -ScenarioRoot (Join-Path $BenchmarkRoot "c1-shell-v2-environmental-cohesion") -ExpectedFiles @("worker-art-opt-in-benchmark-runtime.json")
} finally {
  Remove-Item Env:\GODOT_SALTO_EXE_PATH -ErrorAction SilentlyContinue
}

node "tools/godot/saltoShellV2EnvironmentalCohesionTool.mjs" benchmark "--artifact-root=$ArtifactRootArg"
if ($LASTEXITCODE -ne 0) {
  throw "v0.203 environmental cohesion benchmark failed with exit code $LASTEXITCODE."
}
