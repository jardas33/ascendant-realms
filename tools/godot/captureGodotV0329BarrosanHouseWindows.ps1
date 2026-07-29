$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location $RepoRoot
$CaptureRoot = Join-Path $RepoRoot 'artifacts\desktop-spikes\godot-salto\v0329'
$GodotConsole = Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64_console.exe'
$GodotGui = Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64.exe'
$Project = Join-Path $RepoRoot 'desktop-spikes\godot-salto'
$Python = 'C:\Users\barro\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
if (!(Test-Path -LiteralPath $Python)) { $Python = (Get-Command python).Source }
if (Test-Path -LiteralPath $CaptureRoot) { Remove-Item -LiteralPath $CaptureRoot -Recurse -Force }
New-Item -ItemType Directory -Force -Path $CaptureRoot | Out-Null
& $GodotConsole --headless --editor --path $Project --quit-after 120
if ($LASTEXITCODE -ne 0) { throw 'v0.329 Godot import scan failed' }
$env:V0329_ARTIFACT_ROOT = $CaptureRoot.Replace('\','/')
$argumentString = '--path "{0}" --rendering-method gl_compatibility --rendering-driver opengl3 --scene res://scenes/review/V0329BarrosanHouseReview.tscn' -f $Project
$process = Start-Process -FilePath $GodotGui -ArgumentList $argumentString -WorkingDirectory $Project -Wait -PassThru
Remove-Item Env:V0329_ARTIFACT_ROOT -ErrorAction SilentlyContinue
if ($process.ExitCode -ne 0) { throw "v0.329 Godot capture failed with exit code $($process.ExitCode)" }
$env:V0329_ARTIFACT_ROOT = $CaptureRoot.Replace('\','/')
$env:V0329_BENCHMARK_ONLY = '1'
$benchmark = Start-Process -FilePath $GodotGui -ArgumentList $argumentString -WorkingDirectory $Project -Wait -PassThru
Remove-Item Env:V0329_ARTIFACT_ROOT -ErrorAction SilentlyContinue
Remove-Item Env:V0329_BENCHMARK_ONLY -ErrorAction SilentlyContinue
if ($benchmark.ExitCode -ne 0) { throw "v0.329 benchmark failed with exit code $($benchmark.ExitCode)" }
& $Python 'tools/godot/buildV0329BarrosanHouseReviewPack.py'
if ($LASTEXITCODE -ne 0) { throw 'v0.329 review-pack builder failed' }
Write-Output 'PASS_V0329_BARROSAN_HOUSE_CAPTURE_PACK_READY'
