param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ExePath = Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe"
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0161"
$SourcePath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0148\local-worker-slot\worker_billboard_static_v0147_trimmed_1024.png"
$MetadataPath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0148\local-worker-slot\worker_billboard_static_v0147_trimmed_1024.metadata.json"
$MissingSourcePath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0161\missing-worker-source\worker_billboard_static_v0147_trimmed_1024.png"
$ExpectedSha = "a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc"
$MismatchSha = "0000000000000000000000000000000000000000000000000000000000000000"

Set-Location $RepoRoot

& (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
& (Join-Path $PSScriptRoot "packageGodotWindows.ps1")

if (-not (Test-Path $ExePath)) {
  throw "Missing packaged Godot executable after export."
}
if (-not (Test-Path $SourcePath)) {
  throw "Missing selected Worker source: $SourcePath"
}
if (-not (Test-Path $MetadataPath)) {
  throw "Missing selected Worker metadata: $MetadataPath"
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

function Invoke-GodotScenario {
  param(
    [Parameter(Mandatory = $true)][string]$ScenarioRoot,
    [Parameter(Mandatory = $true)][string[]]$ScenarioArgs,
    [Parameter(Mandatory = $true)][string[]]$ExpectedFiles
  )
  New-Item -ItemType Directory -Force -Path $ScenarioRoot | Out-Null
  $ArtifactArg = $ScenarioRoot.Replace("\", "/")
  $ArgumentList = $ScenarioArgs + @("--artifact-root=$ArtifactArg")
  $Process = Start-Process -FilePath $ExePath -ArgumentList (ConvertTo-ProcessArgumentString $ArgumentList) -Wait -PassThru -WindowStyle Hidden
  $GodotExitCode = if ($null -eq $Process.ExitCode) { 0 } else { $Process.ExitCode }
  if ($GodotExitCode -ne 0) {
    throw "Godot scenario '$ScenarioRoot' exited with code $GodotExitCode."
  }
  foreach ($fileName in $ExpectedFiles) {
    if (-not (Test-Path -LiteralPath (Join-Path $ScenarioRoot $fileName))) {
      throw "Missing expected artifact '$fileName' for scenario '$ScenarioRoot'."
    }
  }
}

function Worker-ArtArgs {
  param(
    [string]$Source = $SourcePath,
    [string]$Expected = $ExpectedSha,
    [string]$Scale = "1.00",
    [string]$FallbackMode = "none"
  )
  return @(
    "--worker-art-opt-in",
    "--worker-art-source=$($Source.Replace('\', '/'))",
    "--worker-art-metadata=$($MetadataPath.Replace('\', '/'))",
    "--worker-art-expected-sha256=$Expected",
    "--worker-art-scale=$Scale",
    "--worker-art-fallback-mode=$FallbackMode"
  )
}

function Invoke-NodeHardeningTool {
  param([Parameter(Mandatory = $true)][string]$Command)
  node "tools/godot/saltoWorkerArtOptInHardeningTool.mjs" $Command "--artifact-root=$($ArtifactRoot.Replace('\', '/'))"
  if ($LASTEXITCODE -ne 0) {
    throw "v0.161 hardening tool '$Command' failed with exit code $LASTEXITCODE."
  }
}

$ValidationRoot = Join-Path $ArtifactRoot "validation"
Reset-SafeDirectory -Path $ValidationRoot -Parent $ArtifactRoot
Invoke-GodotScenario -ScenarioRoot (Join-Path $ValidationRoot "default-procedural") -ScenarioArgs @("--player-slice-validate") -ExpectedFiles @("player-slice-validation-runtime.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $ValidationRoot "worker-opt-in") -ScenarioArgs (@("--player-slice-validate") + (Worker-ArtArgs)) -ExpectedFiles @("player-slice-validation-runtime.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $ValidationRoot "missing-art-fallback") -ScenarioArgs (@("--player-slice-validate") + (Worker-ArtArgs -Source $MissingSourcePath -FallbackMode "missing")) -ExpectedFiles @("player-slice-validation-runtime.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $ValidationRoot "hash-mismatch-fallback") -ScenarioArgs (@("--player-slice-validate") + (Worker-ArtArgs -Expected $MismatchSha -FallbackMode "hash-mismatch")) -ExpectedFiles @("player-slice-validation-runtime.json")
Invoke-NodeHardeningTool -Command "validation"

$CaptureRoot = Join-Path $ArtifactRoot "capture"
Reset-SafeDirectory -Path $CaptureRoot -Parent $ArtifactRoot
Invoke-GodotScenario -ScenarioRoot (Join-Path $CaptureRoot "default-procedural") -ScenarioArgs @("--player-slice-capture") -ExpectedFiles @("screenshot-runtime-manifest.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $CaptureRoot "worker-opt-in") -ScenarioArgs (@("--player-slice-capture") + (Worker-ArtArgs)) -ExpectedFiles @("screenshot-runtime-manifest.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $CaptureRoot "worker-opt-in-scale-090") -ScenarioArgs (@("--player-slice-capture") + (Worker-ArtArgs -Scale "0.90")) -ExpectedFiles @("screenshot-runtime-manifest.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $CaptureRoot "missing-art-fallback") -ScenarioArgs (@("--player-slice-capture") + (Worker-ArtArgs -Source $MissingSourcePath -FallbackMode "missing")) -ExpectedFiles @("screenshot-runtime-manifest.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $CaptureRoot "hash-mismatch-fallback") -ScenarioArgs (@("--player-slice-capture") + (Worker-ArtArgs -Expected $MismatchSha -FallbackMode "hash-mismatch")) -ExpectedFiles @("screenshot-runtime-manifest.json")
Invoke-NodeHardeningTool -Command "capture"

$BenchmarkRoot = Join-Path $ArtifactRoot "benchmark"
Reset-SafeDirectory -Path $BenchmarkRoot -Parent $ArtifactRoot
Invoke-GodotScenario -ScenarioRoot (Join-Path $BenchmarkRoot "procedural-baseline") -ScenarioArgs @("--worker-art-opt-in-benchmark") -ExpectedFiles @("worker-art-opt-in-benchmark-runtime.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $BenchmarkRoot "worker-opt-in") -ScenarioArgs (@("--worker-art-opt-in-benchmark") + (Worker-ArtArgs)) -ExpectedFiles @("worker-art-opt-in-benchmark-runtime.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $BenchmarkRoot "missing-art-fallback") -ScenarioArgs (@("--worker-art-opt-in-benchmark") + (Worker-ArtArgs -Source $MissingSourcePath -FallbackMode "missing")) -ExpectedFiles @("worker-art-opt-in-benchmark-runtime.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $BenchmarkRoot "hash-mismatch-fallback") -ScenarioArgs (@("--worker-art-opt-in-benchmark") + (Worker-ArtArgs -Expected $MismatchSha -FallbackMode "hash-mismatch")) -ExpectedFiles @("worker-art-opt-in-benchmark-runtime.json")
Invoke-NodeHardeningTool -Command "benchmark"

$RealInputRoot = Join-Path $ArtifactRoot "real-input"
Reset-SafeDirectory -Path $RealInputRoot -Parent $ArtifactRoot
Invoke-GodotScenario -ScenarioRoot (Join-Path $RealInputRoot "default-real-input") -ScenarioArgs @("--real-input-validate") -ExpectedFiles @("headed-playability-smoke.json", "selection-proof.json", "movement-proof.json", "screenshot-manifest.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $RealInputRoot "opt-in-real-input") -ScenarioArgs (@("--real-input-validate") + (Worker-ArtArgs)) -ExpectedFiles @("headed-playability-smoke.json", "selection-proof.json", "movement-proof.json", "screenshot-manifest.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $RealInputRoot "opt-in-site-semantics") -ScenarioArgs (@("--site-semantics-validate") + (Worker-ArtArgs)) -ExpectedFiles @("headed-site-semantics-smoke.json", "mine-conversion-proof.json", "worker-assignment-proof.json", "screenshot-manifest.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $RealInputRoot "opt-in-post-mine-flow") -ScenarioArgs (@("--post-mine-flow-validate") + (Worker-ArtArgs)) -ExpectedFiles @("headed-post-mine-flow-smoke.json", "barracks-restoration-proof.json", "lume-restore-proof.json", "screenshot-manifest.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $RealInputRoot "opt-in-restart-replay") -ScenarioArgs (@("--triple-natural-playthrough") + (Worker-ArtArgs)) -ExpectedFiles @("triple-playthrough-report.json", "recovery-case-report.json", "restart-integrity-report.json", "screenshot-manifest.json")
Invoke-NodeHardeningTool -Command "real-input"

Invoke-NodeHardeningTool -Command "boundary"

Write-Output "PASS_V0161_WORKER_ART_OPT_IN_HARDENING_AUTOMATION_READY"
