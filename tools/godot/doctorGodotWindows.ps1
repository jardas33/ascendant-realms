param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $RepoRoot
node "desktop-spikes/godot-salto/tools/godotSpikeTool.mjs" doctor
