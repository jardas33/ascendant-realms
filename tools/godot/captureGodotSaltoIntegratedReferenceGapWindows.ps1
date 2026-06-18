param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0224"
$CaptureRoot = Join-Path $ArtifactRoot "capture"
$ScenarioRoot = Join-Path $CaptureRoot "selected-integrated-reference-gap"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0224-integrated-reference-gap-review"
$ArtifactRootArg = $ArtifactRoot.Replace("\", "/")
$ScenarioRootArg = $ScenarioRoot.Replace("\", "/")
Set-Location $RepoRoot

if (Test-Path -LiteralPath $CaptureRoot) { Remove-Item -LiteralPath $CaptureRoot -Recurse -Force }
New-Item -ItemType Directory -Force -Path $ScenarioRoot | Out-Null

& (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
& (Join-Path $PSScriptRoot "packageGodotWindows.ps1")
& (Join-Path $PSScriptRoot "launchGodotSaltoPresentationRebootWindows.ps1") -Wait `
  "--player-slice-capture" "--artifact-root=$ScenarioRootArg" `
  "--salto-hud-visual-language" "--salto-integrated-reference-gap"

$Manifest = Join-Path $ScenarioRoot "screenshot-runtime-manifest.json"
$Deadline = (Get-Date).AddSeconds(360)
$CapturePassed = $false
while ((Get-Date) -lt $Deadline) {
  if (Test-Path -LiteralPath $Manifest) {
    try {
      $Report = Get-Content -LiteralPath $Manifest -Raw | ConvertFrom-Json
      if ($Report.status -eq "PASS_PLAYER_SLICE_CAPTURE") {
        $CapturePassed = $true
        break
      }
    } catch {}
  }
  Start-Sleep -Milliseconds 500
}
if (-not $CapturePassed) { throw "v0.224 capture did not reach PASS_PLAYER_SLICE_CAPTURE." }

node tools/godot/saltoIntegratedReferenceGapTool.mjs capture "--artifact-root=$ArtifactRootArg"
if ($LASTEXITCODE -ne 0) { throw "v0.224 review-pack generation failed." }

$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
if (-not (Test-Path -LiteralPath $Python)) { $Python = "python" }
& $Python tools/godot/buildV0224ContactSheet.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.224 contact sheet generation failed." }
Write-Output "PASS_V0224_INTEGRATED_REFERENCE_GAP_CAPTURE_READY"
