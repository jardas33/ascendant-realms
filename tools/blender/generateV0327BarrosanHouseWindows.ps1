$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
Set-Location $RepoRoot
$Blender = 'C:\Program Files\Blender Foundation\Blender 5.1\blender.exe'
if (!(Test-Path -LiteralPath $Blender)) { throw "Blender 5.1 not found at $Blender" }
$Python = 'C:\Users\barro\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
if (!(Test-Path -LiteralPath $Python)) { throw 'Bundled Python runtime not found' }
$Output = Join-Path $RepoRoot 'desktop-spikes\godot-salto\assets\v0327\barrosan_house_gold_01.glb'
& $Python 'tools/godot/generateV0327BarrosanHouseTextures.py'
if ($LASTEXITCODE -ne 0) { throw "v0.327 texture generation failed with exit code $LASTEXITCODE" }
& $Blender --background --factory-startup --python 'tools/blender/generate_v0327_barrosan_house_gold.py' -- "--output=$($Output.Replace('\','/'))"
if ($LASTEXITCODE -ne 0) { throw "v0.327 Blender author/export failed with exit code $LASTEXITCODE" }
Write-Output 'PASS_V0327_BARROSAN_HOUSE_GOLD_ASSET_GENERATED'
