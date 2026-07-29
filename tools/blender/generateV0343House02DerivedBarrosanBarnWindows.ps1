$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location $RepoRoot
$Blender = 'C:\Program Files\Blender Foundation\Blender 5.1\blender.exe'
& $Blender --background --factory-startup --python 'tools/blender/generateV0343House02DerivedBarrosanBarn.py'
if ($LASTEXITCODE -ne 0) { throw 'v0.343 Blender export failed' }
Write-Output 'PASS_V0343_HOUSE02_DERIVED_BARN_EXPORT'
