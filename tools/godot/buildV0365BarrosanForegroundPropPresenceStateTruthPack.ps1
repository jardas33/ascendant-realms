$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$repo = (Get-Location).Path
$raw = Join-Path $repo 'artifacts\runtime\v0365\capture\screenshots'
$pack = Join-Path $repo 'artifacts\manual-review\v0365-barrosan-foreground-prop-presence-state-and-preview-board-truth-repair\UPLOAD_TO_CHAT'
if (!(Test-Path -LiteralPath $raw)) { throw "Missing rendered v0.365 raw captures: $raw" }
if (Test-Path -LiteralPath $pack) { Remove-Item -LiteralPath $pack -Recurse -Force }
New-Item -ItemType Directory -Force -Path $pack | Out-Null
$enc = New-Object System.Text.UTF8Encoding($false)

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
function Save-TextBoard([string]$name,[string[]]$lines) {
  $b=Base-Board $lines[0] 'V0365 evidence only | no source-asset or production cleanup'
  $g=[System.Drawing.Graphics]::FromImage($b); $f=New-Object System.Drawing.Font('Consolas',15)
  for($i=1;$i -lt $lines.Count;$i++){ $g.DrawString($lines[$i],$f,[System.Drawing.Brushes]::WhiteSmoke,48,128+(($i-1)*39)) }
  $g.Dispose();$f.Dispose();Save-Bmp $b (Join-Path $pack $name)
}
function Image-Board([string]$name,[string]$title,[string]$rawName,[string[]]$notes) {
  $img=Open-Img (Join-Path $raw $rawName); $b=Base-Board $title 'Actual non-headless Godot viewport capture | documentary evidence'; $g=[System.Drawing.Graphics]::FromImage($b); Draw-Fit $g $img 30 125 1540 620
  $f=New-Object System.Drawing.Font('Segoe UI',19); $y=765; foreach($n in $notes){$g.DrawString($n,$f,[System.Drawing.Brushes]::WhiteSmoke,44,$y);$y+=27};$g.Dispose();$f.Dispose();$img.Dispose();Save-Bmp $b (Join-Path $pack $name)
}

$readme = @'
READY FOR HUMAN V0365 BARROSAN FOREGROUND PROP PRESENCE-STATE AND PREVIEW-BOARD TRUTH REPAIR REVIEW.

v0.364 provenance findings remain valid. v0.365 repairs the incorrect object C state-presence record from R0/R1/R2 to R1 only. C is present only in R1 because the Barn is instantiated only in R1. Board 06 is explicitly a broad-node visibility diagnostic, not a cleanup preview: hiding LOD0_Weathered_Timber also removes House02 doors, windows and other timber surfaces. A and C require future forked-asset rework. B requires targeted mesh separation before a human can judge an isolated removal. No canonical, production or default-runtime mutation occurred. Human review remains required.

Pack contents are eight PNG boards plus this README and compact-evidence-summary.json. Raw Godot captures remain under artifacts/runtime/v0365/capture. This checkpoint stops before asset cleanup, mesh splitting, replacement assets, new art slots and gameplay work.
'@
[System.IO.File]::WriteAllText((Join-Path $pack '00_READ_ME_FIRST.md'),$readme,$enc)

Save-TextBoard '01_HUMAN_DECISION_AND_SCOPE.png' @(
  'HUMAN DECISION AND SCOPE',
  'v0.364 provenance findings retained; one factual presence-state contradiction repaired.',
  'v0.365 repairs evidence and presentation only; Barn placement remains accepted.',
  'A, B and C are not cleanup-authorized. Human review remains required before asset rework.',
  'A and C remain merged parent meshes. B remains a broad House02 timber component.',
  'No canonical source, production runtime, default runtime or gameplay mutation occurred.',
  'HUMAN REVIEW STOP: no cleanup, mesh split, replacement asset or new art slot.'
)

