$ErrorActionPreference = 'Stop'
$repo = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$godot = if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $repo '.tools\godot\Godot_v4.6.3-stable_win64.exe' }
if (-not (Test-Path -LiteralPath $godot)) { throw "Missing Godot executable: $godot" }
Set-Location $repo
$artifact = Join-Path $repo 'artifacts\runtime\v0368'; New-Item -ItemType Directory -Force -Path $artifact | Out-Null
& $godot --path desktop-spikes/godot-salto --v0368-capture "--artifact-root=$($artifact.Replace('\','/'))"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
$pack = Join-Path $repo 'artifacts\manual-review\v0368-playable-slice-visual-coherence'
New-Item -ItemType Directory -Force -Path $pack | Out-Null
for($attempt=0; $attempt -lt 80; $attempt++) { $missing = @('01_POLISHED_SLICE_START.png','02_GATHERING_AND_CONSTRUCTION.png','03_COMPLETED_SETTLEMENT_AND_MILITIA.png','04_COMBAT_AND_VICTORY.png') | Where-Object { -not (Test-Path -LiteralPath (Join-Path $artifact $_)) }; if($missing.Count -eq 0){ break }; Start-Sleep -Milliseconds 250 }
foreach($name in @('01_POLISHED_SLICE_START.png','02_GATHERING_AND_CONSTRUCTION.png','03_COMPLETED_SETTLEMENT_AND_MILITIA.png','04_COMBAT_AND_VICTORY.png')) { Copy-Item -LiteralPath (Join-Path $artifact $name) -Destination (Join-Path $pack $name) -Force }
node tools/godot/saltoV0368PlayableSliceVisualCoherenceTool.mjs pack
