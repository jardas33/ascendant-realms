param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$V0166ExeName = "AscendantRealmsGodotSalto-v0166.exe"
$ExePath = Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\$V0166ExeName"
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0166"
$WorkerSourcePath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0148\local-worker-slot\worker_billboard_static_v0147_trimmed_1024.png"
$WorkerMetadataPath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0148\local-worker-slot\worker_billboard_static_v0147_trimmed_1024.metadata.json"
$BarracksSourcePath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0150\local-barracks-material-seam-repair\barrosan_barracks_material_v0149_768_wrapsafe_offset_blend.png"
$BarracksMetadataPath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0150\local-barracks-material-seam-repair\barrosan_barracks_material_v0149_768_wrapsafe_offset_blend.metadata.json"
$MilitiaSourcePath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0155\local-militia-billboard-repair\militia_billboard_static_v0154_trimmed_1024.png"
$MilitiaMetadataPath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0155\local-militia-billboard-repair\militia_billboard_static_v0154_trimmed_1024.metadata.json"
$MissingMilitiaSourcePath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0164\missing-militia-source\militia_billboard_static_v0154_trimmed_1024.png"
$WorkerExpectedSha = "a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc"
$BarracksExpectedSha = "58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f"
$MilitiaExpectedSha = "c25349f00c422a0b3c9d5862027351bd70008e9314d4e3cd4001676e914321cb"
$MismatchSha = "0000000000000000000000000000000000000000000000000000000000000000"

Set-Location $RepoRoot

