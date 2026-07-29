$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location $RepoRoot
$Blender = 'C:\Program Files\Blender Foundation\Blender 5.1\blender.exe'
& $Blender --background --factory-startup --python 'tools/blender/generate_v0334_barrosan_house_02.py'
if ($LASTEXITCODE -ne 0) { throw 'v0.334 Blender House 02 granite generator failed' }
Write-Output 'PASS_V0334_BARROSAN_HOUSE_02_GRANITE_SOURCE'
