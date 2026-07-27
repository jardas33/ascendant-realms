$ErrorActionPreference = 'Stop'
$repo = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$godot = if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $repo '.tools\godot\Godot_v4.6.3-stable_win64.exe' }
if (-not (Test-Path -LiteralPath $godot)) { throw "Missing Godot executable: $godot" }
Set-Location $repo
$process = Start-Process -FilePath $godot -ArgumentList @('--path','desktop-spikes/godot-salto','--v0406-western-footing-smoke','--artifact-root=artifacts/runtime/v0406') -WorkingDirectory $repo -PassThru -Wait
if ($process.ExitCode -ne 0) { exit $process.ExitCode }
Write-Output 'PASS_V0406_EXACT_WESTERN_FOOTING_RING_SMOKE'
