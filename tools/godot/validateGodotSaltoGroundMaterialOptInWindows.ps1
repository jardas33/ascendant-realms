param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ExePath = if ($env:GODOT_SALTO_EXE_PATH) {
  $env:GODOT_SALTO_EXE_PATH
} else {
  Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe"
}
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0177"
$ArtifactRootArg = $ArtifactRoot.Replace("\", "/")
$WorkerSourcePath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0148\local-worker-slot\worker_billboard_static_v0147_trimmed_1024.png"
$WorkerMetadataPath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0148\local-worker-slot\worker_billboard_static_v0147_trimmed_1024.metadata.json"
$BarracksSourcePath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0150\local-barracks-material-seam-repair\barrosan_barracks_material_v0149_768_wrapsafe_offset_blend.png"
$BarracksMetadataPath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0150\local-barracks-material-seam-repair\barrosan_barracks_material_v0149_768_wrapsafe_offset_blend.metadata.json"
$MilitiaSourcePath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0155\local-militia-billboard-repair\militia_billboard_static_v0154_trimmed_1024.png"
$MilitiaMetadataPath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0155\local-militia-billboard-repair\militia_billboard_static_v0154_trimmed_1024.metadata.json"
$AsterSourcePath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0152\local-aster-billboard-repair\aster_billboard_static_v0151_trimmed_1024.png"
$AsterMetadataPath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0152\local-aster-billboard-repair\aster_billboard_static_v0151_trimmed_1024.metadata.json"
$AshenSourcePath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0157\local-ashen-raider-restrained-replacement\ashen_raider_billboard_static_v0157_restrained_trimmed_1024.png"
$AshenMetadataPath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0157\local-ashen-raider-restrained-replacement\ashen_raider_billboard_static_v0157_restrained_trimmed_1024.metadata.json"
$GroundSourcePath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0175\local-ground-material-slot\barrosan_foothold_ground_material_v0175_1024.png"
$GroundMetadataPath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0175\local-ground-material-slot\barrosan_foothold_ground_material_v0175_1024.metadata.json"
$WorkerExpectedSha = "a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc"
$BarracksExpectedSha = "58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f"
$MilitiaExpectedSha = "c25349f00c422a0b3c9d5862027351bd70008e9314d4e3cd4001676e914321cb"
$AsterExpectedSha = "b256f96f762187c05d68f2c2de62bedec0248896210767e98cb8f210dac2829a"
$AshenExpectedSha = "8eb011f56d5cd56cf6ef0a843d2a5899e27aa13e203cc44517ed4a0c55c631c8"
$GroundExpectedSha = "818b7743fbf192fe95dd95a0fbadb59ea92b1cb36c420dac5526c0f4d1af18a8"
$WrongGroundSha = "0000000000000000000000000000000000000000000000000000000000000000"

Set-Location $RepoRoot

& (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
& (Join-Path $PSScriptRoot "packageGodotWindows.ps1")

foreach ($path in @($ExePath, $WorkerSourcePath, $WorkerMetadataPath, $BarracksSourcePath, $BarracksMetadataPath, $MilitiaSourcePath, $MilitiaMetadataPath, $AsterSourcePath, $AsterMetadataPath, $AshenSourcePath, $AshenMetadataPath, $GroundSourcePath, $GroundMetadataPath)) {
  if (-not (Test-Path -LiteralPath $path)) {
    throw "Missing required v0.177 ground material validation path: $path"
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

function Invoke-GodotScenario {
  param([string]$ScenarioRoot, [string[]]$ScenarioArgs, [string[]]$ExpectedFiles)
  New-Item -ItemType Directory -Force -Path $ScenarioRoot | Out-Null
  $ScenarioRootArg = $ScenarioRoot.Replace("\", "/")
  $ArgumentList = $ScenarioArgs + @("--artifact-root=$ScenarioRootArg")
  $process = Start-Process -FilePath $ExePath -ArgumentList (ConvertTo-ProcessArgumentString $ArgumentList) -Wait -PassThru -WindowStyle Hidden
  $GodotExitCode = if ($null -eq $process.ExitCode) { 0 } else { $process.ExitCode }
  if ($GodotExitCode -ne 0) {
    throw "Godot v0.177 scenario '$ScenarioRoot' exited with code $GodotExitCode."
  }
  foreach ($fileName in $ExpectedFiles) {
    if (-not (Test-Path -LiteralPath (Join-Path $ScenarioRoot $fileName))) {
      throw "Missing expected artifact '$fileName' for scenario '$ScenarioRoot'."
    }
  }
}

function Worker-ArtArgs { return @("--worker-art-opt-in", "--worker-art-source=$($WorkerSourcePath.Replace('\', '/'))", "--worker-art-metadata=$($WorkerMetadataPath.Replace('\', '/'))", "--worker-art-expected-sha256=$WorkerExpectedSha", "--worker-art-scale=1.10") }
function Barracks-ArtArgs { return @("--barracks-material-opt-in", "--barracks-material-source=$($BarracksSourcePath.Replace('\', '/'))", "--barracks-material-metadata=$($BarracksMetadataPath.Replace('\', '/'))", "--barracks-material-expected-sha256=$BarracksExpectedSha") }
function Militia-ArtArgs { return @("--militia-art-opt-in", "--militia-art-source=$($MilitiaSourcePath.Replace('\', '/'))", "--militia-art-metadata=$($MilitiaMetadataPath.Replace('\', '/'))", "--militia-art-expected-sha256=$MilitiaExpectedSha", "--militia-art-scale=1.08") }
function Aster-ArtArgs { return @("--aster-art-opt-in", "--aster-art-source=$($AsterSourcePath.Replace('\', '/'))", "--aster-art-metadata=$($AsterMetadataPath.Replace('\', '/'))", "--aster-art-expected-sha256=$AsterExpectedSha", "--aster-art-scale=1.16") }
function Ashen-ArtArgs { return @("--ashen-art-opt-in", "--ashen-art-source=$($AshenSourcePath.Replace('\', '/'))", "--ashen-art-metadata=$($AshenMetadataPath.Replace('\', '/'))", "--ashen-art-expected-sha256=$AshenExpectedSha", "--ashen-art-scale=1.08") }
function Five-SlotArgs { return (Worker-ArtArgs) + (Barracks-ArtArgs) + (Militia-ArtArgs) + (Aster-ArtArgs) + (Ashen-ArtArgs) }
function Environment-FoundationArgs { return @("--player-slice", "--experimental-review-mode-label=Experimental opt-in art: 5 slots + E0 foundation", "--salto-five-slot-review-framing", "--salto-environment-foundation-review") }
function Environment-GroundMaterialArgs { return @("--player-slice", "--experimental-review-mode-label=Experimental opt-in art: 5 slots + Barrosan foothold ground", "--salto-five-slot-review-framing", "--salto-environment-foundation-review") }
function Environment-GroundMissingArgs { return @("--player-slice", "--experimental-review-mode-label=Experimental opt-in art: 5 slots + ground fallback missing", "--salto-five-slot-review-framing", "--salto-environment-foundation-review") }
function Environment-GroundMismatchArgs { return @("--player-slice", "--experimental-review-mode-label=Experimental opt-in art: 5 slots + ground fallback hash mismatch", "--salto-five-slot-review-framing", "--salto-environment-foundation-review") }
function Ground-MaterialArgs { return @("--ground-material-opt-in", "--ground-material-source=$($GroundSourcePath.Replace('\', '/'))", "--ground-material-metadata=$($GroundMetadataPath.Replace('\', '/'))", "--ground-material-expected-sha256=$GroundExpectedSha", "--ground-material-uv-scale=0.72") }
function Ground-MissingArgs { return @("--ground-material-opt-in", "--ground-material-fallback-mode=missing", "--ground-material-metadata=$($GroundMetadataPath.Replace('\', '/'))", "--ground-material-expected-sha256=$GroundExpectedSha", "--ground-material-uv-scale=0.72") }
function Ground-MismatchArgs { return @("--ground-material-opt-in", "--ground-material-source=$($GroundSourcePath.Replace('\', '/'))", "--ground-material-metadata=$($GroundMetadataPath.Replace('\', '/'))", "--ground-material-expected-sha256=$WrongGroundSha", "--ground-material-uv-scale=0.72") }

function Invoke-V0177Tool {
  param([Parameter(Mandatory = $true)][string]$Command)
  node "tools/godot/saltoGroundMaterialOptInTool.mjs" $Command "--artifact-root=$ArtifactRootArg"
  if ($LASTEXITCODE -ne 0) {
    throw "v0.177 ground material opt-in tool '$Command' failed with exit code $LASTEXITCODE."
  }
}

Reset-SafeDirectory -Path $ArtifactRoot -Parent (Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto")

$ValidationRoot = Join-Path $ArtifactRoot "validation"
Reset-SafeDirectory -Path $ValidationRoot -Parent $ArtifactRoot
Invoke-GodotScenario -ScenarioRoot (Join-Path $ValidationRoot "default-procedural") -ScenarioArgs @("--player-slice", "--player-slice-validate") -ExpectedFiles @("player-slice-validation-runtime.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $ValidationRoot "e0-environment-foundation-baseline") -ScenarioArgs (@("--player-slice-validate") + (Environment-FoundationArgs) + (Five-SlotArgs)) -ExpectedFiles @("player-slice-validation-runtime.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $ValidationRoot "e1-ground-material-opt-in") -ScenarioArgs (@("--player-slice-validate") + (Environment-GroundMaterialArgs) + (Five-SlotArgs) + (Ground-MaterialArgs)) -ExpectedFiles @("player-slice-validation-runtime.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $ValidationRoot "ground-missing-art-fallback") -ScenarioArgs (@("--player-slice-validate") + (Environment-GroundMissingArgs) + (Five-SlotArgs) + (Ground-MissingArgs)) -ExpectedFiles @("player-slice-validation-runtime.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $ValidationRoot "ground-hash-mismatch-fallback") -ScenarioArgs (@("--player-slice-validate") + (Environment-GroundMismatchArgs) + (Five-SlotArgs) + (Ground-MismatchArgs)) -ExpectedFiles @("player-slice-validation-runtime.json")
Invoke-V0177Tool -Command "validation"

$CaptureRoot = Join-Path $ArtifactRoot "capture"
Reset-SafeDirectory -Path $CaptureRoot -Parent $ArtifactRoot
Invoke-GodotScenario -ScenarioRoot (Join-Path $CaptureRoot "e0-environment-foundation-baseline") -ScenarioArgs (@("--player-slice-capture") + (Environment-FoundationArgs) + (Five-SlotArgs)) -ExpectedFiles @("screenshot-runtime-manifest.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $CaptureRoot "e1-ground-material-opt-in") -ScenarioArgs (@("--player-slice-capture") + (Environment-GroundMaterialArgs) + (Five-SlotArgs) + (Ground-MaterialArgs)) -ExpectedFiles @("screenshot-runtime-manifest.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $CaptureRoot "ground-missing-art-fallback") -ScenarioArgs (@("--player-slice-capture") + (Environment-GroundMissingArgs) + (Five-SlotArgs) + (Ground-MissingArgs)) -ExpectedFiles @("screenshot-runtime-manifest.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $CaptureRoot "ground-hash-mismatch-fallback") -ScenarioArgs (@("--player-slice-capture") + (Environment-GroundMismatchArgs) + (Five-SlotArgs) + (Ground-MismatchArgs)) -ExpectedFiles @("screenshot-runtime-manifest.json")
Invoke-V0177Tool -Command "capture"

$BenchmarkRoot = Join-Path $ArtifactRoot "benchmark"
Reset-SafeDirectory -Path $BenchmarkRoot -Parent $ArtifactRoot
Invoke-GodotScenario -ScenarioRoot (Join-Path $BenchmarkRoot "e0-environment-foundation-baseline") -ScenarioArgs (@("--worker-art-opt-in-benchmark") + (Environment-FoundationArgs) + (Five-SlotArgs)) -ExpectedFiles @("worker-art-opt-in-benchmark-runtime.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $BenchmarkRoot "e1-ground-material-opt-in") -ScenarioArgs (@("--worker-art-opt-in-benchmark") + (Environment-GroundMaterialArgs) + (Five-SlotArgs) + (Ground-MaterialArgs)) -ExpectedFiles @("worker-art-opt-in-benchmark-runtime.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $BenchmarkRoot "ground-missing-art-fallback") -ScenarioArgs (@("--worker-art-opt-in-benchmark") + (Environment-GroundMissingArgs) + (Five-SlotArgs) + (Ground-MissingArgs)) -ExpectedFiles @("worker-art-opt-in-benchmark-runtime.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $BenchmarkRoot "ground-hash-mismatch-fallback") -ScenarioArgs (@("--worker-art-opt-in-benchmark") + (Environment-GroundMismatchArgs) + (Five-SlotArgs) + (Ground-MismatchArgs)) -ExpectedFiles @("worker-art-opt-in-benchmark-runtime.json")
Invoke-V0177Tool -Command "benchmark"

Invoke-V0177Tool -Command "boundary"

node "scripts/cleanupSaltoExperimentalArtifacts.mjs" "--output-root=$((Join-Path $ArtifactRoot 'cleanup-dry-run').Replace('\', '/'))"
if ($LASTEXITCODE -ne 0) {
  throw "v0.177 cleanup dry-run failed with exit code $LASTEXITCODE."
}

node "scripts/validateSaltoExperimentalArtifactRetention.mjs" "--output-root=$((Join-Path $ArtifactRoot 'artifact-retention').Replace('\', '/'))"
if ($LASTEXITCODE -ne 0) {
  throw "v0.177 artifact retention validation failed with exit code $LASTEXITCODE."
}

Write-Output "PASS_V0177_SALTO_GROUND_MATERIAL_OPT_IN_AUTOMATION_READY"
