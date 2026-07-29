$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$Project = Join-Path $RepoRoot 'desktop-spikes\godot-salto'
$CaptureRoot = Join-Path $RepoRoot 'artifacts\runtime\v0355'
$Godot = Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64.exe'
$GodotConsole = Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64_console.exe'
if (-not (Test-Path $Godot)) { throw 'v0.355 Godot executable not found' }
if (-not (Test-Path $GodotConsole)) { throw 'v0.355 Godot console executable not found' }
$import = & $GodotConsole --headless --editor --path $Project --quit-after 120
if ($LASTEXITCODE -ne 0) { throw 'v0.355 Godot import scan failed' }
if (Test-Path $CaptureRoot) { Remove-Item $CaptureRoot -Recurse -Force }
New-Item -ItemType Directory -Force -Path $CaptureRoot | Out-Null
$env:V0355_ARTIFACT_ROOT = $CaptureRoot.Replace('\','/')
$args = '--path "{0}" --rendering-method gl_compatibility --rendering-driver opengl3 --scene res://scenes/review/V0355BarrosanBarnHumanGoldLock.tscn' -f $Project
$run = Start-Process -FilePath $Godot -ArgumentList $args -WorkingDirectory $Project -Wait -PassThru
if ($run.ExitCode -ne 0) { throw "v0.355 Godot capture failed with exit code $($run.ExitCode)" }
if (-not (Test-Path (Join-Path $CaptureRoot 'v0355-barrosan-barn-human-gold-lock-runtime.json'))) { throw 'v0.355 capture did not write a manifest' }
Remove-Item Env:V0355_ARTIFACT_ROOT -ErrorAction SilentlyContinue
Write-Output 'PASS_V0355_BARROSAN_BARN_HUMAN_GOLD_LOCK_CAPTURE_READY'
