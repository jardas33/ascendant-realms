param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ExePath = Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe"
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0200"
$CaptureRoot = Join-Path $ArtifactRoot "capture"
$ArtifactRootArg = $ArtifactRoot.Replace("\", "/")

Set-Location $RepoRoot

& (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
& (Join-Path $PSScriptRoot "packageGodotWindows.ps1")

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
  $deadline = (Get-Date).AddSeconds(90)
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
    throw "Missing expected artifact '$fileName' for v0.200 capture scenario '$ScenarioRoot'."
  }
}

Reset-SafeDirectory -Path $CaptureRoot -Parent $ArtifactRoot
$env:GODOT_SALTO_EXE_PATH = $ExePath
try {
  & (Join-Path $PSScriptRoot "launchGodotSaltoShellV2StructureHierarchyWindows.ps1") -Wait "--player-slice-capture" "--artifact-root=$((Join-Path $CaptureRoot 's1-shell-v2-structure-hierarchy').Replace('\', '/'))"
  Assert-ExpectedFiles -ScenarioRoot (Join-Path $CaptureRoot "s1-shell-v2-structure-hierarchy") -ExpectedFiles @("screenshot-runtime-manifest.json")
  & (Join-Path $PSScriptRoot "launchGodotSaltoShellV2GroundingLightingWindows.ps1") -Wait "--player-slice-capture" "--artifact-root=$((Join-Path $CaptureRoot 'g1-shell-v2-grounding-lighting').Replace('\', '/'))"
  Assert-ExpectedFiles -ScenarioRoot (Join-Path $CaptureRoot "g1-shell-v2-grounding-lighting") -ExpectedFiles @("screenshot-runtime-manifest.json")
} finally {
  Remove-Item Env:\GODOT_SALTO_EXE_PATH -ErrorAction SilentlyContinue
}

$BundledPython = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
if (Test-Path -LiteralPath $BundledPython) {
  $env:SALTO_CONTACT_SHEET_PYTHON = $BundledPython
}

node "tools/godot/saltoShellV2GroundingLightingTool.mjs" capture "--artifact-root=$ArtifactRootArg"
if ($LASTEXITCODE -ne 0) {
  throw "v0.200 grounding lighting capture report failed with exit code $LASTEXITCODE."
}

Remove-Item Env:\SALTO_CONTACT_SHEET_PYTHON -ErrorAction SilentlyContinue
