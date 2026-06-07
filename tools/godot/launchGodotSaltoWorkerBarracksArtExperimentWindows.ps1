param(
  [switch]$Wait,
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$RemainingArgs
)

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ExePath = Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe"
$WorkerSourcePath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0148\local-worker-slot\worker_billboard_static_v0147_trimmed_1024.png"
$WorkerMetadataPath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0148\local-worker-slot\worker_billboard_static_v0147_trimmed_1024.metadata.json"
$BarracksSourcePath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0150\local-barracks-material-seam-repair\barrosan_barracks_material_v0149_768_wrapsafe_offset_blend.png"
$BarracksMetadataPath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0150\local-barracks-material-seam-repair\barrosan_barracks_material_v0149_768_wrapsafe_offset_blend.metadata.json"
$WorkerExpectedSha = "a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc"
$BarracksExpectedSha = "58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f"

Set-Location $RepoRoot

if (-not (Test-Path $ExePath)) {
  & (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
  & (Join-Path $PSScriptRoot "packageGodotWindows.ps1")
}

foreach ($path in @($ExePath, $WorkerSourcePath, $WorkerMetadataPath, $BarracksSourcePath, $BarracksMetadataPath)) {
  if (-not (Test-Path $path)) {
    throw "Missing required Worker + Barracks opt-in path: $path"
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
  "--worker-art-opt-in",
  "--worker-art-source=$($WorkerSourcePath.Replace('\', '/'))",
  "--worker-art-metadata=$($WorkerMetadataPath.Replace('\', '/'))",
  "--worker-art-expected-sha256=$WorkerExpectedSha",
  "--worker-art-scale=1.00",
  "--barracks-material-opt-in",
  "--barracks-material-source=$($BarracksSourcePath.Replace('\', '/'))",
  "--barracks-material-metadata=$($BarracksMetadataPath.Replace('\', '/'))",
  "--barracks-material-expected-sha256=$BarracksExpectedSha"
)
if ($RemainingArgs) {
  $ArgumentList += $RemainingArgs
}

if ($Wait) {
  & $ExePath @ArgumentList
  $GodotExitCode = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE }
  if ($GodotExitCode -ne 0) {
    throw "Packaged Godot Worker + Barracks art opt-in player slice exited with code $GodotExitCode."
  }
  return
}

Start-Process -FilePath $ExePath -ArgumentList (ConvertTo-ProcessArgumentString $ArgumentList) | Out-Null
