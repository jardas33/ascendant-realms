param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0216"
$CaptureRoot = Join-Path $ArtifactRoot "capture"
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

function Assert-PassManifest {
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
    throw "Expected capture manifest was not written: $Path"
  }
  if ($manifest.status -ne "PASS_PLAYER_SLICE_CAPTURE") {
    throw "Expected PASS_PLAYER_SLICE_CAPTURE in $Path but received $($manifest.status)."
  }
}

function Invoke-CaptureScenario {
  param(
    [Parameter(Mandatory = $true)][string]$ScenarioId,
    [string[]]$ExtraArgs = @()
  )
  $ScenarioRoot = Join-Path $CaptureRoot $ScenarioId
  $ScenarioRootArg = $ScenarioRoot.Replace("\", "/")
  $ScenarioArgs = @("--player-slice-capture", "--artifact-root=$ScenarioRootArg") + $ExtraArgs
  try {
    & (Join-Path $PSScriptRoot "launchGodotSaltoPresentationRebootWindows.ps1") -Wait @ScenarioArgs
  } catch {
    Start-Sleep -Seconds 20
    Assert-PassManifest -Path (Join-Path $ScenarioRoot "screenshot-runtime-manifest.json")
    Write-Output "Packaged Godot returned nonzero after writing PASS_PLAYER_SLICE_CAPTURE for $ScenarioId; continuing from manifest gate."
    return
  }
  Start-Sleep -Seconds 20
  Assert-PassManifest -Path (Join-Path $ScenarioRoot "screenshot-runtime-manifest.json")
}

& (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
& (Join-Path $PSScriptRoot "packageGodotWindows.ps1")

Reset-SafeDirectory -Path $CaptureRoot -Parent $ArtifactRoot

Invoke-CaptureScenario -ScenarioId "selected-terrain" -ExtraArgs @()
Invoke-CaptureScenario -ScenarioId "previous-ground-material" -ExtraArgs @(
  "--salto-presentation-reboot-use-v0175-ground"
)
Invoke-CaptureScenario -ScenarioId "hash-mismatch-fallback" -ExtraArgs @(
  "--salto-presentation-reboot-ground-hash-mismatch"
)
Invoke-CaptureScenario -ScenarioId "missing-art-fallback" -ExtraArgs @(
  "--salto-presentation-reboot-ground-missing-fallback"
)

$BundledPython = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
if (Test-Path -LiteralPath $BundledPython) {
  $env:SALTO_CONTACT_SHEET_PYTHON = $BundledPython
}

try {
  node "tools/godot/saltoTerrainMaterialProductionTool.mjs" capture "--artifact-root=$ArtifactRootArg"
  if ($LASTEXITCODE -ne 0) {
    throw "v0.216 terrain material production capture report failed with exit code $LASTEXITCODE."
  }
} finally {
  Remove-Item Env:\SALTO_CONTACT_SHEET_PYTHON -ErrorAction SilentlyContinue
}

Write-Output "PASS_V0216_TERRAIN_MATERIAL_CAPTURE_READY"
