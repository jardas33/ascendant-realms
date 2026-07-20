$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$Runtime = Join-Path $RepoRoot 'artifacts\runtime\v0348\screenshots'
$Diagnostics = Join-Path $RepoRoot 'artifacts\runtime\v0348\diagnostics'
$V0347Runtime = Join-Path $RepoRoot 'artifacts\runtime\v0347\screenshots'
$Source = Join-Path $RepoRoot 'art-source\blender\v0348'
$Pack = Join-Path $RepoRoot 'artifacts\manual-review\v0348-barn-material-harmony-gold-candidate\UPLOAD_TO_CHAT'
if (Test-Path -LiteralPath $Pack) { Get-ChildItem -LiteralPath $Pack -Force | Remove-Item -Force }
New-Item -ItemType Directory -Force -Path $Pack | Out-Null

function New-Board([string]$path, [array]$items, [string]$title) {
  $canvas = New-Object System.Drawing.Bitmap(1600, 900); $graphics = [System.Drawing.Graphics]::FromImage($canvas); $graphics.Clear([System.Drawing.Color]::FromArgb(71, 78, 70))
  $font = New-Object System.Drawing.Font('Arial', 20, [System.Drawing.FontStyle]::Bold); $small = New-Object System.Drawing.Font('Arial', 14, [System.Drawing.FontStyle]::Regular); $graphics.DrawString($title, $font, [System.Drawing.Brushes]::White, 28, 22)
  foreach ($item in $items) {
    $rootKey = [string]$item['root']; $fileKey = [string]$item['file']; $imagePath = if ($rootKey -eq 'v0347') { Join-Path $V0347Runtime $fileKey } elseif ($rootKey -eq 'diagnostics') { Join-Path $Diagnostics $fileKey } elseif ($rootKey -eq 'source') { Join-Path $Source $fileKey } else { Join-Path $Runtime $fileKey }
    $image = [System.Drawing.Image]::FromFile($imagePath); $rect = New-Object System.Drawing.Rectangle($item.x, $item.y, $item.w, $item.h)
    if ($item.gray) {
      $attributes = New-Object System.Drawing.Imaging.ImageAttributes; $matrix = New-Object System.Drawing.Imaging.ColorMatrix; $matrix.Matrix00=0.299; $matrix.Matrix01=0.299; $matrix.Matrix02=0.299; $matrix.Matrix10=0.587; $matrix.Matrix11=0.587; $matrix.Matrix12=0.587; $matrix.Matrix20=0.114; $matrix.Matrix21=0.114; $matrix.Matrix22=0.114; $attributes.SetColorMatrix($matrix); $graphics.DrawImage($image,$rect,0,0,$image.Width,$image.Height,[System.Drawing.GraphicsUnit]::Pixel,$attributes); $attributes.Dispose()
    } else { $graphics.DrawImage($image, $rect) }
    $graphics.DrawString($item.caption, $small, [System.Drawing.Brushes]::White, $item.x, ($item.y + $item.h + 8)); $image.Dispose()
  }
  $canvas.Save($path, [System.Drawing.Imaging.ImageFormat]::Png); $graphics.Dispose(); $canvas.Dispose(); $font.Dispose(); $small.Dispose()
}

function New-GrayscaleBoard([string]$path, [string]$source, [string]$title) {
  $image = [System.Drawing.Bitmap]::FromFile($source); $canvas = New-Object System.Drawing.Bitmap(1600, 900); $graphics = [System.Drawing.Graphics]::FromImage($canvas); $graphics.Clear([System.Drawing.Color]::FromArgb(71,78,70)); $font = New-Object System.Drawing.Font('Arial',20,[System.Drawing.FontStyle]::Bold); $graphics.DrawString($title,$font,[System.Drawing.Brushes]::White,28,22)
  $attributes = New-Object System.Drawing.Imaging.ImageAttributes; $matrix = New-Object System.Drawing.Imaging.ColorMatrix; $matrix.Matrix00=0.299; $matrix.Matrix01=0.299; $matrix.Matrix02=0.299; $matrix.Matrix10=0.587; $matrix.Matrix11=0.587; $matrix.Matrix12=0.587; $matrix.Matrix20=0.114; $matrix.Matrix21=0.114; $matrix.Matrix22=0.114; $attributes.SetColorMatrix($matrix); $graphics.DrawImage($image,(New-Object System.Drawing.Rectangle(30,90,1540,740)),0,0,$image.Width,$image.Height,[System.Drawing.GraphicsUnit]::Pixel,$attributes); $graphics.DrawString('Actual neutral-overcast render converted to greyscale for value readability.',(New-Object System.Drawing.Font('Arial',14)),[System.Drawing.Brushes]::White,30,840); $canvas.Save($path,[System.Drawing.Imaging.ImageFormat]::Png); $attributes.Dispose(); $image.Dispose(); $graphics.Dispose(); $canvas.Dispose(); $font.Dispose()
}

