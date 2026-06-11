param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ExePath = Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe"
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0215"
$ValidationRoot = Join-Path $ArtifactRoot "validation"
$ArtifactRootArg = $ArtifactRoot.Replace("\", "/")

Set-Location $RepoRoot

function Assert-PassManifest {
  param([Parameter(Mandatory = $true)][string]$Path, [Parameter(Mandatory = $true)][string]$ExpectedStatus)
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
    throw "Expected manifest was not written: $Path"
  }
  if ($manifest.status -ne $ExpectedStatus) {
    throw "Expected $ExpectedStatus in $Path but received $($manifest.status)."
  }
}

function Test-PassManifest {
  param([Parameter(Mandatory = $true)][string]$Path, [Parameter(Mandatory = $true)][string]$ExpectedStatus)
  if (-not (Test-Path -LiteralPath $Path)) {
    return $false
  }
  try {
    $manifest = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
    return $manifest.status -eq $ExpectedStatus
  } catch {
    return $false
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
  $ManifestPath = Join-Path $ScenarioRoot "player-slice-validation-runtime.json"
  if (Test-PassManifest -Path $ManifestPath -ExpectedStatus "PASS_PLAYER_SLICE_VALIDATION") {
    Write-Output "Reusing existing PASS_PLAYER_SLICE_VALIDATION manifest: $ManifestPath"
    return
  }
  New-Item -ItemType Directory -Force -Path $ScenarioRoot | Out-Null
  $ScenarioRootArg = $ScenarioRoot.Replace("\", "/")
  $ArgumentList = @("--player-slice-validate", "--artifact-root=$ScenarioRootArg")
  $process = Start-Process -FilePath $ExePath -ArgumentList (ConvertTo-ProcessArgumentString $ArgumentList) -Wait -PassThru -WindowStyle Hidden
  $GodotExitCode = if ($null -eq $process.ExitCode) { 0 } else { $process.ExitCode }
  if ($GodotExitCode -ne 0) {
    throw "Default procedural validation exited with code $GodotExitCode."
  }
  Assert-PassManifest -Path $ManifestPath -ExpectedStatus "PASS_PLAYER_SLICE_VALIDATION"
}

function Invoke-GodotPassIfNeeded {
  param(
    [Parameter(Mandatory = $true)][string]$ScriptPath,
    [Parameter(Mandatory = $true)][string[]]$Args,
    [Parameter(Mandatory = $true)][string]$ManifestPath,
    [Parameter(Mandatory = $true)][string]$ExpectedStatus
  )
  if (Test-PassManifest -Path $ManifestPath -ExpectedStatus $ExpectedStatus) {
    Write-Output "Reusing existing $ExpectedStatus manifest: $ManifestPath"
    return
  }
  try {
    & $ScriptPath -Wait @Args
  } catch {
    Start-Sleep -Seconds 12
    Assert-PassManifest -Path $ManifestPath -ExpectedStatus $ExpectedStatus
    Write-Output "Packaged Godot returned nonzero after writing $ExpectedStatus; continuing from manifest gate."
    return
  }
  Start-Sleep -Seconds 12
  Assert-PassManifest -Path $ManifestPath -ExpectedStatus $ExpectedStatus
}

& (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
& (Join-Path $PSScriptRoot "packageGodotWindows.ps1")

if (-not (Test-Path -LiteralPath (Join-Path $ArtifactRoot "capture\presentation-reboot\screenshot-runtime-manifest.json"))) {
  & (Join-Path $PSScriptRoot "captureGodotSaltoPresentationRebootWindows.ps1")
}

if (-not (Test-Path -LiteralPath $ExePath)) {
  throw "Missing exported Godot executable for v0.215 validation: $ExePath"
}

New-Item -ItemType Directory -Force -Path $ValidationRoot | Out-Null

$UiFlags = @(
  "--salto-ui-shell-experiment",
  "--salto-selection-command-panel",
  "--salto-production-objectives-log",
  "--salto-minimap-tooltip-accessibility"
)

Invoke-DefaultValidationScenario -ScenarioRoot (Join-Path $ValidationRoot "default-procedural")
Invoke-GodotPassIfNeeded -ScriptPath (Join-Path $PSScriptRoot "launchGodotSaltoShellV2GroundingPropsWindows.ps1") -Args (@("--player-slice-validate", "--artifact-root=$((Join-Path $ValidationRoot 'full-ui-comparator').Replace('\', '/'))") + $UiFlags) -ManifestPath (Join-Path $ValidationRoot "full-ui-comparator\player-slice-validation-runtime.json") -ExpectedStatus "PASS_PLAYER_SLICE_VALIDATION"
Invoke-GodotPassIfNeeded -ScriptPath (Join-Path $PSScriptRoot "launchGodotSaltoPresentationRebootWindows.ps1") -Args @("--player-slice-validate", "--artifact-root=$((Join-Path $ValidationRoot 'presentation-reboot').Replace('\', '/'))") -ManifestPath (Join-Path $ValidationRoot "presentation-reboot\player-slice-validation-runtime.json") -ExpectedStatus "PASS_PLAYER_SLICE_VALIDATION"
Invoke-GodotPassIfNeeded -ScriptPath (Join-Path $PSScriptRoot "launchGodotSaltoPresentationRebootWindows.ps1") -Args @("--player-slice-validate", "--salto-ui-shell-force-fallback", "--artifact-root=$((Join-Path $ValidationRoot 'procedural-fallback').Replace('\', '/'))") -ManifestPath (Join-Path $ValidationRoot "procedural-fallback\player-slice-validation-runtime.json") -ExpectedStatus "PASS_PLAYER_SLICE_VALIDATION"

node "tools/godot/saltoPresentationRebootTool.mjs" validation "--artifact-root=$ArtifactRootArg"
if ($LASTEXITCODE -ne 0) {
  throw "v0.215 presentation reboot validation report failed with exit code $LASTEXITCODE."
}

node "tools/godot/saltoPresentationRebootTool.mjs" boundary "--artifact-root=$ArtifactRootArg"
if ($LASTEXITCODE -ne 0) {
  throw "v0.215 presentation reboot boundary scan failed with exit code $LASTEXITCODE."
}

node "scripts/validateSaltoExperimentalArtifactRetention.mjs" "--output-root=$((Join-Path $ArtifactRoot 'artifact-retention').Replace('\', '/'))"
if ($LASTEXITCODE -ne 0) {
  throw "v0.215 artifact retention validation failed with exit code $LASTEXITCODE."
}

Write-Output "PASS_V0215_PRESENTATION_REBOOT_VALIDATION_READY"
