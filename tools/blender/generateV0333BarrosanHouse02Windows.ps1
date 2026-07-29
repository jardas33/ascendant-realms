$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location $RepoRoot
$Blender = 'C:\Program Files\Blender Foundation\Blender 5.1\blender.exe'
& $Blender --background --factory-startup --python 'tools/blender/generate_v0333_barrosan_house_02.py'
if ($LASTEXITCODE -ne 0) { throw 'v0.333 Blender House 02 granite/roof generator failed' }
Write-Output 'PASS_V0333_BARROSAN_HOUSE_02_GRANITE_ROOF_SOURCE'
