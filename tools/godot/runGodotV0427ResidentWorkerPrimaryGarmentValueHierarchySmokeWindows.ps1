param([string]$Repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path)
$godot = if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $Repo '.tools\godot\Godot_v4.6.3-stable_win64.exe' }
if (-not (Test-Path -LiteralPath $godot)) { throw "Missing Godot executable: $godot" }
$process = Start-Process -FilePath $godot -ArgumentList @('--headless','--path','desktop-spikes/godot-salto','--v0427-resident-worker-primary-garment-smoke','--artifact-root=artifacts/runtime/v0427') -WorkingDirectory $Repo -PassThru -Wait
if ($process.ExitCode -ne 0) { throw "Godot v0.427 smoke exited $($process.ExitCode)" }
Write-Output 'PASS_V0427_RESIDENT_WORKER_PRIMARY_GARMENT_SMOKE'
