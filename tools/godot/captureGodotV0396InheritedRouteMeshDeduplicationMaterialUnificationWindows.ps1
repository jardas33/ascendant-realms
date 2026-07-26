$ErrorActionPreference = 'Stop'
$repo = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$godot = if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $repo '.tools\godot\Godot_v4.6.3-stable_win64.exe' }
if (-not (Test-Path -LiteralPath $godot)) { throw "Missing Godot executable: $godot" }
Set-Location $repo
& $godot --path desktop-spikes/godot-salto --v0396-route-mesh-capture --artifact-root=artifacts/runtime/v0396
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
$root = Join-Path $repo 'desktop-spikes\godot-salto\artifacts\runtime\v0396'
$required = @('01_PRIMARY_RTS_VIEW.png','02_CLOSE_ROUTE_YARD_DOORWAY.png','03_GRAYSCALE_PRIMARY.png','04_DIAGNOSTIC_INHERITED_ROUTE_MESH_ISOLATED.png','05_V0395_V0396_PRIMARY_COMPARISON.png')
foreach ($file in $required) { if (-not (Test-Path (Join-Path $root $file))) { throw "Missing v0.396 capture: $file" } }
Write-Output 'PASS_V0396_RENDERED_INHERITED_ROUTE_MESH_DEDUPLICATION_MATERIAL_UNIFICATION'
exit 0
