$ErrorActionPreference = 'Stop'
$repo = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$godot = if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $repo '.tools\godot\Godot_v4.6.3-stable_win64.exe' }
if (-not (Test-Path -LiteralPath $godot)) { throw "Missing Godot executable: $godot" }
Set-Location $repo
$iteration = if ($env:V0382_ITERATION) { $env:V0382_ITERATION } else { '3' }
$outputRoot = if ($env:V0382_OUTPUT_ROOT) { $env:V0382_OUTPUT_ROOT } else { 'artifacts/runtime/v0382' }
$importArguments = @('--editor', '--headless', '--path', 'desktop-spikes/godot-salto', '--quit')
$importProcess = Start-Process -FilePath $godot -ArgumentList $importArguments -Wait -PassThru -NoNewWindow
if ($importProcess.ExitCode -ne 0) { throw "Godot v0.382 asset import failed with exit code $($importProcess.ExitCode)" }
Start-Sleep -Milliseconds 1000
$arguments = @('--path', 'desktop-spikes/godot-salto', '--v0382-clustered-dressing-capture', "--artifact-root=$outputRoot", "--v0382-iteration=$iteration")
$process = Start-Process -FilePath $godot -ArgumentList $arguments -Wait -PassThru -NoNewWindow
if ($process.ExitCode -ne 0) { exit $process.ExitCode }
foreach ($name in @('01_PRIMARY_RTS_VIEW.png','02_CLUSTERED_CROSSING_CONTEXT.png','03_RIVERBANK_VEGETATION_DETAIL.png','04_BRIDGE_APPROACH_DRESSING.png','05_DRESSING_DISTRIBUTION_AUDIT.png','06_GRAYSCALE_PRIMARY.png','v0382-clustered-highland-dressing.json')) {
  $file = Join-Path (Join-Path $repo 'desktop-spikes\godot-salto') (Join-Path $outputRoot $name)
  if (-not (Test-Path -LiteralPath $file)) { throw "Missing raw v0.382 capture: $name" }
}
Write-Output 'PASS_V0382_RENDERED_CLUSTERED_DRESSING'
