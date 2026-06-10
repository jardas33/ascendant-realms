param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ExePath = Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe"
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0199"
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
    throw "Missing expected artifact '$fileName' for v0.199 scenario '$ScenarioRoot'."
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

function Invoke-V0199Tool {
  param([Parameter(Mandatory = $true)][string]$Command)
  node "tools/godot/saltoShellV2StructureHierarchyTool.mjs" $Command "--artifact-root=$ArtifactRootArg"
  if ($LASTEXITCODE -ne 0) {
    throw "v0.199 structure hierarchy tool '$Command' failed with exit code $LASTEXITCODE."
  }
}

Reset-SafeDirectory -Path $ArtifactRoot -Parent (Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto")

$ValidationRoot = Join-Path $ArtifactRoot "validation"
Reset-SafeDirectory -Path $ValidationRoot -Parent $ArtifactRoot
$env:GODOT_SALTO_EXE_PATH = $ExePath
try {
  Invoke-DefaultValidationScenario -ScenarioRoot (Join-Path $ValidationRoot "default-procedural")
  & (Join-Path $PSScriptRoot "launchGodotSaltoShellV2MeshWetGraniteWindows.ps1") -Wait "--player-slice-validate" "--artifact-root=$((Join-Path $ValidationRoot 'w1-shell-v2-mesh-wet-granite').Replace('\', '/'))"
  Assert-ExpectedFiles -ScenarioRoot (Join-Path $ValidationRoot "w1-shell-v2-mesh-wet-granite") -ExpectedFiles @("player-slice-validation-runtime.json")
  & (Join-Path $PSScriptRoot "launchGodotSaltoShellV2StructureHierarchyWindows.ps1") -Wait "--player-slice-validate" "--artifact-root=$((Join-Path $ValidationRoot 's1-shell-v2-structure-hierarchy').Replace('\', '/'))"
  Assert-ExpectedFiles -ScenarioRoot (Join-Path $ValidationRoot "s1-shell-v2-structure-hierarchy") -ExpectedFiles @("player-slice-validation-runtime.json")
} finally {
  Remove-Item Env:\GODOT_SALTO_EXE_PATH -ErrorAction SilentlyContinue
}
Invoke-V0199Tool -Command "validation"
Invoke-V0199Tool -Command "boundary"

node "scripts/cleanupSaltoExperimentalArtifacts.mjs" "--output-root=$((Join-Path $ArtifactRoot 'cleanup-dry-run').Replace('\', '/'))"
if ($LASTEXITCODE -ne 0) {
  throw "v0.199 cleanup dry-run failed with exit code $LASTEXITCODE."
}

node "scripts/cleanupSaltoExperimentalArtifacts.mjs" "--apply-safe-only" "--output-root=$((Join-Path $ArtifactRoot 'cleanup-safe-only').Replace('\', '/'))"
if ($LASTEXITCODE -ne 0) {
  throw "v0.199 safe-only cleanup failed with exit code $LASTEXITCODE."
}

node "scripts/validateSaltoExperimentalArtifactRetention.mjs" "--output-root=$((Join-Path $ArtifactRoot 'artifact-retention-post-cleanup').Replace('\', '/'))"
if ($LASTEXITCODE -ne 0) {
  throw "v0.199 artifact retention validation failed with exit code $LASTEXITCODE."
}

Write-Output "PASS_V0199_STRUCTURE_HIERARCHY_VALIDATION_READY"
