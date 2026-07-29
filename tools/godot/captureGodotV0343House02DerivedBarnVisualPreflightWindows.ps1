$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location $RepoRoot
$CaptureRoot = Join-Path $RepoRoot 'artifacts\runtime\v0343'
$Godot = Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64.exe'
$Project = Join-Path $RepoRoot 'desktop-spikes\godot-salto'
if (Test-Path -LiteralPath $CaptureRoot) { Remove-Item -LiteralPath $CaptureRoot -Recurse -Force }
New-Item -ItemType Directory -Force -Path $CaptureRoot | Out-Null
$env:V0331_ARTIFACT_ROOT = $CaptureRoot.Replace('\','/')
$env:V0343_PREFLIGHT_OUTCOME = 'REJECTED INTERNALLY ' + [char]0x2014 + ' HOUSE02-DERIVED BARN STILL FAILS THE VISUAL PREFLIGHT'
$args = '--path "{0}" --rendering-method gl_compatibility --rendering-driver opengl3 --scene res://scenes/review/V0343House02DerivedBarnVisualPreflight.tscn' -f $Project
$run = Start-Process -FilePath $Godot -ArgumentList $args -WorkingDirectory $Project -Wait -PassThru
Remove-Item Env:V0331_ARTIFACT_ROOT -ErrorAction SilentlyContinue
Remove-Item Env:V0343_PREFLIGHT_OUTCOME -ErrorAction SilentlyContinue
if ($run.ExitCode -ne 0) { throw "v0.343 Godot capture failed with exit code $($run.ExitCode)" }
Write-Output 'PASS_V0343_HOUSE02_DERIVED_BARN_VISUAL_PREFLIGHT_CAPTURE_READY'
