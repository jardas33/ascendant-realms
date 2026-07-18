$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location $RepoRoot
& 'C:\Users\barro\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' 'tools/godot/calibrateV0337House02GraniteMaps.py'
if ($LASTEXITCODE -ne 0) { throw 'v0.337 granite map calibration failed' }
& 'C:\Program Files\Blender Foundation\Blender 5.1\blender.exe' --background --factory-startup --python 'tools/blender/generateV0337BarrosanHouse02SelectedGranite.py'
if ($LASTEXITCODE -ne 0) { throw 'v0.337 derived House 02 Blender export failed' }
Write-Output 'PASS_V0337_SELECTED_GRANITE_DERIVED_HOUSE02_EXPORT'
