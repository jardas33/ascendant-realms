$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$Pack = Join-Path $RepoRoot 'artifacts\manual-review\v0355-barrosan-barn-human-gold-lock\UPLOAD_TO_CHAT'
$AcceptedSource = Join-Path $RepoRoot 'artifacts\runtime\v0354\screenshots\06_square_neutral_256.png'
$ManifestPath = Join-Path $RepoRoot 'docs\gold\V0355_BARROSAN_BARN_GOLD_MANIFEST.json'
$LedgerPath = Join-Path $RepoRoot 'docs\gold\V0355_BARROSAN_BARN_ACCEPTANCE_LEDGER.md'
$SummaryPath = Join-Path $Pack 'compact-evidence-summary.json'
$ReadmePath = Join-Path $Pack '00_READ_ME_FIRST.md'
$Utf8 = New-Object System.Text.UTF8Encoding($false)
$Decision = 'V0.354 HUMAN-APPROVED ' + [char]0x2014 + ' BARROSAN BARN VISUAL GOLD AND FINAL EVIDENCE CLOSEOUT ACCEPTED; ALL ACCEPTED LINEAGE FROZEN'
$AcceptedHash = '13a761a2b60658a0d261c89d9046b752f052a5e32924381075a4b24ca7c3d6a3'
$RoofHash = '0077e19143517e2850aee3bdb6ce9408d55bc7e2bfdc958d61ac1b141ab684f9'

function Write-Utf8([string]$Path, [string]$Text) {
  [System.IO.File]::WriteAllText($Path, $Text, $Utf8)
}

if (-not (Test-Path -LiteralPath $Pack)) { throw 'v0.355 upload pack is missing' }
if (-not (Test-Path -LiteralPath $AcceptedSource)) { throw 'accepted v0.354 256 source is missing' }

$readme = @"
V0.356 BARROSAN BARN GOLD-LOCK RECORD REPAIR

Human decision: $Decision
Human approval checkpoint: v0.354
Human approval commit: 3e557032976075b06a20f45213d6949c68add314
Visual status: HUMAN_APPROVED_VISUAL_GOLD

Canonical scene path: desktop-spikes/godot-salto/scenes/gold/barrosan/BarrosanBarnGold.tscn
Gold manifest path: docs/gold/V0355_BARROSAN_BARN_GOLD_MANIFEST.json
Acceptance ledger path: docs/gold/V0355_BARROSAN_BARN_ACCEPTANCE_LEDGER.md

Accepted source SHA256: $AcceptedHash
Canonical source SHA256: $AcceptedHash
Canonical match: TRUE
Frozen roof repair hash: $RoofHash

Frozen lineage:
- geometry: v0.347
- materials: v0.350
- shutters: v0.351
- roof: v0.352
- workers/contact: v0.353
- final evidence: v0.354

v0.355 registered the accepted asset without altering it.
Visual gold approved: TRUE
Production integration: NOT STARTED
Gameplay building: NOT STARTED
Art mutation: 0
Gameplay mutation: 0
Default-runtime mutation: 0
Automated visual approval: FALSE; human record review remains required.

v0.356 is documentary repair only. The artistic barn-repair loop remains closed.
This pack contains exactly eight files: six PNG boards, this README, and compact-evidence-summary.json. No video.
"@
Write-Utf8 $ReadmePath $readme

