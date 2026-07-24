$ErrorActionPreference = 'Stop'
$repo = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$blender = if ($env:BLENDER_BIN -and (Test-Path $env:BLENDER_BIN)) { $env:BLENDER_BIN } else { 'C:\Program Files\Blender Foundation\Blender 5.1\blender.exe' }
if (-not (Test-Path -LiteralPath $blender)) { throw "Missing Blender executable: $blender" }
Set-Location $repo
& $blender --background --python tools/blender/generate_v0377_terrain_infrastructure.py
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Output 'PASS_V0377_BARROSAN_TERRAIN_INFRASTRUCTURE_KIT_GENERATED'
