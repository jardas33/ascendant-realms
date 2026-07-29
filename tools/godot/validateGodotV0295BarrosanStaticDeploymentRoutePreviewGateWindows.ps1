param()
$ErrorActionPreference = 'Stop'
Set-Location (Resolve-Path (Join-Path $PSScriptRoot '..\..'))
node tools/godot/saltoV0295BarrosanStaticDeploymentRoutePreviewGateTool.mjs
if ($LASTEXITCODE -ne 0) { throw 'v0.295 validation failed' }
Write-Output 'PASS_v0295_BARROSAN_STATIC_DEPLOYMENT_ROUTE_PREVIEW_GATE_VALIDATION'
