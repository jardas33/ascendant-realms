param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ExePath = Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe"
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0195"
$ArtifactRootArg = $ArtifactRoot.Replace("\", "/")
$BeforeRoot = Join-Path $ArtifactRoot "before-v0194-authoritative"

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
    throw "Missing expected artifact '$fileName' for v0.195 scenario '$ScenarioRoot'."
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
  New-Item -ItemType Directory -Force -Path $ScenarioRoot | Out-Null
  $ScenarioRootArg = $ScenarioRoot.Replace("\", "/")
  $ArgumentList = @("--player-slice-validate", "--artifact-root=$ScenarioRootArg")
  $process = Start-Process -FilePath $ExePath -ArgumentList (ConvertTo-ProcessArgumentString $ArgumentList) -Wait -PassThru -WindowStyle Hidden
  $GodotExitCode = if ($null -eq $process.ExitCode) { 0 } else { $process.ExitCode }
  if ($GodotExitCode -ne 0) {
    throw "Default procedural validation exited with code $GodotExitCode."
  }
  Assert-ExpectedFiles -ScenarioRoot $ScenarioRoot -ExpectedFiles @("player-slice-validation-runtime.json")
}

function Invoke-V0195Tool {
  param([Parameter(Mandatory = $true)][string]$Command)
  node "tools/godot/saltoShellV2ScopedMaterialRecoveryTool.mjs" $Command "--artifact-root=$ArtifactRootArg"
  if ($LASTEXITCODE -ne 0) {
    throw "v0.195 shell v2 scoped material recovery tool '$Command' failed with exit code $LASTEXITCODE."
  }
}

function Copy-DirectoryIfPresent {
  param([Parameter(Mandatory = $true)][string]$Source, [Parameter(Mandatory = $true)][string]$Destination)
  if (-not (Test-Path -LiteralPath $Source)) {
    throw "Missing required authoritative v0.194 artifact directory: $Source"
  }
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Destination) | Out-Null
  Copy-Item -LiteralPath $Source -Destination $Destination -Recurse -Force
}

function Preserve-BeforeV0194Evidence {
  $TempBefore = Join-Path $env:TEMP "ascendant-realms-v0195-before-v0194-authoritative"
  if (Test-Path -LiteralPath $TempBefore) {
    Remove-Item -LiteralPath $TempBefore -Recurse -Force
  }
  if (Test-Path -LiteralPath $BeforeRoot) {
    Copy-Item -LiteralPath $BeforeRoot -Destination $TempBefore -Recurse -Force
  }

  Reset-SafeDirectory -Path $ArtifactRoot -Parent (Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto")

  if (Test-Path -LiteralPath $TempBefore) {
    Copy-Item -LiteralPath $TempBefore -Destination $BeforeRoot -Recurse -Force
    return
  }

  $V0194Root = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0194"
  Copy-DirectoryIfPresent -Source (Join-Path $V0194Root "validation\v2-topology-repair") -Destination (Join-Path $BeforeRoot "validation\v2-topology-repair")
  Copy-DirectoryIfPresent -Source (Join-Path $V0194Root "benchmark\v2-topology-repair") -Destination (Join-Path $BeforeRoot "benchmark\v2-topology-repair")
  $V0194CaptureRoot = Join-Path $V0194Root "capture\shell-v2-topology-repair"
  if (Test-Path -LiteralPath $V0194CaptureRoot) {
    Copy-DirectoryIfPresent -Source $V0194CaptureRoot -Destination (Join-Path $BeforeRoot "capture\shell-v2-topology-repair")
  }
}

Preserve-BeforeV0194Evidence

$ValidationRoot = Join-Path $ArtifactRoot "validation"
Reset-SafeDirectory -Path $ValidationRoot -Parent $ArtifactRoot
$env:GODOT_SALTO_EXE_PATH = $ExePath
try {
  Invoke-DefaultValidationScenario -ScenarioRoot (Join-Path $ValidationRoot "default-procedural")
  & (Join-Path $PSScriptRoot "launchGodotSaltoRiverbankBridgeApproachWindows.ps1") -Wait "--player-slice-validate" "--artifact-root=$((Join-Path $ValidationRoot 'l1-legacy-riverbank-bridge-approach').Replace('\', '/'))"
  Assert-ExpectedFiles -ScenarioRoot (Join-Path $ValidationRoot "l1-legacy-riverbank-bridge-approach") -ExpectedFiles @("player-slice-validation-runtime.json")
  & (Join-Path $PSScriptRoot "launchGodotSaltoShellV2ScopedMaterialRecoveryWindows.ps1") -Wait "--player-slice-validate" "--artifact-root=$((Join-Path $ValidationRoot 'v2-scoped-material-recovery').Replace('\', '/'))"
  Assert-ExpectedFiles -ScenarioRoot (Join-Path $ValidationRoot "v2-scoped-material-recovery") -ExpectedFiles @("player-slice-validation-runtime.json")
} finally {
  Remove-Item Env:\GODOT_SALTO_EXE_PATH -ErrorAction SilentlyContinue
}
Invoke-V0195Tool -Command "validation"

$BenchmarkRoot = Join-Path $ArtifactRoot "benchmark"
Reset-SafeDirectory -Path $BenchmarkRoot -Parent $ArtifactRoot
$env:GODOT_SALTO_EXE_PATH = $ExePath
try {
  & (Join-Path $PSScriptRoot "launchGodotSaltoShellV2ScopedMaterialRecoveryWindows.ps1") -Wait "--worker-art-opt-in-benchmark" "--artifact-root=$((Join-Path $BenchmarkRoot 'v2-scoped-material-recovery').Replace('\', '/'))"
  Assert-ExpectedFiles -ScenarioRoot (Join-Path $BenchmarkRoot "v2-scoped-material-recovery") -ExpectedFiles @("worker-art-opt-in-benchmark-runtime.json")
} finally {
  Remove-Item Env:\GODOT_SALTO_EXE_PATH -ErrorAction SilentlyContinue
}
Invoke-V0195Tool -Command "benchmark"
Invoke-V0195Tool -Command "boundary"

node "scripts/cleanupSaltoExperimentalArtifacts.mjs" "--output-root=$((Join-Path $ArtifactRoot 'cleanup-dry-run').Replace('\', '/'))"
if ($LASTEXITCODE -ne 0) {
  throw "v0.195 cleanup dry-run failed with exit code $LASTEXITCODE."
}

node "scripts/validateSaltoExperimentalArtifactRetention.mjs" "--output-root=$((Join-Path $ArtifactRoot 'artifact-retention').Replace('\', '/'))"
if ($LASTEXITCODE -ne 0) {
  throw "v0.195 artifact retention validation failed with exit code $LASTEXITCODE."
}

Write-Output "PASS_V0195_SALTO_SHELL_V2_SCOPED_MATERIAL_RECOVERY_VALIDATION_READY"
