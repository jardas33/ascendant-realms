param()
$ErrorActionPreference = 'Stop'
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..')
Set-Location $RepoRoot
$Godot = Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64.exe'
$Project = Join-Path $RepoRoot 'desktop-spikes\godot-salto'
$CaptureRoot = Join-Path $RepoRoot 'artifacts\desktop-spikes\godot-salto\v0321\true-3d-barrosan-art-direction-lock'
if (Test-Path -LiteralPath $CaptureRoot) { Remove-Item -LiteralPath $CaptureRoot -Recurse -Force }
New-Item -ItemType Directory -Force -Path $CaptureRoot | Out-Null
$arguments = '--path "' + $Project + '" --scene "res://visual_vertical_slice/V0321BarrosanArtDirectionLock.tscn" -- --artifact-root="' + $CaptureRoot + '"'
$process = Start-Process -FilePath $Godot -ArgumentList $arguments -WorkingDirectory $Project -Wait -PassThru
if ($process.ExitCode -ne 0) { throw "v0.321 Godot capture failed with exit code $($process.ExitCode)" }
$manifest = Join-Path $CaptureRoot 'v0321-barrosan-art-direction-lock-runtime.json'
$until = (Get-Date).AddSeconds(1200)
while (!(Test-Path -LiteralPath $manifest) -and (Get-Date) -lt $until) { Start-Sleep -Milliseconds 250 }
if (!(Test-Path -LiteralPath $manifest)) { throw 'v0.321 capture manifest was not written' }
$Python = 'C:\Users\barro\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
if (!(Test-Path -LiteralPath $Python)) { $Python = (Get-Command python).Source }
& $Python 'tools/godot/buildV0321BarrosanArtDirectionLockPack.py'
if ($LASTEXITCODE -ne 0) { throw 'v0.321 review-pack builder failed' }
node 'tools/godot/saltoV0321BarrosanArtDirectionLockTool.mjs' validate
if ($LASTEXITCODE -ne 0) { throw 'v0.321 validator failed' }
Write-Output 'PASS_V0321_TRUE_3D_BARROSAN_ART_DIRECTION_LOCK_CAPTURE_PACK_READY'
