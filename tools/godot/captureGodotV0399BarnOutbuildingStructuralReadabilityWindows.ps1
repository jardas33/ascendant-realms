$ErrorActionPreference = 'Stop'
$repo = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$godot = if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $repo '.tools\godot\Godot_v4.6.3-stable_win64.exe' }
if (-not (Test-Path -LiteralPath $godot)) { throw "Missing Godot executable: $godot" }
Set-Location $repo
& $godot --path desktop-spikes/godot-salto --v0399-barn-structure-capture --artifact-root=artifacts/runtime/v0399
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
$root = Join-Path $repo 'desktop-spikes\godot-salto\artifacts\runtime\v0399'
$pack = Join-Path $repo 'artifacts\manual-review\v0399-barn-outbuilding-structural-readability'
New-Item -ItemType Directory -Force -Path $pack | Out-Null
foreach ($file in @('01_PRIMARY_RTS_VIEW.png','02_BARN_STRUCTURAL_CLOSE.png','03_GRAYSCALE_PRIMARY.png','04_BARN_STRUCTURAL_GRAYSCALE.png','05_V0398_V0399_PRIMARY_COMPARISON.png','v0399-barn-outbuilding-structural-readability.json')) { Copy-Item -LiteralPath (Join-Path $root $file) -Destination (Join-Path $pack $file) -Force }
Copy-Item -LiteralPath (Join-Path $repo 'docs\V0399_BARN_OUTBUILDING_STRUCTURAL_READABILITY_REPORT.md') -Destination (Join-Path $pack '06_ITERATION_SUMMARY.md') -Force
Copy-Item -LiteralPath (Join-Path $repo 'artifacts\manual-review\v0399-barn-outbuilding-structural-readability\07_VALIDATION.json') -Destination (Join-Path $pack '07_VALIDATION.json') -Force
Write-Output 'PASS_V0399_RENDERED_BARN_OUTBUILDING_STRUCTURAL_READABILITY'
exit 0
