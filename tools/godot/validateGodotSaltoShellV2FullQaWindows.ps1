param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ExePath = Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe"
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0206"
$ValidationRoot = Join-Path $ArtifactRoot "validation"
$ArtifactRootArg = $ArtifactRoot.Replace("\", "/")
$MissingSourcePath = Join-Path $ArtifactRoot "missing-structure-finish-source\barrosan_structure_finish_material_v0202_1024.png"
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
  throw "Missing exported Godot executable for v0.206 validation: $Path"
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
    throw "Missing expected artifact '$fileName' for v0.206 validation scenario '$ScenarioRoot'."
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

$env:GODOT_SALTO_EXE_PATH = $ExePath
try {
  Invoke-DefaultValidationScenario -ScenarioRoot (Join-Path $ValidationRoot "default-procedural")

  & (Join-Path $PSScriptRoot "launchGodotSaltoShellV2GroundingLightingWindows.ps1") -Wait "--player-slice-validate" "--artifact-root=$((Join-Path $ValidationRoot 'legacy-pre-v0203-shell-v2').Replace('\', '/'))"
  Assert-ExpectedFiles -ScenarioRoot (Join-Path $ValidationRoot "legacy-pre-v0203-shell-v2") -ExpectedFiles @("player-slice-validation-runtime.json")

  & (Join-Path $PSScriptRoot "launchGodotSaltoShellV2GroundingPropsWindows.ps1") -Wait "--player-slice-validate" "--artifact-root=$((Join-Path $ValidationRoot 'final-shell-v2-grounding-props').Replace('\', '/'))"
  Assert-ExpectedFiles -ScenarioRoot (Join-Path $ValidationRoot "final-shell-v2-grounding-props") -ExpectedFiles @("player-slice-validation-runtime.json")

  & (Join-Path $PSScriptRoot "launchGodotSaltoShellV2GroundingPropsWindows.ps1") -Wait "--player-slice-validate" "--artifact-root=$((Join-Path $ValidationRoot 'missing-structure-material-fallback').Replace('\', '/'))" "--structure-finish-material-source=$($MissingSourcePath.Replace('\', '/'))" "--structure-finish-material-fallback-mode=missing"
  Assert-ExpectedFiles -ScenarioRoot (Join-Path $ValidationRoot "missing-structure-material-fallback") -ExpectedFiles @("player-slice-validation-runtime.json")

  & (Join-Path $PSScriptRoot "launchGodotSaltoShellV2GroundingPropsWindows.ps1") -Wait "--player-slice-validate" "--artifact-root=$((Join-Path $ValidationRoot 'hash-mismatch-structure-material-fallback').Replace('\', '/'))" "--structure-finish-material-expected-sha256=$MismatchSha" "--structure-finish-material-fallback-mode=hash-mismatch"
  Assert-ExpectedFiles -ScenarioRoot (Join-Path $ValidationRoot "hash-mismatch-structure-material-fallback") -ExpectedFiles @("player-slice-validation-runtime.json")
} finally {
  Remove-Item Env:\GODOT_SALTO_EXE_PATH -ErrorAction SilentlyContinue
}

node "tools/godot/saltoShellV2FullQaTool.mjs" validation "--artifact-root=$ArtifactRootArg"
if ($LASTEXITCODE -ne 0) {
  throw "v0.206 shell-v2 full QA validation report failed with exit code $LASTEXITCODE."
}

node "tools/godot/saltoShellV2FullQaTool.mjs" boundary "--artifact-root=$ArtifactRootArg"
if ($LASTEXITCODE -ne 0) {
  throw "v0.206 shell-v2 full QA boundary scan failed with exit code $LASTEXITCODE."
}

node "scripts/validateSaltoExperimentalArtifactRetention.mjs" "--output-root=$((Join-Path $ArtifactRoot 'artifact-retention').Replace('\', '/'))"
if ($LASTEXITCODE -ne 0) {
  throw "v0.206 artifact retention validation failed with exit code $LASTEXITCODE."
}

Write-Output "PASS_V0206_SHELL_V2_FULL_QA_VALIDATION_READY"
