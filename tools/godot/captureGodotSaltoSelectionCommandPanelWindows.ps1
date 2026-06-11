param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0210"
$CaptureRoot = Join-Path $ArtifactRoot "capture"
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

function Invoke-SelectionPanelPass {
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

Reset-SafeDirectory -Path $CaptureRoot -Parent $ArtifactRoot

$OptInRoot = Join-Path $CaptureRoot "opt-in"
$FallbackRoot = Join-Path $CaptureRoot "portrait-fallback"
$OptInArg = $OptInRoot.Replace("\", "/")
$FallbackArg = $FallbackRoot.Replace("\", "/")

Invoke-SelectionPanelPass -Args @("--player-slice-capture", "--salto-selection-command-panel", "--artifact-root=$OptInArg") -ManifestPath (Join-Path $OptInRoot "screenshot-runtime-manifest.json") -ExpectedStatus "PASS_PLAYER_SLICE_CAPTURE"
Invoke-SelectionPanelPass -Args @("--player-slice-capture", "--salto-selection-command-panel", "--salto-aster-portrait-force-fallback", "--artifact-root=$FallbackArg") -ManifestPath (Join-Path $FallbackRoot "screenshot-runtime-manifest.json") -ExpectedStatus "PASS_PLAYER_SLICE_CAPTURE"

$BundledPython = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
if (Test-Path -LiteralPath $BundledPython) {
  $env:SALTO_CONTACT_SHEET_PYTHON = $BundledPython
}

try {
  node "tools/godot/saltoSelectionCommandPanelTool.mjs" capture "--artifact-root=$ArtifactRootArg"
  if ($LASTEXITCODE -ne 0) {
    throw "v0.210 selection command panel review pack creation failed with exit code $LASTEXITCODE."
  }
} finally {
  Remove-Item Env:\SALTO_CONTACT_SHEET_PYTHON -ErrorAction SilentlyContinue
}
