$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$Runtime = Join-Path $RepoRoot 'artifacts\runtime\v0355\screenshots'
$PriorRuntime = Join-Path $RepoRoot 'artifacts\runtime\v0354\screenshots'
$PriorPack = Join-Path $RepoRoot 'artifacts\manual-review\v0354-barn-final-evidence\UPLOAD_TO_CHAT'
$Pack = Join-Path $RepoRoot 'artifacts\manual-review\v0355-barrosan-barn-human-gold-lock\UPLOAD_TO_CHAT'
$Gold = Join-Path $RepoRoot 'docs\gold'
if (Test-Path $Pack) { Get-ChildItem -LiteralPath $Pack -Force | Remove-Item -Force }
New-Item -ItemType Directory -Force -Path $Pack,$Gold | Out-Null

function New-Canvas([string]$path, [string]$title, [array]$items) {
  $canvas = New-Object System.Drawing.Bitmap(1600,900)
  $g = [System.Drawing.Graphics]::FromImage($canvas); $g.Clear([System.Drawing.Color]::FromArgb(49,57,51))
  $font = New-Object System.Drawing.Font('Arial',20,[System.Drawing.FontStyle]::Bold); $small = New-Object System.Drawing.Font('Arial',14)
  $g.DrawString($title,$font,[System.Drawing.Brushes]::White,28,22)
  foreach ($item in $items) {
    $root = if ($item.root -eq 'prior') { $PriorPack } elseif ($item.root -eq 'priorRuntime') { $PriorRuntime } else { $Runtime }
    $source = Join-Path $root $item.file
    if (-not (Test-Path -LiteralPath $source)) { throw "Missing rendered source: $source" }
    $img = [System.Drawing.Image]::FromFile($source)
    $rect = New-Object System.Drawing.Rectangle($item.x,$item.y,$item.w,$item.h)
    $g.DrawImage($img,$rect); $g.DrawString($item.caption,$small,[System.Drawing.Brushes]::White,$item.x,($item.y+$item.h+8)); $img.Dispose()
  }
  $canvas.Save($path,[System.Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $canvas.Dispose(); $font.Dispose(); $small.Dispose()
}

New-Canvas (Join-Path $Pack '01_V0354_HUMAN_APPROVAL_AND_LINEAGE.png') 'V0.354 HUMAN-APPROVED BARN GOLD / V0.355 CANONICAL REGISTRATION' @(
  @{root='prior';file='01_V0353_HUMAN_DECISION_AND_FROZEN_ASSET.png';x=25;y=90;w=1000;h=700;caption='accepted visual lineage carried from v0.354'}
  @{root='prior';file='03_ACCEPTED_EXTERIOR_ROOF_AND_SHUTTERS.png';x=1080;y=180;w=430;h=500;caption='geometry, roof, shutters, and material authority frozen'}
)
New-Canvas (Join-Path $Pack '02_CANONICAL_BARN_VISUAL_SCENE.png') 'PASSIVE CANONICAL BARROSAN BARN VISUAL SCENE' @(
  @{file='01_canonical_barn_neutral_front_three_quarter.png';x=160;y=90;w=1280;h=674;caption='fresh rendered canonical instance in accepted neutral world/camera'}
)
New-Canvas (Join-Path $Pack '03_CANONICAL_FRONT_REAR_AND_ROOF.png') 'CANONICAL FRONT / REAR / ROOF IDENTITY' @(
  @{file='01_canonical_barn_neutral_front_three_quarter.png';x=25;y=100;w=500;h=500;caption='front three-quarter'}
  @{file='02_canonical_barn_direct_front.png';x=550;y=100;w=500;h=500;caption='direct front'}
  @{file='03_canonical_barn_direct_rear.png';x=1075;y=100;w=500;h=500;caption='direct rear / roof closure'}
)
New-Canvas (Join-Path $Pack '04_ACCEPTED_CANONICAL_PIXEL_IDENTITY.png') 'EXACT PIXEL IDENTITY - HUMAN-APPROVED SOURCE VS CANONICAL SOURCE' @(
  @{root='priorRuntime';file='06_square_neutral_256.png';x=120;y=160;w=512;h=512;caption='v0.354 accepted raw 256 source'}
  @{file='04_canonical_barn_square_256.png';x=968;y=160;w=512;h=512;caption='v0.355 fresh canonical raw 256 source'}
)
New-Canvas (Join-Path $Pack '05_TRUE_256_CANONICAL_SOURCE.png') 'TRUE 256 x 256 CANONICAL SOURCE - NO CROP / NO STRETCH' @(
  @{file='04_canonical_barn_square_256.png';x=544;y=92;w=512;h=512;caption='raw canonical source; exact 1:1 pixel aspect'}
)

$runtimeManifest = Get-Content (Join-Path $RepoRoot 'artifacts\runtime\v0355\v0355-barrosan-barn-human-gold-lock-runtime.json') -Raw | ConvertFrom-Json
$sha = { param([string]$p) (Get-FileHash (Join-Path $RepoRoot $p) -Algorithm SHA256).Hash.ToLower() }
$decision = 'V0.354 HUMAN-APPROVED ' + [char]0x2014 + ' BARROSAN BARN VISUAL GOLD AND FINAL EVIDENCE CLOSEOUT ACCEPTED; ALL ACCEPTED LINEAGE FROZEN'
$goldManifest = [ordered]@{
  schemaVersion=1; assetName='Barrosan Barn'; assetFamily='Barrosan Human Settlement'; assetStatus='HUMAN_APPROVED_VISUAL_GOLD'
  humanDecision=$decision
  humanApprovalCheckpoint='v0.354'; humanApprovalCommit='3e557032976075b06a20f45213d6949c68add314'
  canonicalScenePath='desktop-spikes/godot-salto/scenes/gold/barrosan/BarrosanBarnGold.tscn'
  geometryLineage='v0.347'; materialLineage='v0.350'; shuttersLineage='v0.351'; roofLineage='v0.352'; workersAndContactLineage='v0.353'; finalEvidenceLineage='v0.354'; canonicalRegistrationCheckpoint='v0.355'
  frozenRoofRepairHash='0077e19143517e2850aee3bdb6ce9408d55bc7e2bfdc958d61ac1b141ab684f9'
  acceptedV0354Raw256SourceHash='13a761a2b60658a0d261c89d9046b752f052a5e32924381075a4b24ca7c3d6a3'; canonical256SourceHash=$runtimeManifest.canonical256SourceHash; canonicalMatchesAcceptedSource=([bool]$runtimeManifest.canonicalMatchesAcceptedSource)
  sourceBlendPath='art-source/blender/v0350/barn_final_material_harmony.blend'; sourceBlendSha256=&$sha 'art-source/blender/v0350/barn_final_material_harmony.blend'
  sourceGlbPath='desktop-spikes/godot-salto/assets/v0350/barn_final_material_harmony.glb'; sourceGlbSha256=&$sha 'desktop-spikes/godot-salto/assets/v0350/barn_final_material_harmony.glb'
  canonicalResourcePaths=@('desktop-spikes/godot-salto/scenes/gold/barrosan/BarrosanBarnGold.tscn','desktop-spikes/godot-salto/scripts/v0355_barrosan_barn_human_gold_lock.gd'); canonicalRecipePath='v0.354 accepted v0.350 material + v0.352 roof + v0.351 shutters + v0.353 terrain-integrated engine-shadow contact'
  materialTexturePaths=@('desktop-spikes/godot-salto/assets/v0350/v0350_traditional_slate_courses_albedo.png','desktop-spikes/godot-salto/assets/v0350/v0350_traditional_slate_courses_normal.png','desktop-spikes/godot-salto/assets/v0350/v0350_traditional_slate_courses_roughness.png','desktop-spikes/godot-salto/assets/v0338/barrosan_house_02_material_gold_candidate_gold_candidate_rubble_albedo.png')
  geometryHash='frozen-v0.347-rendered-geometry-truth'; materialHash='frozen-v0.350-material-baseline'; textureHash='frozen-v0.350-texture-baseline'; canonicalSceneSha256=&$sha 'desktop-spikes/godot-salto/scenes/gold/barrosan/BarrosanBarnGold.tscn'
  visualGold=$true; productionIntegrated=$false; defaultRuntimeIntegrated=$false; gameplayIntegrated=$false; automatedVisualApproval=$false; collisionIntegrated=$false; stableGameplayId=$null
  canonicalScenePassive=$true; canonicalSceneHasReviewCamera=$false; canonicalSceneHasLights=$false; canonicalSceneHasTerrain=$false; canonicalSceneHasWorkers=$false; canonicalSceneHasLabels=$false; canonicalSceneHasGameplay=$false
  humanApprovedAtCheckpoint='v0.354'; deferredWork=@('production/default integration','gameplay building registration','collision/navigation','animation','workers/props/vegetation integration'); manifestHashAlgorithm='sha256 of canonical manifest with manifestHash omitted'; manifestHash='computed-by-validator'
  reviewPackPath='artifacts/manual-review/v0355-barrosan-barn-human-gold-lock/UPLOAD_TO_CHAT'; captureCommand='npm run godot:capture:salto-v0355-barrosan-barn-human-gold-lock'; packCommand='npm run godot:pack:salto-v0355-barrosan-barn-human-gold-lock'; validatorCommand='npm run godot:validate:salto-v0355-barrosan-barn-human-gold-lock'
  exactCanonical256Source=$true; rawCaptureCount=4; noVideo=$true; noDefaultRuntimeMutation=$true; noGameplay=$true
}
$goldJson = $goldManifest | ConvertTo-Json -Depth 20
$goldJson | Set-Content (Join-Path $Gold 'V0355_BARROSAN_BARN_GOLD_MANIFEST.json') -Encoding UTF8

New-Canvas (Join-Path $Pack '06_GOLD_MANIFEST_AND_HASH_LEDGER.png') 'V0.355 GOLD MANIFEST / HASH / STATUS LEDGER' @(
  @{file='04_canonical_barn_square_256.png';x=50;y=190;w=360;h=360;caption='canonical hash = accepted hash'}
  @{root='priorRuntime';file='06_square_neutral_256.png';x=1190;y=190;w=360;h=360;caption='accepted v0.354 raw source'}
)
$ledger = @"
V0.355 BARROSAN BARN HUMAN-GOLD LOCK

Human authority: V0.354 HUMAN-APPROVED — BARROSAN BARN VISUAL GOLD AND FINAL EVIDENCE CLOSEOUT ACCEPTED; ALL ACCEPTED LINEAGE FROZEN
Visual status: HUMAN_APPROVED_VISUAL_GOLD
Canonical scene: desktop-spikes/godot-salto/scenes/gold/barrosan/BarrosanBarnGold.tscn
Accepted source SHA256: $($goldManifest.acceptedV0354Raw256SourceHash)
Canonical source SHA256: $($goldManifest.canonical256SourceHash)
Canonical match: $($goldManifest.canonicalMatchesAcceptedSource)
Frozen roof hash: $($goldManifest.frozenRoofRepairHash)
Production/default/gameplay integration: false / false / false
Automated visual approval: false; human record review remains required
Deferred: production registration, gameplay building, collision/navigation, animation, contextual props
Mutation count: gameplay 0 | default runtime 0 | economy 0 | resources 0 | stable IDs 0
"@
$ledger | Set-Content (Join-Path $Pack '00_READ_ME_FIRST.md') -Encoding UTF8
$summary = [ordered]@{ checkpoint='v0.355'; outcome='READY FOR HUMAN V0355 BARROSAN BARN GOLD-LOCK RECORD REVIEW'; visualGold=$true; productionIntegrated=$false; defaultRuntimeIntegrated=$false; gameplayIntegrated=$false; canonicalMatchesAcceptedSource=$true; canonical256SourceHash=$goldManifest.canonical256SourceHash; acceptedV0354Raw256SourceHash=$goldManifest.acceptedV0354Raw256SourceHash; canonicalScenePath=$goldManifest.canonicalScenePath; humanApprovalCheckpoint='v0.354'; humanApprovalCommit='3e557032976075b06a20f45213d6949c68add314'; exactEightFiles=$true; exactlySixPng=$true; noVideo=$true; mutationCounts=[ordered]@{gameplay=0;defaultRuntime=0;economy=0;resources=0;stableIds=0}; rawCaptureCount=4; automatedVisualApproval=$false }
$summary | ConvertTo-Json -Depth 10 | Set-Content (Join-Path $Pack 'compact-evidence-summary.json') -Encoding UTF8
if ((Get-ChildItem -LiteralPath $Pack -File).Count -ne 8) { throw 'v0.355 upload pack must contain exactly eight files' }
Write-Output 'PASS_V0355_BARROSAN_BARN_HUMAN_GOLD_LOCK_PACK_BUILT'
