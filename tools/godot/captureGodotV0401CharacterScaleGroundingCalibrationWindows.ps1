$ErrorActionPreference = 'Stop'
$repo = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$godot = if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $repo '.tools\godot\Godot_v4.6.3-stable_win64.exe' }
if (-not (Test-Path -LiteralPath $godot)) { throw "Missing Godot executable: $godot" }
Set-Location $repo
$process = Start-Process -FilePath $godot -ArgumentList @('--path','desktop-spikes/godot-salto','--v0401-character-grounding-capture','--artifact-root=artifacts/runtime/v0401') -WorkingDirectory $repo -PassThru -Wait
if ($process.ExitCode -ne 0) { exit $process.ExitCode }
$root = Join-Path $repo 'desktop-spikes\godot-salto\artifacts\runtime\v0401'
$pack = Join-Path $repo 'artifacts\manual-review\v0401-character-scale-grounding-calibration'
New-Item -ItemType Directory -Force -Path $pack | Out-Null
foreach ($file in @('01_PRIMARY_RTS_VIEW.png','02_CHARACTER_SCALE_GROUNDING_CLOSE.png','03_GRAYSCALE_PRIMARY.png','04_CHARACTER_GROUNDING_GRAYSCALE.png','05_V0400_V0401_PRIMARY_COMPARISON.png','v0401-character-scale-grounding-calibration.json')) { Copy-Item -LiteralPath (Join-Path $root $file) -Destination (Join-Path $pack $file) -Force }
Copy-Item -LiteralPath (Join-Path $repo 'docs\V0401_CHARACTER_SCALE_GROUNDING_CALIBRATION_REPORT.md') -Destination (Join-Path $pack '06_ITERATION_SUMMARY.md') -Force
Write-Output 'PASS_V0401_RENDERED_CHARACTER_SCALE_GROUNDING_CALIBRATION'
exit 0
