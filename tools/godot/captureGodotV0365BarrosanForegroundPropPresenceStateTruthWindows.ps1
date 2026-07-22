$ErrorActionPreference = 'Stop'
$repo = (Get-Location).Path
$project = Join-Path $repo 'desktop-spikes\godot-salto'
$godot = Join-Path $repo '.tools\godot\Godot_v4.6.3-stable_win64_console.exe'
$root = Join-Path $repo 'artifacts\runtime\v0365\capture'
if (Test-Path -LiteralPath $root) { Remove-Item -LiteralPath $root -Recurse -Force }
New-Item -ItemType Directory -Force -Path $root | Out-Null
$env:V0365_ARTIFACT_ROOT = $root.Replace('\','/')
$env:V0365_REPO_ROOT = $repo.Replace('\','/')
Push-Location $project
try {
  & $godot --path $project --rendering-method gl_compatibility --rendering-driver opengl3 --scene res://scenes/review/V0365BarrosanForegroundPropPresenceStateTruth.tscn --v0365-mode=all
  if ($LASTEXITCODE -ne 0) { throw "Godot v0.365 capture failed with exit code $LASTEXITCODE" }
} finally { Pop-Location }
Remove-Item Env:V0365_ARTIFACT_ROOT -ErrorAction SilentlyContinue
Remove-Item Env:V0365_REPO_ROOT -ErrorAction SilentlyContinue
Write-Output "PASS_V0365_CAPTURE $root"
