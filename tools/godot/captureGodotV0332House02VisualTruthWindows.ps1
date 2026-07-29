$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location $RepoRoot
$CaptureRoot = Join-Path $RepoRoot 'artifacts\desktop-spikes\godot-salto\v0332'
$GodotConsole = Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64_console.exe'
$GodotGui = Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64.exe'
$Project = Join-Path $RepoRoot 'desktop-spikes\godot-salto'
$Python = 'C:\Users\barro\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
$Glb = Join-Path $Project 'assets\v0330\barrosan_house_gold_02.glb'
$GlbSha = (Get-FileHash -LiteralPath $Glb -Algorithm SHA256).Hash.ToLowerInvariant()
if (Test-Path -LiteralPath $CaptureRoot) { Remove-Item -LiteralPath $CaptureRoot -Recurse -Force }
New-Item -ItemType Directory -Force -Path $CaptureRoot | Out-Null
& $GodotConsole --headless --editor --path $Project --quit-after 120
if ($LASTEXITCODE -ne 0) { throw 'v0.332 Godot import scan failed' }
$env:V0332_ARTIFACT_ROOT = $CaptureRoot.Replace('\','/')
$env:V0332_GLB_SHA = $GlbSha
$argumentString = '--path "{0}" --rendering-method gl_compatibility --rendering-driver opengl3 --scene res://scenes/review/V0332BarrosanHouse02VisualTruth.tscn' -f $Project
$process = Start-Process -FilePath $GodotGui -ArgumentList $argumentString -WorkingDirectory $Project -Wait -PassThru
if ($process.ExitCode -ne 0) { throw "v0.332 Godot capture failed with exit code $($process.ExitCode)" }
$env:V0332_BENCHMARK_ONLY = '1'
$env:V0331_BENCHMARK_ONLY = '1'
$benchmark = Start-Process -FilePath $GodotGui -ArgumentList $argumentString -WorkingDirectory $Project -Wait -PassThru
Copy-Item -LiteralPath (Join-Path $CaptureRoot 'v0331-benchmark.json') -Destination (Join-Path $CaptureRoot 'v0332-benchmark.json') -Force
Remove-Item Env:V0332_ARTIFACT_ROOT -ErrorAction SilentlyContinue
Remove-Item Env:V0332_GLB_SHA -ErrorAction SilentlyContinue
Remove-Item Env:V0332_BENCHMARK_ONLY -ErrorAction SilentlyContinue
Remove-Item Env:V0331_BENCHMARK_ONLY -ErrorAction SilentlyContinue
if ($benchmark.ExitCode -ne 0) { throw "v0.332 benchmark failed with exit code $($benchmark.ExitCode)" }
& $Python 'tools/godot/buildV0332House02VisualTruthPack.py'
if ($LASTEXITCODE -ne 0) { throw 'v0.332 review-pack builder failed' }
Write-Output 'PASS_V0332_HOUSE02_VISUAL_TRUTH_CAPTURE_PACK_READY'
