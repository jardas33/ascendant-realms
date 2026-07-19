$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$Project = Join-Path $RepoRoot 'desktop-spikes\godot-salto'; $CaptureRoot = Join-Path $RepoRoot 'artifacts\runtime\v0347'; $Godot = Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64.exe'
if (-not (Test-Path -LiteralPath $Godot)) { throw 'Godot executable not found in .tools\godot' }
if (Test-Path -LiteralPath $CaptureRoot) { Remove-Item -LiteralPath $CaptureRoot -Recurse -Force }
New-Item -ItemType Directory -Force -Path $CaptureRoot | Out-Null
$env:V0347_ARTIFACT_ROOT = $CaptureRoot.Replace('\','/'); $env:V0347_INTERNAL_OUTCOME = 'READY FOR HUMAN V0347 BARN RENDERED-GEOMETRY REVIEW'
$args = '--path "{0}" --rendering-method gl_compatibility --rendering-driver opengl3 --scene res://scenes/review/V0347BarnRenderedGeometryTruth.tscn' -f $Project
$run = Start-Process -FilePath $Godot -ArgumentList $args -WorkingDirectory $Project -Wait -PassThru
if ($run.ExitCode -ne 0) { throw "v0.347 Godot capture failed with exit code $($run.ExitCode)" }
if (-not (Test-Path (Join-Path $CaptureRoot 'v0347-barn-rendered-geometry-truth-runtime.json'))) { throw 'v0.347 Godot capture did not write a manifest' }
Remove-Item Env:V0347_ARTIFACT_ROOT -ErrorAction SilentlyContinue; Remove-Item Env:V0347_INTERNAL_OUTCOME -ErrorAction SilentlyContinue
Write-Output 'PASS_V0347_BARN_RENDERED_GEOMETRY_TRUTH_CAPTURE_READY'
