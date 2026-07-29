param([string]$Repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path)
$godot = if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $Repo '.tools\godot\Godot_v4.6.3-stable_win64.exe' }
if (-not (Test-Path -LiteralPath $godot)) { throw "Missing Godot executable: $godot" }
$root = Join-Path $Repo 'desktop-spikes\godot-salto\artifacts\runtime\v0424'
$process = Start-Process -FilePath $godot -ArgumentList @('--headless','--path','desktop-spikes/godot-salto','--v0424-secondary-barn-ridge-beam-smoke','--artifact-root=artifacts/runtime/v0424') -WorkingDirectory $Repo -PassThru -Wait
if ($process.ExitCode -ne 0) { throw "Godot v0.424 smoke exited $($process.ExitCode)" }
if (-not (Test-Path -LiteralPath (Join-Path $root 'v0424-secondary-barn-ridge-beam-smoke.json'))) { throw 'Missing v0.424 smoke audit' }
Write-Output 'PASS_V0424_SECONDARY_BARN_RIDGE_BEAM_SMOKE'
