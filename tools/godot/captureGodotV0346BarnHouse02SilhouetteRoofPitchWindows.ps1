$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$Project = Join-Path $RepoRoot 'desktop-spikes\godot-salto'; $CaptureRoot = Join-Path $RepoRoot 'artifacts\runtime\v0346'; $Godot = Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64.exe'
if (-not (Test-Path -LiteralPath $Godot)) { throw 'Godot executable not found in .tools\godot' }
if (Test-Path -LiteralPath $CaptureRoot) { Remove-Item -LiteralPath $CaptureRoot -Recurse -Force }
New-Item -ItemType Directory -Force -Path $CaptureRoot | Out-Null
$env:V0346_ARTIFACT_ROOT = $CaptureRoot.Replace('\','/'); $env:V0346_INTERNAL_OUTCOME = 'READY FOR HUMAN V0346 BARN HOUSE02-FAMILY SILHOUETTE REVIEW'
$args = '--path "{0}" --rendering-method gl_compatibility --rendering-driver opengl3 --scene res://scenes/review/V0346BarnHouse02SilhouetteRoofPitch.tscn' -f $Project
$run = Start-Process -FilePath $Godot -ArgumentList $args -WorkingDirectory $Project -Wait -PassThru
if ($run.ExitCode -ne 0) { throw "v0.346 Godot capture failed with exit code $($run.ExitCode)" }
Remove-Item Env:V0346_ARTIFACT_ROOT -ErrorAction SilentlyContinue; Remove-Item Env:V0346_INTERNAL_OUTCOME -ErrorAction SilentlyContinue
Write-Output 'PASS_V0346_BARN_HOUSE02_SILHOUETTE_ROOF_PITCH_CAPTURE_READY'
