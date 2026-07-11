param()
$ErrorActionPreference='Stop'
$RepoRoot=Resolve-Path (Join-Path $PSScriptRoot '..\..')
Set-Location $RepoRoot
node tools/godot/saltoV0302BarrosanPlayerFacing25DDepthFoundationTool.mjs
if($LASTEXITCODE-ne 0){throw 'v0.302 validation failed'}
Write-Output 'PASS_v0302_BARROSAN_PLAYER_FACING_2_5D_DEPTH_FOUNDATION_VALIDATION'
