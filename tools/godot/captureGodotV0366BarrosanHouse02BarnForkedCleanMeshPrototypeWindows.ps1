$ErrorActionPreference = 'Stop'
$repo = (Get-Location).Path
$project = Join-Path $repo 'desktop-spikes\godot-salto'
$godot = Join-Path $repo '.tools\godot\Godot_v4.6.3-stable_win64_console.exe'
$root = Join-Path $repo 'artifacts\runtime\v0366\capture'
if (Test-Path -LiteralPath $root) { Remove-Item -LiteralPath $root -Recurse -Force }
New-Item -ItemType Directory -Force -Path $root | Out-Null
$env:V0366_ARTIFACT_ROOT = $root.Replace('\','/')
$env:V0366_REPO_ROOT = $repo.Replace('\','/')
Push-Location $project
try {
  & $godot --path $project --rendering-method gl_compatibility --rendering-driver opengl3 --scene res://scenes/rework/barrosan/v0366/V0366BarrosanHouse02AndBarnForkedCleanMeshPrototype.tscn
  if ($LASTEXITCODE -ne 0) { throw "Godot v0.366 capture failed with exit code $LASTEXITCODE" }
} finally { Pop-Location }
Remove-Item Env:V0366_ARTIFACT_ROOT -ErrorAction SilentlyContinue
Remove-Item Env:V0366_REPO_ROOT -ErrorAction SilentlyContinue
Write-Output "PASS_V0366_CAPTURE $root"
