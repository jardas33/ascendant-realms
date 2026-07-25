$ErrorActionPreference = 'Stop'
$repo = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$godot = if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $repo '.tools\godot\Godot_v4.6.3-stable_win64.exe' }
if (-not (Test-Path -LiteralPath $godot)) { throw "Missing Godot executable: $godot" }
Set-Location $repo
$iteration = if ($env:V0383_ITERATION) { $env:V0383_ITERATION } else { '3' }
$outputRoot = if ($env:V0383_OUTPUT_ROOT) { $env:V0383_OUTPUT_ROOT } else { 'artifacts/runtime/v0383' }
$importArguments = @('--editor', '--headless', '--path', 'desktop-spikes/godot-salto', '--quit')
$importProcess = Start-Process -FilePath $godot -ArgumentList $importArguments -Wait -PassThru -NoNewWindow
if ($importProcess.ExitCode -ne 0) { throw "Godot v0.383 asset import failed with exit code $($importProcess.ExitCode)" }
Start-Sleep -Milliseconds 1000
$arguments = @('--path', 'desktop-spikes/godot-salto', '--v0383-style-coherence-capture', "--artifact-root=$outputRoot", "--v0383-iteration=$iteration")
$process = Start-Process -FilePath $godot -ArgumentList $arguments -Wait -PassThru -NoNewWindow
if ($process.ExitCode -ne 0) { exit $process.ExitCode }
foreach ($name in @('01_PRIMARY_RTS_VIEW.png','02_BRIDGE_CLEARANCE_AUDIT.png','03_RIVERBANK_VARIATION_DETAIL.png','04_VEGETATION_MASS_SPACING.png','05_DRESSING_DISTRIBUTION_AUDIT.png','06_GRAYSCALE_PRIMARY.png','v0383-highland-style-coherence.json')) {
  $file = Join-Path (Join-Path $repo 'desktop-spikes\godot-salto') (Join-Path $outputRoot $name)
  if (-not (Test-Path -LiteralPath $file)) { throw "Missing raw v0.383 capture: $name" }
}
Write-Output 'PASS_V0383_RENDERED_STYLE_COHERENCE'
