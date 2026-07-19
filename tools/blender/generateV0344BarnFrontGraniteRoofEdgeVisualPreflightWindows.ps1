$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location $RepoRoot
$Blender = 'C:\Program Files\Blender Foundation\Blender 5.1\blender.exe'
& $Blender --background --factory-startup --python 'tools/blender/generateV0344BarnFrontGraniteRoofEdgeVisualPreflight.py'
if ($LASTEXITCODE -ne 0) { throw 'v0.344 Blender export failed' }
Write-Output 'PASS_V0344_BARN_FRONT_GRANITE_ROOF_EDGE_EXPORT'
