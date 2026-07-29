param()
$ErrorActionPreference='Stop'
$RepoRoot=Resolve-Path (Join-Path $PSScriptRoot '..\..')
Set-Location $RepoRoot
node tools/godot/saltoV0303BarrosanPlayerFacing25DVisualHierarchyMaterialReadabilityTool.mjs
if($LASTEXITCODE-ne 0){throw 'v0.303 validation failed'}
Write-Output 'PASS_v0303_BARROSAN_PLAYER_FACING_2_5D_VISUAL_HIERARCHY_MATERIAL_READABILITY_VALIDATION'
