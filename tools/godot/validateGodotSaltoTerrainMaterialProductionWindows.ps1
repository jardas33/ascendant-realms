param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ExePath = Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe"
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0216"
$ValidationRoot = Join-Path $ArtifactRoot "validation"
$ArtifactRootArg = $ArtifactRoot.Replace("\", "/")

$PreviousGroundSourcePath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0175\local-ground-material-slot\barrosan_foothold_ground_material_v0175_1024.png"
$PreviousGroundMetadataPath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0175\local-ground-material-slot\barrosan_foothold_ground_material_v0175_1024.metadata.json"
$PreviousGroundSha256 = "818b7743fbf192fe95dd95a0fbadb59ea92b1cb36c420dac5526c0f4d1af18a8"
$MissingGroundSourcePath = Join-Path $ArtifactRoot "missing-source\barrosan_foothold_terrain_material_v0216_1024.png"

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

function Assert-PassValidation {
  param([Parameter(Mandatory = $true)][string]$Path)
  $deadline = (Get-Date).AddSeconds(360)
  $manifest = $null
  while ((Get-Date) -lt $deadline) {
    if (Test-Path -LiteralPath $Path) {
      try {
        $manifest = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
        break
      } catch {
        Start-Sleep -Milliseconds 250
      }
    } else {
      Start-Sleep -Milliseconds 250
    }
  }
  if ($null -eq $manifest) {
    throw "Expected validation manifest was not written: $Path"
  }
  if ($manifest.status -ne "PASS_PLAYER_SLICE_VALIDATION") {
    throw "Expected PASS_PLAYER_SLICE_VALIDATION in $Path but received $($manifest.status)."
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
  Assert-PassValidation -Path (Join-Path $ScenarioRoot "player-slice-validation-runtime.json")
}

function Invoke-RebootValidationScenario {
  param(
    [Parameter(Mandatory = $true)][string]$ScenarioId,
    [string[]]$ExtraArgs = @()
  )
  $ScenarioRoot = Join-Path $ValidationRoot $ScenarioId
  $ScenarioRootArg = $ScenarioRoot.Replace("\", "/")
  $ScenarioArgs = @("--player-slice-validate", "--artifact-root=$ScenarioRootArg") + $ExtraArgs
  try {
    & (Join-Path $PSScriptRoot "launchGodotSaltoPresentationRebootWindows.ps1") -Wait @ScenarioArgs
  } catch {
    Start-Sleep -Seconds 20
    Assert-PassValidation -Path (Join-Path $ScenarioRoot "player-slice-validation-runtime.json")
    Write-Output "Packaged Godot returned nonzero after writing PASS_PLAYER_SLICE_VALIDATION for $ScenarioId; continuing from manifest gate."
    return
  }
  Start-Sleep -Seconds 20
  Assert-PassValidation -Path (Join-Path $ScenarioRoot "player-slice-validation-runtime.json")
}

& (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
& (Join-Path $PSScriptRoot "packageGodotWindows.ps1")

if (-not (Test-Path -LiteralPath (Join-Path $ArtifactRoot "capture\selected-terrain\screenshot-runtime-manifest.json"))) {
  & (Join-Path $PSScriptRoot "captureGodotSaltoTerrainMaterialProductionWindows.ps1")
}
if (-not (Test-Path -LiteralPath $ExePath)) {
  throw "Missing exported Godot executable for v0.216 validation: $ExePath"
}

Reset-SafeDirectory -Path $ValidationRoot -Parent $ArtifactRoot

Invoke-DefaultValidationScenario -ScenarioRoot (Join-Path $ValidationRoot "default-procedural")
Invoke-RebootValidationScenario -ScenarioId "selected-terrain" -ExtraArgs @()
Invoke-RebootValidationScenario -ScenarioId "previous-ground-material" -ExtraArgs @(
  "--salto-presentation-reboot-use-v0175-ground"
)
Invoke-RebootValidationScenario -ScenarioId "hash-mismatch-fallback" -ExtraArgs @(
  "--salto-presentation-reboot-ground-hash-mismatch"
)
Invoke-RebootValidationScenario -ScenarioId "missing-art-fallback" -ExtraArgs @(
  "--salto-presentation-reboot-ground-missing-fallback"
)

node "tools/godot/saltoTerrainMaterialProductionTool.mjs" validation "--artifact-root=$ArtifactRootArg"
if ($LASTEXITCODE -ne 0) {
  throw "v0.216 terrain material production validation report failed with exit code $LASTEXITCODE."
}

node "tools/godot/saltoTerrainMaterialProductionTool.mjs" boundary "--artifact-root=$ArtifactRootArg"
if ($LASTEXITCODE -ne 0) {
  throw "v0.216 terrain material production boundary scan failed with exit code $LASTEXITCODE."
}

node "scripts/cleanupSaltoExperimentalArtifacts.mjs" "--output-root=$((Join-Path $ArtifactRoot 'cleanup-dry-run').Replace('\', '/'))"
if ($LASTEXITCODE -ne 0) {
  throw "v0.216 cleanup dry-run failed with exit code $LASTEXITCODE."
}

node "scripts/validateSaltoExperimentalArtifactRetention.mjs" "--output-root=$((Join-Path $ArtifactRoot 'artifact-retention').Replace('\', '/'))"
if ($LASTEXITCODE -ne 0) {
  throw "v0.216 artifact retention validation failed with exit code $LASTEXITCODE."
}

Write-Output "PASS_V0216_TERRAIN_MATERIAL_VALIDATION_READY"
