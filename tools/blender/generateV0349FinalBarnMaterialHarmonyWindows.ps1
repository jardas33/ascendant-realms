$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$Blender = 'C:\Program Files\Blender Foundation\Blender 5.1\blender.exe'
if (-not (Test-Path -LiteralPath $Blender)) { throw 'Blender 5.1 executable not found' }
$Source = Join-Path $RepoRoot 'art-source\blender\v0349'
New-Item -ItemType Directory -Force -Path $Source | Out-Null
$script = Join-Path $RepoRoot 'tools\blender\generateV0349BarnFinalMaterialHarmony.py'
Push-Location $RepoRoot
try { & $Blender --background --factory-startup --python $script } finally { Pop-Location }
if ($LASTEXITCODE -ne 0) { throw "v0.348 Blender generation failed with exit code $LASTEXITCODE" }
if (-not (Test-Path -LiteralPath (Join-Path $RepoRoot 'desktop-spikes\godot-salto\assets\v0349\barn_final_material_harmony.glb'))) { throw 'v0.349 GLB was not generated' }
$GodotAssets = Join-Path $RepoRoot 'desktop-spikes\godot-salto\assets\v0349'
New-Item -ItemType Directory -Force -Path $GodotAssets | Out-Null
Copy-Item -LiteralPath (Join-Path $Source 'v0349_weathered_slate_courses_albedo.png') -Destination (Join-Path $GodotAssets 'v0349_weathered_slate_courses_albedo.png') -Force
Copy-Item -LiteralPath (Join-Path $Source 'v0349_weathered_slate_courses_normal.png') -Destination (Join-Path $GodotAssets 'v0349_weathered_slate_courses_normal.png') -Force
Copy-Item -LiteralPath (Join-Path $Source 'v0349_weathered_slate_courses_roughness.png') -Destination (Join-Path $GodotAssets 'v0349_weathered_slate_courses_roughness.png') -Force
Remove-Item -LiteralPath (Join-Path $Source 'barn_final_material_harmony.blend1') -Force -ErrorAction SilentlyContinue
Write-Output 'PASS_V0349_FINAL_BARN_MATERIAL_HARMONY_DERIVATIVE_GENERATED'
