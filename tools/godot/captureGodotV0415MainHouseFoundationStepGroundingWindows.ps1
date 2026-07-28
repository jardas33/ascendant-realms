param([string]$Repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path)
$root = Join-Path $Repo 'desktop-spikes\godot-salto\artifacts\runtime\v0415'
$pack = Join-Path $Repo 'artifacts\manual-review\v0415-main-house-foundation-step-grounding'
& (Join-Path $PSScriptRoot 'runGodotV0415MainHouseFoundationStepGroundingSmokeWindows.ps1') -Repo $Repo
$godot = if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $Repo '.tools\godot\Godot_v4.6.3-stable_win64.exe' }
if (-not (Test-Path -LiteralPath $godot)) { throw "Missing Godot executable: $godot" }
$process = Start-Process -FilePath $godot -ArgumentList @('--path','desktop-spikes/godot-salto','--v0415-main-house-foundation-step-capture','--artifact-root=artifacts/runtime/v0415') -WorkingDirectory $Repo -PassThru -Wait
if ($process.ExitCode -ne 0) { throw "Godot v0.415 capture exited $($process.ExitCode)" }
New-Item -ItemType Directory -Force -Path $pack | Out-Null
foreach ($file in @('01_PRIMARY_RTS_COLOUR.png','02_MAIN_HOUSE_FOUNDATION_STEPS_CLOSE_COLOUR.png','03_PRIMARY_RTS_GRAYSCALE.png','04_MAIN_HOUSE_FOUNDATION_STEPS_CLOSE_GRAYSCALE.png','05_TEMPORARY_FOUNDATION_STEP_NODE_ID.png','06_V0414_V0415_WIDE_COMPARISON.png','07_V0414_V0415_FOUNDATION_CLOSE_COMPARISON.png','v0415-preservation-audit.json')) {
  $source = Join-Path $root $file
  if (-not (Test-Path -LiteralPath $source)) { throw "Missing v0.415 capture: $file" }
  Copy-Item -LiteralPath $source -Destination (Join-Path $pack $file) -Force
}
Write-Output 'PASS_V0415_RENDERED_MAIN_HOUSE_FOUNDATION_STEP_GROUNDING'
