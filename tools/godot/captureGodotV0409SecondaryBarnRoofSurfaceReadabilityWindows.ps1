param([string]$Repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path)
$root = Join-Path $Repo 'desktop-spikes\godot-salto\artifacts\runtime\v0409'
$pack = Join-Path $Repo 'artifacts\manual-review\v0409-secondary-barn-roof-surface-readability'
& (Join-Path $PSScriptRoot 'runGodotV0409SecondaryBarnRoofSurfaceReadabilitySmokeWindows.ps1') -Repo $Repo
$godot = if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $Repo '.tools\godot\Godot_v4.6.3-stable_win64.exe' }
if (-not (Test-Path -LiteralPath $godot)) { throw "Missing Godot executable: $godot" }
Set-Location $Repo
$process = Start-Process -FilePath $godot -ArgumentList @('--path','desktop-spikes/godot-salto','--v0409-secondary-barn-roof-capture','--artifact-root=artifacts/runtime/v0409') -WorkingDirectory $Repo -PassThru -Wait
if ($process.ExitCode -ne 0) { exit $process.ExitCode }
New-Item -ItemType Directory -Force -Path $pack | Out-Null
foreach ($file in @('01_PRIMARY_RTS_COLOUR.png','02_SECONDARY_BARN_ROOF_CLOSE_COLOUR.png','03_PRIMARY_RTS_GRAYSCALE.png','04_SECONDARY_BARN_ROOF_GRAYSCALE.png','05_SECONDARY_BARN_ROOF_MATERIAL_DIAGNOSTIC.png','06_V0408_V0409_WIDE_COMPARISON.png','07_V0408_V0409_BARN_ROOF_CLOSE_COMPARISON.png','v0409-preservation-audit.json')) { Copy-Item -LiteralPath (Join-Path $root $file) -Destination (Join-Path $pack $file) -Force }
Write-Output 'PASS_V0409_RENDERED_SECONDARY_BARN_ROOF_SURFACE_READABILITY'
