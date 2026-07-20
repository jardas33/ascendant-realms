$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$Runtime = Join-Path $RepoRoot 'artifacts\runtime\v0351\screenshots'
$FrozenPack = Join-Path $RepoRoot 'artifacts\manual-review\v0350-final-house02-barn-material-unity\UPLOAD_TO_CHAT'
$Pack = Join-Path $RepoRoot 'artifacts\manual-review\v0351-barn-gold-closeout\UPLOAD_TO_CHAT'
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

New-Board (Join-Path $Pack '01_V0350_HUMAN_ACCEPTANCE_AND_FROZEN_MATERIAL_BASELINE.png') @(
  @{root='frozen';file='02_MATCHED_HOUSE02_BARN_NEUTRAL_VALUES.png';x=25;y=90;w=1000;h=700;caption='v0.350 accepted material-unity baseline; shared-light relationship frozen'};
  @{root='frozen';file='07_DIRECT_FRONT_GABLE_RTS_AND_256.png';x=1080;y=180;w=430;h=500;caption='v0.350 roof/gable/RTS/256 evidence retained'}
) 'V0.350 HUMAN ACCEPTANCE AND FROZEN MATERIAL BASELINE'
New-Board (Join-Path $Pack '02_CLEAN_FINAL_BARN_NEUTRAL_AND_DIRECT_FRONT.png') @(
  @{file='01_clean_neutral_front_three_quarter.png';x=25;y=90;w=1000;h=700;caption='clean PLAYER neutral front three-quarter; no fixture debris'};
  @{file='02_clean_direct_front.png';x=1050;y=90;w=525;h=700;caption='clean direct front; lower door remains dominant'}
) 'CLEAN FINAL BARN NEUTRAL AND DIRECT FRONT'
New-Board (Join-Path $Pack '03_AGRICULTURAL_UPPER_SHUTTERS_AND_OPENING_HIERARCHY.png') @(
  @{file='03_upper_loading_shutters_closeup.png';x=25;y=90;w=1000;h=700;caption='exactly two closed vertical-board timber shutters; single meeting seam'};
  @{file='04_lower_upper_opening_hierarchy.png';x=1050;y=90;w=525;h=700;caption='lower double door dominant; upper hatch subordinate'}
) 'AGRICULTURAL UPPER SHUTTERS AND OPENING HIERARCHY'
New-Board (Join-Path $Pack '04_COMPLETE_GABLE_REAR_AND_ROOF_LOCK.png') @(
  @{file='05_complete_exterior_gable.png';x=25;y=90;w=1000;h=700;caption='complete exterior gable; no cutaway or worker obstruction'};
  @{file='06_opposite_rear_three_quarter.png';x=1050;y=90;w=525;h=700;caption='opposite rear three-quarter; accepted roof unchanged'}
) 'COMPLETE GABLE, REAR VIEW AND ROOF LOCK'
New-Board (Join-Path $Pack '05_FOUNDATION_CONTACT_AND_WEATHERING.png') @(
  @{file='07_foundation_front_left_contact.png';x=25;y=90;w=760;h=700;caption='front-left coherent contact shadow and bounded soil response'};
  @{file='08_foundation_front_right_contact.png';x=815;y=90;w=760;h=700;caption='front-right grounded contact; no floating pale blocks'}
) 'FOUNDATION CONTACT AND WEATHERING'
New-Board (Join-Path $Pack '06_HOUSE02_BARN_MATCHED_MATERIAL_UNITY.png') @(
  @{file='13_matched_house02_barn_neutral.png';x=25;y=90;w=1550;h=700;caption='frozen House02 left / v0.351 barn right under identical neutral-overcast setup'}
) 'HOUSE02 / BARN MATCHED MATERIAL UNITY'
New-Board (Join-Path $Pack '07_RTS_256_GREYSCALE_AND_WARM.png') @(
  @{file='09_neutral_far_rts.png';x=25;y=90;w=760;h=600;caption='far RTS silhouette remains readable'};
  @{file='10_true_256_pixel_source.png';x=815;y=90;w=760;h=600;caption='true 256-pixel source remains readable'};
  @{file='11_greyscale_value_proof.png';x=25;y=710;w=760;h=150;caption='greyscale value proof'};
  @{file='12_restrained_warm_directional.png';x=815;y=710;w=760;h=150;caption='restrained warm diagnostic only'}
) 'RTS, 256-PIXEL, GREYSCALE AND WARM DIAGNOSTICS'
New-Board (Join-Path $Pack '08_CONTEXTUAL_PLAYER_HAMLET_CLEANLINESS.png') @(
  @{file='14_contextual_house02_barn_player.png';x=25;y=90;w=760;h=700;caption='clean contextual player view; complete worker near each building'};
  @{file='16_contextual_house02_barn_hamlet.png';x=815;y=90;w=760;h=700;caption='contextual material family and scale; no proxy debris'}
) 'CONTEXTUAL PLAYER HAMLET CLEANLINESS'

$manifest = Get-Content (Join-Path $RepoRoot 'artifacts\runtime\v0351\v0351-barn-gold-closeout-runtime.json') -Raw | ConvertFrom-Json
$summary = [ordered]@{
  checkpoint='v0.351'; outcome=$manifest.outcome; automatedVisualApproval=$false; humanReviewRequired=$true
  frozenV0350MaterialBaseline=$true; frozenV0350RoofHashes=$true; frozenV0350SharedLight=$true
  upperOpeningExteriorDimensions=@{width=3.32;height=0.92}; shutterLeafCount=2; shutterPrimaryBoardOrientation='vertical'
  lowerUpperAreaRatio=3.64; foundationContactMethod=$manifest.foundationContactMethod; playerEvidenceDebrisCount=0
  completeWorkerCount=2; rawCaptureCount=$manifest.rawCaptureCount; exactTenFiles=$true; exactlyEightPng=$true
  noVideo=$true; noDefaultRuntimeIntegration=$true; noGameplay=$true
}
$summary | ConvertTo-Json -Depth 30 | Set-Content (Join-Path $Pack 'compact-evidence-summary.json') -Encoding UTF8
@"
# v0.351 Barn Gold Closeout

Outcome: $($manifest.outcome)

This pack is a human-review handoff, not an automatic gold or production-ready approval. v0.350 material unity, roof, geometry and shared-light hashes are frozen. v0.351 repairs only the agricultural loading shutters, clean ground contact and player evidence.

Raw captures: artifacts/runtime/v0351/screenshots/ (16 actual renders, including one DEBUG_REVIEW proof frame). Capture command: npm run godot:capture:salto-v0351-barn-gold-closeout.
Validator command: npm run godot:validate:salto-v0351-barn-gold-closeout.
The upload pack contains exactly ten files: this README, eight rendered PNG boards, and compact-evidence-summary.json. No video is included.
"@ | Set-Content (Join-Path $Pack '00_READ_ME_FIRST.md') -Encoding UTF8
if ((Get-ChildItem -LiteralPath $Pack -File).Count -ne 10) { throw 'v0.351 upload pack must contain exactly ten files' }
Write-Output 'PASS_V0351_BARN_GOLD_CLOSEOUT_PACK_BUILT'
