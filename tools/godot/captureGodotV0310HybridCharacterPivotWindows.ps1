param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $RepoRoot
$Godot = Join-Path $RepoRoot ".tools\godot\Godot_v4.6.3-stable_win64.exe"
$Project = Join-Path $RepoRoot "desktop-spikes\godot-salto"
$CaptureRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0310\hybrid-character-pivot"
if (Test-Path -LiteralPath $CaptureRoot) { Remove-Item -LiteralPath $CaptureRoot -Recurse -Force }
New-Item -ItemType Directory -Force -Path $CaptureRoot | Out-Null
$GodotArgs = @('--path', $Project, '--scene', 'res://scenes/salto_v0310_hybrid_character_pivot.tscn', '--', "--artifact-root=$($CaptureRoot.Replace('\','/'))")
& $Godot @GodotArgs
$RuntimeManifest = Join-Path $CaptureRoot "v0310-hybrid-character-pivot-runtime.json"
if (-not (Test-Path -LiteralPath $RuntimeManifest)) { throw "v0.310 Godot capture did not write its manifest" }
$Python = "C:\Users\barro\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
if (!(Test-Path -LiteralPath $Python)) { $Python = (Get-Command python -ErrorAction Stop).Source }
& $Python "tools/godot/buildV0310HybridCharacterPivotPack.py"
if ($LASTEXITCODE -ne 0) { throw "v0.310 pack builder failed" }
node "tools/godot/saltoV0310HybridCharacterPivotTool.mjs"
if ($LASTEXITCODE -ne 0) { throw "v0.310 validator failed" }
Write-Output "PASS_V0310_HYBRID_CHARACTER_PIVOT_CAPTURE_PACK_READY"
