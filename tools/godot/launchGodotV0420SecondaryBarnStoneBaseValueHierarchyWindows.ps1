param([string]$Repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path)
$godot = if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $Repo '.tools\godot\Godot_v4.6.3-stable_win64.exe' }
if (-not (Test-Path -LiteralPath $godot)) { throw "Missing Godot executable: $godot" }
Start-Process -FilePath $godot -ArgumentList @('--path','desktop-spikes/godot-salto','--v0420-secondary-barn-stone-base-capture','--artifact-root=artifacts/runtime/v0420') -WorkingDirectory $Repo
