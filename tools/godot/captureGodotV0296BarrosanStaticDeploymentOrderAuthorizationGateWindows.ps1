param()
$ErrorActionPreference='Stop'; $RepoRoot=Resolve-Path (Join-Path $PSScriptRoot '..\..'); Set-Location $RepoRoot
$root=Join-Path $RepoRoot 'artifacts\desktop-spikes\godot-salto\v0296\static-deployment-order-authorization-gate-runtime'; $default=Join-Path $RepoRoot 'artifacts\desktop-spikes\godot-salto\true-default-runtime-baseline-lock-0296'
foreach($target in @($root,$default)){if(Test-Path $target){Remove-Item -LiteralPath $target -Recurse -Force}; New-Item -ItemType Directory -Force -Path $target|Out-Null}
$godot=Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64.exe'
function Capture([string[]]$arguments,[string]$manifest){& $godot @arguments; $until=(Get-Date).AddSeconds(120); while(!(Test-Path $manifest) -and (Get-Date) -lt $until){Start-Sleep -Milliseconds 250}; if(!(Test-Path $manifest)){throw 'missing capture manifest'}; if((Get-Content -Raw $manifest) -notmatch 'PASS_PLAYER_SLICE_CAPTURE'){throw 'capture manifest failed'}}
New-Item -ItemType Directory -Force -Path (Join-Path $default 'screenshots') | Out-Null
Copy-Item (Join-Path $RepoRoot 'artifacts\desktop-spikes\godot-salto\true-default-runtime-baseline-lock-0295\screenshots\03_battle_default.png') (Join-Path $default 'screenshots\03_battle_default.png')
Capture @('--path','.\desktop-spikes\godot-salto','--','--player-slice-capture','--salto-barrosan-playable-runtime-skin','--artifact-root=../../artifacts/desktop-spikes/godot-salto/v0296/static-deployment-order-authorization-gate-runtime') (Join-Path $root 'screenshot-runtime-manifest.json')
& 'C:\Users\barro\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' tools/godot/buildV0296BarrosanStaticDeploymentOrderAuthorizationGatePack.py
node tools/godot/saltoV0296BarrosanStaticDeploymentOrderAuthorizationGateTool.mjs
if($LASTEXITCODE -ne 0){throw 'v0.296 validator failed'}
Write-Output 'PASS_v0296_BARROSAN_STATIC_DEPLOYMENT_ORDER_AUTHORIZATION_GATE_PACK_READY'
