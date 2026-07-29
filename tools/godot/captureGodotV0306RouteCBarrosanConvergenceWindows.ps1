param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $RepoRoot
$Godot = Join-Path $RepoRoot ".tools\godot\Godot_v4.6.3-stable_win64.exe"
$Project = Join-Path $RepoRoot "desktop-spikes\godot-salto"
$CaptureRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0306\route-c-convergence"
if (Test-Path $CaptureRoot) { Remove-Item $CaptureRoot -Recurse -Force }
New-Item -ItemType Directory -Force -Path $CaptureRoot | Out-Null
& $Godot --path $Project --scene "res://scenes/salto_v0306_route_c_barrosan_convergence.tscn" -- "--artifact-root=$($CaptureRoot.Replace('\','/'))"
if ($LASTEXITCODE -ne 0) { throw "v0.306 Godot capture failed with exit code $LASTEXITCODE" }
$Python = "C:\Users\barro\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
if (!(Test-Path $Python)) { $Python = (Get-Command python).Source }
& $Python "tools/godot/buildV0306RouteCBarrosanConvergencePack.py"
if ($LASTEXITCODE -ne 0) { throw "v0.306 pack builder failed" }
node "tools/godot/saltoV0306RouteCBarrosanConvergenceTool.mjs"
if ($LASTEXITCODE -ne 0) { throw "v0.306 validator failed" }
Write-Output "PASS_V0306_ROUTE_C_BARROSAN_CONVERGENCE_CAPTURE_PACK_READY"
