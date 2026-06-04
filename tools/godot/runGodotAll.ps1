param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $RepoRoot

& (Join-Path $PSScriptRoot "doctorGodotWindows.ps1")
& (Join-Path $PSScriptRoot "runGodotValidation.ps1")
& (Join-Path $PSScriptRoot "generateGodotSaltoScene.ps1")
& (Join-Path $PSScriptRoot "runGodotTests.ps1")
& (Join-Path $PSScriptRoot "runGodotBenchmark.ps1")
& (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
& (Join-Path $PSScriptRoot "packageGodotWindows.ps1")
& (Join-Path $PSScriptRoot "runGodotBenchmark.ps1") -ScorecardOnly
node "desktop-spikes/godot-salto/tools/godotSpikeTool.mjs" manual-review
