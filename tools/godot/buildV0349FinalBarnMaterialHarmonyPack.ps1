$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$Runtime = Join-Path $RepoRoot 'artifacts\runtime\v0349\screenshots'
$Previous = Join-Path $RepoRoot 'artifacts\runtime\v0348\screenshots'
$Source = Join-Path $RepoRoot 'art-source\blender\v0349'
$Pack = Join-Path $RepoRoot 'artifacts\manual-review\v0349-final-barn-material-harmony\UPLOAD_TO_CHAT'
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

New-Board (Join-Path $Pack '01_V0348_HUMAN_REJECTION_AND_PRESERVED_FOUNDATION.png') @(
  @{root='previous';file='01_front_three_quarter.png';x=25;y=90;w=1000;h=700;caption='v0.348 human rejection context; frozen geometry and UV foundation retained'};
  @{root='source';file='v0349_roof_uv_layout.png';x=1080;y=160;w=430;h=430;caption='v0.348 UV infrastructure carried into v0.349'}
) 'V0.349 HUMAN REJECTION AND PRESERVED V0.347/V0.348 FOUNDATION'
New-Board (Join-Path $Pack '02_FINAL_NEUTRAL_FRONT_AND_GABLE.png') @(
  @{file='04_neutral_front_three_quarter.png';x=25;y=90;w=1000;h=700;caption='v0.349 neutral-overcast front three-quarter'};
  @{file='06_direct_granite_gable.png';x=1050;y=90;w=525;h=700;caption='continuous granite gable and dark subordinate edge'}
) 'V0.349 FINAL NEUTRAL FRONT AND GABLE'
New-Board (Join-Path $Pack '03_HOUSE02_BARN_SLATE_NORMAL_ENABLED.png') @(
  @{file='01_house02_barn_roof_normal_enabled.png';x=25;y=90;w=1550;h=700;caption='matched neutral camera; House02 left / v0.349 barn right; normal enabled; albedo-first slate'}
) 'HOUSE02 / BARN MATCH - NORMAL ENABLED'
New-Board (Join-Path $Pack '04_HOUSE02_BARN_SLATE_NORMAL_DISABLED_AND_ALBEDO.png') @(
  @{file='02_house02_barn_roof_normal_disabled.png';x=25;y=90;w=760;h=600;caption='same matched roof with normal disabled'};
  @{file='03_barn_roof_albedo_only.png';x=815;y=90;w=760;h=600;caption='barn albedo-only: slate courses remain visible without normal definition'}
) 'NORMAL-DISABLED AND ALBEDO-ONLY SLATE TRUTH'
New-Board (Join-Path $Pack '05_ROOF_EDGE_AND_SLATE_DETAIL.png') @(
  @{file='12_roof_edge_closeup.png';x=25;y=90;w=1000;h=700;caption='neutral eave, verge, ridge and tile overlap; edge nearly disappears at RTS'};
  @{root='source';file='v0349_weathered_slate_courses_albedo.png';x=1060;y=170;w=450;h=450;caption='external albedo source: staggered charcoal courses'}
) 'ROOF EDGE AND SLATE COURSE DETAIL'
New-Board (Join-Path $Pack '06_GRANITE_FOUNDATION_TIMBER_AND_OPENINGS.png') @(
  @{file='07_openings_foundation_closeup.png';x=25;y=90;w=1000;h=700;caption='lower-wall contact response, aged timber, iron and opening hierarchy'};
  @{file='05_direct_front.png';x=1050;y=90;w=525;h=700;caption='lower agricultural door dominant; upper opening subordinate'}
) 'GRANITE FOUNDATION TIMBER AND AGRICULTURAL OPENINGS'
New-Board (Join-Path $Pack '07_RTS_256_GREYSCALE_AND_WARM.png') @(
  @{file='08_far_rts.png';x=25;y=90;w=900;h=600;caption='ordinary far RTS readability'};
  @{file='09_256_pixel_source.png';x=980;y=90;w=256;h=256;caption='true 256px source'};
  @{file='10_greyscale.png';x=1280;y=90;w=280;h=200;caption='greyscale value proof'};
  @{file='11_warm_directional.png';x=980;y=420;w=580;h=320;caption='restrained warm directional response'}
) 'RTS, 256-PIXEL, GREYSCALE AND WARM-LIGHT REVIEW'
New-Board (Join-Path $Pack '08_TRUE_MATCHED_HOUSE02_BARN.png') @(
  @{file='01_house02_barn_roof_normal_enabled.png';x=40;y=120;w=1520;h=760;caption='actual matched source panels; no substituted frame or title-card evidence'}
) 'TRUE MATCHED HOUSE02 / BARN SOURCE'

