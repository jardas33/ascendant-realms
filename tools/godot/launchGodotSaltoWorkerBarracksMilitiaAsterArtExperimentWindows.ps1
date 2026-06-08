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
$WorkerExpectedSha = "a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc"
$BarracksExpectedSha = "58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f"
$MilitiaExpectedSha = "c25349f00c422a0b3c9d5862027351bd70008e9314d4e3cd4001676e914321cb"
$AsterExpectedSha = "b256f96f762187c05d68f2c2de62bedec0248896210767e98cb8f210dac2829a"

Set-Location $RepoRoot

if (-not (Test-Path $ExePath)) {
  & (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
  & (Join-Path $PSScriptRoot "packageGodotWindows.ps1")
}

foreach ($path in @($ExePath, $WorkerSourcePath, $WorkerMetadataPath, $BarracksSourcePath, $BarracksMetadataPath, $MilitiaSourcePath, $MilitiaMetadataPath, $AsterSourcePath, $AsterMetadataPath)) {
  if (-not (Test-Path -LiteralPath $path)) {
    throw "Missing required Worker + Barracks + Militia + Aster opt-in path: $path"
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
  "--experimental-review-mode-label=Experimental opt-in art: Worker + Barracks + Militia + Aster",
  "--salto-four-slot-review-framing",
  "--worker-art-opt-in",
  "--worker-art-source=$($WorkerSourcePath.Replace('\', '/'))",
  "--worker-art-metadata=$($WorkerMetadataPath.Replace('\', '/'))",
  "--worker-art-expected-sha256=$WorkerExpectedSha",
  "--worker-art-scale=1.00",
  "--barracks-material-opt-in",
  "--barracks-material-source=$($BarracksSourcePath.Replace('\', '/'))",
  "--barracks-material-metadata=$($BarracksMetadataPath.Replace('\', '/'))",
  "--barracks-material-expected-sha256=$BarracksExpectedSha",
  "--militia-art-opt-in",
  "--militia-art-source=$($MilitiaSourcePath.Replace('\', '/'))",
  "--militia-art-metadata=$($MilitiaMetadataPath.Replace('\', '/'))",
  "--militia-art-expected-sha256=$MilitiaExpectedSha",
  "--militia-art-scale=1.00",
  "--aster-art-opt-in",
  "--aster-art-source=$($AsterSourcePath.Replace('\', '/'))",
  "--aster-art-metadata=$($AsterMetadataPath.Replace('\', '/'))",
  "--aster-art-expected-sha256=$AsterExpectedSha",
  "--aster-art-scale=1.08"
)
if ($RemainingArgs) {
  $ArgumentList += $RemainingArgs
}

Write-Output "Launching v0.168 Worker + Barracks + Militia + Aster opt-in player slice."
Write-Output "Worker: worker_billboard_static_v0147 / HYBRID_WORKER_TRIMMED_1024 / $WorkerExpectedSha"
Write-Output "Barracks: barrosan_barracks_material_v0149 / HYBRID_BARRACKS_768_WRAPSAFE_OFFSET_BLEND / $BarracksExpectedSha"
Write-Output "Militia: militia_billboard_static_v0154 / HYBRID_MILITIA_TRIMMED_1024 / $MilitiaExpectedSha"
Write-Output "Aster: aster_billboard_static_v0151 / HYBRID_ASTER_TRIMMED_1024 / $AsterExpectedSha"
Write-Output "Mode label: Experimental opt-in art: Worker + Barracks + Militia + Aster"

if ($Wait) {
  & $ExePath @ArgumentList
  $GodotExitCode = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE }
  if ($GodotExitCode -ne 0) {
    throw "Packaged Godot Worker + Barracks + Militia + Aster art opt-in player slice exited with code $GodotExitCode."
  }
  return
}

Start-Process -FilePath $ExePath -ArgumentList (ConvertTo-ProcessArgumentString $ArgumentList) | Out-Null
