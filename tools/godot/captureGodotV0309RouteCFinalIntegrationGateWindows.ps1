param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $RepoRoot
$Godot = Join-Path $RepoRoot ".tools\godot\Godot_v4.6.3-stable_win64.exe"
$Project = Join-Path $RepoRoot "desktop-spikes\godot-salto"
$CaptureRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0309\final-integration-gate"
if (Test-Path -LiteralPath $CaptureRoot) { Remove-Item -LiteralPath $CaptureRoot -Recurse -Force }
New-Item -ItemType Directory -Force -Path $CaptureRoot | Out-Null
$GodotArgs = @('--path', $Project, '--scene', 'res://scenes/salto_v0309_route_c_final_integration_gate.tscn', '--', "--artifact-root=$($CaptureRoot.Replace('\','/'))")
& $Godot @GodotArgs
$RuntimeManifest = Join-Path $CaptureRoot "v0309-route-c-final-integration-gate-runtime.json"
if (-not (Test-Path -LiteralPath $RuntimeManifest)) { throw "v0.309 Godot capture did not write its manifest" }
$Python = "C:\Users\barro\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
if (!(Test-Path -LiteralPath $Python)) { $Python = (Get-Command python).Source }
& $Python "tools/godot/buildV0309RouteCFinalIntegrationGatePack.py"
if ($LASTEXITCODE -ne 0) { throw "v0.309 pack builder failed" }
node "tools/godot/saltoV0309RouteCFinalIntegrationGateTool.mjs"
if ($LASTEXITCODE -ne 0) { throw "v0.309 validator failed" }
Write-Output "PASS_V0309_ROUTE_C_FINAL_INTEGRATION_GATE_CAPTURE_PACK_READY"
