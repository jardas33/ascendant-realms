param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ExePath = Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe"
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0229"
$BenchmarkRoot = Join-Path $ArtifactRoot "benchmark"
Set-Location $RepoRoot
if (Test-Path $BenchmarkRoot) { Remove-Item $BenchmarkRoot -Recurse -Force }
New-Item -ItemType Directory -Force -Path $BenchmarkRoot | Out-Null
function Wait-Report([string]$Path) {
  $deadline = (Get-Date).AddSeconds(180)
  while (-not (Test-Path $Path) -and (Get-Date) -lt $deadline) { Start-Sleep -Milliseconds 500 }
  if (-not (Test-Path $Path)) { throw "Missing benchmark $Path" }
}
function Invoke-Reboot([string]$Id, [string[]]$ExtraArgs) {
  $root = Join-Path $BenchmarkRoot $Id
  New-Item -ItemType Directory -Force -Path $root | Out-Null
  try {
    & (Join-Path $PSScriptRoot "launchGodotSaltoPresentationRebootWindows.ps1") -Wait `
      "--worker-art-opt-in-benchmark" "--artifact-root=$($root.Replace('\','/'))" @ExtraArgs
  } catch {}
  Wait-Report (Join-Path $root "worker-art-opt-in-benchmark-runtime.json")
}
$default = Join-Path $BenchmarkRoot "default-procedural"
New-Item -ItemType Directory -Force -Path $default | Out-Null
& $ExePath "--worker-art-opt-in-benchmark" "--artifact-root=$($default.Replace('\','/'))"
Wait-Report (Join-Path $default "worker-art-opt-in-benchmark-runtime.json")
Invoke-Reboot "selected-v0228-comparator" @("--salto-hud-visual-language", "--salto-production-battlefield-backplate")
Invoke-Reboot "selected-structure-landmark-fidelity" @("--salto-hud-visual-language", "--salto-structure-landmark-fidelity")
node tools/godot/saltoStructureLandmarkFidelityTool.mjs benchmark "--artifact-root=$($ArtifactRoot.Replace('\','/'))"
if ($LASTEXITCODE -ne 0) { throw "v0.229 benchmark failed." }
Write-Output "PASS_V0229_STRUCTURE_LANDMARK_FIDELITY_BENCHMARK_READY"