$metrics = Get-Content (Join-Path $Source 'v0349-final-barn-material-harmony-metrics.json') -Raw | ConvertFrom-Json
$manifest = Get-Content (Join-Path $RepoRoot 'artifacts\runtime\v0349\v0349-final-barn-material-harmony-runtime.json') -Raw | ConvertFrom-Json
$summary = [ordered]@{ checkpoint='v0.349'; outcome=$manifest.outcome; automatedVisualApproval=$false; humanReviewRequired=$true; rawCaptureCount=$manifest.rawCaptureCount; rawCaptures=@($manifest.captures | ForEach-Object {$_.fileName}); requiredRawSet=@('01_house02_barn_roof_normal_enabled.png','02_house02_barn_roof_normal_disabled.png','03_barn_roof_albedo_only.png','04_neutral_front_three_quarter.png','05_direct_front.png','06_direct_granite_gable.png','07_openings_foundation_closeup.png','08_far_rts.png','09_256_pixel_source.png','10_greyscale.png','11_warm_directional.png','12_roof_edge_closeup.png'); geometryUnchanged=$metrics.geometryUnchanged; v0348Preserved=$metrics.v0348Preserved; albedoFirst=$metrics.albedoFirst; normalIntensity=$metrics.normalIntensity; slatePalette=$metrics.slatePalette; foundationWeathering=$metrics.foundationWeathering; openings=$metrics.openings; exactTenFiles=$true; exactlyEightPng=$true; noVideo=$true; noDefaultRuntimeIntegration=$true; noGameplay=$true }
$summary | ConvertTo-Json -Depth 30 | Set-Content (Join-Path $Pack 'compact-evidence-summary.json') -Encoding UTF8
@"
# v0.349 Final Barn Material Harmony

Outcome: $($manifest.outcome)

This is a human-review handoff, not an automatic gold or production-ready approval. v0.348 was rejected as a gold candidate because its roof read as a pale normal-dependent industrial grid. v0.349 preserves the frozen v0.347 geometry and v0.348 UV/material-response infrastructure while applying an isolated albedo-first dark slate response, reduced normal intensity, subdued edge, calibrated granite/timber/iron, and restrained agricultural weathering.

The pack contains exactly ten files: this readme, eight actual rendered PNG boards, and compact-evidence-summary.json. No video is included. Raw captures remain under artifacts/runtime/v0349/screenshots/.

Capture command: npm run godot:capture:salto-v0349-final-barn-material-harmony
Validator command: npm run godot:validate:salto-v0349-final-barn-material-harmony
Source material paths are explicit under art-source/blender/v0349/ and desktop-spikes/godot-salto/assets/v0349/. The fixture is opt-in and not wired into the default runtime.
"@ | Set-Content (Join-Path $Pack '00_READ_ME_FIRST.md') -Encoding UTF8
if ((Get-ChildItem -LiteralPath $Pack -File).Count -ne 10) { throw 'v0.349 upload pack must contain exactly ten files' }
Write-Output 'PASS_V0349_FINAL_BARN_MATERIAL_HARMONY_PACK_BUILT'
