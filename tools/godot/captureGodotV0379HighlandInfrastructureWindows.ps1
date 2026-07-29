$ErrorActionPreference = 'Stop'
$repo = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$godot = if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $repo '.tools\godot\Godot_v4.6.3-stable_win64.exe' }
if (-not (Test-Path -LiteralPath $godot)) { throw "Missing Godot executable: $godot" }
Set-Location $repo
$iteration = if ($env:V0379_ITERATION) { $env:V0379_ITERATION } else { '1' }
$target = if ($env:V0379_OUTPUT_ROOT) { Join-Path $repo $env:V0379_OUTPUT_ROOT } else { Join-Path $repo ("artifacts\work\v0379-iteration-0{0}" -f $iteration) }
$source = Join-Path $repo 'desktop-spikes\godot-salto\artifacts\runtime\v0379'
New-Item -ItemType Directory -Force -Path $target | Out-Null
$importArguments = @('--editor', '--headless', '--path', 'desktop-spikes/godot-salto', '--quit')
$importProcess = Start-Process -FilePath $godot -ArgumentList $importArguments -Wait -PassThru -NoNewWindow
if ($importProcess.ExitCode -ne 0) { throw "Godot v0.379 asset import failed with exit code $($importProcess.ExitCode)" }
$arguments = @('--path', 'desktop-spikes/godot-salto', '--v0379-highland-infrastructure-capture', '--artifact-root=artifacts/runtime/v0379', "--v0379-iteration=$iteration")
$process = Start-Process -FilePath $godot -ArgumentList $arguments -Wait -PassThru -NoNewWindow
if ($process.ExitCode -ne 0) { exit $process.ExitCode }
foreach ($name in @('01_PRIMARY_RTS_VIEW.png','02_ROAD_AND_TERRAIN_DETAIL.png','03_RIVERBANK_DEPTH_DETAIL.png','04_BRIDGE_AND_LANDINGS.png','05_ELEVATED_SPACING_AUDIT.png','06_GRAYSCALE_PRIMARY.png','v0379-authored-highland-infrastructure.json')) {
  $file = Join-Path $source $name
  if (-not (Test-Path -LiteralPath $file)) { throw "Missing raw v0.379 capture: $name" }
  Copy-Item -LiteralPath $file -Destination (Join-Path $target $name) -Force
}
Write-Output "PASS_V0379_RENDERED_ITERATION_$iteration"
