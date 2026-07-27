$ErrorActionPreference = 'Stop'
$repo = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$godot = if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $repo '.tools\godot\Godot_v4.6.3-stable_win64.exe' }
if (-not (Test-Path -LiteralPath $godot)) { throw "Missing Godot executable: $godot" }
Set-Location $repo
$process = Start-Process -FilePath $godot -ArgumentList @('--path','desktop-spikes/godot-salto','--v0406-western-footing-capture','--artifact-root=artifacts/runtime/v0406') -WorkingDirectory $repo -PassThru -Wait
if ($process.ExitCode -ne 0) { exit $process.ExitCode }
$root = Join-Path $repo 'desktop-spikes\godot-salto\artifacts\runtime\v0406'
$pack = Join-Path $repo 'artifacts\manual-review\v0406-exact-western-footing-ring-extension'
New-Item -ItemType Directory -Force -Path $pack | Out-Null
foreach ($file in @('01_PRIMARY_RTS_COLOUR.png','02_WESTERN_LANDING_CLOSE_COLOUR.png','03_PRIMARY_RTS_GRAYSCALE.png','04_WESTERN_LANDING_CLOSE_GRAYSCALE.png','05_MOVED_RING_DIAGNOSTIC.png','06_V0401_V0406_WIDE_COMPARISON.png','07_V0401_V0406_CLOSE_COMPARISON.png','v0406-preservation-audit.json')) { Copy-Item -LiteralPath (Join-Path $root $file) -Destination (Join-Path $pack $file) -Force }
Write-Output 'PASS_V0406_RENDERED_EXACT_WESTERN_FOOTING_RING_EXTENSION'
