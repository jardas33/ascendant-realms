$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location $RepoRoot
$CaptureRoot = Join-Path $RepoRoot 'artifacts\desktop-spikes\godot-salto\v0333'
$GodotConsole = Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64_console.exe'
$GodotGui = Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64.exe'
$Project = Join-Path $RepoRoot 'desktop-spikes\godot-salto'
$Python = 'C:\Users\barro\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
$Glb = Join-Path $Project 'assets\v0333\barrosan_house_gold_02.glb'
$GlbSha = (Get-FileHash -LiteralPath $Glb -Algorithm SHA256).Hash.ToLowerInvariant()
if (Test-Path -LiteralPath $CaptureRoot) { Remove-Item -LiteralPath $CaptureRoot -Recurse -Force }
New-Item -ItemType Directory -Force -Path $CaptureRoot | Out-Null
& $GodotConsole --headless --editor --path $Project --quit-after 120
if ($LASTEXITCODE -ne 0) { throw 'v0.333 Godot import scan failed' }
$env:V0331_ARTIFACT_ROOT = $CaptureRoot.Replace('\','/')
$env:V0333_GLB_SHA = $GlbSha
$argumentString = '--path "{0}" --rendering-method gl_compatibility --rendering-driver opengl3 --scene res://scenes/review/V0333BarrosanHouse02GraniteRoof.tscn' -f $Project
$process = Start-Process -FilePath $GodotGui -ArgumentList $argumentString -WorkingDirectory $Project -Wait -PassThru
if ($process.ExitCode -ne 0) { throw "v0.333 Godot capture failed with exit code $($process.ExitCode)" }
$env:V0331_BENCHMARK_ONLY = '1'
$benchmark = Start-Process -FilePath $GodotGui -ArgumentList $argumentString -WorkingDirectory $Project -Wait -PassThru
Remove-Item Env:V0331_ARTIFACT_ROOT -ErrorAction SilentlyContinue
Remove-Item Env:V0333_GLB_SHA -ErrorAction SilentlyContinue
Remove-Item Env:V0331_BENCHMARK_ONLY -ErrorAction SilentlyContinue
if ($benchmark.ExitCode -ne 0) { throw "v0.333 benchmark failed with exit code $($benchmark.ExitCode)" }
& $Python 'tools/godot/buildV0333House02GraniteRoofPack.py'
if ($LASTEXITCODE -ne 0) { throw 'v0.333 review-pack builder failed' }
Write-Output 'PASS_V0333_HOUSE02_GRANITE_ROOF_CAPTURE_PACK_READY'
