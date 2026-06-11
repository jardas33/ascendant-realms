param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0212"
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

function Invoke-MinimapTooltipPass {
  param(
    [Parameter(Mandatory = $true)][string[]]$Args,
    [Parameter(Mandatory = $true)][string]$ManifestPath,
    [Parameter(Mandatory = $true)][string]$ExpectedStatus
  )
  try {
    & (Join-Path $PSScriptRoot "launchGodotSaltoUiShellExperimentWindows.ps1") -Wait @Args
  } catch {
    Assert-PassManifest -Path $ManifestPath -ExpectedStatus $ExpectedStatus
    Write-Output "Packaged Godot returned nonzero after writing $ExpectedStatus; continuing from manifest gate."
    return
  }
  Assert-PassManifest -Path $ManifestPath -ExpectedStatus $ExpectedStatus
}

$OptInRoot = Join-Path $ArtifactRoot "capture\opt-in"
$OptInArg = $OptInRoot.Replace("\", "/")
Invoke-MinimapTooltipPass -Args @("--player-slice-capture", "--salto-selection-command-panel", "--salto-production-objectives-log", "--salto-minimap-tooltip-accessibility", "--artifact-root=$OptInArg") -ManifestPath (Join-Path $OptInRoot "screenshot-runtime-manifest.json") -ExpectedStatus "PASS_PLAYER_SLICE_CAPTURE"

node "tools/godot/saltoMinimapTooltipAccessibilityTool.mjs" capture "--artifact-root=$ArtifactRootArg"
if ($LASTEXITCODE -ne 0) {
  throw "v0.212 minimap tooltip accessibility capture failed with exit code $LASTEXITCODE."
}

Write-Output "PASS_V0212_MINIMAP_TOOLTIP_ACCESSIBILITY_CAPTURE_READY"
