param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $RepoRoot
$Godot = Join-Path $RepoRoot ".tools\godot\Godot_v4.6.3-stable_win64.exe"
$Project = Join-Path $RepoRoot "desktop-spikes\godot-salto"
$CaptureRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0308\final-pre-integration-proof"
if (Test-Path -LiteralPath $CaptureRoot) { Remove-Item -LiteralPath $CaptureRoot -Recurse -Force }
New-Item -ItemType Directory -Force -Path $CaptureRoot | Out-Null
$GodotArgs = @('--path', $Project, '--scene', 'res://scenes/salto_v0308_route_c_final_pre_integration_proof.tscn', '--', "--artifact-root=$($CaptureRoot.Replace('\','/'))")
& $Godot @GodotArgs
$RuntimeManifest = Join-Path $CaptureRoot "v0308-route-c-final-pre-integration-proof-runtime.json"
if (-not (Test-Path -LiteralPath $RuntimeManifest)) { throw "v0.308 Godot capture did not write its manifest" }
$Python = "C:\Users\barro\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
if (!(Test-Path -LiteralPath $Python)) { $Python = (Get-Command python).Source }
& $Python "tools/godot/buildV0308RouteCFinalPreIntegrationProofPack.py"
if ($LASTEXITCODE -ne 0) { throw "v0.308 pack builder failed" }
node "tools/godot/saltoV0308RouteCFinalPreIntegrationProofTool.mjs"
if ($LASTEXITCODE -ne 0) { throw "v0.308 validator failed" }
Write-Output "PASS_V0308_ROUTE_C_FINAL_PRE_INTEGRATION_PROOF_CAPTURE_PACK_READY"
