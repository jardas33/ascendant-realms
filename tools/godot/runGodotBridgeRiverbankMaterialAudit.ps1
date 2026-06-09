param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0189\evidence"
$ArtifactArg = $ArtifactRoot.Replace("\", "/")

Set-Location $RepoRoot
New-Item -ItemType Directory -Force -Path $ArtifactRoot | Out-Null
node "tools/godot/bridgeRiverbankMaterialSingleSlotTool.mjs" audit "--artifact-root=$ArtifactArg"
node "tools/godot/bridgeRiverbankMaterialSingleSlotTool.mjs" boundary "--artifact-root=$ArtifactArg"
