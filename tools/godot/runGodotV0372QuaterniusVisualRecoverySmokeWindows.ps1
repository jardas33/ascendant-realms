$ErrorActionPreference = 'Stop'
$repo = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$godot = if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $repo '.tools\godot\Godot_v4.6.3-stable_win64.exe' }
if (-not (Test-Path -LiteralPath $godot)) { throw "Missing Godot executable: $godot" }
Set-Location $repo
& $godot --headless --path desktop-spikes/godot-salto --v0372-quaternius-smoke --artifact-root=artifacts/runtime/v0372
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Output 'PASS_V0372_QUATERNIUS_VISUAL_RECOVERY_SMOKE'
