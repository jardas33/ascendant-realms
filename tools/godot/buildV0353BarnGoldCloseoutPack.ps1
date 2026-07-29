$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$Runtime = Join-Path $RepoRoot 'artifacts\runtime\v0353\screenshots'
$FrozenPack = Join-Path $RepoRoot 'artifacts\manual-review\v0352-barn-final-gold-repair\UPLOAD_TO_CHAT'
$Pack = Join-Path $RepoRoot 'artifacts\manual-review\v0353-barn-gold-closeout\UPLOAD_TO_CHAT'
if (Test-Path -LiteralPath $Pack) { Get-ChildItem -LiteralPath $Pack -Force | Remove-Item -Force }
New-Item -ItemType Directory -Force -Path $Pack | Out-Null

function New-Board([string]$path, [array]$items, [string]$title) {
  $canvas = New-Object System.Drawing.Bitmap(1600,900)
  $g = [System.Drawing.Graphics]::FromImage($canvas); $g.Clear([System.Drawing.Color]::FromArgb(71,78,70))
  $font = New-Object System.Drawing.Font('Arial',20,[System.Drawing.FontStyle]::Bold); $small = New-Object System.Drawing.Font('Arial',14)
  $g.DrawString($title,$font,[System.Drawing.Brushes]::White,28,22)
  foreach ($item in $items) {
    $root = if ($item.root -eq 'frozen') { $FrozenPack } else { $Runtime }
    $source = Join-Path $root $item.file
    if (-not (Test-Path -LiteralPath $source)) { throw "Missing rendered source: $source" }
    $img = [System.Drawing.Image]::FromFile($source)
    $rect = New-Object System.Drawing.Rectangle($item.x,$item.y,$item.w,$item.h)
    $g.DrawImage($img,$rect); $g.DrawString($item.caption,$small,[System.Drawing.Brushes]::White,$item.x,($item.y+$item.h+8)); $img.Dispose()
  }
  $canvas.Save($path,[System.Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $canvas.Dispose(); $font.Dispose(); $small.Dispose()
}

New-Board (Join-Path $Pack '01_V0352_HUMAN_DECISION_AND_FROZEN_ROOF.png') @(
  @{root='frozen';file='03_COMPLETE_EXTERIOR_ROOF_ORBIT_PROOF.png';x=25;y=90;w=1000;h=700;caption='v0.352 retained exterior roof repair: frozen input'};
  @{root='frozen';file='01_V0351_HUMAN_DECISION_AND_FROZEN_SHUTTERS.png';x=1080;y=180;w=430;h=500;caption='v0.352 human rejection and freeze authority'}
) 'V0.352 HUMAN DECISION AND FROZEN ROOF'
New-Board (Join-Path $Pack '02_FINAL_BARN_AND_NATURAL_CONTACT.png') @(
  @{file='04_clean_foundation_front_left.png';x=25;y=90;w=760;h=700;caption='foundation contact is ordinary terrain plus engine shadow'};
  @{file='05_clean_foundation_front_right.png';x=815;y=90;w=760;h=700;caption='no rounded contact blobs, stains, slabs, or decal boundaries'}
) 'FINAL BARN AND NATURAL TERRAIN CONTACT'
New-Board (Join-Path $Pack '03_INTACT_WORKER_CLOSE_PROOF.png') @(
  @{file='07_worker_house02_close_three_quarter.png';x=25;y=90;w=760;h=700;caption='complete worker scene near House02'};
  @{file='08_worker_barn_close_three_quarter.png';x=815;y=90;w=760;h=700;caption='complete worker scene near barn'}
) 'INTACT COMPLETE WORKER CLOSE PROOF'
New-Board (Join-Path $Pack '04_CONTEXTUAL_THREE_QUARTER_PLAYER_PROOF.png') @(
  @{file='11_contextual_three_quarter_player.png';x=25;y=90;w=760;h=700;caption='clean contextual PLAYER three-quarter view'};
  @{file='12_contextual_worker_completeness_player.png';x=815;y=90;w=760;h=700;caption='both complete upright workers remain readable'}
) 'CONTEXTUAL THREE-QUARTER PLAYER PROOF'
New-Board (Join-Path $Pack '05_HOUSE02_BARN_MATCHED_MATERIAL_UNITY.png') @(
  @{file='18_matched_house02_barn_material_unity.png';x=25;y=90;w=1550;h=700;caption='frozen House02 and frozen barn materials remain matched'}
) 'HOUSE02 / BARN MATCHED MATERIAL UNITY'
New-Board (Join-Path $Pack '06_RETAINED_EXTERIOR_ROOF_PROOF.png') @(
  @{file='01_frozen_barn_neutral_front_three_quarter.png';x=25;y=90;w=760;h=700;caption='front three-quarter roof remains closed'};
  @{file='21_retained_roof_front_three_quarter.png';x=815;y=90;w=760;h=700;caption='second exterior orbit confirms retained roof'}
) 'RETAINED EXTERIOR ROOF PROOF'
New-Board (Join-Path $Pack '07_TRUE_ASPECT_RTS_256_GREYSCALE_WARM.png') @(
  @{file='13_ordinary_far_rts.png';x=25;y=90;w=520;h=700;caption='ordinary RTS camera'};
  @{file='14_true_256_pixel_source.png';x=575;y=140;w=520;h=520;caption='actual square 256 x 256 viewport source'};
  @{file='16_greyscale_value_proof.png';x=1125;y=90;w=430;h=330;caption='greyscale value proof'};
  @{file='17_restrained_warm_directional.png';x=1125;y=490;w=430;h=330;caption='restrained warm proof'}
) 'TRUE-ASPECT RTS 256 / GREYSCALE / WARM'
New-Board (Join-Path $Pack '08_FINAL_GOLD_CLOSEOUT_SUMMARY.png') @(
  @{file='19_debug_review_worker_hierarchy.png';x=25;y=90;w=760;h=700;caption='DEBUG_REVIEW worker hierarchy evidence'};
  @{file='20_debug_review_terrain_contact.png';x=815;y=90;w=760;h=700;caption='DEBUG_REVIEW terrain contact evidence'}
) 'V0.353 FINAL GOLD CLOSEOUT SUMMARY'

$manifest = Get-Content (Join-Path $RepoRoot 'artifacts\runtime\v0353\v0353-barn-gold-closeout-runtime.json') -Raw | ConvertFrom-Json
$summary = [ordered]@{
  checkpoint='v0.353'; outcome=$manifest.outcome; automatedVisualApproval=$false; humanReviewRequired=$true
  frozenV0352RoofRepair=$true; frozenRoofRepairHash=$manifest.frozenV0352RoofRepairHash
  completeWorkerCount=$manifest.completeWorkerCount; disassembledWorkerCount=$manifest.disassembledWorkerCount; detachedWorkerPartCount=$manifest.detachedWorkerPartCount; horizontalWorkerCount=$manifest.horizontalWorkerCount; uprightWorkerCount=$manifest.uprightWorkerCount; minimumContextWorkerPixelHeight=$manifest.minimumContextWorkerPixelHeight
  visibleContactBlobCount=$manifest.visibleContactBlobCount; visibleRectangularContactArtifactCount=$manifest.visibleRectangularContactArtifactCount; visibleDecalBoundaryCount=$manifest.visibleDecalBoundaryCount; floatingFoundationGeometryCount=$manifest.floatingFoundationGeometryCount; foundationContactMethod=$manifest.foundationContactMethod
  actual256SourceDimensions=$manifest.actual256SourceDimensions; pixelAspectRatio=$manifest.pixelAspectRatio; squareCaptureMethod=$manifest.squareCaptureMethod
  rawCaptureCount=$manifest.rawCaptureCount; exactTenFiles=$true; exactlyEightPng=$true; noVideo=$true; noDefaultRuntimeMutation=$true; noGameplay=$true
}
$summary | ConvertTo-Json -Depth 30 | Set-Content (Join-Path $Pack 'compact-evidence-summary.json') -Encoding UTF8
@"
# v0.353 Barn Gold Closeout

Outcome: $($manifest.outcome)

This is a human-review handoff, not an automatic gold or production approval. v0.352 roof, shutters, geometry, and material decisions are frozen. v0.353 repairs only complete worker-scene instantiation, natural terrain contact, and true-aspect square evidence.

Raw captures: artifacts/runtime/v0353/screenshots/ ($($manifest.rawCaptureCount) actual renders, including two DEBUG_REVIEW proof frames). Capture command: npm run godot:capture:salto-v0353-barn-gold-closeout.
Validator command: npm run godot:validate:salto-v0353-barn-gold-closeout.
The upload pack contains exactly ten files: this README, eight rendered PNG boards, and compact-evidence-summary.json. No video is included.
"@ | Set-Content (Join-Path $Pack '00_READ_ME_FIRST.md') -Encoding UTF8
if ((Get-ChildItem -LiteralPath $Pack -File).Count -ne 10) { throw 'v0.353 upload pack must contain exactly ten files' }
Write-Output 'PASS_V0353_BARN_GOLD_CLOSEOUT_PACK_BUILT'
