param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ExePath = Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe"
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0227"
$ValidationRoot = Join-Path $ArtifactRoot "validation"
$ArtifactRootArg = $ArtifactRoot.Replace("\", "/")
Set-Location $RepoRoot

if (-not (Test-Path -LiteralPath (Join-Path $ArtifactRoot "capture\selected-battlefield-visual-rescue\screenshot-runtime-manifest.json"))) {
  & (Join-Path $PSScriptRoot "captureGodotSaltoBattlefieldVisualRescueWindows.ps1")
}
if (Test-Path -LiteralPath $ValidationRoot) { Remove-Item -LiteralPath $ValidationRoot -Recurse -Force }
New-Item -ItemType Directory -Force -Path $ValidationRoot | Out-Null

function Wait-Pass([string]$Path) {
  $deadline = (Get-Date).AddSeconds(360)
  while ((Get-Date) -lt $deadline) {
    if (Test-Path -LiteralPath $Path) {
      try {
        $report = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
        if ($report.status -eq "PASS_PLAYER_SLICE_VALIDATION") { return }
      } catch {}
    }
    Start-Sleep -Milliseconds 500
  }
  throw "Validation did not reach PASS_PLAYER_SLICE_VALIDATION: $Path"
}

function Invoke-Reboot([string]$Id, [string[]]$ExtraArgs) {
  $root = Join-Path $ValidationRoot $Id
  New-Item -ItemType Directory -Force -Path $root | Out-Null
  $rootArg = $root.Replace("\", "/")
  try {
    & (Join-Path $PSScriptRoot "launchGodotSaltoPresentationRebootWindows.ps1") -Wait `
      "--player-slice-validate" "--artifact-root=$rootArg" @ExtraArgs
  } catch {
    Write-Output "Packaged Godot returned nonzero for $Id; applying the runtime manifest gate."
  }
  Wait-Pass (Join-Path $root "player-slice-validation-runtime.json")
}

$DefaultRoot = Join-Path $ValidationRoot "default-procedural"
New-Item -ItemType Directory -Force -Path $DefaultRoot | Out-Null
$DefaultArg = $DefaultRoot.Replace("\", "/")
& $ExePath "--player-slice-validate" "--artifact-root=$DefaultArg"
Wait-Pass (Join-Path $DefaultRoot "player-slice-validation-runtime.json")

Invoke-Reboot "selected-v0224-comparator" @("--salto-hud-visual-language", "--salto-integrated-reference-gap")
Invoke-Reboot "selected-battlefield-visual-rescue" @("--salto-hud-visual-language", "--salto-battlefield-visual-rescue")
Invoke-Reboot "ground-missing-fallback" @("--salto-hud-visual-language", "--salto-battlefield-visual-rescue", "--salto-presentation-reboot-ground-missing-fallback")

node tools/godot/saltoBattlefieldVisualRescueTool.mjs validation "--artifact-root=$ArtifactRootArg"
if ($LASTEXITCODE -ne 0) { throw "v0.227 validation report failed." }
node scripts/cleanupSaltoExperimentalArtifacts.mjs "--output-root=$((Join-Path $ArtifactRoot 'cleanup-dry-run').Replace('\', '/'))"
if ($LASTEXITCODE -ne 0) { throw "v0.227 cleanup dry-run failed." }
Write-Output "PASS_V0227_BATTLEFIELD_VISUAL_RESCUE_VALIDATION_READY"
