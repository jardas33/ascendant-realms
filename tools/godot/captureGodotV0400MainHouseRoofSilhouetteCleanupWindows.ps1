$ErrorActionPreference = 'Stop'
$repo = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$godot = if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $repo '.tools\godot\Godot_v4.6.3-stable_win64.exe' }
if (-not (Test-Path -LiteralPath $godot)) { throw "Missing Godot executable: $godot" }
Set-Location $repo
& $godot --path desktop-spikes/godot-salto --v0400-house-roof-capture --artifact-root=artifacts/runtime/v0400
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
$root = Join-Path $repo 'desktop-spikes\godot-salto\artifacts\runtime\v0400'
$pack = Join-Path $repo 'artifacts\manual-review\v0400-main-house-roof-silhouette-cleanup'
New-Item -ItemType Directory -Force -Path $pack | Out-Null
foreach ($file in @('01_PRIMARY_RTS_VIEW.png','02_MAIN_HOUSE_ROOF_CLOSE.png','03_GRAYSCALE_PRIMARY.png','04_MAIN_HOUSE_ROOF_GRAYSCALE.png','05_V0399_V0400_PRIMARY_COMPARISON.png','v0400-main-house-roof-silhouette-cleanup.json')) { Copy-Item -LiteralPath (Join-Path $root $file) -Destination (Join-Path $pack $file) -Force }
Copy-Item -LiteralPath (Join-Path $repo 'docs\V0400_MAIN_HOUSE_ROOF_SILHOUETTE_CLEANUP_REPORT.md') -Destination (Join-Path $pack '06_ITERATION_SUMMARY.md') -Force
Copy-Item -LiteralPath (Join-Path $repo 'artifacts\manual-review\v0400-main-house-roof-silhouette-cleanup\07_VALIDATION.json') -Destination (Join-Path $pack '07_VALIDATION.json') -Force
Write-Output 'PASS_V0400_RENDERED_MAIN_HOUSE_ROOF_SILHOUETTE_CLEANUP'
exit 0
