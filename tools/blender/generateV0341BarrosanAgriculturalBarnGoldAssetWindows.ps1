$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location $RepoRoot
& 'C:\Program Files\Blender Foundation\Blender 5.1\blender.exe' --background --factory-startup --python 'tools/blender/generateV0341BarrosanAgriculturalBarnGoldAsset.py'
if ($LASTEXITCODE -ne 0) { throw 'v0.341 Blender generation/export failed' }
Write-Output 'PASS_V0341_BARROSAN_AGRICULTURAL_BARN_GOLD_ASSET_EXPORT'
