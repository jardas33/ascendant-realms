param([string]$Repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path)
$godot = if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $Repo '.tools\godot\Godot_v4.6.3-stable_win64.exe' }
if (-not (Test-Path -LiteralPath $godot)) { throw "Missing Godot executable: $godot" }
Set-Location $Repo
$root = Join-Path $Repo 'desktop-spikes\godot-salto\artifacts\runtime\v0411'
New-Item -ItemType Directory -Force -Path $root | Out-Null
$process = Start-Process -FilePath $godot -ArgumentList @('--path','desktop-spikes/godot-salto','--v0411-bridge-rail-post-smoke','--artifact-root=artifacts/runtime/v0411') -WorkingDirectory $Repo -PassThru -Wait
if ($process.ExitCode -ne 0) { exit $process.ExitCode }
if (-not (Test-Path -LiteralPath (Join-Path $root 'v0411-bridge-rail-post-smoke.json'))) { throw 'Missing v0.411 smoke audit' }
Write-Output 'PASS_V0411_BRIDGE_RAIL_POST_VALUE_HIERARCHY_SMOKE'
