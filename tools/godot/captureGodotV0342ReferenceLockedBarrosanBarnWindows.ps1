$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location $RepoRoot
$CaptureRoot = Join-Path $RepoRoot 'artifacts\runtime\v0342'
$Godot = Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64.exe'
$GodotConsole = Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64_console.exe'
$Project = Join-Path $RepoRoot 'desktop-spikes\godot-salto'
$Ffmpeg = 'C:\Users\barro\.cache\codex-runtimes\ffmpeg-v0322\bin\ffmpeg.exe'
if (Test-Path -LiteralPath $CaptureRoot) { Remove-Item -LiteralPath $CaptureRoot -Recurse -Force }
New-Item -ItemType Directory -Force -Path $CaptureRoot | Out-Null
# The v0.342 GLB was generated before capture and Godot's normal project
# launch performs the required import scan. Avoid the editor's timed layout
# wait here so capture remains a bounded headed operation.
$env:V0331_ARTIFACT_ROOT = $CaptureRoot.Replace('\','/')
$args = '--path "{0}" --rendering-method gl_compatibility --rendering-driver opengl3 --scene res://scenes/review/V0342ReferenceLockedBarrosanBarnReview.tscn' -f $Project
$run = Start-Process -FilePath $Godot -ArgumentList $args -WorkingDirectory $Project -Wait -PassThru
if ($run.ExitCode -ne 0) { throw "v0.342 Godot capture failed with exit code $($run.ExitCode)" }
Remove-Item Env:V0331_ARTIFACT_ROOT -ErrorAction SilentlyContinue
$continuous = Join-Path $CaptureRoot 'continuous\frame_%04d.png'
$media = Join-Path $CaptureRoot '08_CONTINUOUS_V0342_REFERENCE_LOCKED_BARROSAN_BARN.mp4'
& $Ffmpeg -y -v error -framerate 24 -i $continuous -frames:v 360 -vf 'scale=1280:720:flags=lanczos' -c:v libx264 -pix_fmt yuv420p -movflags +faststart $media
if ($LASTEXITCODE -ne 0) { throw 'v0.342 MP4 encoding failed' }
Write-Output 'PASS_V0342_REFERENCE_LOCKED_BARROSAN_BARN_CAPTURE_READY'
