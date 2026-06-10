param(
  [switch]$Wait,
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$RemainingArgs
)

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $RepoRoot

$GroundingPropsArgs = @(
  "--experimental-review-mode-label=Experimental opt-in: Salto shell v2 restrained grounding, lighting and sparse props",
  "--salto-shell-v2-grounding-props"
)
if ($RemainingArgs) {
  $GroundingPropsArgs += $RemainingArgs
}

Write-Output "Launching v0.205 Salto shell v2 restrained grounding, lighting and sparse props review."
Write-Output "QA scope: isolated shell-v2 review path only; visual-only procedural props; no generated images, no new art slots, no browser wiring."
Write-Output "v0.204 structure material, all prior launchers, and the procedural default launcher remain preserved."

& (Join-Path $PSScriptRoot "launchGodotSaltoShellV2StructureMaterialWindows.ps1") -Wait:$Wait @GroundingPropsArgs
