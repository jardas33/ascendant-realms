$ErrorActionPreference = 'Stop'
$repo = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$godot = if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $repo '.tools\godot\Godot_v4.6.3-stable_win64.exe' }
if (-not (Test-Path -LiteralPath $godot)) { throw "Missing Godot executable: $godot" }
Set-Location $repo
$source = Join-Path $repo 'desktop-spikes\godot-salto\artifacts\runtime\v0373'
$target = if ($env:V0373_OUTPUT_ROOT) { Join-Path $repo $env:V0373_OUTPUT_ROOT } else { Join-Path $repo 'artifacts\runtime\v0373' }
$iteration = if ($env:V0373_ITERATION) { $env:V0373_ITERATION } else { '1' }
New-Item -ItemType Directory -Force -Path $target | Out-Null
$arguments = @('--path', 'desktop-spikes/godot-salto', '--v0373-autonomous-capture', '--artifact-root=artifacts/runtime/v0373', "--v0373-iteration=$iteration")
$process = Start-Process -FilePath $godot -ArgumentList $arguments -Wait -PassThru -NoNewWindow
if ($process.ExitCode -ne 0) { exit $process.ExitCode }
foreach ($name in @('01_FINAL_PRIMARY_RTS_COMPOSITION.png','02_FINAL_SETTLEMENT_AND_RESOURCE.png','03_FINAL_BRIDGE_AND_HOSTILE_CAMP.png','04_FINAL_TOPDOWN_SPACING_AUDIT.png','v0373-autonomous-visual-direction.json')) {
  $file = Join-Path $source $name
  if (-not (Test-Path -LiteralPath $file)) { throw "Missing raw v0.373 capture: $name" }
  Copy-Item -LiteralPath $file -Destination (Join-Path $target $name) -Force
}
if (-not $env:V0373_SKIP_PACK) { node tools/godot/saltoV0373AutonomousVisualDirectionTool.mjs pack; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }; node tools/godot/saltoV0373AutonomousVisualDirectionTool.mjs validate; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE } }
Write-Output "PASS_V0373_RENDERED_ITERATION_$iteration"
