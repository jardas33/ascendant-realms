$ErrorActionPreference = 'Stop'
$repo = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$godot = if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $repo '.tools\godot\Godot_v4.6.3-stable_win64.exe' }
if (-not (Test-Path -LiteralPath $godot)) { throw "Missing Godot executable: $godot" }
Set-Location $repo
$artifact = Join-Path $repo 'artifacts\runtime\v0372'
$godotArtifact = Join-Path $repo 'desktop-spikes\godot-salto\artifacts\runtime\v0372'
$pack = Join-Path $repo 'artifacts\manual-review\v0372-quaternius-rts-visual-recovery'
New-Item -ItemType Directory -Force -Path $artifact | Out-Null
New-Item -ItemType Directory -Force -Path $pack | Out-Null
$arguments = @('--path', 'desktop-spikes/godot-salto', '--v0372-quaternius-capture', '--artifact-root=artifacts/runtime/v0372')
$process = Start-Process -FilePath $godot -ArgumentList $arguments -Wait -PassThru -NoNewWindow
if ($process.ExitCode -ne 0) { exit $process.ExitCode }
foreach($name in @('01_PRIMARY_RTS_COMPOSITION.png','02_CLOSER_SETTLEMENT_AND_RESOURCE.png','03_BRIDGE_AND_HOSTILE_CAMP.png','04_TOPDOWN_SPACING_AUDIT.png')) {
  $source = Join-Path $godotArtifact $name
  if (-not (Test-Path -LiteralPath $source)) { throw "Missing raw v0.372 capture: $name" }
  Copy-Item -LiteralPath $source -Destination (Join-Path $artifact $name) -Force
  Copy-Item -LiteralPath $source -Destination (Join-Path $pack $name) -Force
}
node tools/godot/saltoV0372QuaterniusVisualRecoveryTool.mjs pack
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
node tools/godot/saltoV0372QuaterniusVisualRecoveryTool.mjs validate
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Output 'PASS_V0372_QUATERNIUS_VISUAL_RECOVERY_PACK'
