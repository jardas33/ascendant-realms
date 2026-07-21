$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$repo = (Get-Location).Path
$raw = Join-Path $repo 'artifacts\runtime\v0364\capture\screenshots'
$pack = Join-Path $repo 'artifacts\manual-review\v0364-barrosan-foreground-prop-provenance-and-non-destructive-cleanup-preview\UPLOAD_TO_CHAT'
if (!(Test-Path -LiteralPath $raw)) { throw "Missing rendered v0.364 raw captures: $raw" }
if (Test-Path -LiteralPath $pack) { Remove-Item -LiteralPath $pack -Recurse -Force }
New-Item -ItemType Directory -Force -Path $pack | Out-Null

function Open-Img([string]$path) { if (!(Test-Path -LiteralPath $path)) { throw "Missing image $path" }; return [System.Drawing.Image]::FromFile($path) }
function Save-Bmp($bmp, [string]$path) { $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png); $bmp.Dispose() }
function Base-Board([string]$title, [string]$subtitle) {
  $b = New-Object System.Drawing.Bitmap(1600,900)
  $g = [System.Drawing.Graphics]::FromImage($b); $g.Clear([System.Drawing.Color]::FromArgb(20,29,27))
  $font = New-Object System.Drawing.Font('Segoe UI',34,[System.Drawing.FontStyle]::Bold)
  $small = New-Object System.Drawing.Font('Segoe UI',20)
  $g.DrawString($title,$font,[System.Drawing.Brushes]::Wheat,42,34)
  $g.DrawString($subtitle,$small,[System.Drawing.Brushes]::WhiteSmoke,44,86)
  $g.Dispose(); $font.Dispose(); $small.Dispose(); return $b
}
function Draw-Fit($g,$img,[int]$x,[int]$y,[int]$w,[int]$h) {
  $scale = [Math]::Min($w / $img.Width, $h / $img.Height); $dw=[int]($img.Width*$scale); $dh=[int]($img.Height*$scale)
  $g.DrawImage($img, $x+[int](($w-$dw)/2), $y+[int](($h-$dh)/2), $dw, $dh)
}
function Add-Footer($g,[string]$text) { $f=New-Object System.Drawing.Font('Segoe UI',18); $g.DrawString($text,$f,[System.Drawing.Brushes]::LightGreen,42,850); $f.Dispose() }
function Save-TextBoard([string]$name,[string[]]$lines) {
  $b=Base-Board $lines[0] 'V0364 documentary evidence only | no source-asset mutation'
  $g=[System.Drawing.Graphics]::FromImage($b); $f=New-Object System.Drawing.Font('Consolas',16)
  for($i=1;$i -lt $lines.Count;$i++){ $g.DrawString($lines[$i],$f,[System.Drawing.Brushes]::WhiteSmoke,58,125+(($i-1)*36)) }
  $g.Dispose(); $f.Dispose(); Save-Bmp $b (Join-Path $pack $name)
}

$readme = @'
READY FOR HUMAN V0364 BARROSAN FOREGROUND PROP PROVENANCE AND NON-DESTRUCTIVE CLEANUP PREVIEW REVIEW.

v0.363 evidence repair and the accepted Barn placement remain accepted. This pack audits three ambiguous foreground regions without cleaning any canonical or production asset. Hidden examples are review-only duplicate-instance visibility previews. Object A and object C are merged parent meshes and therefore receive annotated evidence instead of a fabricated removal. Object B is independently addressable in a duplicate, but its authored node is broader than the visually ambiguous bracket and its purpose is not established from source. Human disposition is required before any actual presentation or asset mutation.

Pack contents are eight PNG boards plus this README and compact-evidence-summary.json. Raw Godot captures remain under artifacts/runtime/v0364/capture and are not part of the exact upload pack.
'@
$enc=New-Object System.Text.UTF8Encoding($false); [System.IO.File]::WriteAllText((Join-Path $pack '00_READ_ME_FIRST.md'),$readme,$enc)

Save-TextBoard '01_HUMAN_DECISION_AND_SCOPE.png' @(
  'HUMAN DECISION AND SCOPE',
  'v0.363 evidence repair accepted; Barn placement remains accepted.',
  'v0.364 audits A, B and C only; no canonical or production asset cleanup.',
  'Original fixture nodes remain untouched; hidden examples are duplicate previews.',
  'A: merged House02 parent render mesh - future asset rework required.',
  'B: independently toggleable broad timber mesh - purpose not established from source.',
  'C: merged Barn render mesh - future asset rework required.',
  'HUMAN REVIEW STOP: decide disposition before any cleanup.'
)