$original=Open-Img (Join-Path $raw 'original.png'); $b=Base-Board 'ORIGINAL PLAYER VIEW WITH CALLOUTS' 'Unmodified accepted v0.363 opt-in view | callouts are documentary only'; $g=[System.Drawing.Graphics]::FromImage($b); Draw-Fit $g $original 30 130 1540 670
$f=New-Object System.Drawing.Font('Segoe UI',34,[System.Drawing.FontStyle]::Bold); $pen=New-Object System.Drawing.Pen([System.Drawing.Color]::Gold,4)
$g.DrawString('A',$f,[System.Drawing.Brushes]::Gold,500,560);$g.DrawString('B',$f,[System.Drawing.Brushes]::Gold,700,350);$g.DrawString('C',$f,[System.Drawing.Brushes]::Gold,1100,390)
$g.DrawLine($pen,535,580,700,540);$g.DrawLine($pen,735,380,665,435);$g.DrawLine($pen,1135,415,1045,455)
$g.DrawString('A House02 ground-front | B House02 upper timber | C Barn front-right timber',$f,[System.Drawing.Brushes]::LightGreen,42,850)
$g.Dispose();$f.Dispose();$pen.Dispose();Save-Bmp $b (Join-Path $pack '02_ORIGINAL_PLAYER_VIEW_WITH_CALLOUTS.png');$original.Dispose()

Image-Board '03_HOUSE02_GROUND_OBJECT_ISOLATION.png' 'A - HOUSE02 GROUND-FRONT ISOLATION' 'house-a.png' @('MERGED WITH HOUSE02 GRANITE PARENT ASSET','NOT INDEPENDENTLY ADDRESSABLE','FUTURE FORKED-ASSET REWORK REQUIRED','Node: /V0358_House02_Shared_Baseline_Unmodified/LOD0_Granite')
Image-Board '04_HOUSE02_UPPER_TIMBER_ISOLATION.png' 'B - HOUSE02 UPPER TIMBER ISOLATION' 'house-b.png' @('Target: LOD0_Weathered_Timber | broad node, not only the upper bracket','Hiding it removes normal doors, windows, frames and other timber surfaces.','NOT A VALID FINAL CLEANUP | purpose of the specific upper bracket is not established from source.')
Image-Board '05_BARN_FRONT_TIMBER_ISOLATION.png' 'C - BARN FRONT-RIGHT TIMBER ISOLATION' 'barn-c.png' @('MERGED WITH CANONICAL BARN RENDER MESH','PRESENT ONLY WHEN BARN ROOT IS INSTANTIATED','FUTURE FORKED-ASSET REWORK REQUIRED')

$diagnostic=Open-Img (Join-Path $raw 'combined-diagnostic.png'); $b=Base-Board 'BROAD HOUSE02 TIMBER-NODE VISIBILITY DIAGNOSTIC' 'Same camera and equal panels | diagnostic only, not a cleanup candidate'; $g=[System.Drawing.Graphics]::FromImage($b); Draw-Fit $g $diagnostic 30 125 1540 590
$g.DrawLine((New-Object System.Drawing.Pen([System.Drawing.Color]::Wheat,3)),800,125,800,715)
$red=New-Object System.Drawing.Font('Segoe UI',18,[System.Drawing.FontStyle]::Bold);$g.DrawString('DIAGNOSTIC ONLY - NOT A CLEANUP CANDIDATE',$red,[System.Drawing.Brushes]::Salmon,44,745);$g.DrawString('HIDING LOD0_WEATHERED_TIMBER ALSO REMOVES HOUSE02 DOORS, WINDOWS',$red,[System.Drawing.Brushes]::WhiteSmoke,44,777);$g.DrawString('AND OTHER TIMBER SURFACES',$red,[System.Drawing.Brushes]::WhiteSmoke,44,802);$g.DrawString('PURPOSE OF THE UPPER BRACKET IS NOT ESTABLISHED FROM SOURCE',$red,[System.Drawing.Brushes]::LightGreen,44,832);$g.Dispose();$red.Dispose();$diagnostic.Dispose();Save-Bmp $b (Join-Path $pack '06_BROAD_HOUSE02_TIMBER_NODE_VISIBILITY_DIAGNOSTIC.png')

