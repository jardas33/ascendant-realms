param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0175\evidence"
$ArtifactArg = $ArtifactRoot.Replace("\", "/")

Set-Location $RepoRoot
New-Item -ItemType Directory -Force -Path $ArtifactRoot | Out-Null
node "tools/godot/groundMaterialSingleSlotTool.mjs" derivatives "--artifact-root=$ArtifactArg"
node "tools/godot/groundMaterialSingleSlotTool.mjs" derivatives:check "--artifact-root=$ArtifactArg"