$original=Open-Img (Join-Path $raw 'original.png'); $b=Base-Board 'ORIGINAL PLAYER VIEW WITH CALLOUTS' 'Unmodified accepted v0.363 opt-in view | callouts are documentary only'; $g=[System.Drawing.Graphics]::FromImage($b); Draw-Fit $g $original 30 130 1540 670
$f=New-Object System.Drawing.Font('Segoe UI',34,[System.Drawing.FontStyle]::Bold); $pen=New-Object System.Drawing.Pen([System.Drawing.Color]::Gold,4)
$g.DrawString('A', $f, [System.Drawing.Brushes]::Gold, 500, 560); $g.DrawString('B', $f, [System.Drawing.Brushes]::Gold, 700, 350); $g.DrawString('C', $f, [System.Drawing.Brushes]::Gold, 1100, 390)
$g.DrawLine($pen,535,580,700,540); $g.DrawLine($pen,735,380,665,435); $g.DrawLine($pen,1135,415,1045,455); Add-Footer $g 'A House02 ground-front object | B House02 upper timber object | C Barn front-right timber object'; $g.Dispose();$f.Dispose();$pen.Dispose();Save-Bmp $b (Join-Path $pack '02_ORIGINAL_PLAYER_VIEW_WITH_CALLOUTS.png');$original.Dispose()

function Image-Board([string]$name,[string]$title,[string]$rawName,[string[]]$notes) {
  $img=Open-Img (Join-Path $raw $rawName); $b=Base-Board $title 'Actual non-headless Godot viewport capture | review-only evidence'; $g=[System.Drawing.Graphics]::FromImage($b); Draw-Fit $g $img 30 125 1540 620
  $f=New-Object System.Drawing.Font('Segoe UI',20); $y=765; foreach($n in $notes){$g.DrawString($n,$f,[System.Drawing.Brushes]::WhiteSmoke,44,$y);$y+=28};$g.Dispose();$f.Dispose();$img.Dispose();Save-Bmp $b (Join-Path $pack $name)
}
Image-Board '03_HOUSE02_GROUND_OBJECT_ISOLATION.png' 'A - HOUSE02 GROUND-FRONT ISOLATION' 'house-a.png' @('Node: /V0358_House02_Shared_Baseline_Unmodified/LOD0_Granite','Owner: canonical House02 GLB | independently addressable: NO','MERGED WITH PARENT ASSET - FUTURE ASSET REWORK REQUIRED')
Image-Board '04_HOUSE02_UPPER_TIMBER_ISOLATION.png' 'B - HOUSE02 UPPER TIMBER ISOLATION' 'house-b.png' @('Node: /V0358_House02_Shared_Baseline_Unmodified/LOD0_Weathered_Timber','Owner: canonical House02 GLB | independently addressable in duplicate: YES','Purpose not established from source; broad node hides all authored timber surfaces in preview')
Image-Board '05_BARN_FRONT_TIMBER_ISOLATION.png' 'C - BARN FRONT-RIGHT TIMBER ISOLATION' 'barn-c.png' @('Node: /V0358_Barrosan_Barn_Gold_OptIn_Single_Instance/V0347_Barn_Rendered_Geometry_Truth','Owner: canonical Barn scene | independently addressable: NO','MERGED WITH PARENT ASSET - FUTURE ASSET REWORK REQUIRED')
Image-Board '06_COMBINED_NON_DESTRUCTIVE_CLEAN_PLAYER_PREVIEW.png' 'COMBINED NON-DESTRUCTIVE REVIEW PREVIEW' 'combined-preview.png' @('LEFT: exact original fixture | RIGHT: review-only duplicate preview with B hidden','NON-AUTHORITATIVE REVIEW PREVIEW | NO SOURCE-ASSET MUTATION','A and C remain visible because their parent meshes are merged; no fabricated removal')

$ledgerLines=@('PROVENANCE AND OWNERSHIP LEDGER','A | House02/LOD0_Granite | House02 GLB | toggle NO | R0/R1/R2 | REWORK ASSET LATER','  full path: /V0358_House02_Shared_Baseline_Unmodified/LOD0_Granite','B | House02/LOD0_Weathered_Timber | House02 GLB | toggle YES | R0/R1/R2 | INSUFFICIENT EVIDENCE','  full path: /V0358_House02_Shared_Baseline_Unmodified/LOD0_Weathered_Timber','C | Barn/V0347_Barn_Rendered_Geometry_Truth | Barn scene | toggle NO | R0/R1/R2 | REWORK ASSET LATER','  full path: /V0358_Barrosan_Barn_Gold_OptIn_Single_Instance/V0347_Barn_Rendered_Geometry_Truth','Transforms, AABBs and material identities are in v0364-provenance-probe.json.','Recommendations are documentary only. No production visibility rule changed.')
Save-TextBoard '07_PROVENANCE_AND_OWNERSHIP_LEDGER.png' $ledgerLines

