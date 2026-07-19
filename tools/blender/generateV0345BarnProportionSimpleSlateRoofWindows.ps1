$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$Script = Join-Path $RepoRoot 'tools\blender\generateV0345BarnProportionSimpleSlateRoof.py'
$Candidates = @()
if ($env:BLENDER_EXE) { $Candidates += $env:BLENDER_EXE }
$Candidates += @(
  'C:\Program Files\Blender Foundation\Blender 5.1\blender.exe',
  'C:\Program Files\Blender Foundation\Blender 5.0\blender.exe',
  'C:\Program Files\Blender Foundation\Blender 4.3\blender.exe',
  (Join-Path $env:LOCALAPPDATA 'Programs\Blender Foundation\Blender\blender.exe'),
  (Join-Path $env:USERPROFILE 'scoop\apps\blender\current\blender.exe')
)
$Blender = $Candidates | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
if (-not $Blender) { throw 'Blender executable not found; set BLENDER_EXE' }
& $Blender --background --python $Script
if ($LASTEXITCODE -ne 0) { throw "v0.345 Blender generator failed with exit code $LASTEXITCODE" }
Write-Output 'PASS_V0345_BARN_PROPORTION_SIMPLE_SLATE_ROOF_GENERATED'
