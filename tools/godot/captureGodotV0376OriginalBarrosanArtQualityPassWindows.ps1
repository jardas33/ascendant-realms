$ErrorActionPreference = 'Stop'
$repo = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$godot = if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $repo '.tools\godot\Godot_v4.6.3-stable_win64.exe' }
if (-not (Test-Path -LiteralPath $godot)) { throw "Missing Godot executable: $godot" }
Set-Location $repo
$iteration = if ($env:V0376_ITERATION) { $env:V0376_ITERATION } else { '1' }
$target = if ($env:V0376_OUTPUT_ROOT) { Join-Path $repo $env:V0376_OUTPUT_ROOT } else { Join-Path $repo "artifacts\work\v0376-iteration-0$iteration" }
$source = Join-Path $repo 'desktop-spikes\godot-salto\artifacts\runtime\v0376'
New-Item -ItemType Directory -Force -Path $target | Out-Null
$arguments = @('--path', 'desktop-spikes/godot-salto', '--v0376-original-barrosan-capture', '--artifact-root=artifacts/runtime/v0376', "--v0376-iteration=$iteration")
$process = Start-Process -FilePath $godot -ArgumentList $arguments -Wait -PassThru -NoNewWindow
if ($process.ExitCode -ne 0) { exit $process.ExitCode }
foreach ($name in @('01_ART_QUALITY_PRIMARY_OVERVIEW.png','02_ART_QUALITY_SETTLEMENT_AND_MINE.png','03_ART_QUALITY_BRIDGE_AND_CAMP.png','04_ART_QUALITY_ELEVATED_SPACING_AUDIT.png','v0376-original-barrosan-art-quality.json')) {
  $file = Join-Path $source $name
  if (-not (Test-Path -LiteralPath $file)) { throw "Missing raw v0.375 capture: $name" }
  Copy-Item -LiteralPath $file -Destination (Join-Path $target $name) -Force
}
Write-Output "PASS_V0376_RENDERED_ITERATION_$iteration"
