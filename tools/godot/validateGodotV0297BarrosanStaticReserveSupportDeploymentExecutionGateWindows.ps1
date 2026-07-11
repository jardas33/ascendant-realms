param()
$ErrorActionPreference='Stop'; Set-Location (Resolve-Path (Join-Path $PSScriptRoot '..\..'))
node tools/godot/saltoV0297BarrosanStaticReserveSupportDeploymentExecutionGateTool.mjs
if($LASTEXITCODE -ne 0){throw 'v0.297 validation failed'}
Write-Output 'PASS_v0297_BARROSAN_STATIC_RESERVE_SUPPORT_DEPLOYMENT_EXECUTION_GATE_VALIDATION'
