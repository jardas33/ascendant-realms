param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$GodotExe = if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $RepoRoot ".tools\godot\Godot_v4.6.3-stable_win64_console.exe" }
if (-not (Test-Path $GodotExe)) { throw "Missing Godot executable: $GodotExe" }
Set-Location $RepoRoot
$ArtifactRoot = Join-Path $RepoRoot "artifacts\manual-review\v0367-first-playable-vertical-slice"
New-Item -ItemType Directory -Force -Path $ArtifactRoot | Out-Null
$ArtifactArg = $ArtifactRoot.Replace("\", "/")
& $GodotExe --path desktop-spikes/godot-salto -- "--v0367-capture" "--artifact-root=$ArtifactArg"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
node tools/godot/saltoV0367FirstPlayableVerticalSliceTool.mjs pack
