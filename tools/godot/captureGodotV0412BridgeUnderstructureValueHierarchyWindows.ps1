param([string]$Repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path)
$root = Join-Path $Repo 'desktop-spikes\godot-salto\artifacts\runtime\v0412'
$pack = Join-Path $Repo 'artifacts\manual-review\v0412-bridge-understructure-value-hierarchy'
& (Join-Path $PSScriptRoot 'runGodotV0412BridgeUnderstructureValueHierarchySmokeWindows.ps1') -Repo $Repo
$godot = if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $Repo '.tools\godot\Godot_v4.6.3-stable_win64.exe' }
if (-not (Test-Path -LiteralPath $godot)) { throw "Missing Godot executable: $godot" }
Set-Location $Repo
$process = Start-Process -FilePath $godot -ArgumentList @('--path','desktop-spikes/godot-salto','--v0412-bridge-understructure-capture','--artifact-root=artifacts/runtime/v0412') -WorkingDirectory $Repo -PassThru -Wait
if ($process.ExitCode -ne 0) { exit $process.ExitCode }
New-Item -ItemType Directory -Force -Path $pack | Out-Null
foreach ($file in @('01_PRIMARY_RTS_COLOUR.png','02_BRIDGE_UNDERSTRUCTURE_CLOSE_COLOUR.png','03_PRIMARY_RTS_GRAYSCALE.png','04_BRIDGE_UNDERSTRUCTURE_CLOSE_GRAYSCALE.png','05_TEMPORARY_UNDERBEAM_EDGECOURSE_ID.png','06_V0411_V0412_WIDE_COMPARISON.png','07_V0411_V0412_CLOSE_COMPARISON.png','v0412-preservation-audit.json')) { Copy-Item -LiteralPath (Join-Path $root $file) -Destination (Join-Path $pack $file) -Force }
Write-Output 'PASS_V0412_RENDERED_BRIDGE_UNDERSTRUCTURE_VALUE_HIERARCHY'
