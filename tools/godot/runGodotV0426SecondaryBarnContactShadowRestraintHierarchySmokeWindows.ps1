param([string]$Repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path)
$godot = if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $Repo '.tools\godot\Godot_v4.6.3-stable_win64.exe' }
if (-not (Test-Path -LiteralPath $godot)) { throw "Missing Godot executable: $godot" }
& $godot --headless --path (Join-Path $Repo 'desktop-spikes\godot-salto') --v0426-secondary-barn-contact-shadow-smoke --artifact-root=artifacts/runtime/v0426
if ($LASTEXITCODE -ne 0) { throw "Godot v0.426 smoke exited $LASTEXITCODE" }
Write-Output 'PASS_V0426_SECONDARY_BARN_CONTACT_SHADOW_SMOKE'
