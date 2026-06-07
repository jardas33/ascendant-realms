param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0155\evidence"
$ArtifactArg = $ArtifactRoot.Replace("\", "/")

Set-Location $RepoRoot
New-Item -ItemType Directory -Force -Path $ArtifactRoot | Out-Null

node "tools/godot/militiaBillboardSingleSlotTool.mjs" repair:audit "--artifact-root=$ArtifactArg"
if ($LASTEXITCODE -ne 0) { throw "Militia billboard repair audit failed." }
