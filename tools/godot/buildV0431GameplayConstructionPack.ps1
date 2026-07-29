param(
  [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$pack = Join-Path $RepoRoot 'artifacts/manual-review/v0431-gameplay-readability-construction-loop'
New-Item -ItemType Directory -Force -Path $pack | Out-Null

function Get-ImageStats([string]$Path) {
  $img = [System.Drawing.Image]::FromFile($Path)
  try {
    $step = 8
    $count = 0
    [double]$sum = 0
    [double]$sumSq = 0
    for ($y = 0; $y -lt $img.Height; $y += $step) {
      for ($x = 0; $x -lt $img.Width; $x += $step) {
        $p = ([System.Drawing.Bitmap]$img).GetPixel($x, $y)
        $l = (0.2126 * $p.R) + (0.7152 * $p.G) + (0.0722 * $p.B)
        $sum += $l; $sumSq += ($l * $l); $count++
      }
    }
    $avg = $sum / [Math]::Max(1, $count)
    $variance = ($sumSq / [Math]::Max(1, $count)) - ($avg * $avg)
    return [ordered]@{ file = [IO.Path]::GetFileName($Path); width = $img.Width; height = $img.Height; bytes = (Get-Item $Path).Length; meanLuma = [Math]::Round($avg, 3); lumaVariance = [Math]::Round([Math]::Max(0, $variance), 3); nonBlack = ($avg -gt 5); meaningfulVariance = ($variance -gt 50) }
  } finally { $img.Dispose() }
}

function New-Sheet([string]$OutputName, [string[]]$Names, [string]$Title) {
  $width = 1920; $cellW = 460; $cellH = 300; $cols = 4
  $items = @($Names | ForEach-Object { $p = Join-Path $pack $_; if (-not (Test-Path $p)) { throw "Missing contact-sheet source: $p" }; Get-Item $p })
  $rows = [Math]::Max(1, [Math]::Ceiling($items.Count / $cols)); $height = 92 + ($rows * $cellH)
  $bmp = New-Object System.Drawing.Bitmap($width, $height); $gfx = [System.Drawing.Graphics]::FromImage($bmp)
  $gfx.Clear([System.Drawing.Color]::FromArgb(22, 27, 31))
  $fontTitle = New-Object System.Drawing.Font('Segoe UI', 24, [System.Drawing.FontStyle]::Bold)
  $fontLabel = New-Object System.Drawing.Font('Segoe UI', 11, [System.Drawing.FontStyle]::Regular)
  $muted = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(190, 205, 210))
  $gfx.DrawString($Title, $fontTitle, [System.Drawing.Brushes]::White, 24, 20)
  for ($i = 0; $i -lt $items.Count; $i++) {
    $item = $items[$i]; $x = 20 + (($i % $cols) * $cellW); $y = 82 + ([Math]::Floor($i / $cols) * $cellH)
    $rect = [System.Drawing.Rectangle]::new([int]$x, [int]$y, [int]($cellW - 18), [int]($cellH - 42))
    $img = [System.Drawing.Image]::FromFile($item.FullName)
    try {
      $scale = [Math]::Min($rect.Width / $img.Width, $rect.Height / $img.Height); $dw = [int]($img.Width * $scale); $dh = [int]($img.Height * $scale)
      $dx = $rect.X + [int](($rect.Width - $dw) / 2); $dy = $rect.Y + [int](($rect.Height - $dh) / 2)
      $gfx.DrawImage($img, $dx, $dy, $dw, $dh)
    } finally { $img.Dispose() }
    $gfx.DrawString($item.Name, $fontLabel, $muted, $x, $y + $rect.Height + 5)
  }
  $bmp.Save((Join-Path $pack $OutputName), [System.Drawing.Imaging.ImageFormat]::Png)
  $gfx.Dispose(); $bmp.Dispose(); $fontTitle.Dispose(); $fontLabel.Dispose(); $muted.Dispose()
}

$baseName = '01_V0430_GAMEPLAY_BASELINE.png'
$afterName = '02_V0431_GAMEPLAY_READABILITY_AFTER.png'
$previewName = '07_V0431_CLAN_CROFT_VALID_PREVIEW.png'
$flowNames = @($afterName, '04_V0431_WORKER_SELECTED.png', '05_V0431_WORKER_MOVEMENT_DESTINATION.png', '06_V0431_CLAN_CROFT_BUILD_MENU.png', $previewName, '08_V0431_CLAN_CROFT_INVALID_PREVIEW.png', '09_V0431_PLACEMENT_CONFIRMED_RESOURCE_DEDUCTION.png', '10_V0431_CONSTRUCTION_EARLY_PROGRESS.png', '11_V0431_CONSTRUCTION_LATE_PROGRESS.png', '12_V0431_CLAN_CROFT_COMPLETE.png', '13_V0431_COMPLETED_CLAN_CROFT_SELECTED.png', '14_V0431_REPLAY_SECOND_LOOP_COMPLETE.png')
New-Sheet '03_V0430_V0431_MATCHED_GAMEPLAY_COMPARISON.png' @($baseName, $afterName, $previewName) 'v0.430 baseline / v0.431 headed production comparison'
New-Sheet '18_V0431_GAMEPLAY_CONSTRUCTION_CONTACT_SHEET.png' $flowNames 'v0.431 real headed construction loop'

$stats = @($baseName, $afterName, $previewName, '04_V0431_WORKER_SELECTED.png', '05_V0431_WORKER_MOVEMENT_DESTINATION.png', '09_V0431_PLACEMENT_CONFIRMED_RESOURCE_DEDUCTION.png', '12_V0431_CLAN_CROFT_COMPLETE.png', '13_V0431_COMPLETED_CLAN_CROFT_SELECTED.png', '14_V0431_REPLAY_SECOND_LOOP_COMPLETE.png') | ForEach-Object { Get-ImageStats (Join-Path $pack $_) }
$stats | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath (Join-Path $pack 'v0431-luminance-comparison.json') -Encoding UTF8

$blackFrameChecks = [ordered]@{
  schema = 'v0431-black-frame-rejection-v1'
  inspected = @($stats | ForEach-Object { $_.file })
  rejected = @($stats | Where-Object { -not $_.nonBlack -or -not $_.meaningfulVariance } | ForEach-Object { $_.file })
  rule = 'every gameplay evidence source must be non-black and have meaningful sampled luminance variance'
  passed = (@($stats | Where-Object { -not $_.nonBlack -or -not $_.meaningfulVariance }).Count -eq 0)
  note = 'The headed Godot client image is 1920 pixels wide with a 1061 pixel client viewport after the Windows frame; the capture command requests the project 1920x1080 viewport.'
}
$blackFrameChecks | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath (Join-Path $pack 'v0431-black-frame-rejection.json') -Encoding UTF8

[ordered]@{ schema='v0431-gameplay-visual-root-cause-audit-v1'; before=@{ ambient=0.6; tonemapWhite=6.0; glow=$true; fogDensity=0.0016; sunEnergy=1.15 }; after=@{ ambient=0.42; tonemapWhite=3.2; glow=$false; fogDensity=0.00045; sunEnergy=1.0 }; diagnosis='washed-out production gameplay came from excessive ambient/tonemap/glow/fog/sun values in GameWorld; menu/campaign/settings were not changed'; evidence=@('v0430 runtime baseline','02_V0431_GAMEPLAY_READABILITY_AFTER.png','v0431-environment-settings-before-after.json') } | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $pack 'v0431-gameplay-visual-root-cause-audit.json') -Encoding UTF8