$env:GODOT_EXPORT_EXE_NAME = $V0166ExeName
$env:GODOT_PACKAGE_EXE_PATH = $ExePath
& (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
& (Join-Path $PSScriptRoot "packageGodotWindows.ps1")

foreach ($path in @($ExePath, $WorkerSourcePath, $WorkerMetadataPath, $BarracksSourcePath, $BarracksMetadataPath, $MilitiaSourcePath, $MilitiaMetadataPath)) {
  if (-not (Test-Path -LiteralPath $path)) {
    throw "Missing required v0.166 three-slot visual-coherence path: $path"
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

function Reset-SafeDirectory {
  param(
    [Parameter(Mandatory = $true)][string]$Path,
    [Parameter(Mandatory = $true)][string]$Parent
  )
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

function Invoke-GodotScenario {
  param(
    [Parameter(Mandatory = $true)][string]$ScenarioRoot,
    [Parameter(Mandatory = $true)][string[]]$ScenarioArgs,
    [Parameter(Mandatory = $true)][string[]]$ExpectedFiles
  )
  New-Item -ItemType Directory -Force -Path $ScenarioRoot | Out-Null
  $ArtifactArg = $ScenarioRoot.Replace("\", "/")
  $ArgumentList = $ScenarioArgs + @("--artifact-root=$ArtifactArg")
  $Process = Start-Process -FilePath $ExePath -ArgumentList (ConvertTo-ProcessArgumentString $ArgumentList) -Wait -PassThru -WindowStyle Hidden
  $GodotExitCode = if ($null -eq $Process.ExitCode) { 0 } else { $Process.ExitCode }
  if ($GodotExitCode -ne 0) {
    throw "Godot v0.166 scenario '$ScenarioRoot' exited with code $GodotExitCode."
  }
  foreach ($fileName in $ExpectedFiles) {
    if (-not (Test-Path -LiteralPath (Join-Path $ScenarioRoot $fileName))) {
      throw "Missing expected artifact '$fileName' for scenario '$ScenarioRoot'."
    }
  }
}

function Worker-ArtArgs {
  return @(
    "--worker-art-opt-in",
    "--worker-art-source=$($WorkerSourcePath.Replace('\', '/'))",
    "--worker-art-metadata=$($WorkerMetadataPath.Replace('\', '/'))",
    "--worker-art-expected-sha256=$WorkerExpectedSha",
    "--worker-art-scale=1.00"
  )
}

function Barracks-ArtArgs {
  return @(
    "--barracks-material-opt-in",
    "--barracks-material-source=$($BarracksSourcePath.Replace('\', '/'))",
    "--barracks-material-metadata=$($BarracksMetadataPath.Replace('\', '/'))",
    "--barracks-material-expected-sha256=$BarracksExpectedSha"
  )
}

function Militia-ArtArgs {
  param(
    [string]$Source = $MilitiaSourcePath,
    [string]$Expected = $MilitiaExpectedSha,
    [string]$FallbackMode = "none"
  )
  return @(
    "--militia-art-opt-in",
    "--militia-art-source=$($Source.Replace('\', '/'))",
    "--militia-art-metadata=$($MilitiaMetadataPath.Replace('\', '/'))",
    "--militia-art-expected-sha256=$Expected",
    "--militia-art-scale=1.00",
    "--militia-art-fallback-mode=$FallbackMode"
  )
}

function Review-ArtArgs {
  return @(
    "--experimental-review-mode-label=Experimental opt-in art: Worker + Barracks + Militia",
    "--salto-three-slot-review-framing",
    "--worker-art-scale=1.15",
    "--militia-art-scale=1.12"
  )
}

function Invoke-V0165Tool {
  param([Parameter(Mandatory = $true)][string]$Command)
  node "tools/godot/saltoThreeSlotVisualHardeningTool.mjs" $Command "--artifact-root=$($ArtifactRoot.Replace('\', '/'))"
  if ($LASTEXITCODE -ne 0) {
    throw "v0.166 reused three-slot visual-hardening tool '$Command' failed with exit code $LASTEXITCODE."
  }
}

$ValidationRoot = Join-Path $ArtifactRoot "validation"
Reset-SafeDirectory -Path $ValidationRoot -Parent $ArtifactRoot
Invoke-GodotScenario -ScenarioRoot (Join-Path $ValidationRoot "default-procedural") -ScenarioArgs @("--player-slice-validate") -ExpectedFiles @("player-slice-validation-runtime.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $ValidationRoot "worker-only") -ScenarioArgs (@("--player-slice-validate") + (Worker-ArtArgs)) -ExpectedFiles @("player-slice-validation-runtime.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $ValidationRoot "worker-barracks") -ScenarioArgs (@("--player-slice-validate") + (Worker-ArtArgs) + (Barracks-ArtArgs)) -ExpectedFiles @("player-slice-validation-runtime.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $ValidationRoot "worker-barracks-militia") -ScenarioArgs (@("--player-slice-validate") + (Worker-ArtArgs) + (Barracks-ArtArgs) + (Militia-ArtArgs)) -ExpectedFiles @("player-slice-validation-runtime.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $ValidationRoot "militia-missing-art-fallback") -ScenarioArgs (@("--player-slice-validate") + (Worker-ArtArgs) + (Barracks-ArtArgs) + (Militia-ArtArgs -Source $MissingMilitiaSourcePath -FallbackMode "missing")) -ExpectedFiles @("player-slice-validation-runtime.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $ValidationRoot "militia-hash-mismatch-fallback") -ScenarioArgs (@("--player-slice-validate") + (Worker-ArtArgs) + (Barracks-ArtArgs) + (Militia-ArtArgs -Expected $MismatchSha -FallbackMode "hash-mismatch")) -ExpectedFiles @("player-slice-validation-runtime.json")

$CaptureRoot = Join-Path $ArtifactRoot "capture"
Reset-SafeDirectory -Path $CaptureRoot -Parent $ArtifactRoot
Invoke-GodotScenario -ScenarioRoot (Join-Path $CaptureRoot "default-procedural") -ScenarioArgs @("--player-slice-capture") -ExpectedFiles @("screenshot-runtime-manifest.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $CaptureRoot "worker-only") -ScenarioArgs (@("--player-slice-capture") + (Worker-ArtArgs)) -ExpectedFiles @("screenshot-runtime-manifest.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $CaptureRoot "worker-barracks") -ScenarioArgs (@("--player-slice-capture") + (Worker-ArtArgs) + (Barracks-ArtArgs)) -ExpectedFiles @("screenshot-runtime-manifest.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $CaptureRoot "worker-barracks-militia") -ScenarioArgs (@("--player-slice-capture") + (Worker-ArtArgs) + (Barracks-ArtArgs) + (Militia-ArtArgs)) -ExpectedFiles @("screenshot-runtime-manifest.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $CaptureRoot "militia-missing-art-fallback") -ScenarioArgs (@("--player-slice-capture") + (Worker-ArtArgs) + (Barracks-ArtArgs) + (Militia-ArtArgs -Source $MissingMilitiaSourcePath -FallbackMode "missing")) -ExpectedFiles @("screenshot-runtime-manifest.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $CaptureRoot "militia-hash-mismatch-fallback") -ScenarioArgs (@("--player-slice-capture") + (Worker-ArtArgs) + (Barracks-ArtArgs) + (Militia-ArtArgs -Expected $MismatchSha -FallbackMode "hash-mismatch")) -ExpectedFiles @("screenshot-runtime-manifest.json")

$ReviewRoot = Join-Path $ArtifactRoot "review"
Reset-SafeDirectory -Path $ReviewRoot -Parent $ArtifactRoot
Invoke-GodotScenario -ScenarioRoot (Join-Path $ReviewRoot "worker-barracks-militia") -ScenarioArgs (@("--player-slice-capture") + (Worker-ArtArgs) + (Barracks-ArtArgs) + (Militia-ArtArgs) + (Review-ArtArgs)) -ExpectedFiles @("screenshot-runtime-manifest.json")

$BenchmarkRoot = Join-Path $ArtifactRoot "benchmark"
Reset-SafeDirectory -Path $BenchmarkRoot -Parent $ArtifactRoot
Invoke-GodotScenario -ScenarioRoot (Join-Path $BenchmarkRoot "procedural-baseline") -ScenarioArgs @("--worker-art-opt-in-benchmark") -ExpectedFiles @("worker-art-opt-in-benchmark-runtime.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $BenchmarkRoot "worker-only") -ScenarioArgs (@("--worker-art-opt-in-benchmark") + (Worker-ArtArgs)) -ExpectedFiles @("worker-art-opt-in-benchmark-runtime.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $BenchmarkRoot "worker-barracks") -ScenarioArgs (@("--worker-art-opt-in-benchmark") + (Worker-ArtArgs) + (Barracks-ArtArgs)) -ExpectedFiles @("worker-art-opt-in-benchmark-runtime.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $BenchmarkRoot "worker-barracks-militia") -ScenarioArgs (@("--worker-art-opt-in-benchmark") + (Worker-ArtArgs) + (Barracks-ArtArgs) + (Militia-ArtArgs)) -ExpectedFiles @("worker-art-opt-in-benchmark-runtime.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $BenchmarkRoot "militia-missing-art-fallback") -ScenarioArgs (@("--worker-art-opt-in-benchmark") + (Worker-ArtArgs) + (Barracks-ArtArgs) + (Militia-ArtArgs -Source $MissingMilitiaSourcePath -FallbackMode "missing")) -ExpectedFiles @("worker-art-opt-in-benchmark-runtime.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $BenchmarkRoot "militia-hash-mismatch-fallback") -ScenarioArgs (@("--worker-art-opt-in-benchmark") + (Worker-ArtArgs) + (Barracks-ArtArgs) + (Militia-ArtArgs -Expected $MismatchSha -FallbackMode "hash-mismatch")) -ExpectedFiles @("worker-art-opt-in-benchmark-runtime.json")

$RealInputRoot = Join-Path $ArtifactRoot "real-input"
Reset-SafeDirectory -Path $RealInputRoot -Parent $ArtifactRoot
Invoke-GodotScenario -ScenarioRoot (Join-Path $RealInputRoot "worker-barracks-militia-post-mine-flow") -ScenarioArgs (@("--post-mine-flow-validate") + (Worker-ArtArgs) + (Barracks-ArtArgs) + (Militia-ArtArgs)) -ExpectedFiles @("headed-post-mine-flow-smoke.json", "barracks-restoration-proof.json", "militia-recruit-proof.json", "lume-restore-proof.json", "screenshot-manifest.json")

Invoke-V0165Tool -Command "scale-aspect"
Invoke-V0165Tool -Command "duplicate"
Invoke-V0165Tool -Command "barracks"
Invoke-V0165Tool -Command "capture"
Invoke-V0165Tool -Command "benchmark"
Invoke-V0165Tool -Command "boundary"

node "tools/godot/saltoThreeSlotVisualCoherenceTool.mjs" report "--artifact-root=$($ArtifactRoot.Replace('\', '/'))"
if ($LASTEXITCODE -ne 0) {
  throw "v0.166 three-slot visual-coherence report failed with exit code $LASTEXITCODE."
}

Write-Output "PASS_V0166_THREE_SLOT_VISUAL_COHERENCE_AUTOMATION_READY"
