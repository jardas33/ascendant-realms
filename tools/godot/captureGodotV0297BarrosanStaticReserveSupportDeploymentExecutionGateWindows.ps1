param()
$ErrorActionPreference='Stop'; $RepoRoot=Resolve-Path (Join-Path $PSScriptRoot '..\..'); Set-Location $RepoRoot
$root=Join-Path $RepoRoot 'artifacts\desktop-spikes\godot-salto\v0297\static-reserve-support-deployment-execution-gate-runtime'; $default=Join-Path $RepoRoot 'artifacts\desktop-spikes\godot-salto\true-default-runtime-baseline-lock-0297'
foreach($target in @($root,$default)){if(Test-Path $target){Remove-Item -LiteralPath $target -Recurse -Force}; New-Item -ItemType Directory -Force -Path $target|Out-Null}
$godot=Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64.exe'
New-Item -ItemType Directory -Force -Path (Join-Path $default 'screenshots')|Out-Null
Copy-Item (Join-Path $RepoRoot 'artifacts\desktop-spikes\godot-salto\true-default-runtime-baseline-lock-0296\screenshots\03_battle_default.png') (Join-Path $default 'screenshots\03_battle_default.png')
& $godot '--path','.\desktop-spikes\godot-salto','--','--player-slice-capture','--salto-barrosan-playable-runtime-skin','--artifact-root=../../artifacts/desktop-spikes/godot-salto/v0297/static-reserve-support-deployment-execution-gate-runtime'
$manifest=Join-Path $root 'screenshot-runtime-manifest.json'; $until=(Get-Date).AddSeconds(300); while(!(Test-Path $manifest) -and (Get-Date) -lt $until){Start-Sleep -Milliseconds 250}; if(!(Test-Path $manifest) -or (Get-Content -Raw $manifest) -notmatch 'PASS_PLAYER_SLICE_CAPTURE'){throw 'v0.297 capture manifest failed'}
& 'C:\Users\barro\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' tools/godot/buildV0297BarrosanStaticReserveSupportDeploymentExecutionGatePack.py
node tools/godot/saltoV0297BarrosanStaticReserveSupportDeploymentExecutionGateTool.mjs
if($LASTEXITCODE -ne 0){throw 'v0.297 validator failed'}
Write-Output 'PASS_v0297_BARROSAN_STATIC_RESERVE_SUPPORT_DEPLOYMENT_EXECUTION_GATE_PACK_READY'
