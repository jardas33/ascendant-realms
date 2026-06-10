param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ExePath = Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe"
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0195"
$CaptureRoot = Join-Path $ArtifactRoot "capture"
$BeforeRoot = Join-Path $ArtifactRoot "before-v0194-authoritative"
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
    throw "Missing expected artifact '$fileName' for v0.195 capture scenario '$ScenarioRoot'."
  }
}

if (-not (Test-Path -LiteralPath (Join-Path $BeforeRoot "capture\shell-v2-topology-repair\screenshot-runtime-manifest.json"))) {
  $V0194CaptureRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0194\capture\shell-v2-topology-repair"
  if (-not (Test-Path -LiteralPath $V0194CaptureRoot)) {
    throw "Missing retained v0.194 shell-v2 topology capture baseline: $V0194CaptureRoot"
  }
  New-Item -ItemType Directory -Force -Path (Join-Path $BeforeRoot "capture") | Out-Null
  Copy-Item -LiteralPath $V0194CaptureRoot -Destination (Join-Path $BeforeRoot "capture\shell-v2-topology-repair") -Recurse -Force
}

Reset-SafeDirectory -Path $CaptureRoot -Parent $ArtifactRoot
$env:GODOT_SALTO_EXE_PATH = $ExePath
try {
  & (Join-Path $PSScriptRoot "launchGodotSaltoShellV2ScopedMaterialRecoveryWindows.ps1") -Wait "--player-slice-capture" "--artifact-root=$((Join-Path $CaptureRoot 'shell-v2-scoped-material-recovery').Replace('\', '/'))"
  Assert-ExpectedFiles -ScenarioRoot (Join-Path $CaptureRoot "shell-v2-scoped-material-recovery") -ExpectedFiles @("screenshot-runtime-manifest.json")
} finally {
  Remove-Item Env:\GODOT_SALTO_EXE_PATH -ErrorAction SilentlyContinue
}

node "tools/godot/saltoShellV2ScopedMaterialRecoveryTool.mjs" capture "--artifact-root=$ArtifactRootArg"
if ($LASTEXITCODE -ne 0) {
  throw "v0.195 shell v2 scoped material recovery capture report failed with exit code $LASTEXITCODE."
}
