param()
$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $RepoRoot

node tools/godot/saltoV0275BarrosanPostContactLabelArbitrationHudFirstReadabilityTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0275"
if ($LASTEXITCODE -ne 0) { throw "v0.275 Post-Contact Label Arbitration HUD-First Readability validation failed." }

Write-Output "PASS_V0275_BARROSAN_POST_CONTACT_LABEL_ARBITRATION_HUD_FIRST_READABILITY_VALIDATION"
