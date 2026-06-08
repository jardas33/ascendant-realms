param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ExePath = Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe"
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0170\capture"
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
$MissingAshenSourcePath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0170\missing-ashen-source\ashen_raider_billboard_static_v0157_restrained_trimmed_1024.png"
$WorkerExpectedSha = "a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc"
$BarracksExpectedSha = "58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f"
$MilitiaExpectedSha = "c25349f00c422a0b3c9d5862027351bd70008e9314d4e3cd4001676e914321cb"
$AsterExpectedSha = "b256f96f762187c05d68f2c2de62bedec0248896210767e98cb8f210dac2829a"
$AshenExpectedSha = "8eb011f56d5cd56cf6ef0a843d2a5899e27aa13e203cc44517ed4a0c55c631c8"
$MismatchSha = "0000000000000000000000000000000000000000000000000000000000000000"

Set-Location $RepoRoot

& (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
& (Join-Path $PSScriptRoot "packageGodotWindows.ps1")

function ConvertTo-ProcessArgumentString {
  param([Parameter(Mandatory = $true)][string[]]$Arguments)
  return ($Arguments | ForEach-Object { if ($_ -match '[\s"]') { '"' + ($_ -replace '"', '\"') + '"' } else { $_ } }) -join " "
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

function Invoke-GodotCaptureScenario {
  param([string]$ScenarioId, [string[]]$ScenarioArgs = @())
  $ScenarioRoot = Join-Path $ArtifactRoot $ScenarioId
  New-Item -ItemType Directory -Force -Path $ScenarioRoot | Out-Null
  $ArtifactArg = $ScenarioRoot.Replace("\", "/")
  $ArgumentList = @("--player-slice-capture", "--artifact-root=$ArtifactArg") + $ScenarioArgs
  $Process = Start-Process -FilePath $ExePath -ArgumentList (ConvertTo-ProcessArgumentString $ArgumentList) -Wait -PassThru -WindowStyle Hidden
  $GodotExitCode = if ($null -eq $Process.ExitCode) { 0 } else { $Process.ExitCode }
  if ($GodotExitCode -ne 0) {
    throw "Godot five-slot capture scenario '$ScenarioId' exited with code $GodotExitCode."
  }
  if (-not (Test-Path (Join-Path $ScenarioRoot "screenshot-runtime-manifest.json"))) {
    throw "Missing capture runtime artifact for scenario '$ScenarioId'."
  }
}

function Worker-ArtArgs { return @("--worker-art-opt-in", "--worker-art-source=$($WorkerSourcePath.Replace('\', '/'))", "--worker-art-metadata=$($WorkerMetadataPath.Replace('\', '/'))", "--worker-art-expected-sha256=$WorkerExpectedSha", "--worker-art-scale=1.00") }
function Barracks-ArtArgs { return @("--barracks-material-opt-in", "--barracks-material-source=$($BarracksSourcePath.Replace('\', '/'))", "--barracks-material-metadata=$($BarracksMetadataPath.Replace('\', '/'))", "--barracks-material-expected-sha256=$BarracksExpectedSha") }
function Militia-ArtArgs { return @("--militia-art-opt-in", "--militia-art-source=$($MilitiaSourcePath.Replace('\', '/'))", "--militia-art-metadata=$($MilitiaMetadataPath.Replace('\', '/'))", "--militia-art-expected-sha256=$MilitiaExpectedSha", "--militia-art-scale=1.00") }
function Aster-ArtArgs { return @("--aster-art-opt-in", "--aster-art-source=$($AsterSourcePath.Replace('\', '/'))", "--aster-art-metadata=$($AsterMetadataPath.Replace('\', '/'))", "--aster-art-expected-sha256=$AsterExpectedSha", "--aster-art-scale=1.08") }
function Ashen-ArtArgs {
  param([string]$Source = $AshenSourcePath, [string]$Expected = $AshenExpectedSha, [string]$FallbackMode = "none")
  return @("--ashen-art-opt-in", "--ashen-art-source=$($Source.Replace('\', '/'))", "--ashen-art-metadata=$($AshenMetadataPath.Replace('\', '/'))", "--ashen-art-expected-sha256=$Expected", "--ashen-art-scale=1.00", "--ashen-art-fallback-mode=$FallbackMode")
}
function Review-FourArgs { return @("--experimental-review-mode-label=Experimental opt-in art: Worker + Barracks + Militia + Aster", "--salto-four-slot-review-framing") }
function Review-FiveArgs { return @("--experimental-review-mode-label=Experimental opt-in art: Worker + Barracks + Militia + Aster + Ashen", "--salto-five-slot-review-framing") }

Reset-SafeDirectory -Path $ArtifactRoot -Parent (Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0170")
Invoke-GodotCaptureScenario -ScenarioId "default-procedural" -ScenarioArgs @()
Invoke-GodotCaptureScenario -ScenarioId "worker-barracks-militia-aster" -ScenarioArgs ((Review-FourArgs) + (Worker-ArtArgs) + (Barracks-ArtArgs) + (Militia-ArtArgs) + (Aster-ArtArgs))
Invoke-GodotCaptureScenario -ScenarioId "worker-barracks-militia-aster-ashen" -ScenarioArgs ((Review-FiveArgs) + (Worker-ArtArgs) + (Barracks-ArtArgs) + (Militia-ArtArgs) + (Aster-ArtArgs) + (Ashen-ArtArgs))
Invoke-GodotCaptureScenario -ScenarioId "ashen-missing-art-fallback" -ScenarioArgs ((Review-FiveArgs) + (Worker-ArtArgs) + (Barracks-ArtArgs) + (Militia-ArtArgs) + (Aster-ArtArgs) + (Ashen-ArtArgs -Source $MissingAshenSourcePath -FallbackMode "missing"))
Invoke-GodotCaptureScenario -ScenarioId "ashen-hash-mismatch-fallback" -ScenarioArgs ((Review-FiveArgs) + (Worker-ArtArgs) + (Barracks-ArtArgs) + (Militia-ArtArgs) + (Aster-ArtArgs) + (Ashen-ArtArgs -Expected $MismatchSha -FallbackMode "hash-mismatch"))

node "tools/godot/saltoFiveSlotArtOptInTool.mjs" capture "--artifact-root=$((Join-Path $RepoRoot 'artifacts\desktop-spikes\godot-salto\v0170').Replace('\', '/'))"
if ($LASTEXITCODE -ne 0) {
  throw "v0.170 five-slot capture report failed with exit code $LASTEXITCODE."
}