$r0=Open-Img (Join-Path $repo 'artifacts\runtime\v0363\board07\screenshots\r0.png');$r1=Open-Img (Join-Path $repo 'artifacts\runtime\v0363\board07\screenshots\r1.png');$r2=Open-Img (Join-Path $repo 'artifacts\runtime\v0363\board07\screenshots\r2.png');$b=Base-Board 'R0 / R1 / R2 AND SOURCE PRESERVATION' 'Retained v0.363 evidence; v0.364 does not rerun performance benchmarks';$g=[System.Drawing.Graphics]::FromImage($b);Draw-Fit $g $r0 40 130 500 300;Draw-Fit $g $r1 550 130 500 300;Draw-Fit $g $r2 1060 130 500 300;$f=New-Object System.Drawing.Font('Consolas',17);$lines=@('R0 Barn root count 0 | R1 Barn root count 1 | R2 Barn root count 0','R0/R2 raw pixel match true | R0/R2 state signature match true','R1 duplicate Barn roots 0 | retained Barn nodes after rollback 0','Barn root (4.000, 0.180, -1.000) | structural 2.480 | roof/eave 2.510 | worker 1.875','canonical and House02 hashes unchanged | preview visibility only in v0.364 fixture');for($i=0;$i -lt $lines.Count;$i++){$g.DrawString($lines[$i],$f,[System.Drawing.Brushes]::WhiteSmoke,50,500+($i*45))};$g.Dispose();$f.Dispose();Save-Bmp $b (Join-Path $pack '08_R0_R1_R2_AND_SOURCE_PRESERVATION.png');$r0.Dispose();$r1.Dispose();$r2.Dispose()

$summary=@{checkpoint='v0.364';previousCheckpoint='v0.363';previousCommit='277f4d1d5a44660c0e9132efc45a001a319669df';v0363Accepted=$true;placementStillAccepted=$true;acceptedBarnRootTransform=@{x=4.0;y=0.18;z=-1.0};structuralGap=2.480;roofEaveGap=2.510;requiredWorkerGap=1.875;objectAFound=$true;objectANodePaths=@('/V0358_House02_Shared_Baseline_Unmodified/LOD0_Granite');objectAOwnerClassification='House02 canonical merged parent render mesh';objectAIndependentToggle=$false;objectAPresentStates=@('R0','R1','R2');objectARecommendation='REWORK ASSET LATER';objectBFound=$true;objectBNodePaths=@('/V0358_House02_Shared_Baseline_Unmodified/LOD0_Weathered_Timber');objectBOwnerClassification='House02 canonical active LOD0 mesh component';objectBIndependentToggle=$true;objectBPresentStates=@('R0','R1','R2');objectBRecommendation='INSUFFICIENT EVIDENCE';objectCFound=$true;objectCNodePaths=@('/V0358_Barrosan_Barn_Gold_OptIn_Single_Instance/V0347_Barn_Rendered_Geometry_Truth');objectCOwnerClassification='Canonical Barn single merged render mesh';objectCIndependentToggle=$false;objectCPresentStates=@('R0','R1','R2');objectCRecommendation='REWORK ASSET LATER';combinedPreviewCreated=$true;combinedPreviewReviewOnly=$true;combinedPreviewRuntimeMutationCount=0;canonicalBarnMutationCount=0;house02SourceMutationCount=0;geometryMutationCount=0;materialMutationCount=0;textureMutationCount=0;transformMutationCount=0;placementMutationCount=0;defaultRuntimeMutationCount=0;gameplayMutationCount=0;collisionMutationCount=0;navigationMutationCount=0;saveMutationCount=0;stableIdMutationCount=0;benchmarkRerunCount=0;r0BarnRootCount=0;r1BarnRootCount=1;r2BarnRootCount=0;r0R2RawCaptureMatch=$true;r0R2StateSignatureMatch=$true;r1DuplicateBarnRootCount=0;retainedBarnNodeCountAfterRollback=0;humanReviewStop=$true}
$json=$summary|ConvertTo-Json -Depth 8;[System.IO.File]::WriteAllText((Join-Path $pack 'compact-evidence-summary.json'),$json,$enc)
Write-Output "PASS_V0364_PACK $pack"
