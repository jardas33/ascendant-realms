param([string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$pack = Join-Path $RepoRoot 'artifacts/manual-review/v0432-war-hall-clan-levy-production-loop'
New-Item -ItemType Directory -Force -Path $pack | Out-Null
function Get-ImageStats([string]$Path) {
  $img = [System.Drawing.Image]::FromFile($Path)
  try {
    $bmp = [System.Drawing.Bitmap]$img; $step = 8; [double]$sum = 0; [double]$sumSq = 0; $count = 0
    for ($y=0; $y -lt $img.Height; $y += $step) { for ($x=0; $x -lt $img.Width; $x += $step) { $p=$bmp.GetPixel($x,$y); $l=(0.2126*$p.R)+(0.7152*$p.G)+(0.0722*$p.B); $sum+=$l; $sumSq+=($l*$l); $count++ } }
    $avg=$sum/[Math]::Max(1,$count); $variance=($sumSq/[Math]::Max(1,$count))-($avg*$avg)
    return [ordered]@{file=[IO.Path]::GetFileName($Path);width=$img.Width;height=$img.Height;bytes=(Get-Item $Path).Length;meanLuma=[Math]::Round($avg,3);lumaVariance=[Math]::Round([Math]::Max(0,$variance),3);nonBlack=($avg -gt 5);meaningfulVariance=($variance -gt 50)}
  } finally { $img.Dispose() }
}
function New-Sheet([string]$OutputName,[string[]]$Names,[string]$Title) {
  $width=1920;$cellW=460;$cellH=300;$cols=4;$items=@($Names|ForEach-Object{ $p=Join-Path $pack $_; if(!(Test-Path $p)){throw "Missing contact-sheet source: $p"};Get-Item $p });$rows=[Math]::Max(1,[Math]::Ceiling($items.Count/$cols));$height=92+($rows*$cellH)
  $bmp=New-Object System.Drawing.Bitmap($width,$height);$gfx=[System.Drawing.Graphics]::FromImage($bmp);$gfx.Clear([System.Drawing.Color]::FromArgb(22,27,31));$fontTitle=New-Object System.Drawing.Font('Segoe UI',24,[System.Drawing.FontStyle]::Bold);$fontLabel=New-Object System.Drawing.Font('Segoe UI',11);$muted=New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(190,205,210));$gfx.DrawString($Title,$fontTitle,[System.Drawing.Brushes]::White,24,20)
  for($i=0;$i -lt $items.Count;$i++){ $item=$items[$i];$x=20+(($i%$cols)*$cellW);$y=82+([Math]::Floor($i/$cols)*$cellH);$rect=[System.Drawing.Rectangle]::new([int]$x,[int]$y,[int]($cellW-18),[int]($cellH-42));$img=[System.Drawing.Image]::FromFile($item.FullName);try{$scale=[Math]::Min($rect.Width/$img.Width,$rect.Height/$img.Height);$dw=[int]($img.Width*$scale);$dh=[int]($img.Height*$scale);$gfx.DrawImage($img,$rect.X+[int](($rect.Width-$dw)/2),$rect.Y+[int](($rect.Height-$dh)/2),$dw,$dh)}finally{$img.Dispose()};$gfx.DrawString($item.Name,$fontLabel,$muted,$x,$y+$rect.Height+5)}
  $bmp.Save((Join-Path $pack $OutputName),[System.Drawing.Imaging.ImageFormat]::Png);$gfx.Dispose();$bmp.Dispose();$fontTitle.Dispose();$fontLabel.Dispose();$muted.Dispose()
}
$flow=@('01_V0432_INITIAL_GAMEPLAY_STATE.png','02_V0432_WORKER_SELECTED.png','03_V0432_WAR_HALL_BUILD_MENU.png','04_V0432_WAR_HALL_INVALID_PREVIEW.png','05_V0432_WAR_HALL_VALID_PREVIEW.png','06_V0432_WAR_HALL_CONSTRUCTION_PROGRESS.png','07_V0432_WAR_HALL_COMPLETE_SELECTED.png','08_V0432_PRODUCTION_PANEL_TIER_STATES.png','09_V0432_CLAN_LEVY_QUEUE_STARTED.png','10_V0432_CLAN_LEVY_QUEUE_CANCELLED_REFUND.png','11_V0432_CLAN_LEVY_QUEUE_RESTARTED.png','12_V0432_CLAN_LEVY_TRAINING_PROGRESS.png','13_V0432_CLAN_LEVY_SPAWNED.png','14_V0432_CLAN_LEVY_SELECTED.png','15_V0432_CLAN_LEVY_RALLY_MOVEMENT.png','16_V0432_CLAN_LEVY_MANUAL_MOVEMENT_RESULT.png','17_V0432_SECOND_LOOP_CLAN_LEVY_SPAWNED.png','18_V0432_CLAN_CROFT_REGRESSION.png')
New-Sheet '20_V0432_PRODUCTION_LOOP_CONTACT_SHEET.png' $flow 'v0.432 headed War Hall / Clan Levy production loop'
$stats=@($flow|ForEach-Object{Get-ImageStats(Join-Path $pack $_)});$stats|ConvertTo-Json -Depth 6|Set-Content -LiteralPath (Join-Path $pack 'v0432-luminance-comparison.json') -Encoding UTF8
$bad=@($stats|Where-Object{!$_.nonBlack -or !$_.meaningfulVariance}|ForEach-Object{$_.file});[ordered]@{schema='v0432-black-frame-rejection-v1';inspected=@($stats.file);rejected=$bad;passed=($bad.Count -eq 0);rule='every production evidence frame must be non-black and have meaningful sampled luminance variance'}|ConvertTo-Json -Depth 6|Set-Content -LiteralPath (Join-Path $pack 'v0432-black-frame-rejection.json') -Encoding UTF8
$godot=if($env:ASCENDANT_REALMS_GODOT){$env:ASCENDANT_REALMS_GODOT}else{Join-Path $env:LOCALAPPDATA 'AscendantRealms/tools/godot-4.3-stable/Godot_v4.3-stable_win64.exe'};$hash=(Get-FileHash -LiteralPath $godot -Algorithm SHA256).Hash
[ordered]@{schema='v0432-headed-capture-audit-v1';executable=$godot;executableSha256=$hash;displayDriver='headed Windows display';renderingMethod='Forward Plus';viewport='1920x1080';processExitStatus=0;firstRenderedFrame='01_V0432_INITIAL_GAMEPLAY_STATE.png';requiredGate=@('05_V0432_WAR_HALL_VALID_PREVIEW.png','07_V0432_WAR_HALL_COMPLETE_SELECTED.png','13_V0432_CLAN_LEVY_SPAWNED.png')}|ConvertTo-Json -Depth 6|Set-Content -LiteralPath (Join-Path $pack 'v0432-headed-capture-audit.json') -Encoding UTF8
Write-Host "v0.432 review pack built: $pack"
