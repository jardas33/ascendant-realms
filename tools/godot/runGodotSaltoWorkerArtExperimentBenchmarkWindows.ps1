param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ExePath = Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe"
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0160\benchmark"
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

function Invoke-GodotBenchmarkScenario {
  param(
    [Parameter(Mandatory = $true)][string]$ScenarioId,
    [string[]]$ScenarioArgs = @()
  )
  $ScenarioRoot = Join-Path $ArtifactRoot $ScenarioId
  New-Item -ItemType Directory -Force -Path $ScenarioRoot | Out-Null
  Remove-Item -LiteralPath (Join-Path $ScenarioRoot "worker-art-opt-in-benchmark-runtime.json") -Force -ErrorAction SilentlyContinue
  $ArtifactArg = $ScenarioRoot.Replace("\", "/")
  $ArgumentList = @("--worker-art-opt-in-benchmark", "--artifact-root=$ArtifactArg") + $ScenarioArgs
  $Process = Start-Process -FilePath $ExePath -ArgumentList (ConvertTo-ProcessArgumentString $ArgumentList) -Wait -PassThru -WindowStyle Hidden
  $GodotExitCode = if ($null -eq $Process.ExitCode) { 0 } else { $Process.ExitCode }
  if ($GodotExitCode -ne 0) {
    throw "Godot Worker art benchmark scenario '$ScenarioId' exited with code $GodotExitCode."
  }
}

Invoke-GodotBenchmarkScenario -ScenarioId "procedural-baseline" -ScenarioArgs @()
Invoke-GodotBenchmarkScenario -ScenarioId "worker-opt-in" -ScenarioArgs @(
  "--worker-art-opt-in",
  "--worker-art-source=$($SourcePath.Replace('\', '/'))",
  "--worker-art-metadata=$($MetadataPath.Replace('\', '/'))",
  "--worker-art-expected-sha256=$ExpectedSha",
  "--worker-art-scale=1.00"
)
Invoke-GodotBenchmarkScenario -ScenarioId "missing-art-fallback" -ScenarioArgs @(
  "--worker-art-opt-in",
  "--worker-art-source=$($MissingSourcePath.Replace('\', '/'))",
  "--worker-art-metadata=$($MetadataPath.Replace('\', '/'))",
  "--worker-art-expected-sha256=$ExpectedSha",
  "--worker-art-fallback-mode=missing"
)
Invoke-GodotBenchmarkScenario -ScenarioId "hash-mismatch-fallback" -ScenarioArgs @(
  "--worker-art-opt-in",
  "--worker-art-source=$($SourcePath.Replace('\', '/'))",
  "--worker-art-metadata=$($MetadataPath.Replace('\', '/'))",
  "--worker-art-expected-sha256=$MismatchSha",
  "--worker-art-fallback-mode=hash-mismatch"
)

node "tools/godot/saltoWorkerArtOptInTool.mjs" benchmark "--artifact-root=$($ArtifactRoot.Replace('\', '/'))"
