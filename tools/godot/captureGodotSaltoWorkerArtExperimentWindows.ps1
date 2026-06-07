param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ExePath = Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe"
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0160\capture"
$SourcePath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0148\local-worker-slot\worker_billboard_static_v0147_trimmed_1024.png"
$MetadataPath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0148\local-worker-slot\worker_billboard_static_v0147_trimmed_1024.metadata.json"
$MissingSourcePath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0160\missing-worker-source\worker_billboard_static_v0147_trimmed_1024.png"
$ExpectedSha = "a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc"
$MismatchSha = "0000000000000000000000000000000000000000000000000000000000000000"

Set-Location $RepoRoot

& (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
& (Join-Path $PSScriptRoot "packageGodotWindows.ps1")

if (-not (Test-Path $ExePath)) {
  throw "Missing packaged Godot executable after export."
}
New-Item -ItemType Directory -Force -Path $ArtifactRoot | Out-Null

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

function Invoke-GodotCaptureScenario {
  param(
    [Parameter(Mandatory = $true)][string]$ScenarioId,
    [string[]]$ScenarioArgs = @()
  )
  $ScenarioRoot = Join-Path $ArtifactRoot $ScenarioId
  $ScreenshotRoot = Join-Path $ScenarioRoot "screenshots"
  if (Test-Path -LiteralPath $ScreenshotRoot) {
    $resolvedScreenshots = Resolve-Path -LiteralPath $ScreenshotRoot
    $resolvedScenario = Resolve-Path -LiteralPath $ScenarioRoot
    if (-not ($resolvedScreenshots.Path.StartsWith($resolvedScenario.Path))) {
      throw "Refusing to remove screenshots outside scenario root: $($resolvedScreenshots.Path)"
    }
    Remove-Item -LiteralPath $ScreenshotRoot -Recurse -Force
  }
  New-Item -ItemType Directory -Force -Path $ScreenshotRoot | Out-Null
  Remove-Item -LiteralPath (Join-Path $ScenarioRoot "screenshot-runtime-manifest.json") -Force -ErrorAction SilentlyContinue
  $ArtifactArg = $ScenarioRoot.Replace("\", "/")
  $ArgumentList = @("--player-slice-capture", "--artifact-root=$ArtifactArg") + $ScenarioArgs
  $Process = Start-Process -FilePath $ExePath -ArgumentList (ConvertTo-ProcessArgumentString $ArgumentList) -Wait -PassThru -WindowStyle Hidden
  $GodotExitCode = if ($null -eq $Process.ExitCode) { 0 } else { $Process.ExitCode }
  if ($GodotExitCode -ne 0) {
    throw "Godot Worker art capture scenario '$ScenarioId' exited with code $GodotExitCode."
  }
  if (-not (Test-Path (Join-Path $ScenarioRoot "screenshot-runtime-manifest.json"))) {
    throw "Missing capture runtime artifact for scenario '$ScenarioId'."
  }
}

Invoke-GodotCaptureScenario -ScenarioId "default-procedural" -ScenarioArgs @()
Invoke-GodotCaptureScenario -ScenarioId "worker-opt-in" -ScenarioArgs @(
  "--worker-art-opt-in",
  "--worker-art-source=$($SourcePath.Replace('\', '/'))",
  "--worker-art-metadata=$($MetadataPath.Replace('\', '/'))",
  "--worker-art-expected-sha256=$ExpectedSha",
  "--worker-art-scale=1.00"
)
Invoke-GodotCaptureScenario -ScenarioId "worker-opt-in-scale-090" -ScenarioArgs @(
  "--worker-art-opt-in",
  "--worker-art-source=$($SourcePath.Replace('\', '/'))",
  "--worker-art-metadata=$($MetadataPath.Replace('\', '/'))",
  "--worker-art-expected-sha256=$ExpectedSha",
  "--worker-art-scale=0.90"
)
Invoke-GodotCaptureScenario -ScenarioId "missing-art-fallback" -ScenarioArgs @(
  "--worker-art-opt-in",
  "--worker-art-source=$($MissingSourcePath.Replace('\', '/'))",
  "--worker-art-metadata=$($MetadataPath.Replace('\', '/'))",
  "--worker-art-expected-sha256=$ExpectedSha",
  "--worker-art-fallback-mode=missing"
)
Invoke-GodotCaptureScenario -ScenarioId "hash-mismatch-fallback" -ScenarioArgs @(
  "--worker-art-opt-in",
  "--worker-art-source=$($SourcePath.Replace('\', '/'))",
  "--worker-art-metadata=$($MetadataPath.Replace('\', '/'))",
  "--worker-art-expected-sha256=$MismatchSha",
  "--worker-art-fallback-mode=hash-mismatch"
)

node "tools/godot/saltoWorkerArtOptInTool.mjs" capture "--artifact-root=$($ArtifactRoot.Replace('\', '/'))"