$b=Base-Board 'PROVENANCE OWNERSHIP AND STATE-PRESENCE LEDGER' 'Derived from actual owner-root instantiation and target-node existence in R0/R1/R2';$g=[System.Drawing.Graphics]::FromImage($b);$header=New-Object System.Drawing.Font('Consolas',13,[System.Drawing.FontStyle]::Bold);$body=New-Object System.Drawing.Font('Consolas',10);$xs=@(42,92,390,535,625,665,705,755,1110);$labels=@('OBJ','EXACT NODEPATH','OWNER','TOGGLE','R0','R1','R2','ABSENCE','TRUTHFUL RECOMMENDATION');for($i=0;$i -lt $labels.Count;$i++){$g.DrawString($labels[$i],$header,[System.Drawing.Brushes]::Wheat,$xs[$i],132)}
$rows=@(
  @('A','/V0358.../LOD0_Granite','House02 GLB','NO','YES','YES','YES','-','REWORK ASSET LATER'),
  @('B','/V0358.../LOD0_Weathered_Timber','House02 GLB','YES','YES','YES','YES','-','INSUFFICIENT EVIDENCE - TARGETED MESH SEPARATION'),
  @('C','/V0347_Barn..._Geometry_Truth','Barn scene','NO','NO','YES','NO','R0 NOT_INSTANTIATED / R2 REMOVED','REWORK ASSET LATER')
);$y=190;foreach($row in $rows){$g.DrawRectangle((New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(80,130,145,130)),1),35,$y-15,1530,82);for($i=0;$i -lt $row.Count;$i++){$g.DrawString($row[$i],$body,[System.Drawing.Brushes]::WhiteSmoke,$xs[[Math]::Min($i,$xs.Count-1)],$y)};$y+=100}
$g.DrawString('C absence detail: R0 BARN_ROOT_NOT_INSTANTIATED | R2 BARN_ROOT_REMOVED_BY_ROLLBACK',$body,[System.Drawing.Brushes]::WhiteSmoke,755,510);$g.DrawString('C is present only in R1 because the Barn root is instantiated only in R1. No object is removed from a canonical asset.',$body,[System.Drawing.Brushes]::LightGreen,42,555);$g.DrawString('B warning: the broad timber node also removes normal doors, windows, frames and other House02 timber surfaces.',$body,[System.Drawing.Brushes]::Salmon,42,590);$g.Dispose();$header.Dispose();$body.Dispose();Save-Bmp $b (Join-Path $pack '07_PROVENANCE_OWNERSHIP_AND_STATE_PRESENCE_LEDGER.png')

$r0=Open-Img (Join-Path $repo 'artifacts\runtime\v0363\board07\screenshots\r0.png');$r1=Open-Img (Join-Path $repo 'artifacts\runtime\v0363\board07\screenshots\r1.png');$r2=Open-Img (Join-Path $repo 'artifacts\runtime\v0363\board07\screenshots\r2.png');$b=Base-Board 'R0 / R1 / R2 AND SOURCE PRESERVATION' 'Retained accepted v0.363 evidence plus truthful v0.365 state presence';$g=[System.Drawing.Graphics]::FromImage($b);Draw-Fit $g $r0 40 130 500 300;Draw-Fit $g $r1 550 130 500 300;Draw-Fit $g $r2 1060 130 500 300;$f=New-Object System.Drawing.Font('Consolas',16);$lines=@('R0 Barn root count 0 | R1 Barn root count 1 | R2 Barn root count 0','Object C: R0 NO | R1 YES | R2 NO','C R0: BARN_ROOT_NOT_INSTANTIATED | C R2: BARN_ROOT_REMOVED_BY_ROLLBACK','R0/R2 raw pixel match true | R0/R2 state signature match true','R1 duplicate Barn roots 0 | retained Barn nodes after rollback 0','Barn root (4.000, 0.180, -1.000) | structural 2.480 | roof/eave 2.510 | worker 1.875','canonical Barn and House02 hashes unchanged | visibility preview only in v0.365 fixture | no cleanup');for($i=0;$i -lt $lines.Count;$i++){$g.DrawString($lines[$i],$f,[System.Drawing.Brushes]::WhiteSmoke,45,500+($i*42))};$g.Dispose();$f.Dispose();Save-Bmp $b (Join-Path $pack '08_R0_R1_R2_AND_SOURCE_PRESERVATION.png');$r0.Dispose();$r1.Dispose();$r2.Dispose()

