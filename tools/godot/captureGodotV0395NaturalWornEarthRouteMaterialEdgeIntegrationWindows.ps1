$ErrorActionPreference = 'Stop'
$repo = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$godot = if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $repo '.tools\godot\Godot_v4.6.3-stable_win64.exe' }
if (-not (Test-Path -LiteralPath $godot)) { throw "Missing Godot executable: $godot" }
Set-Location $repo
$iteration = if ($env:V0395_ITERATION) { $env:V0395_ITERATION } else { '1' }
$outputRoot = if ($env:V0395_OUTPUT_ROOT) { $env:V0395_OUTPUT_ROOT } else { 'artifacts/runtime/v0395' }
$import = Start-Process -FilePath $godot -ArgumentList @('--editor','--headless','--path','desktop-spikes/godot-salto','--quit') -Wait -PassThru -NoNewWindow
if ($import.ExitCode -ne 0) { throw "Godot v0.395 import failed with exit code $($import.ExitCode)" }
$process = Start-Process -FilePath $godot -ArgumentList @('--path','desktop-spikes/godot-salto','--v0395-route-material-capture',"--artifact-root=$outputRoot", "--v0395-iteration=$iteration") -Wait -PassThru -NoNewWindow
if ($process.ExitCode -ne 0) { exit $process.ExitCode }
foreach ($name in @('01_PRIMARY_RTS_VIEW.png','02_SETTLEMENT_AND_CROSSING_CONTEXT.png','03_CLOSE_ROUTE_YARD_DOORWAY.png','04_BARN_BRANCH_CONNECTION.png','05_GRAYSCALE_PRIMARY.png','06_GRAYSCALE_CLOSE_ROUTE.png','07_V0394_V0395_PRIMARY_COMPARISON.png','v0395-natural-worn-earth-route-material-edge-integration.json')) {
  $file = Join-Path (Join-Path $repo 'desktop-spikes\godot-salto') (Join-Path $outputRoot $name)
  if (-not (Test-Path -LiteralPath $file)) { throw "Missing raw v0.395 capture: $name" }
}
Write-Output 'PASS_V0395_RENDERED_NATURAL_WORN_EARTH_ROUTE_MATERIAL_EDGE_INTEGRATION'
