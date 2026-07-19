$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location $RepoRoot
& 'C:\Program Files\Blender Foundation\Blender 5.1\blender.exe' --background --factory-startup --python 'tools/blender/generateV0340BarrosanSecondaryEnvironmentKit.py'
if ($LASTEXITCODE -ne 0) { throw 'v0.340 Blender authored kit export failed' }
Write-Output 'PASS_V0340_BARROSAN_SECONDARY_ENVIRONMENT_KIT_EXPORT'
