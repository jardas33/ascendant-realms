param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $RepoRoot

& (Join-Path $PSScriptRoot "runGodotTripleNaturalPlaythroughWindows.ps1")
& (Join-Path $PSScriptRoot "runGodotRtsErgonomicsSmokeWindows.ps1")
& (Join-Path $PSScriptRoot "runGodotUsabilityPresentationWindows.ps1")
& (Join-Path $PSScriptRoot "runGodotBlockoutQualityWindows.ps1")
& (Join-Path $PSScriptRoot "packageGodotWindows.ps1")
& (Join-Path $PSScriptRoot "runGodotBenchmark.ps1") -ScorecardOnly
npm run art:reference:validate
npm run art:reference:review-pack
node "tools/godot/generateGodotStabilizationReviewPack.mjs"
