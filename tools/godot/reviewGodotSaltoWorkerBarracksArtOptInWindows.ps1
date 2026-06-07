param(
  [ValidateSet("default-procedural", "worker-only", "worker-barracks", "barracks-missing-art-fallback", "barracks-hash-mismatch-fallback")]
  [string]$Posture = "worker-barracks",
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
$MissingBarracksSourcePath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0163\missing-barracks-source\barrosan_barracks_material_v0149_768_wrapsafe_offset_blend.png"
$WorkerExpectedSha = "a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc"
$BarracksExpectedSha = "58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f"
$MismatchSha = "0000000000000000000000000000000000000000000000000000000000000000"

Set-Location $RepoRoot

if (-not (Test-Path $ExePath)) {
  & (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
  & (Join-Path $PSScriptRoot "packageGodotWindows.ps1")
}

foreach ($path in @($ExePath, $WorkerSourcePath, $WorkerMetadataPath, $BarracksSourcePath, $BarracksMetadataPath)) {
  if (-not (Test-Path -LiteralPath $path)) {
    throw "Missing required Worker + Barracks opt-in review path: $path"
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
  param(
    [string]$Source = $BarracksSourcePath,
    [string]$Expected = $BarracksExpectedSha,
    [string]$FallbackMode = "none"
  )
  return @(
    "--barracks-material-opt-in",
    "--barracks-material-source=$($Source.Replace('\', '/'))",
    "--barracks-material-metadata=$($BarracksMetadataPath.Replace('\', '/'))",
    "--barracks-material-expected-sha256=$Expected",
    "--barracks-material-fallback-mode=$FallbackMode"
  )
}

$ArgumentList = @("--player-slice")
if ($Posture -eq "worker-only") {
  $ArgumentList += (Worker-ArtArgs)
}
if ($Posture -eq "worker-barracks") {
  $ArgumentList += (Worker-ArtArgs)
  $ArgumentList += (Barracks-ArtArgs)
}
if ($Posture -eq "barracks-missing-art-fallback") {
  $ArgumentList += (Worker-ArtArgs)
  $ArgumentList += (Barracks-ArtArgs -Source $MissingBarracksSourcePath -FallbackMode "missing")
}
if ($Posture -eq "barracks-hash-mismatch-fallback") {
  $ArgumentList += (Worker-ArtArgs)
  $ArgumentList += (Barracks-ArtArgs -Expected $MismatchSha -FallbackMode "hash-mismatch")
}
if ($RemainingArgs) {
  $ArgumentList += $RemainingArgs
}

Write-Output "Launching the v0.163 Worker + Barracks-material opt-in review posture: $Posture"
Write-Output "Default procedural review remains GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat."
Write-Output "Worker-only review remains GODOT_LAUNCH_SALTO_WORKER_ART_EXPERIMENT_WINDOWS.bat."
Write-Output "Combined slot posture: worker_billboard_static_v0147 + barrosan_barracks_material_v0149."

if ($Wait) {
  & $ExePath @ArgumentList
  $GodotExitCode = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE }
  if ($GodotExitCode -ne 0) {
    throw "Packaged Godot v0.163 Worker + Barracks posture '$Posture' exited with code $GodotExitCode."
  }
  return
}

Start-Process -FilePath $ExePath -ArgumentList (ConvertTo-ProcessArgumentString $ArgumentList) | Out-Null
