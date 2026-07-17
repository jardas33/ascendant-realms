$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location $RepoRoot
$CaptureRoot = Join-Path $RepoRoot 'artifacts\desktop-spikes\godot-salto\v0327'
$GodotConsole = Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64_console.exe'
$GodotGui = Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64.exe'
$Project = Join-Path $RepoRoot 'desktop-spikes\godot-salto'
$Python = 'C:\Users\barro\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
if (!(Test-Path -LiteralPath $Python)) { $Python = (Get-Command python).Source }
if (Test-Path -LiteralPath $CaptureRoot) { Remove-Item -LiteralPath $CaptureRoot -Recurse -Force }
New-Item -ItemType Directory -Force -Path $CaptureRoot | Out-Null
powershell -NoProfile -ExecutionPolicy Bypass -File 'tools/blender/generateV0327BarrosanHouseWindows.ps1'
& $GodotConsole --headless --editor --path $Project --quit-after 120
if ($LASTEXITCODE -ne 0) { throw 'v0.327 Godot import scan failed' }
$env:V0327_ARTIFACT_ROOT = $CaptureRoot.Replace('\','/')
$argumentString = '--path "{0}" --rendering-method gl_compatibility --rendering-driver opengl3 --scene res://scenes/review/V0327BarrosanHouseReview.tscn' -f $Project
$process = Start-Process -FilePath $GodotGui -ArgumentList $argumentString -WorkingDirectory $Project -Wait -PassThru
Remove-Item Env:V0327_ARTIFACT_ROOT -ErrorAction SilentlyContinue
if ($process.ExitCode -ne 0) { throw "v0.327 Godot capture failed with exit code $($process.ExitCode)" }
$manifest = Join-Path $CaptureRoot 'v0327-barrosan-house-review-runtime.json'
if (!(Test-Path -LiteralPath $manifest)) { throw 'v0.327 capture manifest was not written' }
& $Python 'tools/godot/buildV0327BarrosanHouseReviewPack.py'
if ($LASTEXITCODE -ne 0) { throw 'v0.327 review-pack builder failed' }
node 'tools/godot/saltoV0327BarrosanHouseTool.mjs' validate
if ($LASTEXITCODE -ne 0) { throw 'v0.327 validator failed' }
Write-Output 'PASS_V0327_BARROSAN_HOUSE_CAPTURE_PACK_READY'
