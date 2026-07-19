$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location $RepoRoot
$Blender = 'C:\Program Files\Blender Foundation\Blender 5.1\blender.exe'
& $Blender --background --factory-startup --python 'tools/blender/generateV0342ReferenceLockedBarrosanBarn.py'
if ($LASTEXITCODE -ne 0) { throw 'v0.342 Blender generation/export failed' }
Write-Output 'PASS_V0342_REFERENCE_LOCKED_BARROSAN_BARN_EXPORT'