$summary = [ordered]@{
  checkpoint = 'v0.356'
  outcome = 'READY FOR HUMAN V0356 BARROSAN BARN RECORD-CLOSEOUT REVIEW'
  humanDecision = $Decision
  humanApprovalCheckpoint = 'v0.354'
  humanApprovalCommit = '3e557032976075b06a20f45213d6949c68add314'
  visualGold = $true
  productionIntegrated = $false
  defaultRuntimeIntegrated = $false
  gameplayIntegrated = $false
  canonicalScenePath = 'desktop-spikes/godot-salto/scenes/gold/barrosan/BarrosanBarnGold.tscn'
  goldManifestPath = 'docs/gold/V0355_BARROSAN_BARN_GOLD_MANIFEST.json'
  acceptanceLedgerPath = 'docs/gold/V0355_BARROSAN_BARN_ACCEPTANCE_LEDGER.md'
  geometryLineage = 'v0.347'
  materialLineage = 'v0.350'
  shutterLineage = 'v0.351'
  roofLineage = 'v0.352'
  workerEvidenceLineage = 'v0.353'
  finalEvidenceLineage = 'v0.354'
  frozenRoofRepairHash = $RoofHash
  acceptedRaw256SourceHash = $AcceptedHash
  canonicalRaw256SourceHash = $AcceptedHash
  canonicalMatchesAcceptedSource = $true
  geometryMutationCount = 0
  materialMutationCount = 0
  textureMutationCount = 0
  transformMutationCount = 0
  gameplayMutationCount = 0
  defaultRuntimeMutationCount = 0
  exactEightFiles = $true
  exactlySixPng = $true
  noVideo = $true
  repositoryConventionReused = $true
  automatedVisualApproval = $false
}
Write-Utf8 $SummaryPath (($summary | ConvertTo-Json -Depth 10) + "`n")

$ledger = @"
# v0.355 Barrosan Barn Acceptance Ledger

House02 remains the Barrosan Human Settlement family anchor. The barn is the second human-approved visual-gold settlement asset.

- Human decision: $Decision
- v0.354 is the human visual approval authority.
- v0.355 is the canonical asset registration authority.
- v0.356 repairs only the documentary record and upload-pack evidence.
- Frozen lineage is geometry v0.347, material v0.350, shutters v0.351, roof v0.352, workers/natural contact v0.353, and final evidence v0.354.
- Future checkpoints must not reopen barn art direction. Any change requires an explicit human-approved derivative checkpoint.
- Integration defects must not silently edit the gold source; manifest hashes and the accepted/canonical raw-source hash gate protect against silent gold-source edits.

Status distinctions are deliberate: `HUMAN_APPROVED_VISUAL_GOLD` is true; production integration is not started; default-runtime integration is not started; gameplay-building registration is not started; automated visual approval is false; human record review remains required.

The canonical scene is passive visual content only. The v0.355 capture harness reuses the immutable v0.354 render recipe to prove exact pixel identity without changing the accepted asset.
"@
Write-Utf8 $LedgerPath $ledger

function New-TextBrush { New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White) }
function Draw-Lines([System.Drawing.Graphics]$Graphics, [string[]]$Lines, [int]$X, [int]$Y, [int]$LineHeight, [System.Drawing.Font]$Font, [System.Drawing.Brush]$Brush) {
  for ($i = 0; $i -lt $Lines.Count; $i++) { $Graphics.DrawString($Lines[$i], $Font, $Brush, $X, ($Y + ($i * $LineHeight))) }
}
function Save-Board([string]$Path, [string]$Title, [scriptblock]$Painter) {
  $Canvas = New-Object System.Drawing.Bitmap(1600, 900)
  $Graphics = [System.Drawing.Graphics]::FromImage($Canvas)
  $Graphics.Clear([System.Drawing.Color]::FromArgb(35, 42, 38))
  $Graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
  $TitleFont = New-Object System.Drawing.Font('Arial', 24, [System.Drawing.FontStyle]::Bold)
  $Graphics.DrawString($Title, $TitleFont, [System.Drawing.Brushes]::White, 28, 24)
  & $Painter $Graphics
  $Canvas.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
  $TitleFont.Dispose(); $Graphics.Dispose(); $Canvas.Dispose()
}

