param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0215"
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
  param([Parameter(Mandatory = $true)][string]$Path, [Parameter(Mandatory = $true)][string]$ExpectedStatus)
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
    Start-Sleep -Seconds 6
    Assert-PassManifest -Path $ManifestPath -ExpectedStatus $ExpectedStatus
    Write-Output "Packaged Godot returned nonzero after writing $ExpectedStatus; continuing from manifest gate."
    return
  }
  Start-Sleep -Seconds 6
  Assert-PassManifest -Path $ManifestPath -ExpectedStatus $ExpectedStatus
}

function Invoke-RealInputPass {
  param([Parameter(Mandatory = $true)][string[]]$Args, [Parameter(Mandatory = $true)][string]$ScenarioRoot, [Parameter(Mandatory = $true)][string[]]$ExpectedFiles)
  & (Join-Path $PSScriptRoot "launchGodotSaltoPresentationRebootWindows.ps1") -Wait @Args
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
    throw "Missing expected artifact '$fileName' for v0.215 real-input scenario '$ScenarioRoot'."
  }
}

& (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
& (Join-Path $PSScriptRoot "packageGodotWindows.ps1")

if (-not (Test-Path -LiteralPath (Join-Path $RepoRoot "artifacts\manual-review\v0213-full-ui-qa\02_initial.png"))) {
  & (Join-Path $PSScriptRoot "captureGodotSaltoFullUiQaWindows.ps1")
}

Reset-SafeDirectory -Path $CaptureRoot -Parent $ArtifactRoot
Reset-SafeDirectory -Path $RealInputRoot -Parent $ArtifactRoot

$RebootRoot = Join-Path $CaptureRoot "presentation-reboot"
$FallbackRoot = Join-Path $CaptureRoot "procedural-fallback"

Invoke-GodotPass -ScriptPath (Join-Path $PSScriptRoot "launchGodotSaltoPresentationRebootWindows.ps1") -Args @("--player-slice-capture", "--artifact-root=$($RebootRoot.Replace('\', '/'))") -ManifestPath (Join-Path $RebootRoot "screenshot-runtime-manifest.json") -ExpectedStatus "PASS_PLAYER_SLICE_CAPTURE"
Invoke-GodotPass -ScriptPath (Join-Path $PSScriptRoot "launchGodotSaltoPresentationRebootWindows.ps1") -Args @("--player-slice-capture", "--salto-ui-shell-force-fallback", "--artifact-root=$($FallbackRoot.Replace('\', '/'))") -ManifestPath (Join-Path $FallbackRoot "screenshot-runtime-manifest.json") -ExpectedStatus "PASS_PLAYER_SLICE_CAPTURE"

Invoke-RealInputPass -Args @("--post-mine-flow-validate", "--artifact-root=$((Join-Path $RealInputRoot 'post-mine-flow').Replace('\', '/'))") -ScenarioRoot (Join-Path $RealInputRoot "post-mine-flow") -ExpectedFiles @("headed-post-mine-flow-smoke.json", "barracks-restoration-proof.json", "militia-recruit-proof.json", "combat-onset-proof.json", "lume-restore-proof.json", "screenshot-manifest.json")

$BundledPython = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
if (Test-Path -LiteralPath $BundledPython) {
  $env:SALTO_CONTACT_SHEET_PYTHON = $BundledPython
}

try {
  node "tools/godot/saltoPresentationRebootTool.mjs" capture "--artifact-root=$ArtifactRootArg"
  if ($LASTEXITCODE -ne 0) {
    throw "v0.215 presentation reboot capture report failed with exit code $LASTEXITCODE."
  }
} finally {
  Remove-Item Env:\SALTO_CONTACT_SHEET_PYTHON -ErrorAction SilentlyContinue
}

Write-Output "PASS_V0215_PRESENTATION_REBOOT_CAPTURE_READY"
