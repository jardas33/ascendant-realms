param()
$ErrorActionPreference="Stop"
$RepoRoot=Resolve-Path(Join-Path $PSScriptRoot "..\..")
$ExePath=Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe"
$ArtifactRoot=Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0228"
$BenchmarkRoot=Join-Path $ArtifactRoot "benchmark"
Set-Location $RepoRoot
if(Test-Path $BenchmarkRoot){Remove-Item $BenchmarkRoot -Recurse -Force};New-Item -ItemType Directory -Force -Path $BenchmarkRoot|Out-Null
function Wait-Report([string]$Path){$d=(Get-Date).AddSeconds(180);while(-not(Test-Path $Path)-and(Get-Date)-lt$d){Start-Sleep -Milliseconds 500};if(-not(Test-Path $Path)){throw "Missing benchmark $Path"}}
$default=Join-Path $BenchmarkRoot "default-procedural";New-Item -ItemType Directory -Force -Path $default|Out-Null
& $ExePath "--worker-art-opt-in-benchmark" "--artifact-root=$($default.Replace('\','/'))";Wait-Report(Join-Path $default "worker-art-opt-in-benchmark-runtime.json")
function Invoke-Reboot([string]$Id,[string[]]$ExtraArgs){$root=Join-Path $BenchmarkRoot $Id;New-Item -ItemType Directory -Force -Path $root|Out-Null;try{& (Join-Path $PSScriptRoot "launchGodotSaltoPresentationRebootWindows.ps1") -Wait "--worker-art-opt-in-benchmark" "--artifact-root=$($root.Replace('\','/'))" @ExtraArgs}catch{};Wait-Report(Join-Path $root "worker-art-opt-in-benchmark-runtime.json")}
Invoke-Reboot "selected-v0227-comparator" @("--salto-hud-visual-language","--salto-battlefield-visual-rescue")
Invoke-Reboot "selected-production-battlefield-backplate" @("--salto-hud-visual-language","--salto-production-battlefield-backplate")
node tools/godot/saltoProductionBattlefieldBackplateTool.mjs benchmark "--artifact-root=$($ArtifactRoot.Replace('\','/'))"
if($LASTEXITCODE-ne 0){throw "v0.228 benchmark failed."}
Write-Output "PASS_V0228_PRODUCTION_BATTLEFIELD_BACKPLATE_BENCHMARK_READY"
