param()
$ErrorActionPreference='Stop';Set-Location (Resolve-Path (Join-Path $PSScriptRoot '..\..'));node tools/godot/saltoV0298BarrosanStaticBridgeSupportIntegrationGateTool.mjs;if($LASTEXITCODE-ne 0){throw 'v0.298 validation failed'};Write-Output 'PASS_v0298_BARROSAN_STATIC_BRIDGE_SUPPORT_INTEGRATION_GATE_VALIDATION'
