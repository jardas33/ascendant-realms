$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$Project = Join-Path $RepoRoot 'desktop-spikes\godot-salto'
$CaptureRoot = Join-Path $RepoRoot 'artifacts\runtime\v0345'
$Godot = Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64.exe'
if (-not (Test-Path -LiteralPath $Godot)) { throw 'Godot executable not found in .tools\godot' }
if (Test-Path -LiteralPath $CaptureRoot) { Remove-Item -LiteralPath $CaptureRoot -Recurse -Force }
New-Item -ItemType Directory -Force -Path $CaptureRoot | Out-Null
$env:V0345_ARTIFACT_ROOT = $CaptureRoot.Replace('\','/')
$env:V0345_INTERNAL_OUTCOME = 'READY FOR HUMAN V0345 BARN PROPORTION-AND-ROOF VISUAL REVIEW'
$args = '--path "{0}" --rendering-method gl_compatibility --rendering-driver opengl3 --scene res://scenes/review/V0345BarnProportionSimpleSlateRoofReset.tscn' -f $Project
$run = Start-Process -FilePath $Godot -ArgumentList $args -WorkingDirectory $Project -Wait -PassThru
if ($run.ExitCode -ne 0) { throw "v0.345 Godot capture failed with exit code $($run.ExitCode)" }
Remove-Item Env:V0345_ARTIFACT_ROOT -ErrorAction SilentlyContinue
Remove-Item Env:V0345_INTERNAL_OUTCOME -ErrorAction SilentlyContinue
Write-Output 'PASS_V0345_BARN_PROPORTION_SIMPLE_SLATE_ROOF_CAPTURE_READY'
