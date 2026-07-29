param()
$ErrorActionPreference='Stop'
$RepoRoot=Resolve-Path (Join-Path $PSScriptRoot '..\..')
Set-Location $RepoRoot
$base=Join-Path $RepoRoot 'artifacts\desktop-spikes\godot-salto\v0301\player-facing-presentation-debug-overlay-separation'
$player=Join-Path $base 'player-facing'
$debug=Join-Path $base 'debug-review'
$default=Join-Path $RepoRoot 'artifacts\desktop-spikes\godot-salto\true-default-runtime-baseline-lock-0301'
foreach($target in @($player,$debug,$default)){if(Test-Path $target){Remove-Item $target -Recurse -Force};New-Item -ItemType Directory -Force $target|Out-Null}
New-Item -ItemType Directory -Force (Join-Path $default 'screenshots')|Out-Null
$baseline=Join-Path $RepoRoot 'artifacts\desktop-spikes\godot-salto\true-default-runtime-baseline-lock-0300\screenshots\03_battle_default.png'
if(!(Test-Path $baseline)){$baseline=Join-Path $RepoRoot 'artifacts\desktop-spikes\godot-salto\true-default-runtime-baseline-lock-0299\screenshots\03_battle_default.png'}
Copy-Item $baseline (Join-Path $default 'screenshots\03_battle_default.png')
$godot=Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64.exe'
$project=Join-Path $RepoRoot 'desktop-spikes\godot-salto'
function Invoke-V0301Capture([string]$modeFlag,[string]$artifactRoot){
    & $godot '--headless' '--path' $project '--' '--player-slice-capture' '--salto-barrosan-playable-runtime-skin' $modeFlag ("--artifact-root=../../artifacts/desktop-spikes/godot-salto/v0301/player-facing-presentation-debug-overlay-separation/{0}" -f $artifactRoot)
    $manifest=Join-Path $base (Join-Path $artifactRoot 'screenshot-runtime-manifest.json')
    $until=(Get-Date).AddSeconds(300)
    while(!(Test-Path $manifest)-and(Get-Date)-lt $until){Start-Sleep -Milliseconds 250}
    if(!(Test-Path $manifest)){throw "v0.301 capture manifest failed: $artifactRoot"}
}
Invoke-V0301Capture '--salto-barrosan-player-presentation' 'player-facing'
Invoke-V0301Capture '--salto-barrosan-debug-review-overlay' 'debug-review'
& 'C:\Users\barro\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' tools/godot/buildV0301BarrosanPlayerFacingPresentationDebugOverlaySeparationPack.py
node tools/godot/saltoV0301BarrosanPlayerFacingPresentationDebugOverlaySeparationTool.mjs
if($LASTEXITCODE-ne 0){throw 'v0.301 validator failed'}
Write-Output 'PASS_v0301_BARROSAN_PLAYER_FACING_PRESENTATION_DEBUG_OVERLAY_SEPARATION_PACK_READY'
