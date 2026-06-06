param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")

Set-Location $RepoRoot
node "tools/godot/workerBillboardSingleSlotTool.mjs" fallback:check