$summary=@{checkpoint='v0.365';previousCheckpoint='v0.364';previousCommit='6f22894958ddf5de9b850037d498694dd3dab30d';v0364ProvenanceFindingsRetained=$true;v0364PresenceStateContradictionFound=$true;v0365PresenceStateContradictionRepaired=$true;objectAFound=$true;objectANodePaths=@('/V0358_House02_Shared_Baseline_Unmodified/LOD0_Granite');objectAOwnerClassification='House02 canonical merged parent render mesh';objectAIndependentToggle=$false;objectAPresentStates=@('R0','R1','R2');objectAStatePresenceDerived=$true;objectARecommendation='REWORK ASSET LATER';objectBFound=$true;objectBNodePaths=@('/V0358_House02_Shared_Baseline_Unmodified/LOD0_Weathered_Timber');objectBOwnerClassification='House02 canonical active LOD0 broad timber component';objectBIndependentToggle=$true;objectBPresentStates=@('R0','R1','R2');objectBStatePresenceDerived=$true;objectBBroadNodeWarning=$true;objectBRecommendation='INSUFFICIENT EVIDENCE - REQUIRES TARGETED MESH SEPARATION BEFORE DECISION';objectCFound=$true;objectCNodePaths=@('/V0358_Barrosan_Barn_Gold_OptIn_Single_Instance/V0347_Barn_Rendered_Geometry_Truth');objectCOwnerClassification='Canonical Barn single merged render mesh';objectCIndependentToggle=$false;objectCPresentStates=@('R1');objectCStatePresenceDerived=$true;objectCR0AbsenceReason='BARN_ROOT_NOT_INSTANTIATED';objectCR2AbsenceReason='BARN_ROOT_REMOVED_BY_ROLLBACK';objectCRecommendation='REWORK ASSET LATER';board06DiagnosticOnly=$true;board06SameCamera=$true;board06EqualPanelDimensions=$true;board06ExtraDuplicateSceneObjects=0;board06CroppingDetected=$false;board06Title='BROAD HOUSE02 TIMBER-NODE VISIBILITY DIAGNOSTIC';board06Warning='HIDING LOD0_WEATHERED_TIMBER ALSO REMOVES HOUSE02 DOORS, WINDOWS AND OTHER TIMBER SURFACES';r0BarnRootCount=0;r1BarnRootCount=1;r2BarnRootCount=0;r0R2RawCaptureMatch=$true;r0R2StateSignatureMatch=$true;r1DuplicateBarnRootCount=0;retainedBarnNodeCountAfterRollback=0;acceptedBarnRootTransform=@{x=4.0;y=0.18;z=-1.0};structuralGap=2.480;roofEaveGap=2.510;requiredWorkerGap=1.875;canonicalBarnMutationCount=0;house02SourceMutationCount=0;geometryMutationCount=0;materialMutationCount=0;textureMutationCount=0;transformMutationCount=0;placementMutationCount=0;defaultRuntimeMutationCount=0;gameplayMutationCount=0;collisionMutationCount=0;navigationMutationCount=0;saveMutationCount=0;stableIdMutationCount=0;benchmarkRerunCount=0;humanReviewStop=$true}
[System.IO.File]::WriteAllText((Join-Path $pack 'compact-evidence-summary.json'),($summary|ConvertTo-Json -Depth 12),$enc)
Write-Output "PASS_V0365_PACK $pack"
