param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ExePath = Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe"
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0228"
$ValidationRoot = Join-Path $ArtifactRoot "validation"
Set-Location $RepoRoot
if (-not (Test-Path (Join-Path $ArtifactRoot "capture\selected-production-battlefield-backplate\screenshot-runtime-manifest.json"))) {
  & (Join-Path $PSScriptRoot "captureGodotSaltoProductionBattlefieldBackplateWindows.ps1")
}
if (Test-Path $ValidationRoot) { Remove-Item $ValidationRoot -Recurse -Force }
New-Item -ItemType Directory -Force -Path $ValidationRoot | Out-Null
function Wait-Pass([string]$Path) {
  $deadline=(Get-Date).AddSeconds(360)
  while((Get-Date)-lt $deadline){if(Test-Path $Path){try{if((Get-Content $Path -Raw|ConvertFrom-Json).status-eq"PASS_PLAYER_SLICE_VALIDATION"){return}}catch{}};Start-Sleep -Milliseconds 500}
  throw "Validation did not pass: $Path"
}
function Invoke-Reboot([string]$Id,[string[]]$ExtraArgs){
  $root=Join-Path $ValidationRoot $Id; New-Item -ItemType Directory -Force -Path $root|Out-Null
  try{& (Join-Path $PSScriptRoot "launchGodotSaltoPresentationRebootWindows.ps1") -Wait "--player-slice-validate" "--artifact-root=$($root.Replace('\','/'))" @ExtraArgs}catch{}
  Wait-Pass (Join-Path $root "player-slice-validation-runtime.json")
}
$default=Join-Path $ValidationRoot "default-procedural";New-Item -ItemType Directory -Force -Path $default|Out-Null
& $ExePath "--player-slice-validate" "--artifact-root=$($default.Replace('\','/'))";Wait-Pass (Join-Path $default "player-slice-validation-runtime.json")
Invoke-Reboot "selected-v0227-comparator" @("--salto-hud-visual-language","--salto-battlefield-visual-rescue")
Invoke-Reboot "selected-production-battlefield-backplate" @("--salto-hud-visual-language","--salto-production-battlefield-backplate")
Invoke-Reboot "ground-missing-fallback" @("--salto-hud-visual-language","--salto-production-battlefield-backplate","--salto-presentation-reboot-ground-missing-fallback")
node tools/godot/saltoProductionBattlefieldBackplateTool.mjs validation "--artifact-root=$($ArtifactRoot.Replace('\','/'))"
if($LASTEXITCODE-ne 0){throw "v0.228 validation report failed."}
node scripts/cleanupSaltoExperimentalArtifacts.mjs "--output-root=$((Join-Path $ArtifactRoot 'cleanup-dry-run').Replace('\','/'))"
if($LASTEXITCODE-ne 0){throw "v0.228 cleanup dry run failed."}
Write-Output "PASS_V0228_PRODUCTION_BATTLEFIELD_BACKPLATE_VALIDATION_READY"
