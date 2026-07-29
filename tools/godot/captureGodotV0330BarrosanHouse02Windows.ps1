$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location $RepoRoot
$CaptureRoot = Join-Path $RepoRoot 'artifacts\desktop-spikes\godot-salto\v0330'
$GodotConsole = Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64_console.exe'
$GodotGui = Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64.exe'
$Project = Join-Path $RepoRoot 'desktop-spikes\godot-salto'
$Python = 'C:\Users\barro\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
if (Test-Path -LiteralPath $CaptureRoot) { Remove-Item -LiteralPath $CaptureRoot -Recurse -Force }
New-Item -ItemType Directory -Force -Path $CaptureRoot | Out-Null
& $GodotConsole --headless --editor --path $Project --quit-after 120
if ($LASTEXITCODE -ne 0) { throw 'v0.330 Godot import scan failed' }
$env:V0330_ARTIFACT_ROOT = $CaptureRoot.Replace('\','/')
$argumentString = '--path "{0}" --rendering-method gl_compatibility --rendering-driver opengl3 --scene res://scenes/review/V0330BarrosanHouse02Review.tscn' -f $Project
$process = Start-Process -FilePath $GodotGui -ArgumentList $argumentString -WorkingDirectory $Project -Wait -PassThru
Remove-Item Env:V0330_ARTIFACT_ROOT -ErrorAction SilentlyContinue
if ($process.ExitCode -ne 0) { throw "v0.330 Godot capture failed with exit code $($process.ExitCode)" }
$env:V0330_ARTIFACT_ROOT = $CaptureRoot.Replace('\','/')
$env:V0330_BENCHMARK_ONLY = '1'
$benchmark = Start-Process -FilePath $GodotGui -ArgumentList $argumentString -WorkingDirectory $Project -Wait -PassThru
Remove-Item Env:V0330_ARTIFACT_ROOT -ErrorAction SilentlyContinue
Remove-Item Env:V0330_BENCHMARK_ONLY -ErrorAction SilentlyContinue
if ($benchmark.ExitCode -ne 0) { throw "v0.330 benchmark failed with exit code $($benchmark.ExitCode)" }
& $Python 'tools/godot/buildV0330BarrosanHouse02ReviewPack.py'
if ($LASTEXITCODE -ne 0) { throw 'v0.330 review-pack builder failed' }
Write-Output 'PASS_V0330_BARROSAN_HOUSE_02_CAPTURE_PACK_READY'
