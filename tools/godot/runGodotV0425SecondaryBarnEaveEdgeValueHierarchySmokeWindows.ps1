param([string]$Repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path)
$godot = if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $Repo '.tools\godot\Godot_v4.6.3-stable_win64.exe' }
if (-not (Test-Path -LiteralPath $godot)) { throw "Missing Godot executable: $godot" }
& $godot --headless --path (Join-Path $Repo 'desktop-spikes\godot-salto') --v0425-secondary-barn-eaves-smoke --artifact-root=artifacts/runtime/v0425
if ($LASTEXITCODE -ne 0) { throw "Godot v0.425 smoke exited $LASTEXITCODE" }
Write-Output 'PASS_V0425_SECONDARY_BARN_EAVES_SMOKE'
