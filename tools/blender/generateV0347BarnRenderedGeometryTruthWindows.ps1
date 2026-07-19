$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$Script = Join-Path $RepoRoot 'tools\blender\generateV0347BarnRenderedGeometryTruth.py'
$Candidates = @(); if ($env:BLENDER_EXE) { $Candidates += $env:BLENDER_EXE }
$Candidates += @('C:\Program Files\Blender Foundation\Blender 5.1\blender.exe','C:\Program Files\Blender Foundation\Blender 5.0\blender.exe',(Join-Path $env:LOCALAPPDATA 'Programs\Blender Foundation\Blender\blender.exe'))
$Blender = $Candidates | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
if (-not $Blender) { throw 'Blender executable not found; set BLENDER_EXE' }
& $Blender --background --python $Script
if ($LASTEXITCODE -ne 0) { throw "v0.347 Blender generator failed with exit code $LASTEXITCODE" }
if (-not (Test-Path (Join-Path $RepoRoot 'art-source\blender\v0347\barn_rendered_geometry_truth.blend')) -or -not (Test-Path (Join-Path $RepoRoot 'art-source\blender\v0347\v0347-barn-rendered-geometry-metrics.json'))) { throw 'v0.347 Blender generator did not produce the required final source and metrics' }
Write-Output 'PASS_V0347_BARN_RENDERED_GEOMETRY_TRUTH_GENERATED'
