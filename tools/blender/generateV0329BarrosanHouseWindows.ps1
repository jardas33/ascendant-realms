$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location $RepoRoot
$Python = 'C:\Users\barro\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
if (!(Test-Path -LiteralPath $Python)) { $Python = (Get-Command python).Source }
$Blender = 'C:\Program Files\Blender Foundation\Blender 5.1\blender.exe'
if (!(Test-Path -LiteralPath $Blender)) { throw 'Blender 5.1 executable not found' }
& $Python 'tools/godot/generateV0329BarrosanHouseTextures.py'
if ($LASTEXITCODE -ne 0) { throw 'v0.329 texture generation failed' }
& $Blender --background --factory-startup --python 'tools/blender/generate_v0329_barrosan_house_authenticity.py' -- 'desktop-spikes/godot-salto/assets/v0327/barrosan_house_gold_01.glb'
if ($LASTEXITCODE -ne 0) { throw 'v0.329 Blender house export failed' }
$pycache = Join-Path $RepoRoot 'tools\blender\__pycache__'
if (Test-Path -LiteralPath $pycache) { Remove-Item -LiteralPath $pycache -Recurse -Force }
Get-ChildItem -Path $RepoRoot -Filter '*.blend1' -Recurse -File -ErrorAction SilentlyContinue | Remove-Item -Force
Write-Output 'PASS_V0329_BARROSAN_HOUSE_AUTHENTICITY_SOURCE_READY'
