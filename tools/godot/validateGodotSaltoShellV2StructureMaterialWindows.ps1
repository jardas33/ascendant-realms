param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ExePath = Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe"
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0204"
$ValidationRoot = Join-Path $ArtifactRoot "validation"
$ArtifactRootArg = $ArtifactRoot.Replace("\", "/")
$MissingSourcePath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0204\missing-structure-finish-source\barrosan_structure_finish_material_v0202_1024.png"
$MismatchSha = "0000000000000000000000000000000000000000000000000000000000000000"

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
  throw "Missing exported Godot executable for v0.204 validation: $Path"
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
    throw "Missing expected artifact '$fileName' for v0.204 validation scenario '$ScenarioRoot'."
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

New-Item -ItemType Directory -Force -Path $ArtifactRoot | Out-Null
$ExePath = Wait-ForExecutable -Path $ExePath
Reset-SafeDirectory -Path $ValidationRoot -Parent $ArtifactRoot

node "tools/godot/saltoShellV2StructureMaterialTool.mjs" material "--artifact-root=$ArtifactRootArg"
if ($LASTEXITCODE -ne 0) {
  throw "v0.204 structure material identity validation failed with exit code $LASTEXITCODE."
}

$env:GODOT_SALTO_EXE_PATH = $ExePath
try {
  Invoke-DefaultValidationScenario -ScenarioRoot (Join-Path $ValidationRoot "default-procedural")

  & (Join-Path $PSScriptRoot "launchGodotSaltoShellV2EnvironmentalCohesionWindows.ps1") -Wait "--player-slice-validate" "--artifact-root=$((Join-Path $ValidationRoot 'b0-shell-v2-environmental-cohesion').Replace('\', '/'))"
  Assert-ExpectedFiles -ScenarioRoot (Join-Path $ValidationRoot "b0-shell-v2-environmental-cohesion") -ExpectedFiles @("player-slice-validation-runtime.json")

  & (Join-Path $PSScriptRoot "launchGodotSaltoShellV2StructureMaterialWindows.ps1") -Wait "--player-slice-validate" "--artifact-root=$((Join-Path $ValidationRoot 'm1-shell-v2-structure-material').Replace('\', '/'))"
  Assert-ExpectedFiles -ScenarioRoot (Join-Path $ValidationRoot "m1-shell-v2-structure-material") -ExpectedFiles @("player-slice-validation-runtime.json")

  & (Join-Path $PSScriptRoot "launchGodotSaltoShellV2StructureMaterialWindows.ps1") -Wait "--player-slice-validate" "--artifact-root=$((Join-Path $ValidationRoot 'f1-missing-structure-material-fallback').Replace('\', '/'))" "--structure-finish-material-source=$($MissingSourcePath.Replace('\', '/'))" "--structure-finish-material-fallback-mode=missing"
  Assert-ExpectedFiles -ScenarioRoot (Join-Path $ValidationRoot "f1-missing-structure-material-fallback") -ExpectedFiles @("player-slice-validation-runtime.json")

  & (Join-Path $PSScriptRoot "launchGodotSaltoShellV2StructureMaterialWindows.ps1") -Wait "--player-slice-validate" "--artifact-root=$((Join-Path $ValidationRoot 'f2-hash-mismatch-structure-material-fallback').Replace('\', '/'))" "--structure-finish-material-expected-sha256=$MismatchSha"
  Assert-ExpectedFiles -ScenarioRoot (Join-Path $ValidationRoot "f2-hash-mismatch-structure-material-fallback") -ExpectedFiles @("player-slice-validation-runtime.json")
} finally {
  Remove-Item Env:\GODOT_SALTO_EXE_PATH -ErrorAction SilentlyContinue
}

node "tools/godot/saltoShellV2StructureMaterialTool.mjs" validation "--artifact-root=$ArtifactRootArg"
if ($LASTEXITCODE -ne 0) {
  throw "v0.204 structure-shell material validation report failed with exit code $LASTEXITCODE."
}

node "tools/godot/saltoShellV2StructureMaterialTool.mjs" boundary "--artifact-root=$ArtifactRootArg"
if ($LASTEXITCODE -ne 0) {
  throw "v0.204 structure-shell material boundary scan failed with exit code $LASTEXITCODE."
}

node "scripts/cleanupSaltoExperimentalArtifacts.mjs" "--output-root=$((Join-Path $ArtifactRoot 'cleanup-dry-run').Replace('\', '/'))"
if ($LASTEXITCODE -ne 0) {
  throw "v0.204 cleanup dry-run failed with exit code $LASTEXITCODE."
}

node "scripts/validateSaltoExperimentalArtifactRetention.mjs" "--output-root=$((Join-Path $ArtifactRoot 'artifact-retention').Replace('\', '/'))"
if ($LASTEXITCODE -ne 0) {
  throw "v0.204 artifact retention validation failed with exit code $LASTEXITCODE."
}

Write-Output "PASS_V0204_STRUCTURE_SHELL_MATERIAL_VALIDATION_READY"
