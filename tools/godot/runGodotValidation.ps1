param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $RepoRoot
npm run export:desktop-spike-fixture
npm run validate:desktop-spike-fixture
node "desktop-spikes/godot-salto/tools/godotSpikeTool.mjs" generate
node "desktop-spikes/godot-salto/tools/godotSpikeTool.mjs" validate
