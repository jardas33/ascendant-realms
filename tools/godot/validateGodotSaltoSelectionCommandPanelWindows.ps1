param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0210"
$ArtifactRootArg = $ArtifactRoot.Replace("\", "/")

Set-Location $RepoRoot

function Assert-PassManifest {
  param(
    [Parameter(Mandatory = $true)][string]$Path,
    [Parameter(Mandatory = $true)][string]$ExpectedStatus
  )
  $deadline = (Get-Date).AddSeconds(90)
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

function Invoke-GodotPass {
  param(
    [Parameter(Mandatory = $true)][string]$ScriptPath,
    [Parameter(Mandatory = $true)][string[]]$Args,
    [Parameter(Mandatory = $true)][string]$ManifestPath,
    [Parameter(Mandatory = $true)][string]$ExpectedStatus
  )
  try {
    & $ScriptPath -Wait @Args
  } catch {
    Assert-PassManifest -Path $ManifestPath -ExpectedStatus $ExpectedStatus
    Write-Output "Packaged Godot returned nonzero after writing $ExpectedStatus; continuing from manifest gate."
    return
  }
  Assert-PassManifest -Path $ManifestPath -ExpectedStatus $ExpectedStatus
}

if (-not (Test-Path -LiteralPath (Join-Path $ArtifactRoot "capture\opt-in\screenshot-runtime-manifest.json")) -or
    -not (Test-Path -LiteralPath (Join-Path $ArtifactRoot "capture\portrait-fallback\screenshot-runtime-manifest.json"))) {
  & (Join-Path $PSScriptRoot "captureGodotSaltoSelectionCommandPanelWindows.ps1")
}

$OptInValidationRoot = Join-Path $ArtifactRoot "validation\opt-in"
$FallbackValidationRoot = Join-Path $ArtifactRoot "validation\portrait-fallback"
$DefaultValidationRoot = Join-Path $ArtifactRoot "validation\default-procedural"

Invoke-GodotPass -ScriptPath (Join-Path $PSScriptRoot "launchGodotSaltoUiShellExperimentWindows.ps1") -Args @("--player-slice-validate", "--salto-selection-command-panel", "--artifact-root=$($OptInValidationRoot.Replace('\', '/'))") -ManifestPath (Join-Path $OptInValidationRoot "player-slice-validation-runtime.json") -ExpectedStatus "PASS_PLAYER_SLICE_VALIDATION"
Invoke-GodotPass -ScriptPath (Join-Path $PSScriptRoot "launchGodotSaltoUiShellExperimentWindows.ps1") -Args @("--player-slice-validate", "--salto-selection-command-panel", "--salto-aster-portrait-force-fallback", "--artifact-root=$($FallbackValidationRoot.Replace('\', '/'))") -ManifestPath (Join-Path $FallbackValidationRoot "player-slice-validation-runtime.json") -ExpectedStatus "PASS_PLAYER_SLICE_VALIDATION"
Invoke-GodotPass -ScriptPath (Join-Path $PSScriptRoot "launchGodotPlayerSliceWindows.ps1") -Args @("--player-slice-validate", "--artifact-root=$($DefaultValidationRoot.Replace('\', '/'))") -ManifestPath (Join-Path $DefaultValidationRoot "player-slice-validation-runtime.json") -ExpectedStatus "PASS_PLAYER_SLICE_VALIDATION"

node "tools/godot/saltoSelectionCommandPanelTool.mjs" validation "--artifact-root=$ArtifactRootArg"
if ($LASTEXITCODE -ne 0) {
  throw "v0.210 selection command panel validation failed with exit code $LASTEXITCODE."
}

node "tools/godot/saltoSelectionCommandPanelTool.mjs" boundary "--artifact-root=$ArtifactRootArg"
if ($LASTEXITCODE -ne 0) {
  throw "v0.210 selection command panel boundary scan failed with exit code $LASTEXITCODE."
}

node "scripts/validateSaltoExperimentalArtifactRetention.mjs" "--output-root=$((Join-Path $ArtifactRoot 'artifact-retention').Replace('\', '/'))"
if ($LASTEXITCODE -ne 0) {
  throw "v0.210 artifact retention validation failed with exit code $LASTEXITCODE."
}

Write-Output "PASS_V0210_SELECTION_COMMAND_PANEL_VALIDATION_READY"
