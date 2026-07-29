param([string]$Repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path)
$godot = if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $Repo '.tools\godot\Godot_v4.6.3-stable_win64.exe' }
if (-not (Test-Path -LiteralPath $godot)) { throw "Missing Godot executable: $godot" }
$root = Join-Path $Repo 'desktop-spikes\godot-salto\artifacts\runtime\v0423'
$process = Start-Process -FilePath $godot -ArgumentList @('--headless','--path','desktop-spikes/godot-salto','--v0423-secondary-barn-side-beams-smoke','--artifact-root=artifacts/runtime/v0423') -WorkingDirectory $Repo -PassThru -Wait
if ($process.ExitCode -ne 0) { throw "Godot v0.423 smoke exited $($process.ExitCode)" }
if (-not (Test-Path -LiteralPath (Join-Path $root 'v0423-secondary-barn-side-beams-smoke.json'))) { throw 'Missing v0.423 smoke audit' }
Write-Output 'PASS_V0423_SECONDARY_BARN_SIDE_BEAMS_SMOKE'
