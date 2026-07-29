$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location $RepoRoot
$CaptureRoot = Join-Path $RepoRoot 'artifacts\runtime\v0338'
$Godot = Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64.exe'
$GodotConsole = Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64_console.exe'
$Project = Join-Path $RepoRoot 'desktop-spikes\godot-salto'
$Ffmpeg = 'C:\Users\barro\.cache\codex-runtimes\ffmpeg-v0322\bin\ffmpeg.exe'
if (Test-Path -LiteralPath $CaptureRoot) { Remove-Item -LiteralPath $CaptureRoot -Recurse -Force }
New-Item -ItemType Directory -Force -Path $CaptureRoot | Out-Null
& $GodotConsole --headless --editor --path $Project --quit-after 120
if ($LASTEXITCODE -ne 0) { throw 'v0.338 Godot import scan failed' }
$env:V0331_ARTIFACT_ROOT = $CaptureRoot.Replace('\','/')
$args = '--path "{0}" --rendering-method gl_compatibility --rendering-driver opengl3 --scene res://scenes/review/V0338BarrosanHouse02MaterialGoldCandidateReview.tscn' -f $Project
$run = Start-Process -FilePath $Godot -ArgumentList $args -WorkingDirectory $Project -Wait -PassThru
if ($run.ExitCode -ne 0) { throw "v0.338 Godot capture failed with exit code $($run.ExitCode)" }
$env:V0331_BENCHMARK_ONLY = '1'
$benchmark = Start-Process -FilePath $Godot -ArgumentList $args -WorkingDirectory $Project -Wait -PassThru
Remove-Item Env:V0331_ARTIFACT_ROOT -ErrorAction SilentlyContinue
Remove-Item Env:V0331_BENCHMARK_ONLY -ErrorAction SilentlyContinue
if ($benchmark.ExitCode -ne 0) { throw "v0.338 benchmark failed with exit code $($benchmark.ExitCode)" }
$continuous = Join-Path $CaptureRoot 'continuous\frame_%04d.png'
$media = Join-Path $CaptureRoot '08_CONTINUOUS_V0338_HOUSE02_MATERIAL_GOLD_CANDIDATE.mp4'
& $Ffmpeg -y -v error -framerate 24 -i $continuous -frames:v 432 -vf 'scale=1280:720:flags=lanczos' -c:v libx264 -pix_fmt yuv420p -movflags +faststart $media
if ($LASTEXITCODE -ne 0) { throw 'v0.338 MP4 encoding failed' }
& 'C:\Users\barro\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' (Join-Path $RepoRoot 'tools\godot\buildV0338House02MaterialGoldCandidatePack.py')
if ($LASTEXITCODE -ne 0) { throw 'v0.338 review pack build failed' }
Write-Output 'PASS_V0338_HOUSE02_MATERIAL_GOLD_CANDIDATE_CAPTURE_READY'
