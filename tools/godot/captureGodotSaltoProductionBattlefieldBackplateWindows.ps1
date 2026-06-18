param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0228"
$CaptureRoot = Join-Path $ArtifactRoot "capture"
$ScenarioRoot = Join-Path $CaptureRoot "selected-production-battlefield-backplate"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0228-production-battlefield-backplate"
Set-Location $RepoRoot
if (Test-Path -LiteralPath $CaptureRoot) { Remove-Item -LiteralPath $CaptureRoot -Recurse -Force }
if (Test-Path -LiteralPath $ManualRoot) { Remove-Item -LiteralPath $ManualRoot -Recurse -Force }
New-Item -ItemType Directory -Force -Path $ScenarioRoot | Out-Null
& (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
& (Join-Path $PSScriptRoot "packageGodotWindows.ps1")
& (Join-Path $PSScriptRoot "launchGodotSaltoPresentationRebootWindows.ps1") -Wait `
  "--player-slice-capture" "--artifact-root=$($ScenarioRoot.Replace('\','/'))" `
  "--salto-hud-visual-language" "--salto-production-battlefield-backplate"
$Manifest = Join-Path $ScenarioRoot "screenshot-runtime-manifest.json"
$Deadline = (Get-Date).AddSeconds(360)
while ((Get-Date) -lt $Deadline) {
  if (Test-Path -LiteralPath $Manifest) {
    try { if ((Get-Content $Manifest -Raw | ConvertFrom-Json).status -eq "PASS_PLAYER_SLICE_CAPTURE") { break } } catch {}
  }
  Start-Sleep -Milliseconds 500
}
if (-not (Test-Path -LiteralPath $Manifest)) { throw "Missing v0.228 capture manifest." }
node tools/godot/saltoProductionBattlefieldBackplateTool.mjs capture "--artifact-root=$($ArtifactRoot.Replace('\','/'))"
if ($LASTEXITCODE -ne 0) { throw "v0.228 review-pack generation failed." }
$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
if (-not (Test-Path -LiteralPath $Python)) { $Python = "python" }
& $Python tools/godot/buildV0228BeforeAfterContactSheet.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.228 contact sheet failed." }
Write-Output "PASS_V0228_PRODUCTION_BATTLEFIELD_BACKPLATE_CAPTURE_READY"
