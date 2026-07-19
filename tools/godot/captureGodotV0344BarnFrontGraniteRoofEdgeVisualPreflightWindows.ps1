$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location $RepoRoot
$CaptureRoot = Join-Path $RepoRoot 'artifacts\runtime\v0344'
$DiagnosticRoot = Join-Path $RepoRoot 'artifacts\runtime\v0344-diagnostics'
$Godot = Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64.exe'
$Project = Join-Path $RepoRoot 'desktop-spikes\godot-salto'
if (Test-Path -LiteralPath $CaptureRoot) { Remove-Item -LiteralPath $CaptureRoot -Recurse -Force }
if (Test-Path -LiteralPath $DiagnosticRoot) { Remove-Item -LiteralPath $DiagnosticRoot -Recurse -Force }
New-Item -ItemType Directory -Force -Path $CaptureRoot | Out-Null
New-Item -ItemType Directory -Force -Path $DiagnosticRoot | Out-Null
$env:V0331_ARTIFACT_ROOT = $CaptureRoot.Replace('\','/')
$env:V0344_INTERNAL_DIAGNOSTICS_ROOT = $DiagnosticRoot.Replace('\','/')
$env:V0344_PREFLIGHT_OUTCOME = 'READY FOR HUMAN V0344 BARN MATERIAL-AND-ROOF VISUAL PREFLIGHT REVIEW'
$args = '--path "{0}" --rendering-method gl_compatibility --rendering-driver opengl3 --scene res://scenes/review/V0344BarnFrontGraniteRoofEdgeVisualPreflight.tscn' -f $Project
$run = Start-Process -FilePath $Godot -ArgumentList $args -WorkingDirectory $Project -Wait -PassThru
Remove-Item Env:V0331_ARTIFACT_ROOT -ErrorAction SilentlyContinue
Remove-Item Env:V0344_INTERNAL_DIAGNOSTICS_ROOT -ErrorAction SilentlyContinue
Remove-Item Env:V0344_PREFLIGHT_OUTCOME -ErrorAction SilentlyContinue
if ($run.ExitCode -ne 0) { throw "v0.344 Godot capture failed with exit code $($run.ExitCode)" }
Write-Output 'PASS_V0344_BARN_FRONT_GRANITE_ROOF_EDGE_VISUAL_PREFLIGHT_CAPTURE_READY'
