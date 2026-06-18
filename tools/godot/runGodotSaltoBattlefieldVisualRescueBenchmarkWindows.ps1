param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ExePath = Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe"
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0227"
$BenchmarkRoot = Join-Path $ArtifactRoot "benchmark"
$ArtifactRootArg = $ArtifactRoot.Replace("\", "/")
Set-Location $RepoRoot

if (Test-Path -LiteralPath $BenchmarkRoot) { Remove-Item -LiteralPath $BenchmarkRoot -Recurse -Force }
New-Item -ItemType Directory -Force -Path $BenchmarkRoot | Out-Null

function Wait-Report([string]$Path) {
  $deadline = (Get-Date).AddSeconds(180)
  while (-not (Test-Path -LiteralPath $Path) -and (Get-Date) -lt $deadline) { Start-Sleep -Milliseconds 500 }
  if (-not (Test-Path -LiteralPath $Path)) { throw "Missing benchmark report: $Path" }
}

$DefaultRoot = Join-Path $BenchmarkRoot "default-procedural"
New-Item -ItemType Directory -Force -Path $DefaultRoot | Out-Null
& $ExePath "--worker-art-opt-in-benchmark" "--artifact-root=$($DefaultRoot.Replace('\', '/'))"
Wait-Report (Join-Path $DefaultRoot "worker-art-opt-in-benchmark-runtime.json")

function Invoke-RebootBenchmark([string]$Id, [string[]]$ExtraArgs) {
  $root = Join-Path $BenchmarkRoot $Id
  New-Item -ItemType Directory -Force -Path $root | Out-Null
  try {
    & (Join-Path $PSScriptRoot "launchGodotSaltoPresentationRebootWindows.ps1") -Wait `
      "--worker-art-opt-in-benchmark" "--artifact-root=$($root.Replace('\', '/'))" @ExtraArgs
  } catch {
    Write-Output "Packaged benchmark returned nonzero for $Id; applying the artifact gate."
  }
  Wait-Report (Join-Path $root "worker-art-opt-in-benchmark-runtime.json")
}

Invoke-RebootBenchmark "selected-v0224-comparator" @("--salto-hud-visual-language", "--salto-integrated-reference-gap")
Invoke-RebootBenchmark "selected-battlefield-visual-rescue" @("--salto-hud-visual-language", "--salto-battlefield-visual-rescue")
node tools/godot/saltoBattlefieldVisualRescueTool.mjs benchmark "--artifact-root=$ArtifactRootArg"
if ($LASTEXITCODE -ne 0) { throw "v0.227 benchmark report failed." }
Write-Output "PASS_V0227_BATTLEFIELD_VISUAL_RESCUE_BENCHMARK_READY"
