$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location $RepoRoot
& 'C:\Users\barro\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' 'tools/godot/calibrateV0338House02MaterialGoldCandidateMaps.py'
if ($LASTEXITCODE -ne 0) { throw 'v0.338 material map calibration failed' }
& 'C:\Program Files\Blender Foundation\Blender 5.1\blender.exe' --background --factory-startup --python 'tools/blender/generateV0338BarrosanHouse02MaterialGoldCandidate.py'
if ($LASTEXITCODE -ne 0) { throw 'v0.338 House 02 gold-candidate Blender export failed' }
Write-Output 'PASS_V0338_HOUSE02_MATERIAL_GOLD_CANDIDATE_DERIVED_EXPORT'
