param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0229"
$CaptureRoot = Join-Path $ArtifactRoot "capture"
$ScenarioRoot = Join-Path $CaptureRoot "selected-structure-landmark-fidelity"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0229-structure-landmark-fidelity"
Set-Location $RepoRoot
if (Test-Path -LiteralPath $CaptureRoot) { Remove-Item -LiteralPath $CaptureRoot -Recurse -Force }
if (Test-Path -LiteralPath $ManualRoot) { Remove-Item -LiteralPath $ManualRoot -Recurse -Force }
New-Item -ItemType Directory -Force -Path $ScenarioRoot | Out-Null
& (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
& (Join-Path $PSScriptRoot "packageGodotWindows.ps1")
& (Join-Path $PSScriptRoot "launchGodotSaltoPresentationRebootWindows.ps1") -Wait `
  "--player-slice-capture" "--artifact-root=$($ScenarioRoot.Replace('\','/'))" `
  "--salto-hud-visual-language" "--salto-structure-landmark-fidelity"
$Manifest = Join-Path $ScenarioRoot "screenshot-runtime-manifest.json"
$Deadline = (Get-Date).AddSeconds(360)
while ((Get-Date) -lt $Deadline) {
  if (Test-Path -LiteralPath $Manifest) {
    try { if ((Get-Content $Manifest -Raw | ConvertFrom-Json).status -eq "PASS_PLAYER_SLICE_CAPTURE") { break } } catch {}
  }
  Start-Sleep -Milliseconds 500
}
if (-not (Test-Path -LiteralPath $Manifest)) { throw "Missing v0.229 capture manifest." }
node tools/godot/saltoStructureLandmarkFidelityTool.mjs capture "--artifact-root=$($ArtifactRoot.Replace('\','/'))"
if ($LASTEXITCODE -ne 0) { throw "v0.229 review-pack generation failed." }
$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
if (-not (Test-Path -LiteralPath $Python)) { $Python = "python" }
& $Python tools/godot/buildV0229BeforeAfterContactSheet.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.229 contact sheet failed." }
Write-Output "PASS_V0229_STRUCTURE_LANDMARK_FIDELITY_CAPTURE_READY"
