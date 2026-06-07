param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ExePath = Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe"
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0163"
$WorkerSourcePath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0148\local-worker-slot\worker_billboard_static_v0147_trimmed_1024.png"
$WorkerMetadataPath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0148\local-worker-slot\worker_billboard_static_v0147_trimmed_1024.metadata.json"
$BarracksSourcePath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0150\local-barracks-material-seam-repair\barrosan_barracks_material_v0149_768_wrapsafe_offset_blend.png"
$BarracksMetadataPath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0150\local-barracks-material-seam-repair\barrosan_barracks_material_v0149_768_wrapsafe_offset_blend.metadata.json"
$MissingBarracksSourcePath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0163\missing-barracks-source\barrosan_barracks_material_v0149_768_wrapsafe_offset_blend.png"
$WorkerExpectedSha = "a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc"
$BarracksExpectedSha = "58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f"
$MismatchSha = "0000000000000000000000000000000000000000000000000000000000000000"

Set-Location $RepoRoot

& (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
& (Join-Path $PSScriptRoot "packageGodotWindows.ps1")

foreach ($path in @($ExePath, $WorkerSourcePath, $WorkerMetadataPath, $BarracksSourcePath, $BarracksMetadataPath)) {
  if (-not (Test-Path -LiteralPath $path)) {
    throw "Missing required Worker + Barracks hardening path: $path"
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

function Invoke-V0163Tool {
  param([Parameter(Mandatory = $true)][string]$Command)
  node "tools/godot/saltoWorkerBarracksArtOptInHardeningTool.mjs" $Command "--artifact-root=$($ArtifactRoot.Replace('\', '/'))"
  if ($LASTEXITCODE -ne 0) {
    throw "v0.163 Worker + Barracks opt-in hardening tool '$Command' failed with exit code $LASTEXITCODE."
  }
}

$ValidationRoot = Join-Path $ArtifactRoot "validation"
Reset-SafeDirectory -Path $ValidationRoot -Parent $ArtifactRoot
Invoke-GodotScenario -ScenarioRoot (Join-Path $ValidationRoot "default-procedural") -ScenarioArgs @("--player-slice-validate") -ExpectedFiles @("player-slice-validation-runtime.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $ValidationRoot "worker-only") -ScenarioArgs (@("--player-slice-validate") + (Worker-ArtArgs)) -ExpectedFiles @("player-slice-validation-runtime.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $ValidationRoot "worker-barracks") -ScenarioArgs (@("--player-slice-validate") + (Worker-ArtArgs) + (Barracks-ArtArgs)) -ExpectedFiles @("player-slice-validation-runtime.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $ValidationRoot "barracks-missing-art-fallback") -ScenarioArgs (@("--player-slice-validate") + (Worker-ArtArgs) + (Barracks-ArtArgs -Source $MissingBarracksSourcePath -FallbackMode "missing")) -ExpectedFiles @("player-slice-validation-runtime.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $ValidationRoot "barracks-hash-mismatch-fallback") -ScenarioArgs (@("--player-slice-validate") + (Worker-ArtArgs) + (Barracks-ArtArgs -Expected $MismatchSha -FallbackMode "hash-mismatch")) -ExpectedFiles @("player-slice-validation-runtime.json")
Invoke-V0163Tool -Command "validation"

$CaptureRoot = Join-Path $ArtifactRoot "capture"
Reset-SafeDirectory -Path $CaptureRoot -Parent $ArtifactRoot
Invoke-GodotScenario -ScenarioRoot (Join-Path $CaptureRoot "default-procedural") -ScenarioArgs @("--player-slice-capture") -ExpectedFiles @("screenshot-runtime-manifest.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $CaptureRoot "worker-only") -ScenarioArgs (@("--player-slice-capture") + (Worker-ArtArgs)) -ExpectedFiles @("screenshot-runtime-manifest.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $CaptureRoot "worker-barracks") -ScenarioArgs (@("--player-slice-capture") + (Worker-ArtArgs) + (Barracks-ArtArgs)) -ExpectedFiles @("screenshot-runtime-manifest.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $CaptureRoot "barracks-missing-art-fallback") -ScenarioArgs (@("--player-slice-capture") + (Worker-ArtArgs) + (Barracks-ArtArgs -Source $MissingBarracksSourcePath -FallbackMode "missing")) -ExpectedFiles @("screenshot-runtime-manifest.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $CaptureRoot "barracks-hash-mismatch-fallback") -ScenarioArgs (@("--player-slice-capture") + (Worker-ArtArgs) + (Barracks-ArtArgs -Expected $MismatchSha -FallbackMode "hash-mismatch")) -ExpectedFiles @("screenshot-runtime-manifest.json")
Invoke-V0163Tool -Command "capture"

$BenchmarkRoot = Join-Path $ArtifactRoot "benchmark"
Reset-SafeDirectory -Path $BenchmarkRoot -Parent $ArtifactRoot
Invoke-GodotScenario -ScenarioRoot (Join-Path $BenchmarkRoot "procedural-baseline") -ScenarioArgs @("--worker-art-opt-in-benchmark") -ExpectedFiles @("worker-art-opt-in-benchmark-runtime.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $BenchmarkRoot "worker-only") -ScenarioArgs (@("--worker-art-opt-in-benchmark") + (Worker-ArtArgs)) -ExpectedFiles @("worker-art-opt-in-benchmark-runtime.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $BenchmarkRoot "worker-barracks") -ScenarioArgs (@("--worker-art-opt-in-benchmark") + (Worker-ArtArgs) + (Barracks-ArtArgs)) -ExpectedFiles @("worker-art-opt-in-benchmark-runtime.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $BenchmarkRoot "barracks-missing-art-fallback") -ScenarioArgs (@("--worker-art-opt-in-benchmark") + (Worker-ArtArgs) + (Barracks-ArtArgs -Source $MissingBarracksSourcePath -FallbackMode "missing")) -ExpectedFiles @("worker-art-opt-in-benchmark-runtime.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $BenchmarkRoot "barracks-hash-mismatch-fallback") -ScenarioArgs (@("--worker-art-opt-in-benchmark") + (Worker-ArtArgs) + (Barracks-ArtArgs -Expected $MismatchSha -FallbackMode "hash-mismatch")) -ExpectedFiles @("worker-art-opt-in-benchmark-runtime.json")
Invoke-V0163Tool -Command "benchmark"

$RealInputRoot = Join-Path $ArtifactRoot "real-input"
Reset-SafeDirectory -Path $RealInputRoot -Parent $ArtifactRoot
Invoke-GodotScenario -ScenarioRoot (Join-Path $RealInputRoot "worker-barracks-post-mine-flow") -ScenarioArgs (@("--post-mine-flow-validate") + (Worker-ArtArgs) + (Barracks-ArtArgs)) -ExpectedFiles @("headed-post-mine-flow-smoke.json", "barracks-restoration-proof.json", "militia-recruit-proof.json", "lume-restore-proof.json", "screenshot-manifest.json")
Invoke-GodotScenario -ScenarioRoot (Join-Path $RealInputRoot "worker-barracks-restart-replay") -ScenarioArgs (@("--triple-natural-playthrough") + (Worker-ArtArgs) + (Barracks-ArtArgs)) -ExpectedFiles @("triple-playthrough-report.json", "recovery-case-report.json", "restart-integrity-report.json", "no-softlock-proof.json", "no-shortcut-proof.json", "screenshot-manifest.json")
Invoke-V0163Tool -Command "real-input"

Invoke-V0163Tool -Command "boundary"

Write-Output "PASS_V0163_WORKER_BARRACKS_ART_OPT_IN_HARDENING_AUTOMATION_READY"
