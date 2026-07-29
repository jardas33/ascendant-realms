$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location $RepoRoot
& 'C:\Program Files\Blender Foundation\Blender 5.1\blender.exe' --background --factory-startup --python 'tools/blender/generateV0339BarrosanHamletVerticalSlice.py'
if ($LASTEXITCODE -ne 0) { throw 'v0.339 Blender secondary asset export failed' }
Write-Output 'PASS_V0339_BARROSAN_HAMLET_SECONDARY_ASSET_EXPORT'
