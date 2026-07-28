param([string]$Repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path)
$root = Join-Path $Repo 'desktop-spikes\godot-salto\artifacts\runtime\v0413'
$pack = Join-Path $Repo 'artifacts\manual-review\v0413-main-house-masonry-value-hierarchy'
& (Join-Path $PSScriptRoot 'runGodotV0413MainHouseMasonryValueHierarchySmokeWindows.ps1') -Repo $Repo
$godot = if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $Repo '.tools\godot\Godot_v4.6.3-stable_win64.exe' }
if (-not (Test-Path -LiteralPath $godot)) { throw "Missing Godot executable: $godot" }
$process = Start-Process -FilePath $godot -ArgumentList @('--path','desktop-spikes/godot-salto','--v0413-main-house-masonry-capture','--artifact-root=artifacts/runtime/v0413') -WorkingDirectory $Repo -PassThru -Wait
if ($process.ExitCode -ne 0) { throw "Godot v0.413 capture exited $($process.ExitCode)" }
New-Item -ItemType Directory -Force -Path $pack | Out-Null
foreach ($file in @('01_PRIMARY_RTS_COLOUR.png','02_MAIN_HOUSE_MASONRY_CLOSE_COLOUR.png','03_PRIMARY_RTS_GRAYSCALE.png','04_MAIN_HOUSE_MASONRY_CLOSE_GRAYSCALE.png','05_TEMPORARY_MASONRY_NODE_MATERIAL_ID.png','06_V0412_V0413_WIDE_COMPARISON.png','07_V0412_V0413_HOUSE_CLOSE_COMPARISON.png','v0413-preservation-audit.json')) {
  $source = Join-Path $root $file
  if (-not (Test-Path -LiteralPath $source)) { throw "Missing v0.413 capture: $file" }
  Copy-Item -LiteralPath $source -Destination (Join-Path $pack $file) -Force
}
Write-Output 'PASS_V0413_RENDERED_MAIN_HOUSE_MASONRY_VALUE_HIERARCHY'
