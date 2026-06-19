param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0232"
$SpikeRoot = Join-Path $ArtifactRoot "production-target-spike"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0232-visual-pipeline-reset"
Set-Location $RepoRoot
if (Test-Path -LiteralPath $ArtifactRoot) { Remove-Item -LiteralPath $ArtifactRoot -Recurse -Force }
if (Test-Path -LiteralPath $ManualRoot) { Remove-Item -LiteralPath $ManualRoot -Recurse -Force }
New-Item -ItemType Directory -Force -Path $SpikeRoot | Out-Null
New-Item -ItemType Directory -Force -Path $ManualRoot | Out-Null
& (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
& (Join-Path $PSScriptRoot "packageGodotWindows.ps1")
$ExePath = Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe"
$GodotArgs = "--salto-production-target-spike `"--artifact-root=$($SpikeRoot.Replace('\','/'))`""
$Process = Start-Process -FilePath $ExePath -ArgumentList $GodotArgs -Wait -PassThru -WindowStyle Hidden
Write-Output "Godot spike capture process exit code: $($Process.ExitCode)"
$Manifest = Join-Path $SpikeRoot "v0232-production-target-spike-runtime.json"
if (-not (Test-Path -LiteralPath $Manifest)) { throw "Missing v0.232 production-target spike manifest." }
$Status = Get-Content $Manifest -Raw | ConvertFrom-Json
if ($Status.status -ne "PASS_V0232_PRODUCTION_TARGET_SPIKE") { throw "v0.232 production-target spike failed." }
node tools/godot/saltoVisualPipelineResetTool.mjs capture "--artifact-root=$($ArtifactRoot.Replace('\','/'))"
if ($LASTEXITCODE -ne 0) { throw "v0.232 review-pack generation failed." }
$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
& $Python tools/godot/buildV0232BeforeAfterContactSheet.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.232 contact sheet failed." }
Write-Output "PASS_V0232_VISUAL_PIPELINE_RESET_CAPTURE_READY"
