param([string]$Repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path)
$godot = if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $Repo '.tools\godot\Godot_v4.6.3-stable_win64.exe' }
if (-not (Test-Path -LiteralPath $godot)) { throw "Missing Godot executable: $godot" }
$root = Join-Path $Repo 'desktop-spikes\godot-salto\artifacts\runtime\v0421'
$process = Start-Process -FilePath $godot -ArgumentList @('--path','desktop-spikes/godot-salto','--v0421-secondary-barn-entrance-frame-smoke','--artifact-root=artifacts/runtime/v0421') -WorkingDirectory $Repo -PassThru -Wait
if ($process.ExitCode -ne 0) { throw "Godot v0.421 smoke exited $($process.ExitCode)" }
if (-not (Test-Path -LiteralPath (Join-Path $root 'v0421-secondary-barn-entrance-frame-smoke.json'))) { throw 'Missing v0.421 smoke audit' }
Write-Output 'PASS_V0421_SECONDARY_BARN_ENTRANCE_FRAME_SMOKE'