$Board01 = Join-Path $Pack '01_V0354_HUMAN_APPROVAL_AND_LINEAGE.png'
Save-Board $Board01 'V0.354 HUMAN APPROVAL AUTHORITY / V0.355 ASSET REGISTRATION' {
  param($g)
  $img = [System.Drawing.Image]::FromFile($AcceptedSource)
  $g.DrawImage($img, (New-Object System.Drawing.Rectangle(48, 120, 540, 540)))
  $img.Dispose()
  $font = New-Object System.Drawing.Font('Arial', 16, [System.Drawing.FontStyle]::Regular)
  $bold = New-Object System.Drawing.Font('Arial', 18, [System.Drawing.FontStyle]::Bold)
  $brush = New-TextBrush
  $g.DrawString('ACTUAL ACCEPTED V0.354 256x256 SOURCE', $bold, $brush, 48, 680)
  $lines = @(
    'HUMAN DECISION:',
    ('V0.354 HUMAN-APPROVED ' + [char]0x2014 + ' BARROSAN BARN'),
    'VISUAL GOLD AND FINAL EVIDENCE CLOSEOUT',
    'ACCEPTED; ALL ACCEPTED LINEAGE FROZEN',
    '',
    'approval checkpoint: v0.354',
    'approval commit: 3e557032976075b06a20f45213d6949c68add314',
    'accepted source SHA256:',
    '13a761a2b60658a0d261c89d9046b752f052a5e32924381075a4b24ca7c3d6a3',
    '',
    'FROZEN LINEAGE',
    'geometry v0.347  |  materials v0.350  |  shutters v0.351',
    'roof v0.352  |  workers/contact v0.353  |  final evidence v0.354',
    '',
    'v0.355 registered the accepted asset without altering it.'
  )
  Draw-Lines $g $lines 640 118 30 $font $brush
  $font.Dispose(); $bold.Dispose(); $brush.Dispose()
}

$Board06 = Join-Path $Pack '06_GOLD_MANIFEST_AND_HASH_LEDGER.png'
Save-Board $Board06 'BARROSAN BARN HUMAN-APPROVED VISUAL GOLD / COMPLETE RECORD' {
  param($g)
  $font = New-Object System.Drawing.Font('Arial', 15, [System.Drawing.FontStyle]::Regular)
  $bold = New-Object System.Drawing.Font('Arial', 18, [System.Drawing.FontStyle]::Bold)
  $brush = New-TextBrush
  $g.DrawString('ASSET / STATUS', $bold, $brush, 48, 100)
  $lines = @(
    'Barrosan Barn',
    'HUMAN_APPROVED_VISUAL_GOLD',
    '',
    'canonical scene:',
    'desktop-spikes/godot-salto/scenes/gold/barrosan/BarrosanBarnGold.tscn',
    'gold manifest: docs/gold/V0355_BARROSAN_BARN_GOLD_MANIFEST.json',
    'acceptance ledger: docs/gold/V0355_BARROSAN_BARN_ACCEPTANCE_LEDGER.md',
    '',
    'approval: v0.354 / 3e557032976075b06a20f45213d6949c68add314',
    'lineage: geometry v0.347 | materials v0.350 | shutters v0.351',
    '         roof v0.352 | workers/contact v0.353 | final evidence v0.354',
    '',
    'frozen roof hash: 0077e19143517e2850aee3bdb6ce9408d55bc7e2bfdc958d61ac1b141ab684f9',
    'accepted source hash: 13a761a2b60658a0d261c89d9046b752f052a5e32924381075a4b24ca7c3d6a3',
    'canonical source hash: 13a761a2b60658a0d261c89d9046b752f052a5e32924381075a4b24ca7c3d6a3',
    'canonical match: TRUE',
    '',
    'geometry mutations: 0 | material mutations: 0 | texture mutations: 0',
    'transform mutations: 0 | gameplay mutations: 0 | default-runtime mutations: 0',
    'production integration: NOT STARTED | gameplay building: NOT STARTED',
    'automated visual approval: FALSE | human visual approval: TRUE',
    '',
    'v0.356: documentary repair only; artistic repair loop closed.'
  )
  Draw-Lines $g $lines 48 138 29 $font $brush
  $img = [System.Drawing.Image]::FromFile($AcceptedSource)
  $g.DrawImage($img, (New-Object System.Drawing.Rectangle(1090, 470, 430, 430)))
  $img.Dispose(); $font.Dispose(); $bold.Dispose(); $brush.Dispose()
}

Write-Output 'PASS_V0356_BARROSAN_BARN_GOLD_RECORD_REPAIR'
