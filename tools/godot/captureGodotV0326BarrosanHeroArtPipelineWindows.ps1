$ErrorActionPreference = 'Stop'
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..')
Set-Location $RepoRoot
$Godot = Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64.exe'
$Project = Join-Path $RepoRoot 'desktop-spikes\godot-salto'
$CaptureRoot = Join-Path $RepoRoot 'artifacts\desktop-spikes\godot-salto\v0326'
if (Test-Path -LiteralPath $CaptureRoot) { Remove-Item -LiteralPath $CaptureRoot -Recurse -Force }
New-Item -ItemType Directory -Force -Path $CaptureRoot | Out-Null
$arguments = @('--path', $Project, '--rendering-method', 'gl_compatibility', '--rendering-driver', 'opengl3', '--scene', 'res://visual_vertical_slice/V0326BarrosanHeroArtPipelineProof.tscn', '--', "--artifact-root=$CaptureRoot")
$process = Start-Process -FilePath $Godot -ArgumentList $arguments -WorkingDirectory $Project -Wait -PassThru
if ($process.ExitCode -ne 0) { throw "v0.326 Godot capture failed with exit code $($process.ExitCode)" }
$manifest = Join-Path $CaptureRoot 'v0326-barrosan-hero-art-pipeline-runtime.json'
$until = (Get-Date).AddSeconds(1800)
while (!(Test-Path -LiteralPath $manifest) -and (Get-Date) -lt $until) { Start-Sleep -Milliseconds 250 }
if (!(Test-Path -LiteralPath $manifest)) { throw 'v0.326 capture manifest was not written' }
$Python = 'C:\Users\barro\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
if (!(Test-Path -LiteralPath $Python)) { $Python = (Get-Command python).Source }
& $Python 'tools/godot/buildV0326BarrosanHeroArtPipelinePack.py'
if ($LASTEXITCODE -ne 0) { throw 'v0.326 review-pack builder failed' }
node 'tools/godot/saltoV0326BarrosanHeroArtPipelineTool.mjs' validate
if ($LASTEXITCODE -ne 0) { throw 'v0.326 validator failed' }
Write-Output 'PASS_V0326_BARROSAN_HERO_ART_PIPELINE_CAPTURE_PACK_READY'