New-Board (Join-Path $Pack '01_HUMAN_V0347_ACCEPTANCE_AND_FROZEN_GEOMETRY.png') @(
  @{root='v0347';file='01_front_three_quarter.png';x=25;y=90;w=1000;h=700;caption='Accepted v0.347 render: geometry foundation retained unchanged'};
  @{root='source';file='v0348_roof_uv_checker.png';x=1050;y=130;w=480;h=480;caption='v0.348 derivative ledger: primary bounds unchanged; material-only candidate'}
) 'V0.348 HUMAN ACCEPTANCE AND FROZEN GEOMETRY LEDGER'
New-Board (Join-Path $Pack '02_FINAL_BARN_NEUTRAL_AND_FRONT.png') @(
  @{file='01_front_three_quarter.png';x=25;y=90;w=1000;h=700;caption='Final v0.348 neutral overcast front three-quarter'};
  @{file='02_direct_front.png';x=1050;y=90;w=525;h=700;caption='Final direct front: lower agricultural door remains dominant'}
) 'V0.348 FINAL BARN NEUTRAL AND DIRECT FRONT'
New-Board (Join-Path $Pack '03_HOUSE02_AND_BARN_SLATE_MATCH.png') @(
  @{file='04_house02_barn_slate_match.png';x=25;y=90;w=1550;h=700;caption='Actual matched camera: House02 anchor and v0.348 barn; visible slate courses and compatible scale'}
) 'V0.348 HOUSE02 AND BARN SLATE MATCH'
New-Board (Join-Path $Pack '04_GRANITE_GABLE_UV_CONTINUITY.png') @(
  @{file='03_direct_side_gable.png';x=25;y=90;w=760;h=700;caption='Actual complete granite gable: stone scale continues through triangle'};
  @{file='04_house02_barn_slate_match.png';x=815;y=90;w=760;h=700;caption='Actual roof-to-gable transition: dark edge and explicit eave/ridge treatment'}
) 'V0.348 GRANITE GABLE AND ROOF UV CONTINUITY'
New-Board (Join-Path $Pack '05_OPENINGS_TIMBER_AND_FOUNDATION.png') @(
  @{file='05_front_openings_closeup.png';x=25;y=90;w=1000;h=700;caption='Actual close render: lower double door, subordinate upper loading opening, timber and contact'};
  @{file='02_direct_front.png';x=1050;y=90;w=525;h=700;caption='Front hierarchy remains agricultural and broad'}
) 'V0.348 OPENINGS TIMBER AND FOUNDATION CONTACT'
New-Board (Join-Path $Pack '06_RTS_256_AND_GREYSCALE.png') @(
  @{file='06_far_rts.png';x=25;y=90;w=900;h=600;caption='Actual far RTS view'};
  @{file='07_256_pixel_source.png';x=980;y=90;w=256;h=256;caption='Actual 256px source'};
  @{file='10_warm_directional_full_asset.png';x=980;y=400;w=280;h=200;caption='Warm directional render'};
  @{file='09_neutral_overcast_full_asset.png';x=1280;y=400;w=280;h=200;caption='Neutral greyscale proof';gray=$true}
) 'V0.348 RTS, 256-PIXEL AND VALUE READABILITY'
New-Board (Join-Path $Pack '07_PBR_NORMAL_ROUGHNESS_AND_UV.png') @(
  @{root='diagnostics';file='normal_enabled.png';x=25;y=90;w=500;h=280;caption='Normal enabled'};
  @{root='diagnostics';file='normal_disabled.png';x=550;y=90;w=500;h=280;caption='Normal disabled'};
  @{root='diagnostics';file='albedo_only.png';x=1075;y=90;w=500;h=280;caption='Albedo-only diagnostic'};
  @{root='diagnostics';file='roughness_isolation.png';x=25;y=430;w=500;h=280;caption='Roughness isolation diagnostic'};
  @{root='source';file='v0348_roof_uv_checker.png';x=550;y=430;w=380;h=280;caption='UV checker source'};
  @{root='source';file='v0348_roof_uv_layout.png';x=975;y=430;w=380;h=280;caption='Authored roof/gable UV layout'}
) 'V0.348 PBR RESPONSE AND EXPLICIT ROOF UV EVIDENCE'
New-Board (Join-Path $Pack '08_TRUE_MATCHED_HOUSE02_BARN.png') @(
  @{file='08_true_matched_house02_barn.png';x=40;y=120;w=1520;h=760;caption='Actual 512x256 source panels: frozen House02 left / v0.348 barn right'}
) 'V0.348 TRUE MATCHED HOUSE02 AND BARN FRONT'

