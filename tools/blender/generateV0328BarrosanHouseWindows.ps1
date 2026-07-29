$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location $RepoRoot
$Blender = 'C:\Program Files\Blender Foundation\Blender 5.1\blender.exe'
if (!(Test-Path -LiteralPath $Blender)) { throw 'Blender 5.1.2 executable not found' }
$Python = 'C:\Users\barro\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
if (!(Test-Path -LiteralPath $Python)) { $Python = (Get-Command python).Source }
& $Python 'tools/godot/generateV0328BarrosanHouseTextures.py'
if ($LASTEXITCODE -ne 0) { throw 'v0.328 texture generation failed' }
& $Blender --background --python 'tools/blender/generate_v0328_barrosan_house_gold.py' -- --output='desktop-spikes/godot-salto/assets/v0327/barrosan_house_gold_01.glb'
if ($LASTEXITCODE -ne 0) { throw 'v0.328 Blender repair/export failed' }
Write-Output 'PASS_V0328_BARROSAN_HOUSE_BLENDER_EXPORT_READY'
