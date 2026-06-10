param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ExePath = Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe"
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0198"
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
    throw "Missing expected artifact '$fileName' for v0.198 scenario '$ScenarioRoot'."
  }
}

function ConvertTo-ProcessArgumentString {
  param([Parameter(Mandatory = $true)][string[]]$Arguments)
  return ($Arguments | ForEach-Object {
    if ($_ -match '[\s"]') {
      '"' + ($_ -replace '"', '\"') + '"'
    } else {
      $_
    }
  }) -join " "
}

function Invoke-DefaultValidationScenario {
  param([Parameter(Mandatory = $true)][string]$ScenarioRoot)
  New-Item -ItemType Directory -Force -Path $ScenarioRoot | Out-Null
  $ScenarioRootArg = $ScenarioRoot.Replace("\", "/")
  $ArgumentList = @("--player-slice-validate", "--artifact-root=$ScenarioRootArg")
  $process = Start-Process -FilePath $ExePath -ArgumentList (ConvertTo-ProcessArgumentString $ArgumentList) -Wait -PassThru -WindowStyle Hidden
  $GodotExitCode = if ($null -eq $process.ExitCode) { 0 } else { $process.ExitCode }
  if ($GodotExitCode -ne 0) {
    throw "Default procedural validation exited with code $GodotExitCode."
  }
  Assert-ExpectedFiles -ScenarioRoot $ScenarioRoot -ExpectedFiles @("player-slice-validation-runtime.json")
}

function Invoke-V0198Tool {
  param([Parameter(Mandatory = $true)][string]$Command)
  node "tools/godot/saltoShellV2MeshWetGraniteTool.mjs" $Command "--artifact-root=$ArtifactRootArg"
  if ($LASTEXITCODE -ne 0) {
    throw "v0.198 wet-granite mesh opt-in tool '$Command' failed with exit code $LASTEXITCODE."
  }
}

Reset-SafeDirectory -Path $ArtifactRoot -Parent (Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto")

$ValidationRoot = Join-Path $ArtifactRoot "validation"
Reset-SafeDirectory -Path $ValidationRoot -Parent $ArtifactRoot
$env:GODOT_SALTO_EXE_PATH = $ExePath
try {
  Invoke-DefaultValidationScenario -ScenarioRoot (Join-Path $ValidationRoot "default-procedural")
  & (Join-Path $PSScriptRoot "launchGodotSaltoShellV2MeshQaWindows.ps1") -Wait "--player-slice-validate" "--artifact-root=$((Join-Path $ValidationRoot 'm2-shell-v2-mesh-qa').Replace('\', '/'))"
  Assert-ExpectedFiles -ScenarioRoot (Join-Path $ValidationRoot "m2-shell-v2-mesh-qa") -ExpectedFiles @("player-slice-validation-runtime.json")
  & (Join-Path $PSScriptRoot "launchGodotSaltoShellV2MeshWetGraniteWindows.ps1") -Wait "--player-slice-validate" "--artifact-root=$((Join-Path $ValidationRoot 'w1-shell-v2-mesh-wet-granite').Replace('\', '/'))"
  Assert-ExpectedFiles -ScenarioRoot (Join-Path $ValidationRoot "w1-shell-v2-mesh-wet-granite") -ExpectedFiles @("player-slice-validation-runtime.json")
  & (Join-Path $PSScriptRoot "launchGodotSaltoShellV2MeshWetGraniteWindows.ps1") -Wait "--bridge-riverbank-material-fallback-mode=missing" "--bridge-riverbank-material-source=$((Join-Path $ArtifactRoot 'missing-bridge-riverbank-source\barrosan_wet_granite_bridge_riverbank_material_v0189_1024.png').Replace('\', '/'))" "--player-slice-validate" "--artifact-root=$((Join-Path $ValidationRoot 'w1-missing-bridge-riverbank-fallback').Replace('\', '/'))"
  Assert-ExpectedFiles -ScenarioRoot (Join-Path $ValidationRoot "w1-missing-bridge-riverbank-fallback") -ExpectedFiles @("player-slice-validation-runtime.json")
  & (Join-Path $PSScriptRoot "launchGodotSaltoShellV2MeshWetGraniteWindows.ps1") -Wait "--bridge-riverbank-material-expected-sha256=0000000000000000000000000000000000000000000000000000000000000000" "--player-slice-validate" "--artifact-root=$((Join-Path $ValidationRoot 'w1-hash-mismatch-bridge-riverbank-fallback').Replace('\', '/'))"
  Assert-ExpectedFiles -ScenarioRoot (Join-Path $ValidationRoot "w1-hash-mismatch-bridge-riverbank-fallback") -ExpectedFiles @("player-slice-validation-runtime.json")
} finally {
  Remove-Item Env:\GODOT_SALTO_EXE_PATH -ErrorAction SilentlyContinue
}
Invoke-V0198Tool -Command "validation"

$BenchmarkRoot = Join-Path $ArtifactRoot "benchmark"
Reset-SafeDirectory -Path $BenchmarkRoot -Parent $ArtifactRoot
$env:GODOT_SALTO_EXE_PATH = $ExePath
try {
  & (Join-Path $PSScriptRoot "launchGodotSaltoShellV2MeshQaWindows.ps1") -Wait "--worker-art-opt-in-benchmark" "--artifact-root=$((Join-Path $BenchmarkRoot 'm2-shell-v2-mesh-qa').Replace('\', '/'))"
  Assert-ExpectedFiles -ScenarioRoot (Join-Path $BenchmarkRoot "m2-shell-v2-mesh-qa") -ExpectedFiles @("worker-art-opt-in-benchmark-runtime.json")
  & (Join-Path $PSScriptRoot "launchGodotSaltoShellV2MeshWetGraniteWindows.ps1") -Wait "--worker-art-opt-in-benchmark" "--artifact-root=$((Join-Path $BenchmarkRoot 'w1-shell-v2-mesh-wet-granite').Replace('\', '/'))"
  Assert-ExpectedFiles -ScenarioRoot (Join-Path $BenchmarkRoot "w1-shell-v2-mesh-wet-granite") -ExpectedFiles @("worker-art-opt-in-benchmark-runtime.json")
} finally {
  Remove-Item Env:\GODOT_SALTO_EXE_PATH -ErrorAction SilentlyContinue
}
Invoke-V0198Tool -Command "benchmark"
Invoke-V0198Tool -Command "boundary"

node "scripts/cleanupSaltoExperimentalArtifacts.mjs" "--output-root=$((Join-Path $ArtifactRoot 'cleanup-dry-run').Replace('\', '/'))"
if ($LASTEXITCODE -ne 0) {
  throw "v0.198 cleanup dry-run failed with exit code $LASTEXITCODE."
}

node "scripts/cleanupSaltoExperimentalArtifacts.mjs" "--apply-safe-only" "--output-root=$((Join-Path $ArtifactRoot 'cleanup-safe-only').Replace('\', '/'))"
if ($LASTEXITCODE -ne 0) {
  throw "v0.198 safe-only cleanup failed with exit code $LASTEXITCODE."
}

node "scripts/validateSaltoExperimentalArtifactRetention.mjs" "--output-root=$((Join-Path $ArtifactRoot 'artifact-retention-post-cleanup').Replace('\', '/'))"
if ($LASTEXITCODE -ne 0) {
  throw "v0.198 artifact retention validation failed with exit code $LASTEXITCODE."
}

Write-Output "PASS_V0198_WET_GRANITE_MESH_OPT_IN_VALIDATION_READY"
