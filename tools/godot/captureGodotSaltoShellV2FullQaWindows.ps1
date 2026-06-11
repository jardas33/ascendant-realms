param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ExePath = Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe"
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0206"
$CaptureRoot = Join-Path $ArtifactRoot "capture"
$RealInputRoot = Join-Path $ArtifactRoot "real-input"
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
  throw "Missing exported Godot executable for v0.206 capture: $Path"
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
    throw "Missing expected artifact '$fileName' for v0.206 capture scenario '$ScenarioRoot'."
  }
}

Reset-SafeDirectory -Path $CaptureRoot -Parent $ArtifactRoot
Reset-SafeDirectory -Path $RealInputRoot -Parent $ArtifactRoot
$ExePath = Wait-ForExecutable -Path $ExePath
$env:GODOT_SALTO_EXE_PATH = $ExePath
try {
  & (Join-Path $PSScriptRoot "launchGodotSaltoShellV2GroundingLightingWindows.ps1") -Wait "--player-slice-capture" "--artifact-root=$((Join-Path $CaptureRoot 'legacy-pre-v0203-shell-v2').Replace('\', '/'))"
  Assert-ExpectedFiles -ScenarioRoot (Join-Path $CaptureRoot "legacy-pre-v0203-shell-v2") -ExpectedFiles @("screenshot-runtime-manifest.json")

  & (Join-Path $PSScriptRoot "launchGodotSaltoShellV2GroundingPropsWindows.ps1") -Wait "--player-slice-capture" "--artifact-root=$((Join-Path $CaptureRoot 'final-shell-v2-grounding-props').Replace('\', '/'))"
  Assert-ExpectedFiles -ScenarioRoot (Join-Path $CaptureRoot "final-shell-v2-grounding-props") -ExpectedFiles @("screenshot-runtime-manifest.json")

  & (Join-Path $PSScriptRoot "launchGodotSaltoShellV2GroundingPropsWindows.ps1") -Wait "--player-slice-capture" "--artifact-root=$((Join-Path $CaptureRoot 'missing-structure-material-fallback').Replace('\', '/'))" "--structure-finish-material-source=$($MissingSourcePath.Replace('\', '/'))" "--structure-finish-material-fallback-mode=missing"
  Assert-ExpectedFiles -ScenarioRoot (Join-Path $CaptureRoot "missing-structure-material-fallback") -ExpectedFiles @("screenshot-runtime-manifest.json")

  & (Join-Path $PSScriptRoot "launchGodotSaltoShellV2GroundingPropsWindows.ps1") -Wait "--player-slice-capture" "--artifact-root=$((Join-Path $CaptureRoot 'hash-mismatch-structure-material-fallback').Replace('\', '/'))" "--structure-finish-material-expected-sha256=$MismatchSha" "--structure-finish-material-fallback-mode=hash-mismatch"
  Assert-ExpectedFiles -ScenarioRoot (Join-Path $CaptureRoot "hash-mismatch-structure-material-fallback") -ExpectedFiles @("screenshot-runtime-manifest.json")

  & (Join-Path $PSScriptRoot "launchGodotSaltoShellV2GroundingPropsWindows.ps1") -Wait "--post-mine-flow-validate" "--artifact-root=$((Join-Path $RealInputRoot 'post-mine-flow').Replace('\', '/'))"
  Assert-ExpectedFiles -ScenarioRoot (Join-Path $RealInputRoot "post-mine-flow") -ExpectedFiles @("headed-post-mine-flow-smoke.json", "barracks-restoration-proof.json", "militia-recruit-proof.json", "combat-onset-proof.json", "lume-restore-proof.json", "screenshot-manifest.json")

  & (Join-Path $PSScriptRoot "launchGodotSaltoShellV2GroundingPropsWindows.ps1") -Wait "--triple-natural-playthrough" "--artifact-root=$((Join-Path $RealInputRoot 'restart-replay').Replace('\', '/'))"
  Assert-ExpectedFiles -ScenarioRoot (Join-Path $RealInputRoot "restart-replay") -ExpectedFiles @("triple-playthrough-report.json", "recovery-case-report.json", "restart-integrity-report.json", "no-softlock-proof.json", "no-shortcut-proof.json", "screenshot-manifest.json")
} finally {
  Remove-Item Env:\GODOT_SALTO_EXE_PATH -ErrorAction SilentlyContinue
}

$BundledPython = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
if (Test-Path -LiteralPath $BundledPython) {
  $env:SALTO_CONTACT_SHEET_PYTHON = $BundledPython
}

node "tools/godot/saltoShellV2FullQaTool.mjs" capture "--artifact-root=$ArtifactRootArg"
if ($LASTEXITCODE -ne 0) {
  throw "v0.206 shell-v2 full QA capture report failed with exit code $LASTEXITCODE."
}

Remove-Item Env:\SALTO_CONTACT_SHEET_PYTHON -ErrorAction SilentlyContinue
