param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0150\evidence"
$ArtifactArg = $ArtifactRoot.Replace("\", "/")

Set-Location $RepoRoot
New-Item -ItemType Directory -Force -Path $ArtifactRoot | Out-Null
node "tools/godot/barracksMaterialSingleSlotTool.mjs" seam-repair:derivatives "--artifact-root=$ArtifactArg"
node "tools/godot/barracksMaterialSingleSlotTool.mjs" seam-repair:derivatives:check "--artifact-root=$ArtifactArg"
