param()
$ErrorActionPreference = 'Stop'
Set-Location (Resolve-Path (Join-Path $PSScriptRoot '..\\..'))
$Python = 'C:\\Users\\barro\\.cache\\codex-runtimes\\codex-primary-runtime\\dependencies\\python\\python.exe'
& $Python tools/godot/buildV0294BarrosanFinalReadyChainVisualContractHardeningPack.py
node tools/godot/saltoV0294BarrosanFinalReadyChainVisualContractHardeningTool.mjs
if ($LASTEXITCODE -ne 0) { throw 'v0.294 validation failed' }
Write-Output 'PASS_v0294_BARROSAN_FINAL_READY_CHAIN_VISUAL_CONTRACT_HARDENING_VALIDATION'
