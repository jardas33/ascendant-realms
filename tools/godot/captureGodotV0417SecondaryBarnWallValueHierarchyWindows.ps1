param([string]$Repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path)
$root = Join-Path $Repo 'desktop-spikes\godot-salto\artifacts\runtime\v0417'
$pack = Join-Path $Repo 'artifacts\manual-review\v0417-secondary-barn-wall-value-hierarchy'
& (Join-Path $PSScriptRoot 'runGodotV0417SecondaryBarnWallValueHierarchySmokeWindows.ps1') -Repo $Repo
$godot = if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $Repo '.tools\godot\Godot_v4.6.3-stable_win64.exe' }
if (-not (Test-Path -LiteralPath $godot)) { throw "Missing Godot executable: $godot" }
$process = Start-Process -FilePath $godot -ArgumentList @('--path','desktop-spikes/godot-salto','--v0417-secondary-barn-walls-capture','--artifact-root=artifacts/runtime/v0417') -WorkingDirectory $Repo -PassThru -Wait
if ($process.ExitCode -ne 0) { throw "Godot v0.417 capture exited $($process.ExitCode)" }
New-Item -ItemType Directory -Force -Path $pack | Out-Null
foreach ($file in @('01_PRIMARY_RTS_COLOUR.png','02_SECONDARY_BARN_WALLS_CLOSE_COLOUR.png','03_PRIMARY_RTS_GRAYSCALE.png','04_SECONDARY_BARN_WALLS_CLOSE_GRAYSCALE.png','05_TEMPORARY_BARN_WALL_NODE_ID.png','06_V0416_V0417_WIDE_COMPARISON.png','07_V0416_V0417_BARN_CLOSE_COMPARISON.png','v0417-preservation-audit.json')) {
  $source = Join-Path $root $file
  if (-not (Test-Path -LiteralPath $source)) { throw "Missing v0.417 capture: $file" }
  Copy-Item -LiteralPath $source -Destination (Join-Path $pack $file) -Force
}
Write-Output 'PASS_V0417_RENDERED_SECONDARY_BARN_WALL_MATERIAL_HIERARCHY'
