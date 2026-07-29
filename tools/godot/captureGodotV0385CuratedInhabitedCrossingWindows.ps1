$ErrorActionPreference = 'Stop'
$repo = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$godot = if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $repo '.tools\godot\Godot_v4.6.3-stable_win64.exe' }
if (-not (Test-Path -LiteralPath $godot)) { throw "Missing Godot executable: $godot" }
Set-Location $repo
$iteration = if ($env:V0385_ITERATION) { $env:V0385_ITERATION } else { '3' }
$outputRoot = if ($env:V0385_OUTPUT_ROOT) { $env:V0385_OUTPUT_ROOT } else { 'artifacts/runtime/v0385' }
$import = Start-Process -FilePath $godot -ArgumentList @('--editor','--headless','--path','desktop-spikes/godot-salto','--quit') -Wait -PassThru -NoNewWindow
if ($import.ExitCode -ne 0) { throw "Godot v0.385 import failed with exit code $($import.ExitCode)" }
$process = Start-Process -FilePath $godot -ArgumentList @('--path','desktop-spikes/godot-salto','--v0385-inhabited-crossing-capture',"--artifact-root=$outputRoot", "--v0385-iteration=$iteration") -Wait -PassThru -NoNewWindow
if ($process.ExitCode -ne 0) { exit $process.ExitCode }
foreach ($name in @('01_PRIMARY_RTS_VIEW.png','02_SETTLEMENT_AND_CROSSING_CONTEXT.png','03_YARD_AND_CHARACTER_ROLE_DETAIL.png','04_BUILDING_SILHOUETTE_AND_ENTRANCE_DETAIL.png','05_CHARACTER_SCALE_AND_SEPARATION_AUDIT.png','06_ROAD_YARD_ENTRANCE_CONNECTION.png','07_GRAYSCALE_PRIMARY.png','v0385-curated-inhabited-crossing.json')) {
  $file = Join-Path (Join-Path $repo 'desktop-spikes\godot-salto') (Join-Path $outputRoot $name)
  if (-not (Test-Path -LiteralPath $file)) { throw "Missing raw v0.385 capture: $name" }
}
Write-Output 'PASS_V0385_RENDERED_CURATED_INHABITED_CROSSING'
