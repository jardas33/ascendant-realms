$ErrorActionPreference = 'Stop'
$repo = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$godot = if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $repo '.tools\godot\Godot_v4.6.3-stable_win64_console.exe' }
if (-not (Test-Path -LiteralPath $godot)) { throw "Missing Godot executable: $godot" }
Set-Location $repo
$artifact = Join-Path $repo 'artifacts\runtime\v0368'; New-Item -ItemType Directory -Force -Path $artifact | Out-Null
& $godot --headless --path desktop-spikes/godot-salto --v0368-smoke "--artifact-root=$($artifact.Replace('\','/'))"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
node tools/godot/saltoV0368PlayableSliceVisualCoherenceTool.mjs smoke
