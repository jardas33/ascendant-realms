param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ExePath = if ($env:GODOT_SALTO_EXE_PATH) {
  $env:GODOT_SALTO_EXE_PATH
} else {
  Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe"
}
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0181"
$CaptureRoot = Join-Path $ArtifactRoot "capture"
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
$WrongRoadSha = "0000000000000000000000000000000000000000000000000000000000000000"

Set-Location $RepoRoot

& (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
& (Join-Path $PSScriptRoot "packageGodotWindows.ps1")

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
  param([string]$Path, [string]$Parent)
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

function Invoke-CaptureScenario {
  param([string]$ScenarioId, [string[]]$ScenarioArgs)
  $ScenarioRoot = Join-Path $CaptureRoot $ScenarioId
  New-Item -ItemType Directory -Force -Path $ScenarioRoot | Out-Null
  $ScenarioRootArg = $ScenarioRoot.Replace("\", "/")
  $ArgumentList = @("--player-slice-capture", "--artifact-root=$ScenarioRootArg") + $ScenarioArgs
  $process = Start-Process -FilePath $ExePath -ArgumentList (ConvertTo-ProcessArgumentString $ArgumentList) -Wait -PassThru -WindowStyle Hidden
  $GodotExitCode = if ($null -eq $process.ExitCode) { 0 } else { $process.ExitCode }
  if ($GodotExitCode -ne 0) {
    throw "Godot v0.181 capture scenario '$ScenarioId' exited with code $GodotExitCode."
  }
  if (-not (Test-Path -LiteralPath (Join-Path $ScenarioRoot "screenshot-runtime-manifest.json"))) {
    throw "Missing capture runtime artifact for scenario '$ScenarioId'."
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
function Environment-GroundRoadMaterialArgs { return @("--player-slice", "--experimental-review-mode-label=Experimental opt-in art: 5 slots + Barrosan foothold ground + roads", "--salto-five-slot-review-framing", "--salto-environment-foundation-review") }
function Environment-RoadMissingArgs { return @("--player-slice", "--experimental-review-mode-label=Experimental opt-in art: 5 slots + road fallback missing", "--salto-five-slot-review-framing", "--salto-environment-foundation-review") }
function Environment-RoadMismatchArgs { return @("--player-slice", "--experimental-review-mode-label=Experimental opt-in art: 5 slots + road fallback hash mismatch", "--salto-five-slot-review-framing", "--salto-environment-foundation-review") }
function Ground-MaterialArgs { return @("--ground-material-opt-in", "--ground-material-source=$($GroundSourcePath.Replace('\', '/'))", "--ground-material-metadata=$($GroundMetadataPath.Replace('\', '/'))", "--ground-material-expected-sha256=$GroundExpectedSha", "--ground-material-uv-scale=0.56") }
function Road-MaterialArgs { return @("--road-material-opt-in", "--road-material-source=$($RoadSourcePath.Replace('\', '/'))", "--road-material-metadata=$($RoadMetadataPath.Replace('\', '/'))", "--road-material-expected-sha256=$RoadExpectedSha", "--road-material-uv-scale=0.80") }
function Road-MissingArgs { return @("--road-material-opt-in", "--road-material-fallback-mode=missing", "--road-material-metadata=$($RoadMetadataPath.Replace('\', '/'))", "--road-material-expected-sha256=$RoadExpectedSha", "--road-material-uv-scale=0.80") }
function Road-MismatchArgs { return @("--road-material-opt-in", "--road-material-source=$($RoadSourcePath.Replace('\', '/'))", "--road-material-metadata=$($RoadMetadataPath.Replace('\', '/'))", "--road-material-expected-sha256=$WrongRoadSha", "--road-material-uv-scale=0.80") }

Reset-SafeDirectory -Path $CaptureRoot -Parent $ArtifactRoot
Invoke-CaptureScenario -ScenarioId "e0-environment-foundation-baseline" -ScenarioArgs ((Environment-FoundationArgs) + (Five-SlotArgs))
Invoke-CaptureScenario -ScenarioId "e1-ground-material-opt-in" -ScenarioArgs ((Environment-GroundMaterialArgs) + (Five-SlotArgs) + (Ground-MaterialArgs))
Invoke-CaptureScenario -ScenarioId "e2-ground-road-material-opt-in" -ScenarioArgs ((Environment-GroundRoadMaterialArgs) + (Five-SlotArgs) + (Ground-MaterialArgs) + (Road-MaterialArgs))
Invoke-CaptureScenario -ScenarioId "road-missing-art-fallback" -ScenarioArgs ((Environment-RoadMissingArgs) + (Five-SlotArgs) + (Ground-MaterialArgs) + (Road-MissingArgs))
Invoke-CaptureScenario -ScenarioId "road-hash-mismatch-fallback" -ScenarioArgs ((Environment-RoadMismatchArgs) + (Five-SlotArgs) + (Ground-MaterialArgs) + (Road-MismatchArgs))

node "tools/godot/saltoGroundRoadMaterialOptInTool.mjs" capture "--artifact-root=$ArtifactRootArg"
if ($LASTEXITCODE -ne 0) {
  throw "v0.181 ground+road material opt-in capture report failed with exit code $LASTEXITCODE."
}
