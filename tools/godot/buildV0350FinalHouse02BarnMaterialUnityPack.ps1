$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$Runtime = Join-Path $RepoRoot 'artifacts\runtime\v0350\screenshots'
$Previous = Join-Path $RepoRoot 'artifacts\manual-review\v0349-final-barn-material-harmony\UPLOAD_TO_CHAT'
$Source = Join-Path $RepoRoot 'art-source\blender\v0350'
$Pack = Join-Path $RepoRoot 'artifacts\manual-review\v0350-final-house02-barn-material-unity\UPLOAD_TO_CHAT'
if (Test-Path -LiteralPath $Pack) { Get-ChildItem -LiteralPath $Pack -Force | Remove-Item -Force }
New-Item -ItemType Directory -Force -Path $Pack | Out-Null

function New-Board([string]$path, [array]$items, [string]$title) {
  $canvas = New-Object System.Drawing.Bitmap(1600,900); $g = [System.Drawing.Graphics]::FromImage($canvas); $g.Clear([System.Drawing.Color]::FromArgb(71,78,70))
  $font = New-Object System.Drawing.Font('Arial',20,[System.Drawing.FontStyle]::Bold); $small = New-Object System.Drawing.Font('Arial',14); $g.DrawString($title,$font,[System.Drawing.Brushes]::White,28,22)
  foreach ($item in $items) {
    $root = if ($item.root -eq 'previous') { $Previous } elseif ($item.root -eq 'source') { $Source } else { $Runtime }
    $img = [System.Drawing.Image]::FromFile((Join-Path $root $item.file)); $rect = New-Object System.Drawing.Rectangle($item.x,$item.y,$item.w,$item.h)
    if ($item.gray) { $attrs=New-Object System.Drawing.Imaging.ImageAttributes; $m=New-Object System.Drawing.Imaging.ColorMatrix; $m.Matrix00=.299;$m.Matrix01=.299;$m.Matrix02=.299;$m.Matrix10=.587;$m.Matrix11=.587;$m.Matrix12=.587;$m.Matrix20=.114;$m.Matrix21=.114;$m.Matrix22=.114;$attrs.SetColorMatrix($m);$g.DrawImage($img,$rect,0,0,$img.Width,$img.Height,[System.Drawing.GraphicsUnit]::Pixel,$attrs);$attrs.Dispose() } else { $g.DrawImage($img,$rect) }
    $g.DrawString($item.caption,$small,[System.Drawing.Brushes]::White,$item.x,($item.y+$item.h+8)); $img.Dispose()
  }
  $canvas.Save($path,[System.Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $canvas.Dispose(); $font.Dispose(); $small.Dispose()
}

New-Board (Join-Path $Pack '01_V0349_HUMAN_DECISION_AND_PRESERVED_BASELINE.png') @(
  @{root='previous';file='01_V0348_HUMAN_REJECTION_AND_PRESERVED_FOUNDATION.png';x=25;y=90;w=1000;h=700;caption='v0.349 accepted technical/material baseline; v0.349 human rejection preserved'};
  @{root='source';file='v0350_roof_uv_layout.png';x=1080;y=160;w=430;h=430;caption='v0.348 explicit roof/gable UV infrastructure retained'}
) 'V0.349 HUMAN DECISION AND PRESERVED TECHNICAL BASELINE'
New-Board (Join-Path $Pack '02_MATCHED_HOUSE02_BARN_NEUTRAL_VALUES.png') @(
  @{file='01_matched_house02_barn_neutral_full.png';x=25;y=90;w=1550;h=700;caption='same neutral-overcast camera and shared light; House02 left / v0.350 barn right'}
) 'MATCHED HOUSE02 / BARN NEUTRAL VALUES'
New-Board (Join-Path $Pack '03_SLATE_NORMAL_ENABLED_DISABLED_AND_ALBEDO.png') @(
  @{file='02_matched_roof_normal_enabled.png';x=25;y=90;w=760;h=600;caption='normal enabled: shallow relief only'};
  @{file='03_matched_roof_normal_disabled.png';x=815;y=90;w=760;h=600;caption='normal disabled: same recognisable slate material'};
  @{file='04_barn_albedo_only_roof.png';x=420;y=710;w=760;h=150;caption='albedo-only capture remains course-readable'}
) 'ALBEDO-FIRST SLATE AND NORMAL CONSISTENCY'
New-Board (Join-Path $Pack '04_TRADITIONAL_SLATE_VARIATION_AND_ROOF_EDGE.png') @(
  @{file='10_roof_edge_slate_irregularity.png';x=25;y=90;w=1000;h=700;caption='traditional varied widths, staggered joints and subordinate edge'};
  @{root='source';file='v0350_traditional_slate_courses_albedo.png';x=1060;y=170;w=450;h=450;caption='external albedo source with three restrained width patterns'}
) 'TRADITIONAL SLATE VARIATION AND ROOF EDGE'
New-Board (Join-Path $Pack '05_GRANITE_GABLE_AND_FOUNDATION_CONTACT.png') @(
  @{file='08_granite_foundation_closeup.png';x=25;y=90;w=1000;h=700;caption='medium grey granite, irregular lower contact and selected corner darkening'};
  @{file='07_complete_direct_exterior_gable.png';x=1050;y=90;w=525;h=700;caption='complete direct exterior silhouette; no cutaway or near-plane clip'}
) 'GRANITE GABLE AND FOUNDATION CONTACT'
New-Board (Join-Path $Pack '06_TIMBER_IRON_AND_REDUCED_UPPER_OPENING.png') @(
  @{file='09_doors_openings_closeup.png';x=25;y=90;w=1000;h=700;caption='muted chestnut timber, visible near-black iron, reduced upper opening'};
  @{file='06_direct_front.png';x=1050;y=90;w=525;h=700;caption='lower double agricultural door remains visibly dominant'}
) 'TIMBER, IRON AND REDUCED UPPER LOADING OPENING'
New-Board (Join-Path $Pack '07_DIRECT_FRONT_GABLE_RTS_AND_256.png') @(
  @{file='06_direct_front.png';x=25;y=90;w=760;h=600;caption='direct front'};
  @{file='07_complete_direct_exterior_gable.png';x=815;y=90;w=760;h=600;caption='complete exterior gable'};
  @{file='11_far_rts.png';x=25;y=710;w=760;h=150;caption='far RTS'};
  @{file='12_true_256_pixel_source.png';x=815;y=710;w=256;h=150;caption='256-pixel readability'}
) 'DIRECT FRONT, COMPLETE GABLE, RTS AND 256-PIXEL REVIEW'
New-Board (Join-Path $Pack '08_CONTEXTUAL_HAMLET_MATERIAL_UNITY.png') @(
  @{file='15_contextual_house02_barn_hamlet.png';x=25;y=90;w=1550;h=700;caption='bounded House02/barn hamlet with one restrained worker near each building'}
) 'CONTEXTUAL HOUSE02 / BARN HAMLET MATERIAL UNITY'

$metrics = Get-Content (Join-Path $Source 'v0350-final-house02-barn-material-unity-metrics.json') -Raw | ConvertFrom-Json
$manifest = Get-Content (Join-Path $RepoRoot 'artifacts\runtime\v0350\v0350-final-house02-barn-material-unity-runtime.json') -Raw | ConvertFrom-Json
$summary = [ordered]@{ checkpoint='v0.350'; outcome=$manifest.outcome; automatedVisualApproval=$false; humanReviewRequired=$true; rawCaptureCount=$manifest.rawCaptureCount; rawCaptures=@($manifest.captures | ForEach-Object {$_.fileName}); requiredRawSet=$manifest.requiredRawNames; geometryCarrierPreserved=$true; v0348Preserved=$metrics.v0348Preserved; v0349MaterialBaselinePreserved=$true; albedoFirst=$metrics.albedoFirst; normalIntensity=$metrics.normalIntensity; slatePalette=$metrics.slatePalette; foundationWeathering=$metrics.foundationWeathering; openings=$metrics.openings; exactTenFiles=$true; exactlyEightPng=$true; noVideo=$true; noDefaultRuntimeIntegration=$true; noGameplay=$true }
$summary | ConvertTo-Json -Depth 30 | Set-Content (Join-Path $Pack 'compact-evidence-summary.json') -Encoding UTF8
@"
# v0.350 Final House02/Barn Material Unity

Outcome: $($manifest.outcome)

This is a human-review handoff, not an automatic gold or production-ready approval. v0.349 was rejected as final gold because it remained too dark and too regular against House02. v0.350 preserves the accepted v0.347 geometry, v0.348 UV infrastructure, and v0.349 albedo-first resource workflow while calibrating shared-light value, traditional slate variation, granite, foundation contact, timber/iron, and the permitted upper-opening reduction.

The pack contains exactly ten files: this readme, eight actual rendered PNG boards, and compact-evidence-summary.json. No video is included. Raw captures remain under artifacts/runtime/V0350/screenshots/.

Capture command: npm run godot:capture:salto-v0350-final-house02-barn-material-unity
Validator command: npm run godot:validate:salto-v0350-final-house02-barn-material-unity
Source material paths are explicit under art-source/blender/v0350/ and desktop-spikes/godot-salto/assets/v0350/. The fixture is opt-in and not wired into the default runtime.
"@ | Set-Content (Join-Path $Pack '00_READ_ME_FIRST.md') -Encoding UTF8
if ((Get-ChildItem -LiteralPath $Pack -File).Count -ne 10) { throw 'v0.350 upload pack must contain exactly ten files' }
Write-Output 'PASS_V0350_FINAL_HOUSE02_BARN_MATERIAL_UNITY_PACK_BUILT'
