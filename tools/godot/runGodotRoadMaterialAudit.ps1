param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0180\evidence"
$ArtifactArg = $ArtifactRoot.Replace("\", "/")

Set-Location $RepoRoot
New-Item -ItemType Directory -Force -Path $ArtifactRoot | Out-Null
node "tools/godot/roadMaterialSingleSlotTool.mjs" audit "--artifact-root=$ArtifactArg"
node "tools/godot/roadMaterialSingleSlotTool.mjs" boundary "--artifact-root=$ArtifactArg"
