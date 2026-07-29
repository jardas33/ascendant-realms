param([string]$Repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path)
$root = Join-Path $Repo 'desktop-spikes\godot-salto\artifacts\runtime\v0414'
$pack = Join-Path $Repo 'artifacts\manual-review\v0414-main-house-openings-trim-value-hierarchy'
& (Join-Path $PSScriptRoot 'runGodotV0414MainHouseOpeningsTrimValueHierarchySmokeWindows.ps1') -Repo $Repo
$godot = if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $Repo '.tools\godot\Godot_v4.6.3-stable_win64.exe' }
if (-not (Test-Path -LiteralPath $godot)) { throw "Missing Godot executable: $godot" }
$process = Start-Process -FilePath $godot -ArgumentList @('--path','desktop-spikes/godot-salto','--v0414-main-house-openings-trim-capture','--artifact-root=artifacts/runtime/v0414') -WorkingDirectory $Repo -PassThru -Wait
if ($process.ExitCode -ne 0) { throw "Godot v0.414 capture exited $($process.ExitCode)" }
New-Item -ItemType Directory -Force -Path $pack | Out-Null
foreach ($file in @('01_PRIMARY_RTS_COLOUR.png','02_MAIN_HOUSE_OPENINGS_TRIM_CLOSE_COLOUR.png','03_PRIMARY_RTS_GRAYSCALE.png','04_MAIN_HOUSE_OPENINGS_TRIM_CLOSE_GRAYSCALE.png','05_TEMPORARY_OPENING_TRIM_NODE_ID.png','06_V0413_V0414_WIDE_COMPARISON.png','07_V0413_V0414_HOUSE_CLOSE_COMPARISON.png','v0414-preservation-audit.json')) {
  $source = Join-Path $root $file
  if (-not (Test-Path -LiteralPath $source)) { throw "Missing v0.414 capture: $file" }
  Copy-Item -LiteralPath $source -Destination (Join-Path $pack $file) -Force
}
Write-Output 'PASS_V0414_RENDERED_MAIN_HOUSE_OPENINGS_TRIM_VALUE_HIERARCHY'
