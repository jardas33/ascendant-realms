param([string]$Repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path)
$root = Join-Path $Repo 'desktop-spikes\godot-salto\artifacts\runtime\v0427'
$pack = Join-Path $Repo 'artifacts\manual-review\v0427-resident-worker-primary-garment-value-hierarchy'
& (Join-Path $PSScriptRoot 'runGodotV0427ResidentWorkerPrimaryGarmentValueHierarchySmokeWindows.ps1') -Repo $Repo
$godot = if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $Repo '.tools\godot\Godot_v4.6.3-stable_win64.exe' }
if (-not (Test-Path -LiteralPath $godot)) { throw "Missing Godot executable: $godot" }
$process = Start-Process -FilePath $godot -ArgumentList @('--path','desktop-spikes/godot-salto','--v0427-resident-worker-primary-garment-capture','--artifact-root=artifacts/runtime/v0427') -WorkingDirectory $Repo -PassThru -Wait
if ($process.ExitCode -ne 0) { throw "Godot v0.427 capture exited $($process.ExitCode)" }
New-Item -ItemType Directory -Force -Path $pack | Out-Null
foreach ($capture in @('01_PRIMARY_RTS_COLOUR.png','02_RESIDENT_WORKER_GARMENT_CLOSE_COLOUR.png','03_THREE_CHARACTER_CONTEXT_COLOUR.png','04_RESIDENT_WORKER_GARMENT_CLOSE_GRAYSCALE.png','05_TEMPORARY_RESIDENT_WORKER_GARMENT_NODE_ID.png','06_V0426_V0427_WIDE_COMPARISON.png','07_V0426_V0427_WORKER_CLOSE_COMPARISON.png','v0427-preservation-audit.json')) {
  $source = Join-Path $root $capture
  if (-not (Test-Path -LiteralPath $source)) { throw "Missing v0.427 capture: $capture" }
  Copy-Item -LiteralPath $source -Destination (Join-Path $pack $capture) -Force
}
Write-Output 'PASS_V0427_RENDERED_RESIDENT_WORKER_PRIMARY_GARMENT_HIERARCHY'
