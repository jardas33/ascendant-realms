param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0213"
$CaptureRoot = Join-Path $ArtifactRoot "capture"
$RealInputRoot = Join-Path $ArtifactRoot "real-input"
$ArtifactRootArg = $ArtifactRoot.Replace("\", "/")

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
  param(
    [Parameter(Mandatory = $true)][string]$Path,
    [Parameter(Mandatory = $true)][string]$ExpectedStatus
  )
  $deadline = (Get-Date).AddSeconds(180)
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
  param(
    [Parameter(Mandatory = $true)][string]$Path,
    [Parameter(Mandatory = $true)][string]$ExpectedStatus
  )
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

function Invoke-FullUiQaPass {
  param(
    [Parameter(Mandatory = $true)][string[]]$Args,
    [Parameter(Mandatory = $true)][string]$ManifestPath,
    [Parameter(Mandatory = $true)][string]$ExpectedStatus
  )
  try {
    & (Join-Path $PSScriptRoot "launchGodotSaltoShellV2GroundingPropsWindows.ps1") -Wait @Args
  } catch {
    Assert-PassManifest -Path $ManifestPath -ExpectedStatus $ExpectedStatus
    Write-Output "Packaged Godot returned nonzero after writing $ExpectedStatus; continuing from manifest gate."
    return
  }
  Assert-PassManifest -Path $ManifestPath -ExpectedStatus $ExpectedStatus
}

function Invoke-RealInputPass {
  param(
    [Parameter(Mandatory = $true)][string[]]$Args,
    [Parameter(Mandatory = $true)][string]$ScenarioRoot,
    [Parameter(Mandatory = $true)][string[]]$ExpectedFiles
  )
  & (Join-Path $PSScriptRoot "launchGodotSaltoShellV2GroundingPropsWindows.ps1") -Wait @Args
  $deadline = (Get-Date).AddSeconds(360)
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
    throw "Missing expected artifact '$fileName' for v0.213 real-input scenario '$ScenarioRoot'."
  }
}

& (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
& (Join-Path $PSScriptRoot "packageGodotWindows.ps1")

Reset-SafeDirectory -Path $RealInputRoot -Parent $ArtifactRoot

$UiFlags = @(
  "--salto-ui-shell-experiment",
  "--salto-selection-command-panel",
  "--salto-production-objectives-log",
  "--salto-minimap-tooltip-accessibility"
)

$FullUiRoot = Join-Path $CaptureRoot "full-ui"
$PortraitFallbackRoot = Join-Path $CaptureRoot "portrait-fallback"
$ProceduralFallbackRoot = Join-Path $CaptureRoot "procedural-fallback"

$FullUiManifest = Join-Path $FullUiRoot "screenshot-runtime-manifest.json"
$PortraitFallbackManifest = Join-Path $PortraitFallbackRoot "screenshot-runtime-manifest.json"
$ProceduralFallbackManifest = Join-Path $ProceduralFallbackRoot "screenshot-runtime-manifest.json"
$CaptureManifestsReady = (
  (Test-PassManifest -Path $FullUiManifest -ExpectedStatus "PASS_PLAYER_SLICE_CAPTURE") -and
  (Test-PassManifest -Path $PortraitFallbackManifest -ExpectedStatus "PASS_PLAYER_SLICE_CAPTURE") -and
  (Test-PassManifest -Path $ProceduralFallbackManifest -ExpectedStatus "PASS_PLAYER_SLICE_CAPTURE")
)

if ($CaptureManifestsReady) {
  Write-Output "Reusing existing PASS v0.213 capture manifests."
} else {
  Reset-SafeDirectory -Path $CaptureRoot -Parent $ArtifactRoot
  Invoke-FullUiQaPass -Args (@("--player-slice-capture", "--artifact-root=$($FullUiRoot.Replace('\', '/'))") + $UiFlags) -ManifestPath $FullUiManifest -ExpectedStatus "PASS_PLAYER_SLICE_CAPTURE"
  Invoke-FullUiQaPass -Args (@("--player-slice-capture", "--artifact-root=$($PortraitFallbackRoot.Replace('\', '/'))", "--salto-aster-portrait-force-fallback") + $UiFlags) -ManifestPath $PortraitFallbackManifest -ExpectedStatus "PASS_PLAYER_SLICE_CAPTURE"
  Invoke-FullUiQaPass -Args (@("--player-slice-capture", "--artifact-root=$($ProceduralFallbackRoot.Replace('\', '/'))", "--salto-ui-shell-force-fallback") + $UiFlags) -ManifestPath $ProceduralFallbackManifest -ExpectedStatus "PASS_PLAYER_SLICE_CAPTURE"
}

Invoke-RealInputPass -Args (@("--post-mine-flow-validate", "--artifact-root=$((Join-Path $RealInputRoot 'post-mine-flow').Replace('\', '/'))") + $UiFlags) -ScenarioRoot (Join-Path $RealInputRoot "post-mine-flow") -ExpectedFiles @("headed-post-mine-flow-smoke.json", "barracks-restoration-proof.json", "militia-recruit-proof.json", "combat-onset-proof.json", "lume-restore-proof.json", "screenshot-manifest.json")
Invoke-RealInputPass -Args (@("--triple-natural-playthrough", "--artifact-root=$((Join-Path $RealInputRoot 'restart-replay').Replace('\', '/'))") + $UiFlags) -ScenarioRoot (Join-Path $RealInputRoot "restart-replay") -ExpectedFiles @("triple-playthrough-report.json", "recovery-case-report.json", "restart-integrity-report.json", "no-softlock-proof.json", "no-shortcut-proof.json", "screenshot-manifest.json")

$BundledPython = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
if (Test-Path -LiteralPath $BundledPython) {
  $env:SALTO_CONTACT_SHEET_PYTHON = $BundledPython
}

try {
  node "tools/godot/saltoFullUiQaTool.mjs" capture "--artifact-root=$ArtifactRootArg"
  if ($LASTEXITCODE -ne 0) {
    throw "v0.213 full UI QA capture report failed with exit code $LASTEXITCODE."
  }
} finally {
  Remove-Item Env:\SALTO_CONTACT_SHEET_PYTHON -ErrorAction SilentlyContinue
}

Write-Output "PASS_V0213_FULL_UI_QA_CAPTURE_READY"
