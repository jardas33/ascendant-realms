param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ExePath = Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe"
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0184"
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
$RoadSourcePath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0180\local-road-material-slot\barrosan_foothold_road_material_v0180_1024.png"
$RoadMetadataPath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0180\local-road-material-slot\barrosan_foothold_road_material_v0180_1024.metadata.json"
$WorkerExpectedSha = "a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc"
$BarracksExpectedSha = "58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f"
$MilitiaExpectedSha = "c25349f00c422a0b3c9d5862027351bd70008e9314d4e3cd4001676e914321cb"
$AsterExpectedSha = "b256f96f762187c05d68f2c2de62bedec0248896210767e98cb8f210dac2829a"
$AshenExpectedSha = "8eb011f56d5cd56cf6ef0a843d2a5899e27aa13e203cc44517ed4a0c55c631c8"
$GroundExpectedSha = "818b7743fbf192fe95dd95a0fbadb59ea92b1cb36c420dac5526c0f4d1af18a8"
$RoadExpectedSha = "a64959ef2fd7a509fcaaa969fca3e095d590d563a4f0c578a5e96d1fb04c0e10"

Set-Location $RepoRoot

& (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
& (Join-Path $PSScriptRoot "packageGodotWindows.ps1")

foreach ($path in @($ExePath, $WorkerSourcePath, $WorkerMetadataPath, $BarracksSourcePath, $BarracksMetadataPath, $MilitiaSourcePath, $MilitiaMetadataPath, $AsterSourcePath, $AsterMetadataPath, $AshenSourcePath, $AshenMetadataPath, $GroundSourcePath, $GroundMetadataPath, $RoadSourcePath, $RoadMetadataPath)) {
  if (-not (Test-Path -LiteralPath $path)) {
    throw "Missing required v0.184 environment geometry convergence validation path: $path"
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
    throw "Godot v0.184 scenario '$ScenarioRoot' exited with code $GodotExitCode."
  }
  foreach ($fileName in $ExpectedFiles) {
    if (-not (Test-Path -LiteralPath (Join-Path $ScenarioRoot $fileName))) {
      throw "Missing expected artifact '$fileName' for v0.184 scenario '$ScenarioRoot'."
    }
  }
}

function Worker-ArtArgs { return @("--worker-art-opt-in", "--worker-art-source=$($WorkerSourcePath.Replace('\', '/'))", "--worker-art-metadata=$($WorkerMetadataPath.Replace('\', '/'))", "--worker-art-expected-sha256=$WorkerExpectedSha", "--worker-art-scale=1.10") }
function Barracks-ArtArgs { return @("--barracks-material-opt-in", "--barracks-material-source=$($BarracksSourcePath.Replace('\', '/'))", "--barracks-material-metadata=$($BarracksMetadataPath.Replace('\', '/'))", "--barracks-material-expected-sha256=$BarracksExpectedSha") }
function Militia-ArtArgs { return @("--militia-art-opt-in", "--militia-art-source=$($MilitiaSourcePath.Replace('\', '/'))", "--militia-art-metadata=$($MilitiaMetadataPath.Replace('\', '/'))", "--militia-art-expected-sha256=$MilitiaExpectedSha", "--militia-art-scale=1.08") }
function Aster-ArtArgs { return @("--aster-art-opt-in", "--aster-art-source=$($AsterSourcePath.Replace('\', '/'))", "--aster-art-metadata=$($AsterMetadataPath.Replace('\', '/'))", "--aster-art-expected-sha256=$AsterExpectedSha", "--aster-art-scale=1.16") }
function Ashen-ArtArgs { return @("--ashen-art-opt-in", "--ashen-art-source=$($AshenSourcePath.Replace('\', '/'))", "--ashen-art-metadata=$($AshenMetadataPath.Replace('\', '/'))", "--ashen-art-expected-sha256=$AshenExpectedSha", "--ashen-art-scale=1.08") }
function Five-SlotArgs { return (Worker-ArtArgs) + (Barracks-ArtArgs) + (Militia-ArtArgs) + (Aster-ArtArgs) + (Ashen-ArtArgs) }
function Ground-MaterialArgs { return @("--ground-material-opt-in", "--ground-material-source=$($GroundSourcePath.Replace('\', '/'))", "--ground-material-metadata=$($GroundMetadataPath.Replace('\', '/'))", "--ground-material-expected-sha256=$GroundExpectedSha", "--ground-material-uv-scale=0.56") }
function Road-MaterialArgs { return @("--road-material-opt-in", "--road-material-source=$($RoadSourcePath.Replace('\', '/'))", "--road-material-metadata=$($RoadMetadataPath.Replace('\', '/'))", "--road-material-expected-sha256=$RoadExpectedSha", "--road-material-uv-scale=0.80") }
function Environment-GroundRoadArgs { return @("--player-slice", "--experimental-review-mode-label=Experimental opt-in art: 5 slots + Barrosan foothold ground + roads", "--salto-five-slot-review-framing", "--salto-environment-foundation-review") }
function Environment-GeometryArgs { return @("--player-slice", "--experimental-review-mode-label=Experimental opt-in: 5 slots + Barrosan ground + roads + geometry convergence", "--salto-five-slot-review-framing", "--salto-environment-foundation-review", "--salto-environment-geometry-convergence") }

function Invoke-V0184Tool {
  param([Parameter(Mandatory = $true)][string]$Command)
  node "tools/godot/saltoEnvironmentGeometryConvergenceTool.mjs" $Command "--artifact-root=$ArtifactRootArg"
  if ($LASTEXITCODE -ne 0) {
    throw "v0.184 environment geometry convergence tool '$Command' failed with exit code $LASTEXITCODE."
  }
}

Reset-SafeDirectory -Path $ArtifactRoot -Parent (Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto")

$ValidationRoot = Join-Path $ArtifactRoot "validation"
Reset-SafeDirectory -Path $ValidationRoot -Parent $ArtifactRoot
Invoke-GodotScenario -ScenarioRoot (Join-Path $ValidationRoot "default-procedural") -ScenarioArgs @("--player-slice", "--player-slice-validate") -ExpectedFiles @("player-slice-validation-runtime.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $ValidationRoot "e2-ground-road-material-opt-in-baseline") -ScenarioArgs (@("--player-slice-validate") + (Environment-GroundRoadArgs) + (Five-SlotArgs) + (Ground-MaterialArgs) + (Road-MaterialArgs)) -ExpectedFiles @("player-slice-validation-runtime.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $ValidationRoot "e3-geometry-convergence-opt-in") -ScenarioArgs (@("--player-slice-validate") + (Environment-GeometryArgs) + (Five-SlotArgs) + (Ground-MaterialArgs) + (Road-MaterialArgs)) -ExpectedFiles @("player-slice-validation-runtime.json")
Invoke-V0184Tool -Command "validation"

$CaptureRoot = Join-Path $ArtifactRoot "capture"
Reset-SafeDirectory -Path $CaptureRoot -Parent $ArtifactRoot
Invoke-GodotScenario -ScenarioRoot (Join-Path $CaptureRoot "e2-ground-road-material-opt-in-baseline") -ScenarioArgs (@("--player-slice-capture") + (Environment-GroundRoadArgs) + (Five-SlotArgs) + (Ground-MaterialArgs) + (Road-MaterialArgs)) -ExpectedFiles @("screenshot-runtime-manifest.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $CaptureRoot "e3-geometry-convergence-opt-in") -ScenarioArgs (@("--player-slice-capture") + (Environment-GeometryArgs) + (Five-SlotArgs) + (Ground-MaterialArgs) + (Road-MaterialArgs)) -ExpectedFiles @("screenshot-runtime-manifest.json")
Invoke-V0184Tool -Command "capture"

$BenchmarkRoot = Join-Path $ArtifactRoot "benchmark"
Reset-SafeDirectory -Path $BenchmarkRoot -Parent $ArtifactRoot
Invoke-GodotScenario -ScenarioRoot (Join-Path $BenchmarkRoot "e2-ground-road-material-opt-in-baseline") -ScenarioArgs (@("--worker-art-opt-in-benchmark") + (Environment-GroundRoadArgs) + (Five-SlotArgs) + (Ground-MaterialArgs) + (Road-MaterialArgs)) -ExpectedFiles @("worker-art-opt-in-benchmark-runtime.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $BenchmarkRoot "e3-geometry-convergence-opt-in") -ScenarioArgs (@("--worker-art-opt-in-benchmark") + (Environment-GeometryArgs) + (Five-SlotArgs) + (Ground-MaterialArgs) + (Road-MaterialArgs)) -ExpectedFiles @("worker-art-opt-in-benchmark-runtime.json")
Invoke-V0184Tool -Command "benchmark"

Invoke-V0184Tool -Command "boundary"

node "scripts/cleanupSaltoExperimentalArtifacts.mjs" "--output-root=$((Join-Path $ArtifactRoot 'cleanup-dry-run').Replace('\', '/'))"
if ($LASTEXITCODE -ne 0) {
  throw "v0.184 cleanup dry-run failed with exit code $LASTEXITCODE."
}

node "scripts/validateSaltoExperimentalArtifactRetention.mjs" "--output-root=$((Join-Path $ArtifactRoot 'artifact-retention').Replace('\', '/'))"
if ($LASTEXITCODE -ne 0) {
  throw "v0.184 artifact retention validation failed with exit code $LASTEXITCODE."
}

Write-Output "PASS_V0184_SALTO_ENVIRONMENT_GEOMETRY_CONVERGENCE_AUTOMATION_READY"
