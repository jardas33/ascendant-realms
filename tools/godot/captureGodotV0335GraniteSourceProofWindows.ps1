$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location $RepoRoot
$CaptureRoot = Join-Path $RepoRoot 'artifacts\desktop-spikes\godot-salto\v0335'
$Godot = Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64.exe'
$GodotConsole = Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64_console.exe'
$Project = Join-Path $RepoRoot 'desktop-spikes\godot-salto'
$Python = 'C:\Users\barro\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
$Ffmpeg = 'C:\Users\barro\.cache\codex-runtimes\ffmpeg-v0322\bin\ffmpeg.exe'
if (Test-Path -LiteralPath $CaptureRoot) { Remove-Item -LiteralPath $CaptureRoot -Recurse -Force }
New-Item -ItemType Directory -Force -Path $CaptureRoot | Out-Null
& $GodotConsole --headless --editor --path $Project --quit-after 120
if ($LASTEXITCODE -ne 0) { throw 'v0.335 Godot import scan failed' }
$env:V0335_ARTIFACT_ROOT = $CaptureRoot.Replace('\','/')
$arguments = '--path "{0}" --rendering-method gl_compatibility --rendering-driver opengl3 --scene res://scenes/review/V0335GraniteSourceProof.tscn' -f $Project
$run = Start-Process -FilePath $Godot -ArgumentList $arguments -WorkingDirectory $Project -Wait -PassThru
if ($run.ExitCode -ne 0) { throw "v0.335 Godot capture failed with exit code $($run.ExitCode)" }
Remove-Item Env:V0335_ARTIFACT_ROOT -ErrorAction SilentlyContinue
$continuous = Join-Path $CaptureRoot 'continuous\frame_%04d.png'
$media = Join-Path $CaptureRoot 'v0335-granite-source-proof.mp4'
& $Ffmpeg -y -v error -framerate 24 -stream_loop 3 -i $continuous -vf 'scale=1280:720:flags=lanczos' -t 15 -c:v libx264 -pix_fmt yuv420p -movflags +faststart $media
if ($LASTEXITCODE -ne 0) { throw 'v0.335 MP4 encoding failed' }
& $Python 'tools/godot/buildV0335GraniteSourceProofPack.py'
if ($LASTEXITCODE -ne 0) { throw 'v0.335 review-pack builder failed' }
Write-Output 'PASS_V0335_GRANITE_SOURCE_PROOF_CAPTURE_PACK_READY'
