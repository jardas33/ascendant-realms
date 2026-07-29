$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location $RepoRoot
$CaptureRoot = Join-Path $RepoRoot 'artifacts\runtime\v0339'
$Godot = Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64.exe'
$GodotConsole = Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64_console.exe'
$Project = Join-Path $RepoRoot 'desktop-spikes\godot-salto'
$Ffmpeg = 'C:\Users\barro\.cache\codex-runtimes\ffmpeg-v0322\bin\ffmpeg.exe'
if (Test-Path -LiteralPath $CaptureRoot) { Remove-Item -LiteralPath $CaptureRoot -Recurse -Force }
New-Item -ItemType Directory -Force -Path $CaptureRoot | Out-Null
& $GodotConsole --headless --editor --path $Project --quit-after 120
if ($LASTEXITCODE -ne 0) { throw 'v0.339 Godot import scan failed' }
$env:V0331_ARTIFACT_ROOT = $CaptureRoot.Replace('\','/')
$env:V0339_MODE = 'PLAYER'
$args = '--path "{0}" --rendering-method gl_compatibility --rendering-driver opengl3 --scene res://scenes/review/V0339BarrosanHamletVerticalSliceReview.tscn' -f $Project
$run = Start-Process -FilePath $Godot -ArgumentList $args -WorkingDirectory $Project -Wait -PassThru
if ($run.ExitCode -ne 0) { throw "v0.339 Godot capture failed with exit code $($run.ExitCode)" }
Remove-Item Env:V0331_ARTIFACT_ROOT -ErrorAction SilentlyContinue
Remove-Item Env:V0339_MODE -ErrorAction SilentlyContinue
$continuous = Join-Path $CaptureRoot 'continuous\frame_%04d.png'
$media = Join-Path $CaptureRoot '08_CONTINUOUS_V0339_BARROSAN_HAMLET_VERTICAL_SLICE.mp4'
& $Ffmpeg -y -v error -framerate 24 -i $continuous -frames:v 504 -vf 'scale=1280:720:flags=lanczos' -c:v libx264 -pix_fmt yuv420p -movflags +faststart $media
if ($LASTEXITCODE -ne 0) { throw 'v0.339 MP4 encoding failed' }
& 'C:\Users\barro\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' (Join-Path $RepoRoot 'tools\godot\buildV0339BarrosanHamletVerticalSlicePack.py')
if ($LASTEXITCODE -ne 0) { throw 'v0.339 review pack build failed' }
Write-Output 'PASS_V0339_BARROSAN_HAMLET_VERTICAL_SLICE_CAPTURE_READY'
