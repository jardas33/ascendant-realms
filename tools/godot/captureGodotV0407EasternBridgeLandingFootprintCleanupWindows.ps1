param([string]$Repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path)
$root = Join-Path $Repo 'desktop-spikes\godot-salto\artifacts\runtime\v0407'
$pack = Join-Path $Repo 'artifacts\manual-review\v0407-eastern-bridge-landing-footprint-cleanup'
& (Join-Path $PSScriptRoot 'runGodotV0407EasternBridgeLandingFootprintCleanupSmokeWindows.ps1') -Repo $Repo
$godot = if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $Repo '.tools\godot\Godot_v4.6.3-stable_win64.exe' }
if (-not (Test-Path -LiteralPath $godot)) { throw "Missing Godot executable: $godot" }
Set-Location $Repo
$process = Start-Process -FilePath $godot -ArgumentList @('--path','desktop-spikes/godot-salto','--v0407-eastern-landing-capture','--artifact-root=artifacts/runtime/v0407') -WorkingDirectory $Repo -PassThru -Wait
if ($process.ExitCode -ne 0) { exit $process.ExitCode }
New-Item -ItemType Directory -Force -Path $pack | Out-Null
foreach ($file in @('01_PRIMARY_RTS_COLOUR.png','02_EASTERN_LANDING_CLOSE_COLOUR.png','03_PRIMARY_RTS_GRAYSCALE.png','04_EASTERN_LANDING_CLOSE_GRAYSCALE.png','05_EASTERN_COMPONENT_DIAGNOSTIC.png','06_V0406_V0407_WIDE_COMPARISON.png','07_V0406_V0407_CLOSE_COMPARISON.png','v0407-preservation-audit.json')) { Copy-Item -LiteralPath (Join-Path $root $file) -Destination (Join-Path $pack $file) -Force }
Write-Output 'PASS_V0407_RENDERED_EASTERN_BRIDGE_LANDING_FOOTPRINT_CLEANUP'
