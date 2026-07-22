$ErrorActionPreference = 'Stop'
$repo = (Get-Location).Path
$capture = Join-Path $repo 'artifacts\runtime\v0366\capture\screenshots'
$pack = Join-Path $repo 'artifacts\manual-review\v0366-barrosan-house02-and-barn-forked-clean-mesh-prototype\UPLOAD_TO_CHAT'
if (-not (Test-Path -LiteralPath (Join-Path $capture '01_decision_scope.png'))) { throw 'v0.366 capture output missing; run capture first' }
if (Test-Path -LiteralPath $pack) { Remove-Item -LiteralPath $pack -Recurse -Force }
New-Item -ItemType Directory -Force -Path $pack | Out-Null
Add-Type -AssemblyName System.Drawing
function Save-LabeledCapture([string]$source, [string]$destination, [string]$title, [string]$subtitle) {
  $image = New-Object System.Drawing.Bitmap($source)
  $graphics = [System.Drawing.Graphics]::FromImage($image)
  $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
  $graphics.FillRectangle((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(205,18,26,26))), 0, 0, $image.Width, 78)
  $titleFont = New-Object System.Drawing.Font('Arial', 24, [System.Drawing.FontStyle]::Bold)
  $subtitleFont = New-Object System.Drawing.Font('Arial', 13, [System.Drawing.FontStyle]::Regular)
  $graphics.DrawString($title, $titleFont, [System.Drawing.Brushes]::White, 24, 12)
  $graphics.DrawString($subtitle, $subtitleFont, [System.Drawing.Brushes]::LightGoldenrodYellow, 26, 48)
  $graphics.Dispose(); $titleFont.Dispose(); $subtitleFont.Dispose(); $image.Save($destination, [System.Drawing.Imaging.ImageFormat]::Png); $image.Dispose()
}
$map = [ordered]@{
  '01_HUMAN_DECISION_AND_SCOPE.png'=@('01_decision_scope.png','V0366 HUMAN DECISION AND SCOPE','Canonical left / derived clean right | isolated review fixture')
  '02_ORIGINAL_VS_CLEAN_PLAYER_SCENE.png'=@('02_original_vs_clean.png','ORIGINAL VS CLEAN PLAYER SCENE','Same source transforms and lighting | only target mesh fork differs')
  '03_HOUSE02_A_GROUND_STONE_REMOVAL.png'=@('03_house_a.png','HOUSE02 A - FRONT-GROUND STONE REMOVAL','Triangle-connected granite component removed from derived fork')
  '04_HOUSE02_B_UPPER_TIMBER_REMOVAL.png'=@('04_house_b.png','HOUSE02 B - UPPER TIMBER REMOVAL','Upper bracket/scaffold component islands removed; normal timber preserved')
  '05_HOUSE02_FULL_ARCHITECTURAL_PRESERVATION.png'=@('05_house_preservation.png','HOUSE02 CLEAN FORK - ARCHITECTURAL PRESERVATION','Roof, walls, doors, windows, frames and side structure remain')
  '06_BARN_C_FRONT_TIMBER_REMOVAL.png'=@('06_barn_c.png','BARN C - FRONT TIMBER REMOVAL','Front pen/trough/platform cluster removed across merged surfaces')
  '07_BARN_FULL_ARCHITECTURAL_PRESERVATION.png'=@('07_barn_preservation.png','BARN CLEAN FORK - ARCHITECTURAL PRESERVATION','Roof, stone walls, end structure and material hierarchy remain')
  '08_DERIVED_MESH_HASH_AND_MUTATION_LEDGER.png'=@('08_ledger.png','DERIVED MESH HASH AND MUTATION LEDGER','True triangle deltas | canonical/production/gameplay mutations: zero')
}
foreach ($name in $map.Keys) { Save-LabeledCapture (Join-Path $capture $map[$name][0]) (Join-Path $pack $name) $map[$name][1] $map[$name][2] }
$readme = @'
READY FOR HUMAN V0366 BARROSAN HOUSE02 AND BARN FORKED CLEAN-MESH PROTOTYPE REVIEW.

Human decision scope:
- House02 A: remove the front-ground stone projection from a derived LOD0_Granite ArrayMesh fork.
- House02 B: remove the upper strange timber bracket/scaffold islands from a derived LOD0_Weathered_Timber ArrayMesh fork.
- Barn C: remove the front timber pen/trough/platform cluster from a derived Barn render ArrayMesh fork.

This is an isolated, opt-in, review-only prototype. Canonical assets and accepted production scenes were not edited. The left side of the comparison captures the canonical instance; the right side is the same source scene and transform with only the derived mesh assigned to the target MeshInstance3D. The derivation preserves source surfaces/material identities and removes triangles belonging to reviewed connected component envelopes. It does not hide a target parent node.

Prototype scene: res://scenes/rework/barrosan/v0366/V0366BarrosanHouse02AndBarnForkedCleanMeshPrototype.tscn
Capture: npm run godot:capture:salto-v0366-barrosan-house02-and-barn-forked-clean-mesh-prototype
Pack: npm run godot:pack:salto-v0366-barrosan-house02-and-barn-forked-clean-mesh-prototype
Validator: npm run godot:validate:salto-v0366-barrosan-house02-and-barn-forked-clean-mesh-prototype

Human stop: do not integrate these derived meshes into production or replace canonical assets until this pack is reviewed and approved.
'@
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText((Join-Path $pack '00_READ_ME_FIRST.md'), $readme, $utf8NoBom)
$summary = [ordered]@{
  checkpoint='v0.366'; baseHead='82a0dfb1f58bbb1651c29893b9414fa6b73a553a'; branch='codex/v0215-v0226-recovery'; status='READY_FOR_HUMAN_V0366_REVIEW'
  prototypeScene='desktop-spikes/godot-salto/scenes/rework/barrosan/v0366/V0366BarrosanHouse02AndBarnForkedCleanMeshPrototype.tscn'
  canonicalHouse='desktop-spikes/godot-salto/assets/v0338/barrosan_house_02_material_gold_candidate.glb'; canonicalBarn='desktop-spikes/godot-salto/scenes/gold/barrosan/BarrosanBarnGold.tscn'
  derivedMeshMethod='surface-preserving ArrayMesh fork with connected triangle-component exclusion'; targetA='House02 front-ground stone projection'; targetB='House02 upper timber bracket/scaffold'; targetC='Barn front-right timber pen/trough/platform'
  canonicalAssetMutationCount=0; canonicalSceneMutationCount=0; productionIntegrationCount=0; gameplayMutationCount=0; transformMutationCount=0; placementMutationCount=0; stableIdMutationCount=0; saveMutationCount=0; defaultRuntimeMutationCount=0; humanReviewStop=$true
  packFiles=@($map.Keys + '00_READ_ME_FIRST.md' + 'compact-evidence-summary.json')
}
[System.IO.File]::WriteAllText((Join-Path $pack 'compact-evidence-summary.json'), ($summary | ConvertTo-Json -Depth 12), $utf8NoBom)
Write-Output "PASS_V0366_PACK $pack"
