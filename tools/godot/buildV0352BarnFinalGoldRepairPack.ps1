$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$Runtime = Join-Path $RepoRoot 'artifacts\runtime\v0352\screenshots'
$FrozenPack = Join-Path $RepoRoot 'artifacts\manual-review\v0351-barn-gold-closeout\UPLOAD_TO_CHAT'
$Pack = Join-Path $RepoRoot 'artifacts\manual-review\v0352-barn-final-gold-repair\UPLOAD_TO_CHAT'
if (Test-Path -LiteralPath $Pack) { Get-ChildItem -LiteralPath $Pack -Force | Remove-Item -Force }
New-Item -ItemType Directory -Force -Path $Pack | Out-Null

function New-Board([string]$path, [array]$items, [string]$title) {
  $canvas = New-Object System.Drawing.Bitmap(1600,900); $g = [System.Drawing.Graphics]::FromImage($canvas); $g.Clear([System.Drawing.Color]::FromArgb(71,78,70))
  $font = New-Object System.Drawing.Font('Arial',20,[System.Drawing.FontStyle]::Bold); $small = New-Object System.Drawing.Font('Arial',14)
  $g.DrawString($title,$font,[System.Drawing.Brushes]::White,28,22)
  foreach ($item in $items) {
    $root = if ($item.root -eq 'frozen') { $FrozenPack } else { $Runtime }
    $img = [System.Drawing.Image]::FromFile((Join-Path $root $item.file)); $rect = New-Object System.Drawing.Rectangle($item.x,$item.y,$item.w,$item.h)
    $g.DrawImage($img,$rect); $g.DrawString($item.caption,$small,[System.Drawing.Brushes]::White,$item.x,($item.y+$item.h+8)); $img.Dispose()
  }
  $canvas.Save($path,[System.Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $canvas.Dispose(); $font.Dispose(); $small.Dispose()
}

New-Board (Join-Path $Pack '01_V0351_HUMAN_DECISION_AND_FROZEN_SHUTTERS.png') @(
  @{root='frozen';file='03_AGRICULTURAL_UPPER_SHUTTERS_AND_OPENING_HIERARCHY.png';x=25;y=90;w=1000;h=700;caption='v0.351 accepted and frozen: two closed vertical-board agricultural shutters'};
  @{root='frozen';file='02_CLEAN_FINAL_BARN_NEUTRAL_AND_DIRECT_FRONT.png';x=1080;y=180;w=430;h=500;caption='v0.351 human rejection retained as repair authority'}
) 'V0.351 HUMAN DECISION AND FROZEN SHUTTERS'
New-Board (Join-Path $Pack '02_FINAL_BARN_FRONT_AND_DIRECT_FRONT.png') @(
  @{file='01_front_three_quarter_left.png';x=25;y=90;w=760;h=700;caption='front three-quarter left: closed roof and clean contact'};
  @{file='03_direct_front.png';x=815;y=90;w=760;h=700;caption='direct front: lower door dominant and shutters unchanged'}
) 'FINAL BARN FRONT AND DIRECT FRONT'
New-Board (Join-Path $Pack '03_COMPLETE_EXTERIOR_ROOF_ORBIT_PROOF.png') @(
  @{file='02_front_three_quarter_right.png';x=25;y=90;w=500;h=700;caption='front right'};
  @{file='05_rear_three_quarter_left.png';x=550;y=90;w=500;h=700;caption='rear left'};
  @{file='06_rear_three_quarter_right.png';x=1075;y=90;w=500;h=700;caption='rear right'}
) 'COMPLETE EXTERIOR ROOF ORBIT PROOF'
New-Board (Join-Path $Pack '04_REAR_GABLE_AND_ROOF_VISIBILITY.png') @(
  @{file='04_direct_rear.png';x=25;y=90;w=760;h=700;caption='direct rear: both closed roof slopes, no cavity'};
  @{file='07_direct_left_gable.png';x=815;y=90;w=760;h=700;caption='direct left gable: complete exterior silhouette'}
) 'REAR GABLE AND ROOF VISIBILITY'
New-Board (Join-Path $Pack '05_ORGANIC_FOUNDATION_CONTACT.png') @(
  @{file='10_foundation_front_left_organic.png';x=25;y=90;w=500;h=700;caption='front-left rounded contact darkening'};
  @{file='11_foundation_front_right_organic.png';x=550;y=90;w=500;h=700;caption='front-right rounded contact darkening'};
  @{file='12_foundation_rear_organic.png';x=1075;y=90;w=500;h=700;caption='rear contact: no perimeter slab'}
) 'ORGANIC FOUNDATION CONTACT'
New-Board (Join-Path $Pack '06_HOUSE02_BARN_MATCHED_MATERIAL_UNITY.png') @(
  @{file='17_matched_house02_barn_neutral.png';x=25;y=90;w=1550;h=700;caption='frozen House02 left / repaired barn right under shared neutral-overcast light'}
) 'HOUSE02 / BARN MATCHED MATERIAL UNITY'
New-Board (Join-Path $Pack '07_RTS_256_GREYSCALE_AND_WARM.png') @(
  @{file='13_ordinary_far_rts.png';x=25;y=90;w=760;h=520;caption='ordinary elevated RTS camera'};
  @{file='14_true_256_pixel_source.png';x=815;y=90;w=760;h=520;caption='actual 256 x 256 normal-camera source'};
  @{file='15_greyscale_value_proof.png';x=25;y=640;w=760;h=220;caption='same useful camera family, greyscale'};
  @{file='16_restrained_warm_directional.png';x=815;y=640;w=760;h=220;caption='same useful camera family, warm diagnostic'}
) 'RTS, 256, GREYSCALE AND WARM PROOF'
New-Board (Join-Path $Pack '08_CONTEXTUAL_THREE_QUARTER_PLAYER_PROOF.png') @(
  @{file='18_contextual_three_quarter_player.png';x=25;y=90;w=760;h=700;caption='clean three-quarter PLAYER context; both workers inspectable'};
  @{file='19_contextual_worker_completeness.png';x=815;y=90;w=760;h=700;caption='closer worker-completeness and believable scale proof'}
) 'CONTEXTUAL THREE-QUARTER PLAYER PROOF'

$manifest = Get-Content (Join-Path $RepoRoot 'artifacts\runtime\v0352\v0352-barn-final-gold-repair-runtime.json') -Raw | ConvertFrom-Json
$summary = [ordered]@{
  checkpoint='v0.352'; outcome=$manifest.outcome; automatedVisualApproval=$false; humanReviewRequired=$true
  frozenV0351Shutters=$true; frozenV0350MaterialBaseline=$true; oldRoofGeometryHash=$manifest.oldRoofGeometryHash; newRoofGeometryHash=$manifest.newRoofGeometryHash
  roofRepairReason='closed two-slope underside inside frozen eave/ridge bounds; ordinary backface culling retained'; roofExteriorBoundsBefore=$manifest.roofExteriorBoundsBefore; roofExteriorBoundsAfter=$manifest.roofExteriorBoundsAfter
  roofExteriorOrbitViewCount=$manifest.roofExteriorOrbitViewCount; missingRoofSlopeCount=0; exteriorCutawayCount=0; roofInteriorExposureCount=0
  upperOpeningExteriorDimensions=@{width=3.32;height=0.92}; shutterLeafCount=2; shutterPrimaryBoardOrientation='vertical'; lowerUpperAreaRatio=3.64
  visibleRectangularContactArtifactCount=0; visibleDecalBoundaryCount=0; floatingFoundationGeometryCount=0; foundationContactMethod=$manifest.foundationContactMethod
  contextualCameraMode='three-quarter RTS'; completeWorkerCount=2; minimumContextWorkerPixelHeight=20; actual256SourceDimensions='256x256'
  rawCaptureCount=$manifest.rawCaptureCount; exactTenFiles=$true; exactlyEightPng=$true; noVideo=$true; noDefaultRuntimeIntegration=$true; noGameplay=$true
}
$summary | ConvertTo-Json -Depth 30 | Set-Content (Join-Path $Pack 'compact-evidence-summary.json') -Encoding UTF8
@"
# v0.352 Barn Final-Gold Repair

Outcome: $($manifest.outcome)

This is a human-review handoff, not an automatic gold or production-ready approval. v0.351 agricultural shutters are accepted and frozen. v0.352 repairs only exterior roof closure, organic ground contact, and contextual PLAYER proof.

Raw captures: artifacts/runtime/v0352/screenshots/ (20 actual renders, including one DEBUG_REVIEW proof frame). Capture command: npm run godot:capture:salto-v0352-barn-final-gold-repair.
Validator command: npm run godot:validate:salto-v0352-barn-final-gold-repair.
The upload pack contains exactly ten files: this README, eight rendered PNG boards, and compact-evidence-summary.json. No video is included.
"@ | Set-Content (Join-Path $Pack '00_READ_ME_FIRST.md') -Encoding UTF8
if ((Get-ChildItem -LiteralPath $Pack -File).Count -ne 10) { throw 'v0.352 upload pack must contain exactly ten files' }
Write-Output 'PASS_V0352_BARN_FINAL_GOLD_REPAIR_PACK_BUILT'
