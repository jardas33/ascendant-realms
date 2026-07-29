$ErrorActionPreference = 'Stop'
$repo = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$godot = if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $repo '.tools\godot\Godot_v4.6.3-stable_win64.exe' }
if (-not (Test-Path -LiteralPath $godot)) { throw "Missing Godot executable: $godot" }
Set-Location $repo
New-Item -ItemType Directory -Force -Path (Join-Path $repo 'artifacts\runtime\v0377') | Out-Null
$arguments = @('--path', 'desktop-spikes/godot-salto', '--v0377-terrain-infrastructure-smoke', '--artifact-root=artifacts/runtime/v0377')
$process = Start-Process -FilePath $godot -ArgumentList $arguments -Wait -PassThru -NoNewWindow
if ($process.ExitCode -ne 0) { exit $process.ExitCode }
Write-Output 'PASS_V0377_TERRAIN_INFRASTRUCTURE_SMOKE'
