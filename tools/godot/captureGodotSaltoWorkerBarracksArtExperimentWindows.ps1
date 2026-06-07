param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ExePath = Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe"
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0162\capture"
$WorkerSourcePath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0148\local-worker-slot\worker_billboard_static_v0147_trimmed_1024.png"
$WorkerMetadataPath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0148\local-worker-slot\worker_billboard_static_v0147_trimmed_1024.metadata.json"
$BarracksSourcePath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0150\local-barracks-material-seam-repair\barrosan_barracks_material_v0149_768_wrapsafe_offset_blend.png"
$BarracksMetadataPath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0150\local-barracks-material-seam-repair\barrosan_barracks_material_v0149_768_wrapsafe_offset_blend.metadata.json"
$MissingBarracksSourcePath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0162\missing-barracks-source\barrosan_barracks_material_v0149_768_wrapsafe_offset_blend.png"
$WorkerExpectedSha = "a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc"
$BarracksExpectedSha = "58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f"
$MismatchSha = "0000000000000000000000000000000000000000000000000000000000000000"

Set-Location $RepoRoot

& (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
& (Join-Path $PSScriptRoot "packageGodotWindows.ps1")

if (-not (Test-Path $ExePath)) {
  throw "Missing packaged Godot executable after export."
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

function Invoke-GodotCaptureScenario {
  param(
    [Parameter(Mandatory = $true)][string]$ScenarioId,
    [string[]]$ScenarioArgs = @()
  )
  $ScenarioRoot = Join-Path $ArtifactRoot $ScenarioId
  New-Item -ItemType Directory -Force -Path $ScenarioRoot | Out-Null
  $ArtifactArg = $ScenarioRoot.Replace("\", "/")
  $ArgumentList = @("--player-slice-capture", "--artifact-root=$ArtifactArg") + $ScenarioArgs
  $Process = Start-Process -FilePath $ExePath -ArgumentList (ConvertTo-ProcessArgumentString $ArgumentList) -Wait -PassThru -WindowStyle Hidden
  $GodotExitCode = if ($null -eq $Process.ExitCode) { 0 } else { $Process.ExitCode }
  if ($GodotExitCode -ne 0) {
    throw "Godot Worker + Barracks capture scenario '$ScenarioId' exited with code $GodotExitCode."
  }
  if (-not (Test-Path (Join-Path $ScenarioRoot "screenshot-runtime-manifest.json"))) {
    throw "Missing capture runtime artifact for scenario '$ScenarioId'."
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

Reset-SafeDirectory -Path $ArtifactRoot -Parent (Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0162")
Invoke-GodotCaptureScenario -ScenarioId "default-procedural" -ScenarioArgs @()
Invoke-GodotCaptureScenario -ScenarioId "worker-only" -ScenarioArgs (Worker-ArtArgs)
Invoke-GodotCaptureScenario -ScenarioId "worker-barracks" -ScenarioArgs ((Worker-ArtArgs) + (Barracks-ArtArgs))
Invoke-GodotCaptureScenario -ScenarioId "barracks-missing-art-fallback" -ScenarioArgs ((Worker-ArtArgs) + (Barracks-ArtArgs -Source $MissingBarracksSourcePath -FallbackMode "missing"))
Invoke-GodotCaptureScenario -ScenarioId "barracks-hash-mismatch-fallback" -ScenarioArgs ((Worker-ArtArgs) + (Barracks-ArtArgs -Expected $MismatchSha -FallbackMode "hash-mismatch"))

node "tools/godot/saltoWorkerBarracksArtOptInTool.mjs" capture "--artifact-root=$((Join-Path $RepoRoot 'artifacts\desktop-spikes\godot-salto\v0162').Replace('\', '/'))"
if ($LASTEXITCODE -ne 0) {
  throw "v0.162 Worker + Barracks capture report failed with exit code $LASTEXITCODE."
}
