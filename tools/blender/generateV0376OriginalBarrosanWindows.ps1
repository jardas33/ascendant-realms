$ErrorActionPreference = 'Stop'
$repo = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$blender = if ($env:BLENDER_BIN -and (Test-Path $env:BLENDER_BIN)) { $env:BLENDER_BIN } else { 'C:\Program Files\Blender Foundation\Blender 5.1\blender.exe' }
if (-not (Test-Path -LiteralPath $blender)) { throw "Missing Blender executable: $blender" }
Set-Location $repo
& $blender --background --python tools/blender/generate_v0376_original_barrosan.py
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Output 'PASS_V0376_ORIGINAL_BARROSAN_ART_QUALITY_KIT_GENERATED'
