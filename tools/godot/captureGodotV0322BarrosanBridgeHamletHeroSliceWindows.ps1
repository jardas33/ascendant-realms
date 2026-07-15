param()
$ErrorActionPreference = 'Stop'
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..')
Set-Location $RepoRoot
$Godot = Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64.exe'
$Project = Join-Path $RepoRoot 'desktop-spikes\godot-salto'
$CaptureRoot = Join-Path $RepoRoot 'artifacts\desktop-spikes\godot-salto\v0322\barrosan-bridge-hamlet-hero-slice'
if (Test-Path -LiteralPath $CaptureRoot) { Remove-Item -LiteralPath $CaptureRoot -Recurse -Force }
New-Item -ItemType Directory -Force -Path $CaptureRoot | Out-Null
$arguments = '--path "' + $Project + '" --scene "res://visual_vertical_slice/V0322BarrosanBridgeHamletHeroSlice.tscn" -- --artifact-root="' + $CaptureRoot + '"'
$process = Start-Process -FilePath $Godot -ArgumentList $arguments -WorkingDirectory $Project -Wait -PassThru
if ($process.ExitCode -ne 0) { throw "v0.322 Godot capture failed with exit code $($process.ExitCode)" }
$manifest = Join-Path $CaptureRoot 'v0322-barrosan-bridge-hamlet-hero-slice-runtime.json'
$until = (Get-Date).AddSeconds(1800)
while (!(Test-Path -LiteralPath $manifest) -and (Get-Date) -lt $until) { Start-Sleep -Milliseconds 250 }
if (!(Test-Path -LiteralPath $manifest)) { throw 'v0.322 capture manifest was not written' }
$Python = 'C:\Users\barro\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
if (!(Test-Path -LiteralPath $Python)) { $Python = (Get-Command python).Source }
& $Python 'tools/godot/buildV0322BarrosanBridgeHamletHeroSlicePack.py'
if ($LASTEXITCODE -ne 0) { throw 'v0.322 review-pack builder failed' }
node 'tools/godot/saltoV0322BarrosanBridgeHamletHeroSliceTool.mjs' validate
if ($LASTEXITCODE -ne 0) { throw 'v0.322 validator failed' }
Write-Output 'PASS_V0322_BARROSAN_BRIDGE_HAMLET_HERO_SLICE_CAPTURE_PACK_READY'