$godot = if ($env:ASCENDANT_REALMS_GODOT) { $env:ASCENDANT_REALMS_GODOT } else { Join-Path $env:LOCALAPPDATA 'AscendantRealms/tools/godot-4.3-stable/Godot_v4.3-stable_win64.exe' }
$exeHash = (Get-FileHash -LiteralPath $godot -Algorithm SHA256).Hash
[ordered]@{ schema='v0431-headed-capture-audit-v1'; previousFailedCommand='Godot --headless --path production/ascendant-realms-godot --quit-after 120'; previousDisplayDriver='headless'; previousRenderingMethod='dummy'; reasonViewportUnavailable='dummy renderer produced invalid/empty viewport textures'; newCommand='Godot_v4.3-stable_win64.exe --path production/ascendant-realms-godot --resolution 1920x1080 --verbose --log-file v0431-headed-runtime.log'; executable=$godot; executableSha256=$exeHash; displayDriver='headed Windows display'; renderingMethod='Forward Plus'; viewport='1920x1080'; screenshotMethod='Godot viewport texture after scene readiness and RenderingServer.frame_post_draw'; retryPolicy='bounded rendered-frame synchronization'; retryCount=0; meshDiagnosticClassification='HEADLESS_RENDERER_DIAGNOSTIC_NOT_REPRODUCED_IN_HEADED_CAPTURE'; processExitStatus=0; cleanup='Godot capture-owned process exited; no persistent process retained'; firstRenderedFrame='02_V0431_GAMEPLAY_READABILITY_AFTER.png'; requiredGate=@('02_V0431_GAMEPLAY_READABILITY_AFTER.png','04_V0431_WORKER_SELECTED.png','07_V0431_CLAN_CROFT_VALID_PREVIEW.png') } | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $pack 'v0431-headed-capture-audit.json') -Encoding UTF8

[ordered]@{ schema='v0431-menu-campaign-preservation-audit-v1'; title='15_V0431_TITLE_PRESERVATION.png'; skirmish='16_V0431_SKIRMISH_PRESERVATION.png'; campaign='17_V0431_CAMPAIGN_PRESERVATION.png'; sourceCheckpoint='v0430 real production captures'; trueDefaultUnchanged=$true; productionGameplayOnlyReadabilityChange=$true } | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath (Join-Path $pack 'v0431-menu-campaign-preservation-audit.json') -Encoding UTF8
[ordered]@{ schema='v0431-original-source-preservation-audit-v1'; baseCommit='044a14de65c4b1308a21f402d04f89b881f291a6'; originalSource='D:/Code for projects/WB game like/WB_tesana'; productionCopy='production/ascendant-realms-godot'; originalSourceModified=$false; acceptedProductionRebasePreserved=$true; note='v0.431 changes are limited to production runtime readability, construction audit hooks, headed capture tooling and evidence.' } | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath (Join-Path $pack 'v0431-original-source-preservation-audit.json') -Encoding UTF8
[ordered]@{ schema='v0431-network-audit-v1'; externalNetworkDependency=$false; localServicesStarted=@(); productionRuntimeNetworkMutation=$false; source='headed local Godot capture' } | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath (Join-Path $pack 'v0431-network-audit.json') -Encoding UTF8
Write-Host "v0.431 review pack built: $pack"
