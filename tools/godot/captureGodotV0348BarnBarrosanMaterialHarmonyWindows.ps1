$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$Project = Join-Path $RepoRoot 'desktop-spikes\godot-salto'; $CaptureRoot = Join-Path $RepoRoot 'artifacts\runtime\v0348'; $Godot = Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64.exe'; $GodotConsole = Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64_console.exe'
if (-not (Test-Path -LiteralPath $Godot)) { throw 'Godot executable not found in .tools\godot' }
if (-not (Test-Path -LiteralPath $GodotConsole)) { throw 'Godot console executable not found in .tools\godot' }
$import = & $GodotConsole --headless --editor --path $Project --quit-after 120
if ($LASTEXITCODE -ne 0) { throw 'v0.348 Godot import scan failed' }
if (Test-Path -LiteralPath $CaptureRoot) { Remove-Item -LiteralPath $CaptureRoot -Recurse -Force }
New-Item -ItemType Directory -Force -Path $CaptureRoot | Out-Null
$env:V0348_ARTIFACT_ROOT = $CaptureRoot.Replace('\','/'); $env:V0348_INTERNAL_OUTCOME = 'READY FOR HUMAN V0348 BARN MATERIAL-HARMONY GOLD-CANDIDATE REVIEW'
$args = '--path "{0}" --rendering-method gl_compatibility --rendering-driver opengl3 --scene res://scenes/review/V0348BarnBarrosanMaterialHarmony.tscn' -f $Project
$run = Start-Process -FilePath $Godot -ArgumentList $args -WorkingDirectory $Project -Wait -PassThru
if ($run.ExitCode -ne 0) { throw "v0.348 Godot capture failed with exit code $($run.ExitCode)" }
if (-not (Test-Path (Join-Path $CaptureRoot 'v0348-barn-material-harmony-runtime.json'))) { throw 'v0.348 Godot capture did not write a manifest' }
Remove-Item Env:V0348_ARTIFACT_ROOT -ErrorAction SilentlyContinue; Remove-Item Env:V0348_INTERNAL_OUTCOME -ErrorAction SilentlyContinue
Write-Output 'PASS_V0348_BARN_MATERIAL_HARMONY_CAPTURE_READY'
