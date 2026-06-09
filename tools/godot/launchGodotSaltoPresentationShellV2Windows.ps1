param(
  [switch]$Wait,
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$RemainingArgs
)

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ExePath = if ($env:GODOT_SALTO_EXE_PATH) {
  $env:GODOT_SALTO_EXE_PATH
} else {
  Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe"
}
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

if (-not (Test-Path $ExePath)) {
  & (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
  & (Join-Path $PSScriptRoot "packageGodotWindows.ps1")
}

foreach ($path in @($ExePath, $WorkerSourcePath, $WorkerMetadataPath, $BarracksSourcePath, $BarracksMetadataPath, $MilitiaSourcePath, $MilitiaMetadataPath, $AsterSourcePath, $AsterMetadataPath, $AshenSourcePath, $AshenMetadataPath, $GroundSourcePath, $GroundMetadataPath, $RoadSourcePath, $RoadMetadataPath)) {
  if (-not (Test-Path -LiteralPath $path)) {
    throw "Missing required v0.193 presentation shell v2 path: $path"
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

$ArgumentList = @(
  "--player-slice",
  "--experimental-review-mode-label=Experimental opt-in: Salto presentation shell v2",
  "--salto-five-slot-review-framing",
  "--salto-presentation-shell-v2",
  "--worker-art-opt-in",
  "--worker-art-source=$($WorkerSourcePath.Replace('\', '/'))",
  "--worker-art-metadata=$($WorkerMetadataPath.Replace('\', '/'))",
  "--worker-art-expected-sha256=$WorkerExpectedSha",
  "--worker-art-scale=1.10",
  "--barracks-material-opt-in",
  "--barracks-material-source=$($BarracksSourcePath.Replace('\', '/'))",
  "--barracks-material-metadata=$($BarracksMetadataPath.Replace('\', '/'))",
  "--barracks-material-expected-sha256=$BarracksExpectedSha",
  "--militia-art-opt-in",
  "--militia-art-source=$($MilitiaSourcePath.Replace('\', '/'))",
  "--militia-art-metadata=$($MilitiaMetadataPath.Replace('\', '/'))",
  "--militia-art-expected-sha256=$MilitiaExpectedSha",
  "--militia-art-scale=1.08",
  "--aster-art-opt-in",
  "--aster-art-source=$($AsterSourcePath.Replace('\', '/'))",
  "--aster-art-metadata=$($AsterMetadataPath.Replace('\', '/'))",
  "--aster-art-expected-sha256=$AsterExpectedSha",
  "--aster-art-scale=1.16",
  "--ashen-art-opt-in",
  "--ashen-art-source=$($AshenSourcePath.Replace('\', '/'))",
  "--ashen-art-metadata=$($AshenMetadataPath.Replace('\', '/'))",
  "--ashen-art-expected-sha256=$AshenExpectedSha",
  "--ashen-art-scale=1.08",
  "--ground-material-opt-in",
  "--ground-material-source=$($GroundSourcePath.Replace('\', '/'))",
  "--ground-material-metadata=$($GroundMetadataPath.Replace('\', '/'))",
  "--ground-material-expected-sha256=$GroundExpectedSha",
  "--ground-material-uv-scale=0.56",
  "--road-material-opt-in",
  "--road-material-source=$($RoadSourcePath.Replace('\', '/'))",
  "--road-material-metadata=$($RoadMetadataPath.Replace('\', '/'))",
  "--road-material-expected-sha256=$RoadExpectedSha",
  "--road-material-uv-scale=0.80"
)
if ($RemainingArgs) {
  $ArgumentList += $RemainingArgs
}

Write-Output "Launching v0.193 Salto presentation shell v2 review."
Write-Output "Experimental opt-in: Salto presentation shell v2"
Write-Output "Worker SHA: $WorkerExpectedSha"
Write-Output "Barracks SHA: $BarracksExpectedSha"
Write-Output "Militia SHA: $MilitiaExpectedSha"
Write-Output "Aster SHA: $AsterExpectedSha"
Write-Output "Ashen SHA: $AshenExpectedSha"
Write-Output "Ground SHA: $GroundExpectedSha"
Write-Output "Road SHA: $RoadExpectedSha"
Write-Output "Shell v2 posture: visual-only compositor; legacy shell remains comparator/fallback; default launcher remains procedural."

if ($Wait) {
  & $ExePath @ArgumentList
  $GodotExitCode = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE }
  if ($GodotExitCode -ne 0) {
    throw "Packaged Godot presentation shell v2 review exited with code $GodotExitCode."
  }
  return
}

Start-Process -FilePath $ExePath -ArgumentList (ConvertTo-ProcessArgumentString $ArgumentList) | Out-Null
