$ErrorActionPreference = 'Stop'
$repo = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$godot = if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $repo '.tools\godot\Godot_v4.6.3-stable_win64.exe' }
if (-not (Test-Path -LiteralPath $godot)) { throw "Missing Godot executable: $godot" }
Set-Location $repo
$iteration = if ($env:V0391_ITERATION) { $env:V0391_ITERATION } else { '3' }
$outputRoot = if ($env:V0391_OUTPUT_ROOT) { $env:V0391_OUTPUT_ROOT } else { 'artifacts/runtime/v0391' }
$import = Start-Process -FilePath $godot -ArgumentList @('--editor','--headless','--path','desktop-spikes/godot-salto','--quit') -Wait -PassThru -NoNewWindow
if ($import.ExitCode -ne 0) { throw "Godot v0.390 import failed with exit code $($import.ExitCode)" }
$process = Start-Process -FilePath $godot -ArgumentList @('--path','desktop-spikes/godot-salto','--v0391-ground-plane-capture',"--artifact-root=$outputRoot", "--v0391-iteration=$iteration") -Wait -PassThru -NoNewWindow
if ($process.ExitCode -ne 0) { exit $process.ExitCode }
foreach ($name in @('01_PRIMARY_RTS_VIEW.png','02_SETTLEMENT_AND_CROSSING_CONTEXT.png','03_ROAD_YARD_ENTRANCE_CONNECTION.png','04_FIVE_FUNCTIONAL_YARD_GROUPS.png','05_THREE_CHARACTER_ROLE_AUDIT.png','06_BUILDING_SEPARATION_AND_ENTRANCES.png','07_GRAYSCALE_PRIMARY.png','v0391-ground-plane-legibility-building-separation-repair.json')) {
  $file = Join-Path (Join-Path $repo 'desktop-spikes\godot-salto') (Join-Path $outputRoot $name)
  if (-not (Test-Path -LiteralPath $file)) { throw "Missing raw v0.389 capture: $name" }
}
Write-Output 'PASS_V0391_RENDERED_GROUND_PLANE_LEGIBILITY_BUILDING_SEPARATION_REPAIR'
