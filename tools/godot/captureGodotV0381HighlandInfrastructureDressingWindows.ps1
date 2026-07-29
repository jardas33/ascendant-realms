$ErrorActionPreference = 'Stop'
$repo = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$godot = if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $repo '.tools\godot\Godot_v4.6.3-stable_win64.exe' }
if (-not (Test-Path -LiteralPath $godot)) { throw "Missing Godot executable: $godot" }
Set-Location $repo
$source = Join-Path $repo 'desktop-spikes\godot-salto\artifacts\runtime\v0381'
New-Item -ItemType Directory -Force -Path $source | Out-Null
$importArguments = @('--editor', '--headless', '--path', 'desktop-spikes/godot-salto', '--quit')
$importProcess = Start-Process -FilePath $godot -ArgumentList $importArguments -Wait -PassThru -NoNewWindow
if ($importProcess.ExitCode -ne 0) { throw "Godot v0.381 asset import failed with exit code $($importProcess.ExitCode)" }
Start-Sleep -Milliseconds 1000
$arguments = @('--path', 'desktop-spikes/godot-salto', '--v0381-highland-dressing-capture', '--artifact-root=artifacts/runtime/v0381')
$process = Start-Process -FilePath $godot -ArgumentList $arguments -Wait -PassThru -NoNewWindow
if ($process.ExitCode -ne 0) { exit $process.ExitCode }
foreach ($name in @('01_PRIMARY_RTS_VIEW.png','02_CROSSING_CONTEXT_VIEW.png','03_RIVERBANK_AND_REEDS_DETAIL.png','04_BRIDGE_AND_LANDINGS_DETAIL.png','05_DRESSING_DISTRIBUTION_AUDIT.png','06_GRAYSCALE_PRIMARY.png','v0381-highland-infrastructure-dressing.json')) {
  $file = Join-Path $source $name
  if (-not (Test-Path -LiteralPath $file)) { throw "Missing raw v0.381 capture: $name" }
}
Write-Output 'PASS_V0381_RENDERED_ENVIRONMENT_DRESSING'
