param()
$ErrorActionPreference='Stop'
$RepoRoot=Resolve-Path (Join-Path $PSScriptRoot '..\..')
Set-Location $RepoRoot
$root=Join-Path $RepoRoot 'artifacts\desktop-spikes\godot-salto\v0299\static-bridge-pressure-stabilization-gate-runtime'
$default=Join-Path $RepoRoot 'artifacts\desktop-spikes\godot-salto\true-default-runtime-baseline-lock-0299'
foreach($target in @($root,$default)){if(Test-Path $target){Remove-Item $target -Recurse -Force};New-Item -ItemType Directory -Force $target|Out-Null}
New-Item -ItemType Directory -Force (Join-Path $default 'screenshots')|Out-Null
Copy-Item (Join-Path $RepoRoot 'artifacts\desktop-spikes\godot-salto\true-default-runtime-baseline-lock-0298\screenshots\03_battle_default.png') (Join-Path $default 'screenshots\03_battle_default.png')
$godot=Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64.exe'
$project=Join-Path $RepoRoot 'desktop-spikes\godot-salto'
& $godot '--path' $project '--','--player-slice-capture','--salto-barrosan-playable-runtime-skin','--artifact-root=../../artifacts/desktop-spikes/godot-salto/v0299/static-bridge-pressure-stabilization-gate-runtime'
$manifest=Join-Path $root 'screenshot-runtime-manifest.json'
$until=(Get-Date).AddSeconds(300)
while(!(Test-Path $manifest)-and(Get-Date)-lt $until){Start-Sleep -Milliseconds 250}
if(!(Test-Path $manifest)){throw 'v0.299 capture manifest failed'}
& 'C:\Users\barro\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' tools/godot/buildV0299BarrosanStaticBridgePressureStabilizationGatePack.py
node tools/godot/saltoV0299BarrosanStaticBridgePressureStabilizationGateTool.mjs
if($LASTEXITCODE-ne 0){throw 'v0.299 validator failed'}
Write-Output 'PASS_v0299_BARROSAN_STATIC_BRIDGE_PRESSURE_STABILIZATION_GATE_PACK_READY'
