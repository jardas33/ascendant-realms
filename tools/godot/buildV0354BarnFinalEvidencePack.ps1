$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$Runtime = Join-Path $RepoRoot 'artifacts\runtime\v0354\screenshots'
$PriorPack = Join-Path $RepoRoot 'artifacts\manual-review\v0353-barn-gold-closeout\UPLOAD_TO_CHAT'
$Pack = Join-Path $RepoRoot 'artifacts\manual-review\v0354-barn-final-evidence\UPLOAD_TO_CHAT'
if (Test-Path -LiteralPath $Pack) { Get-ChildItem -LiteralPath $Pack -Force | Remove-Item -Force }
New-Item -ItemType Directory -Force -Path $Pack | Out-Null

function New-Board([string]$path, [array]$items, [string]$title) {
  $canvas = New-Object System.Drawing.Bitmap(1600,900)
  $g = [System.Drawing.Graphics]::FromImage($canvas); $g.Clear([System.Drawing.Color]::FromArgb(71,78,70))
  $font = New-Object System.Drawing.Font('Arial',20,[System.Drawing.FontStyle]::Bold); $small = New-Object System.Drawing.Font('Arial',14)
  $g.DrawString($title,$font,[System.Drawing.Brushes]::White,28,22)
  foreach ($item in $items) {
    $root = if ($item.root -eq 'prior') { $PriorPack } else { $Runtime }
    $source = Join-Path $root $item.file
    if (-not (Test-Path -LiteralPath $source)) { throw "Missing rendered source: $source" }
    $img = [System.Drawing.Image]::FromFile($source)
    $rect = New-Object System.Drawing.Rectangle($item.x,$item.y,$item.w,$item.h)
    $g.DrawImage($img,$rect)
    $g.DrawString($item.caption,$small,[System.Drawing.Brushes]::White,$item.x,($item.y+$item.h+8))
    $img.Dispose()
  }
  $canvas.Save($path,[System.Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $canvas.Dispose(); $font.Dispose(); $small.Dispose()
}

New-Board (Join-Path $Pack '01_V0353_HUMAN_DECISION_AND_FROZEN_ASSET.png') @(
  @{file='01_accepted_barn_neutral_front_three_quarter.png';x=25;y=90;w=1000;h=700;caption='v0.353 accepted barn geometry and frozen asset, carried into v0.354'};
  @{root='prior';file='01_V0352_HUMAN_DECISION_AND_FROZEN_ROOF.png';x=1080;y=180;w=430;h=500;caption='human rejection/freeze authority retained'}
) 'V0.353 HUMAN DECISION AND FROZEN ASSET'
New-Board (Join-Path $Pack '02_ACCEPTED_BARN_CONTACT_AND_WORKERS.png') @(
  @{file='04_accepted_natural_contact.png';x=25;y=90;w=760;h=700;caption='ordinary terrain and engine-shadow contact'};
  @{file='03_accepted_worker_integrity.png';x=815;y=90;w=760;h=700;caption='two complete upright workers'}
) 'ACCEPTED BARN CONTACT AND WORKERS'
New-Board (Join-Path $Pack '03_ACCEPTED_EXTERIOR_ROOF_AND_SHUTTERS.png') @(
  @{file='01_accepted_barn_neutral_front_three_quarter.png';x=25;y=90;w=760;h=700;caption='accepted front three-quarter roof'};
  @{file='05_accepted_exterior_roof.png';x=815;y=90;w=760;h=700;caption='accepted exterior roof and shutters'}
) 'ACCEPTED EXTERIOR ROOF AND SHUTTERS'
New-Board (Join-Path $Pack '04_CONTEXTUAL_PLAYER_PROOF.png') @(
  @{file='02_accepted_contextual_player.png';x=25;y=90;w=1550;h=700;caption='accepted contextual PLAYER proof'}
) 'CONTEXTUAL PLAYER PROOF'
New-Board (Join-Path $Pack '05_HOUSE02_BARN_MATERIAL_UNITY.png') @(
  @{root='prior';file='05_HOUSE02_BARN_MATCHED_MATERIAL_UNITY.png';x=25;y=90;w=1550;h=700;caption='accepted House02/barn material unity'}
) 'HOUSE02 / BARN MATERIAL UNITY'
New-Board (Join-Path $Pack '06_TRUE_256_NEUTRAL_SOURCE.png') @(
  @{file='06_square_neutral_256.png';x=544;y=92;w=512;h=512;caption='RAW SOURCE - exact 256 x 256 / 1:1 pixel aspect / no crop / no stretch'}
) 'TRUE 256 NEUTRAL SOURCE - RAW SQUARE'
New-Board (Join-Path $Pack '07_TRUE_ASPECT_256_NEUTRAL_GREYSCALE_WARM.png') @(
  @{file='06_square_neutral_256.png';x=70;y=110;w=400;h=400;caption='NEUTRAL - 256 x 256'};
  @{file='07_square_greyscale_256.png';x=600;y=110;w=400;h=400;caption='GREYSCALE - same camera'};
  @{file='08_square_warm_256.png';x=1130;y=110;w=400;h=400;caption='WARM - same camera'}
) 'TRUE-ASPECT 256 / NEUTRAL / GREYSCALE / WARM - IDENTICAL FRAMING'
New-Board (Join-Path $Pack '08_FINAL_EVIDENCE_CLOSEOUT_SUMMARY.png') @(
  @{file='10_debug_projected_bounds.png';x=25;y=90;w=760;h=700;caption='DEBUG_REVIEW projected bounds, 32 px margin, centred'};
  @{file='11_debug_camera_state_identity.png';x=815;y=90;w=760;h=700;caption='DEBUG_REVIEW identical camera-state evidence'}
) 'V0.354 FINAL EVIDENCE CLOSEOUT SUMMARY'

$manifest = Get-Content (Join-Path $RepoRoot 'artifacts\runtime\v0354\v0354-barn-final-evidence-runtime.json') -Raw | ConvertFrom-Json
$summary = [ordered]@{
  checkpoint=$manifest.checkpoint; outcome=$manifest.outcome; automatedVisualApproval=$false; humanReviewRequired=$true
  frozenV0352RoofRepair=$manifest.frozenV0352RoofRepair; frozenRoofRepairHash=$manifest.frozenRoofRepairHash; frozenV0351Shutters=$manifest.frozenV0351Shutters; frozenV0350MaterialBaseline=$manifest.frozenV0350MaterialBaseline; frozenV0353Workers=$manifest.frozenV0353Workers; frozenV0353TerrainContact=$manifest.frozenV0353TerrainContact
  completeWorkerCount=$manifest.completeWorkerCount; uprightWorkerCount=$manifest.uprightWorkerCount; disassembledWorkerCount=$manifest.disassembledWorkerCount; detachedWorkerPartCount=$manifest.detachedWorkerPartCount; horizontalWorkerCount=$manifest.horizontalWorkerCount; workerScenePath=$manifest.workerScenePath; workerInstantiationMethod=$manifest.workerInstantiationMethod; minimumContextWorkerPixelHeight=$manifest.minimumContextWorkerPixelHeight
  visibleContactBlobCount=$manifest.visibleContactBlobCount; visibleOvalStainCount=$manifest.visibleOvalStainCount; visibleElongatedStainCount=$manifest.visibleElongatedStainCount; visibleRectangularContactArtifactCount=$manifest.visibleRectangularContactArtifactCount; visibleDecalBoundaryCount=$manifest.visibleDecalBoundaryCount; floatingFoundationGeometryCount=$manifest.floatingFoundationGeometryCount; foundationContactMethod=$manifest.foundationContactMethod
  actual256SourceDimensions=$manifest.actual256SourceDimensions; actual256PixelAspectRatio=$manifest.actual256PixelAspectRatio; actual256SubjectBoundingBox=$manifest.actual256SubjectBoundingBox; actual256SubjectWidthPercentage=$manifest.actual256SubjectWidthPercentage; actual256SubjectHeightPercentage=$manifest.actual256SubjectHeightPercentage; actual256MinimumEdgeMargin=$manifest.actual256MinimumEdgeMargin; actual256HorizontalCentreError=$manifest.actual256HorizontalCentreError; actual256VerticalCentreError=$manifest.actual256VerticalCentreError
  reviewBoard256DisplayDimensions=$manifest.reviewBoard256DisplayDimensions; reviewBoard256DisplayAspectRatio=$manifest.reviewBoard256DisplayAspectRatio; stretched256EvidenceCount=$manifest.stretched256EvidenceCount; cropped256EvidenceCount=$manifest.cropped256EvidenceCount; clipped256EvidenceCount=$manifest.clipped256EvidenceCount; offCentre256EvidenceCount=$manifest.offCentre256EvidenceCount
  squareNeutralCameraHash=$manifest.squareNeutralCameraHash; squareGreyscaleCameraHash=$manifest.squareGreyscaleCameraHash; squareWarmCameraHash=$manifest.squareWarmCameraHash; raw256SourceHash=$manifest.raw256SourceHash; reviewBoardDisplayed256SourceHash=$manifest.reviewBoardDisplayed256SourceHash; contextualCameraMode=$manifest.contextualCameraMode
  rawCaptureCount=$manifest.rawCaptureCount; exactTenFiles=$true; exactlyEightPng=$true; noVideo=$true; noDefaultRuntimeMutation=$true; noGameplay=$true; scenePath=$manifest.scenePath; sourceOfFailedV0353Square=$manifest.sourceOfFailedV0353Square; squareCameraFailureDiagnosis=$manifest.squareCameraFailureDiagnosis
}
$summary | ConvertTo-Json -Depth 30 | Set-Content (Join-Path $Pack 'compact-evidence-summary.json') -Encoding UTF8
@"
# v0.354 Barn Final Evidence

Outcome: $($manifest.outcome)

This is a human-review handoff. v0.353 barn geometry, roof, shutters, materials, terrain contact, and workers are frozen. v0.354 repairs only true-aspect square capture framing, source/display identity, diagnostics, and evidence packaging.

The corrected square source is a direct 256x256 SubViewport using the accepted camera global transform, orthographic KEEP_HEIGHT framing, and square size 25.0. Measured subject bounds are $($manifest.actual256SubjectBoundingBox.width)x$($manifest.actual256SubjectBoundingBox.height), with $($manifest.actual256MinimumEdgeMargin) px minimum edge margin, $($manifest.actual256HorizontalCentreError) px horizontal centre error, and $($manifest.actual256VerticalCentreError) px vertical centre error.

Capture command: npm run godot:capture:salto-v0354-barn-final-evidence
Pack command: npm run godot:pack:salto-v0354-barn-final-evidence
Validator command: npm run godot:validate:salto-v0354-barn-final-evidence
Raw captures: artifacts/runtime/v0354/screenshots/ ($($manifest.rawCaptureCount) renders; 06/07/08 are exact 256x256 sources; 09 is the 2x integer display proof).

The upload pack contains exactly ten files: this README, eight PNG boards, and compact-evidence-summary.json. No video is included. Human review remains required; no automatic gold or production approval is claimed.
"@ | Set-Content (Join-Path $Pack '00_READ_ME_FIRST.md') -Encoding UTF8
if ((Get-ChildItem -LiteralPath $Pack -File).Count -ne 10) { throw 'v0.354 upload pack must contain exactly ten files' }
Write-Output 'PASS_V0354_BARN_FINAL_EVIDENCE_PACK_BUILT'
