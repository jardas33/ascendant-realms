$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location $RepoRoot
$CaptureRoot = Join-Path $RepoRoot 'artifacts\desktop-spikes\godot-salto\v0328'
$GodotConsole = Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64_console.exe'
$GodotGui = Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64.exe'
$Project = Join-Path $RepoRoot 'desktop-spikes\godot-salto'
$Python = 'C:\Users\barro\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
if (!(Test-Path -LiteralPath $Python)) { $Python = (Get-Command python).Source }
if (Test-Path -LiteralPath $CaptureRoot) { Remove-Item -LiteralPath $CaptureRoot -Recurse -Force }
New-Item -ItemType Directory -Force -Path $CaptureRoot | Out-Null
powershell -NoProfile -ExecutionPolicy Bypass -File 'tools/blender/generateV0328BarrosanHouseWindows.ps1'
& $GodotConsole --headless --editor --path $Project --quit-after 120
if ($LASTEXITCODE -ne 0) { throw 'v0.328 Godot import scan failed' }
$env:V0328_ARTIFACT_ROOT = $CaptureRoot.Replace('\','/')
$argumentString = '--path "{0}" --rendering-method gl_compatibility --rendering-driver opengl3 --scene res://scenes/review/V0328BarrosanHouseReview.tscn' -f $Project
$process = Start-Process -FilePath $GodotGui -ArgumentList $argumentString -WorkingDirectory $Project -Wait -PassThru
Remove-Item Env:V0328_ARTIFACT_ROOT -ErrorAction SilentlyContinue
if ($process.ExitCode -ne 0) { throw "v0.328 Godot capture failed with exit code $($process.ExitCode)" }
$env:V0328_ARTIFACT_ROOT = $CaptureRoot.Replace('\','/')
$env:V0328_BENCHMARK_ONLY = '1'
$benchmarkArguments = '--path "{0}" --rendering-method gl_compatibility --rendering-driver opengl3 --scene res://scenes/review/V0328BarrosanHouseReview.tscn' -f $Project
$benchmark = Start-Process -FilePath $GodotGui -ArgumentList $benchmarkArguments -WorkingDirectory $Project -Wait -PassThru
Remove-Item Env:V0328_ARTIFACT_ROOT -ErrorAction SilentlyContinue
Remove-Item Env:V0328_BENCHMARK_ONLY -ErrorAction SilentlyContinue
if ($benchmark.ExitCode -ne 0) { throw "v0.328 performance benchmark failed with exit code $($benchmark.ExitCode)" }
& $Python 'tools/godot/buildV0328BarrosanHouseReviewPack.py'
if ($LASTEXITCODE -ne 0) { throw 'v0.328 review-pack builder failed' }
node 'tools/godot/saltoV0328BarrosanHouseTool.mjs' validate
if ($LASTEXITCODE -ne 0) { throw 'v0.328 validator failed' }
Write-Output 'PASS_V0328_BARROSAN_HOUSE_CAPTURE_PACK_READY'
