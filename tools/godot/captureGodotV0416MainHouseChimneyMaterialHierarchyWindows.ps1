param([string]$Repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path)
$root = Join-Path $Repo 'desktop-spikes\godot-salto\artifacts\runtime\v0416'
$pack = Join-Path $Repo 'artifacts\manual-review\v0416-main-house-chimney-material-hierarchy'
& (Join-Path $PSScriptRoot 'runGodotV0416MainHouseChimneyMaterialHierarchySmokeWindows.ps1') -Repo $Repo
$godot = if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $Repo '.tools\godot\Godot_v4.6.3-stable_win64.exe' }
if (-not (Test-Path -LiteralPath $godot)) { throw "Missing Godot executable: $godot" }
$process = Start-Process -FilePath $godot -ArgumentList @('--path','desktop-spikes/godot-salto','--v0416-main-house-chimney-capture','--artifact-root=artifacts/runtime/v0416') -WorkingDirectory $Repo -PassThru -Wait
if ($process.ExitCode -ne 0) { throw "Godot v0.416 capture exited $($process.ExitCode)" }
New-Item -ItemType Directory -Force -Path $pack | Out-Null
foreach ($file in @('01_PRIMARY_RTS_COLOUR.png','02_MAIN_HOUSE_CHIMNEY_CLOSE_COLOUR.png','03_PRIMARY_RTS_GRAYSCALE.png','04_MAIN_HOUSE_CHIMNEY_CLOSE_GRAYSCALE.png','05_TEMPORARY_CHIMNEY_NODE_ID.png','06_V0415_V0416_WIDE_COMPARISON.png','07_V0415_V0416_CHIMNEY_CLOSE_COMPARISON.png','v0416-preservation-audit.json')) {
  $source = Join-Path $root $file
  if (-not (Test-Path -LiteralPath $source)) { throw "Missing v0.416 capture: $file" }
  Copy-Item -LiteralPath $source -Destination (Join-Path $pack $file) -Force
}
Write-Output 'PASS_V0416_RENDERED_MAIN_HOUSE_CHIMNEY_MATERIAL_HIERARCHY'
