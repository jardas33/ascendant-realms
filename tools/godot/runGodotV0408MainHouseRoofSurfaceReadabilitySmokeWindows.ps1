param([string]$Repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path)
$godot = if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $Repo '.tools\godot\Godot_v4.6.3-stable_win64.exe' }
if (-not (Test-Path -LiteralPath $godot)) { throw "Missing Godot executable: $godot" }
Set-Location $Repo
$root = Join-Path $Repo 'desktop-spikes\godot-salto\artifacts\runtime\v0408'
New-Item -ItemType Directory -Force -Path $root | Out-Null
$process = Start-Process -FilePath $godot -ArgumentList @('--path','desktop-spikes/godot-salto','--v0408-main-house-roof-smoke','--artifact-root=artifacts/runtime/v0408') -WorkingDirectory $Repo -PassThru -Wait
if ($process.ExitCode -ne 0) { exit $process.ExitCode }
$audit = Join-Path $root 'v0408-main-house-roof-surface-readability-smoke.json'
if (-not (Test-Path -LiteralPath $audit)) { throw "Missing v0.408 smoke audit: $audit" }
Write-Output 'PASS_V0408_MAIN_HOUSE_ROOF_SURFACE_READABILITY_SMOKE'
