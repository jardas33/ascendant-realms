$ErrorActionPreference = 'Stop'
$repo = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$godot = if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $repo '.tools\godot\Godot_v4.6.3-stable_win64.exe' }
if (-not (Test-Path -LiteralPath $godot)) { throw "Missing Godot executable: $godot" }
Set-Location $repo
$artifact = Join-Path $repo 'artifacts\runtime\v0370'
$godotArtifact = Join-Path $repo 'desktop-spikes\godot-salto\artifacts\runtime\v0370'
New-Item -ItemType Directory -Force -Path $artifact | Out-Null
$arguments = @('--path', 'desktop-spikes/godot-salto', '--v0370-quaternius-capture', '--artifact-root=artifacts/runtime/v0370')
$process = Start-Process -FilePath $godot -ArgumentList $arguments -Wait -PassThru -NoNewWindow
if ($process.ExitCode -ne 0) { exit $process.ExitCode }
$pack = Join-Path $repo 'artifacts\manual-review\v0370-quaternius-cohesive-art-family-proof'
New-Item -ItemType Directory -Force -Path $pack | Out-Null
foreach($name in @('01_QUATERNIUS_WIDE.png','02_QUATERNIUS_RTS_CAMERA.png','03_QUATERNIUS_CLOSE_DETAIL.png','04_QUATERNIUS_BRIDGE_CONTACT.png','05_QUATERNIUS_HOSTILE_CAMP.png')) {
  $source = Join-Path $godotArtifact $name
  if (-not (Test-Path -LiteralPath $source)) { throw "Missing raw v0.370 capture: $name" }
  Copy-Item -LiteralPath $source -Destination (Join-Path $artifact $name) -Force
  Copy-Item -LiteralPath $source -Destination (Join-Path $pack $name) -Force
}
