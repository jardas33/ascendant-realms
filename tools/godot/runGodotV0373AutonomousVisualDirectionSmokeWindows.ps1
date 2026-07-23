$ErrorActionPreference = 'Stop'
$repo = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$godot = if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $repo '.tools\godot\Godot_v4.6.3-stable_win64.exe' }
if (-not (Test-Path -LiteralPath $godot)) { throw "Missing Godot executable: $godot" }
Set-Location $repo
New-Item -ItemType Directory -Force -Path (Join-Path $repo 'artifacts\runtime\v0373') | Out-Null
& $godot '--path' 'desktop-spikes/godot-salto' '--v0373-autonomous-smoke' '--artifact-root=artifacts/runtime/v0373'
exit $LASTEXITCODE