$metrics = Get-Content (Join-Path $Source 'v0348-barn-material-harmony-metrics.json') -Raw | ConvertFrom-Json
$manifest = Get-Content (Join-Path $RepoRoot 'artifacts\runtime\v0348\v0348-barn-material-harmony-runtime.json') -Raw | ConvertFrom-Json
$files = @('00_READ_ME_FIRST.md','01_HUMAN_V0347_ACCEPTANCE_AND_FROZEN_GEOMETRY.png','02_FINAL_BARN_NEUTRAL_AND_FRONT.png','03_HOUSE02_AND_BARN_SLATE_MATCH.png','04_GRANITE_GABLE_UV_CONTINUITY.png','05_OPENINGS_TIMBER_AND_FOUNDATION.png','06_RTS_256_AND_GREYSCALE.png','07_PBR_NORMAL_ROUGHNESS_AND_UV.png','08_TRUE_MATCHED_HOUSE02_BARN.png','compact-evidence-summary.json')
$summary = [ordered]@{ checkpoint='v0.348'; outcome=$manifest.outcome; automatedVisualApproval=$false; humanReviewRequired=$true; rawCaptureCount=$manifest.rawCaptureCount; rawCaptures=@($manifest.captures | ForEach-Object {$_.fileName}); requiredRawSet=@('01_front_three_quarter.png','02_direct_front.png','03_direct_side_gable.png','04_house02_barn_slate_match.png','05_front_openings_closeup.png','06_far_rts.png','07_256_pixel_source.png','08_true_matched_house02_barn.png','09_neutral_overcast_full_asset.png','10_warm_directional_full_asset.png'); geometryUnchanged=$metrics.geometryUnchanged; v0347FrozenGeometryHash=$metrics.v0347FrozenGeometryHash; finalHashes=$metrics.finalHashes; slateScale=$metrics.slateScale; roof=$metrics.roof; openings=$metrics.openings; responseMatrix='art-source/blender/v0348/v0348-material-response-matrix.json'; exactTenFiles=$true; exactlyEightPng=$true; noVideo=$true; noTitleCardOnlyEvidence=$true; noDefaultRuntimeIntegration=$true; noGameplay=$true }
$summary | ConvertTo-Json -Depth 30 | Set-Content (Join-Path $Pack 'compact-evidence-summary.json') -Encoding UTF8
@"
# v0.348 Barrosan material-harmony gold candidate

Outcome: **$($manifest.outcome)**

Human review remains required. This is not an automatic gold or production-ready approval. v0.347 geometry is frozen; the v0.348 derivative changes copied material resources and explicit roof/gable UV evidence only. Because Godot's locked importer rejected the new embedded Blender image variant, the captured opt-in scene uses the frozen v0.347 GLB as the geometry carrier and applies the v0.348 material skin in the isolated review fixture. The Blender source still records the material-harmony derivative, UV contract, slate measurements, and response matrix.

The upload pack contains exactly ten files: this readme, eight actual rendered PNG boards, and compact-evidence-summary.json. No video, title-card-only evidence, runtime integration, gameplay, movement, pathfinding, combat, economy, or resource mutation is included.

Capture: npm run godot:capture:salto-v0348-barn-material-harmony-gold-candidate
Pack: npm run godot:pack:salto-v0348-barn-material-harmony-gold-candidate
Validator: npm run godot:validate:salto-v0348-barn-material-harmony-gold-candidate

The ten raw Godot captures remain under artifacts/runtime/v0348/screenshots/; the diagnostic normal/albedo/roughness renders remain under artifacts/runtime/v0348/diagnostics/ and are represented on board 07. The true matched House02/barn source is 512x256 with 256x256 panels.
"@ | Set-Content (Join-Path $Pack '00_READ_ME_FIRST.md') -Encoding UTF8
if ((Get-ChildItem -LiteralPath $Pack -File).Count -ne 10) { throw 'v0.348 upload pack must contain exactly ten files' }
Write-Output 'PASS_V0348_BARN_MATERIAL_HARMONY_PACK_BUILT'
